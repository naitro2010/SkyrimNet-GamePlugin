scriptname SkyrimNetInternal

; Functions from within this file are executed directly by the main DLL.
; Do not change or touch them, or you risk stability issues.

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