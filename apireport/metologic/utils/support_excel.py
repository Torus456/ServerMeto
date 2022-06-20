import os
from datetime import datetime

import cx_Oracle
import pandas as pd
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
        print(row["CLS_ID"])
        print(row["LISTFNAME"])
        df_vsn = fill_dataframe(sql_path, 'vsn_for_excel.sql', con, project_args_obj, [[':DVSFIELDS:', row["LISTFNAME"]]])
        print(df_vsn.head())
        df_vsn = df_vsn.drop_duplicates()
        df_vsn.to_excel(writer, row["NAME30"], index=False)
    writer.save()
    result["path_file"] = path_file
    result["name"] = str("NS_" + str(datetime.now().strftime("%Y-_%m-%d-%H_%M_%S")))
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
    print(project_args)
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
            'Стандарт', 'Шаблон краткого наименования', 'Шаблон полного наименования',
            'ЕИ нормализованная', 'Наименования краткое', 'Наименования полное'
        ]
        columns_end = [
            'Итог нормализации', 'Комментарий ИНКОН',
            'Комментарий заказчика', 'Дубль'
        ]
        
        # print(row["LISTFNAME"])
        mapping = mapping_sdv(row["MAPFNAME"])
        
        df_vsn = fill_dataframe(sql_path, 'vsn_for_excel.sql', con, project_args_obj, [[':DVSFIELDS:', row["LISTFNAME"]]])
        # print(mapping.keys())
        # print(columns_start + list(mapping) + columns_end)
        df_vsn = df_vsn[columns_start + list(mapping) + columns_end]
        df_vsn = df_vsn.drop_duplicates()
        df_vsn = df_vsn.rename(columns=mapping)
        # print([*df_vsn])
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
