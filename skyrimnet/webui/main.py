import os, logging
import streamlit as st

from scripts import generate_sidebar
from dependencies import load_db_list

logger = logging.getLogger(__name__)

def main():
    load_db_list()
    generate_sidebar()

    pass

if __name__ == "__main__": 
    main()