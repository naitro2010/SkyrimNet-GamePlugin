# SkyrimNet Prompt Creation Workflow

> **Purpose:** This is an interactive workflow for AI assistants to help users create or modify prompt templates that control how AI generates dialogue, thoughts, and other content.

## What Are Prompts?

Prompts are `.prompt` files that:
- Define instructions sent to AI language models
- Use Inja template syntax (similar to Jinja2) for dynamic content
- Can access game state via decorator functions
- Are organized into main prompts and submodule components

**Key directories:**
- `prompts/` - Main prompt files (dialogue_response, player_thoughts, etc.)
- `prompts/submodules/character_bio/` - Character biography components
- `prompts/submodules/system_head/` - System prompt components
- `prompts/submodules/guidelines/` - Roleplay guidelines
- `prompts/submodules/user_final_instructions/` - Final user instructions
- `prompts/components/` - Reusable component templates

---

## PHASE 1: Discovery - Understanding the Goal

### Step 1.1: Clarify What's Needed

**ASK THE USER:**
- "What do you want to achieve?" (modify NPC behavior, add mod awareness, change dialogue style?)
- "Is this for a specific mod integration or general prompt modification?"
- "Should this affect all NPCs, specific types, or only certain conditions?"
- "Do you have the mod's source code in the workspace?" (if mod-related)

### Step 1.2: Check Source Code (if mod-related)

**If this prompt is for a specific mod and source is available:**
- Read Papyrus scripts to understand what state the mod tracks
- Identify factions, globals, magic effects used for state
- Understand when states change and what they represent

> **⚠️ CRITICAL:** Source code helps you *understand* what the mod tracks, but **MCP tools are the source of truth** for editor IDs and current state. Always verify effect names, faction IDs, and global names via MCP.

### Step 1.3: Determine Prompt Type

| Goal | Prompt Location | Type |
|------|-----------------|------|
| Add mod status to character bio | `submodules/character_bio/` | Submodule |
| Change how NPCs speak | `submodules/guidelines/` or main prompts | Submodule or Main |
| Add conditional instructions | `submodules/user_final_instructions/` | Submodule |
| Create entirely new feature | Main `prompts/` directory | Main prompt |
| Modify system setup | `submodules/system_head/` | Submodule |

### Step 1.4: Explore Existing Prompts

**If modifying existing behavior:**
- Read the relevant prompt files to understand current structure
- Identify where changes should be made
- Look for existing patterns to follow

---

## PHASE 2: Decorator Discovery - Finding Available Functions

### Step 2.1: Query Available Decorators via MCP (CRITICAL - Source of Truth)

**Decorators are functions that fetch game data for use in prompts.**

```
mcp_skyrimnet-mcp_get_decorators
```

Filter by category:
```
mcp_skyrimnet-mcp_get_decorators:
  category: "Actor"
```

Search by name:
```
mcp_skyrimnet-mcp_get_decorators:
  name_contains: "faction"
```

### Step 2.2: Key Decorator Categories

| Category | Examples | Use For |
|----------|----------|---------|
| `Actor` | `decnpc()`, `is_in_combat()`, `get_actor_value()` | NPC/player info |
| `Player` | `get_player_name()`, `player_is_vampire()` | Player-specific data |
| `Quest` | `get_quest_name()`, `is_quest_active()` | Quest state |
| `Combat` | `is_in_combat()`, `get_combat_target()` | Combat info |
| `Environment` | `get_current_location()`, `get_weather_description()` | World state |
| `Time` | `get_time_of_day()`, `get_current_date()` | Time info |
| `Faction` | `is_in_faction()`, `get_faction_rank()` | Faction checks |
| `Relationship` | `get_relationship_rank()` | NPC relationships |
| `Global` | `get_global_value()` | Mod global variables |

### Step 2.3: The Core `decnpc()` Decorator

**Most important decorator - returns comprehensive NPC data:**

