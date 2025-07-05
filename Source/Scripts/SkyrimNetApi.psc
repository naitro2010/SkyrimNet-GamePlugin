Scriptname SkyrimNetApi


; -----------------------------------------------------------------------------
; --- Decorator Management ---
; -----------------------------------------------------------------------------

; Register a decorator to be used when resolving a variable in a prompt
; - decoratorID: Unique identifier for the decorator, e.g., "my_custom_decorator"
; - sourceScript: The script where the global decorator function is defined
; - functionName: The name of the function in the source script that implements the decorator logic
;                 
;   Functions with an Actor parameter can be called from the prompt template by passing a UUID 
;   `{{my_custom_decorator(player.UUID)}}` -> `Function DecoratorFunction(Actor akActor) Global`
int function RegisterDecorator(String decoratorID, String sourceScript, String functionName) Global Native

; -----------------------------------------------------------------------------
; --- Action Management ---
; -----------------------------------------------------------------------------

; Register an action to be performed by an NPC
;
; - actionName: Will be visible to the LLM. Take care when naming so the llm will call it in the right circumstances.
; - parameterSchemaJson: Describes expected parameters, e.g., {"target": "string", "duration": "number"}
; - categoryStr: Should be PAPYRUS

int function RegisterAction(String actionName, String description, \
                           String eligibilityScriptName, String eligibilityFunctionName, \
                           String executionScriptName, String executionFunctionName, \
                           String triggeringEventTypesCsv, String categoryStr, \
                           int defaultPriority, String parameterSchemaJson, String customCategory="", String tags="") Global Native

; Register a custom sub-category for PAPYRUS_CUSTOM actions
int function RegisterSubCategory (String actionName, String description, \
                                String eligibilityScriptName, String eligibilityFunctionName, \
                                String triggeringEventTypesCsv, \
                                int defaultPriority,String customParentCategory, String customCategory) Global Native

; Register a tag with its associated eligibility function
int function RegisterTag(String tagName, String eligibilityScriptName, String eligibilityFunctionName) Global Native

; Check if an action is registered in the action library
; Returns true if the action exists, false otherwise
bool function IsActionRegistered(String actionName) Global Native

; -----------------------------------------------------------------------------
; --- Event Management ---
; -----------------------------------------------------------------------------

; Register a short-lived event that appears in scene context and expires after TTL
; You can use this to have highly real-time events that don't blow up the context. For example, I use these to track the spells that actors have recently cast, like such: spell_cast_actor_id. Whenever an actor casts a spell, it updates this key. Therefore, only the last spell they cast shows up in the context.

; Returns 0 on success, 1 on failure
; - eventId is a unique key for your event. 


int function RegisterShortLivedEvent(String eventId, String eventType, String description, \
                                    String data, int ttlMs, Actor sourceActor, Actor targetActor) Global Native

; Register a persistent event for historical tracking and analysis
; Returns 0 on success, 1 on failure
int function RegisterEvent(String eventType, String content, Actor originatorActor, Actor targetActor) Global Native

; -----------------------------------------------------------------------------
; --- Dialogue Management ---
; -----------------------------------------------------------------------------

; Register dialogue from a speaker (general announcement, no specific listener)
; Returns 0 on success, 1 on failure
int function RegisterDialogue(Actor speaker, String dialogue) Global Native

; Register dialogue from a speaker to a specific listener
; Returns 0 on success, 1 on failure
int function RegisterDialogueToListener(Actor speaker, Actor listener, String dialogue) Global Native

; -----------------------------------------------------------------------------
; --- Package Management ---
; -----------------------------------------------------------------------------

; Register a package to be applied to an actor
; This registers the package internally in SkyrimNet so that its lifecycle is tracked and managed, 
; and then calls RegisterPackage on the SkyrimNetInternal script.
int function RegisterPackage(Actor akActor, String packageName, int priority, int flags, bool isPersistent) Global Native

; Remove a package from an actor
int function UnregisterPackage(Actor akActor, String packageName) Global Native

; Schedule a delayed package removal
int function ScheduleDelayedPackageRemoval(Actor akActor, String packageName, int delaySeconds) Global Native

; Clear all packages applied to an actor
int function ClearAllPackages(Actor akActor) Global Native

; Clear all packages that SkyrimNet is managing
int function ClearAllPackagesGlobally() Global Native

; Cancel any pending package removal tasks for an actor
int function CancelPendingPackageTasks(Actor akActor) Global Native

; Check if an actor has a specific package applied
int function HasPackage(Actor akActor, String packageName) Global Native

; -----------------------------------------------------------------------------
; --- LLM Interaction ---
; -----------------------------------------------------------------------------

