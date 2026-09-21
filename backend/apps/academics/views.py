"""
API Views for the Academics module.

Provides endpoints to:
- GET academic data (scraped + AI analysis)
- POST student's data.jdu.uz link/hash
"""
import re
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import permissions, status

from .scraper import scrape_student_data
from .ai_advisor import generate_full_report


class AcademicDataView(APIView):
    """
    GET /api/academics/my-data/

    Returns the student's full academic data: grades, attendance,
    credits, GPA, and AI advisor warnings.
    """
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        profile = getattr(request.user, 'student_profile', None)
        if not profile or not profile.data_jdu_hash:
            return Response({
                'has_data': False,
                'message': 'data.jdu.uz havolangiz hali kiritilmagan. Iltimos, avval havolani kiriting.',
            }, status=status.HTTP_200_OK)

        try:
            scraped = scrape_student_data(profile.data_jdu_hash)
            report = generate_full_report(scraped)
            return Response({
                'has_data': True,
                'data': report,
            }, status=status.HTTP_200_OK)
        except ValueError as e:
            return Response({
                'has_data': False,
                'error': str(e),
            }, status=status.HTTP_502_BAD_GATEWAY)
        except Exception as e:
            return Response({
                'has_data': False,
                'error': f'Kutilmagan xatolik: {str(e)}',
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


class SetDataLinkView(APIView):
    """
    POST /api/academics/set-link/

    Body: { "link": "https://data.jdu.uz/2c7a6987" }
       or { "link": "2c7a6987" }

    Extracts the hash and saves it to the student's profile.
    """
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        raw_link = request.data.get('link', '').strip()
        if not raw_link:
            return Response({
                'success': False,
                'error': 'Havola kiritilmagan.',
            }, status=status.HTTP_400_BAD_REQUEST)

        # Extract hash: accept full URL or just the hash code
        hash_match = re.search(r'data\.jdu\.uz/([a-zA-Z0-9]+)', raw_link)
        if hash_match:
            student_hash = hash_match.group(1)
        elif re.match(r'^[a-zA-Z0-9]{6,12}$', raw_link):
            # Looks like a bare hash
            student_hash = raw_link
        else:
            return Response({
                'success': False,
                'error': 'Noto\'g\'ri havola formati. Namuna: https://data.jdu.uz/2c7a6987',
            }, status=status.HTTP_400_BAD_REQUEST)

        profile = getattr(request.user, 'student_profile', None)
        if not profile:
            return Response({
                'success': False,
                'error': 'Talaba profili topilmadi.',
            }, status=status.HTTP_404_NOT_FOUND)

        # Verify the hash actually works by trying to fetch the page
        try:
            scraped = scrape_student_data(student_hash)
            if not scraped.get('categories'):
                return Response({
                    'success': False,
                    'error': 'Bu havola uchun ma\'lumot topilmadi. Havolani tekshiring.',
                }, status=status.HTTP_400_BAD_REQUEST)
        except ValueError:
            return Response({
                'success': False,
                'error': 'Havola ishlamayapti. Iltimos, to\'g\'ri havolani kiriting.',
            }, status=status.HTTP_400_BAD_REQUEST)

        # Save the verified hash
        profile.data_jdu_hash = student_hash
        profile.save(update_fields=['data_jdu_hash'])

        return Response({
            'success': True,
            'hash': student_hash,
            'student_name': scraped.get('student_name', ''),
            'message': 'Havola muvaffaqiyatli saqlandi!',
        }, status=status.HTTP_200_OK)
