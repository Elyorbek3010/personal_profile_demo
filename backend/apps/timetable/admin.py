from django.contrib import admin
from .models import TimetableEntry

@admin.register(TimetableEntry)
class TimetableEntryAdmin(admin.ModelAdmin):
    list_display = (
        'day_name',
        'period',
        'start_time',
        'end_time',
        'subject',
        'room',
        'teacher',
        'target_partner',
        'is_japanese',
        'semester'
    )
    list_filter = (
        'semester',
        'day_index',
        'room',
        'target_partner',
        'is_japanese'
    )
    search_fields = (
        'subject',
        'teacher',
        'room',
        'notes'
    )
    ordering = ('semester', 'day_index', 'period', 'room')
