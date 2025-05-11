from typing import Tuple
import shutil, os

def backup_file(src: str) -> str:
    ''' copies a file perserving metadata to the same directory with .bak extension if it does not already exist.
    returns an empty string on success or an error message on failure'''
    if os.path.isfile(f"{src}.bak"):
        return ""
    try:
        shutil.copy2(src, f"{src}.bak")
    except Exception as e:
        return str(e)
    return ""

def restore_backup(src: str) -> str:
    ''' restores a backup file from the same directory with .bak extension
    returns an empty string on success or an error message on failure'''
    if not os.path.isfile(f"{src}.bak"):
        return ""
    try:
        shutil.copy2(f"{src}.bak", src)
    except Exception as e:
        return str(e)
    return ""

def split_dir_file(file_path: str) -> Tuple[str, str]:
    directory = os.path.dirname(file_path)
    filename = os.path.basename(file_path)
    return directory, filename
