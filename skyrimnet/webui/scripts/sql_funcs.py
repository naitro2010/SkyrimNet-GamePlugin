import glob, os

import streamlit as st
from sqlalchemy import text
import pandas as pd
from bidict import bidict

from datatypes import webui_strings as ui_str
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

@st.cache_data(ttl=60)
def load_db_list() -> str:
    """loads the db list into the streamlit session state. session state allows different pages to share data"""
    db_files = []
    for db_dir in glob.iglob(f"{ui_str.path_dbs}/*.db"):
        if not os.path.isfile(db_dir):
            continue
        db_files.append((os.path.getmtime(db_dir), db_dir))
    if not db_files:
        return ui_str.err_no_dbs
    db_files = sorted(db_files, key=lambda x: x[0], reverse=True)
    db_files:list[str]  = [x[1] for x in db_files]
    dbs_dict:bidict[str, str] = bidict()
    for filename in db_files:
        if filename.rfind("_") == -1:
            dbs_dict[filename[filename.rfind("/")+1:-3]] = filename
        else:
            dbs_dict[filename[filename.rfind("/")+1:filename.rfind("_")].capitalize()] = filename
    st.session_state["db_dict"] = dbs_dict
    if "db_current" not in st.session_state.keys():
        st.session_state["db_current"] = list(st.session_state["db_dict"].values())[0]
    