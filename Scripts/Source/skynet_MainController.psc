ScriptName skynet_MainController extends Quest

Actor property playerRef Auto

Event OnInit()
  Maintenance()
EndEvent

Int Function GetVersion()
  return 1
EndFunction

Function Maintenance()
  playerRef = game.GetPlayer()
  SkyrimnetApi.RegisterDecorator("ExampleDecorator", "skynet_ExampleScript", "ExampleCallback")
  Info("SkyrimNet initialized")
EndFunction


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
