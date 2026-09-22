import datetime
from django.utils import timezone
from django.db.models import Q
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import permissions, status
from .models import TimetableEntry
from .serializers import TimetableEntrySerializer
from .services.schedule_filter import get_student_schedule

DAY_NAMES = {
    0: 'Dushanba',
    1: 'Seshanba',
    2: 'Chorshanba',
    3: 'Payshanba',
    4: 'Juma',
    5: 'Shanba',
    6: 'Yakshanba'
}

class MyScheduleView(APIView):
    """
    Returns full weekly timetable personalized for the logged-in student.
    Grouped by days of the week (Dushanba - Shanba).
    """
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        user = request.user
        queryset = get_student_schedule(user)

        # Group classes by weekday (0=Dushanba to 6=Yakshanba)
        grouped_by_day = {}

        total_classes = 0
        for entry in queryset:
            d_idx = entry.day_index
            if d_idx not in grouped_by_day:
                grouped_by_day[d_idx] = {
                    'day_index': d_idx,
                    'day_name': DAY_NAMES.get(d_idx, entry.day_name),
                    'classes_count': 0,
                    'classes': []
                }
            serialized_entry = TimetableEntrySerializer(entry).data
            grouped_by_day[d_idx]['classes'].append(serialized_entry)
            grouped_by_day[d_idx]['classes_count'] += 1
            total_classes += 1

        # Return ordered list of days
        days_list = [grouped_by_day[k] for k in sorted(grouped_by_day.keys())]

        profile = getattr(user, 'student_profile', None)
        return Response({
            'student': {
                'id': user.id,
                'email': user.email,
                'group': profile.group if profile else '',
                'partnerUniversity': profile.partner_university if profile else '',
                'japaneseExempt': profile.japanese_exempt if profile else False,
            },
            'total_classes_week': total_classes,
            'schedule': days_list
        }, status=status.HTTP_200_OK)

class TodayScheduleView(APIView):
    """
    Returns today's classes for the student.
    """
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        user = request.user
        today_weekday = datetime.datetime.now().weekday() # 0 = Monday, 6 = Sunday
        today_date = datetime.date.today()

        queryset = get_student_schedule(user).filter(
            day_index=today_weekday
        ).filter(
            Q(specific_date__isnull=True) | Q(specific_date=today_date)
        )
        classes_data = TimetableEntrySerializer(queryset, many=True).data

        return Response({
            'today': DAY_NAMES.get(today_weekday, 'Bugun'),
            'day_index': today_weekday,
            'classes_count': len(classes_data),
            'classes': classes_data
        }, status=status.HTTP_200_OK)

class NextClassView(APIView):
    """
    Calculates the student's next imminent class based on the current time.
    """
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        user = request.user
        now = datetime.datetime.now()
        current_time = now.time()
        current_weekday = now.weekday()

        schedule = get_student_schedule(user)

        # 1. Check for remaining classes today
        today_date = datetime.date.today()
        next_class = schedule.filter(
            day_index=current_weekday,
            start_time__gte=current_time
        ).filter(
            Q(specific_date__isnull=True) | Q(specific_date=today_date)
        ).order_by('start_time').first()

        # 2. If no more classes today, find the first class of the next school day
        if not next_class:
            for offset in range(1, 7):
                next_date = today_date + datetime.timedelta(days=offset)
                next_day_index = next_date.weekday()
                next_class = schedule.filter(
                    day_index=next_day_index
                ).filter(
                    Q(specific_date__isnull=True) | Q(specific_date=next_date)
                ).order_by('period').first()
                if next_class:
                    break

        if not next_class:
            return Response({
                'has_next_class': False,
                'message': "Yaqin orada darslar rejalashtirilmagan."
            }, status=status.HTTP_200_OK)

        serializer = TimetableEntrySerializer(next_class)
        return Response({
            'has_next_class': True,
            'is_today': next_class.day_index == current_weekday,
            'day_name': next_class.day_name,
            'next_class': serializer.data
        }, status=status.HTTP_200_OK)
