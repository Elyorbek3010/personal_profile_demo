from rest_framework import serializers
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer
from django.contrib.auth.models import User
from .models import StudentProfile

class StudentProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = StudentProfile
        fields = (
            'student_id',
            'group',
            'course',
            'direction',
            'partner_university',
            'japanese_exempt',
            'japanese_level',
            'avatar_url',
            'phone',
            'bio',
            'is_verified'
        )

class UserSerializer(serializers.ModelSerializer):
    student_profile = StudentProfileSerializer(read_only=True)
    full_name = serializers.SerializerMethodField()

    class Meta:
        model = User
        fields = ('id', 'username', 'email', 'first_name', 'last_name', 'full_name', 'student_profile')

    def get_full_name(self, obj):
        name = f"{obj.first_name} {obj.last_name}".strip()
        return name if name else obj.username

class CustomTokenObtainPairSerializer(TokenObtainPairSerializer):
    """
    Enhanced JWT Serializer.
    Accepts official @jdu.uz corporate email and password.
    Returns JWT tokens along with verified student profile information from the database.
    """
    def validate(self, attrs):
        login_input = attrs.get('username', '').strip()

        # 1. Enforce strictly official @jdu.uz university email
        if not login_input.lower().endswith('@jdu.uz'):
            raise serializers.ValidationError({
                "detail": "Faqat rasmiy universitet emaili (@jdu.uz) orqali kirish mumkin."
            })

        user_obj = User.objects.filter(email__iexact=login_input).first() or User.objects.filter(username__iexact=login_input).first()
        if not user_obj:
            raise serializers.ValidationError({
                "detail": "Email yoki parol noto'g'ri kiritildi."
            })

        attrs['username'] = user_obj.username

        # 2. Authenticate credentials and issue JWT tokens
        data = super().validate(attrs)
        user = self.user

        # 3. Retrieve verified profile from database
        profile = getattr(user, 'student_profile', None)

        full_name = f"{user.first_name} {user.last_name}".strip() or user.username

        data['user'] = {
            'id': user.id,
            'email': user.email,
            'username': user.username,
            'name': full_name,
            'firstName': user.first_name,
            'lastName': user.last_name,
            'studentId': profile.student_id if profile else '',
            'group': profile.group if profile else '',
            'course': profile.course if profile else '',
            'direction': profile.direction if profile else '',
            'partnerUniversity': profile.partner_university if profile else '',
            'japaneseExempt': profile.japanese_exempt if profile else False,
            'japaneseLevel': getattr(profile, 'japanese_level', 'N3') if profile else 'N3',
            'avatar': profile.avatar_url if profile else '',
            'isVerified': profile.is_verified if profile else False,
            'role': 'student'
        }
        return data

class GoogleAuthSerializer(serializers.Serializer):
    credential = serializers.CharField(required=False, allow_blank=True)
    demo = serializers.BooleanField(required=False, default=False)
    email = serializers.EmailField(required=False, allow_blank=True)
    name = serializers.CharField(required=False, allow_blank=True)
