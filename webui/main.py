import os, logging
import streamlit as st

from scripts import generate_sidebar

logger = logging.getLogger(__name__)

def main():
    generate_sidebar()
    pass

if __name__ == "__main__": 
    main()