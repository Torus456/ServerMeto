import docx
import os
import pandas as pd
import pyodbc
from datetime import datetime
from django.conf import settings
from docx.shared import Inches
from docx.shared import Pt
from docx.oxml.ns import nsdecls
from docx.oxml import parse_xml
from supp.utils.helpers_db import fill_dataframe


def connect_to_portal():
    """
    Создаем подключение к порталу используя доменное подключение
    """
    conn = pyodbc.connect(
        'Driver={SQL Server};'
        'Server=FS2;'
        'Database=TTS;'
        'Trusted_Connection=yes;'
    )
    return conn


def get_report_incidents(start_date: str, end_date: str):
    """
    Формируем даннные по инцидентам  отправляем на указанную почту
    """
    result = {}
    sql_path = settings.BASE_DIR + "/supp/sqlscript/permbudget"
    docs_path = settings.BASE_DIR + "/supp/word_template/" + "Incidents.docx"
    project_args = (
        start_date,
        end_date
    )
    conn = connect_to_portal()
    incidents = fill_dataframe(
        sql_path,
        'get_incident.sql',
        conn,
        project_args
    )
    document = docx.Document(docs_path)
    rows = len(incidents)
    table_incident = document.add_table(rows=rows + 1, cols=6)
    table_incident.style = 'Table Grid'
    table_incident.autofit = True
    # Шапка для таблицы значений признаков
    cell = table_incident.cell(0, 0)
    cell.text = "п/п"
    cell.width = Inches(0.5)
    cell = table_incident.cell(0, 1)
    cell.text = "Наименование инцидента"
    cell = table_incident.cell(0, 2)
    cell.text = "Описание"
    cell = table_incident.cell(0, 3)
    cell.text = "Приоритет"
    cell = table_incident.cell(0, 4)
    cell.text = "Дата выявления"
    cell = table_incident.cell(0, 5)
    cell.text = "Дата исправления"
    i = 1
    for row in incidents.itertuples():
        cell = table_incident.cell(i, 0)
        cell.width = Inches(0.5)
        cell.text = str(row.record_number)
        cell = table_incident.cell(i, 1)
        cell.text = row.record_title
        cell = table_incident.cell(i, 2)
        cell.text = row.record_desc
        cell = table_incident.cell(i, 3)
        cell.text = row.priority_name
        cell = table_incident.cell(i, 4)
        cell.text = row.date_start
        cell = table_incident.cell(i, 5)
        cell.text = row.date_finish
        i += 1
    path_file = (
        settings.BASE_DIR +
        "/upload/Incidents_" +
        "_" +
        str(datetime.now().strftime("%Y-_%m-%d-%H_%M_%S")) +
        ".docx"
    )
    document.save(path_file)
    result["path_file"] = path_file
    result["name"] = "Отчет инцидентов"
    return result
