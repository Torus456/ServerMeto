from django.conf.urls import url
from .import views

app_name = "budgetpermreport"
# app_name will help us do a reverse look-up latter.
urlpatterns = [
    url('budgetperm_report_incident', views.create_report_budgetperm, name="create-report-budgetperm"),
    url('budgetperm_report_data', views.create_report_budgetperm_data, name="create-report-budgetperm-data")
]
