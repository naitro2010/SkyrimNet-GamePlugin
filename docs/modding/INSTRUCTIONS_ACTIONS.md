# LLM Instructions: Building SkyrimNet Action Files

This document provides comprehensive instructions for an LLM to create action files for the SkyrimNet mod system. Actions are behaviors that NPCs can perform in response to dialogue or situations.

## Overview

Actions are YAML files stored in `SKSE/Plugins/SkyrimNet/config/actions/`. Each action file defines:
- A named action that NPCs can perform
- The Papyrus script and function to execute
- Parameter mappings (static values, dynamic LLM-provided values, or speaker references)
- Eligibility conditions based on game state
- Optional event registration when the action executes

**CRITICAL**: To build effective actions, you MUST thoroughly understand the mod you're integrating with. This means:
1. Examining the mod's Papyrus scripts to understand available functions
2. Identifying quest editor IDs and script names
3. Understanding parameter types and expected values
4. Determining eligibility conditions based on game state

## MCP Server for Game Data Exploration

**IMPORTANT**: You have access to the SkyrimNet MCP server which exposes game data. The MCP server provides tools to query quests, scripts, functions, properties, and runtime game state.

### Essential MCP Tools for Action Creation

| Tool | Purpose |
|------|---------|
| `get_quests` | Find quests by plugin or name - get quest editor IDs |
| `get_quest_scripts` | **List all Papyrus scripts attached to a quest** |
| `get_quest_script_functions` | **Get all callable functions with full signatures, parameter types, and docstrings** |
| `get_quest_script_properties` | **Get properties/variables from a script with types and current values** |
| `get_quest_property_value` | **Read current runtime value of a specific property** |
| `execute_quest_function` | Test function execution (use with extreme caution!) |
| `get_decorators` | Discover decorator functions for eligibility conditions |
| `get_factions` | Find faction editor IDs for eligibility rules |
| `get_keywords` | Find keyword editor IDs for eligibility rules |
| `get_globals` | Find global variable editor IDs |

### Step-by-Step Workflow for Creating Actions

#### Step 1: Find the Quest
```
Use: get_quests
Parameters: { "plugin": "MyMod.esp" } or { "name_contains": "MyQuest" }
Returns: Quest editor IDs, form IDs, source plugins
```

#### Step 2: Discover Scripts on the Quest
```
Use: get_quest_scripts
Parameters: { "quest_editor_id": "MyModMainQuest" }
Returns: List of script names and types bound to the quest
```

#### Step 3: Explore Available Functions
```
Use: get_quest_script_functions  
Parameters: { "quest_editor_id": "MyModMainQuest", "script_name": "MyModScript" }
Returns: 
- Function names
- Return types
- Parameters with types (Int, Float, Bool, String, Actor, etc.)
- Parameter counts
- Docstrings (if available)
```

**This is the most important step!** The function list tells you exactly what actions are possible and what parameters they need.

#### Step 4: Check Script Properties (Optional)
```
Use: get_quest_script_properties
Parameters: { "quest_editor_id": "MyModMainQuest", "script_name": "MyModScript" }
Returns: Property names, types, and whether they're properties or variables
```

This helps understand the script's state and can inform eligibility conditions.

#### Step 5: Build Eligibility Conditions
```
Use: get_decorators
Parameters: { "category": "Actor" } or { "name_contains": "faction" }
Returns: Available decorator functions with arguments and return types
```

---

## Action File Structure

```yaml
name: "ActionName"
description: "Description visible to the LLM for action selection"

# Papyrus script execution
questEditorId: "QuestEditorID"
scriptName: "ScriptName"
executionFunctionName: "FunctionName"

# Parameter mapping (positional)
parameterMapping:
  - type: "static"
    value: "fixed_value"
  - type: "dynamic"
    name: "param_name"
    description: "Param description for LLM"
  - type: "speaker"

# Eligibility conditions using decorators
eligibilityRules:
  - conditions:
      - decoratorName: "decorator_function"
        arguments: ["currentActor", "other_arg"]  # Use currentActor or player for actor refs
        comparisonOperator: "=="
        expectedValue: true
    logicalOperator: "AND"
    required: true

# Tags for grouping eligibility
tags:
  - "follower"
  - "merchant"

# Event registration (optional)
eventString: "Action performed event description"
isShortLived: false

# Behavior
enabled: true
defaultPriority: 5
```

