Scriptname SkyrimNet_agDebugLever01 extends ObjectReference  

Actor Property actor1 Auto
Actor Property actor2 Auto

Function SetActorDialogueTarget(ObjectReference akRef, ObjectReference akTarget)
    Keyword dialogueTargetKeyword = Game.GetFormFromFile(0x01401, "SkyrimNet.esp") as Keyword
    Package npcDialoguePackage = Game.GetFormFromFile(0x01965, "SkyrimNet.esp") as Package

    if !npcDialoguePackage || !dialogueTargetKeyword
        Debug.Notification("[SkyrimNetInternal] Failed to load package or keyword")
        Debug.Trace("[SkyrimNetInternal] AddPackageToActor: playerDialoguePackage is null")
        return
    endif

    Actor speaker = akRef as Actor
    if !speaker
        Debug.Notification("[SkyrimNetInternal] Actor Cast failed.")
        Return
    endif

    ; we're using linkedrefs with keyword to pass info to the packages about who our target is.
    ; you can clear them with akRef.SetLinkedRef(None, dialogueTargetKeyword).
    PO3_SKSEFunctions.SetLinkedRef(akRef, akTarget, dialogueTargetKeyword)
    speaker.SetLookAt(akTarget)

    ActorUtil.AddPackageOverride(speaker, npcDialoguePackage, 1)
    speaker.EvaluatePackage()
EndFunction

Function ClearActorDialogueTarget(ObjectReference akRef) 
    Keyword dialogueTargetKeyword = Game.GetFormFromFile(0x01401, "SkyrimNet.esp") as Keyword
    Package npcDialoguePackage = Game.GetFormFromFile(0x01965, "SkyrimNet.esp") as Package

    if !npcDialoguePackage || !dialogueTargetKeyword
        Debug.Notification("[SkyrimNetInternal] Failed to load package or keyword")
        Debug.Trace("[SkyrimNetInternal] AddPackageToActor: playerDialoguePackage is null")
        return
    endif

    Actor speaker = akRef as Actor
    if !speaker
        Debug.Notification("[SkyrimNetInternal] Actor Cast failed.")
        Return
    endif

    PO3_SKSEFunctions.SetLinkedRef(akRef, None, dialogueTargetKeyword)
    speaker.ClearLookAt()

    ActorUtil.RemovePackageOverride(speaker, npcDialoguePackage)
    speaker.EvaluatePackage()
EndFunction

Bool bActivated = False
Event OnActivate(ObjectReference akActivator)
    if !bActivated
        debug.notification("Starting Dialogue between Faendal and Gerdur")
        bActivated = true
        SetActorDialogueTarget(actor1, actor2)
        SetActorDialogueTarget(actor2, actor1)
    Else
        debug.notification("Stopping Dialogue between Faendal and Gerdur")
        bActivated = false
        ClearActorDialogueTarget(actor1)
        ClearActorDialogueTarget(actor2)
    EndIf
EndEvent