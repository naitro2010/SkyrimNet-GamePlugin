from typing import TypedDict
import glob
import logging

import streamlit as st

logger = logging.getLogger(__name__)

class menu_entry(TypedDict):
    path: str
    description: str

@st.cache_data(ttl=1)
def generate_sidebar():
    '''
    Generates the menu list based off the files in the 
    pages dir. The page name format is

    'pages/{order}_{description}.py'

    order: int determinig the order of the menu items
    description: str describing the page

    pages without an number_description.py will be ignored
    '''
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
