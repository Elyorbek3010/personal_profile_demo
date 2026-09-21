"""
Personalized Schedule Filter Service.
Applies university business rules to the master TimetableEntry table:
- Filter by student's academic group (e.g. '23D')
- Filter by partner university (TOU vs SANNO vs Okayama)
- Filter by Japanese exemption status
"""
import logging
from django.db.models import Q
from apps.timetable.models import TimetableEntry

import re

logger = logging.getLogger(__name__)

def get_student_schedule(user, semester=None):
    """
    Returns personalized TimetableEntry queryset for the given student user.
    """
    profile = getattr(user, 'student_profile', None)
    if not profile:
        return TimetableEntry.objects.none()

    group = (profile.group or '23D').strip()
    partner = (profile.partner_university or 'TOU').strip().upper()
    is_japanese_exempt = bool(profile.japanese_exempt)

    # 1. Base query: must belong to student's group (enclosing in quotes prevents partial matches e.g. '3D' in '23D')
    quoted_group = f'"{group}"'
    queryset = TimetableEntry.objects.filter(groups__icontains=quoted_group)

    if semester:
        queryset = queryset.filter(semester=semester)

    # 2. Filter partner university classes
    if 'TOU' in partner or 'TOKYO' in partner:
        # Exclude SANNO-only or other partner-only classes
        queryset = queryset.exclude(target_partner__in=['SANNO', 'OKAYAMA', 'NIIGATA'])
    elif 'SANNO' in partner:
        # Exclude TOU-only classes
        queryset = queryset.exclude(target_partner__in=['TOU', 'OKAYAMA', 'NIIGATA'])
    elif 'OKAYAMA' in partner:
        queryset = queryset.exclude(target_partner__in=['TOU', 'SANNO', 'NIIGATA'])

    # 3. Filter Japanese language exemption and specific JLPT level
    if is_japanese_exempt:
        # Student passed exam and is exempt from Japanese language classes
        queryset = queryset.filter(is_japanese=False)
    else:
        # Student attends Japanese classes: filter to their specific JLPT level (N2, N3, N4, N5, N3G...)
        raw_level = (getattr(profile, 'japanese_level', '') or 'N3').strip().upper()
        match = re.search(r'N[1-5][A-Z]?', raw_level)
        if match:
            clean_level = match.group(0)
            base_lvl = clean_level[:2] # e.g. 'N3'

            # Exclude other base levels (e.g. if student is N3, exclude N1, N2, N4, N5)
            other_bases = [lvl for lvl in ['N1', 'N2', 'N3', 'N4', 'N5'] if lvl != base_lvl]
            for other_lvl in other_bases:
                queryset = queryset.exclude(is_japanese=True, subject__icontains=f'({other_lvl}')

            # If student has a sub-level (e.g. 'N3G'), exclude other sub-levels for that base
            if len(clean_level) > 2:
                sub_letter = clean_level[2:]
                for other_sub in ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'K']:
                    if other_sub != sub_letter:
                        queryset = queryset.exclude(is_japanese=True, subject__icontains=f'({base_lvl}{other_sub}')

    return queryset.order_by('day_index', 'period', 'start_time')
