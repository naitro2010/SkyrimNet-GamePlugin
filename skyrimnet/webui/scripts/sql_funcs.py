import glob, os
import datetime

import streamlit as st
from sqlalchemy import text
import pandas as pd
from bidict import bidict

from datatypes import webui_strings as ui_str
from dependencies import get_dirfiles_sorted_mru_alpha
"""
Streamlit is a little funky with DBs/ML models needing to 
share the resuorce.

The db connection is mutable so results cant be cached, but
the params of the call to get the tables can be.
"""

@st.cache_resource
def get_sql_connection(db_file: str):
    conn = st.connection("sql", url= f'sqlite:///{db_file}')
    return conn

#@st.cache_data(ttl=60)
def get_table_names() -> list[str]:
    conn = get_sql_connection(st.session_state["db_current"])
    with conn.session as c:
        query = text("SELECT name FROM sqlite_master WHERE type='table'")
        tables = c.execute(query)
    return [x[0] for x in tables]

#@st.cache_data(ttl=60)
def get_table_data(table: str):
    # create a function to return a copy of the table data 
    conn = get_sql_connection(st.session_state["db_current"])
    with conn.session as c:
        query = text(f"SELECT * FROM {table}")
        results = c.execute(query)
        df = pd.DataFrame(results, columns=results.keys())
    return df

def gen_db_dict() -> dict[str, str]:
    """generates a dict of human-readible timestamp (or just the filename) to filepath"""
    file_list: list[str] = get_dirfiles_sorted_mru_alpha(path=ui_str.path_dbs, ext=".db")
    output_dict = bidict()
    for filename in file_list:
        name = filename[filename.rfind("/")+1:-3]
        if (name.find("-") == -1) or (name.find("-") == name.rfind("-")):
            output_dict[name] = filename
            continue
        name_time_str = name[name.find("-")+1:name.rfind("-")]
        if not name_time_str.isdigit():
            output_dict[name] = filename
            continue
        # todo: Possible to extract name from the profile and use that
        timestamp = int(name_time_str[:-3])
        dt_object = datetime.datetime.fromtimestamp(timestamp)
        output_dict[dt_object.strftime("%Y-%m-%d %H:%M:%S")] = f"{ui_str.path_dbs}/{filename}"
    return output_dict
    
def load_db_list() -> bool:
    """loads the db dict into the streamlit session state, returns false if no dbs.
    session state allows different pages to share data"""
    db_dict = gen_db_dict()
    if not db_dict:
        return False
    st.session_state["db_dict"] = db_dict
    if "db_current" not in st.session_state.keys():
        st.session_state["db_current"] = list(st.session_state["db_dict"].values())[0]
    return True