```
{% set npc_data = decnpc(actorUUID) %}

{{ npc_data.name }}              {# Display name #}
{{ npc_data.race }}              {# Race name #}
{{ npc_data.gender }}            {# "Male" or "Female" #}
{{ npc_data.class }}             {# Class name #}
{{ npc_data.level }}             {# Level #}

{# Stats #}
{{ npc_data.health }}
{{ npc_data.magicka }}
{{ npc_data.stamina }}

{# Skills (0-100) #}
{{ npc_data.oneHanded }}
{{ npc_data.destruction }}
{{ npc_data.speech }}
... (all skills available)

{# Profile data #}
{{ npc_data.summary }}
{{ npc_data.background }}
{{ npc_data.personality }}
{{ npc_data.speechStyle }}

{# Pronouns #}
{{ npc_data.subjectivePronoun }}   {# he/she/they #}
{{ npc_data.objectivePronoun }}    {# him/her/them #}
{{ npc_data.possessivePronoun }}   {# his/her/their #}
{{ npc_data.reflexivePronoun }}    {# himself/herself/themselves #}

{# Relationship #}
{{ npc_data.relationshipRank }}    {# -4 to 4 #}
```

---

## PHASE 3: Template Syntax Reference

### Step 3.1: Inja Basics

**Expressions (render values):**
```
{{ variable }}
{{ decorator_function(arg) }}
{{ npc.name }}
```

**Statements (control flow):**
```
{% if condition %}
  content
{% elif other_condition %}
  alternative
{% else %}
  default
{% endif %}

{% for item in list %}
  {{ item }}
{% endfor %}

{% set variable = value %}
```

**Comments:**
```
{# This is ignored in output #}
```

### Step 3.2: Conditionals

```
{% if is_in_combat(actorUUID) %}
Combat content
{% elif get_actor_value(actorUUID, "Health") < 50 %}
Low health content
{% else %}
Normal content
{% endif %}
```

**Operators:**
- Logical: `and`, `or`, `not`
- Comparison: `<`, `>`, `==`, `!=`, `>=`, `<=`
- Membership: `value in list`

### Step 3.3: Loops

```
{% for nearby in get_nearby_npc_list(npc.UUID) %}
- {{ decnpc(nearby.UUID).name }} ({{ nearby.distance }}m away)
{% endfor %}
```

**Loop variables:**
- `loop.index` - 0-based index
- `loop.index1` - 1-based index
- `loop.is_first` - True on first iteration
- `loop.is_last` - True on last iteration

### Step 3.4: Variable Assignment

```
{% set actor = decnpc(actorUUID) %}
{% set is_hostile = is_in_combat(actorUUID) %}
{% set health_percent = get_actor_value(actorUUID, "Health") %}
```

### Step 3.5: Built-in Functions

| Function | Description |
|----------|-------------|
| `upper(str)` / `lower(str)` | Convert case |
| `length(arr)` | Count elements |
| `first(arr)` / `last(arr)` | First/last element |
| `join(arr, sep)` | Join with separator |
| `round(num, digits)` | Round number |
| `default(val, fallback)` | Use fallback if undefined |
| `exists("key")` | Check if key exists |
| `contains(str, substr)` | Check substring |
| `replace(str, old, new)` | Replace text |

### Step 3.6: Whitespace Control

```
{{- variable -}}      {# Trim both sides #}
{% if x -%}           {# Trim after #}
{%- endif %}          {# Trim before #}
```

---

## PHASE 4: Prompt Structure Patterns

### Step 4.1: Chat-Style Prompts (Main Prompts)

```
[ system ]
System instructions here.
{{ render_subcomponent("system_head", "full") }}
[ end system ]

{{ render_template("components\\event_history") }}

[ user ]
User/context information here.
{{ render_subcomponent("user_final_instructions", "full") }}
[ end user ]
```

### Step 4.2: Submodule Prompts (Character Bio, etc.)

```
{# Comment explaining what this submodule does #}

{# Check if this should render (mod installed, condition met, etc.) #}
{% if some_condition %}

{% set actor = decnpc(actorUUID) %}
{% set first_person = (render_mode == "full" or render_mode == "thoughts") %}

## Section Header

{% if first_person %}
Content written for first-person context...
{% else %}
Content written for third-person context...
{% endif %}

{% endif %}
```

### Step 4.3: Rendering Other Templates

```
{# Render a template file #}
{{ render_template("components\\event_history") }}

{# Render character profile in specific mode #}
{{ render_character_profile("full", npc.UUID) }}
{{ render_character_profile("short_inline", npc.UUID) }}

{# Render submodules #}
{{ render_subcomponent("system_head", "full") }}
{{ render_subcomponent("character_bio", "thoughts") }}
```

