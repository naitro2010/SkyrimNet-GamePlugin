import glob, logging, os

import streamlit as st

from datatypes import webui_strings as ui_str

def get_sub_dir(dirpath: str) -> str:
    removed_prefix =  dirpath[len(ui_str.path_prompts)+1:]
    sub_dir, file_name = os.path.split(removed_prefix)
    return sub_dir, file_name

class File_Names():
    def __init__(self, full_path: str):
        self.full_path = full_path
        _, self.name_nice = get_sub_dir(dirpath=full_path)
        self.name_nice = self.name_nice[:-7]

class Prompt_Editor_Tabs():
    def __init__(self, title: str):
        self.title: str = title
        self.files: list[File_Names] = []
        self.tab_context: any = None

def prompt_editor(file_name: File_Names) -> None:
    with st.expander(label=file_name.name_nice):
        loaded_text = ""
        try:
            with open(file_name.full_path, "r") as f:
                loaded_text = f.read()
        except Exception as e:
            st.echo("Failed to load file: "+str(e))
        modified_text = st.text_area("", value=loaded_text, height=250, key=file_name.full_path+"text")
        if not st.button("Save", key=file_name.full_path+"save"):
            return
        
        try:
            with open(file_name.full_path, "w") as f:
                f.write(modified_text)
        except Exception as e:
            st.echo("Failed to save file: "+str(e))
        st.rerun()

def generate_prompt_editors():
    tabs_dict:dict[str, Prompt_Editor_Tabs] = {}

    for full_path in glob.iglob(f'{ui_str.path_prompts}/**', recursive=True):

        if not os.path.isfile(full_path):
            continue
        if not full_path.endswith(".prompt"):
            continue

        sub_dir, _ = get_sub_dir(dirpath=full_path)
        if not sub_dir:
            if ".root" not in tabs_dict.keys():
                tabs_dict[".root"] = Prompt_Editor_Tabs(".root")
            tabs_dict[".root"].files.append(File_Names(full_path=full_path))
        else:
            if sub_dir not in tabs_dict.keys():
                tabs_dict[sub_dir] = Prompt_Editor_Tabs(title=sub_dir)
            tabs_dict[sub_dir].files.append(File_Names(full_path=full_path))

    #create tabs and associate them with the dict    
    sorted_tabs_list = sorted(tabs_dict.keys())
    _tabs = st.tabs(sorted_tabs_list)
    for tl_item, tl_value in enumerate(sorted_tabs_list):
        tabs_dict[tl_value].tab_context = _tabs[tl_item]

    for key, values in tabs_dict.items():
        with values.tab_context:
            for item in values.files:
                prompt_editor(item)
