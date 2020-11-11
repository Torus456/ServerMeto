from django.conf.urls import url
from .import views

app_name = "metologic"
# app_name will help us do a reverse look-up latter.
urlpatterns = [
    url('metodologic', views.create_metodologic, name='create-metodologic'),
]