### Step 4.4: Render Modes

**Submodules receive a `render_mode` variable:**

| Mode | Use For |
|------|---------|
| `full` | Complete character information |
| `short_inline` | Brief inline summary |
| `interject_inline` | For NPC interjections |
| `dialogue_target` | When NPC is dialogue target |
| `thoughts` | For thought generation |
| `transform` | First-person transformation |

---

## PHASE 5: Creating Mod Integration Submodules

### Step 5.1: File Naming Convention

For character bio submodules:
```
prompts/submodules/character_bio/NNNN_description.prompt
```

- Numbers control load order (lower = earlier in bio)
- Use `0xxx` for core info, `03xx-04xx` for mod integrations

### Step 5.2: Standard Submodule Pattern

```
{# ModName - Brief description of what this adds #}
{# Only active when [conditions] #}

{# Determine render perspective #}
{% set first_person = (render_mode == "full" or render_mode == "thoughts" or render_mode == "transform") %}

{# Check if mod data is available (effect, faction, global, etc.) #}
{% set mod_active = has_magic_effect(actorUUID, "ModEffect") %}
{# OR #}
{% set mod_active = is_in_faction(actorUUID, "ModFaction") %}
{# OR #}
{% set mod_value = get_global_value("ModGlobal") %}
{% set mod_active = mod_value > 0 %}

{% if mod_active and first_person %}
{% set actor = decnpc(actorUUID) %}
{% set actorName = actor.name %}
{% set subj = actor.subjectivePronoun %}
{% set obj = actor.objectivePronoun %}
{% set poss = actor.possessivePronoun %}

## Mod Feature Status

{# Describe the mod's effect on this character #}
{{ actorName }} is affected by [mod feature].

{# Use conditionals for different states #}
{% if some_condition %}
Description of state 1...
{% else %}
Description of state 2...
{% endif %}

{% endif %}
```

### Step 5.3: Finding Mod Indicators via MCP (Source of Truth)

**Use MCP to find what the mod exposes (even if you have source code):**

Magic effects:
```
mcp_skyrimnet-mcp_get_magic_effects:
  plugin: "ModName.esp"
```

Factions:
```
mcp_skyrimnet-mcp_get_factions:
  plugin: "ModName.esp"
```

Global variables:
```
mcp_skyrimnet-mcp_get_globals:
  plugin: "ModName.esp"
```

Keywords:
```
mcp_skyrimnet-mcp_get_keywords:
  plugin: "ModName.esp"
```

### Step 5.4: Checking for Mod Data

**Common patterns for detecting mod state:**

```
{# Check magic effect #}
{% set has_effect = has_magic_effect(actorUUID, "EffectEditorID") %}

{# Check faction membership #}
{% set in_faction = is_in_faction(actorUUID, "FactionEditorID") %}

{# Check global variable #}
{% set global_val = get_global_value("GlobalEditorID") %}

{# Check keyword #}
{% set has_keyword = has_keyword(actorUUID, "KeywordEditorID") %}
```

---

## PHASE 6: Validation (REQUIRED)

### Step 6.1: Validate Template Syntax

**ALWAYS validate before finalizing:**

```
mcp_skyrimnet-mcp_validate_prompt:
  prompt_content: |
    {% set actor = decnpc(actorUUID) %}
    {{ actor.name }} content here...
```

**Check response:**
- `valid: true` → Proceed
- `valid: false` + `error` → Fix syntax error and re-validate

### Step 6.2: Common Validation Errors

| Error | Cause | Fix |
|-------|-------|-----|
| `Expected closing tag` | Missing `{% endif %}` or `{% endfor %}` | Add closing tag |
| `Unknown function` | Decorator name typo | Check `get_decorators` for correct name |
| `Variable not found` | Undefined variable | Define with `{% set %}` or check context |
| `Unexpected token` | Syntax error | Check brackets, quotes, operators |

### Step 6.3: Review with User

**PRESENT:**
- The complete prompt content
- What conditions trigger it
- What information it adds

**ASK:** "Does this prompt look correct? Would you like to adjust the wording or conditions?"

---

## Complete Examples

### Example: Bathing Mod Integration

