# LLM Instructions: Building SkyrimNet Prompt Files

This document provides comprehensive instructions for an LLM to create prompt files for the SkyrimNet mod system. Prompts define how AI models generate dialogue, thoughts, memories, and other content.

## Overview

Prompts are `.prompt` files stored in `SKSE/Plugins/SkyrimNet/prompts/`. They use **Inja template syntax** (similar to Jinja2) and define the instructions sent to AI language models.

**Key directories:**
- `prompts/` - Main prompt files for dialogue, thoughts, actions, etc.
- `prompts/submodules/character_bio/` - Character biography components
- `prompts/submodules/system_head/` - System prompt components
- `prompts/submodules/guidelines/` - Roleplay guidelines
- `prompts/submodules/user_final_instructions/` - Final user instructions
- `prompts/components/` - Reusable component templates
- `prompts/helpers/` - Helper prompts for specific tasks
- `prompts/memory/` - Memory-related prompts

## MCP Server for Game Data and Decorators

**IMPORTANT**: You have access to the SkyrimNet MCP server which exposes game data. The MCP server provides tools to query player info, nearby actors, quests, factions, items, spells, and more.

**Essential**: Use `mcp_skyrimnet-mcp_get_decorators` to discover all available template decorators - their arguments, return types, and descriptions. This is critical for building prompts that use game data.

Explore other `mcp_skyrimnet-mcp_*` tools to discover what game data you can query.

---

## Inja Template Syntax

### Expressions: `{{ ... }}`

Render variables and evaluate expressions:

```
{{ npc.name }}
{{ decnpc(npc.UUID).race }}
{{ player.name }}
{{ variable + 1 }}
```

### Control Flow: `{% ... %}`

#### Conditionals

```
{% if condition %}
  Content when true
{% else if other_condition %}
  Alternative content
{% else %}
  Default content
{% endif %}
```

**Operators:**
- Logical: `and`, `or`, `not`
- Comparison: `<`, `>`, `==`, `!=`, `>=`, `<=`
- Membership: `value in list`

#### Loops

```
{% for item in get_nearby_npc_list(npc.UUID) %}
  {{ item.name }}
{% endfor %}

{% for key, value in object %}
  {{ key }}: {{ value }}
{% endfor %}
```

**Loop variables:**
- `loop.index` - 0-based index
- `loop.index1` - 1-based index
- `loop.is_first` - True on first iteration
- `loop.is_last` - True on last iteration

#### Assignments

```
{% set variable = value %}
{% set npc_data = decnpc(actorUUID) %}
```

#### Includes

```
{% include "template_name" %}
{% include "components\\event_history" %}
```

### Comments: `{# ... #}`

```
{# This is a comment - ignored in output #}
```

### Whitespace Control

Use `-` to trim whitespace:

```
{{- variable -}}      {# Trim both sides #}
{% if x -%}           {# Trim after #}
{%- endif %}          {# Trim before #}
```

---

## Built-in Inja Functions

| Function | Description |
|----------|-------------|
| `upper(str)` / `lower(str)` | Convert case |
| `range(n)` | Generate 0 to n-1 |
| `at(arr, i)` | Index into array |
| `length(arr)` | Count elements |
| `first(arr)` / `last(arr)` | First/last element |
| `sort(arr)` | Sort values |
| `join(arr, sep)` | Join with separator |
| `round(num, digits)` | Round number |
| `odd(num)` / `even(num)` | Check parity |
| `max(arr)` / `min(arr)` | Find extremes |
| `int("2")` / `float("3.1")` | Convert types |
| `default(val, fallback)` | Use fallback if undefined |
| `exists("key")` | Check if key exists |
| `existsIn(obj, "key")` | Check if key exists in object |
| `isString(val)` / `isArray(val)` | Type checks |
| `contains(str, substr)` | Check if string contains substring |

---

## SkyrimNet Decorators

Decorators are custom functions that fetch game data. **Use `mcp_skyrimnet-mcp_get_decorators` to get the full list!**

