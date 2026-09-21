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

    # 3. Filter Japanese language exemption
    if is_japanese_exempt:
        # Student passed exam and is exempt from Japanese language classes
        queryset = queryset.filter(is_japanese=False)

    return queryset.order_by('day_index', 'period', 'start_time')
