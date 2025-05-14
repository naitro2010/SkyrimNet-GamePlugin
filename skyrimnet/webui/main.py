import os, logging
import streamlit as st

from scripts import generate_sidebar
from dependencies import load_db_list
from datatypes import webui_strings as ui_str
from forms import NPC_Profile_Form

logger = logging.getLogger(__name__)

def main():
    load_db_list()
    generate_sidebar()
    
    pass

if __name__ == "__main__": 
    main()