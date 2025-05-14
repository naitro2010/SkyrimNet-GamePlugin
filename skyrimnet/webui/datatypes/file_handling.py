def gnice_name(filename: str) -> str:
    name_section = filename[filename.rfind("/")+1:filename.rfind("_")]
    name_split = name_section.split("_")
    return " ".join(name_split).title()

def gnice_prompt(filename: str) -> str:
    return filename[filename.rfind("/")+1:-7]

class File_Names():
    def __init__(self, full_path: str, is_profile = False):
        self.full_path = full_path
        if is_profile:
            self.name_nice = gnice_name(full_path)
        else:
            self.name_nice = gnice_prompt(full_path)

