import cx_Oracle
import json
import os
from datetime import datetime
from django.conf import settings
from .support_docx import fill_dataframe


def fill_json_for_ns(data_js):
    """ По данным сформируем json файл"""
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

    df_cls = fill_dataframe(sql_path, 'cls_for_doc.sql', con, project_args)
    df_dvs = fill_dataframe(sql_path, 'dvs_for_doc.sql', con, project_args)
    df_vsn = fill_dataframe(sql_path, 'vsn_for_doc.sql', con, project_args_obj)
    df_obj = fill_dataframe(sql_path, 'obj_for_doc.sql', con, project_args_obj)
    df_lst = fill_dataframe(sql_path, 'dict_list.sql', con, project_args)
    temp_dict = {}
    prev_dict = {}
    
    dict_cls = {}
    temp_dict["catalog"] = []
    prev_dict = temp_dict["catalog"]
    prev_name = "catalog"
    lvl = 0
    plvl = 0
    for index, row in df_cls.iterrows():
        newdict = {}
        newdict["name"] = row["NAME"]
        lvl = row["CLV_LEV"]
        dict_cls[row["NAME"]] = prev_dict
        if (row["ISLEAF"] != 1):
            newdict["children"] = []
        else:
            newdict["information_models"] = []
            newdict["information_models"].append(get_data_cls(row, df_dvs, df_obj, df_vsn, df_lst))

        # Если уровень 1 нужно его на первый уровень и забросить
        # if lvl == 1:
        #     prev_dict = temp_dict["catalog"]
        # print(df_cls[["NAME", "CLV_LEV"]])
        # print(row["NAME"] + " " + str(lvl) + " " + str(plvl))
        # if (lvl < plvl):
        #     print(row["NAME"] + " " + str(lvl) + " " + str(plvl))
        if (lvl >= plvl and row["ISLEAF"] != 1):
            if lvl != plvl:
                prev_name = row["NAME"]
                prev_dict.append(newdict)
                prev_dict = newdict["children"]
            else:
                prev_dict.append(newdict)
        elif (lvl < plvl):
            prev_dict = dict_cls[prev_name]
            prev_dict.append(newdict)
            prev_dict = newdict["children"]
        else:
            prev_dict.append(newdict)
        plvl = lvl
    # Для получения плоской таблицы классов
    # for index, row in df_cls.iterrows():
    #     newdict = {}
    #     newdict["name"] = row["NAME"]
    #     if (row["ISLEAF"] != 1):
    #         newdict["children"] = []
    #     else:
    #         newdict["information_models"] = []

    #     temp_dict["cls"].append(newdict)
    # for i, row in enumerate(df_cls.itertuples(), 1):
    #     print(row[6])
        # if (root==0 or root != row.clv_cls_id):
        #     root = row.clv_cls_id
        #     cls["name"] = row.name

    temp_dict["attributes"] = get_data_attribute(df_dvs)
    # temp_dict["directories"] = get_directories(df_lst)
    jstemp = json.dumps(
        temp_dict,
        sort_keys=False,
        indent=4,
        ensure_ascii=False,
        separators=(',', ': ')
    )
    # print(jstemp)
    # print(type(jstemp))
    path_file = settings.BASE_DIR + "/upload/ns_" + "_" + str(datetime.now().strftime("%Y-_%m-%d-%H_%M_%S")) + ".json"
    with open(path_file, "w", encoding="utf-8") as file:
        file.write(jstemp)
        # json.dump(jstemp, file)
    result["path_file"] = path_file
    result["name"] = str("NS_" + str(datetime.now().strftime("%Y-_%m-%d-%H_%M_%S")))
    return result