### Core NPC Decorator: `decnpc(UUID)`

The most important decorator - returns comprehensive NPC data:

```
{% set npc_data = decnpc(actorUUID) %}

{{ npc_data.name }}              {# Display name #}
{{ npc_data.race }}              {# Race name #}
{{ npc_data.gender }}            {# "Male" or "Female" #}
{{ npc_data.class }}             {# Class name #}
{{ npc_data.level }}             {# Level #}

{# Actor values/stats #}
{{ npc_data.health }}
{{ npc_data.magicka }}
{{ npc_data.stamina }}

{# Skills (0-100) #}
{{ npc_data.oneHanded }}
{{ npc_data.twoHanded }}
{{ npc_data.archery }}
{{ npc_data.block }}
{{ npc_data.heavyArmor }}
{{ npc_data.lightArmor }}
{{ npc_data.sneak }}
{{ npc_data.lockpicking }}
{{ npc_data.pickpocket }}
{{ npc_data.speech }}
{{ npc_data.alchemy }}
{{ npc_data.smithing }}
{{ npc_data.enchanting }}
{{ npc_data.destruction }}
{{ npc_data.restoration }}
{{ npc_data.alteration }}
{{ npc_data.conjuration }}
{{ npc_data.illusion }}

{# Profile data #}
{{ npc_data.summary }}
{{ npc_data.background }}
{{ npc_data.personality }}
{{ npc_data.aspirations }}
{{ npc_data.speechStyle }}
{{ npc_data.appearance }}
{{ npc_data.currentStatus }}

{# Relationship #}
{{ npc_data.relationshipRank }}   {# -4 to 4 #}
```

### Common Decorator Categories

Use `mcp_skyrimnet-mcp_get_decorators` with `category` filter to explore:

| Category | Example Decorators |
|----------|-------------------|
| `Player` | `get_player_name()`, `player_is_vampire()`, `player_is_werewolf()` |
| `Quest` | `get_quest_name(questId)`, `is_quest_active(questId)`, `get_quest_stage(questId)` |
| `Combat` | `is_in_combat(UUID)`, `get_combat_target(UUID)` |
| `Environment` | `get_current_location()`, `get_weather_description()`, `is_interior()` |
| `Equipment` | `get_equipped_weapon(UUID)`, `get_equipped_armor(UUID)` |
| `Faction` | `is_in_faction(UUID, factionId)`, `get_faction_rank(UUID, factionId)` |
| `Time` | `get_time_of_day()`, `get_day_of_week()`, `get_current_date()` |
| `Relationship` | `get_relationship_rank(UUID1, UUID2)` |
| `Scene` | `get_nearby_npc_list(UUID)`, `get_nearby_actor_count(UUID)` |

### Rendering Templates

```
{# Render another template file #}
{{ render_template("components\\event_history") }}

{# Render a character profile in a specific mode #}
{{ render_character_profile("full", npc.UUID) }}
{{ render_character_profile("short_inline", npc.UUID) }}
{{ render_character_profile("interject_inline", npc.UUID) }}

{# Render submodules #}
{{ render_subcomponent("system_head", "full") }}
{{ render_subcomponent("character_bio", "full") }}
```

---

## Prompt File Structure

### Chat-Style Prompts

Most prompts use a chat format with `[ system ]`, `[ user ]`, and `[ assistant ]` blocks:

```
[ system ]
You are {{ decnpc(npc.UUID).name }}, a {{ decnpc(npc.UUID).gender }} {{ decnpc(npc.UUID).race }} in Skyrim.

## Character Information
{{ render_character_profile("full", npc.UUID) }}

## Guidelines
- Stay in character at all times
- Respond naturally to the situation
[ end system ]

[ user ]
## Current Scene
Location: {{ get_current_location() }}
Time: {{ get_time_of_day() }}

## Recent Events
{{ render_template("components\\event_history") }}

Respond in character now.
[ end user ]
```

### Non-Chat Prompts

Some prompts (like action selectors) use a simpler format:

