import streamlit as st
import hashlib
from datatypes import NPC_Profile

class NPC_Profile_Form:
    def __init__(self, npc_profile: NPC_Profile | None = None):
        key_prefix = "npc_profile"

        if npc_profile:
            self.npc_profile = npc_profile
        else:
            self.npc_profile = NPC_Profile(id=-1, name="")
        
        self.npc_profile.name = st.text_input("Name", value=self.npc_profile.name, key=key_prefix+"name")
        self.npc_profile.bio = st.text_area("Biography", value=self.npc_profile.bio, key=key_prefix+"bio")
        self.npc_profile.personality = st.text_area("Personality", value=self.npc_profile.personality, key=key_prefix+"personality")
        self.npc_profile.voiceMannerisms = st.text_area("Voice Mannerisms", value=self.npc_profile.voiceMannerisms, key=key_prefix+"voiceMannerisms")
        self.npc_profile.beliefs = st.text_area("Beliefs", value=self.npc_profile.beliefs, key=key_prefix+"beliefs")
        self.npc_profile.likes = st.text_area("Likes", value=self.npc_profile.likes, key=key_prefix+"likes")
        self.npc_profile.dislikes = st.text_area("Dislikes", value=self.npc_profile.dislikes, key=key_prefix+"dislikes")
        self.npc_profile.goals = st.text_area("Goals", value=self.npc_profile.goals, key=key_prefix+"goals")
        self.npc_profile.fears = st.text_area("Fears", value=self.npc_profile.fears, key=key_prefix+"fears")
        self.npc_profile.physical_desc = st.text_area("Physical Description", value=self.npc_profile.physical_desc, key=key_prefix+"physical_desc")
    
    def  generate(self) -> NPC_Profile | None:
        # check to see if required fields are filled out before generating, display error and return nothing
        if not self.npc_profile.name:
            st.error("Name is a required field.")
            return None
        
        self.npc_profile.id = hashlib.md5(self.npc_profile.name.encode()).hexdigest()
        
        return self.npc_profile