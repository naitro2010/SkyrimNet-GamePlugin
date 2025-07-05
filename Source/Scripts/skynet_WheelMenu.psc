Scriptname skynet_WheelMenu extends ActiveMagicEffect  

Event OnEffectStart(Actor akTarget, Actor akCaster)
	
    skynet_WheelMenu.DisplayWheel()

EndEvent

;NOTE - this is the function to call from the DLL
;I had to make some sub menus because the wheel menu only supports 9 items
Function DisplayWheel() global

    string recordLabel = "Record Speech"
    string recordOption = "Record Speech"
    
    ; Check if currently recording to update the label and option
    if SkyrimNetApi.IsRecordingInput()
        recordLabel = "Stop Recording"
        recordOption = "Stop Recording"
    else
        recordLabel = "Record Speech"
        recordOption = "Record Speech"
    endif

    string labels = "Text Input," + recordLabel + ",Toggle GameMaster,Player Actions,Dialogue,Special Modes,Narration"
    string options = "Text Input," + recordOption + ",Toggle GameMaster,Player Actions Menu,Dialogue Menu,Special Modes Menu,Narration"

    int result = skynet_WheelMenu.MenuWheel(StringUtil.Split(options, ","), StringUtil.Split(labels, ","))

    if result == 0
        ; Text input
        SkyrimNetApi.TriggerTextInput()
    elseif result == 1
        ; Record speech - check current state
        if SkyrimNetApi.IsRecordingInput()
            ; Currently recording, so stop it
            SkyrimNetApi.TriggerRecordSpeechReleased(10.0)
        else
            ; Not recording, so start it
            SkyrimNetApi.TriggerRecordSpeechPressed()
        endif
    elseif result == 2
        ; Toggle GameMaster
        SkyrimNetApi.TriggerToggleGameMaster()
    elseif result == 3
        skynet_WheelMenu.DisplayPlayerActions()
    elseif result == 4
        skynet_WheelMenu.DisplayDialogue()
    elseif result == 5
        skynet_WheelMenu.DisplaySpecialModes()
    elseif result == 6
        ; Continue narration
        SkyrimNetApi.TriggerContinueNarration()
    endif

EndFunction

Function DisplayPlayerActions() global

    string voiceThoughtLabel = "Voice Thought"
    string voiceThoughtOption = "Voice Thought"
    
    ; Check if currently recording to update the label and option
    if SkyrimNetApi.IsRecordingInput()
        voiceThoughtLabel = "Stop Voice Thought"
        voiceThoughtOption = "Stop Voice Thought"
    else
        voiceThoughtLabel = "Voice Thought"
        voiceThoughtOption = "Voice Thought"
    endif

    string labels = "Go Back,Text Thought," + voiceThoughtLabel
    string options = "Go Back,Text Thought," + voiceThoughtOption

    int result = skynet_WheelMenu.MenuWheel(StringUtil.Split(options, ","), StringUtil.Split(labels, ","))

    if result == 0
        skynet_WheelMenu.DisplayWheel()
    elseif result == 1
        ; Text thought
        SkyrimNetApi.TriggerTextThought()
    elseif result == 2
        ; Voice thought - check current state
        if SkyrimNetApi.IsRecordingInput()
            ; Currently recording, so stop it
            SkyrimNetApi.TriggerVoiceThoughtReleased(10.0)
        else
            ; Not recording, so start it
            SkyrimNetApi.TriggerVoiceThoughtPressed()
        endif
    endif

EndFunction

Function DisplayDialogue() global

    string voiceDialogueLabel = "Voice Dialogue Transform"
    string voiceDialogueOption = "Voice Dialogue Transform"
    
    ; Check if currently recording to update the label and option
    if SkyrimNetApi.IsRecordingInput()
        voiceDialogueLabel = "Stop Voice Dialogue"
        voiceDialogueOption = "Stop Voice Dialogue"
    else
        voiceDialogueLabel = "Voice Dialogue Transform"
        voiceDialogueOption = "Voice Dialogue Transform"
    endif

    string labels = "Go Back,Text Dialogue Transform," + voiceDialogueLabel
    string options = "Go Back,Text Dialogue Transform," + voiceDialogueOption

    int result = skynet_WheelMenu.MenuWheel(StringUtil.Split(options, ","), StringUtil.Split(labels, ","))

    if result == 0
        skynet_WheelMenu.DisplayWheel()
    elseif result == 1
        ; Text dialogue transform
        SkyrimNetApi.TriggerTextDialogueTransform()
    elseif result == 2
        ; Voice dialogue transform - check current state
        if SkyrimNetApi.IsRecordingInput()
            ; Currently recording, so stop it
            SkyrimNetApi.TriggerVoiceDialogueTransformReleased(10.0)
        else
            ; Not recording, so start it
            SkyrimNetApi.TriggerVoiceDialogueTransformPressed()
        endif
    endif

EndFunction

Function DisplaySpecialModes() global

    string voiceDirectLabel = "Voice Direct Input"
    string voiceDirectOption = "Voice Direct Input"
    
    ; Check if currently recording to update the label and option
    if SkyrimNetApi.IsRecordingInput()
        voiceDirectLabel = "Stop Voice Direct"
        voiceDirectOption = "Stop Voice Direct"
    else
        voiceDirectLabel = "Voice Direct Input"
        voiceDirectOption = "Voice Direct Input"
    endif

    string labels = "Go Back,Toggle Continuous Mode,Direct Input," + voiceDirectLabel
    string options = "Go Back,Toggle Continuous Mode,Direct Input," + voiceDirectOption

    int result = skynet_WheelMenu.MenuWheel(StringUtil.Split(options, ","), StringUtil.Split(labels, ","))

    if result == 0
        skynet_WheelMenu.DisplayWheel()
    elseif result == 1
        ; Toggle continuous mode
        SkyrimNetApi.TriggerToggleContinuousMode()
    elseif result == 2
        ; Direct input
        SkyrimNetApi.TriggerDirectInput()
    elseif result == 3
        ; Voice direct input - check current state
        if SkyrimNetApi.IsRecordingInput()
            ; Currently recording, so stop it
            SkyrimNetApi.TriggerVoiceDirectInputReleased(10.0)
        else
            ; Not recording, so start it
            SkyrimNetApi.TriggerVoiceDirectInputPressed()
        endif
    endif

EndFunction

int Function MenuWheel(String[] options, string[] labels) global
    UIMenuBase wheelMenu = uiextensions.GetMenu("UIWheelMenu")
    int i = 0
    int count = options.length 
    while i < count 
        wheelMenu.SetPropertyIndexString(PropertyName = "optionText", index = i, value = options[i])
        wheelMenu.SetPropertyIndexString(PropertyName = "optionLabelText", index = i, value = labels[i])
        wheelMenu.SetPropertyIndexBool("optionEnabled", i, true)
        i += 1
    endwhile 
    return wheelMenu.OpenMenu()
EndFunction