from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework_simplejwt.views import TokenObtainPairView
from rest_framework_simplejwt.tokens import RefreshToken
from django.contrib.auth.models import User
from django.conf import settings
from .models import StudentProfile
from .serializers import (
    UserSerializer,
    StudentProfileSerializer,
    CustomTokenObtainPairSerializer,
    GoogleAuthSerializer
)
from .services import get_student_data
import logging

logger = logging.getLogger(__name__)

class CustomTokenObtainPairView(TokenObtainPairView):
    """
    Mobile Login Endpoint.
    Accepts Email, Student ID, or Username.
    """
    serializer_class = CustomTokenObtainPairSerializer

class GoogleAuthView(APIView):
    """
    Google Workspace SSO Endpoint for Mobile & Web.
    Verifies ID token, validates @jdu.uz domain, and matches against university roster.
    """
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        serializer = GoogleAuthSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

        data = serializer.validated_data
        credential = data.get('credential', '').strip()
        is_demo = data.get('demo', False)

        email = None
        first_name = ""
        last_name = ""
        avatar_url = ""
        domain = ""

        # 1. Check if Developer Demo Mode
        is_demo_requested = is_demo or credential.startswith("demo_") or not credential
        if is_demo_requested:
            if not getattr(settings, 'DEBUG', False):
                return Response({
                    "error": "Demo rejim faqat dasturchilar sinov muhitida (DEBUG=True) ruxsat etilgan."
                }, status=status.HTTP_403_FORBIDDEN)
            email = data.get('email') or "2311194e@jdu.uz"
            raw_name = data.get('name') or "Elyorbek Adhamov"
            parts = raw_name.split(' ', 1)
            first_name = parts[0]
            last_name = parts[1] if len(parts) > 1 else ""
            avatar_url = "https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=256"
            domain = email.split('@')[-1].lower() if '@' in email else 'jdu.uz'
        else:
            # 2. Verify Google OAuth ID Token
            try:
                from google.oauth2 import id_token
                from google.auth.transport import requests as google_requests

                client_id = getattr(settings, 'GOOGLE_CLIENT_ID', None) or None
                idinfo = id_token.verify_oauth2_token(
                    credential,
                    google_requests.Request(),
                    client_id
                )
                email = idinfo.get('email')
                domain = idinfo.get('hd') or (email.split('@')[-1].lower() if email else '')
                first_name = idinfo.get('given_name', '')
                last_name = idinfo.get('family_name', '')
                avatar_url = idinfo.get('picture', '')
            except Exception as e:
                logger.error(f"Google Token Verification Error: {e}")
                return Response({
                    "error": "Google token tasdiqlanmadi yoki muddati o'tgan.",
                    "details": str(e)
                }, status=status.HTTP_400_BAD_REQUEST)

        if not email:
            return Response({"error": "Email manzili aniqlanmadi."}, status=status.HTTP_400_BAD_REQUEST)

        # 3. Domain Check (Must be @jdu.uz)
        allowed_domains = getattr(settings, 'ALLOWED_UNIVERSITY_DOMAINS', ['jdu.uz'])
        if allowed_domains and domain not in allowed_domains:
            return Response({
                "error": f"Faqat rasmiy universitet hisobi (@{allowed_domains[0]}) orqali kirish mumkin. Sizning domeningiz: @{domain}",
                "allowed_domains": allowed_domains
            }, status=status.HTTP_403_FORBIDDEN)

        # 4. Get or Create User
        user, _ = User.objects.get_or_create(
            username=email,
            defaults={
                'email': email,
                'first_name': first_name,
                'last_name': last_name
            }
        )

        # 5. Check with Student Data Adapter
        uni_data = get_student_data(email)
        defaults = {
            'student_id': uni_data.get('student_id') if uni_data else ''.join(filter(str.isdigit, email.split('@')[0])),
            'group': uni_data.get('group', '23D') if uni_data else '23D',
            'course': uni_data.get('course', '3') if uni_data else '3',
            'direction': uni_data.get('direction', 'IT') if uni_data else 'IT',
            'partner_university': uni_data.get('partner_university', 'Tokyo Online University (TOU)') if uni_data else 'Tokyo Online University (TOU)',
            'japanese_exempt': uni_data.get('japanese_exempt', True) if uni_data else True,
            'avatar_url': avatar_url,
            'is_verified': uni_data.get('is_verified', True) if uni_data else False
        }

        profile, created = StudentProfile.objects.get_or_create(user=user, defaults=defaults)
        if not created and uni_data:
            profile.group = uni_data.get('group', profile.group)
            profile.partner_university = uni_data.get('partner_university', profile.partner_university)
            profile.japanese_exempt = uni_data.get('japanese_exempt', profile.japanese_exempt)
            profile.is_verified = uni_data.get('is_verified', True)
            if avatar_url and not profile.avatar_url:
                profile.avatar_url = avatar_url
            profile.save()

        # 6. Issue SimpleJWT Tokens
        refresh = RefreshToken.for_user(user)
        full_name = f"{user.first_name} {user.last_name}".strip() or user.username

        return Response({
            "access": str(refresh.access_token),
            "refresh": str(refresh),
            "user": {
                "id": user.id,
                "email": user.email,
                "username": user.username,
                "name": full_name,
                "firstName": user.first_name,
                "lastName": user.last_name,
                "studentId": profile.student_id or '',
                "group": profile.group,
                "course": profile.course,
                "direction": profile.direction,
                "partnerUniversity": profile.partner_university,
                "japaneseExempt": profile.japanese_exempt,
                "avatar": profile.avatar_url or avatar_url,
                "isVerified": profile.is_verified,
                "role": "student"
            },
            "message": "Universitet Google hisobi orqali muvaffaqiyatli kirildi!"
        }, status=status.HTTP_200_OK)

class UserProfileView(generics.RetrieveUpdateAPIView):
    """
    Get or Update authenticated student profile.
    """
    serializer_class = UserSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_object(self):
        user = self.request.user
        if not hasattr(user, 'student_profile'):
            StudentProfile.objects.create(user=user, group="23D", course="3")
        return user


MAX_AVATAR_SIZE = 512 * 1024  # 512 KB

class UpdateAvatarView(APIView):
    """
    POST /api/auth/update-avatar/
    Body: { "avatar": "..." }  (preset URL, base64 image data, or empty string to reset)
    """
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        avatar = request.data.get('avatar', '').strip()

        # Validation 1: Size limit (max 512KB)
        if len(avatar) > MAX_AVATAR_SIZE:
            return Response({
                'error': "Rasm hajmi juda katta (maksimal 512 KB ruxsat etilgan)."
            }, status=status.HTTP_400_BAD_REQUEST)

        # Validation 2: Format (must be https://, http:// for local dev, data:image/, or empty)
        if avatar and not avatar.startswith(('https://', 'http://', 'data:image/')):
            return Response({
                'error': "Noto'g'ri rasm formati. Faqat xavfsiz URL yoki base64 rasm qabul qilinadi."
            }, status=status.HTTP_400_BAD_REQUEST)

        user = request.user
        profile, _ = StudentProfile.objects.get_or_create(user=user)
        profile.avatar_url = avatar
        profile.save(update_fields=['avatar_url'])
        return Response({
            'success': True,
            'avatar': profile.avatar_url,
            'message': 'Profil rasmi yangilandi!'
        }, status=status.HTTP_200_OK)

