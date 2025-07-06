Scriptname skynet_VoiceInputTransform extends ActiveMagicEffect  

Event OnEffectStart(Actor akTarget, Actor akCaster)
	
    ; Record speech - check current state
    if SkyrimNetApi.IsRecordingInput()
        ; Currently recording, so stop it
        SkyrimNetApi.TriggerVoiceDialogueTransformReleased(10.0)
    else
        ; Not recording, so start it
        SkyrimNetApi.TriggerVoiceDialogueTransformPressed()
    endif

EndEvent