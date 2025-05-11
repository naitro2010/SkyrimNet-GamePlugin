import streamlit as st
from datatypes import File_Names, webui_strings as ui_str
from dependencies import backup_file, restore_backup

def prompt_editor(file_name: File_Names) -> None:
    with st.expander(label=file_name.name_nice):

        loaded_text = ""
        try:
            with open(file_name.full_path, "r") as f:
                loaded_text = f.read()
        except Exception as e:
            st.echo(ui_str.error_file_load.format(str(e)))
            return
        
        result = backup_file(file_name.full_path)
        if  result != "":
            st.error(ui_str.error_file_save_backup.format(result))
            return
        
        modified_text = st.text_area(
            label=file_name.name_nice, 
            value=loaded_text, 
            height=250,
            label_visibility="collapsed",
            key=file_name.full_path+"text")

        c_save, c_revert = st.columns(2) #buttons side by side
        with c_save:
            save_button = st.button(
                ui_str.button_save, 
                key=file_name.full_path+"save", 
                use_container_width=True)
        with c_revert:
            revert_button = st.button(
                ui_str.button_revert, 
                key=file_name.full_path+"revert",
                use_container_width=True)
            
        if not (save_button or revert_button):
            return
        
        if revert_button:
            # copy the .bak file to the original file
            result = restore_backup(file_name.full_path)
            if  result != "":
                st.error(ui_str.error_file_restore_backup.format(result))
                return
            st.rerun()

        try:
            with open(file_name.full_path, "w") as f:
                f.write(modified_text)
        except Exception as e:
            st.error(ui_str.error_file_save.format(str(e)))
            return
        #has to be rerun after saving
        st.rerun()
