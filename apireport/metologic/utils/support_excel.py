import os
import cx_Oracle
import pandas as pd
from datetime import datetime
from django.conf import settings

from .support_docx import fill_dataframe


def fill_excel_for_ns(data_js):
    """ По данным сформируем excel файл"""
    os.environ["NLS_LANG"] = '.AL32UTF8'
    sql_path = settings.BASE_DIR + "/supp/sqlscript/66/"
    con = cx_Oracle.connect('CS_ART/CS_ART@192.168.54.17:1521/ORA5.INCON.LO')
    result = {}
    project_args = {
        "MLT_ID": data_js.get("project_args").get("mlt_id"),
        "CLF_ID": data_js.get("project_args").get("clf_id"),
        "CLS_ID": data_js.get("project_args").get("cls_id"),
        "CFV_ID": data_js.get("project_args").get("cfv_id"),
        "PRJ_ID": data_js.get("project_args").get("prj_id"),
        "CST_ID": data_js.get("project_args").get("cst_id")
    }
    project_args_obj = {
        "MLT_ID": data_js.get("project_args").get("mlt_id"),
        "CLF_ID": data_js.get("project_args").get("clf_id"),
        "CLS_ID": data_js.get("project_args").get("cls_id"),
        "CFV_ID": data_js.get("project_args").get("cfv_id"),
        "PRJ_ID": data_js.get("project_args").get("prj_id"),
        "INCLF_ID": data_js.get("project_args").get("inclf_id"),
        "AOBJ_ID": data_js.get("project_args").get("aobj_id"),
        "CST_ID": data_js.get("project_args").get("cst_id")
    }
    temp_dict = {}
    temp_dict["catalog"] = []
    path_file = settings.BASE_DIR + "/upload/ns_" + "_" + str(datetime.now().strftime("%Y-_%m-%d-%H_%M_%S")) + ".xlsx"
    writer = pd.ExcelWriter(path_file)

    df_cls = fill_dataframe(sql_path, 'cls_for_excel.sql', con, project_args)
    df_cls_sheet1 = df_cls[["CLV_LEV", "Класс", "Шаблон", "ЕИ", "ISLEAF", "NAME30"]]
    df_cls_sheet1.to_excel(writer, "Классификация", index=False)
    df_cls = df_cls.loc[df_cls["ISLEAF"] == 1]
    for index, row in df_cls.iterrows():
        project_args_obj["CLS_ID"] = row["CLS_ID"]
        df_vsn = fill_dataframe(
            sql_path,
            'vsn_for_excel.sql',
            con,
            project_args_obj,
            [[':DVSFIELDS:', row["LISTFNAME"]]]
        )
        df_vsn = df_vsn.drop_duplicates()
        df_vsn.to_excel(writer, row["NAME30"], index=False)
    writer.save()
    result["path_file"] = path_file
    result["name"] = str("NS_" + str(datetime.now().strftime("%Y-_%m-%d-%H_%M_%S")))
    return result


