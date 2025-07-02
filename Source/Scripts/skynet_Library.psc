Scriptname skynet_Library extends Quest  

skynet_MainController Property skynet Auto Hidden

; -----------------------------------------------------------------------------
; --- The Library Part of the Library ---
; -----------------------------------------------------------------------------
Faction Property factionMerchants Auto
Faction Property factionInnkeepers Auto
Faction Property factionStewards Auto
Faction Property factionPlayerFollowers Auto

Faction Property factionRentRoom Auto

Quest Property questDialogueGeneric Auto
Quest Property questBountyBandits Auto

GlobalVariable Property globalRentRoomPrice Auto

Keyword Property keywordDialogueTarget Auto
Keyword Property keywordFollowTarget Auto

Package Property packageDialoguePlayer Auto
Package Property packageDialogueNPC Auto
Package Property packageFollowPlayer Auto

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
Idle Property IdleForceDefaultState Auto
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

MiscObject Property miscGold Auto

Message Property msgClearHistory Auto

; -----------------------------------------------------------------------------
; --- Version & Maintenance ---
; -----------------------------------------------------------------------------

Function Maintenance(skynet_MainController _skynet)
    skynet = _skynet
    RegisterActions()
    skynet.Info("Library initialized")
EndFunction

Function RegisterActions()
    if !RegisterTags()
        skynet.Fatal("Tags failed to register.")
        return
    endif

    if !RegisterBasicActions()
        skynet.Fatal("Basic actions failed to register.")
        return
    endif

    if !RegisterAnimationActions()
        skynet.Fatal("Animation actions failed to register.")
        return
    endif

    if !RegisterCompanionActions()
        skynet.Fatal("Companion actions failed to register.")
        return
    endif

    if !RegisterTavernActions()
        skynet.Fatal("Tavern actions failed to register.")
        return
    endif

    ; DEBUG ONLY
    ; debug.notification("Actions registered.")
EndFunction

; -----------------------------------------------------------------------------
; --- Skynet Package Parsing ---
; -----------------------------------------------------------------------------

Package Function GetPackageFromString(String asPackage)
    if asPackage == "TalkToPlayer"
        return packageDialoguePlayer
    elseif asPackage == "TalkToNPC"
        return packageDialogueNPC
    elseif asPackage == "FollowPlayer"
        return packageFollowPlayer
    endif
    return None
EndFunction

Function ApplyPackageOverrideToActor(Actor akActor, String asString, Int priority = 1, Int flags = 0)
    Package _pck = GetPackageFromString(asString)
    if !_pck
        skynet.Error("Could not retrieve package for: " + asString)
        return
    endif
    skynet.Info("Applying package override " + asString + " to " + akActor.GetDisplayName())
    ActorUtil.AddPackageOverride(akActor, _pck, priority, flags)
    akActor.EvaluatePackage()
EndFunction

Function RemovePackageOverrideFromActor(Actor akActor, String asString)
    Package _pck = GetPackageFromString(asString)
    if !_pck
        skynet.Error("Could not retrieve package for: " + asString)
        return
    endif
    skynet.Info("Removing package override " + asString + " from " + akActor.GetDisplayName())
    ActorUtil.RemovePackageOverride(akActor, _pck)
    akActor.EvaluatePackage()
EndFunction

; -----------------------------------------------------------------------------
; --- Skynet Papyrus Actions ---
; -----------------------------------------------------------------------------

Bool Function RegisterBasicActions()
    SkyrimNetApi.RegisterAction("OpenTrade", "Use ONLY if {{ player.name }} asks to trade and you agree to trade. Otherwise, you MUST NOT use this action.", \
                                "SkyrimNetInternal", "OpenTrade_IsEligible", \
                                "SkyrimNetInternal", "OpenTrade_Execute", \
                                "", "PAPYRUS", \
                                1, "")

    SkyrimNetApi.RegisterAction("AccompanyTarget", "Start accompanying {{ player.name }}. Only use this when you are sure that you want to stop what you're doing and follow {{ player.name }} to another location, and {{ player.name }} has specifically requested it.", \
                                "SkyrimNetInternal", "StartFollow_IsEligible", \
                                "SkyrimNetInternal", "StartFollow_Execute", \
                                "", "PAPYRUS", \
                                1, "")

    SkyrimNetApi.RegisterAction("StopAccompanying", "Stop accompanying {{ player.name }}. Use this when you are done accompanying them, or want to go home.", \
                                "SkyrimNetInternal", "StopFollow_IsEligible", \
                                "SkyrimNetInternal", "StopFollow_Execute", \
                                "", "PAPYRUS", \
                                1, "")

    SkyrimNetApi.RegisterAction("WaitHere", "Wait for {{ player.name }} at the current location temporarily. Only use this when {{ player.name }} has specifically requested it.", \
                                "SkyrimNetInternal", "PauseFollow_IsEligible", \
                                "SkyrimNetInternal", "PauseFollow_Execute", \
                                "", "PAPYRUS", \
                                1, "")
    return true
