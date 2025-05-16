app_title = "SkyrimNet"

path_prompts = f"../../SKSE/Plugins/{app_title}/prompts"
path_characters = path_prompts+"/characters"
path_dbs = "../data/"
#path_player = "../../SKSE/Plugins/SkyrimNet/prompts/components/character_bio_full.prompt"

err_file_load = "Failed to load file {file}: {error}"
err_file_restore_backup = "Failed to restore backup file: {error}"
err_file_save = "Failed to save file: {error}"
err_file_save_backup = "Failed to create backup file: {error}"
err_no_dbs = "No databases found in data folder"

button_save = "Save"
button_revert = "Reset to default"

inja_blk_start = "{% block "
inja_blk_start_end = " %}"
inja_blk_end = "{% endblock %}"
inja_blk_quest = "{% block quest_integrations %}"

sel_play = "Select Playthrough:"

suc_file_save = "File saved successfully"
suc_file_restore = "File restored successfully"

filter_num = 15
filter_inst = f"Due to the number of items, only {filter_num} will be displayed. Filter by typing first couple of characters of the name."

not_imp = "Not Implimented"

services = ["Speech to Text", "LLM", "Text to Speech"]

sidebar_db_pos = 50