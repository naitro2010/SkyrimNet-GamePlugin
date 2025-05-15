import streamlit as st
import streamlit_clickable_list

from forms import NPC_Profile_Form, Clickable_List_Form
from scripts import generate_sidebar
from dependencies import get_dirfiles_sorted_mru_alpha
from datatypes import gnice_name, webui_strings as ui_str

def main():
    generate_sidebar()
    profiles_list = get_dirfiles_sorted_mru_alpha(ui_str.path_characters)
    profiles_dict = {}

    for profile in profiles_list:
        profiles_dict[gnice_name(profile)] = profile

    col_sel, col_edit = st.columns([1, 3])
    col_sel.write("**NPC Profiles**")
        
    with col_sel:
        clickable_list = Clickable_List_Form(profiles_dict.keys())
    with col_edit:
        if clickable_list.selection != "":
            NPC_Profile_Form(ui_str.path_characters + "/" + profiles_dict[clickable_list.selection])

if __name__ == "__main__":
    main()