---

## Required Fields

### `name` (string, required)
The action name visible to the LLM. **Choose carefully** - the LLM uses this to decide when to call the action.

```yaml
name: "OpenTrade"        # Clear: opens trade menu
name: "AccompanyTarget"  # Clear: start following
name: "CastHealingSpell" # Clear: cast a healing spell
```

**Tips for naming:**
- Use descriptive verb+noun format
- Avoid ambiguous names
- Consider how the LLM will interpret it

### `description` (string, required)
Detailed description for the LLM to understand when to use this action.

```yaml
description: "Use ONLY if {{ player.name }} asks to trade and you agree. Otherwise, do NOT use this action."
description: "Start following {{ player.name }} when explicitly requested to accompany them."
description: "Cast a healing spell on the target. Use when someone needs medical attention."
```

**Tips for descriptions:**
- Be explicit about when to use AND when NOT to use
- Use template variables like `{{ player.name }}`

**⚠️ DO NOT repeat eligibility conditions in the description!**

If you have eligibility rules that check game state (factions, globals, etc.), **do not mention those conditions in the description**. The action will only appear when eligibility passes, so the LLM doesn't need to know about those checks - they're already guaranteed to be true.

**BAD** - Repeats eligibility conditions unnecessarily:
```yaml
description: "Give {{ player.name }} a free item. Only available if {{ player.name }} is in the Companions faction OR has high reputation. You MUST be a merchant to use this."
eligibilityRules:
  - conditions: [...check if merchant...]
  - conditions: [...check faction OR reputation...]
```

**GOOD** - Describes behavior, not eligibility:
```yaml
description: "Give {{ player.name }} a free item as a gesture of goodwill. Use when you want to reward {{ player.name }} for their help."
eligibilityRules:
  - conditions: [...check if merchant...]
  - conditions: [...check faction OR reputation...]
```

The eligibility rules handle the "when can this happen" logic. The description should focus on "what does this do" and "when should the LLM choose to use it" (from a roleplay/narrative perspective).

### `questEditorId` (string, required)
The editor ID of the quest containing the target script.

To find this:
1. Use the MCP server: `mcp_skyrimnet-mcp_get_quests` with `name_contains` filter
2. Examine the mod's ESP/ESM in xEdit
3. Check the mod's documentation

```yaml
questEditorId: "DialogueGeneric"
questEditorId: "MyModMainQuest"
questEditorId: "SkyrimNetQuest"
```

### `scriptName` (string, required)
The name of the Papyrus script bound to the quest.

```yaml
scriptName: "DialogueGenericScript"
scriptName: "MyModMainScript"
scriptName: "SkyrimNetInternal"
```

### `executionFunctionName` (string, required)
The function to call when the action executes.

The function should have one of these signatures:
```papyrus
; With actor and params
Function MyAction(Actor akActor, string paramsJson)

; Just actor
Function MyAction(Actor akActor)

; Global function
Function MyAction(Actor akActor, string paramsJson) Global
```

```yaml
executionFunctionName: "OpenTrade_Execute"
executionFunctionName: "StartFollow_Execute"
executionFunctionName: "CastSpell_Execute"
```

---

## Parameter Mapping

Parameters are passed positionally to the Papyrus function. Define each parameter in order.

### Parameter Types

#### `static` - Fixed value
Value is set at configuration time, not changeable by the LLM.

```yaml
parameterMapping:
  - type: "static"
    value: "100"           # String value
  - type: "static"
    value: 5               # Integer value
  - type: "static"
    value: true            # Boolean value
```

#### `dynamic` - LLM-provided value
The LLM provides this value at runtime based on context.

```yaml
parameterMapping:
  - type: "dynamic"
    name: "target"
    description: "The actor to target with this action"
  - type: "dynamic"
    name: "amount"
    description: "Amount of gold to give (1-1000)"
  - type: "dynamic"
    name: "spell_id"
    description: "Form ID of the spell to cast"
```

