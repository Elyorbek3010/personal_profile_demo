"""
Seed Student Profiles Script.
Generates 9 diverse test student accounts for local development and demonstration.
Password for all test students: jdu12345
"""
import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from django.contrib.auth.models import User
from apps.accounts.models import StudentProfile

SEED_STUDENTS = [
    {
        'email': '2300037o@jdu.uz',
        'first_name': 'Ozodbek',
        'last_name': 'Amirullayev',
        'student_id': '2300037',
        'group': '23C',
        'course': '3',
        'direction': 'IT',
        'partner_university': 'Tokyo Online University (TOU)',
        'japanese_exempt': True,
        'avatar_url': 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&q=80&w=256',
        'bio': 'IT and Software Engineering student.'
    },
    {
        'email': '2311194e@jdu.uz',
        'first_name': 'Elyorbek',
        'last_name': 'Adhamov',
        'student_id': '2311194',
        'group': '23D',
        'course': '3',
        'direction': 'IT',
        'partner_university': 'Tokyo Online University (TOU)',
        'japanese_exempt': True,
        'avatar_url': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=256',
        'bio': 'Software Engineering and Cloud Computing enthusiast.'
    },
    {
        'email': '2311195e@jdu.uz',
        'first_name': 'Sardor',
        'last_name': 'Rahimiy',
        'student_id': '2311195',
        'group': '23D',
        'course': '3',
        'direction': 'IT',
        'partner_university': 'SANNO University',
        'japanese_exempt': False,
        'avatar_url': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=256',
        'bio': 'Business & IT integration specialist.'
    },
    {
        'email': '2311196e@jdu.uz',
        'first_name': 'Madina',
        'last_name': 'Usmonova',
        'student_id': '2311196',
        'group': '23E',
        'course': '3',
        'direction': 'IT',
        'partner_university': 'Tokyo Online University (TOU)',
        'japanese_exempt': True,
        'avatar_url': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=256',
        'bio': 'UI/UX Design & Frontend development.'
    },
    {
        'email': '2311197e@jdu.uz',
        'first_name': 'Jasur',
        'last_name': 'Bekmurodov',
        'student_id': '2311197',
        'group': '23E',
        'course': '3',
        'direction': 'IT',
        'partner_university': 'SANNO University',
        'japanese_exempt': False,
        'avatar_url': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&q=80&w=256',
        'bio': 'Data analytics & algorithms.'
    },
    {
        'email': '2411001e@jdu.uz',
        'first_name': 'Diyorbek',
        'last_name': 'Xoldorov',
        'student_id': '2411001',
        'group': '24A',
        'course': '2',
        'direction': 'IT',
        'partner_university': 'Tokyo Online University (TOU)',
        'japanese_exempt': False,
        'avatar_url': 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?auto=format&fit=crop&q=80&w=256',
        'bio': 'Backend developer & system admin.'
    },
    {
        'email': '2411002e@jdu.uz',
        'first_name': 'Nilufar',
        'last_name': 'Aliyeva',
        'student_id': '2411002',
        'group': '24A',
        'course': '2',
        'direction': 'IT',
        'partner_university': 'Okayama University',
        'japanese_exempt': True,
        'avatar_url': 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&q=80&w=256',
        'bio': 'Japanese N2 certified & Web developer.'
    },
    {
        'email': '2411003e@jdu.uz',
        'first_name': 'Shohrux',
        'last_name': 'Qodirov',
        'student_id': '2411003',
        'group': '24B',
        'course': '2',
        'direction': 'IT',
        'partner_university': 'SANNO University',
        'japanese_exempt': False,
        'avatar_url': 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?auto=format&fit=crop&q=80&w=256',
        'bio': 'Mobile App Developer (Flutter).'
    },
    {
        'email': '2511010e@jdu.uz',
        'first_name': 'Kamola',
        'last_name': 'Karimova',
        'student_id': '2511010',
        'group': '25A',
        'course': '1',
        'direction': 'IT',
        'partner_university': 'Tokyo Online University (TOU)',
        'japanese_exempt': False,
        'avatar_url': 'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&q=80&w=256',
        'bio': 'First-year IT student, competitive programming.'
    },
    {
        'email': '2211005e@jdu.uz',
        'first_name': 'Azizbek',
        'last_name': 'Rustamov',
        'student_id': '2211005',
        'group': '22A',
        'course': '4',
        'direction': 'IT',
        'partner_university': 'Niigata (Kaishi Professional University)',
        'japanese_exempt': True,
        'avatar_url': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&q=80&w=256',
        'bio': 'Graduating senior, DevOps engineer.'
    }
]

def run_seed():
    print("[+] Seeding test students...")
    created_count = 0
    updated_count = 0

    for item in SEED_STUDENTS:
        user, u_created = User.objects.get_or_create(
            username=item['email'],
            defaults={
                'email': item['email'],
                'first_name': item['first_name'],
                'last_name': item['last_name']
            }
        )
        user.set_password('jdu12345')
        user.first_name = item['first_name']
        user.last_name = item['last_name']
        user.email = item['email']
        user.save()

        profile, p_created = StudentProfile.objects.get_or_create(
            user=user,
            defaults={
                'student_id': item['student_id'],
                'group': item['group'],
                'course': item['course'],
                'direction': item['direction'],
                'partner_university': item['partner_university'],
                'japanese_exempt': item['japanese_exempt'],
                'avatar_url': item['avatar_url'],
                'bio': item['bio'],
                'is_verified': True
            }
        )
        if not p_created:
            profile.student_id = item['student_id']
            profile.group = item['group']
            profile.course = item['course']
            profile.direction = item['direction']
            profile.partner_university = item['partner_university']
            profile.japanese_exempt = item['japanese_exempt']
            profile.avatar_url = item['avatar_url']
            profile.bio = item['bio']
            profile.is_verified = True
            profile.save()
            updated_count += 1
        else:
            created_count += 1

        print(f"  * {item['email']} ({item['first_name']} {item['last_name']}) -> Group: {item['group']}, Partner: {item['partner_university']}, Exempt: {item['japanese_exempt']}")

    print(f"\n[OK] Complete: {created_count} created, {updated_count} updated.")
    print("Password for all test students: jdu12345\n")

if __name__ == '__main__':
    run_seed()
