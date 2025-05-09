from array import array
from pydantic import BaseModel, Field as pydField
"""
Was thinhking this through, and it might be better to have only 
4 fields for user entry and have an llm fill in the rest.

Name:
Physical Desc:
Personality:
Background:

The rest can be dynamically assigned as play continues. A person 
could develop a fear of dragons if repeatedly are put into a 
bleedout state, and have that fear taken away after several 
encounters where this does not occur
"""
class NPC_Profile(BaseModel):
    id: int = "-1"
    name: str = ""
    bio: str = ""
    personality: str = ""
    voiceMannerisms: str = ""
    beliefs: str = ""
    likes: str = ""
    dislikes: str = ""
    goals: str = "" # might want to dynamically modifiy this over time
    fears: str = ""
    physical_desc: str = ""
    #vector: array = pydField(default_factory=array) #unsure what this is for
    #llm_model: int = 0 # index for for the LLM service/model to use
    #voice_id: int = 0 # index/str for the voice sample to use

