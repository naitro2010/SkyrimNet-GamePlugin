scriptname skynet_ConfigUtilityMenu 

function OpenConfigMenu() global
    UIListMenu menu = UIExtensions.GetMenu("UIListMenu") as UIListMenu 
    menu.ResetMenu()

    string title = "SkyrimNet Configuration Utility"

    bool enableGameMasterAgentCurrent = SkyrimNetApi.GetConfigBool("Game", "gamemaster.agentEnabled", true)
    bool enableEventTrackingCurrent = SkyrimNetApi.GetConfigBool("Events", "global.enabled", true)
    string enableSkyrimNet = "SkyrimNet Enabled: " + BoolToDisplayString(enableGameMasterAgentCurrent || enableEventTrackingCurrent)
    string enableSkyrimnetEventTrackingPatchJson = ""
    string enableSkyrimnetGameMasterAgentPatchJson = ""

    ; Clunky way to do thing, but this works around papyrus' unreliable casing of string due to string caching
    if enableEventTrackingCurrent || enableGameMasterAgentCurrent
        enableSkyrimnetEventTrackingPatchJson = "{ \"global\": { \"enabled\": false } }"
        enableSkyrimnetGameMasterAgentPatchJson = "{ \"gamemaster\": { \"agentEnabled\": false } }"
    else
        enableSkyrimnetEventTrackingPatchJson = "{ \"global\": { \"enabled\": true } }"
        enableSkyrimnetGameMasterAgentPatchJson = "{ \"gamemaster\": { \"agentEnabled\": true } }"
    endif
    
    bool shouldApplyTalkToPlayerPackageCurrent = SkyrimNetApi.GetConfigBool("Game", "speech.shouldApplyTalkToPlayerPackage", true)
    string shouldApplyTalkToPlayerPackage = "Apply TalkToPlayer Package: " + BoolToDisplayString(shouldApplyTalkToPlayerPackageCurrent)
    string shouldApplyTalkToPlayerPackagePatchJson = ""
    if shouldApplyTalkToPlayerPackageCurrent
        shouldApplyTalkToPlayerPackagePatchJson = "{ \"speech\": { \"shouldApplyTalkToPlayerPackage\": false } }"
    else
        shouldApplyTalkToPlayerPackagePatchJson = "{ \"speech\": { \"shouldApplyTalkToPlayerPackage\": true } }"
    endif

    bool enableNarrationCurrent = SkyrimNetApi.GetConfigBool("Game", "narration.enabled", true)
    string enableNarration = "Enable Narration: " + BoolToDisplayString(enableNarrationCurrent)
    string enableNarrationPatchJson = ""
    if enableNarrationCurrent
        enableNarrationPatchJson = "{ \"narration\": { \"enabled\": false } }"
    else
        enableNarrationPatchJson = "{ \"narration\": { \"enabled\": true } }"
    endif


    string enableGameMasterAgent = "Enable Game Master Agent: " + BoolToDisplayString(enableGameMasterAgentCurrent)
    string enableGameMasterAgentPatchJson = ""
    if enableGameMasterAgentCurrent
        enableGameMasterAgentPatchJson = "{ \"gamemaster\": { \"agentEnabled\": false } }"
    else
        enableGameMasterAgentPatchJson = "{ \"gamemaster\": { \"agentEnabled\": true } }"
    endif

    menu.AddEntryItem(title)
    menu.AddEntryItem(enableSkyrimNet)
    menu.AddEntryItem(enableGameMasterAgent)
    menu.AddEntryItem(shouldApplyTalkToPlayerPackage)
    menu.AddEntryItem(enableNarration)

    menu.OpenMenu()
        String result =  menu.GetResultString()

    Debug.Trace("[SkyrimNet] Config Menu Result: " + result)
    if result == "" || result == title
        return
    elseif result == enableSkyrimNet
        bool eventSuccess = SkyrimNetApi.PatchConfig("Events", enableSkyrimnetEventTrackingPatchJson)
        bool agentSuccess = SkyrimNetApi.PatchConfig("Game", enableSkyrimnetGameMasterAgentPatchJson)
        OpenConfigMenu()
        return
    elseif result == enableGameMasterAgent
        bool success = SkyrimNetApi.PatchConfig("game", enableGameMasterAgentPatchJson)
        OpenConfigMenu()
        return
    elseif result == shouldApplyTalkToPlayerPackage
        bool success = SkyrimNetApi.PatchConfig("game", shouldApplyTalkToPlayerPackagePatchJson)
        OpenConfigMenu()
        return
    elseif result == enableNarration
        bool success = SkyrimNetApi.PatchConfig("game", enableNarrationPatchJson)
        OpenConfigMenu()
        return
    endif
endFunction

string function BoolToDisplayString(bool value) global
    if value
        return "Yes"
    else
        return "No"
    endif
endfunction

