Scriptname skynet_Library extends Quest  

skynet_MainController Property skynet Auto Hidden

; -----------------------------------------------------------------------------
; --- The Library Part of the Library ---
; -----------------------------------------------------------------------------
Faction Property factionMerchants Auto

Idle Property IdleApplaud2 Auto
Idle Property IdleApplaud3 Auto
Idle Property IdleApplaud4 Auto
Idle Property IdleApplaud5 Auto
Idle Property IdleApplaudSarcastic Auto
Idle Property IdleBook_Reading Auto
Idle Property IdleDrink Auto
Idle Property IdleDrinkPotion Auto
Idle Property IdleEatSoup Auto
Idle Property IdleExamine Auto
Idle Property IdleLaugh Auto
Idle Property IdleNervous Auto
Idle Property IdleNoteRead Auto
Idle Property IdlePointClose Auto
Idle Property IdlePray Auto
Idle Property IdleSalute Auto
Idle Property IdleSnapToAttention Auto
Idle Property IdleStudy Auto
Idle Property IdleWave Auto
Idle Property IdleWipeBrow Auto

; -----------------------------------------------------------------------------
; --- Version & Maintenance ---
; -----------------------------------------------------------------------------

Function Maintenance(skynet_MainController _skynet)
    skynet = _skynet
    RegisterActions()
    skynet.Info("Library initialized")
EndFunction

Function RegisterActions()
    if !RegisterOpenTradeAction()
        skynet.Fatal("OpenTrade failed to register.")
        return
    endif

    if !RegisterAnimationActions()
        skynet.Fatal("Animation actions failed to register.")
        return
    endif

    ; DEBUG ONLY
    debug.notification("Actions registered.")
EndFunction

; -----------------------------------------------------------------------------
; --- Skynet Papyrus Actions ---
; -----------------------------------------------------------------------------

Bool Function RegisterOpenTradeAction()
  string actionName = "OpenTrade"
  string description = "If player asks to trade and you agree to trade, you use this to open the trade menu"
  string eligibilityScriptName = "SkyrimNetInternal"
  string eligibilityFunctionName = "OpenTrade_IsEligible"
  string executionScriptName = "SkyrimNetInternal"
  string executionFunctionName = "OpenTrade_Execute"
  string triggeringEventTypesCsv = ""
  string categoryStr = "PAPYRUS" 
  int defaultPriority = 1
  
  string parameterSchemaJson = "{}"

  int registrationResult = SkyrimNetApi.RegisterAction(actionName, description, \
                                eligibilityScriptName, eligibilityFunctionName, \
                                executionScriptName, executionFunctionName, \
                                triggeringEventTypesCsv, categoryStr, \
                                defaultPriority, parameterSchemaJson)
  
  if registrationResult == 0
    skynet.Info("Papyrus action '" + actionName + "' registered successfully.")
    return true
  else
    skynet.Error("Failed to register Papyrus action '" + actionName + "'. Error code: " + registrationResult)
    return false
  endif
EndFunction

; we reoute stuff here if it has properties we can use so we're not in the global anymore
Bool Function OpenTrade_IsEligible(Actor akActor, string contextJson, string paramsJson)
    if akActor.GetFactionRank(factionMerchants) == -2
        return false
    endif
    return true
EndFunction

Bool Function RegisterAnimationActions()
    SkyrimNetApi.RegisterAction("AnimationSlapActor", "Slap an actor with a sound effect.", \
                                "SkyrimNetInternal", "Animation_IsEligible", \
                                "SkyrimNetInternal", "AnimationSlapActor", \
                                "", "PAPYRUS", \
                                1, "{\"target\": \"Actor\"}")

    SkyrimNetApi.RegisterAction("AnimationGeneric", "Play a generic animation to emphasize your words.", \
                                "SkyrimNetInternal", "Animation_IsEligible", \
                                "SkyrimNetInternal", "AnimationGeneric", \
                                "", "PAPYRUS", \
                                1, "{ \"anim\": \"applaud|applaud_sarcastic|drink|drink_potion|eat|laugh|nervous|read_note|pray|salute|study|wave|wipe_brow\" }")

    SkyrimNetApi.RegisterAction("AnimationPrayer", "Pray with an animation.", \
                                "SkyrimNetInternal", "Animation_IsEligible", \
                                "SkyrimNetInternal", "AnimationPrayer", \
                                "", "PAPYRUS", \
                                1, "")

    return True
EndFunction

Function PlayGenericAnimation(Actor akActor, String anim)
    Idle _idle

    If anim == "applaud"
        int rnd = Utility.RandomInt(0,3)
        if rnd == 0
            _idle = IdleApplaud2
        elseif rnd == 1
            _idle = IdleApplaud3
        elseif rnd == 2
            _idle = IdleApplaud4
        elseif rnd == 3
            _idle = IdleApplaud5
        EndIf
    ElseIf anim == "applaud_sarcastic"
        _idle = IdleApplaudSarcastic
    Elseif anim == "read_book"
        _idle = IdleBook_Reading
    Elseif anim == "drink"
        _idle = IdleDrink
    Elseif anim == "drink_potion"
        _idle = IdleDrinkPotion
    Elseif anim == "eat"
        _idle = IdleEatSoup
    Elseif anim == "laugh"
        _idle = IdleLaugh
    Elseif anim == "nervous"
        _idle = IdleNervous
    Elseif anim == "read_note"
        _idle = IdleNoteRead
    Elseif anim == "pray"
        _idle = IdlePray
    Elseif anim == "salute"
        _idle = IdleSalute
    Elseif anim == "study"
        _idle = IdleStudy
    Elseif anim == "wave"
        _idle = IdleWave
    Elseif anim == "wipe_brow"
        _idle = IdleWipeBrow
    endif

    if !_idle
        skynet.Error("Could not parse animation string for generic animation: " + anim)
        Return
    endif

	debug.notification("Playing animation: " + anim)
    akActor.PlayIdle(_idle)
    utility.wait(5)
    akActor.PlayIdle(_idle) ; playing same idle again resets it in the case of loops
EndFunction