**Parameter Schema for LLM:**
The parameter schema shown to the LLM is built from dynamic parameters:
```yaml
# These dynamic params become this schema for the LLM:
# {"target": "Actor", "amount": "Int"}
```

#### `speaker` - Automatic speaker reference
Automatically filled with the actor who triggered the action (the speaker).

```yaml
parameterMapping:
  - type: "speaker"    # No value needed, auto-filled
```

### Complex Parameter Example

```yaml
# For a function: CastSpell_Execute(Actor akSource, Actor akTarget, String sFormID)
parameterMapping:
  - type: "speaker"              # Position 0: akSource = speaking actor
  - type: "dynamic"              # Position 1: akTarget = LLM chooses target
    name: "target"
    description: "Target actor for the spell"
  - type: "dynamic"              # Position 2: sFormID = LLM chooses spell
    name: "spell_id"
    description: "Form ID of spell to cast (hex string like '0x0004D3F2')"
```

---

## Eligibility Rules

Eligibility rules determine when an action is available. They use **decorators** - functions that query game state.

### Critical: Understanding How Rules Work

**Rules with `required: true`** are evaluated. **Rules with `required: false` are IGNORED entirely** - they have no effect on eligibility.

**The `logicalOperator`** (`AND`/`OR`) combines **conditions within a single rule**, NOT between rules. Multiple required rules are always AND'd together.

### Rule Evaluation Logic

```
Final Eligibility = (Rule1 passes) AND (Rule2 passes) AND (Rule3 passes) ...

Where each rule's result = condition1 [logicalOperator] condition2 [logicalOperator] ...
```

**Example**: To express "A AND (B OR C)", you need TWO rules:
- Rule 1: Condition A (required: true, logicalOperator: AND)
- Rule 2: Condition B, Condition C (required: true, logicalOperator: OR)

### Rule Structure

```yaml
eligibilityRules:
  - conditions:
      - decoratorName: "is_in_faction"
        arguments: ["currentActor", "JobMerchantFaction"]    # Actor reference + faction editor ID
        comparisonOperator: "=="
        expectedValue: true
      - decoratorName: "get_actor_value"
        arguments: ["currentActor", "Health"]
        comparisonOperator: ">"
        expectedValue: 50
    logicalOperator: "AND"     # AND or OR - combines CONDITIONS within this rule
    required: true             # MUST be true for the rule to be evaluated!
```

### ⚠️ COMMON MISTAKE: Incorrect OR Logic

**WRONG** - These `required: false` rules are completely ignored:
```yaml
eligibilityRules:
  - conditions:
      - decoratorName: "is_in_faction"
        arguments: ["currentActor", "JobMerchantFaction"]
        ...
    required: true      # ✓ This is checked
  - conditions:
      - decoratorName: "check_condition_B"
        ...
    logicalOperator: "OR"
    required: false     # ✗ IGNORED! This rule is never evaluated!
  - conditions:
      - decoratorName: "check_condition_C"
        ...
    logicalOperator: "OR"
    required: false     # ✗ IGNORED! This rule is never evaluated!
```

**CORRECT** - Put OR conditions in ONE rule with `required: true`:
```yaml
eligibilityRules:
  - conditions:
      - decoratorName: "is_in_faction"
        arguments: ["currentActor", "JobMerchantFaction"]
        ...
    logicalOperator: "AND"
    required: true      # ✓ Checked: must be in faction
  - conditions:
      - decoratorName: "check_condition_B"
        ...
      - decoratorName: "check_condition_C"
        ...
    logicalOperator: "OR"   # ← Combines B and C with OR
    required: true          # ✓ Checked: B OR C must be true
```

### Actor Reference Values

**IMPORTANT**: When a decorator requires an actor reference, you must use one of these special values:

| Value | Description |
|-------|-------------|
| `currentActor` | The NPC being evaluated for eligibility (the potential action performer) |
| `player` | The player character |

Do NOT use `actor.UUID` or other variable formats - the system parses `currentActor` and `player` as special tokens.

### Available Decorators for Eligibility

Use `mcp_skyrimnet-mcp_get_decorators` to get the full list. Common decorators:

