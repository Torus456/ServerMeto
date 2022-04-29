import json
from django.http import JsonResponse
from .utils.create_report import get_report_incidents, get_report_data
from supp.views import sendmail
# Create your views here.


def create_report_budgetperm(request):
    request_data = json.loads(request.body)
    status = 200
    result = {}
    res = get_report_incidents(
        request_data.get("date_start"),
        request_data.get("date_finish")
    )
    path_file = res.get("path_file")
    name_file = res.get("name")
    result = {}
    result["message"] = "Привет"
    sendmail(request_data.get("email"), "Отчет инцидентов", "text_mail", path_file, name_file)
    return JsonResponse(result, status=status)


def create_report_budgetperm_data(request):
    request_data = json.loads(request.body)
    print("##############")
    status = 200
    result = {}
    res = get_report_data(
        request_data.get("date_start"),
        request_data.get("date_finish")
    )
    path_file = res.get("path_file")
    name_file = res.get("name")
    result = {}
    result["message"] = "Привет"
    sendmail(request_data.get("email"), "Ввод данных", "text_mail", path_file, name_file)
    return JsonResponse(result, status=status)
