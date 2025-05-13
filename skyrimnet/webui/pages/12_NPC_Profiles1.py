from typing import Tuple
import streamlit as st

from scripts import generate_sidebar
from datatypes import File_Names

class NPC_Profile:
    def __init__(self, file_name: str):
        self.filename = File_Names(file_name)
        with open(self.filename.full_path, "r") as f:
            self.full_text = f.read()
        

        block_end = "{% endblock %}"
        block_start = "{% block {title} %}"
        blocks = self.full_text.split(block_end)
        for block in blocks:
            block_text = block[block.rfind(" %}")+3:]
            block_title = block[block.find("{% block ")+9:block.find("%}")]
            st.write("---")
            st.write(f"{block_title}")
            st.write(block_text)


        st.write(self.full_text)
        pass

def main():
    generate_sidebar()
    npc_profile = NPC_Profile("../../SKSE/Plugins/SkyrimNet/prompts/characters/hulda_013BA3.prompt")

if __name__ == "__main__":
    main()