import streamlit as st

from scripts import generate_sidebar
from datatypes import webui_strings as ui_str
from dependencies import get_dirfiles_sorted_mru_alpha

from bidict import bidict
import datetime

def main():
    generate_sidebar()

if __name__ == "__main__":
    main()