from rest_framework import serializers
from .models import TimetableEntry

class TimetableEntrySerializer(serializers.ModelSerializer):
    time_slot = serializers.SerializerMethodField()
    start_time_formatted = serializers.SerializerMethodField()
    end_time_formatted = serializers.SerializerMethodField()

    class Meta:
        model = TimetableEntry
        fields = (
            'id',
            'semester',
            'day_index',
            'day_name',
            'period',
            'start_time',
            'end_time',
            'start_time_formatted',
            'end_time_formatted',
            'time_slot',
            'subject',
            'teacher',
            'room',
            'groups',
            'target_partner',
            'is_japanese',
            'class_type',
            'notes',
            'synced_at'
        )

    def get_time_slot(self, obj):
        start = obj.start_time.strftime('%H:%M') if obj.start_time else ''
        end = obj.end_time.strftime('%H:%M') if obj.end_time else ''
        return f"{start} - {end}" if start and end else ''

    def get_start_time_formatted(self, obj):
        return obj.start_time.strftime('%H:%M') if obj.start_time else ''

    def get_end_time_formatted(self, obj):
        return obj.end_time.strftime('%H:%M') if obj.end_time else ''
