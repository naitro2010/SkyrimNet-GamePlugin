scriptname SkyrimNetInternal

; Functions from within this file are executed directly by the main DLL.
; Do not change or touch them, or you risk stability issues.

; -----------------------------------------------------------------------------
; --- Package Management ---
; -----------------------------------------------------------------------------

Function AddPackageToActor(Actor akActor, string packageName, int priority, int flags) global
    Debug.Trace("[SkyrimNetInternal] AddPackageToActor called for " + akActor.GetDisplayName() + " with package " + packageName + " and priority " + priority + " and flags " + flags)
    ; Package followPlayerPackage = Game.GetFormFromFile(0x0E8E, "SkyrimNet.esp") as Package
    
    ; if !followPlayerPackage
    ;     Debug.Notification("[SkyrimNetInternal] Failed to get FollowPlayer package from SkyrimNet.esp")
    ;     Debug.Trace("[SkyrimNetInternal] AddPackageToActor: followPlayerPackage is null")
    ;     return
    ; endif
    ; Faction followPlayerFaction = Game.GetFormFromFile(0x0E8B, "SkyrimNet.esp") as Faction
    ; if !followPlayerFaction
    ;     Debug.Notification("[SkyrimNetInternal] Failed to get FollowPlayer faction from SkyrimNet.esp")
    ;     Debug.Trace("[SkyrimNetInternal] AddPackageToActor: followPlayerFaction is null")
    ;     return
    ; endif
    ;;;;;
    ;
    ; Package handling
    ;
    ;;;;;
    if packageName == "TalkToPlayer"
        ; FollowPlayer Package
        debug.notification("TalkToPlayer")
        Package playerDialoguePackage = Game.GetFormFromFile(0x01964, "SkyrimNet.esp") as Package

        if !playerDialoguePackage
            Debug.Notification("[SkyrimNetInternal] Failed to get PlayerDialogue package from SkyrimNet.esp")
            Debug.Trace("[SkyrimNetInternal] AddPackageToActor: playerDialoguePackage is null")
            return
        endif

        Debug.Trace("[SkyrimNetInternal] Adding FollowPlayer package to " + akActor.GetDisplayName() + " with priority " + priority + " and flags " + flags)
        ActorUtil.AddPackageOverride(akActor, playerDialoguePackage, priority, flags)
        ; akActor.AddToFaction(followPlayerFaction)
        ; akActor.SetFactionRank(followPlayerFaction, 1)
        akActor.SetLookAt(Game.GetPlayer())
    endif
    akActor.EvaluatePackage()
EndFunction

Function RemovePackageFromActor(Actor akActor, string packageName) global
    Debug.Trace("[SkyrimNetInternal] RemovePackageFromActor called for " + akActor.GetDisplayName() + " with package " + packageName)
    ; Package followPlayerPackage = Game.GetFormFromFile(0x0E8E, "SkyrimNet.esp") as Package
    ; Faction followPlayerFaction = Game.GetFormFromFile(0x0E8B, "SkyrimNet.esp") as Faction

    Package playerDialoguePackage = Game.GetFormFromFile(0x01964, "SkyrimNet.esp") as Package
    
    if packageName == "TalkToPlayer"
        ; FollowPlayer Package
        Debug.Trace("[SkyrimNetInternal] Removing FollowPlayer package from " + akActor.GetDisplayName())
        ActorUtil.RemovePackageOverride(akActor, playerDialoguePackage)
        ; akActor.RemoveFromFaction(followPlayerFaction)
        akActor.ClearLookAt()
    endif
    akActor.EvaluatePackage()
EndFunction


; -----------------------------------------------------------------------------
; --- Player Input Handlers ---
; -----------------------------------------------------------------------------

string Function GetPlayerInput() global
    Debug.Trace("[SkyrimNetInternal] GetPlayerInput called")
    UIExtensions.OpenMenu("UITextEntryMenu")
    string messageText = UIExtensions.GetMenuResultString("UITextEntryMenu")
    Debug.Trace("[SkyrimNetInternal] GetPlayerInput returned: " + messageText)
    return messageText
EndFunction

; -----------------------------------------------------------------------------
; --- Example Papyrus Decorators ---
; -----------------------------------------------------------------------------

string Function ExampleDecorator(Actor akActor) global
    Debug.Trace("[SkyrimNet] (ExampleScript) ExampleDecorator called")
    return "Hello, world!"
EndFunction


string Function ExampleDecorator2(Actor akActor) global
    Debug.Trace("[SkyrimNet] (ExampleScript) ExampleDecorator2 called with " + akActor + " : " + akActor.GetDisplayName())
    return "Hello, world! You called me with " + akActor.GetDisplayName()
EndFunction

