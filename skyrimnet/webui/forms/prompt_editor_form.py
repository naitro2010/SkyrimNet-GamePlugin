import streamlit as st
from datatypes import webui_strings as ui_str
from dependencies import backup_file, restore_backup

def prompt_editor(name_nice: str, filename: str) -> None:
    loaded_text = ""
    try:
        with open(filename, "r") as f:
            loaded_text = f.read()
    except Exception as e:
        st.echo(ui_str.err_file_load.format(file=filename, error=str(e)))
        return
    
    result = backup_file(filename)
    if  result != "":
        st.error(ui_str.err_file_save_backup.format(result))
        return
    
    modified_text = st.text_area(
        label=name_nice, 
        value=loaded_text, 
        height=750,
        label_visibility="collapsed",
        key=filename+"text")

    c_save, c_revert = st.columns(2) #buttons side by side
    with c_save:
        save_button = st.button(
            ui_str.button_save, 
            key=filename+"save", 
            use_container_width=True)
    with c_revert:
        revert_button = st.button(
            ui_str.button_revert, 
            key=filename+"revert",
            use_container_width=True)
        
    if not (save_button or revert_button):
        return
    
    if revert_button:
        # copy the .bak file to the original file
        result = restore_backup(filename)
        if  result != "":
            st.error(ui_str.err_file_restore_backup.format(result))
            return
        st.rerun()

    try:
        with open(filename, "w") as f:
            f.write(modified_text)
    except Exception as e:
        st.error(ui_str.err_file_save.format(str(e)))
        return
    #has to be rerun after saving
    st.rerun()