def fill_excel_for_ns_template(data_js):
    """ По данным сформируем excel файл"""
    os.environ["NLS_LANG"] = '.AL32UTF8'
    sql_path = settings.BASE_DIR + "/supp/sqlscript/66/"
    con = cx_Oracle.connect('CS_ART/CS_ART@192.168.54.17:1521/ORA5.INCON.LO')
    result = {}
    project_args = {
        "MLT_ID": data_js.get("project_args").get("mlt_id"),
        "CLF_ID": data_js.get("project_args").get("clf_id"),
        "CLS_ID": data_js.get("project_args").get("cls_id"),
        "CFV_ID": data_js.get("project_args").get("cfv_id"),
        "PRJ_ID": data_js.get("project_args").get("prj_id"),
        "CST_ID": data_js.get("project_args").get("cst_id")
    }
    project_args_obj = {
        "MLT_ID": data_js.get("project_args").get("mlt_id"),
        "CLF_ID": data_js.get("project_args").get("clf_id"),
        "CLS_ID": data_js.get("project_args").get("cls_id"),
        "CFV_ID": data_js.get("project_args").get("cfv_id"),
        "PRJ_ID": data_js.get("project_args").get("prj_id"),
        "INCLF_ID": data_js.get("project_args").get("inclf_id"),
        "AOBJ_ID": data_js.get("project_args").get("aobj_id"),
        "CST_ID": data_js.get("project_args").get("cst_id")
    }
    # Клиентские системы строкой
    csts = data_js.get("project_args").get("csts")
    temp_dict = {}
    temp_dict["catalog"] = []
    path_file = settings.BASE_DIR + "/upload/ns_" + "_" + str(datetime.now().strftime("%Y-_%m-%d-%H_%M_%S")) + ".xlsx"
    cnt_obj = 0
    writer = pd.ExcelWriter(path_file)

    df_cls = fill_dataframe(sql_path, 'cls_for_excel_only_with_obj.sql', con, project_args, [[':CSTS:', csts]])
    df_cls_sheet1 = df_cls[["CLV_LEV", "Класс", "Шаблон", "ЕИ", "ISLEAF", "NAME30"]]
    df_cls_sheet1.to_excel(writer, "Классификация", index=False)
    df_cls = df_cls.loc[df_cls["ISLEAF"] == 1]
    for index, row in df_cls.iterrows():
        project_args_obj["CLS_ID"] = row["CLS_ID"]
        df_vsn = fill_dataframe(
            sql_path,
            'vsn_for_excel_only_with_obj.sql',
            con,
            project_args_obj,
            [[':DVSFIELDS:', row["LISTFNAME"]], [':CSTS:', csts]]
        )
        mapping = mapping_sdv(row["MAPFNAME"])
        # print(mapping)
        df_vsn = df_vsn.rename(columns=mapping)
        # df_vsn = df_vsn.drop_duplicates()
        # print(str(row["CLS_ID"]) + " " +  )
        cnt_obj += len(df_vsn)
        df_vsn.to_excel(writer, row["NAME30"], index=False)
    writer.save()
    result["path_file"] = path_file
    result["name"] = str("NS_" + str(cnt_obj) + "_" + str(datetime.now().strftime("%Y-_%m-%d-%H_%M_%S")))
    return result


def fill_excel_for_ink(data_js):
    """ По данным сформируем excel файл"""
    os.environ["NLS_LANG"] = '.AL32UTF8'
    sql_path = settings.BASE_DIR + "/supp/sqlscript/67/"
    con = cx_Oracle.connect('CS_ART/CS_ART@192.168.54.17:1521/ORA5.INCON.LO')
    result = {}
    project_args = {
        "MLT_ID": data_js.get("project_args").get("mlt_id"),
        "CLF_ID": data_js.get("project_args").get("clf_id"),
        "CLS_ID": data_js.get("project_args").get("cls_id"),
        "CFV_ID": data_js.get("project_args").get("cfv_id"),
        "PRJ_ID": data_js.get("project_args").get("prj_id"),
        "CST_ID": data_js.get("project_args").get("cst_id")
    }
    project_args_obj = {
        "MLT_ID": data_js.get("project_args").get("mlt_id"),
        "CLF_ID": data_js.get("project_args").get("clf_id"),
        "CLS_ID": data_js.get("project_args").get("cls_id"),
        "CFV_ID": data_js.get("project_args").get("cfv_id"),
        "PRJ_ID": data_js.get("project_args").get("prj_id"),
        "INCLF_ID": data_js.get("project_args").get("inclf_id"),
        "AOBJ_ID": data_js.get("project_args").get("aobj_id"),
        "CST_ID": data_js.get("project_args").get("cst_id")
    }
    temp_dict = {}
    temp_dict["catalog"] = []
    path_file = settings.BASE_DIR + "/upload/ns_" + "_" + str(datetime.now().strftime("%Y-_%m-%d-%H_%M_%S")) + ".xlsx"
    writer = pd.ExcelWriter(path_file)

    df_cls = fill_dataframe(sql_path, 'cls_for_excel.sql', con, project_args)
    # df_cls_sheet1 = df_cls[["CLV_LEV", "Класс", "Шаблон", "ЕИ", "ISLEAF", "NAME30"]]
    map_head_clf = {
        "Шаб.крат.наим.\Норм.крат.наим.": "Шаблон краткого наименования",
        "Шаб.полн.наим.\Норм.полн.наим.": "Шаблон полного наименования"
    }
    df_cls_sheet1 = fill_dataframe(sql_path, 'cls_sheet.sql', con, project_args)
    df_cls_sheet1 = df_cls_sheet1.rename(columns=map_head_clf)
    df_cls_sheet1.to_excel(writer, "Классификация", index=False)

    df_obj_selected = fill_dataframe(sql_path, 'obj_selected.sql', con, project_args_obj)
    df_obj_selected .to_excel(writer, "Выборка", index=False)

    df_cls = df_cls.loc[df_cls["ISLEAF"] == 1]
    for index, row in df_cls.iterrows():
        project_args_obj["CLS_ID"] = row["CLS_ID"]
        project_args_obj["CLF_ID"] = row["CLF_ID"]
        columns_start = [
            'MLT_ID', 'CLF_ID', 'CLS_ID', 'OBJ_ID',
            'Наименование', 'Код НСИ', 'ЕИ', 'Группа', 'Артикул',
            'Описание', 'Класс 1 уровня', 'Класс 2 уровня',
            'Стандарт', 'Шаблон полного наименования', 'Шаблон краткого наименования',
        ]
        columns_end = [
            'ЕИ нормализованная', 'Наименования полное', 'Наименования краткое',
            'Итог нормализации', 'Комментарий ИНКОН',
            'Комментарий заказчика', 'Дубль'
        ]
        mapping = mapping_sdv(row["MAPFNAME"])
        df_vsn = fill_dataframe(
            sql_path,
            'vsn_for_excel.sql',
            con,
            project_args_obj,
            [[':DVSFIELDS:', row["LISTFNAME"]]]
        )
        df_vsn = df_vsn[columns_start + list(mapping) + columns_end]
        df_vsn = df_vsn.drop_duplicates()
        df_vsn = df_vsn.rename(columns=mapping)
        df_vsn.to_excel(writer, row["NAME30"], index=False)
    writer.save()
    result["path_file"] = path_file
    result["name"] = str("INK_" + str(datetime.now().strftime("%Y-_%m-%d-%H_%M_%S")))
    return result


