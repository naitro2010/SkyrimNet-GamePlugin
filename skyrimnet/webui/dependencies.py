#workaround to prevent circular imports from fastapi
from scripts.file_utils import backup_file, restore_backup, split_dir_file