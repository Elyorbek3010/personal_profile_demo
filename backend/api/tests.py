from django.test import TestCase
from django.urls import reverse
from rest_framework.test import APIClient
from rest_framework import status
from django.contrib.auth.models import User
from .models import StudentProfile

class GoogleAuthTests(TestCase):
    def setUp(self):
        self.client = APIClient()

    def test_health_check(self):
        url = reverse('health_check')
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data.get('status'), 'ok')

    def test_google_auth_demo_success(self):
        url = reverse('google_auth')
        payload = {
            "demo": True,
            "email": "elyorbek@jdu.uz",
            "name": "Elyorbek Khayitboev",
            "group": "23E",
            "student_id": "2311195"
        }
        response = self.client.post(url, payload, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('access', response.data)
        self.assertIn('refresh', response.data)
        self.assertEqual(response.data['user']['email'], 'elyorbek@jdu.uz')
        self.assertEqual(response.data['user']['group'], '23E')
        self.assertEqual(response.data['user']['studentId'], '2311195')

        # Verify DB records
        user = User.objects.get(email='elyorbek@jdu.uz')
        self.assertEqual(user.first_name, 'Elyorbek')
        self.assertTrue(hasattr(user, 'student_profile'))
        self.assertEqual(user.student_profile.group, '23E')

    def test_google_auth_forbidden_domain(self):
        url = reverse('google_auth')
        payload = {
            "demo": True,
            "email": "random_user@gmail.com",
            "name": "Random Person"
        }
        response = self.client.post(url, payload, format='json')
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)
        self.assertIn('error', response.data)

    def test_auth_me_with_jwt(self):
        # 1. Login via Google auth
        url_auth = reverse('google_auth')
        res_auth = self.client.post(url_auth, {"demo": True, "email": "test@jdu.uz"}, format='json')
        access_token = res_auth.data['access']

        # 2. Access /api/auth/me/ with Bearer token
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {access_token}')
        url_me = reverse('user_profile')
        res_me = self.client.get(url_me)
        self.assertEqual(res_me.status_code, status.HTTP_200_OK)
        self.assertEqual(res_me.data['email'], 'test@jdu.uz')
        self.assertIn('profile', res_me.data)
