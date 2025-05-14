import glob, logging, os

import streamlit as st

from datatypes import File_Names, webui_strings as ui_str
from forms import Prompt_Editor_Form

class Prompt_Editor_Tabs():
    def __init__(self, title: str):
        self.title: str = title
        self.files: list[File_Names] = []
        self.tab_context: any = None

def generate_prompt_editors():
    tabs_dict:dict[str, Prompt_Editor_Tabs] = {}

    for full_path in glob.iglob(f'{ui_str.path_prompts}/**', recursive=True):

        if not os.path.isfile(full_path):
            continue
        if not full_path.endswith(".prompt"):
            continue

        prompt_file = full_path[len(ui_str.path_prompts)+1:-7]

        if prompt_file.rfind("/") == -1:
            if ".root" not in tabs_dict.keys():
                tabs_dict[".root"] = Prompt_Editor_Tabs(".root")
            tabs_dict[".root"].files.append(File_Names(full_path=full_path))
        else:
            sub_dir = prompt_file[:prompt_file.rfind("/")]
            if sub_dir not in tabs_dict.keys():
                tabs_dict[sub_dir] = Prompt_Editor_Tabs(title=sub_dir)
            tabs_dict[sub_dir].files.append(File_Names(full_path))

    #create tabs and associate them with the dict    
    sorted_tabs_list = sorted(tabs_dict.keys())
    _tabs = st.tabs(sorted_tabs_list)
    for tl_item, tl_value in enumerate(sorted_tabs_list):
        tabs_dict[tl_value].tab_context = _tabs[tl_item]

    for values in tabs_dict.values():
        with values.tab_context:
            for item in values.files:
                Prompt_Editor_Form(item)
