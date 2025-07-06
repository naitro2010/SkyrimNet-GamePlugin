Scriptname skynet_WheelMenu extends ActiveMagicEffect  

Event OnEffectStart(Actor akTarget, Actor akCaster)
	
    skynet_WheelMenu.DisplayWheel()

EndEvent

;NOTE - this is the function to call from the DLL
;I had to make some sub menus because the wheel menu only supports 9 items
Function DisplayWheel() global

    string labels = "Text Input,Text Thought,Text Roleplay,Direct Input,Think to Self,Auto Roleplay,Utilities"
    string options = "Text Input,Text Thought,Text Roleplay,Direct Input,Think to Self,Auto Roleplay,Utilities Menu"

    int result = skynet_WheelMenu.MenuWheel(StringUtil.Split(options, ","), StringUtil.Split(labels, ","))

    if result == 0
        ; Text input
        SkyrimNetApi.TriggerTextInput()
    elseif result == 1
        ; Text thought
        SkyrimNetApi.TriggerTextThought()
    elseif result == 2
        ; Text dialogue transform
        SkyrimNetApi.TriggerTextDialogueTransform()
    elseif result == 3
        ; Direct input
        SkyrimNetApi.TriggerDirectInput()
    elseif result == 4
        ; Direct player thought processing
        SkyrimNetApi.TriggerPlayerThought()
    elseif result == 5
        ; Direct player dialogue processing
        SkyrimNetApi.TriggerPlayerDialogue()
    elseif result == 6
        skynet_WheelMenu.DisplayUtilities()
    endif

EndFunction

Function DisplayUtilities() global

    string labels = "Go Back,Toggle GameMaster,Continue Narration,Toggle Continuous Mode"
    string options = "Go Back,Toggle GameMaster,Continue Narration,Toggle Continuous Mode"

    int result = skynet_WheelMenu.MenuWheel(StringUtil.Split(options, ","), StringUtil.Split(labels, ","))

    if result == 0
        skynet_WheelMenu.DisplayWheel()
    elseif result == 1
        ; Toggle GameMaster
        SkyrimNetApi.TriggerToggleGameMaster()
    elseif result == 2
        ; Continue narration
        SkyrimNetApi.TriggerContinueNarration()
    elseif result == 3
        ; Toggle continuous mode
        SkyrimNetApi.TriggerToggleContinuousMode()
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