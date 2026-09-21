"""
Dual-Mode Excel Timetable Ingestion Service.
Supports:
1. DEV MODE: Reading from local file (data/timetable.xlsx).
2. PROD MODE: Live download from Google Sheets export URL.
"""
import os
import io
import re
import logging
import openpyxl
import requests
from pathlib import Path
from django.conf import settings

logger = logging.getLogger(__name__)

def load_workbook_source():
    """
    Loads openpyxl Workbook according to environment configuration:
    - If settings.TIMETABLE_SOURCE == 'google_sheets' and GOOGLE_SHEET_URL is set:
      downloads live XLSX from Google Sheets.
    - Otherwise: loads local data/timetable.xlsx.
    """
    source_type = getattr(settings, 'TIMETABLE_SOURCE', 'local')
    sheet_url = getattr(settings, 'GOOGLE_SHEET_URL', None) or os.getenv('GOOGLE_SHEET_URL')

    if source_type == 'google_sheets' and sheet_url:
        try:
            logger.info(f"Fetching live timetable from Google Sheets: {sheet_url}")
            # Format export URL if standard /edit link is provided
            export_url = sheet_url
            if '/edit' in export_url:
                export_url = export_url.split('/edit')[0] + '/export?format=xlsx'

            resp = requests.get(export_url, timeout=30)
            resp.raise_for_status()
            return openpyxl.load_workbook(io.BytesIO(resp.content), data_only=True)
        except Exception as e:
            logger.error(f"Failed to fetch live Google Sheet, falling back to local file: {e}")

    # Local fallback / DEV mode
    local_path = getattr(settings, 'DATA_EXCEL_PATH', Path(settings.BASE_DIR).parent / 'data' / 'timetable.xlsx')
    if not os.path.exists(local_path):
        # Alternative path check
        local_path = Path(settings.BASE_DIR) / '..' / 'data' / 'timetable.xlsx'

    if not os.path.exists(local_path):
        raise FileNotFoundError(f"Timetable workbook not found at: {local_path}")

    logger.info(f"Loading local timetable workbook from: {local_path}")
    return openpyxl.load_workbook(local_path, data_only=True)

def find_primary_schedule_sheet(wb):
    """
    Finds the most appropriate schedule sheet in the workbook.
    Prioritizes latest 2026/2025 month sheets (e.g. '2026年4月', '2026年3月').
    """
    sheet_names = wb.sheetnames

    # Priority target: active 2026 month sheets
    priority_sheets = ['2026年4月', '2026年5月', '2026年3月', '2026年9月', '2025年10月']
    for p in priority_sheets:
        if p in sheet_names:
            return wb[p], p

    # Match any year/month sheet excluding copies and drafts
    for s in sheet_names:
        if ('年' in s and '月' in s) and not any(skip in s.lower() for skip in ['copy', 'draft', 'classrooms']):
            return wb[s], s

    # Default to first sheet
    return wb[sheet_names[0]], sheet_names[0]

def extract_raw_schedule_rows(sheet):
    """
    Parses the grid structure of the schedule sheet.
    Maps weekday, period, timeslot, and extracts class cells for each student group.
    """
    rows = list(sheet.iter_rows(values_only=True))
    if not rows or len(rows) < 4:
        return []

    # 1. Identify group column headers from row 0
    header_row = rows[0]
    group_col_map = {} # col_index -> group_code (e.g. 17 -> "23D")

    for col_idx, cell in enumerate(header_row):
        val = str(cell or '').strip()
        if not val:
            continue
        # Check if cell matches a known group pattern (e.g. 23D, 23E, 24A, 22A, 25A)
        match = re.search(r'\b(2[2-5][A-Z])\b', val)
        if match:
            group_col_map[col_idx] = match.group(1)

    logger.info(f"Discovered group column mappings: {group_col_map}")

    # 2. Iterate through schedule rows and track current weekday
    extracted_entries = []
    current_day_str = "Chorshanba"
    current_day_idx = 2

    DAY_MAPPING = {
        '月': (0, 'Dushanba'),
        '火': (1, 'Seshanba'),
        '水': (2, 'Chorshanba'),
        '木': (3, 'Payshanba'),
        '金': (4, 'Juma'),
        '土': (5, 'Shanba'),
        '日': (6, 'Yakshanba'),
        'dush': (0, 'Dushanba'),
        'sesh': (1, 'Seshanba'),
        'chor': (2, 'Chorshanba'),
        'pay': (3, 'Payshanba'),
        'jum': (4, 'Juma'),
        'shan': (5, 'Shanba'),
    }

    # Start after headers (row index 4 or 5)
    for r_idx in range(4, len(rows)):
        row = rows[r_idx]
        if not row:
            continue

        # Check column 1 for Day change
        day_cell = str(row[1] or '').strip()
        for key, (d_idx, d_name) in DAY_MAPPING.items():
            if key in day_cell.lower():
                current_day_str = d_name
                current_day_idx = d_idx
                break

        # Check period in column 2
        period_cell = str(row[2] or '').strip()
        period = None
        period_match = re.search(r'(\d+)', period_cell)
        if period_match:
            period = int(period_match.group(1))

        if not period or period < 1 or period > 7:
            continue

        # Check time range in column 3
        time_cell = str(row[3] or '').strip().replace('\n', ' ')
        start_time_str = "09:00"
        end_time_str = "10:15"

        times = re.findall(r'(\d{1,2}:\d{2})', time_cell)
        if len(times) >= 2:
            start_time_str = times[0]
            end_time_str = times[1]
        elif period == 1:
            start_time_str, end_time_str = "09:00", "10:15"
        elif period == 2:
            start_time_str, end_time_str = "10:25", "11:40"
        elif period == 3:
            start_time_str, end_time_str = "11:50", "13:05"
        elif period == 4:
            start_time_str, end_time_str = "13:50", "15:05"
        elif period == 5:
            start_time_str, end_time_str = "15:15", "16:30"
        elif period == 6:
            start_time_str, end_time_str = "16:40", "17:55"

        # 3. Extract class text for each mapped group
        for col_idx, group_code in group_col_map.items():
            if col_idx < len(row):
                cell_val = str(row[col_idx] or '').strip()
                if cell_val and len(cell_val) > 2:
                    extracted_entries.append({
                        'day_index': current_day_idx,
                        'day_name': current_day_str,
                        'period': period,
                        'start_time': start_time_str,
                        'end_time': end_time_str,
                        'group': group_code,
                        'raw_cell_content': cell_val
                    })

    return extracted_entries
