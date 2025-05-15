from scripts import generate_sidebar
from dependencies import load_db_list

def main():
    load_db_list()
    generate_sidebar()
    
    pass

if __name__ == "__main__": 
    main()