```
[ system ]
## Task
Select an action for {{ npc.name }} based on the dialogue.

## Available Actions
{% for action in eligible_actions %}
- `{{ action.name }}` - {{ action.description }}
{% endfor %}

Output format: `ACTION: [Name]` or `ACTION: None`
[ end system ]

[ user ]
## Dialogue
"{{ dialogue_response }}"

Select the appropriate action.
[ end user ]
```

---

## Key Context Variables

Variables available in prompts (depending on context):

### NPC Context
```
{{ npc.name }}        {# Speaking NPC name #}
{{ npc.UUID }}        {# NPC entity UUID #}
```

### Player Context
```
{{ player.name }}     {# Player character name #}
{{ player.UUID }}     {# Player entity UUID #}
{{ player.race }}     {# Player race #}
{{ player.gender }}   {# Player gender #}
```

### Scene Context
```
{{ location }}        {# Current location name #}
{{ time_of_day }}     {# Time description #}
```

### Dialogue Context
```
{{ dialogue_request }}    {# What triggered the response #}
{{ dialogue_response }}   {# Generated response (in some contexts) #}
{{ responseTarget }}      {# Who the response is directed to #}
```

### Action Context (for action selectors)
```
{{ eligible_actions }}    {# List of available actions #}
```

---

## Prompt File Examples

### Example 1: Character Biography Component

File: `prompts/submodules/character_bio/0100_summary.prompt`

```
{% if render_mode == "full" or render_mode == "thoughts" or render_mode == "dialogue_target" %}
## {{ decnpc(actorUUID).name }} - Character Summary
{% endif %}

{% if render_mode == "full" or render_mode == "short_inline" %}
{% set npc = decnpc(actorUUID) %}
{{ npc.name }} is a {{ npc.gender | lower }} {{ npc.race }} 
{%- if npc.class %} {{ npc.class }}{% endif %}.
{% if npc.summary %}
{{ npc.summary }}
{% endif %}
{% endif %}
```

### Example 2: Simple Dialogue Response Prompt

File: `prompts/dialogue_response.prompt`

```
[ system ]
You are {{ decnpc(npc.UUID).name }}, a {{ decnpc(npc.UUID).gender }} {{ decnpc(npc.UUID).race }} in Skyrim.
{% if responseTarget %}You are speaking to {% if responseTarget.type == "player" %}{{ player.name }}{% else %}{{ decnpc(responseTarget.UUID).name }}{% endif %}.{% endif %}

{{ render_subcomponent("system_head", "full") }}
[ end system ]

{{ render_template("components\\event_history") }}

[ user ]
{{ render_subcomponent("user_final_instructions", "full") }}
{% if decnpc(npc.UUID).universalTranslatorSpeechPattern %}
**Speech Pattern Required:** {{ decnpc(npc.UUID).universalTranslatorSpeechPattern }}
{% endif %}
Respond in character now.
[ end user ]
```

### Example 3: Player Thoughts Prompt

File: `prompts/player_thoughts.prompt`

```
[ system ]
You are the internal voice of {{ player.name }}, a {{ player.gender }} {{ player.race }} adventurer in Skyrim.

Generate the player character's internal thoughts based on the current situation. These thoughts should:
- Reflect on recent events
- Consider the player's goals and motivations
- React to nearby characters and environment
- Be written in first person

Keep thoughts concise (1-3 sentences).
[ end system ]

[ user ]
## Current Situation
Location: {{ get_current_location() }}
Time: {{ get_time_of_day() }}

## Recent Events
{{ render_template("components\\event_history_compact") }}

## Nearby Characters
{% for nearby in get_nearby_npc_list(player.UUID) %}
- {{ decnpc(nearby.UUID).name }} ({{ decnpc(nearby.UUID).race }})
{% endfor %}

Generate {{ player.name }}'s current thoughts.
[ end user ]
```

### Example 4: Action Selector Prompt

File: `prompts/native_action_selector.prompt`

