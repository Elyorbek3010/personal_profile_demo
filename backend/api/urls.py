from django.urls import path
from rest_framework_simplejwt.views import TokenRefreshView
from .views import HealthCheckView, RegisterView, UserProfileView, GoogleAuthView, AITimetableParseView, CustomTokenObtainPairView

urlpatterns = [
    path('health/', HealthCheckView.as_view(), name='health_check'),
    path('auth/google/', GoogleAuthView.as_view(), name='google_auth'),
    path('auth/register/', RegisterView.as_view(), name='auth_register'),
    path('auth/login/', CustomTokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('auth/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('auth/me/', UserProfileView.as_view(), name='user_profile'),
    path('timetable/parse/', AITimetableParseView.as_view(), name='timetable_ai_parse'),
]
