Scriptname skynet_WheelMenu extends ActiveMagicEffect  

Event OnEffectStart(Actor akTarget, Actor akCaster)
	
    skynet_WheelMenu.DisplayWheel()

EndEvent

;NOTE - this is the function to call from the DLL
;I had to make some sub menus because the wheel menu only supports 9 items
Function DisplayWheel() global

    string labels = "Text Input,Record Speech,Toggle GameMaster,Player Actions,Dialogue,Special Modes,Narration"
    string options = "Text Input,Record Speech,Toggle GameMaster,Player Actions Menu,Dialogue Menu,Special Modes Menu,Narration"

    int result = skynet_WheelMenu.MenuWheel(StringUtil.Split(options, ","), StringUtil.Split(labels, ","))

    if result == 0
        ; Text input
        SkyrimNetApi.TriggerTextInput()
    elseif result == 1
        ; Record speech
        SkyrimNetApi.TriggerRecordSpeechPressed()
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

    string labels = "Go Back,Text Thought,Voice Thought"
    string options = "Go Back,Text Thought,Voice Thought"

    int result = skynet_WheelMenu.MenuWheel(StringUtil.Split(options, ","), StringUtil.Split(labels, ","))

    if result == 0
        skynet_WheelMenu.DisplayWheel()
    elseif result == 1
        ; Text thought
        SkyrimNetApi.TriggerTextThought()
    elseif result == 2
        ; Voice thought
        SkyrimNetApi.TriggerVoiceThoughtPressed()
    endif

EndFunction

Function DisplayDialogue() global

    string labels = "Go Back,Text Dialogue Transform,Voice Dialogue Transform"
    string options = "Go Back,Text Dialogue Transform,Voice Dialogue Transform"

    int result = skynet_WheelMenu.MenuWheel(StringUtil.Split(options, ","), StringUtil.Split(labels, ","))

    if result == 0
        skynet_WheelMenu.DisplayWheel()
    elseif result == 1
        ; Text dialogue transform
        SkyrimNetApi.TriggerTextDialogueTransform()
    elseif result == 2
        ; Voice dialogue transform
        SkyrimNetApi.TriggerVoiceDialogueTransformPressed()
    endif

EndFunction

Function DisplaySpecialModes() global

    string labels = "Go Back,Toggle Continuous Mode,Direct Input,Voice Direct Input"
    string options = "Go Back,Toggle Continuous Mode,Direct Input,Voice Direct Input"

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
        ; Voice direct input
        SkyrimNetApi.TriggerVoiceDirectInputPressed()
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