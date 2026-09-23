from django.db.models.signals import post_save
from django.dispatch import receiver
from .models import TimetableEntry
from apps.accounts.models import StudentProfile
from .services.firebase import notify_student_of_schedule_change
import logging

logger = logging.getLogger(__name__)

@receiver(post_save, sender=TimetableEntry)
def notify_on_timetable_change(sender, instance, created, **kwargs):
    # Only notify for updates, not creation (or decide based on requirements)
    # Actually, we might want to notify on creation as well if it's an extra class
    try:
        # Find all students in this group
        students = StudentProfile.objects.filter(group=instance.group)
        for student in students:
            if student.fcm_token:
                notify_student_of_schedule_change(student, instance)
    except Exception as e:
        logger.error(f"Error in notify_on_timetable_change signal: {e}")