| Decorator | Arguments | Returns | Description |
|-----------|-----------|---------|-------------|
| `is_in_faction` | `currentActor` or `player`, `factionEditorID` | boolean | Check faction membership |
| `get_actor_value` | `currentActor` or `player`, `avName` | number | Get actor value (Health, Magicka, etc.) |
| `is_following_player` | `currentActor` or `player` | boolean | Check if following player |
| `is_in_combat` | `currentActor` or `player` | boolean | Check combat state |
| `get_distance_to_player` | `currentActor` or `player` | number | Distance to player |
| `has_keyword` | `currentActor` or `player`, `keywordEditorID` | boolean | Check for keyword |
| `is_dead` | `currentActor` or `player` | boolean | Check if dead |
| `is_essential` | `currentActor` or `player` | boolean | Check if essential NPC |

### Comparison Operators

| Operator | Description |
|----------|-------------|
| `==` | Equal to |
| `!=` | Not equal to |
| `>` | Greater than |
| `<` | Less than |
| `>=` | Greater than or equal |
| `<=` | Less than or equal |
| `contains` | String contains |
| `not_contains` | String does not contain |

### Eligibility Examples

**Example 1: Simple AND (multiple required rules)**
```yaml
eligibilityRules:
  # Rule 1: Must be a merchant
  - conditions:
      - decoratorName: "is_in_faction"
        arguments: ["currentActor", "JobMerchantFaction"]
        comparisonOperator: "=="
        expectedValue: true
    logicalOperator: "AND"
    required: true
  
  # Rule 2: Must not be in combat
  - conditions:
      - decoratorName: "is_in_combat"
        arguments: ["currentActor"]
        comparisonOperator: "=="
        expectedValue: false
    logicalOperator: "AND"
    required: true
# Result: (is merchant) AND (not in combat)
```

**Example 2: AND with OR (A AND (B OR C))**
```yaml
eligibilityRules:
  # Rule 1: Must be in the Companions faction (required)
  - conditions:
      - decoratorName: "is_in_faction"
        arguments: ["currentActor", "CompanionsFaction"]
        comparisonOperator: "=="
        expectedValue: true
    logicalOperator: "AND"
    required: true
  
  # Rule 2: Either player is a friend OR has high speechcraft (both conditions in ONE rule)
  - conditions:
      - decoratorName: "get_relationship_rank"
        arguments: ["currentActor", "player"]
        comparisonOperator: ">="
        expectedValue: 1
      - decoratorName: "get_actor_value"
        arguments: ["player", "Speech"]
        comparisonOperator: ">="
        expectedValue: 50
    logicalOperator: "OR"     # ← This joins the TWO conditions above
    required: true            # ← MUST be true to be evaluated!
# Result: (is Companion) AND ((player is friend) OR (player has high speech))
```

**Example 3: Complex OR with multiple conditions**
```yaml
eligibilityRules:
  # Must meet at least ONE of these three conditions
  - conditions:
      - decoratorName: "is_in_faction"
        arguments: ["player", "FactionA"]
        comparisonOperator: "=="
        expectedValue: true
      - decoratorName: "is_in_faction"
        arguments: ["player", "FactionB"]
        comparisonOperator: "=="
        expectedValue: true
      - decoratorName: "get_global_value"
        arguments: ["SomeGlobal"]
        comparisonOperator: "<="
        expectedValue: 5
    logicalOperator: "OR"
    required: true
# Result: (in FactionA) OR (in FactionB) OR (SomeGlobal <= 5)
```

---

## Tags

Tags provide reusable eligibility groupings. When a tag is assigned to an action, the tag's eligibility function is checked.

```yaml
tags:
  - "follower"    # Only available to followers
  - "merchant"    # Only available to merchants
```

Tags are registered via Papyrus:
```papyrus
SkyrimNetApi.RegisterTag("follower", "SkyrimNetInternal", "Follower_IsEligible")
```

---

## Event Registration (Optional)

When an action executes, it can register an event for context/history.

```yaml
eventString: "{{ actor.name }} began following {{ player.name }}"
isShortLived: false    # false = persistent, true = ephemeral
```

