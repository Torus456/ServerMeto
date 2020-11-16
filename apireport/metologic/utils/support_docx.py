# поддержка формирования документа
import os
import docx
import cx_Oracle
import pandas as pd
from django.conf import settings
from docx.shared import Inches
from docx.shared import Pt
from docx.enum.table import WD_ALIGN_VERTICAL
from docx.enum.text import WD_PARAGRAPH_ALIGNMENT


def create_docx(data_js):
    """
    Создаем методику по фрагменту
    """
    os.environ["NLS_LANG"] = '.AL32UTF8'
    sql_path = settings.BASE_DIR + "\\supp\\sqlscript\\metologic"
    con = cx_Oracle.connect('CS_ART/CS_ART@192.168.54.17:1521/ORA5.INCON.LO')
    print(data_js)
    project_args = {
        "MLT_ID": data_js.get("project_args").get("mlt_id"),
        "CLF_ID": data_js.get("project_args").get("clf_id"),
        "CLS_ID": data_js.get("project_args").get("cls_id"),
        "CFV_ID": data_js.get("project_args").get("cfv_id")
    }
    print(project_args)
    # Классы
    SQL_QUERY = ""
    with open(os.path.join(sql_path, 'cls_for_doc.sql'), 'r') as file:
        SQL_QUERY = file.read().replace('\n', ' ')
    print(SQL_QUERY)
    df = pd.read_sql(SQL_QUERY, con=con, params=project_args)
    df_cls = df.where((pd.notnull(df)), None)
    # Признаки
    SQL_QUERY = ""
    with open(os.path.join(sql_path, 'dvs_for_doc.sql'), 'r') as file:
        SQL_QUERY = file.read().replace('\n', ' ')
    df = pd.read_sql(SQL_QUERY, con=con, params=project_args)
    df_dvs = df.where((pd.notnull(df)), None)
    df_dvs.head()
    # Значения признаков
    SQL_QUERY = ""
    with open(os.path.join(sql_path, 'vsn_for_doc.sql'), 'r') as file:
        SQL_QUERY = file.read().replace('\n', ' ')
    df = pd.read_sql(SQL_QUERY, con=con, params=project_args)
    df_vsn = df.where((pd.notnull(df)), None)
    df_vsn.head()
    document = docx.Document()
    document.add_heading('Методика', 0)

    for index, row in df_cls.iterrows():
        p = document.add_paragraph(
            row["CODE"] + " - " + row["NAME"],
            style="List Bullet"
        )
        p.paragraph_format.left_indent = Inches((row["CLV_LEV"]-1)/4)
    document.add_heading("Признаки", 1)

    for index, row in df_cls.iterrows():
        if row["SNAME"]:
            document.add_heading(row["CODE"] + " - " + row["NAME"], 2)
            p = document.add_paragraph(
                "Шаблон краткого наименование",
                style="List Bullet 2"
            )
            p = document.add_paragraph(
                row["SNAME"]
            )        
            p = document.add_paragraph(
                "Перечень признаков класса МТР", 
                style="List Bullet 2"
            )
            run = p.add_run()
            run.font.name = 'Calibri'
            run.font.size = Pt(12)
            run.underline = True
            # выбираем признаки для класса
            df_attribute_cls = df_dvs.loc[df_dvs["CLS_ID"] == row["CLS_ID"]]
            rows = len(df_attribute_cls)
            table = document.add_table(rows=rows+1, cols=2)
            table.style = 'Table Grid'
            table.autofit = True
            # Шапка для таблицы признаков
            cell = table.cell(0, 0)
            cell.text = "Наименование признака"
            cell.paragraphs[0].style = "Heading 4"
            cell.paragraphs[0].alignment = 1
            cell = table.cell(0, 1)
            cell.text = "Тип признака"
            cell.paragraphs[0].style = "Heading 4"
            cell.paragraphs[0].alignment = 1
            cnt = 1
            for ind_attr, attr in df_attribute_cls.iterrows():
                cell = table.cell(cnt, 0)
                cell.text = attr["NAME"]
                cell = table.cell(cnt, 1)
                cell.text = attr["VALTYPE"]
                cnt += 1
            # Значения признаков
            df_vsn_cls = df_vsn.loc[df_vsn["CLS_ID"] == row["CLS_ID"]]
            values = len(df_vsn_cls)
            if values > 0:
                p = document.add_paragraph(
                    "Список значений",
                    style="List Bullet 2"
                )
                run = p.add_run()
                run.font.name = 'Calibri'
                run.font.size = Pt(12)
                run.underline = True
                # Значения признаков
                table_vsn = document.add_table(rows=values+1, cols=3)
                table_vsn.style = 'Table Grid'
                table_vsn.autofit = True
                # Шапка для таблицы значений признаков
                cell = table_vsn.cell(0, 0)
                cell.text = "Наименование признака"
                cell.paragraphs[0].style = "Heading 4"
                cell.paragraphs[0].alignment = 1
                cell = table_vsn.cell(0, 1)
                cell.text = "Значение"
                cell.paragraphs[0].style = "Heading 4"
                cell.paragraphs[0].alignment = 1
                cell = table_vsn.cell(0, 2)
                cell.text = "Обозначение"
                cell.paragraphs[0].style = "Heading 4"
                cell.paragraphs[0].alignment = 1
                j = 1
                for ind_vsn, vsn in df_vsn_cls.iterrows():
                    cell = table_vsn.cell(j, 0)
                    cell.text = vsn["NAME"]
                    cell = table_vsn.cell(j, 1)
                    cell.text = vsn["VALUE"]
                    cell = table_vsn.cell(j, 2)
                    cell.text = "" if vsn["SYMSGN"]==None else vsn["SYMSGN"]
                    j += 1
    document.save('Instruction.docx')