```
[ system ]
## Task
Select an action to accompany {{ npc.name }}'s dialogue. Match the action to what they said, did, or agreed to.

## Output Format
- `ACTION: ActionName` — action with no parameters
- `ACTION: ActionName PARAMS: {"param": "value"}` — action with parameters
- `ACTION: None` — no action fits

Output exactly one line starting with `ACTION:` and nothing else.

## Selection Logic
Read {{ npc.name }}'s line and match it to an available action.

**Agreement can be implicit.** If the player requested something and {{ npc.name }} responded positively, that's agreement.

**Return `ACTION: None` only when** the line is purely conversational or no action matches.

## {{ npc.name }}
- {{ render_character_profile("short_inline", npc.UUID) }}
- Race/Gender: {{ decnpc(npc.UUID).gender }} {{ decnpc(npc.UUID).race }}
[ end system ]

[ user ]
## Location
{{ location }}

## Recent Dialogue
{{ render_template("components\\event_history_compact") }}

## {{ npc.name }}'s Line (MATCH THIS)
"{{ dialogue_request }}
{{ dialogue_response }}"

## Nearby Actors
- {{ decnpc(player.UUID).name }} (Player)
{% for nearby in get_nearby_npc_list(player.UUID) %}
- {{ decnpc(nearby.UUID).name }} ({{ units_to_meters(nearby.distance) }}m)
{% endfor %}

## Available Actions
{% for action in eligible_actions %}
- `{{ action.name }}`{% if action.parameterSchema %} PARAMS: {{ action.parameterSchema }}{% endif %} — {{ action.description }}
{% endfor %}
- `None` — No action fits

Output: `ACTION: [Name]` or `ACTION: [Name] PARAMS: {...}` or `ACTION: None`
[ end user ]
```

### Example 5: Memory Generation Prompt

File: `prompts/memory/generate_memory.prompt`

```
[ system ]
You are a memory extraction system. Analyze the provided events and dialogue to identify significant memories worth storing for {{ npc.name }}.

A good memory should:
- Capture emotionally significant moments
- Record important information learned
- Note relationship changes
- Document key decisions or actions

Output format:
```json
{
  "memory": "Concise description of the memory",
  "importance": 0.0-1.0,
  "emotion": "primary emotion",
  "related_actors": ["actor names"]
}
```
[ end system ]

[ user ]
## Character
{{ decnpc(npc.UUID).name }} - {{ decnpc(npc.UUID).summary }}

## Recent Events
{{ render_template("components\\event_history_verbose") }}

## Recent Dialogue
{% for event in recent_dialogue %}
{{ event.speaker }}: "{{ event.text }}"
{% endfor %}

Extract the most significant memory from these events.
[ end user ]
```

### Example 6: Diary Entry Prompt

File: `prompts/diary_entry.prompt`

```
[ system ]
You are writing a diary entry as {{ decnpc(npc.UUID).name }}.

Write in first person from the character's perspective. Include:
- Reflections on recent events
- Emotional responses
- Thoughts about other characters
- Goals or concerns for the future

Keep entries 2-4 paragraphs. Write naturally as the character would.
[ end system ]

[ user ]
## Character Information
{{ render_character_profile("full", npc.UUID) }}

## Recent Events to Reflect On
{{ render_template("components\\event_history_verbose") }}

## Recent Memories
{% for memory in recent_memories %}
- {{ memory.content }}
{% endfor %}

Write a diary entry reflecting on these events.
[ end user ]
```

---

## Adding Custom Prompts for Mods

### Character Bio Submodules

To add custom biography content for your mod, create files in `prompts/submodules/character_bio/`:

```
prompts/submodules/character_bio/5000_mymod_status.prompt
```

**Naming convention:** Use numbered prefixes to control order (lower = earlier in bio).

```
{# Only render if this mod's data exists #}
{% if my_mod_decorator_exists(actorUUID) %}

## My Mod Status
{% set mod_data = my_mod_get_data(actorUUID) %}
{{ decnpc(actorUUID).name }} has the following mod status:
- Status: {{ mod_data.status }}
- Level: {{ mod_data.level }}

{% endif %}
```

