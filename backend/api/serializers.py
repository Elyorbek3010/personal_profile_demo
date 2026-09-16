from rest_framework import serializers
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer
from django.contrib.auth.models import User
from .models import StudentProfile

class StudentProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = StudentProfile
        fields = ('student_id', 'group', 'course', 'direction', 'partner_university', 'japanese_exempt', 'avatar_url', 'is_verified')

class CustomTokenObtainPairSerializer(TokenObtainPairSerializer):
    def validate(self, attrs):
        login_val = attrs.get('username')
        if login_val and '@' in login_val:
            try:
                user_obj = User.objects.get(email__iexact=login_val)
                attrs['username'] = user_obj.username
            except User.DoesNotExist:
                pass

        data = super().validate(attrs)
        user = self.user
        profile = getattr(user, 'student_profile', None)

        data['user'] = {
            'id': user.id,
            'email': user.email,
            'username': user.username,
            'name': f"{user.first_name} {user.last_name}".strip() or user.username,
            'firstName': user.first_name,
            'lastName': user.last_name,
            'studentId': profile.student_id if profile else '',
            'group': profile.group if profile else '23D',
            'course': profile.course if profile else '3',
            'direction': profile.direction if profile else 'IT',
            'partnerUniversity': profile.partner_university if profile else 'Tokyo Online University (TOU)',
            'japaneseExempt': profile.japanese_exempt if profile else True,
            'avatar': profile.avatar_url if profile else '',
            'role': 'student'
        }
        return data

class UserSerializer(serializers.ModelSerializer):
    profile = StudentProfileSerializer(source='student_profile', read_only=True)
    name = serializers.SerializerMethodField()

    class Meta:
        model = User
        fields = ('id', 'username', 'email', 'first_name', 'last_name', 'name', 'profile')

    def get_name(self, obj):
        full_name = f"{obj.first_name} {obj.last_name}".strip()
        return full_name if full_name else obj.username

class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, min_length=6)
    student_id = serializers.CharField(write_only=True, required=False, allow_blank=True)
    group = serializers.CharField(write_only=True, required=False, default="23E")
    
    class Meta:
        model = User
        fields = ('username', 'email', 'password', 'first_name', 'last_name', 'student_id', 'group')

    def create(self, validated_data):
        student_id = validated_data.pop('student_id', '')
        group = validated_data.pop('group', '23E')
        
        user = User.objects.create_user(
            username=validated_data['username'],
            email=validated_data.get('email', ''),
            password=validated_data['password'],
            first_name=validated_data.get('first_name', ''),
            last_name=validated_data.get('last_name', '')
        )
        StudentProfile.objects.create(
            user=user,
            student_id=student_id or f"{group}-001",
            group=group
        )
        return user

class GoogleAuthInputSerializer(serializers.Serializer):
    credential = serializers.CharField(required=False, allow_blank=True, help_text="Google ID Token (JWT)")
    demo = serializers.BooleanField(required=False, default=False, help_text="Fast developer demo bypass")
    email = serializers.EmailField(required=False, allow_blank=True)
    name = serializers.CharField(required=False, allow_blank=True)
    group = serializers.CharField(required=False, default="23E")
    student_id = serializers.CharField(required=False, default="2311195")
