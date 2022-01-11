from django.conf.urls import url
from .import views

app_name = "budgetpermreport"
# app_name will help us do a reverse look-up latter.
urlpatterns = [
    url('budgetperm_report', views.create_report_budgetperm, name="create-report-budgetperm")
]
