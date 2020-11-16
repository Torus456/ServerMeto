from django.shortcuts import render
from supp.utils.support_mail import sendmail

# Create your views here.


def send_report():
    '''
    Отправить по почте отчет
    '''
    sendmail(
        "rpulatov@incon.ru",
        "Тест",
        "Тест",
        ""
    )
