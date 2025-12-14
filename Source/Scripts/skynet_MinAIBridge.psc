Scriptname skynet_MinAIBridge extends Quest
; Bridge script that listens for MinAI mod events and forwards them through SkyrimNet's native API.
; This allows SkyrimNet to receive events from mods that integrate with MinAI.

; Reference to main controller for logging
skynet_MainController Property skynet Auto Hidden

; Track if MinAI is installed (we still bridge events even if MinAI is present)
Bool Property minAIInstalled = false Auto Hidden

; =============================================================================
; --- Initialization ---
; =============================================================================

Function Maintenance(skynet_MainController _skynet)
    skynet = _skynet
    
    ; Check if MinAI is installed
    minAIInstalled = (Game.GetModByName("MinAI.esp") != 255)
    
    if minAIInstalled
        skynet.Info("MinAI Bridge: MinAI.esp detected - SkyrimNet will receive events in parallel with MinAI")
    else
        skynet.Info("MinAI Bridge: MinAI.esp not detected - SkyrimNet will handle MinAI-style events exclusively")
    endif
    
    ; Register for MinAI-style mod events
    ; These are the "new style" events that use ModEvent.Create/Push*/Send
    RegisterForModEvent("MinAI_RegisterEvent", "OnMinAI_RegisterEvent")
    RegisterForModEvent("MinAI_SetContext", "OnMinAI_SetContext")
    RegisterForModEvent("MinAI_RequestResponse", "OnMinAI_RequestResponse")
    RegisterForModEvent("MinAI_RequestResponseDialogue", "OnMinAI_RequestResponseDialogue")
    
    skynet.Info("MinAI Bridge: Registered for MinAI-style mod events")
EndFunction

; =============================================================================
; --- MinAI_SetContext ---
; Set persistent context that appears in scene context until TTL expires.
;
; Usage from Papyrus:
;   int handle = ModEvent.Create("MinAI_SetContext")
;   if (handle)
;     ModEvent.PushString(handle, modName)        ; Source mod name
;     ModEvent.PushString(handle, eventKey)       ; Context key
;     ModEvent.PushString(handle, eventValue)     ; Context value/description
;     ModEvent.PushInt(handle, ttl)               ; Time-to-live in seconds (0 to clear)
;     ModEvent.Send(handle)
;   endIf
; =============================================================================

Event OnMinAI_SetContext(string modName, string eventKey, string eventValue, int ttl)
    skynet.Debug("MinAI Bridge: SetContext(" + modName + ":" + eventKey + " TTL:" + ttl + "): " + eventValue)
    
    ; Convert TTL from seconds to milliseconds
    int ttlMs = ttl * 1000
    
    ; If TTL is 0 or negative, this is a context clear - use a very short TTL to expire quickly
    if ttl <= 0
        ttlMs = 100
    endif
    
    ; Create a unique event ID from mod name and key for deduplication
    ; This ensures only one context per key exists at a time per mod
    string eventId = "minai_ctx_" + modName + "_" + eventKey
    
    Actor playerRef = Game.GetPlayer()
    
    ; Register as a short-lived event that will appear in scene context
    SkyrimNetApi.RegisterShortLivedEvent( \
        eventId, \
        "minai_context", \
        eventValue, \
        modName + ":" + eventKey, \
        ttlMs, \
        playerRef, \
        None \
    )
EndEvent

; =============================================================================
; --- MinAI_RegisterEvent ---
; Inform the LLM that something has happened, without requesting a response.
;
; Usage from Papyrus:
;   int handle = ModEvent.Create("MinAI_RegisterEvent")
;   if (handle)
;     ModEvent.PushString(handle, eventLine)      ; Description of what happened
;     ModEvent.PushString(handle, eventType)      ; Category (e.g., "info_mymod")
;     ModEvent.Send(handle)
;   endIf
; =============================================================================

Event OnMinAI_RegisterEvent(string eventLine, string eventType)
    skynet.Debug("MinAI Bridge: RegisterEvent(" + eventType + "): " + eventLine)
    
    ; Forward to SkyrimNet's persistent event system
    ; This creates an event that NPCs will be aware of but won't immediately react to
    Actor playerRef = Game.GetPlayer()
    SkyrimNetApi.RegisterPersistentEvent(eventLine, playerRef, None)
EndEvent

; =============================================================================
; --- MinAI_RequestResponse ---
; Inform the LLM and request an NPC response.
;
; Usage from Papyrus:
;   int handle = ModEvent.Create("MinAI_RequestResponse")
;   if (handle)
;     ModEvent.PushString(handle, eventLine)
;     ModEvent.PushString(handle, eventType)
;     ModEvent.PushString(handle, targetName)     ; Actor name or "everyone"
;     ModEvent.Send(handle)
;   endIf
; =============================================================================

Event OnMinAI_RequestResponse(string eventLine, string eventType, string targetName)
    skynet.Debug("MinAI Bridge: RequestResponse(" + eventType + " => " + targetName + "): " + eventLine)
    
    ; Try to find the target actor by name
    Actor targetActor = SkyrimNetApi.FindActorByName(targetName)
    
    ; Use DirectNarration to trigger an immediate response
    SkyrimNetApi.DirectNarration(eventLine, targetActor, None)
EndEvent

; =============================================================================
; --- MinAI_RequestResponseDialogue ---
; Inform the LLM that an actor has spoken and request a response.
;
; Usage from Papyrus:
;   int handle = ModEvent.Create("MinAI_RequestResponseDialogue")
;   if (handle)
;     ModEvent.PushString(handle, speakerName)
;     ModEvent.PushString(handle, eventLine)      ; What the speaker said
;     ModEvent.PushString(handle, targetName)     ; Who should respond
;     ModEvent.Send(handle)
;   endIf
; =============================================================================

Event OnMinAI_RequestResponseDialogue(string speakerName, string eventLine, string targetName)
    skynet.Debug("MinAI Bridge: RequestResponseDialogue(" + speakerName + " => " + targetName + "): " + eventLine)
    
    ; Try to find both speaker and target actors by name
    Actor speakerActor = SkyrimNetApi.FindActorByName(speakerName)
    Actor targetActor = SkyrimNetApi.FindActorByName(targetName)
    
    ; If we found the speaker, register as dialogue
    if speakerActor
        if targetActor
            SkyrimNetApi.RegisterDialogueToListener(speakerActor, targetActor, eventLine)
        else
            SkyrimNetApi.RegisterDialogue(speakerActor, eventLine)
        endif
    else
        ; Fallback: use DirectNarration with speaker context
        string narratedLine = speakerName + " says: \"" + eventLine + "\""
        SkyrimNetApi.DirectNarration(narratedLine, targetActor, None)
    endif
EndEvent

