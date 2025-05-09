import streamlit as st

from forms import NPC_Profile_Form
from datatypes import NPC_Profile
from scripts import generate_sidebar

def main():
    generate_sidebar()
    st.subheader("Player Profile", anchor=False)
    npc_profile = NPC_Profile_Form()
    
    if not st.button("Submit"):
        return
    
    npc_profile = npc_profile.generate()
    if not npc_profile:
        return
    
    # TODO: save to database

    st.write(npc_profile)

if __name__ == "__main__":
    main()