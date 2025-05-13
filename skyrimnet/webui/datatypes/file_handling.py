class File_Names():
    def __init__(self, full_path: str, is_profile = False):
        self.full_path = full_path
        if is_profile:
            name_section = full_path[full_path.rfind("/")+1:full_path.rfind("_")]
            name_split = name_section.split("_")
            self.name_nice = " ".join(name_split).capitalize()
        else:
            self.name_nice = full_path[full_path.rfind("/")+1:-7]