### Custom Decorators for Prompts

Register decorators via Papyrus to expose mod data:

```papyrus
Function Init()
    SkyrimNetApi.RegisterDecorator( \
        "my_mod_get_status",      ; Decorator name to use in prompts
        "MyModDecoratorScript",   ; Script containing the function
        "GetStatus"               ; Function name
    )
EndFunction
```

```papyrus
String Function GetStatus(Actor akActor) Global
    ; Return JSON data that can be accessed in prompts
    return "{\"status\": \"active\", \"level\": 5}"
EndFunction
```

Use in prompts:
```
{% set status = my_mod_get_status(npc.UUID) %}
{{ status.status }}
{{ status.level }}
```

---

## Best Practices

### 1. Use the MCP Server
Always call `mcp_skyrimnet-mcp_get_decorators` to discover available functions before writing prompts.

### 2. Keep Prompts Modular
- Use `render_template()` and `render_subcomponent()` for reusable content
- Create small, focused component files
- Use conditionals to handle missing data gracefully

### 3. Handle Missing Data
```
{% if decnpc(npc.UUID).summary %}
{{ decnpc(npc.UUID).summary }}
{% else %}
{{ decnpc(npc.UUID).name }} is a {{ decnpc(npc.UUID).race }}.
{% endif %}
```

### 4. Use Appropriate Render Modes
Character profiles support different modes:
- `full` - Complete biography
- `short_inline` - Brief summary
- `interject_inline` - For interjection context
- `dialogue_target` - For dialogue targets
- `thoughts` - For thought generation

### 5. Test Incrementally
- Start with simple prompts
- Add complexity gradually
- Test with different NPCs and scenarios

### 6. Consider Token Limits
- Be concise in system prompts
- Use compact event history for action selection
- Full history for important decisions

### 7. Use Clear Output Formats
For structured outputs (actions, memories), specify exact format:
```
Output format: `ACTION: [Name]` or `ACTION: None`
Do not include any other text.
```

### 8. Provide Context Efficiently
- Include only relevant information
- Use loops with limits: `{% for item in list[:5] %}`
- Filter nearby actors by distance

---

## Debugging Prompts

1. **Check SkyrimNet logs** for template rendering errors

2. **Use the web UI** to preview rendered prompts

3. **Test decorators** with `mcp_skyrimnet-mcp_get_decorators` to verify availability

4. **Start simple** - build up complexity gradually

5. **Check for typos** in decorator names (case-sensitive)

6. **Verify variable availability** - not all variables exist in all contexts

7. **Use `default()` function** to handle undefined values:
   ```
   {{ default(npc.summary, "No summary available") }}
   ```

---

## File Naming Conventions

| Directory | Pattern | Example |
|-----------|---------|---------|
| `character_bio/` | `NNNN_name.prompt` | `0100_summary.prompt` |
| `system_head/` | `NNNN_name.prompt` | `0010_instructions.prompt` |
| `guidelines/` | `NNNN_name.prompt` | `0500_roleplay_guidelines.prompt` |
| `components/` | `name.prompt` | `event_history.prompt` |
| `helpers/` | `name.prompt` | `generate_profile.prompt` |
| Root `prompts/` | `name.prompt` | `dialogue_response.prompt` |

Numbers control loading/rendering order - lower numbers load first.

---

## Template Inheritance

For complex prompts, use inheritance:

```
{# base.prompt #}
[ system ]
{% block system_intro %}
Default intro
{% endblock %}

{% block character_info %}{% endblock %}
[ end system ]

[ user ]
{% block user_content %}{% endblock %}
[ end user ]
```

```
{# child.prompt #}
{% extends "base.prompt" %}

{% block system_intro %}
Custom intro for this prompt type
{% endblock %}

{% block character_info %}
{{ render_character_profile("full", npc.UUID) }}
{% endblock %}

{% block user_content %}
Specific user instructions here
{% endblock %}
```

Use `{{ super() }}` to include parent block content.

