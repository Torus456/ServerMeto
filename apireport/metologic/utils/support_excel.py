import cx_Oracle
import json
import os
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
