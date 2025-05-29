ScriptName skynet_MainController extends Quest

skynet_Library Property libs Auto
Actor property playerRef Auto Hidden

; -----------------------------------------------------------------------------
; --- Version & Maintenance ---
; -----------------------------------------------------------------------------
Event OnInit()
  ; for right now we're okay to start it all right away.
  ; in the future, depending on what we do, we might want to have the user f5-f9 and only initialize on load game
  Maintenance()
EndEvent

Int Property versionCurrent = 0 Auto Hidden

Int Function GetVersion()
  return 1
EndFunction

Int Function GetVersionCutoff()
  return 0
EndFunction

; This runs every game load
Function Maintenance()
  RunUpdate()

  libs.Maintenance(self as skynet_MainController)

  Info("SkyrimNet version " + versionCurrent + " ready.")
  Debug.Notification("SkyrimNet version " + versionCurrent + " ready.")
EndFunction

Function RunUpdate()
  Int versionNumber = GetVersion()
  Int versionCutoff = GetVersionCutoff()

  If versionCurrent < versionCutoff
    Fatal("Version is too far out of date. New game required.")
    Debug.MessageBox("Your SkyrimNet plugin version is too far out of date. A new game is required.")
    Return
  EndIf

  If versionCurrent == 0
    ; first time install
    Info("First time install.")
  ElseIf versionCurrent < versionNumber
    Info("Updating to " + versionNumber)
  EndIf

  versionCurrent = versionNumber
EndFunction

; -----------------------------------------------------------------------------
; --- Debug & Trace Functions ---
; -----------------------------------------------------------------------------
Function Fatal(String str)
  Debug.Trace("[SkyrimNet] (Fatal): " + str)
EndFunction

Function Error(String str)
  Debug.Trace("[SkyrimNet] (Error): " + str)
EndFunction

Function Warn(String str)
  Debug.Trace("[SkyrimNet] (Warn): " + str)
EndFunction

Function Info(String str)
  Debug.Trace("[SkyrimNet] (Info): " + str)
EndFunction

Function Debug(String str)
  Debug.Trace("[SkyrimNet] (Debug): " + str)
EndFunction