def mapping_sdv(mapping: str):
    list_map = mapping.split('$')
    dict = {}
    for field in list_map:
        ind = field.find('~')
        dict[field[:ind]] = field[ind + 1:]
    return dict


def fill_excel_comment_for_ink(data_js):
    """ По данным сформируем excel файл"""
    DATA_FIELDS = [
        "MLT_ID",
        "CLF_ID",
        "CLS_ID",
        "OBJ_ID",
        "Наименование",
        "Код НСИ", "ЕИ",
        "Группа",
        "Артикул",
        "Описание",
        "Класс 1 уровня",
        "Класс 2 уровня",
        "CODE",
        "Стандарт",
        "Шаблон краткого наименования",
        "Шаблон полного наименования",
        "ЕИ нормализованная",
        "Наименования краткое",
        "Наименования полное",
        "Итог нормализации",
        "Комментарий ИНКОН",
        "Комментарий заказчика",
        "Дубль"
    ]
    DIRECTORY = '/mnt/t'  # - смонтированный для ИНК на 25 машине
    # DIRECTORY = "P:/Проекты/Действующие/ИНК/Рабочая/Замечания от заказчика по нормализации/"
    result = {}
    path_to_file = data_js.get("file")
    print(os.path.join(DIRECTORY, path_to_file))
    print(path_to_file)
    xls = pd.ExcelFile(os.path.join(DIRECTORY, path_to_file))
    sheet_names = xls.sheet_names
    df_all = []
    for sheet in sheet_names[2:]:
        df = pd.read_excel(path_to_file, sheet_name=sheet)
        df['CODE'] = sheet
        df = df[DATA_FIELDS]
        df_all.append(df)
    df_result = pd.concat(df_all, ignore_index=True)
    path_file = settings.BASE_DIR + "/upload/ink_" + "_" + str(datetime.now().strftime("%Y-_%m-%d-%H_%M_%S")) + ".xlsx"
    writer = pd.ExcelWriter(path_file, engine='xlsxwriter')
    df_result.to_excel(writer, "Сводный", index=False)
    workbook = writer.book
    worksheet = writer.sheets['Сводный']
    header_format = workbook.add_format({
        'bold': True,
        'text_wrap': True,
        'valign': 'top',
        'fg_color': '#D7E4BC',
        'border': 1
    })
    header_format_warning = workbook.add_format({
        'bold': True,
        'text_wrap': True,
        'valign': 'top',
        'fg_color': '#fffb66',
        'border': 1
    })
    for col_num, value in enumerate(df_result.columns.values):
        if value == 'Комментарий заказчика':
            worksheet.write(0, col_num, value, header_format_warning)
        else:
            worksheet.write(0, col_num, value, header_format)
    writer.save()
    result["path_file"] = str(path_file)
    result["name"] = str("INK_" + str(datetime.now().strftime("%Y-_%m-%d-%H_%M_%S")))
    return result
