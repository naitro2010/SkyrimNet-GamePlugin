import streamlit as st

from scripts import generate_sidebar, get_table_names, get_table_data

def main():
    generate_sidebar()
    tables = get_table_names()
    table_sel = st.radio("Select a Table", tables)
    if table_sel:
        df = get_table_data(table_sel)
        st.write(df)

if __name__ == "__main__":
    main()