; -----------------------------------------------------------------------------
; --- Example Papyrus Action Callbacks for Serving Food ---
; -----------------------------------------------------------------------------

; Eligibility function for a "ServeFood" action
bool Function ServeFood_IsEligible(Actor akActor, string contextJson, string paramsJson) global
    Debug.Trace("[SkyrimNetInternal] ServeFood_IsEligible called for " + akActor.GetDisplayName())
    Debug.Trace("[SkyrimNetInternal] ContextJSON: " + contextJson)
    Debug.Trace("[SkyrimNetInternal] ParamsJSON: " + paramsJson)
    
    ; Example eligibility: 
    ; 1. Actor must not be in combat.
    if akActor.IsInCombat()
        Debug.Trace("[SkyrimNetInternal] ServeFood_IsEligible: " + akActor.GetDisplayName() + " is in combat. Cannot serve food.")
        return false
    endif

    Debug.Trace("[SkyrimNetInternal] ServeFood_IsEligible: " + akActor.GetDisplayName() + " is eligible to serve food.")
    return true
EndFunction

; Execution function for a "ServeFood" action
Function ServeFood_Execute(Actor akActor, string contextJson, string paramsJson) global
    Debug.Trace("[SkyrimNetInternal] ServeFood_Execute called for " + akActor.GetDisplayName())
    Debug.Trace("[SkyrimNetInternal] ContextJSON: " + contextJson)
    Debug.Trace("[SkyrimNetInternal] ParamsJSON: " + paramsJson)

    ; Get parameters using the JSON utility functions
    string foodItem = SkyrimNetApi.GetJsonString(paramsJson, "foodItem", "some bread")
    string targetName = SkyrimNetApi.GetJsonString(paramsJson, "targetName", "the guest") ; Could be "Player" or another NPC name

    Debug.Trace("[SkyrimNetInternal] " + akActor.GetDisplayName() + " is serving " + foodItem + " to " + targetName + ". (Action executed via Papyrus)")
    
    ; Give the item to the player. Placeholder for now.
    Debug.Notification(akActor.GetDisplayName() + " says: Here you go, " + targetName + ". Have some " + foodItem + ".")
    ; Future prompt requests and/or completion signals can go here.
EndFunction


; Eligibility function for an "Animation<type>" action
bool Function Animation_IsEligible(Actor akActor, string contextJson, string paramsJson) global
    Debug.Trace("[SkyrimNetInternal] Animation_IsEligible called for " + akActor.GetDisplayName())

    if akActor.IsInCombat()
        Debug.Trace("[SkyrimNetInternal] Animation_IsEligible: " + akActor.GetDisplayName() + " is in combat. Cannot animate.")
        return false
    endif

    Debug.Trace("[SkyrimNetInternal] Animation_IsEligible: " + akActor.GetDisplayName() + " is eligible to animate.")
    return true
EndFunction


Function AnimationSlapActor(Actor akOriginator, string contextJson, string paramsJson) global
    actor akTarget = SkyrimNetApi.GetJsonActor(paramsJson, "target", Game.GetPlayer())
    sound slapSound = Game.GetFormFromFile(0x0E98, "SkyrimNet.esp") as Sound
    if (!akOriginator || !akTarget)
        Debug.Trace("[SkyrimNetInternal] AnimationSlapActor: akOriginator or akTarget is null")
        return
    endif
    Debug.Trace("[SkyrimNetInternal] AnimationSlapActor: Slapping " + akTarget.GetDisplayName() + " with " + akOriginator.GetDisplayName())
    akTarget.SetDontMove()
    akOriginator.MoveTo(akTarget, 40.0 * Math.Sin(akTarget.GetAngleZ()), 40.0 * Math.Cos(akTarget.GetAngleZ()))
    akOriginator.SetAngle(0.0, 0.0, akTarget.GetAngleZ()+180.0)
    debug.sendanimationevent(akOriginator, "SMplayerslaps")
    slapSound.play(akTarget)
    utility.wait(0.8)
    akOriginator.pushactoraway(akTarget,1)
    akTarget.SetDontMove(false)
EndFunction

Function AnimationPrayer(Actor akOriginator, string contextJson, string paramsJson) global
    GlobalVariable prayAnimationGlobal = Game.GetFormFromFile(0x0E99, "SkyrimNet.esp") as GlobalVariable
    if (!akOriginator)
        Debug.Trace("[SkyrimNetInternal] AnimationPrayer: akOriginator is null")
        return
    endif
    Debug.Trace("[SkyrimNetInternal] AnimationPrayer: Praying with " + akOriginator.GetDisplayName())
    PrayAnimationGlobal.SetValue(10)
    Utility.wait(5)
    PrayAnimationGlobal.SetValue(0)
EndFunction
