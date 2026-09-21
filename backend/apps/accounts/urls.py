from django.urls import path
from rest_framework_simplejwt.views import TokenRefreshView
from .views import (
    CustomTokenObtainPairView,
    GoogleAuthView,
    UserProfileView,
    UpdateAvatarView
)

urlpatterns = [
    path('login/', CustomTokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('google/', GoogleAuthView.as_view(), name='google_auth'),
    path('me/', UserProfileView.as_view(), name='user_profile'),
    path('update-avatar/', UpdateAvatarView.as_view(), name='update_avatar'),
]