def get_data_cls(cls, dvs, obj, vsn, lst):
    """ Заполняем информацию по классу в формате словаря"""
    data_cls = {}
    # Тип продукта (Это наименование класса листка)
    data_cls["product_type"] = cls["NAME"]
    # Шаблон составления имени
    data_cls["product_name"] = cls["FNAME"]
    # Шаблон составления кратокго имени
    data_cls["product_short_name"] = cls["SNAME"]
    # Базовые единицы измерения
    data_cls["basic_units"] = cls["UMS_CODE"]
    # Продажные единицы измерения
    data_cls["sales_unints"] = cls["UMS_CODE"]
    # Тут вставка атрибутов
    data_cls["basic_attributes"] = get_attributes(cls, dvs, vsn, 1)
    # Атрибуты поставщика
    data_cls["supplier_attributes"] = get_attributes(cls, dvs, vsn, 0, True)
    # Еще какие-то атрибуты
    data_cls["auxiliary_attributes"] = get_attributes(cls, dvs, vsn, 0, False)
    # Продуктовые карточки
    data_cls["product_reference_cards"] = get_products(cls, obj, vsn)
    return data_cls


def get_attributes(cls, dvs, vsn, type, isSupplier=False):
    """Возвращаем информацию по ОД в формате словаря"""
    attributes = []
    df_attributes = dvs.loc[(dvs["CLS_ID"] == cls["CLS_ID"]) & (dvs["MND"] == type)]
    if isSupplier:
        df_attributes = df_attributes.loc[df_attributes["SGN_ID"] == 8299]
    else:
        df_attributes = df_attributes.loc[df_attributes["SGN_ID"] != 8299]
    for index, row in df_attributes.iterrows():
        sdv = {}
        # Проектное наименование ОД
        sdv["name"] = row["NAME"]
        # Тап данных атрибута
        sdv["type"] = row["VALTYPE"]
        # Обязательность к заполению
        sdv["required"] = row["MND"] == 1
        sdv["available_values"] = []
        # Доступные значения для атрибута
        if row["MND"] == 0:
            df_lst = vsn.loc[(vsn["CLS_ID"] == cls["CLS_ID"]) & (vsn["DVS_ID"] == row["DVS_ID"])]
            sdv["available_values"] = df_lst["VALUE"].drop_duplicates().tolist()
        attributes.append(sdv)
    return attributes


def get_products(cls, obj, vsn):
    """Данные продуктовых карточек"""
    products = []
    df_obj_cls = obj.loc[obj["CLS_ID"] == cls["CLS_ID"]]
    for index, row in df_obj_cls.iterrows():
        product = {}
        product["name"] = row["FNAME"]
        product["short_name"] = row["SNAME"]
        # Описание ЭКТ
        product["description"] = ""
        # базовые атрибуты
        product["basic_attributes"] = get_data_product(cls, row, vsn)
        # вспомогательные
        product["auxiliary_attributes"] = []
        products.append(product)
    return products


def get_data_product(cls, obj, vsn):
    """Данные по продукту"""
    vals = []
    df_vsn = vsn.loc[(vsn["CLS_ID"] == cls["CLS_ID"]) & (vsn["OBJ_ID"] == obj["OBJ_ID"]) & (vsn["MND"] == 1)]
    for index, row in df_vsn.iterrows():
        val = {}
        val["name"] = row["SDVNAME"]
        val["value"] = row["VALUE"]
        val["short_value"] = "" if row["SYMSGN"] is None else row["SYMSGN"]
        vals.append(val)
    return vals


def get_data_attribute(df_dvs):
    """Получаем данные по атрибутам"""
    arrtibutes = []
    df_attribute = df_dvs[["NAME", "VALTYPE"]].drop_duplicates()
    for index, row in df_attribute.iterrows():
        arrtibute = {}
        arrtibute["name"] = row["NAME"]
        arrtibute["type"] = row["VALTYPE"]
        arrtibute["directory_name"] = row["NAME"] if row["VALTYPE"] == 'Список' else ""
        arrtibutes.append(arrtibute)
    return arrtibutes


def get_directories(df_lst):
    """Получаем словари"""
    directories = []
    df_dir = df_lst["OD"].drop_duplicates()
    for index, row in df_dir.iteritems():
        dir = {}
        dir["name"] = row
        dir["values"] = df_lst.loc[df_lst["OD"] == row]["VALCHAR"].tolist()
        directories.append(dir)
    return directories
