from bidict import bidict
import streamlit as st
import streamlit_clickable_list

from scripts import generate_sidebar
from dependencies import get_dirfiles_sorted_mru_alpha
from datatypes import gnice_name, webui_strings as ui_str
from forms import NPC_Profile_Form

def main():
    generate_sidebar()
    st.subheader("Player Profile", anchor=False)
    with open(ui_str.path_player, "r") as f:
        player_profile = f.read()
    
    #NPC_Profile_Form(ui_str.path_player)

if __name__ == "__main__":
    main()