EndFunction

; we reoute stuff here if it has properties we can use so we're not in the global anymore
Bool Function OpenTrade_IsEligible(Actor akActor, string contextJson, string paramsJson)
    if akActor.GetFactionRank(factionMerchants) == -2
        return false
    endif
    return true
EndFunction

Bool Function RegisterTavernActions()
    SkyrimNetApi.RegisterAction("RentRoom", "Rent a room out to {{ player.name }} for an amount of gold, but only if they agreed to the price beforehand", \
                                "SkyrimNetInternal", "RentRoom_IsEligible", \
                                "SkyrimNetInternal", "RentRoom_Execute", \
                                "", "PAPYRUS", \
                                1, "{\"price\": \"Int\"}")

    ; SkyrimNetApi.RegisterAction("GiveBanditBounty", "Hand {{ player.name }} a bounty poster for a bounty on a bandit leader by the local jarl", \
    ;                             "SkyrimNetInternal", "GiveBanditBounty_IsEligible", \
    ;                             "SkyrimNetInternal", "GiveBanditBounty_Execute", \
    ;                             "", "PAPYRUS", \
    ;                             1, "")

    return True
EndFunction

Bool Function RentRoom_IsEligible(Actor akActor)
    if !akActor.IsInFaction(factionRentRoom) || akActor.GetActorValue("Variable09") > 0
        return false
    EndIf

    if !(akActor as RentRoomScript)
        return false
    endif

    return true
EndFunction

Function RentRoom_Execute(Actor akActor, string paramsJson)
    DialogueGenericScript _dqs = (questDialogueGeneric as DialogueGenericScript)

    if (!(akActor as RentRoomScript)) || (!_dqs)
        return
    endif

    Int price = SkyrimNetApi.GetJsonInt(paramsJson, "price", Math.Floor(globalRentRoomPrice.GetValue()))
    if skynet.playerRef.GetItemCount(miscGold) < price
        return
    EndIf

    skynet.playerRef.RemoveItem(miscGold, price)
    (akActor as RentRoomScript).RentRoom(_dqs)
    return
EndFunction

; Bool Function GiveBanditBounty_IsEligible(Actor akActor)
;     if (!akActor.IsInFaction(factionInnkeepers) && !akActor.IsInFaction(factionStewards)) || questBountyBandits.GetStageDone(10)
;         return false
;     EndIf

;     return true
; EndFunction

; Function GiveBanditBounty_Execute(Actor akActor)
;     questBountyBandits.SetStage(10)
;     return
; EndFunction


Bool Function RegisterAnimationActions()
    SkyrimNetApi.RegisterAction("SlapTarget", "Slap the target.", \
                                "SkyrimNetInternal", "Animation_IsEligible", \
                                "SkyrimNetInternal", "AnimationSlapActor", \
                                "", "PAPYRUS", \
                                1, "{\"target\": \"Actor\"}")

    SkyrimNetApi.RegisterAction("Gesture", "Perform a gesture to emphasize your words.", \
                                "SkyrimNetInternal", "Animation_IsEligible", \
                                "SkyrimNetInternal", "AnimationGeneric", \
                                "", "PAPYRUS", \
                                1, "{ \"anim\": \"applaud|applaud_sarcastic|drink|drink_potion|eat|laugh|nervous|read_note|pray|salute|study|wave|wipe_brow\" }")

    return True
EndFunction

