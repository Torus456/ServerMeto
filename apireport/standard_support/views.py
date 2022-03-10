import requests
import pandas as pd
import re
import cx_Oracle
import json

import urllib.request
import urllib

from django.shortcuts import render
from django.db import connection
from bs4 import BeautifulSoup
from urllib.parse import quote
from supp.views import sendmail
from django.http import JsonResponse


def parse_gosts(request):
    '''
    Принимаем данные для формирования методологии
    '''
    request_data = json.loads(request.body)
    print("Начинаем")
    status = 200
    result = {}
    result["message"] = "Привет"
    df = get_dataframe_standarts_for_check()
    con = cx_Oracle.connect('CS_ART', 'CS_ART', '192.168.54.17:1521/ORA5.INCON.LO')
    try:
        parse_standarts_all_info(con, df)
    except (ConnectionError, ConnectionRefusedError):
        parse_standarts_all_info(con, df)
    sendmail(request_data.get("email"), "Проверка стандарта", "Проверка по выбранным данным завершено", None, None)
    return JsonResponse(result, status=status)


def get_dataframe_standarts_for_check():
    """
    Выбираем данные для дельнейшей обработке
    """
    SELECT_GOSTS = """select a.mlt_id, a.sgn_id, a.vsn_id, a.valchar
                    from cs_art_load.gosts_in a
                    where a.status is null
                      and a.valchar is not null
                      and a.valchar like 'ГОСТ%'
                      and not exists (select 1
                                      from cs_art_load.gosts b
                                      where a.valchar = b.valchar)"""
    return pd.read_sql_query(SELECT_GOSTS, connection)


def save_in_db(cur, data):
    """
    Сохраняем данные с проверенными данными в таблицу gosts
    """
    sql_insert = """begin 
                    ap_standard.insert_into_gosts(:p_mlt_id,
                                                  :p_sgn_id,
                                                  :p_vsn_id,
                                                  :p_valchar,
                                                  :p_valyear,
                                                  :p_descr,
                                                  :p_val);
                    end;"""
    val = (data["MLT_ID"],
           data["SGN_ID"],
           data["VSN_ID"],
           data["VALCHAR"],
           data["GOST"],
           data["NAME"],
           data["STATUS"])
    cur.execute(sql_insert, val)


def update_db(cur, data):
    """
    Изменяем статус проверенного стандарта
    """
    sql_insert = """begin 
                    ap_standard.update_gost(:p_mlt_id,
                                            :p_sgn_id,
                                            :p_vsn_id);
                    end;"""
    val = (data["MLT_ID"],
           data["SGN_ID"],
           data["VSN_ID"])
    cur.execute(sql_insert, val)


def parse_standarts(connection, df):
    """
    По полученнным данным с сайта standards.ru парсим актуальный статус
    """
    URL = 'https://www.standards.ru/doc.aspx?catalogid=gost&search=8394'
    HEADERS = {'User-Agent': 'Mozilla/5.0 (Windows NT 6.1; WOW64; rv:50.0) Gecko/20100101 Firefox/50.0'}
    response = requests.get(URL, headers=HEADERS)
    soup = BeautifulSoup(response.text, 'lxml')
    pattern = re.compile('[^а-яА-Я]*')
    cur = connection.cursor()
    for index, row in df.iterrows():
        print(row["VALCHAR"])
        url = 'https://www.standards.ru/doc.aspx?catalogid=gost&search=' + urllib.parse.quote_plus(row["VALCHAR"], encoding='cp1251')
        headers = {'User-Agent': 'Mozilla/5.0 (Windows NT 6.1; WOW64; rv:50.0) Gecko/20100101 Firefox/50.0'}
        headers['Content-Type'] = 'text/html; charset=UTF-8'
        response = requests.get(url, headers=HEADERS)
        soup = BeautifulSoup(response.text, 'lxml')
        table_status = soup.find_all('table', class_='typetable')
        data = {}
        try:
            data["MLT_ID"] = row["MLT_ID"]
            data["SGN_ID"] = row["SGN_ID"]
            data["VSN_ID"] = row["VSN_ID"]
            data["VALCHAR"] = row["VALCHAR"]
            data["NAME"] = table_status[0].find_all('div')[2].string
            data["STATUS"] = re.sub(pattern, '', table_status[0].find_all('td', class_="tx12")[1].string)
            data["GOST"] = table_status[0].find_all('div')[1].find_all('a')[0].string
        except:
            data["MLT_ID"] = row["MLT_ID"]
            data["SGN_ID"] = row["SGN_ID"]
            data["VSN_ID"] = row["VSN_ID"]
            data["VALCHAR"] = row["VALCHAR"]
            data["NAME"] = "Not found"
            data["STATUS"] = "Not found"
            data["GOST"] = "Not found"
        print(data)
        save_in_db(cur, data)
        connection.commit()
    cur.close()