- **Persistent events** (`isShortLived: false`) are stored in the database and appear in event history
- **Short-lived events** (`isShortLived: true`) appear temporarily in scene context but don't persist

### Available Template Variables for eventString

The eventString uses the full SkyrimNet template language. The following variables are available:

| Variable | Description |
|----------|-------------|
| `{{ actor.name }}` | Name of the NPC performing the action |
| `{{ actor.UUID }}` | UUID of the actor (use with `decnpc()` for full info) |
| `{{ player.name }}` | Player character's name |
| `{{ player.UUID }}` | Player's UUID (use with `decnpc()` for full info) |
| `{{ action_name }}` | Name of the action |
| `{{ <dynamic_param> }}` | Any dynamic parameter by name (e.g., `{{ amount }}`) |

**For pronouns and detailed actor info, use the `decnpc()` decorator:**

| Expression | Description |
|------------|-------------|
| `{{ decnpc(actor.UUID).possessivePronoun }}` | Actor's possessive pronoun (his/her/their) |
| `{{ decnpc(actor.UUID).subjectivePronoun }}` | Actor's subjective pronoun (he/she/they) |
| `{{ decnpc(actor.UUID).objectivePronoun }}` | Actor's objective pronoun (him/her/them) |
| `{{ decnpc(player.UUID).possessivePronoun }}` | Player's possessive pronoun |
| `{{ decnpc(player.UUID).subjectivePronoun }}` | Player's subjective pronoun |

**Examples:**
```yaml
# Simple - just names
eventString: "{{ actor.name }} began following {{ player.name }}."

# With pronouns using decnpc()
eventString: "{{ actor.name }} shared {{ decnpc(actor.UUID).possessivePronoun }} knowledge of alchemy with {{ player.name }}."

# With dynamic parameters
eventString: "{{ actor.name }} gave {{ amount }} gold to {{ player.name }} as payment."
```

---

## Full Action File Examples

### Example 1: Open Trade Action

```yaml
name: "OpenTrade"
description: "Use ONLY if {{ player.name }} asks to trade and you agree to trade. Otherwise, you MUST NOT use this action."

questEditorId: "SkyrimNetQuest"
scriptName: "SkyrimNetInternal"
executionFunctionName: "OpenTrade_Execute"

parameterMapping: []  # No parameters needed

eligibilityRules:
  - conditions:
      - decoratorName: "is_in_faction"
        arguments: ["currentActor", "JobMerchantFaction"]  # Faction editor ID
        comparisonOperator: "!="
        expectedValue: -2  # Not expelled from faction
    logicalOperator: "AND"
    required: true

tags: []
enabled: true
defaultPriority: 5
```

### Example 2: Follow Player Action

```yaml
name: "AccompanyTarget"
description: "Start accompanying {{ player.name }}. Only use this when you are sure that you want to stop what you're doing and follow {{ player.name }} to another location, and {{ player.name }} has specifically requested it."

questEditorId: "SkyrimNetQuest"
scriptName: "SkyrimNetInternal"
executionFunctionName: "StartFollow_Execute"

parameterMapping: []

eligibilityRules:
  - conditions:
      - decoratorName: "is_following_player"
        arguments: ["currentActor"]
        comparisonOperator: "=="
        expectedValue: false
    logicalOperator: "AND"
    required: true

eventString: "{{ actor.name }} began following {{ player.name }}"
isShortLived: false

enabled: true
defaultPriority: 5
```

### Example 3: Gesture Action with Dynamic Parameter

```yaml
name: "Gesture"
description: "Perform a gesture to emphasize your words."

questEditorId: "SkyrimNetQuest"
scriptName: "SkyrimNetInternal"
executionFunctionName: "AnimationGeneric"

parameterMapping:
  - type: "dynamic"
    name: "anim"
    description: "Animation to play: applaud|applaud_sarcastic|drink|drink_potion|eat|laugh|nervous|read_note|pray|salute|study|wave|wipe_brow"

eligibilityRules: []  # No special eligibility

tags: []
enabled: true
defaultPriority: 1
```

### Example 4: Rent Room with Price Parameter

