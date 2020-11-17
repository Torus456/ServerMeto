import json
from django.shortcuts import render
from django.http import JsonResponse
from supp.views import sendmail
from .utils.support_docx import create_docx

# Create your views here.


def create_metodologic(request):
    '''
    Принимаем данные для формирования методологии
    '''
    request_data = json.loads(request.body)
    print(request_data)
    path_file = create_docx(request_data)
    status = 200
    result = {}
    result["message"] = "Привет"
    sendmail(request_data.get("project_args").get("email"), "subject_mail", "text_mail", path_file)
    return JsonResponse(result, status=status)
