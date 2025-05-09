import streamlit as st
from sqlalchemy import text
import pandas as pd

"""
Streamlit is a little funky with DBs/ML models needing to 
share the resuorce.

The db connection is mutable so results cant be cached, but
the params of the call to get the tables can be.
"""

@st.cache_resource
def get_sql_connection():
    conn = st.connection('SkyrimNet', type="sql")
    return conn

@st.cache_data(ttl=60)
def get_table_names() -> list[str]:
    conn = get_sql_connection()
    with conn.session as c:
        query = text("SELECT name FROM sqlite_master WHERE type='table'")
        tables = c.execute(query)
    return [x[0] for x in tables]

#@st.cache_data(ttl=60)
def get_table_data(table: str):
    # create a function to return a copy of the table data 
    conn = get_sql_connection()
    with conn.session as c:
        query = text(f"SELECT * FROM {table}")
        results = c.execute(query)
        df = pd.DataFrame(results, columns=results.keys())
    return df
