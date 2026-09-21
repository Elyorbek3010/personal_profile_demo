from django.db import models

class TimetableEntry(models.Model):
    """
    University Timetable Class Entry.
    Stores parsed class sessions ingested from data/timetable.xlsx or live Google Sheets.
    """
    DAY_CHOICES = (
        (0, 'Dushanba (月)'),
        (1, 'Seshanba (火)'),
        (2, 'Chorshanba (水)'),
        (3, 'Payshanba (木)'),
        (4, 'Juma (金)'),
        (5, 'Shanba (土)'),
        (6, 'Yakshanba (日)'),
    )

    semester = models.CharField(
        max_length=30,
        default="2026_09",
        db_index=True,
        help_text="O'quv semestri (masalan: 2026_09 yoki 2026_04)"
    )
    day_index = models.IntegerField(
        choices=DAY_CHOICES,
        default=0,
        db_index=True,
        help_text="Hafta kuni indeksi (0=Dushanba, 1=Seshanba...)"
    )
    day_name = models.CharField(
        max_length=30,
        default="Dushanba",
        help_text="Hafta kuni nomi o'zbek tilida (Dushanba, Seshanba...)"
    )
    period = models.IntegerField(
        default=1,
        help_text="Para raqami (1-para, 2-para... 1 dan 6 gacha)"
    )
    start_time = models.TimeField(
        help_text="Dars boshlanish vaqti (masalan: 09:00)"
    )
    end_time = models.TimeField(
        help_text="Dars tugash vaqti (masalan: 10:15)"
    )
    subject = models.CharField(
        max_length=200,
        db_index=True,
        help_text="Fan yoki mashg'ulot nomi"
    )
    teacher = models.CharField(
        max_length=150,
        blank=True,
        default="",
        help_text="O'qituvchi ismi (Erkaboy, Sonobe...)"
    )
    room = models.CharField(
        max_length=50,
        blank=True,
        default="",
        help_text="Xona raqami (masalan: 304, 203, Zoom)"
    )
    groups = models.JSONField(
        default=list,
        help_text="Tegishli guruhlar ro'yxati (masalan: ['23D', '23E'])"
    )
    target_partner = models.CharField(
        max_length=50,
        default="ALL",
        help_text="Hamkor OTM filtri (TOU, SANNO, ALL)"
    )
    is_japanese = models.BooleanField(
        default=False,
        help_text="Yapon tili darsimi (agar talaba ozod bo'lsa ko'rsatilmaydi)"
    )
    class_type = models.CharField(
        max_length=50,
        default="lecture",
        blank=True,
        help_text="Dars turi (lecture, seminar, interview, meeting)"
    )
    notes = models.TextField(
        blank=True,
        default="",
        help_text="Qo'shimcha izohlar (toq haftalar, o'quv qurollari va h.k.)"
    )
    synced_at = models.DateTimeField(
        auto_now=True,
        help_text="Oxirgi sinxronizatsiya vaqti"
    )
    created_at = models.DateTimeField(
        auto_now_add=True
    )

    class Meta:
        verbose_name = "Timetable Entry"
        verbose_name_plural = "Timetable Entries"
        ordering = ['day_index', 'period', 'room']

    def __str__(self):
        return f"[{self.get_day_index_display()}] {self.period}-para ({self.start_time.strftime('%H:%M')}-{self.end_time.strftime('%H:%M')}) - {self.subject} ({self.room})"
