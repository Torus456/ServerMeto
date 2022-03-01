# поддержка формирования документа
import cx_Oracle
import docx
import os
import pandas as pd
from datetime import datetime
from django.conf import settings
from docx.shared import Inches
from docx.shared import Pt
from docx.oxml.ns import nsdecls
from docx.oxml import parse_xml


def fill_dataframe(path, query, connect, project_args):
    """
    Заполнить датафрейм на основе запроса
    """
    SQL_QUERY = ""
    print(query)
    with open(os.path.join(path, query), 'r', encoding="utf-8") as file:        
        SQL_QUERY = file.read().replace('\n', ' ')
    df = pd.read_sql(SQL_QUERY, con=connect, params=project_args)
    result = df.where((pd.notnull(df)), None)
    return result


def set_color_cell_header(cell, style):
    """
    Устанавливаем цвет ячейки, использую для шапки
    """
    cell = cell
    cell.paragraphs[0].style = style
    cell.paragraphs[0].alignment = 1
    cell._tc.get_or_add_tcPr().append(parse_xml(r'<w:shd {} w:fill="E0E0E0"/>'.format(nsdecls('w'))))


def create_docx_with_tepmplate(data_js):
    """
    Собираем методику с шаблоном
    """
    os.environ["NLS_LANG"] = '.AL32UTF8'
    sql_path = settings.BASE_DIR + "/supp/sqlscript/63"
    docs_path = settings.BASE_DIR + "/supp/word_template/" + "63.docx"
    con = cx_Oracle.connect('CS_ART/CS_ART@192.168.54.17:1521/ORA5.INCON.LO')
    print(data_js)
    result = {}
    project_args = {
        "MLT_ID": data_js.get("project_args").get("mlt_id"),
        "CLF_ID": data_js.get("project_args").get("clf_id"),
        "CLS_ID": data_js.get("project_args").get("cls_id"),
        "CFV_ID": data_js.get("project_args").get("cfv_id"),
        "PRJ_ID": data_js.get("project_args").get("prj_id"),
        "CST_ID": data_js.get("project_args").get("cst_id"),
    }
    project_args_obj = {
        "MLT_ID": data_js.get("project_args").get("mlt_id"),
        "CLF_ID": data_js.get("project_args").get("clf_id"),
        "CLS_ID": data_js.get("project_args").get("cls_id"),
        "CFV_ID": data_js.get("project_args").get("cfv_id"),
        "PRJ_ID": data_js.get("project_args").get("prj_id"),
        "INCLF_ID": data_js.get("project_args").get("inclf_id"),
        "AOBJ_ID": data_js.get("project_args").get("aobj_id"),
        "CST_ID": data_js.get("project_args").get("cst_id"),
    }
    # Классы, признаки, значения, объекты, оквед
    df_cls = fill_dataframe(sql_path, 'cls_for_doc.sql', con, project_args)
    df_dvs = fill_dataframe(sql_path, 'dvs_for_doc.sql', con, project_args)
    df_vsn = fill_dataframe(sql_path, 'vsn_for_doc2.sql', con, project_args_obj)
    df_obj = fill_dataframe(sql_path, 'obj_for_doc.sql', con, project_args_obj)
    df_okved = fill_dataframe(sql_path, 'okved_for_doc.sql', con, project_args_obj)
    print(data_js)
    document = docx.Document(docs_path)
    for index, row in df_cls.iterrows():
        code = "XXX" if row["CODE"] is None else row["CODE"]
        document.add_heading(code + " - " + row["NAME"], row["CLV_LEV"])
        if row["SNAME"]:
            document.add_paragraph().add_run()
            p = document.add_paragraph(
                "Шаблон наименования",
                style="List Bullet 2"
            )
            p = document.add_paragraph(
                row["SNAME"]
            )
        # if row["FNAME"]:
        #     p = document.add_paragraph(
        #         "Шаблон полного наименования",
        #         style="List Bullet 2"
        #     )
        #     p = document.add_paragraph(
        #         row["FNAME"]
        #     )
        df_obj_cls = df_obj.loc[df_obj["CLS_ID"] == row["CLS_ID"]].head(1)
        if len(df_obj_cls) > 0:
            p = document.add_paragraph(
                "Пример наименования",
                style="List Bullet 2"
            )
            rows = len(df_obj_cls)
            table_obj = document.add_table(rows=rows+1, cols=2)
            table_obj.style = 'Table Grid'
            table_obj.autofit = False
            # Шапка для таблицы объектов эталона
            cell = table_obj.cell(0, 0)
            cell.width = Inches(5.5)
            cell.text = "Наименование"
            set_color_cell_header(cell, "Normal")
            cell = table_obj.cell(0, 1)
            cell.width = Inches(0.5)
            cell.text = "ЕИ"
            set_color_cell_header(cell, "Normal")
            i = 1
            for ind_obj, obj in df_obj_cls.iterrows():
                cell = table_obj.cell(i, 0)
                cell.text = obj["SNAME"]
                cell = table_obj.cell(i, 1)
                cell.width = Inches(0.5)
                if obj["UMS_CODE"]:
                    cell.text = obj["UMS_CODE"]
                i += 1
            document.add_paragraph().add_run()
            p = document.add_paragraph(
                "Перечень атрибутов класса",
                style="List Bullet 2"
            )
            run = p.add_run()
            run.font.name = 'Calibri'
            run.font.size = Pt(12)
            run.underline = True
            # выбираем признаки для класса
            df_attribute_cls = df_dvs.loc[df_dvs["CLS_ID"] == row["CLS_ID"]]
            rows = len(df_attribute_cls)
            table = document.add_table(rows=rows+1, cols=3)
            table.style = 'Table Grid'
            table.autofit = True
            # Шапка для таблицы признаков
            cell = table.cell(0, 0)
            cell.text = "Наименование атрибута"
            set_color_cell_header(cell, "Normal")
            cell = table.cell(0, 1)
            cell.text = "Тип атрибута"
            set_color_cell_header(cell, "Normal")
            cell = table.cell(0, 2)
            cell.text = "ЕИ"
            set_color_cell_header(cell, "Normal")
            cnt = 1
            for ind_attr, attr in df_attribute_cls.iterrows():
                cell = table.cell(cnt, 0)
                cell.text = attr["NAME"]
                cell = table.cell(cnt, 1)
                cell.text = attr["VALTYPE"]
                cell = table.cell(cnt, 2)
                if attr["UMS_CODE"]:
                    cell.text = attr["UMS_CODE"]
                cnt += 1
            # Значения признаков
            df_vsn_cls = df_vsn.loc[df_vsn["CLS_ID"] == row["CLS_ID"]]
            values = len(df_vsn_cls)
            if values > 0:
                document.add_paragraph().add_run()
                p = document.add_paragraph(
                    "Список значений атрибутов",
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
                cell.text = "Наименование атрибута"
                set_color_cell_header(cell, "Normal")
                cell = table_vsn.cell(0, 1)
                cell.text = "Значение"
                set_color_cell_header(cell, "Normal")
                cell = table_vsn.cell(0, 2)
                cell.text = "Обозначение"
                set_color_cell_header(cell, "Normal")
                j = 1
                k = 1
                start_union = 1
                union_name = "Наименование атрибута"
                for ind_vsn, vsn in df_vsn_cls.iterrows():
                    cell = table_vsn.cell(j, 0)
                    cell.text = vsn["NAME"]
                    cell = table_vsn.cell(j, 1)
                    cell.text = vsn["VALUE"]
                    cell = table_vsn.cell(j, 2)
                    cell.text = "" if vsn["SYMSGN"] is None else vsn["SYMSGN"]
                    # объединяем ячейки
                    if union_name != vsn["NAME"]:
                        union_name = vsn["NAME"]
                        start_union = j
                        k = 1
                    else:
                        a = table_vsn.cell(start_union, 0)
                        b = table_vsn.cell(start_union+k, 0)
                        A = a.merge(b)
                        A.text = union_name
                        k += 1
                    j += 1
                document.add_paragraph().add_run()
                if row["UMS_CODE"]:
                    p = document.add_paragraph(
                        "Базовая единица измерения",
                        style="List Bullet 2"
                    )
                    table_umscls = document.add_table(rows=2, cols=3)
                    table_umscls.style = 'Table Grid'
                    table_umscls.autofit = True
                    # Шапка для таблицы значений признаков
                    cell = table_umscls.cell(0, 0)
                    cell.text = "Код ОКЕИ"
                    set_color_cell_header(cell, "Normal")
                    cell = table_umscls.cell(0, 1)
                    cell.text = "Наименование "
                    set_color_cell_header(cell, "Normal")
                    cell = table_umscls.cell(0, 2)
                    cell.text = "Обозначение"
                    set_color_cell_header(cell, "Normal")
                    cell = table_umscls.cell(1, 0)
                    cell.text = row["UMS_ID"]
                    cell = table_umscls.cell(1, 1)
                    cell.text = row["UMS_NAME"]
                    cell = table_umscls.cell(1, 2)
                    cell.text = row["UMS_CODE"]
                df_okved_cls = df_okved.loc[
                    df_okved["CLS_ID"] == row["CLS_ID"]
                    ][["OKVED_CODE", "OKVED_NAME"]].drop_duplicates()
                if len(df_okved_cls) > 0:
                    document.add_paragraph().add_run()
                    p = document.add_paragraph(
                        "Общероссийский классификатор видов экономической деятельности (ОКВЭД 2)",
                        style="List Bullet 2"
                    )
                    table_okved = document.add_table(rows=len(df_okved_cls) + 1, cols=2)
                    table_okved.style = 'Table Grid'
                    table_okved.autofit = True
                    # Шапка для таблицы классов ОКВЕД2
                    cell = table_okved.cell(0, 0)
                    cell.text = "Код класса"
                    set_color_cell_header(cell, "Normal")
                    cell = table_okved.cell(0, 1)
                    cell.text = "Наименование класса"
                    set_color_cell_header(cell, "Normal")
                    r = 1
                    for ind_okv, okv in df_okved_cls.iterrows():
                        cell = table_okved.cell(r, 0)
                        cell.text = okv["OKVED_CODE"]
                        cell = table_okved.cell(r, 1)
                        cell.text = okv["OKVED_NAME"]
                        r += 1
                df_okdp_cls = df_okved.loc[
                    df_okved["CLS_ID"] == row["CLS_ID"]
                    ][["OKDP_CODE", "OKDP_NAME"]].drop_duplicates()
                if len(df_okved_cls) > 0:
                    document.add_paragraph().add_run()
                    p = document.add_paragraph(
                        "Общероссийский классификатор продукции по видам экономической деятельности (ОКПД 2)",
                        style="List Bullet 2"
                    )
                    table_okved = document.add_table(rows=len(df_okdp_cls) + 1, cols=2)
                    table_okved.style = 'Table Grid'
                    table_okved.autofit = True
                    # Шапка для таблицы классов ОКДП2
                    cell = table_okved.cell(0, 0)
                    cell.text = "Код класса"
                    set_color_cell_header(cell, "Normal")
                    cell = table_okved.cell(0, 1)
                    cell.text = "Наименование класса"
                    set_color_cell_header(cell, "Normal")
                    r = 1
                    for ind_okv, okv in df_okdp_cls.iterrows():
                        cell = table_okved.cell(r, 0)
                        cell.text = okv["OKDP_CODE"]
                        cell = table_okved.cell(r, 1)
                        cell.text = okv["OKDP_NAME"]
                        r += 1
                df_lot_cls = df_okved.loc[
                    df_okved["CLS_ID"] == row["CLS_ID"]
                    ][["LOT_CODE"]].drop_duplicates().dropna().head(1)
                if len(df_lot_cls) > 0:
                    document.add_paragraph().add_run()
                    p = document.add_paragraph(
                        "Код НИИ ЛОТ",
                        style="List Bullet 2"
                    )
                    for ind_okv, okv in df_lot_cls.iterrows():
                        p = document.add_paragraph(okv["LOT_CODE"])
        if row["SNAME"]:
            document.add_page_break()

    for paragraph in document.paragraphs:
        if ':КЛАСС:' in paragraph.text:
            paragraph.text = df_cls["CODE"].iloc[0] + ' - ' + df_cls["NAME"].iloc[0]

    path_file = (
                    settings.BASE_DIR +
                    "/upload/Metodika_" +
                    project_args.get("CLS_ID") +
                    "_" +
                    str(datetime.now().strftime("%Y-_%m-%d-%H_%M_%S")) +
                    ".docx"
                )
    document.save(path_file)
    result["path_file"] = path_file
    result["name"] = df_cls["CODE"].iloc[0]
    return result


def create_docx(data_js):
    """
    Создаем методику по фрагменту
    """
    os.environ["NLS_LANG"] = '.AL32UTF8'
    sql_path = settings.BASE_DIR + "/supp/sqlscript/metologic"
    docs_path = settings.BASE_DIR + "/supp/word_template/" + "Schablon64.docx"
    con = cx_Oracle.connect('CS_ART/CS_ART@192.168.54.17:1521/ORA5.INCON.LO')
    result = {}
    project_args = {
        "MLT_ID": data_js.get("project_args").get("mlt_id"),
        "CLF_ID": data_js.get("project_args").get("clf_id"),
        "CLS_ID": data_js.get("project_args").get("cls_id"),
        "CFV_ID": data_js.get("project_args").get("cfv_id"),
        "PRJ_ID": data_js.get("project_args").get("prj_id")
    }
    project_args_obj = {
        "MLT_ID": data_js.get("project_args").get("mlt_id"),
        "CLF_ID": data_js.get("project_args").get("clf_id"),
        "CLS_ID": data_js.get("project_args").get("cls_id"),
        "CFV_ID": data_js.get("project_args").get("cfv_id"),
        "PRJ_ID": data_js.get("project_args").get("prj_id"),
        "INCLF_ID": data_js.get("project_args").get("inclf_id"),
        "AOBJ_ID": data_js.get("project_args").get("aobj_id"),
    }
    # Классы, признаки, значения, объекты, оквед
    df_cls = fill_dataframe(sql_path, 'cls_for_doc.sql', con, project_args)
    df_dvs = fill_dataframe(sql_path, 'dvs_for_doc.sql', con, project_args)
    df_vsn = fill_dataframe(sql_path, 'vsn_for_doc.sql', con, project_args_obj)
    df_obj = fill_dataframe(sql_path, 'obj_for_doc.sql', con, project_args_obj)
    df_okved = fill_dataframe(sql_path, 'okved_for_doc.sql', con, project_args)
    df_okpd = fill_dataframe(sql_path, 'okpd_for_doc.sql', con, project_args)
    document = docx.Document(docs_path)
    # document.add_heading('Методика', 0)
    # Формируем для создания иерархии
    # for index, row in df_cls.iterrows():
    #     code = "XXX" if row["CODE"] is None else row["CODE"]
    #     p = document.add_paragraph(
    #         code + " - " + row["NAME"],
    #         style="List Bullet"
    #     )
    #     p.paragraph_format.left_indent = Inches((row["CLV_LEV"]-1)/4)
    for index, row in df_cls.iterrows():
        code = "XXX" if row["CODE"] is None else row["CODE"]
        document.add_heading(code + " - " + row["NAME"], row["CLV_LEV"])
        if row["SNAME"]:
            # document.add_paragraph().add_run().add_break()
            p = document.add_paragraph(
                "Шаблон краткого наименования",
                style="List Bullet 2"
            )
            p = document.add_paragraph(
                row["SNAME"]
            )
            p = document.add_paragraph(
                "Шаблон полного наименования",
                style="List Bullet 2"
            )
            p = document.add_paragraph(
                row["FNAME"]
            )
        df_obj_cls = df_obj.loc[df_obj["CLS_ID"] == row["CLS_ID"]]
        if len(df_obj_cls) > 0:
            p = document.add_paragraph(
                "Примеры наименований",
                style="List Bullet 2"
            )
            rows = len(df_obj_cls)
            table_obj = document.add_table(rows=rows+1, cols=3)
            table_obj.style = 'Table Grid'
            table_obj.autofit = False
            # Шапка для таблицы объектов эталона
            cell = table_obj.cell(0, 0)
            cell.text = "Краткое наименование"
            set_color_cell_header(cell, "Normal")
            cell = table_obj.cell(0, 1)
            cell.width = Inches(3.5)
            cell.text = "Полное наименование"
            set_color_cell_header(cell, "Normal")
            cell = table_obj.cell(0, 2)
            cell.width = Inches(0.5)
            cell.text = "ЕИ"
            set_color_cell_header(cell, "Normal")
            i = 1
            for ind_obj, obj in df_obj_cls.iterrows():
                cell = table_obj.cell(i, 0)
                cell.text = obj["SNAME"]
                cell = table_obj.cell(i, 1)
                cell.text = obj["FNAME"]
                cell = table_obj.cell(i, 2)
                cell.width = Inches(0.5)
                if obj["UMS_CODE"]:
                    cell.text = obj["UMS_CODE"]
                i += 1
            document.add_paragraph().add_run().add_break()
            p = document.add_paragraph(
                "Перечень признаков класса ТМЦ",
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
            set_color_cell_header(cell, "Normal")
            cell = table.cell(0, 1)
            cell.text = "Тип признака"
            set_color_cell_header(cell, "Normal")
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
                document.add_paragraph().add_run().add_break()
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
                set_color_cell_header(cell, "Normal")
                cell = table_vsn.cell(0, 1)
                cell.text = "Значение"
                set_color_cell_header(cell, "Normal")
                cell = table_vsn.cell(0, 2)
                cell.text = "Обозначение"
                set_color_cell_header(cell, "Normal")
                j = 1
                k = 1
                start_union = 1
                union_name = "Наименование признака"
                for ind_vsn, vsn in df_vsn_cls.iterrows():
                    cell = table_vsn.cell(j, 0)
                    cell.text = vsn["NAME"]
                    cell = table_vsn.cell(j, 1)
                    cell.text = vsn["VALUE"]
                    cell = table_vsn.cell(j, 2)
                    cell.text = "" if vsn["SYMSGN"] is None else vsn["SYMSGN"]
                    # объединяем ячейки
                    if union_name != vsn["NAME"]:
                        union_name = vsn["NAME"]
                        start_union = j
                        k = 1
                    else:
                        a = table_vsn.cell(start_union, 0)
                        b = table_vsn.cell(start_union+k, 0)
                        A = a.merge(b)
                        A.text = union_name
                        k += 1
                    j += 1
                document.add_paragraph().add_run().add_break()
                if row["UMS_CODE"]:
                    p = document.add_paragraph(
                        "Базовая единица измерения",
                        style="List Bullet 2"
                    )
                    table_umscls = document.add_table(rows=2, cols=2)
                    table_umscls.style = 'Table Grid'
                    table_umscls.autofit = True
                    # Шапка для таблицы значений признаков
                    cell = table_umscls.cell(0, 0)
                    cell.text = "Наименование "
                    set_color_cell_header(cell, "Normal")
                    cell = table_umscls.cell(0, 1)
                    cell.text = "Обозначение"
                    set_color_cell_header(cell, "Normal")
                    cell = table_umscls.cell(1, 0)
                    cell.text = row["UMS_NAME"]
                    cell = table_umscls.cell(1, 1)
                    cell.text = row["UMS_CODE"]
                df_okved_cls = df_okved.loc[
                    df_okved["CLS_ID"] == row["CLS_ID"]
                    ][["OKVED_CODE", "OKVED_NAME"]].drop_duplicates()
                if len(df_okved_cls) > 0:
                    document.add_paragraph().add_run().add_break()
                    p = document.add_paragraph(
                        "Общероссийский классификатор видов экономической деятельности (ОКВЭД2)",
                        style="List Bullet 2"
                    )
                    table_okved = document.add_table(rows=len(df_okved_cls) + 1, cols=2)
                    table_okved.style = 'Table Grid'
                    table_okved.autofit = True
                    # Шапка для таблицы классов ОКВЕД2
                    cell = table_okved.cell(0, 0)
                    cell.text = "Код класса"
                    set_color_cell_header(cell, "Normal")
                    cell = table_okved.cell(0, 1)
                    cell.text = "Наименование класса"
                    set_color_cell_header(cell, "Normal")
                    r = 1
                    for ind_okv, okv in df_okved_cls.iterrows():
                        cell = table_okved.cell(r, 0)
                        cell.text = okv["OKVED_CODE"]
                        cell = table_okved.cell(r, 1)
                        cell.text = okv["OKVED_NAME"]
                        r += 1
                
                df_okpd_cls = df_okpd.loc[
                    df_okpd["CLS_ID"] == row["CLS_ID"]
                    ][["OKVED_CODE", "OKVED_NAME"]].drop_duplicates()
                
                if len(df_okpd_cls) > 0:
                    print(row["CLS_ID"])
                    print(df_okpd_cls.head())
                    document.add_paragraph().add_run().add_break()
                    p = document.add_paragraph(
                        "Общероссийский классификатор продукции (ОКПД2)",
                        style="List Bullet 2"
                    )
                    table_okpd = document.add_table(rows=len(df_okpd_cls) + 1, cols=2)
                    table_okpd.style = 'Table Grid'
                    table_okpd.autofit = True
                    # Шапка для таблицы классов ОКВЕД2
                    cell = table_okpd.cell(0, 0)
                    cell.text = "Код класса"
                    set_color_cell_header(cell, "Normal")
                    cell = table_okpd.cell(0, 1)
                    cell.text = "Наименование класса"
                    set_color_cell_header(cell, "Normal")
                    r = 1
                    for ind_okp, okp in df_okpd_cls.iterrows():
                        cell = table_okpd.cell(r, 0)
                        cell.text = okp["OKVED_CODE"]
                        cell = table_okpd.cell(r, 1)
                        cell.text = okp["OKVED_NAME"]
                        r += 1
        if row["SNAME"]:
            document.add_page_break()

    path_file = (
                    settings.BASE_DIR +
                    "/upload/Metodika_" +
                    project_args.get("CLS_ID") +
                    "_" +
                    str(datetime.now().strftime("%Y-_%m-%d-%H_%M_%S")) +
                    ".docx"
                )
    document.save(path_file)
    result["path_file"] = path_file
    result["name"] = "Hello"
    return result


def create_docx64(data_js):
    """
    Создаем методику по фрагменту
    """
    os.environ["NLS_LANG"] = '.AL32UTF8'
    sql_path = settings.BASE_DIR + "/supp/sqlscript/metologic"
    docs_path = settings.BASE_DIR + "/supp/word_template/" + "Schablon64.docx"
    con = cx_Oracle.connect('CS_ART/CS_ART@192.168.54.17:1521/ORA5.INCON.LO')
    result = {}
    project_args = {
        "MLT_ID": data_js.get("project_args").get("mlt_id"),
        "CLF_ID": data_js.get("project_args").get("clf_id"),
        "CLS_ID": data_js.get("project_args").get("cls_id"),
        "CFV_ID": data_js.get("project_args").get("cfv_id"),
        "PRJ_ID": data_js.get("project_args").get("prj_id")
    }
    project_args_obj = {
        "MLT_ID": data_js.get("project_args").get("mlt_id"),
        "CLF_ID": data_js.get("project_args").get("clf_id"),
        "CLS_ID": data_js.get("project_args").get("cls_id"),
        "CFV_ID": data_js.get("project_args").get("cfv_id"),
        "PRJ_ID": data_js.get("project_args").get("prj_id"),
        "INCLF_ID": data_js.get("project_args").get("inclf_id"),
        "AOBJ_ID": data_js.get("project_args").get("aobj_id"),
    }
    # Классы, признаки, значения, объекты, оквед
    df_cls = fill_dataframe(sql_path, 'cls_for_doc.sql', con, project_args)
    df_dvs = fill_dataframe(sql_path, 'dvs_for_doc.sql', con, project_args)
    df_vsn = fill_dataframe(sql_path, 'vsn_for_doc.sql', con, project_args_obj)
    df_obj = fill_dataframe(sql_path, 'obj_for_doc.sql', con, project_args_obj)
    document = docx.Document(docs_path)
    # добавляем параграф с оглавлением
    add_table_of_contents(document)
    document.add_page_break()

    for row in df_cls.itertuples():
        code = "XXX" if row.CODE is None else row.CODE
        # descr = "" if row["DESCR"] is None else "(" + row["DESCR"] + ")"
        document.add_heading(code + " - " + row.NAME, row.CLV_LEV)
        # document.add_paragraph().add_run().add_break()
        if row.SNAME:
            add_project_template(document, row)
        # Далее заполняем данные для класса
        df_obj_cls = df_obj.loc[df_obj["CLS_ID"] == row.CLS_ID]
        if len(df_obj_cls) > 0:
            add_project_name(document, df_obj_cls)
            document.add_paragraph().add_run().add_break()
            # выбираем признаки для класса
            df_attribute_cls = df_dvs.loc[df_dvs["CLS_ID"] == row.CLS_ID]
            add_dvs_type_and_name(document, df_attribute_cls)
            # Значения признаков
            df_vsn_cls = df_vsn.loc[df_vsn["CLS_ID"] == row.CLS_ID]
            add_object_value(document, df_vsn_cls)
            document.add_paragraph().add_run().add_break()
            if row.UMS_CODE:
                add_table_of_ums(document, row)
        if row.SNAME:
            document.add_page_break()
    # Меняем в заголовке
    for paragraph in document.paragraphs:
        if ':КЛАСС:' in paragraph.text:
            paragraph.text = "Класс: " + df_cls["CODE"].iloc[0] + ' - ' + df_cls["NAME"].iloc[0]
    text_footer = "Класс: " + df_cls["CODE"].iloc[0] + ' - ' + df_cls["NAME"].iloc[0]
    for section in document.sections:
        footer = section.footer
        if ':КЛАСС:' in footer.tables[0].cell(0, 0).text:
            footer.tables[0].cell(0, 0).text = footer.tables[0].cell(0, 0).text.replace(":КЛАСС:", text_footer)
            footer.tables[0].cell(0, 0).paragraphs[0].alignment = 1
    path_file = (
        settings.BASE_DIR +
        "/upload/Metodika_" +
        project_args.get("CLS_ID") +
        "_" +
        str(datetime.now().strftime("%Y-_%m-%d-%H_%M_%S")) +
        ".docx"
    )
    document.save(path_file)
    result["path_file"] = path_file
    result["name"] = str(df_cls["CODE"].iloc[0] + ' - ' + df_cls["NAME"].iloc[0])
    return result


def add_table_of_contents(document: object):
    """
    Добавляем оглавление. Создаем оглавление, которое нужно обновить вручную
    """
    paragraph = document.add_paragraph()
    run = paragraph.add_run()
    fldChar = parse_xml(r'<w:fldChar {} w:fldCharType="begin"/>'.format(nsdecls('w')))  # Добавлем елемент
    instrText = parse_xml(r'<w:instrText {} xml:space="preserve"/>'.format(nsdecls('w')))
    instrText.text = 'TOC \\o "1-9" \\h \\z \\u'
    fldChar2 = parse_xml(r'<w:fldChar {} w:fldCharType="separate"/>'.format(nsdecls('w')))  # creates a new element
    fldChar3 = parse_xml(r'<w:t {} />'.format(nsdecls('w')))
    fldChar3.text = "Правой кнопкой и обновить."
    fldChar2.append(fldChar3)
    fldChar4 = parse_xml(r'<w:fldChar {} w:fldCharType="end"/>'.format(nsdecls('w')))
    r_element = run._r
    r_element.append(fldChar)
    r_element.append(instrText)
    r_element.append(fldChar2)
    r_element.append(fldChar4)
    paragraph._p


def add_table_of_ums(document, row):
    """
    Добавление таблицы с единицей измерения
    """
    document.add_paragraph(
        "Базовая единица измерения",
        style="List Bullet 2"
    )
    table_umscls = document.add_table(rows=2, cols=2)
    table_umscls.style = 'Table Grid'
    table_umscls.autofit = True
    # Шапка для таблицы значений признаков
    cell = table_umscls.cell(0, 0)
    cell.text = "Наименование "
    set_color_cell_header(cell, "Normal")
    cell = table_umscls.cell(0, 1)
    cell.text = "Обозначение"
    set_color_cell_header(cell, "Normal")
    cell = table_umscls.cell(1, 0)
    cell.text = row.UMS_NAME
    cell = table_umscls.cell(1, 1)
    cell.text = row.UMS_CODE


def add_project_template(document, row):
    """
    Добавляем в документ проектные шаблоны наименований
    """
    document.add_paragraph(
        "Шаблон краткого наименования",
        style="List Bullet 2"
    )
    document.add_paragraph(
        row.SNAME
    )
    document.add_paragraph(
        "Шаблон полного наименования",
        style="List Bullet 2"
    )
    document.add_paragraph(
        row.FNAME
    )


def add_project_name(document, df_obj_cls):
    """
    Добавляем проектные наименования и ЕИ
    """
    df_obj_cls = df_obj_cls.sort_values(by="SNAME")
    document.add_paragraph(
        "Примеры наименований",
        style="List Bullet 2"
    )
    rows = len(df_obj_cls)
    table_obj = document.add_table(rows=rows+1, cols=3)
    table_obj.style = 'Table Grid'
    table_obj.autofit = False
    # Шапка для таблицы объектов эталона
    cell = table_obj.cell(0, 0)
    cell.text = "Краткое наименование"
    set_color_cell_header(cell, "Normal")
    cell = table_obj.cell(0, 1)
    cell.width = Inches(3.5)
    cell.text = "Полное наименование"
    set_color_cell_header(cell, "Normal")
    cell = table_obj.cell(0, 2)
    cell.width = Inches(0.5)
    cell.text = "ЕИ"
    set_color_cell_header(cell, "Normal")
    i = 1
    for obj in df_obj_cls.itertuples():
        cell = table_obj.cell(i, 0)
        cell.text = obj.SNAME
        cell = table_obj.cell(i, 1)
        cell.text = obj.FNAME
        cell = table_obj.cell(i, 2)
        cell.width = Inches(0.5)
        if obj.UMS_CODE:
            cell.text = obj.UMS_CODE
        i += 1


def add_object_value(document, df_vsn_cls):
    """Добавляем значения признаков"""
    values = len(df_vsn_cls)
    if values == 0:
        return
    document.add_paragraph().add_run().add_break()
    values = len(df_vsn_cls)
    p = document.add_paragraph(
        "Примеры значений признаков (могут быть дополнены в ходе наполнения класса)",
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
    set_color_cell_header(cell, "Normal")
    cell = table_vsn.cell(0, 1)
    cell.text = "Значение"
    set_color_cell_header(cell, "Normal")
    cell = table_vsn.cell(0, 2)
    cell.text = "Обозначение"
    set_color_cell_header(cell, "Normal")
    j = 1
    k = 1
    start_union = 1
    union_name = "Наименование признака"
    for vsn in df_vsn_cls.itertuples():
        cell = table_vsn.cell(j, 0)
        cell.text = vsn.NAME
        cell = table_vsn.cell(j, 1)
        cell.text = "" if vsn.VALUE is None else vsn.VALUE
        cell = table_vsn.cell(j, 2)
        cell.text = "" if vsn.SYMSGN is None else vsn.SYMSGN
        # объединяем ячейки
        if union_name != vsn.NAME:
            union_name = vsn.NAME
            start_union = j
            k = 1
        else:
            a = table_vsn.cell(start_union, 0)
            b = table_vsn.cell(start_union+k, 0)
            A = a.merge(b)
            A.text = union_name
            k += 1
        j += 1


def add_dvs_type_and_name(document, df_attribute_cls):
    """
    Добавляем в документ Наименования и тип ОД
    """
    p = document.add_paragraph(
        "Перечень признаков класса ТМЦ",
        style="List Bullet 2"
    )
    run = p.add_run()
    run.font.name = 'Calibri'
    run.font.size = Pt(12)
    run.underline = True
    rows = len(df_attribute_cls)
    table = document.add_table(rows=rows+1, cols=2)
    table.style = 'Table Grid'
    table.autofit = True
    # Шапка для таблицы признаков
    cell = table.cell(0, 0)
    cell.text = "Наименование признака"
    set_color_cell_header(cell, "Normal")
    cell = table.cell(0, 1)
    cell.text = "Тип признака"
    set_color_cell_header(cell, "Normal")
    cnt = 1
    add_decription = False
    for attr in df_attribute_cls.itertuples():
        cell = table.cell(cnt, 0)
        cell.text = attr.NAME
        if ("(Не обязательный)" in attr.NAME):
            add_decription = True
            cell.paragraphs[0].add_run('1')
            cell.paragraphs[0].runs[1].font.superscript = True
        cell = table.cell(cnt, 1)
        cell.text = attr.VALTYPE
        cnt += 1
    if add_decription:
        document.add_paragraph("1 – Если значение признака не определено для записи материала, оно может быть не указано")