```yaml
name: "RentRoom"
description: "Rent a room out to {{ player.name }} for an amount of gold, but only if they agreed to the price beforehand"

questEditorId: "DialogueGeneric"
scriptName: "DialogueGenericScript"
executionFunctionName: "RentRoom_Execute"

parameterMapping:
  - type: "dynamic"
    name: "price"
    description: "The price in gold for the room"

eligibilityRules:
  - conditions:
      - decoratorName: "is_in_faction"
        arguments: ["currentActor", "RentRoomFaction"]  # Faction editor ID
        comparisonOperator: "=="
        expectedValue: true
    logicalOperator: "AND"
    required: true

enabled: true
defaultPriority: 5
```

### Example 5: Cast Spell with Multiple Parameters

```yaml
name: "CastHealingSpell"
description: "Cast a healing spell on a wounded ally"

questEditorId: "SkyrimNetQuest"
scriptName: "skynet_Library"
executionFunctionName: "CastSpell_Execute"

parameterMapping:
  - type: "speaker"                    # Source actor
  - type: "dynamic"
    name: "target"
    description: "The actor to heal"
  - type: "static"
    value: "0x0004D3F2"               # Fast Healing spell form ID

eligibilityRules:
  - conditions:
      - decoratorName: "get_actor_value"
        arguments: ["currentActor", "Restoration"]
        comparisonOperator: ">"
        expectedValue: 25
    logicalOperator: "AND"
    required: true

eventString: "{{ actor.name }} cast a healing spell on {{ target.name }}"
isShortLived: true

enabled: true
defaultPriority: 5
```

---

## Understanding Mod Code for Action Creation

### Using MCP Tools to Explore Mods

The MCP server provides **direct access to runtime script data**. You don't need to manually examine source files - the tools reveal everything you need.

### 1. Identify the Quest and Script

**Use the MCP tools:**
```
# Find quests from a specific mod
get_quests: { "plugin": "SomeModName.esp" }

# Or search by name
get_quests: { "name_contains": "Companion" }
```

Then get the scripts attached to that quest:
```
get_quest_scripts: { "quest_editor_id": "FoundQuestEditorID" }
```

### 2. Find Available Functions

**Use `get_quest_script_functions` to get the complete function list:**
```
get_quest_script_functions: { 
  "quest_editor_id": "MyModQuest", 
  "script_name": "MyModScript" 
}
```

This returns the **exact function signatures** including:
- Function name
- Return type  
- All parameters with their types
- Docstrings (if the mod author included them)

**Example response:**
```json
{
  "functions": [
    {
      "name": "StartDialogue",
      "type": "member",
      "returnType": "None",
      "parameters": [
        { "name": "akTarget", "type": "Actor" },
        { "name": "sTopicID", "type": "String" }
      ],
      "docString": "Initiates dialogue with target actor"
    },
    {
      "name": "GiveReward",
      "type": "member", 
      "returnType": "None",
      "parameters": [
        { "name": "akActor", "type": "Actor" },
        { "name": "iGoldAmount", "type": "Int" }
      ]
    }
  ]
}
```

**Selecting Functions - Important Guidelines:**

✅ **PREFER** functions that:
- Have clear, action-oriented names (StartFollowing, GiveItem, CastSpell)
- Accept Actor parameters
- Perform visible game actions
- Have simple parameter lists

❌ **AVOID** functions that:
- Modify internal mod state (SetState, UpdateProgress, IncrementCounter)
- Change quest stages (SetStage, CompleteObjective)
- Are clearly internal helpers (Internal_, Private_, _Update)
- Have complex object parameters you can't construct

### 3. Understand Function Parameters

The `get_quest_script_functions` response tells you exactly what parameters each function needs.

**Map Papyrus types to parameter mappings:**

| Papyrus Type | Parameter Mapping |
|--------------|-------------------|
| `Actor` | `type: "speaker"` or `type: "dynamic"` (LLM provides UUID) |
| `Int` | `type: "static"` (fixed) or `type: "dynamic"` (LLM provides) |
| `Float` | `type: "static"` or `type: "dynamic"` |
| `Bool` | `type: "static"` or `type: "dynamic"` |
| `String` | `type: "static"` or `type: "dynamic"` |
| `Form` | `type: "static"` with form ID string |

