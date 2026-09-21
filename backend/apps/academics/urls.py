from django.urls import path
from .views import AcademicDataView, SetDataLinkView

app_name = 'academics'

urlpatterns = [
    path('my-data/', AcademicDataView.as_view(), name='my-data'),
    path('set-link/', SetDataLinkView.as_view(), name='set-link'),
]
