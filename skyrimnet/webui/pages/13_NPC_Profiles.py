import streamlit as st
import streamlit_clickable_list

from forms import NPC_Profile_Form
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
    col_sel.subheader("NPC Profiles", anchor=False)

    def on_click(name):
        st.session_state["list_selection"] = name
        
    with col_sel:
        search_text = st.text_input(label="Filter by typing first couple of characters of the name.")
        if search_text:
            clicklist = [x for x in profiles_dict.keys() if search_text.lower() in x.lower()]
            clicklist = clicklist[:29]
        else:
            clicklist = list(profiles_dict.keys())[:29]
        streamlit_clickable_list.clickable_list(clicklist, on_click=on_click, key="player_profile")
    with col_edit:
        if "list_selection" in st.session_state:
            if st.session_state["list_selection"] != None:
                NPC_Profile_Form(ui_str.path_characters + "/" + profiles_dict[st.session_state["list_selection"]])

if __name__ == "__main__":
    main()