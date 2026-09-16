import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from django.contrib.auth.models import User
from api.models import StudentProfile

STUDENTS = [
    # 3-kurs (2023) - Elyorbek (TOU) & Ulug'bek (SANNO) & Javlonbek (23A)
    {
        "student_id": "2311194",
        "first_name": "Elyorbek",
        "last_name": "Adhamov",
        "email": "2311194e@jdu.uz",
        "group": "23D",
        "course": "3",
        "direction": "IT",
        "partner_university": "Tokyo Online University (TOU)",
        "japanese_exempt": True,
    },
    {
        "student_id": "2311143",
        "first_name": "Ulug'bek",
        "last_name": "Nurmatov",
        "email": "2311143u@jdu.uz",
        "group": "23D",
        "course": "3",
        "direction": "IT",
        "partner_university": "SANNO University",
        "japanese_exempt": True,
    },
    {
        "student_id": "2300038",
        "first_name": "Javlonbek",
        "last_name": "Mamatqosimov",
        "email": "2300038j@jdu.uz",
        "group": "IT 23A",
        "course": "3",
        "direction": "IT",
        "partner_university": "Tokyo Online University (TOU)",
        "japanese_exempt": True,
    },
    # 4-kurs (2021/2022)
    {
        "student_id": "221121",
        "first_name": "Sardor",
        "last_name": "Tolliboyev",
        "email": "221121s@jdu.uz",
        "group": "IT 22A",
        "course": "4",
        "direction": "IT",
        "partner_university": "SANNO University",
        "japanese_exempt": True,
    },
    {
        "student_id": "226516",
        "first_name": "Saidislomxo'ja",
        "last_name": "Toshxo'jayev",
        "email": "226516s@jdu.uz",
        "group": "IT 22B",
        "course": "4",
        "direction": "IT",
        "partner_university": "SANNO University",
        "japanese_exempt": True,
    },
    # 2-kurs (2024)
    {
        "student_id": "2400051",
        "first_name": "Sarvarbek",
        "last_name": "Alikulov",
        "email": "2400051s@jdu.uz",
        "group": "24A",
        "course": "2",
        "direction": "Axborot Xavfsizligi",
        "partner_university": "Asosiy Kurs / 科目履修A",
        "japanese_exempt": True,
    },
    {
        "student_id": "2401028",
        "first_name": "Sevinch",
        "last_name": "Keldibayeva",
        "email": "2401028s@jdu.uz",
        "group": "24A",
        "course": "2",
        "direction": "Axborot Xavfsizligi",
        "partner_university": "Okayama University",
        "japanese_exempt": True,
    },
    # 1-kurs (2025)
    {
        "student_id": "2500097",
        "first_name": "Marjona",
        "last_name": "Sayfullayeva",
        "email": "2500097s@jdu.uz",
        "group": "25A",
        "course": "1",
        "direction": "IT",
        "partner_university": "科目履修25A",
        "japanese_exempt": True,
    },
    {
        "student_id": "2500146",
        "first_name": "Boburjon",
        "last_name": "Egamberdiyev",
        "email": "2500146e@jdu.uz",
        "group": "25A",
        "course": "1",
        "direction": "IT",
        "partner_university": "科目履修25C",
        "japanese_exempt": True,
    }
]

DEFAULT_PASSWORD = "12345678"

def seed():
    print("Seeding students into database...")
    for s in STUDENTS:
        email = s["email"]
        user, created = User.objects.get_or_create(username=email, defaults={"email": email})
        user.email = email
        user.first_name = s["first_name"]
        user.last_name = s["last_name"]
        user.set_password(DEFAULT_PASSWORD)
        user.save()

        profile, p_created = StudentProfile.objects.get_or_create(user=user)
        profile.student_id = s["student_id"]
        profile.group = s["group"]
        profile.course = s["course"]
        profile.direction = s["direction"]
        profile.partner_university = s["partner_university"]
        profile.japanese_exempt = s["japanese_exempt"]
        profile.is_verified = True
        profile.save()

        status = "Created" if created else "Updated"
        print(f"[{status}] {s['student_id']} - {s['first_name']} {s['last_name']} ({email}) -> Group: {s['group']}, Partner: {s['partner_university']}")

    print("\nSuccessfully seeded all student accounts with password:", DEFAULT_PASSWORD)

if __name__ == '__main__':
    seed()
