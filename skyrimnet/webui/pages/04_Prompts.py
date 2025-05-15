import streamlit as st

from scripts import generate_sidebar, generate_prompt_editors

def main():
    generate_sidebar()
    st.write("**Prompts**")
    generate_prompt_editors()

if __name__ == "__main__":
    main()