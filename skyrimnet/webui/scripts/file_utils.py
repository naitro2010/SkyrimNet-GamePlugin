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

def get_dirfiles_sorted_mru_alpha(path:str, ext:str=".prompt") -> list[str]:
    ''' returns a sorted list of files in the given directory with the given extension.
    sorting is done by modification time and then alphabetically'''
    if not os.path.isdir(path):
        return []
    files = [f for f in os.listdir(path) if os.path.isfile(os.path.join(path, f))]
    if ext:
        files = [f for f in files if f.endswith(ext)]
    files.sort(key=lambda x: (os.path.getmtime(os.path.join(path, x)), x), reverse=True)
    return files
    