```
{# Bathing in Skyrim - Tracks hygiene state #}

{% set first_person = (render_mode == "full" or render_mode == "thoughts") %}

{# Check for cleanliness effects #}
{% set is_clean = has_magic_effect(actorUUID, "mzinDirtinessTier0Effect") %}
{% set is_dirty = has_magic_effect(actorUUID, "mzinDirtinessTier2Effect") %}
{% set is_filthy = has_magic_effect(actorUUID, "mzinDirtinessTier3Effect") %}

{% set has_any_state = is_clean or is_dirty or is_filthy %}

{% if has_any_state and first_person %}
{% set actor = decnpc(actorUUID) %}
{% set subj = actor.subjectivePronoun %}
{% set poss = actor.possessivePronoun %}

## Hygiene

{% if is_clean %}
{{ actor.name }} feels refreshingly clean. {{ subj | capitalize }} skin is spotless.
{% elif is_dirty %}
{{ actor.name }} is noticeably dirty. {{ poss | capitalize }} clothes are grimy.
{% elif is_filthy %}
{{ actor.name }} is covered in filth, desperately needing a bath.
{% endif %}

{% endif %}
```

### Example: Conditional Instructions Submodule

```
{# Combat awareness - adds context during combat #}

{% if is_in_combat(npc.UUID) %}
## Combat Situation

You are currently in combat. Focus on:
- Survival and tactical decisions
- Brief, urgent responses
- Awareness of threats and allies

{% set target = get_combat_target(npc.UUID) %}
{% if target %}
Your current target: {{ target.name }}
{% endif %}
{% endif %}
```

### Example: Faction-Based Personality Modifier

```
{# Companions Guild personality traits #}

{% set is_companion = is_in_faction(actorUUID, "CompanionsFaction") %}

{% if is_companion %}
{% set actor = decnpc(actorUUID) %}
{% set rank = get_faction_rank(actorUUID, "CompanionsFaction") %}

## Companions Guild

{{ actor.name }} is a member of the Companions.

{% if rank >= 3 %}
As a senior member, {{ actor.subjectivePronoun }} carries the weight of leadership and tradition.
{% elif rank >= 1 %}
{{ actor.subjectivePronoun | capitalize }} has proven {{ actor.reflexivePronoun }} in battle.
{% else %}
{{ actor.subjectivePronoun | capitalize }} is still proving {{ actor.reflexivePronoun }} to the guild.
{% endif %}

{% endif %}
```

### Example: Global Variable-Based State

```
{# Survival Mode - cold exposure tracking #}

{% set cold_level = get_global_value("Survival_ColdLevel") %}
{% set first_person = (render_mode == "full" or render_mode == "thoughts") %}

{% if cold_level > 0 and first_person %}
{% set actor = decnpc(actorUUID) %}

## Environmental Exposure

{% if cold_level >= 3 %}
{{ actor.name }} is freezing, barely able to function in the bitter cold.
{% elif cold_level >= 2 %}
{{ actor.name }} shivers constantly, the cold seeping into {{ actor.possessivePronoun }} bones.
{% else %}
{{ actor.name }} feels the chill, but manages to stay functional.
{% endif %}

{% endif %}
```

---

## Context Variables Reference

**Variables available in prompts (depending on context):**

| Variable | Available In | Description |
|----------|--------------|-------------|
| `npc.UUID` | All NPC prompts | Speaking NPC's UUID |
| `npc.name` | All NPC prompts | Speaking NPC's name |
| `player.UUID` | All prompts | Player's UUID |
| `player.name` | All prompts | Player's name |
| `actorUUID` | Character bio submodules | Actor being described |
| `render_mode` | Submodules | Current render mode |
| `location` | Scene prompts | Current location |
| `time_of_day` | Scene prompts | Time description |
| `triggeringEvent` | Event-triggered prompts | Event that triggered |

---

## Workflow Checklist

- [ ] Clarified what the prompt should achieve
- [ ] Determined correct prompt location (main/submodule)
- [ ] **Queried `get_decorators` for available functions**
- [ ] If mod integration: found mod's effects/factions/globals
- [ ] Wrote template with proper conditionals
- [ ] Handled different render modes if needed
- [ ] **Validated with `validate_prompt`**
- [ ] Reviewed final content with user

