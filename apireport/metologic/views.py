import json
from django.shortcuts import render
from django.http import JsonResponse

# Create your views here.


def create_metodologic(request):
    '''
    Принимаем данные для формирования методологии
    '''
    request_data = json.loads(request.body)
    print(request_data)
    status = 200
    result = {}
    result["message"] = "Привет"
    return JsonResponse(result, status=status)
