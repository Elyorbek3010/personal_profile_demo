from django.urls import path
from .views import MyScheduleView, TodayScheduleView, NextClassView

app_name = 'timetable'

urlpatterns = [
    path('my-schedule/', MyScheduleView.as_view(), name='my-schedule'),
    path('today/', TodayScheduleView.as_view(), name='today'),
    path('next/', NextClassView.as_view(), name='next'),
]
