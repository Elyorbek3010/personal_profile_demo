"""
University Student Data Adapter Service.
Provides a unified interface for retrieving student profile information.
Currently fetches verified records from the local database (seeded test data).
When handing off to university IT, they can connect their official HEMIS or Google Workspace API here.
"""
import logging
from .models import StudentProfile

logger = logging.getLogger(__name__)

def get_student_data(identifier: str) -> dict | None:
    """
    Adapter function to resolve student university data.
    identifier: Student email (e.g. '2311194e@jdu.uz') or student ID (e.g. '2311194').

    CURRENT (Dev/Demo): Reads directly from local database (populated via seed_students.py).
    FUTURE (Production): University IT connects their HEMIS / Google Directory API here.
    """
    if not identifier:
        return None

    clean_id = ''.join(filter(str.isdigit, str(identifier).split('@')[0]))

    profile = None
    if '@' in str(identifier):
        profile = StudentProfile.objects.filter(user__email__iexact=str(identifier)).first()
    
    if not profile and clean_id:
        profile = StudentProfile.objects.filter(student_id=clean_id).first()

    if profile:
        return {
            'student_id': profile.student_id,
            'group': profile.group,
            'course': profile.course,
            'direction': profile.direction,
            'partner_university': profile.partner_university,
            'japanese_exempt': profile.japanese_exempt,
            'is_verified': profile.is_verified,
        }

    return None
