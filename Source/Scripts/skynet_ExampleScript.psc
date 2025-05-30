scriptname skynet_ExampleScript


String Function ExampleDecorator(string decoratorId, Actor akActor) global
  Debug.Trace("[SkyrimNet] (ExampleScript) ExampleDecorator called with decoratorId: " + decoratorId + " and akActor: " + akActor)
  return "Hello, " + akActor.GetLeveledActorBase().GetName() + "!"
EndFunction