### 4. Check Runtime State (Optional)

Use `get_quest_script_properties` to see what properties the script maintains:
```
get_quest_script_properties: {
  "quest_editor_id": "MyModQuest",
  "script_name": "MyModScript"
}
```

And `get_quest_property_value` to read specific values:
```
get_quest_property_value: {
  "quest_editor_id": "MyModQuest",
  "script_name": "MyModScript",
  "property_name": "IsFeatureEnabled"
}
```

This can help you understand when certain actions make sense.

### 5. Identify Eligibility Requirements

Think about what game state conditions make sense:
- Does the actor need to be in a specific faction?
- Should the actor not be in combat?
- Does the actor need certain skills or abilities?
- Are there location or distance requirements?

**Use `get_decorators` to find available condition-checking functions:**
```
get_decorators: { "category": "Actor" }
get_decorators: { "name_contains": "faction" }
```

Convert your eligibility logic into `eligibilityRules` using the decorator-based system.

---

## Complete Example: Creating an Action Using MCP Tools

Here's a full walkthrough of creating an action for a hypothetical mod.

### Step 1: Find the Quest
```
Tool: get_quests
Params: { "plugin": "CoolFollowerMod.esp" }
Response: 
{
  "results": [
    { "editorID": "CoolFollowerMainQuest", "formID": "0x00000800", "name": "Cool Follower System" }
  ]
}
```

### Step 2: Get Scripts
```
Tool: get_quest_scripts
Params: { "quest_editor_id": "CoolFollowerMainQuest" }
Response:
{
  "scripts": [
    { "scriptName": "CoolFollowerScript", "type": "bound_script" }
  ]
}
```

### Step 3: Explore Functions
```
Tool: get_quest_script_functions
Params: { "quest_editor_id": "CoolFollowerMainQuest", "script_name": "CoolFollowerScript" }
Response:
{
  "functions": [
    {
      "name": "CommandAttack",
      "returnType": "None",
      "parameters": [
        { "name": "akFollower", "type": "Actor" },
        { "name": "akTarget", "type": "Actor" }
      ]
    },
    {
      "name": "SetCombatStyle",
      "returnType": "None", 
      "parameters": [
        { "name": "akFollower", "type": "Actor" },
        { "name": "sStyle", "type": "String" }
      ],
      "docString": "Sets combat style: 'aggressive', 'defensive', 'ranged'"
    }
  ]
}
```

### Step 4: Find Eligibility Decorators
```
Tool: get_decorators
Params: { "name_contains": "following" }
Response:
{
  "results": [
    {
      "name": "is_following_player",
      "category": "Actor",
      "arguments": [{ "name": "actor", "type": "Actor" }],
      "returnType": "bool"
    }
  ]
}
```

### Step 5: Create the Action File

Based on the discovered data, create `SetFollowerCombatStyle.yaml`:

```yaml
name: "SetFollowerCombatStyle"
description: "Change your follower's combat style. Use when {{ player.name }} requests a change in how you fight - 'aggressive' for melee focus, 'defensive' for blocking/evasion, or 'ranged' for bow/magic preference."

questEditorId: "CoolFollowerMainQuest"
scriptName: "CoolFollowerScript"
executionFunctionName: "SetCombatStyle"

parameterMapping:
  - type: "speaker"                    # akFollower - the NPC speaking
  - type: "dynamic"                    # sStyle - LLM chooses based on conversation
    name: "style"
    description: "Combat style: 'aggressive', 'defensive', or 'ranged'"

eligibilityRules:
  - conditions:
      - decoratorName: "is_following_player"
        arguments: ["currentActor"]
        comparisonOperator: "=="
        expectedValue: true
    logicalOperator: "AND"
    required: true

eventString: "{{ actor.name }} changed their combat style"
isShortLived: true

enabled: true
defaultPriority: 5
```

---

## Best Practices

1. **Thoroughly examine the mod's code** before creating actions

2. **Test eligibility carefully** - incorrect eligibility means the action appears when it shouldn't

3. **Write clear descriptions** that help the LLM understand when to use the action

