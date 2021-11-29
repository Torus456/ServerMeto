import json
from django.shortcuts import render
from django.http import JsonResponse
from supp.views import sendmail
from .utils.support_docx import create_docx, create_docx_with_tepmplate, create_docx64
from  metologic.tasks import send_mail, add_task


def create_metodologic(request):
    '''
    Принимаем данные для формирования методологии
    '''
    request_data = json.loads(request.body)
    print(request_data)
    res = create_docx64(request_data)
    path_file = res.get("path_file")
    name_file = res.get("name")
    status = 200
    result = {}
    result["message"] = "Привет"
    sendmail(request_data.get("project_args").get("email"), "subject_mail", "text_mail", path_file, name_file)
    return JsonResponse(result, status=status)


def create_methodology(request):
    '''
    Принимаем данные для формирования методологии
    '''
    request_data = json.loads(request.body)
    res = create_docx_with_tepmplate(request_data)
    path_file = res.get("path_file")
    name_file = res.get("name") + ".docx"
    status = 200
    result = {}
    result["message"] = "Привет"
    print(name_file)
    sendmail(request_data.get("project_args").get("email"), "subject_mail", "text_mail", path_file, name_file)
    return JsonResponse(result, status=status)


def delay_methodology(request):
    request_data = json.loads(request.body)
    print("delay")
    status = 200
    result = {}
    result["message"] = "Привет"
    task = send_mail.delay(request_data)
    print(task.id)
    print(task.status)
    return JsonResponse(result, status=status)