; ag12: I hate this. Why didn't Bethesda give us Lua instead of Papyrus? Fuck you, Todd.
Function PlayGenericAnimation(Actor akActor, String anim)
    Idle _idle
    Debug.Trace("Playing animation: " + anim + " for " + akActor.GetDisplayName())
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

    akActor.PlayIdle(IdleForceDefaultState)
    utility.wait(2)
    ; debug.notification("Playing animation: " + anim + " for " + akActor.GetDisplayName())
    akActor.PlayIdle(_idle)
EndFunction

Bool Function RegisterCompanionActions()
    SkyrimNetApi.RegisterAction("CompanionFollow", "Start following {{ player.name }}.", \
                                "SkyrimNetInternal", "CompanionFollow_IsEligible", \
                                "SkyrimNetInternal", "CompanionFollow", \
                                "", "PAPYRUS", \
                                1, "", "", "follower")

    SkyrimNetApi.RegisterAction("CompanionWait", "Wait at this location", \
                                "SkyrimNetInternal", "CompanionWait_IsEligible", \
                                "SkyrimNetInternal", "CompanionWait", \
                                "", "PAPYRUS", \
                                1, "", "", "follower")

    SkyrimNetApi.RegisterAction("CompanionInventory", "Give {{ player.name }} access to your inventory", \
                                "SkyrimNetInternal", "Companion_IsEligible", \
                                "SkyrimNetInternal", "CompanionInventory", \
                                "", "PAPYRUS", \
                                1, "", "", "follower")

    SkyrimNetApi.RegisterAction("CompanionGiveTask", "Let {{ player.name }} designate a task for you", \
                                "SkyrimNetInternal", "CompanionGiveTask_IsEligible", \
                                "SkyrimNetInternal", "CompanionGiveTask", \
                                "", "PAPYRUS", \
                                1, "", "", "follower")

    return true
EndFunction

Bool Function StartFollow_IsEligible(Actor akActor)
    if SkyrimNetApi.HasPackage(akActor, "FollowPlayer") && akActor.GetAV("WaitingForPlayer") == 0
        return false
    endif

    Faction factionCompanion = Game.GetFormFromFile(0x084D1B, "Skyrim.esm") as Faction
    if (!factionCompanion)
        Debug.Trace("[SkyrimNetInternal] StartFollow_IsEligible: factionCompanion is null")
        return true
    endif

    if akActor.IsInFaction(factionCompanion)
        Debug.Trace("[SkyrimNetInternal] StartFollow_IsEligible: " + akActor.GetDisplayName() + " is in the companion faction.")
        return false
    endif
    return true

EndFunction

Bool Function StopFollow_IsEligible(Actor akActor)
    if akActor.IsInFaction(factionPlayerFollowers)
        return false
    endif

    if !SkyrimNetApi.HasPackage(akActor, "FollowPlayer")
        return false
    endif

    return true
EndFunction

Bool Function PauseFollow_IsEligible(Actor akActor)
    if akActor.IsInFaction(factionPlayerFollowers)
        return false
    endif

    if !SkyrimNetApi.HasPackage(akActor, "FollowPlayer")
        return false
    endif

    if akActor.GetAV("WaitingForPlayer") > 0
        return false
    endif

    return true
EndFunction

Function StartFollow_Execute(Actor akActor)
    debug.notification(akActor.GetDisplayName() + " is now accompanying you.")

    akActor.SetAV("WaitingForPlayer", 0)

    SkyrimNetApi.RegisterPackage(akActor, "FollowPlayer", 10, 0, true)

    akActor.EvaluatePackage()
EndFunction

Function StopFollow_Execute(Actor akActor)    
    debug.notification(akActor.GetDisplayName() + " is no longer accompanying you.")

    SkyrimNetApi.UnregisterPackage(akActor, "FollowPlayer")

    akActor.EvaluatePackage()
EndFunction

Function PauseFollow_Execute(Actor akActor)
    debug.notification(akActor.GetDisplayName() + " is waiting for you here.")

    akActor.SetAV("WaitingForPlayer", 1)

    akActor.EvaluatePackage()
EndFunction

; -----------------------------------------------------------------------------
; --- Skynet Tag Registration ---
; -----------------------------------------------------------------------------

Bool Function RegisterTags()
    SkyrimNetApi.RegisterTag("follower", "SkyrimNetInternal", "Follower_IsEligible")
    return true
EndFunction