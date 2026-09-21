"""
Main URL Configuration for UNIVER SuperApp Backend.
"""
from django.contrib import admin
from django.urls import path, include
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import permissions, status

class HealthCheckView(APIView):
    permission_classes = [permissions.AllowAny]

    def get(self, request):
        return Response({
            "status": "ok",
            "service": "UNIVER SuperApp Mobile Backend",
            "version": "2.0.0",
            "environment": "active",
            "mobile_ready": True
        }, status=status.HTTP_200_OK)

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/health/', HealthCheckView.as_view(), name='health_check'),
    path('api/auth/', include('apps.accounts.urls')),
    path('api/timetable/', include('apps.timetable.urls')),
    path('api/academics/', include('apps.academics.urls')),
]
