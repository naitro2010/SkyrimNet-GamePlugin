from time import sleep
import streamlit as st
from datatypes import File_Names, webui_strings as ui_str
from dependencies import restore_backup, backup_file

class NPC_Profile_Form:
    def __init__(self, file_name: str):
        self.filename = File_Names(file_name, is_profile=True)
        self.quest_integrations = ""
        self.block_end = "{% endblock %}"
        self.block_start = "{% block "
        self.block_start_end = " %}"
        self.profile_blocks: dict[str, str] = {}
        self.but_save = None
        self.but_restore = None

        try:
            with open(self.filename.full_path, "r") as f:
                self.full_text = f.read()
        except Exception as e:
            st.error(f"Error reading file {self.filename.full_path}: {e}")
            return

        blocks = self.full_text.split(self.block_end)

        for block in blocks:
            block = block.strip()
            if block == "":
                continue
            if block.find("{% block quest_integrations %}") != -1:
                self.quest_integrations = block
                continue
            block_title = block[block.find(self.block_start)+len(self.block_start):block.find(self.block_start_end)]
            block_text = block[block.rfind("%}")+2:].strip()
            self.profile_blocks[block_title] = block_text
        st.write(f"**{self.filename.name_nice}**")
        for key, value in self.profile_blocks.items():

            self.profile_blocks[key] = st.text_area(label=key, value=value, key=f"npc_pr{key}")

        col_save, col_restore = st.columns(2)
        save_results_area = st.empty()
        col_debug_orig, col_debug_mod = st.columns(2)

        with col_save:
            self.but_save = st.button(label=ui_str.button_save, key=f"npc_pr_npc_save", use_container_width=True)
        with col_restore:
            self.but_restore = st.button(label=ui_str.button_revert, key=f"npc_pr_npc_restore", use_container_width=True)

        with col_debug_orig:
            st.write("###Orig")
            st.write(self.full_text)
        with col_debug_mod:
            st.write("###Mod")
            st.write(self.generate())

        if not (self.but_restore or self.but_save):
            return
        
        if self.but_save:
            save_results = backup_file(self.filename.full_path)
            if save_results != "":
                save_results_area.error(f"Error backing up file: {save_results}")
                return
            try:
                with open(self.filename.full_path, 'w') as f:
                    f.write(self.generate())
            except Exception as e:
                save_results_area.error(f"Error saving file: {e}")
                return
            save_results_area.success("File saved successfully")
            return

        if self.but_restore:
            restore_results = restore_backup(self.filename.full_path)
            if restore_results != "":
                save_results_area.error(f"Error restoring backup file: {restore_results}")
                return
            save_results_area.success("File restored successfully")
            sleep(1)
            st.rerun()
            return

    def generate(self) -> str:
        output = ""
        for key, value in self.profile_blocks.items():
            output += self.block_start + key + self.block_start_end
            if value.find("\n") != -1:
                output += "\n"
            output += value + " " + self.block_end + "\n\n"
        output += "\n\n" + self.quest_integrations + " " + self.block_end
        return output

