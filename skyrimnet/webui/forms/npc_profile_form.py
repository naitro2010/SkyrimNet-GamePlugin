from time import sleep
import streamlit as st
from datatypes import gnice_name, webui_strings as ui_str
from dependencies import restore_backup, backup_file

class NPC_Profile_Form:
    def __init__(self, filename: str):
        self.filename = filename
        self.name_nice = gnice_name(filename)
        self.quest_integrations = ""
        self.profile_blocks: dict[str, str] = {}
        self.but_save = None
        self.but_restore = None

        try:
            with open(self.filename, "r") as f:
                self.full_text = f.read()
        except Exception as e:
            st.error(ui_str.err_file_load.format(file=self.filename, error=e))
            return

        blocks = self.full_text.split(ui_str.inja_blk_end)

        for block in blocks:
            block = block.strip()
            if block == "":
                continue
            if block.find(ui_str.inja_blk_quest) != -1:
                self.quest_integrations = block
                continue
            block_title = block[block.find(ui_str.inja_blk_start)+len(ui_str.inja_blk_start):block.find(ui_str.inja_blk_start_end)]
            block_text = block[block.rfind("%}")+2:].strip()
            self.profile_blocks[block_title] = block_text
        st.write(f"**{self.name_nice}**")
        for key, value in self.profile_blocks.items():

            self.profile_blocks[key] = st.text_area(label=key, value=value, key=f"npc_pr{key}")

        col_save, col_restore = st.columns(2)
        save_results_area = st.empty()
        col_debug_orig, col_debug_mod = st.columns(2)

        with col_save:
            self.but_save = st.button(label=ui_str.button_save, key=f"npc_pr_npc_save", use_container_width=True)
        with col_restore:
            self.but_restore = st.button(label=ui_str.button_revert, key=f"npc_pr_npc_restore", use_container_width=True)

        #with col_debug_orig:
        #    st.write("###Orig")
        #    st.write(self.full_text)
        #with col_debug_mod:
        #    st.write("###Mod")
        #    st.write(self.generate())

        if not (self.but_restore or self.but_save):
            return
        
        if self.but_save:
            save_results = backup_file(self.filename)
            if save_results != "":
                save_results_area.error(ui_str.err_file_save_backup.format(save_results=save_results))
                return
            try:
                with open(self.filename, 'w') as f:
                    f.write(self.generate())
            except Exception as e:
                save_results_area.error(ui_str.err_file_save.format(error=e))
                return
            save_results_area.success(ui_str.suc_file_save)
            sleep(1)
            st.rerun()
            return

        if self.but_restore:
            restore_results = restore_backup(self.filename)
            if restore_results != "":
                save_results_area.error(ui_str.err_file_restore_backup.format(restore_results))
                    #f"Error restoring backup file: {restore_results}")
                return
            save_results_area.success(ui_str.suc_file_restore)
            sleep(1)
            st.rerun()
            return

    def generate(self) -> str:
        output = ""
        for key, value in self.profile_blocks.items():
            output += ui_str.inja_blk_start + key + ui_str.inja_blk_start_end
            if value.find("\n") != -1:
                output += "\n"
            output += value + " " + ui_str.inja_blk_end + "\n\n"
        output += "\n\n" + self.quest_integrations + " " + ui_str.inja_blk_end
        return output
