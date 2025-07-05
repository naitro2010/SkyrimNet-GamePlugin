Scriptname skynet_VoiceInputNormal extends ActiveMagicEffect  

Event OnEffectStart(Actor akTarget, Actor akCaster)
	
    ; Record speech - check current state
    if SkyrimNetApi.IsRecordingInput()
        ; Currently recording, so stop it
        SkyrimNetApi.TriggerRecordSpeechReleased(10.0)
    else
        ; Not recording, so start it
        SkyrimNetApi.TriggerRecordSpeechPressed()
    endif

EndEvent