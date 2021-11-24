from celery import shared_task
from apireport.celery import celery_app
from django.conf import settings
from metologic.utils.support_docx import create_docx_with_tepmplate
from supp.views import sendmail

@shared_task
def add_task(x, y):
    return x + y


@shared_task
def send_mail(data):
    '''Send document to mail'''
    res = create_docx_with_tepmplate(data) 
    sendmail(data.get("project_args").get("email"), "subject_mail", "text_mail", res.get("path_file"), res.get("name"))