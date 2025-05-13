from typing import TypedDict
import glob
import logging
from bidict import bidict
import streamlit as st

from datatypes import webui_strings
from dependencies import load_db_list

logger = logging.getLogger(__name__)

class menu_entry(TypedDict):
    path: str
    description: str

def generate_sidebar():
    '''
    Generates the menu list based off the files in the 
    pages dir. The page name format is

    'pages/{order}_{description}.py'

    order: int determinig the order of the menu items
    description: str describing the page

    pages without an number_description.py will be ignored
    '''

    st.sidebar.subheader(webui_strings.app_title, anchor=False)

    results = ""
    if "db_dict" not in st.session_state:
        results = load_db_list()

    if results:
        st.sidebar.write(results)
    else:
        db_dict:bidict = st.session_state["db_dict"]
        db_cur:str = st.session_state["db_current"]
        db_list:list[str] = list(db_dict.keys())

        db_sel = st.sidebar.selectbox(
            label="Select PC:", 
            options=db_dict.keys(),
            index=db_list.index(db_dict.inv[db_cur]),
            key="db_current_sel")
        
        if db_sel != db_cur:
            st.session_state["db_current"] = db_dict[db_sel]
    st.sidebar.write("---")
    gen_sidebar_menu()

@st.cache_data(ttl=1)
def gen_sidebar_menu():
    menu_items = {}
    pages_list:list[str] = glob.glob('pages/*.py')

    if not len(pages_list):
        st.sidebar.write("No Pages Found")
        return

    for page in pages_list:

        if page.find('_') == -1: #ignore pages wihtout a _
            continue

        page_items = page[6:-3].split("_")
        if not page_items[0].isnumeric(): #ignore pages without an order number
            continue
        
        menu_items.update({int(page_items[0]):menu_entry(path=page, description=" ".join(page_items[1:]))})

    for item_key in sorted(menu_items.keys()):
        menu_item: menu_entry = menu_items[item_key]
        st.sidebar.page_link(page=menu_item["path"], label=menu_item["description"])
