from django.db import models
from django.contrib.auth.models import User

class StudentProfile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='student_profile')
    student_id = models.CharField(max_length=50, blank=True, null=True, help_text="Talaba ID (masalan: 2311195)")
    group = models.CharField(max_length=50, default="23E", help_text="Guruh (masalan: 23E)")
    course = models.CharField(max_length=50, default="4", help_text="Bosqich / Kurs (masalan: 4期生 / 4)")
    direction = models.CharField(max_length=100, default="IT", help_text="Yo'nalish (masalan: IT, JAPANESE)")
    partner_university = models.CharField(max_length=150, default="Tokyo Online University (TOU)", blank=True, help_text="Hamkor universitet (TOU, SANNO, Niigata va h.k.)")
    japanese_exempt = models.BooleanField(default=True, help_text="Yapon tili darslaridan ozod qilinganligi")
    avatar_url = models.TextField(blank=True, null=True, help_text="Google yoki shaxsiy profil rasmi")
    is_verified = models.BooleanField(default=True, help_text="Universitet tomonidan tasdiqlangan hisob")
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.user.username} ({self.student_id or self.group})"
