"""
Management Command: sync_timetable
Ingests university schedule from local Excel or live Google Sheets,
parses cells with AI / heuristic engine, and saves structured TimetableEntry records to the database.
"""
import os
import datetime
import logging
from django.core.management.base import BaseCommand
from django.conf import settings
from apps.timetable.models import TimetableEntry
from apps.timetable.services.excel_reader import (
    load_workbook_source,
    find_primary_schedule_sheet,
    extract_raw_schedule_rows
)
from apps.timetable.services.ai_parser import (
    parse_with_gemini,
    parse_with_heuristics
)

logger = logging.getLogger(__name__)

class Command(BaseCommand):
    help = "Sync timetable classes from Excel or live Google Sheets into the database."

    def add_arguments(self, parser):
        parser.add_argument('--sheet', type=str, help='Specific sheet name to sync (e.g. 2026年4月)')
        parser.add_argument('--clear', action='store_true', help='Clear existing semester records before sync')

    def handle(self, *args, **options):
        self.stdout.write("[*] Starting Timetable Synchronization...")

        try:
            wb = load_workbook_source()
        except Exception as e:
            self.stderr.write(f"[-] Error loading workbook: {e}")
            return

        sheet_name = options.get('sheet')
        if sheet_name:
            if sheet_name not in wb.sheetnames:
                self.stderr.write(f"[-] Sheet '{sheet_name}' not found in workbook. Available: {wb.sheetnames}")
                return
            sheet = wb[sheet_name]
        else:
            sheet, sheet_name = find_primary_schedule_sheet(wb)

        # Normalize semester code from sheet name (e.g. '2026年4月' -> '2026_04')
        semester = "2026_04"
        if "2026" in sheet_name and "9" in sheet_name:
            semester = "2026_09"
        elif "2026" in sheet_name and "4" in sheet_name:
            semester = "2026_04"
        elif "2026" in sheet_name and "3" in sheet_name:
            semester = "2026_03"

        safe_sheet_name = sheet_name.encode('ascii', 'replace').decode('ascii')
        self.stdout.write(f"[*] Ingesting schedule from sheet: '{safe_sheet_name}' (Semester: {semester})")

        raw_rows = extract_raw_schedule_rows(sheet)
        self.stdout.write(f"[*] Extracted {len(raw_rows)} raw class occurrences.")

        if options.get('clear'):
            deleted, _ = TimetableEntry.objects.filter(semester=semester).delete()
            self.stdout.write(f"[*] Cleared {deleted} previous entries for semester {semester}.")

        api_key = getattr(settings, 'GEMINI_API_KEY', '') or os.getenv('GEMINI_API_KEY', '')

        synced_count = 0
        merged_count = 0

        for item in raw_rows:
            day_idx = item['day_index']
            day_name = item['day_name']
            period = item['period']
            start_str = item['start_time']
            end_str = item['end_time']
            group = item['group']
            raw_text = item['raw_cell_content']

            # Parse start and end times
            try:
                s_h, s_m = map(int, start_str.split(':'))
                start_time = datetime.time(s_h, s_m)
            except Exception:
                start_time = datetime.time(9, 0)

            try:
                e_h, e_m = map(int, end_str.split(':'))
                end_time = datetime.time(e_h, e_m)
            except Exception:
                end_time = datetime.time(10, 15)

            # Parse class items from the raw cell text
            parsed_classes = parse_with_heuristics(raw_text, group_code=group)

            for cls in parsed_classes:
                subject = cls['subject']
                room = cls['room']
                teacher = cls['teacher']
                partner = cls['target_partner']
                is_jp = cls['is_japanese']
                ctype = cls['class_type']

                # Deduplication and multi-group merging:
                # If a class exists at the same day, period, room, and subject, append the group
                existing = TimetableEntry.objects.filter(
                    semester=semester,
                    day_index=day_idx,
                    period=period,
                    subject=subject,
                    room=room
                ).first()

                if existing:
                    if group not in existing.groups:
                        existing.groups.append(group)
                        existing.save(update_fields=['groups'])
                        merged_count += 1
                else:
                    TimetableEntry.objects.create(
                        semester=semester,
                        day_index=day_idx,
                        day_name=day_name,
                        period=period,
                        start_time=start_time,
                        end_time=end_time,
                        subject=subject,
                        teacher=teacher,
                        room=room,
                        groups=[group],
                        target_partner=partner,
                        is_japanese=is_jp,
                        class_type=ctype
                    )
                    synced_count += 1

        total_in_db = TimetableEntry.objects.filter(semester=semester).count()
        self.stdout.write(self.style.SUCCESS(
            f"\n[OK] Timetable Synchronization Complete!\n"
            f"     - New classes created: {synced_count}\n"
            f"     - Shared group classes merged: {merged_count}\n"
            f"     - Total classes in DB for {semester}: {total_in_db}"
        ))
