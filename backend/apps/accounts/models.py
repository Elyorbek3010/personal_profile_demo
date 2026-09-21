from django.db import models
from django.contrib.auth.models import User

class StudentProfile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='student_profile')
    student_id = models.CharField(max_length=50, unique=True, null=True, blank=True, db_index=True, help_text="Rasmiy talaba ID raqami (masalan: 2311194)")
    group = models.CharField(max_length=50, default="23D", db_index=True, help_text="Guruh (masalan: 23D, 24A)")
    course = models.CharField(max_length=50, default="3", help_text="Bosqich / Kurs (masalan: 1, 2, 3, 4)")
    direction = models.CharField(max_length=100, default="IT", help_text="Yo'nalish (IT, Axborot xavfsizligi va h.k.)")
    partner_university = models.CharField(
        max_length=150, 
        default="Tokyo Online University (TOU)", 
        help_text="Hamkor universitet (TOU, SANNO, Okayama, Niigata)"
    )
    japanese_exempt = models.BooleanField(
        default=True, 
        help_text="Yapon tili darslaridan ozod qilinganlik holati (JAPANESE varag'i asosida)"
    )
    data_jdu_hash = models.CharField(
        max_length=50, blank=True, null=True, db_index=True,
        help_text="data.jdu.uz shaxsiy sahifa kodi (masalan: 2c7a6987)"
    )
    avatar_url = models.TextField(blank=True, null=True, help_text="Profil rasmi havolasi")
    phone = models.CharField(max_length=30, blank=True, null=True, help_text="Telefon raqami")
    bio = models.TextField(blank=True, null=True, help_text="Qisqacha talaba ma'lumoti")
    is_verified = models.BooleanField(default=False, help_text="Universitet rasmiy ro'yxatida tasdiqlangan")
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = 'Student Profile'
        verbose_name_plural = 'Student Profiles'
        ordering = ['student_id']

    def __str__(self):
        return f"{self.user.get_full_name() or self.user.username} ({self.student_id or 'No ID'}) - Guruh: {self.group}"
