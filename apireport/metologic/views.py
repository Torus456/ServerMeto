import json
from django.http import JsonResponse
from supp.views import sendmail
from .utils.support_docx import create_docx_with_tepmplate, create_docx64, create_docx67, create_docx66, create_docx71
from .utils.support_json import fill_json_for_ns
from .utils.support_excel import (
    fill_excel_for_ns,
    fill_excel_for_ink,
    fill_excel_for_ns_template,
    fill_excel_comment_for_ink
)
from metologic.tasks import send_mail


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
    print(name_file)
    sendmail(request_data.get("project_args").get("email"), "Методика", "text_mail", path_file, name_file)
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
    sendmail(request_data.get("project_args").get("email"), "subject_mail", "text_mail", path_file, str(name_file))
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


def get_northsteel_data_json(request):
    request_data = json.loads(request.body)
    res = fill_json_for_ns(request_data)
    path_file = res.get("path_file")
    name_file = res.get("name") + ".json"
    status = 200
    result = {}
    result["message"] = "Привет"
    sendmail(request_data.get("project_args").get("email"), "subject_mail", "text_mail", path_file, str(name_file))
    return JsonResponse(result, status=status)


def get_northsteel_data_excel(request):
    request_data = json.loads(request.body)
    res = fill_excel_for_ns(request_data)
    path_file = res.get("path_file")
    name_file = res.get("name") + ".xlsx"
    status = 200
    result = {}
    result["message"] = "Привет"
    sendmail(request_data.get("project_args").get("email"), "subject_mail", "text_mail", path_file, str(name_file))
    return JsonResponse(result, status=status)


def get_northsteel_data_template(request):
    request_data = json.loads(request.body)
    res = fill_excel_for_ns_template(request_data)
    path_file = res.get("path_file")
    name_file = res.get("name") + ".xlsx"
    status = 200
    result = {}
    result["message"] = "Привет"
    sendmail(request_data.get("project_args").get("email"), "subject_mail", "text_mail", path_file, str(name_file))
    return JsonResponse(result, status=status)


def get_ink_data_excel(request):
    """ Формируем excel-файл, каждый класс на отдельном листе"""
    request_data = json.loads(request.body)
    res = fill_excel_for_ink(request_data)
    path_file = res.get("path_file")
    name_file = res.get("name") + ".xlsx"
    status = 200
    result = {}
    result["message"] = "Привет"
    sendmail(request_data.get("project_args").get("email"), "subject_mail", "text_mail", path_file, str(name_file))
    return JsonResponse(result, status=status)


def get_ink_vendor_comment(request):
    """
    Формирование единого файла с комментариями
    """
    request_data = json.loads(request.body)
    res = fill_excel_comment_for_ink(request_data)
    path_file = res.get("path_file")
    print(path_file)
    name_file = res.get("name") + ".xlsx"
    status = 200
    result = {}
    result["message"] = "Привет"
    # print(type(path_file))
    sendmail(request_data.get("email"), "subject_mail", "text_mail", path_file, str(name_file))
    return JsonResponse(result, status=status)


def ink_metodology(request):
    '''
    Принимаем данные для формирования методологии
    '''
    request_data = json.loads(request.body)
    res = create_docx67(request_data)
    path_file = res.get("path_file")
    name_file = res.get("name") + ".docx"
    status = 200
    result = {}
    result["message"] = "Привет"
    print(name_file)
    sendmail(request_data.get("project_args").get("email"), "subject_mail", "text_mail", path_file, str(name_file))
    return JsonResponse(result, status=status)

def sev_metodology(request):
    '''
    Принимаем данные для формирования методологии
    '''
    request_data = json.loads(request.body)
    res = create_docx66(request_data)
    path_file = res.get("path_file")
    name_file = res.get("name") + ".docx"
    status = 200
    result = {}
    result["message"] = "Привет"
    print(name_file)
    sendmail(request_data.get("project_args").get("email"), "subject_mail", "text_mail", path_file, str(name_file))
    return JsonResponse(result, status=status)

def get_unipro_data_excel(request):
    request_data = json.loads(request.body)
    res = fill_excel_for_ns(request_data)
    path_file = res.get("path_file")
    name_file = res.get("name") + ".xlsx"
    status = 200
    result = {}
    result["message"] = "Привет"
    sendmail(request_data.get("project_args").get("email"), "subject_mail", "text_mail", path_file, str(name_file))
    return JsonResponse(result, status=status)

def mag_metodology(request):
    '''
    Принимаем данные для формирования методологии
    '''
    request_data = json.loads(request.body)
    res = create_docx71(request_data)
    path_file = res.get("path_file")
    name_file = res.get("name") + ".docx"
    status = 200
    result = {}
    result["message"] = "Привет"
    print(name_file)
    sendmail(request_data.get("project_args").get("email"), "subject_mail", "text_mail", path_file, str(name_file))
    return JsonResponse(result, status=status)
