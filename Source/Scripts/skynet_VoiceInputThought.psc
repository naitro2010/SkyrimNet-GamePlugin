Scriptname skynet_VoiceInputThought extends ActiveMagicEffect  

Event OnEffectStart(Actor akTarget, Actor akCaster)
	
    ; Record speech - check current state
    if SkyrimNetApi.IsRecordingInput()
        ; Currently recording, so stop it
        SkyrimNetApi.TriggerVoiceThoughtReleased(10.0)
    else
        ; Not recording, so start it
        SkyrimNetApi.TriggerVoiceThoughtPressed()
    endif

EndEvent