; Send a custom prompt to the LLM and receive a callback when it responds
; Returns a request ID (positive integer) on success, or a negative error code on failure
; The callback function should have the signature: Function OnLLMResponse(String response) on the specified script
int function SendCustomPromptToLLM(String promptName, float temperature, int maxTokens, \
                                  String callbackScriptName, String callbackFunctionName) Global Native

; Register a direct narration event that forces the LLM to respond to a factual event
; This function creates an event that NPCs will respond to as established fact, such as:
; - "A tree fell over in the forest"
; - "The guard glares angrily at the traveler" 
; - "Lightning strikes the tower"
; - "A merchant drops their coin purse"
; 
; If originatorActor is specified, that actor will be the one to speak/respond to the event
; If originatorActor is not specified, the system will select an appropriate speaker
; 
; If targetActor is specified, the speaker will address that specific target
; If targetActor is not specified, the speaker will address everyone nearby (general announcement)
; 
; Examples:
; DirectNarration("A wolf howls in the distance") ; System selects speaker, addresses all
; DirectNarration("The shopkeeper drops a bottle", shopkeeperRef) ; Shopkeeper speaks to all
; DirectNarration("The guard thinks that the player looks tired", guardRef, Game.GetPlayer()) ; Guard speaks to player
; 
; Returns 0 on success, 1 on failure
int function DirectNarration(String content, Actor originatorActor = None, Actor targetActor = None) Global Native

; -----------------------------------------------------------------------------
; --- Utility Functions ---
; -----------------------------------------------------------------------------

; Utility functions to extract values from a JSON string
String function GetJsonString(String jsonString, String key, String defaultValue) Global Native
int function GetJsonInt(String jsonString, String key, int defaultValue) Global Native
bool function GetJsonBool(String jsonString, String key, bool defaultValue) Global Native
float function GetJsonFloat(String jsonString, String key, float defaultValue) Global Native
Actor function GetJsonActor(String jsonString, String key, Actor defaultValue) Global Native

; Utility functions to access configuration values
String function GetConfigString(String configName, String path, String defaultValue) Global Native
int function GetConfigInt(String configName, String path, int defaultValue) Global Native
bool function GetConfigBool(String configName, String path, bool defaultValue) Global Native
float function GetConfigFloat(String configName, String path, float defaultValue) Global Native

; Utility functions to get build information
; Returns the SkyrimNet version string (e.g., "0.0.1.0")
String function GetBuildVersion() Global Native
; Returns the build configuration type (e.g., "Debug", "Release", etc.)
String function GetBuildType() Global Native

; Check if currently recording voice input
; Returns true if voice recording is active, false otherwise
bool function IsRecordingInput() Global Native

; -----------------------------------------------------------------------------
; --- Web Interface ---
; -----------------------------------------------------------------------------

; Open the default web browser to the SkyrimNet web interface
; Returns 0 on success, 1 on failure
int function OpenSkyrimNetUI() Global Native

; -----------------------------------------------------------------------------
; --- Hotkey Trigger Functions ---
; -----------------------------------------------------------------------------

; These functions trigger hotkey actions programmatically from Papyrus.
; They function identically as if the player had pressed the corresponding physical key.
; All functions return 0 on success, 1 on failure.

; --- Voice Recording Functions ---

; Simulates pressing the voice recording hotkey
; - Plays input start sound effect or shows notification
; - Prepares search query cache for player input
; - Starts voice recording with 200-second timeout
; - Resets GameMaster action cooldown
; Functions identically to pressing the configured voice recording key
int function TriggerRecordSpeechPressed() Global Native

; Simulates releasing the voice recording hotkey
; - Plays input end sound effect or shows notification
; - Stops voice recording and processes the recorded audio
; - Duration parameter simulates how long the key was held (in seconds)
; Functions identically to releasing the configured voice recording key
int function TriggerRecordSpeechReleased(float duration) Global Native

; --- Text Input Functions ---

; Simulates pressing the text input hotkey
; - Prepares search query cache for player input
; - Opens text input dialog for the player to type their message
; - Resets GameMaster action cooldown
; Functions identically to pressing the configured text input key
int function TriggerTextInput() Global Native

; --- GameMaster Control Functions ---

; Simulates pressing the GameMaster toggle hotkey
; - Toggles the GameMaster agent on/off
; - Updates configuration and shows notification to player
; - Logs the state change
; Functions identically to pressing the configured GameMaster toggle key
int function TriggerToggleGameMaster() Global Native

