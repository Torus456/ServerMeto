import os
import pandas as pd


def fill_dataframe(path, query, connect, project_args):
    """
    Заполнить датафрейм на основе запроса
    """
    SQL_QUERY = ""
    with open(os.path.join(path, query), 'r', encoding="utf-8") as file:
        SQL_QUERY = file.read().replace('\n', ' ')
    df = pd.read_sql(SQL_QUERY, con=connect, params=project_args)
    result = df.where((pd.notnull(df)), None)
    return result
