import streamlit as st
from datatypes import webui_strings as ui_str

from scripts import generate_sidebar

def main():
    generate_sidebar()
    st.subheader(ui_str.not_imp, anchor=False)
    tab_stt, tab_llm, tab_tts = st.tabs(ui_str.services)

if __name__ == "__main__":
    main()