def parse_standarts_all_info(connection, df):
    """
    По полученнным данным с сайта standards.ru парсим актуальный статус
    """
    URL = 'https://www.standards.ru/doc.aspx?catalogid=gost&search=8394'
    HEADERS = {'User-Agent': 'Mozilla/5.0 (Windows NT 6.1; WOW64; rv:50.0) Gecko/20100101 Firefox/50.0'}
    response = requests.get(URL, headers=HEADERS)
    soup = BeautifulSoup(response.text, 'lxml')
    pattern = re.compile('[^а-яА-Я]*')
    cur = connection.cursor()
    for index, row in df.iterrows():
        print(row["VALCHAR"])
        url = 'https://www.standards.ru/doc.aspx?catalogid=gost&search=' + urllib.parse.quote_plus(row["VALCHAR"], encoding='cp1251')
        headers = {'User-Agent': 'Mozilla/5.0 (Windows NT 6.1; WOW64; rv:50.0) Gecko/20100101 Firefox/50.0'}
        headers['Content-Type'] = 'text/html; charset=UTF-8'
        response = requests.get(url, headers=HEADERS)
        soup = BeautifulSoup(response.text, 'lxml')
        table_status = soup.find_all('table', class_='typetable')
        if table_status:
            for i in range(0, len(table_status[0].find_all('div')) // 3):
                value = table_status[0].find_all('div')[i * 3 + 1].find_all('a')[0].string
                data = {}
                print(value + " | " + row["VALCHAR"])
                print(re.match(r'' + row["VALCHAR"] + '[^0-9]', value))
                if re.match(r'' + row["VALCHAR"] + '[^0-9]', value):
                    try:
                        data["MLT_ID"] = row["MLT_ID"]
                        data["SGN_ID"] = row["SGN_ID"]
                        data["VSN_ID"] = row["VSN_ID"]
                        data["VALCHAR"] = row["VALCHAR"]
                        data["NAME"] = table_status[0].find_all('div')[i * 3 + 2].string
                        data["STATUS"] = re.sub(pattern,
                                                '',
                                                table_status[0].find_all('td', class_="tx12")[i * 2 + 1].string)
                        data["GOST"] = value# table_status[0].find_all('div')[i * 3 + 1].find_all('a')[0].string
                    except:
                        data["MLT_ID"] = row["MLT_ID"]
                        data["SGN_ID"] = row["SGN_ID"]
                        data["VSN_ID"] = row["VSN_ID"]
                        data["VALCHAR"] = row["VALCHAR"]
                        data["NAME"] = "Не найден"
                        data["STATUS"] = "Не найден"
                        data["GOST"] = "Не найден"
                    save_in_db(cur, data)
        else:
            data = {}
            data["MLT_ID"] = row["MLT_ID"]
            data["SGN_ID"] = row["SGN_ID"]
            data["VSN_ID"] = row["VSN_ID"]
            update_db(cur, data)
        connection.commit()
        response.close
    cur.close()
