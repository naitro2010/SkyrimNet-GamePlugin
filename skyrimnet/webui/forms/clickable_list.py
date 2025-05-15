from datatypes import webui_strings as ui_str
import streamlit as st
import streamlit_clickable_list

class Clickable_List_Form:
    """ Simple abstraction interface 
    - allows the clickable_list object to have a selection str for its output
    - allows for filtering the list based on text input
    - limits the amount of items to display as set by ui_str.filter_num"""
    def __init__(self, items: list[str]):
        if not items:
            return
        self.selection = ""
        items = list(items)
    
        if len(items) <= ui_str.filter_num:
            clicklist = items
        else:
            search_text = st.text_input(label=ui_str.filter_inst)
            if search_text:
                clicklist = [x for x in items if search_text.lower() in x.lower()]
                clicklist = clicklist[:ui_str.filter_num]
            else:
                clicklist = items[:ui_str.filter_num]
        streamlit_clickable_list.clickable_list(clicklist, on_click=self.on_click, key=f"clf{items[0]}")

    def on_click(self, selection):
        self.selection = selection
        
