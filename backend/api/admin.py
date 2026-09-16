from django.contrib import admin
from .models import StudentProfile

@admin.register(StudentProfile)
class StudentProfileAdmin(admin.ModelAdmin):
    list_display = ('user', 'student_id', 'group', 'direction', 'course', 'is_verified', 'created_at')
    search_fields = ('user__username', 'user__email', 'student_id', 'group')
    list_filter = ('group', 'direction', 'course', 'is_verified')
