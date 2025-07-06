Scriptname skynet_VoiceInputDirect extends ActiveMagicEffect  

Event OnEffectStart(Actor akTarget, Actor akCaster)
	
    ; Record speech - check current state
    if SkyrimNetApi.IsRecordingInput()
        ; Currently recording, so stop it
        SkyrimNetApi.TriggerVoiceDirectInputReleased(10.0)
    else
        ; Not recording, so start it
        SkyrimNetApi.TriggerVoiceDirectInputPressed()
    endif

EndEvent