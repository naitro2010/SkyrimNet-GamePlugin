Scriptname SkyrimNetApi


; Register a decorator to be used when resolving a variable in a prompt
int function RegisterDecorator(String decoratorID, String sourceScript, String functionName) Global Native

; Register an action to be performed by an NPC
int function RegisterAction(String actionName, String description, \
                           String eligibilityScriptName, String eligibilityFunctionName, \
                           String executionScriptName, String executionFunctionName, \
                           String triggeringEventTypesCsv, String categoryStr, \
                           int defaultPriority, String parameterSchemaJson) Global Native

; Send a custom prompt to the LLM and receive a callback when it responds
; Returns a request ID (positive integer) on success, or a negative error code on failure
; The callback function should have the signature: Function OnLLMResponse(String response) on the specified script
int function SendCustomPromptToLLM(String promptName, float temperature, int maxTokens, \
                                  String callbackScriptName, String callbackFunctionName) Global Native

; papyrus_reaction_selector.prompt is used for the event context
bool function SendPapyrusEvent(String content, Actor source, Actor target) Global Native

; Utility functions to extract values from a JSON string
String function GetJsonString(String jsonString, String key, String defaultValue) Global Native
int function GetJsonInt(String jsonString, String key, int defaultValue) Global Native
bool function GetJsonBool(String jsonString, String key, bool defaultValue) Global Native
float function GetJsonFloat(String jsonString, String key, float defaultValue) Global Native
Actor function GetJsonActor(String jsonString, String key, Actor defaultValue) Global Native
