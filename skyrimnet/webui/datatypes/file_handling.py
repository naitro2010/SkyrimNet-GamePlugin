from dependencies import split_dir_file

class File_Names():
    def __init__(self, full_path: str, is_char = False):
        self.full_path = full_path
        _, self.name_nice = split_dir_file(full_path)
        if not is_char:
            self.name_nice = self.name_nice[:-7]
