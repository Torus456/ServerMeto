from django.conf.urls import url
from .import views

app_name = "standard_support"
# app_name will help us do a reverse look-up latter.
urlpatterns = [
    url('parse_gosts', views.parse_gosts, name='parse-gosts'),
    url('parse_yaspeller', views.parse_yaspeller, name='parse-yaspeller'),
]