; Simulates pressing the continuous mode toggle hotkey
; - Toggles continuous scene mode on/off (requires GameMaster to be enabled)
; - Shows notification with current state and cooldown time
; - Only works if GameMaster agent is already enabled
; Functions identically to pressing the configured continuous mode toggle key
int function TriggerToggleContinuousMode() Global Native

; --- Thought System Functions ---

; Simulates pressing the text thought hotkey
; - Shows "Enter your thought..." notification
; - Prepares search query cache for player input
; - Opens text input dialog for thought input
; - Resets GameMaster action cooldown
; Functions identically to pressing the configured text thought key
int function TriggerTextThought() Global Native

; Simulates pressing the voice thought recording hotkey
; - Plays input start sound effect or shows notification
; - Prepares search query cache for player input
; - Starts voice recording with 90-second timeout for thought input
; - Resets GameMaster action cooldown
; Functions identically to pressing the configured voice thought key
int function TriggerVoiceThoughtPressed() Global Native

; Simulates releasing the voice thought recording hotkey
; - Stops voice recording and processes the recorded audio for thoughts
; - If duration < 0.3 seconds, prompts character to think with empty string
; - If duration >= 0.3 seconds, processes the recorded audio normally
; - Duration parameter simulates how long the key was held (in seconds)
; Functions identically to releasing the configured voice thought key
int function TriggerVoiceThoughtReleased(float duration) Global Native

; --- Dialogue Transformation Functions ---

; Simulates pressing the text dialogue transformation hotkey
; - Shows "Enter text to transform into dialogue..." notification
; - Prepares search query cache for player input
; - Opens text input dialog for dialogue transformation
; - Resets GameMaster action cooldown
; Functions identically to pressing the configured text dialogue transform key
int function TriggerTextDialogueTransform() Global Native

; Simulates pressing the voice dialogue transformation hotkey
; - Plays input start sound effect or shows notification
; - Prepares search query cache for player input
; - Starts voice recording with 90-second timeout for dialogue transformation
; - Resets GameMaster action cooldown
; Functions identically to pressing the configured voice dialogue transform key
int function TriggerVoiceDialogueTransformPressed() Global Native

; Simulates releasing the voice dialogue transformation hotkey
; - Stops voice recording and processes the recorded audio for dialogue transformation
; - If duration < 0.3 seconds, prompts character to speak with empty string
; - If duration >= 0.3 seconds, processes the recorded audio normally
; - Duration parameter simulates how long the key was held (in seconds)
; Functions identically to releasing the configured voice dialogue transform key
int function TriggerVoiceDialogueTransformReleased(float duration) Global Native

; --- Direct Input Functions ---

; Simulates pressing the direct input hotkey
; - Shows "Enter custom event text..." notification
; - Prepares search query cache for player input
; - Opens text input dialog for direct event input
; - Resets GameMaster action cooldown
; Functions identically to pressing the configured direct input key
int function TriggerDirectInput() Global Native

; Simulates pressing the voice direct input hotkey
; - Plays input start sound effect or shows notification
; - Prepares search query cache for player input
; - Starts voice direct input recording with 200-second timeout
; - Resets GameMaster action cooldown
; Functions identically to pressing the configured voice direct input key
int function TriggerVoiceDirectInputPressed() Global Native

; Simulates releasing the voice direct input hotkey
; - Plays input end sound effect or shows notification
; - Stops voice recording and processes the recorded audio for direct input
; - Duration parameter simulates how long the key was held (in seconds)
; Functions identically to releasing the configured voice direct input key
int function TriggerVoiceDirectInputReleased(float duration) Global Native

; --- Narration Control Functions ---

; Simulates pressing the continue narration hotkey
; - Shows "Continuing narration..." notification
; - Registers an ephemeral EVENT_CONTINUE_NARRATION event
; - Triggers callbacks for narration continuation without persisting the event
; Functions identically to pressing the configured continue narration key
int function TriggerContinueNarration() Global Native

; -----------------------------------------------------------------------------
; --- Events ---
; -----------------------------------------------------------------------------


; Package Added
; -------------
;
; Called when a package is added to an actor through SkyrimNet
; Example:
;
; RegisterForRegisterForModEvent("SkyrimNet_OnPackageAdded", "OnPackageAdded")
;
; Event OnPackageAdded(Actor akActor, Package akPackage) 
;     ; Your code to handle the package added event
; EndEvent
;
;
;
; Package Removed
; -------------
;
; Called when a package is reemoved from an actor through SkyrimNet
; Example:
;
; RegisterForRegisterForModEvent("SkyrimNet_OnPackageRemoved", "OnPackageRemoved")
;
; Event OnPackageRemoved(Actor akActor, Package akPackage) 
;     ; Your code to handle the package removed event
; EndEvent
;