4. **Use appropriate priorities** - more specific actions should have higher priority

5. **Consider edge cases** in eligibility rules (combat, death, faction membership)

6. **Document parameters clearly** so the LLM provides correct values

7. **Start with enabled: false** for testing, then enable once verified

8. **Use event strings** to track when actions are used

9. **Check for conflicting actions** that might both match the same scenario

10. **Use tags** for common eligibility patterns (follower, merchant, etc.)

---

## Papyrus Integration Reference

### Registering Actions via Papyrus

Actions can also be registered via Papyrus at runtime (note: YAML files with decorator-based eligibility are preferred for new actions):

```papyrus
SkyrimNetApi.RegisterAction( \
    "ActionName",                           ; Action name
    "Description for the LLM",              ; Description
    "EligibilityScriptName",                ; Script with IsEligible function
    "IsEligible_Function",                  ; Eligibility check function
    "ExecutionScriptName",                  ; Script with Execute function
    "Execute_Function",                     ; Execution function
    "",                                     ; Triggering event types (CSV, deprecated)
    "PAPYRUS",                              ; Category
    5,                                      ; Priority
    "{\"param\": \"Type\"}",                ; Parameter schema JSON
    "",                                     ; Custom category (optional)
    "tag1,tag2"                             ; Tags (CSV)
)
```

### Execution Function Signatures

```papyrus
; Without parameters
Function MyAction_Execute(Actor akActor)

; With parameters
Function MyAction_Execute(Actor akActor, string paramsJson)
    Int amount = SkyrimNetApi.GetJsonInt(paramsJson, "amount", 0)
    Actor target = SkyrimNetApi.GetJsonActor(paramsJson, "target", None)
EndFunction
```

---

## Debugging Tips

### Verifying Quest/Script/Function Names
- Use `get_quest_scripts` to confirm the exact script name (case-sensitive!)
- Use `get_quest_script_functions` to verify function names and signatures
- Use `get_quest_property_value` to test if the quest is accessible at runtime

### Testing Actions
- Start with `enabled: false` until you've verified the configuration
- Use `execute_quest_function` MCP tool to test function calls directly (be careful!)
- Check SkyrimNet logs for action loading errors
- Use the web UI to see which actions are available for specific NPCs

### Eligibility Issues
- Use `get_decorators` to verify decorator availability and correct argument types
- Test eligibility with no rules first (`eligibilityRules: []`), then add conditions one by one
- Remember: `currentActor` and `player` are the only valid actor reference tokens

### Common Mistakes
- **Wrong case**: Script and function names are case-sensitive
- **Missing parameters**: The parameter count must match exactly
- **Wrong decorator arguments**: Actor decorators need `currentActor` or `player`, not UUIDs
- **Forgetting positional order**: Parameters are positional, not named

---

## MCP Tools Quick Reference

### Quest & Script Discovery
| Tool | Required Params | Description |
|------|-----------------|-------------|
| `get_quests` | (optional) `plugin`, `name_contains`, `limit`, `offset` | Find quests |
| `get_quest_scripts` | `quest_editor_id` | Get scripts bound to a quest |
| `get_quest_script_functions` | `quest_editor_id`, `script_name` | Get callable functions with signatures |
| `get_quest_script_properties` | `quest_editor_id`, `script_name` | Get script properties and variables |
| `get_quest_property_value` | `quest_editor_id`, `script_name`, `property_name` | Read a specific property value |
| `execute_quest_function` | `quest_editor_id`, `script_name`, `function_name`, (optional) `arguments` | Execute a function (use carefully!) |

### Game Data
| Tool | Required Params | Description |
|------|-----------------|-------------|
| `get_decorators` | (optional) `category`, `name_contains` | Find eligibility decorator functions |
| `get_factions` | (optional) `plugin`, `name_contains` | Find faction editor IDs |
| `get_keywords` | (optional) `plugin`, `name_contains` | Find keyword editor IDs |
| `get_globals` | (optional) `plugin`, `name_contains` | Find global variables |
| `get_spells` | (optional) `plugin`, `name_contains` | Find spells |
| `get_items` | (optional) `plugin`, `name_contains` | Find items |

