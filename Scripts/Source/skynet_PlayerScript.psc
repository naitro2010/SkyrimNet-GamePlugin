Scriptname skynet_PlayerScript extends ReferenceAlias

skynet_MainController Property skynet  Auto

Event OnPlayerLoadGame()
  Debug.Trace("[SkyrimNet] (PlayerScript) OnPlayerLoadGame called")
  SkyrimnetApi.RegisterDecorator("ExampleDecorator", "SkyrimNetInternal", "ExampleDecorator")
  SkyrimnetApi.RegisterDecorator("ExampleDecorator2", "SkyrimNetInternal", "ExampleDecorator2")
  Debug.Trace("[SkyrimNet] (PlayerScript) ExampleDecorators registered")

  ; --- Registering the Papyrus-defined "ServeFood" Action ---
  string actionName = "ServeFood"
  string description = "The actor serves a specified food item, with logic defined in Papyrus."
  string eligibilityScriptName = "SkyrimNetInternal"
  string eligibilityFunctionName = "ServeFood_IsEligible"
  string executionScriptName = "SkyrimNetInternal"
  string executionFunctionName = "ServeFood_Execute"
  string triggeringEventTypesCsv = "" ; Not triggered in response to any specfic event, LLM option
  string categoryStr = "PAPYRUS" 
  int defaultPriority = 4 ; Maybe slightly higher priority than just idling
  
  ; Define a parameter schema as a JSON string
  ; "foodItem" could be an open string, or you could suggest common items.
  ; "targetName" for who to serve (e.g., "Player", or a specific NPC name if your system can resolve it)
  string parameterSchemaJson = "{ \"foodItem\": \"Bread|Apple|Cheese|Cooked Beef\", \"targetName\": \"string\" }"


  int registrationResult = SkyrimNetApi.RegisterAction(actionName, description, \
                                eligibilityScriptName, eligibilityFunctionName, \
                                executionScriptName, executionFunctionName, \
                                triggeringEventTypesCsv, categoryStr, \
                                defaultPriority, parameterSchemaJson)
  
  if registrationResult == 0
    Debug.Trace("[SkyrimNet] (PlayerScript) Papyrus action '" + actionName + "' registered successfully.")
  else
    Debug.Trace("[SkyrimNet] (PlayerScript) Failed to register Papyrus action '" + actionName + "'. Error code: " + registrationResult)
  endif
EndEvent