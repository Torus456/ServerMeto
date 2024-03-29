from django.conf.urls import url
from .import views

app_name = "metologic"
# app_name will help us do a reverse look-up latter.
urlpatterns = [
    url('metodologic', views.create_metodologic, name='create-metodologic'),
    url('delay_methodology', views.delay_methodology, name='delay-methodology'),
    url('methodology', views.create_methodology, name='create-methodology'),
    url('get_northsteel_data_json', views.get_northsteel_data_json, name='get-northsteel-data'),
    url('get_northsteel_data_excel', views.get_northsteel_data_excel, name='get-northsteel-excel'),
    url('get_northsteel_data_template', views.get_northsteel_data_template, name='get-northsteel-template'),
    url('get_ink_data_excel', views.get_ink_data_excel, name='get-ink-excel'),
    url('get_ink_vendor_comment', views.get_ink_vendor_comment, name='get-ink-comment'),
    url('ink_metodology', views.ink_metodology, name='ink-metodology'),
]
