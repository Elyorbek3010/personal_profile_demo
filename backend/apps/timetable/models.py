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
        blank=True,
        null=True,
        db_index=True,
        help_text="Hafta kuni indeksi (0=Dushanba, 1=Seshanba...)"
    )
    day_name = models.CharField(
        max_length=30,
        default="Dushanba",
        help_text="Hafta kuni nomi o'zbek tilida (Dushanba, Seshanba...)"
    )
    PERIOD_CHOICES = (
        (1, '1-para (09:00 - 10:15)'),
        (2, '2-para (10:25 - 11:40)'),
        (3, '3-para (11:50 - 13:05)'),
        (4, '4-para (13:50 - 15:05)'),
        (5, '5-para (15:15 - 16:30)'),
        (6, '6-para (16:40 - 17:55)'),
    )

    specific_date = models.DateField(
        blank=True, null=True,
        help_text="Aniq sana (agar faqat bir kunga tegishli bo'lsa, qaysi kunligi avtomatik olinadi)"
    )
    period = models.IntegerField(
        choices=PERIOD_CHOICES,
        default=1,
        help_text="Para raqami (1 dan 6 gacha)"
    )
    start_time = models.TimeField(
        blank=True, null=True,
        help_text="Dars boshlanish vaqti (avtomatik qo'yiladi)"
    )
    end_time = models.TimeField(
        blank=True, null=True,
        help_text="Dars tugash vaqti (avtomatik qo'yiladi)"
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

    def clean(self):
        super().clean()
        from django.core.exceptions import ValidationError
        if self.specific_date is None and self.day_index is None:
            raise ValidationError("Agar aniq sana kiritilmagan bo'lsa, hafta kuni indeksini belgilash shart.")

    def save(self, *args, **kwargs):
        # Agar aniq sana kiritilgan bo'lsa, hafta kunini shundan olamiz
        if self.specific_date:
            self.day_index = self.specific_date.weekday()

        # Hafta kuni nomini avtomatik to'g'irlash
        day_map = dict(self.DAY_CHOICES)
        if self.day_index in day_map:
            self.day_name = day_map[self.day_index].split(' ')[0]

        # Para vaqtlarini avtomatik to'g'irlash
        PERIOD_TIMES = {
            1: ('09:00', '10:15'),
            2: ('10:25', '11:40'),
            3: ('11:50', '13:05'),
            4: ('13:50', '15:05'),
            5: ('15:15', '16:30'),
            6: ('16:40', '17:55'),
        }
        if self.period in PERIOD_TIMES:
            import datetime
            start_str, end_str = PERIOD_TIMES[self.period]
            self.start_time = datetime.datetime.strptime(start_str, '%H:%M').time()
            self.end_time = datetime.datetime.strptime(end_str, '%H:%M').time()

        # Guruhlar formatini to'g'irlash (masalan oddiy string yozilgan bo'lsa listga o'tkazish)
        if isinstance(self.groups, str):
            import json
            try:
                self.groups = json.loads(self.groups)
            except json.JSONDecodeError:
                # Agar JSON xato bo'lsa vergul bilan ajratilgan string deb qabul qilamiz
                self.groups = [g.strip() for g in self.groups.split(',')]
                
        super().save(*args, **kwargs)

    def __str__(self):
        day_str = self.get_day_index_display() if self.day_index is not None else ""
        return f"[{day_str}] {self.period}-para ({self.start_time.strftime('%H:%M') if self.start_time else ''}-{self.end_time.strftime('%H:%M') if self.end_time else ''}) - {self.subject} ({self.room})"
