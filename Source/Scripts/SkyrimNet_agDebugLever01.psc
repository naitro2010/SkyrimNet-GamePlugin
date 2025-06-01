Scriptname SkyrimNet_agDebugLever01 extends ObjectReference  

skynet_MainController Property skynet Auto
Actor Property actor1 Auto
Actor Property actor2 Auto

Bool bActivated = False
Event OnActivate(ObjectReference akActivator)
    if !bActivated
        debug.notification("Starting Dialogue between Faendal and Gerdur")
        bActivated = true
        skynet.SetActorDialogueTarget(actor1, actor2)
        skynet.SetActorDialogueTarget(actor2, actor1)
    Else
        debug.notification("Stopping Dialogue between Faendal and Gerdur")
        bActivated = false
        skynet.SetActorDialogueTarget(actor1)
        skynet.SetActorDialogueTarget(actor2)
    EndIf
EndEvent