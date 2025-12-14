# LLM Instructions: Building SkyrimNet Trigger Files

This document provides comprehensive instructions for an LLM to create trigger files for the SkyrimNet mod system. Triggers allow custom responses to game events.

## Overview

Triggers are YAML files stored in `SKSE/Plugins/SkyrimNet/config/triggers/`. Each trigger file defines:
- What game events to watch for
- Conditions to filter those events
- What response to generate when conditions are met

## MCP Server for Game Data Exploration

**IMPORTANT**: You have access to the SkyrimNet MCP server which exposes game data. The MCP server provides tools to query spells, magic effects, items, quests, factions, races, keywords, furniture, global variables, plugins, player info, nearby actors, and template decorators.

**Always use the MCP server** to look up exact spell names, effect names, editor IDs, and form IDs when building triggers for specific game elements. Explore available `mcp_skyrimnet-mcp_*` tools to discover what game data you can query.

### Discovering Live Events with `get_monitored_events`

The most powerful tool for building triggers is `mcp_skyrimnet-mcp_get_monitored_events`. This returns **real-time events** from the running game, letting you see exactly what event types and field values are available to trigger on.

**Usage:**
```
mcp_skyrimnet-mcp_get_monitored_events(count: 50, event_type: "mod_event")
```

**Parameters:**
- `count` - Maximum number of events to return (default: 100, max: 500)
- `event_type` - Filter by event type (e.g., `dialogue`, `animation_event`, `mod_event`, `combat`)
- `include_animations` - Set to `false` to exclude high-volume animation events
- `include_stats` - Include event statistics

**Example workflow:**
1. Run `get_monitored_events` with no filters to see all recent events
2. Identify interesting events (e.g., a mod event from a specific mod)
3. Note the exact `eventType` and field values in `extraData`
4. Build your trigger using those exact values

### Event Structure from MCP

Each event returned by the MCP has this structure:

```json
{
  "eventType": "mod_event",
  "id": 84,
  "source": "00105CA6",
  "summary": "OSLA_ActorArousalUpdated",
  "timestamp": 1765687261485,
  "extraData": {
    "event_name": "OSLA_ActorArousalUpdated",
    "num_arg": 23.54,
    "sender_form_id": "00105CA6",
    "sender_name": "",
    "str_arg": ""
  }
}
```

The `eventType` maps to your trigger's `eventCriteria.eventType`, and fields in `extraData` are accessible via `schemaConditions` using `fieldPath`.

### Common Event Types Discovered via MCP

| Event Type | Description | Key `extraData` Fields |
|------------|-------------|------------------------|
| `active_effect` | Magic effect applied/removed | `action`, `effect`, `effect_editor_id`, `caster`, `target`, `caster_uuid`, `target_uuid` |
| `mod_event` | SKSE mod events | `event_name`, `num_arg`, `str_arg`, `sender_form_id`, `sender_name` |
| `quest_start_stop` | Quest starts/stops | `quest`, `quest_id`, `started` (boolean) |
| `quest_stage` | Quest stage progression | `quest`, `quest_id`, `stage` |
| `animation_event` | Actor animations | `tag`, `actor_name`, `actor_form_id`, `actor_uuid`, `payload`, `graph_vars` |
| `spell_cast` | Spell casting | `actor`, `spell`, `spell_id`, `spell_editor_id` |
| `dialogue` | AI dialogue | `speaker`, `dialogue`, `listener` |

### Real-World Examples from MCP Data

**Example: Trigger on Arousal Mod Events**
```yaml
name: "arousal_high_reaction"
description: "React when player arousal gets high"

eventCriteria:
  eventType: "mod_event"
  schemaConditions:
    - fieldPath: "event_name"
      operator: "equals"
      value: "OSLA_ActorArousalUpdated"
    - fieldPath: "sender_form_id"
      operator: "equals"
      value: "00000014"  # Player form ID
    - fieldPath: "num_arg"
      operator: "greater_than"
      value: 75

response:
  type: "player_thought"
  content: "My mind wanders to... distracting thoughts."

audience: "player"
probability: 0.3
cooldownSeconds: 300
```

**Example: Trigger on Quest Starting**
```yaml
name: "quest_started_awareness"
description: "Player becomes aware when a quest begins"

eventCriteria:
  eventType: "quest_start_stop"
  schemaConditions:
    - fieldPath: "started"
      operator: "equals"
      value: true

response:
  type: "player_thought"
  content: "Something has changed... a new path opens before me. {{ event_json.quest }} begins."

audience: "player"
probability: 0.5
cooldownSeconds: 60
```

**Example: Trigger on Specific Animation**
```yaml
name: "dialogue_animation_narration"
description: "Narrate when NPC enters dialogue animation"

eventCriteria:
  eventType: "animation_event"
  schemaConditions:
    - fieldPath: "tag"
      operator: "equals"
      value: "IdleDialogueLock"

response:
  type: "direct_narration"
  content: "{{ event_json.actor_name }} turns to speak."

audience: "nearby_npcs"
probability: 0.2
cooldownSeconds: 30
```

**Example: Trigger on Active Effect Removal**
```yaml
name: "buff_expired_thought"
description: "Player notices when a protective spell fades"

eventCriteria:
  eventType: "active_effect"
  schemaConditions:
    - fieldPath: "action"
      operator: "equals"
      value: "removed"
    - fieldPath: "target"
      operator: "equals"
      value: "{{ player_name }}"
    - fieldPath: "effect"
      operator: "contains"
      value: "Armor"

response:
  type: "player_thought"
  content: "The {{ event_json.effect }} spell fades. I feel exposed once more."

audience: "player"
probability: 0.7
cooldownSeconds: 10
```

**Example: SkyUI Widget Events**
```yaml
name: "hud_mode_changed"
description: "React to HUD mode changes from SkyUI"

eventCriteria:
  eventType: "mod_event"
  schemaConditions:
    - fieldPath: "event_name"
      operator: "equals"
      value: "SKIWF_hudModeChanged"
    - fieldPath: "str_arg"
      operator: "equals"
      value: "All"

response:
  type: "persistent_event"
  content: "HUD visibility changed to full mode"

enabled: false  # Example only - very frequent event
```

### How to Use MCP for Trigger Creation

When a user asks you to create a trigger (e.g., "I want NPCs to react when I cast a healing spell"), follow this workflow:

#### Step 1: Query Recent Events
Run `get_monitored_events` to see what's happening in the game:
```
get_monitored_events(count: 100)
get_monitored_events(count: 50, event_type: "spell_cast")  # If you know the category
get_monitored_events(count: 100, include_animations: false)  # Reduce noise
```

#### Step 2: Carefully Examine the Event Data
Look at each event's structure and identify:
- **`eventType`** → This becomes your `eventCriteria.eventType`
- **`extraData` fields** → These become your `schemaConditions` with `fieldPath`
- **Exact values** → Copy these precisely for `value` in conditions

**Example event from MCP:**
```json
{
  "eventType": "active_effect",
  "extraData": {
    "action": "applied",
    "effect": "Armor - Oak",
    "effect_editor_id": "ArmorOakfleshFFSelf",
    "caster": "PlayerName",
    "target": "PlayerName"
  }
}
```

**Becomes this trigger:**
```yaml
eventCriteria:
  eventType: "active_effect"
  schemaConditions:
    - fieldPath: "action"
      operator: "equals"
      value: "applied"
    - fieldPath: "effect_editor_id"
      operator: "equals"
      value: "ArmorOakfleshFFSelf"
```

#### Step 3: Identify the Right Fields to Match On
When examining events, prioritize matching on:

1. **`editor_id` fields** (most reliable) - e.g., `spell_editor_id`, `effect_editor_id`
2. **`event_name`** for mod events - the SKSE ModEvent name
3. **`action` or `state` fields** - e.g., `"applied"`, `"removed"`, `"Combat"`
4. **Actor/target names** - when you need to filter by who's involved
5. **Numeric thresholds** - use `greater_than`/`less_than` for values like arousal, health, etc.

#### Step 4: Handle Common Scenarios

**"Trigger when the player does X":**
Look for events where the actor/caster is the player. The player's form ID is always `00000014`.
```yaml
schemaConditions:
  - fieldPath: "actor"
    operator: "equals"
    value: "{{ player_name }}"
```

**"Trigger when a specific mod does something":**
Filter mod events by `event_name` and optionally `sender_form_id`:
```yaml
eventCriteria:
  eventType: "mod_event"
  schemaConditions:
    - fieldPath: "event_name"
      operator: "equals"
      value: "OSLA_ActorArousalUpdated"
```

**"Trigger on a specific spell/effect":**
Use the `editor_id` for precision, or `contains` for categories:
```yaml
# Exact spell
- fieldPath: "spell_editor_id"
  operator: "equals"
  value: "HealSelf01"

# Category of spells
- fieldPath: "spell"
  operator: "contains"
  value: "Heal"
  caseSensitive: false
```

**"Trigger when a quest progresses":**
Use `quest_stage` for stage changes, `quest_start_stop` for start/end:
```yaml
eventCriteria:
  eventType: "quest_stage"
  schemaConditions:
    - fieldPath: "quest"
      operator: "contains"
      value: "MQ"  # Main quest prefix
```

#### Step 5: Verify Your Understanding
If you're unsure what events fire for a user's request:
1. Ask them to perform the action in-game
2. Query `get_monitored_events` immediately
3. Look for events that correlate with their action
4. If multiple events fire, choose the most specific one

#### Common MCP Queries for Trigger Creation

```
# See everything (good starting point)
get_monitored_events(count: 100)

# Focus on specific event types
get_monitored_events(count: 50, event_type: "mod_event")
get_monitored_events(count: 50, event_type: "spell_cast")
get_monitored_events(count: 50, event_type: "active_effect")
get_monitored_events(count: 50, event_type: "quest_stage")

# Reduce noise from animations
get_monitored_events(count: 100, include_animations: false)

# Get event statistics
get_monitored_events(count: 50, include_stats: true)
```

#### Key Things to Look For in Events

| What You Want | Look For in Events |
|---------------|-------------------|
| Spell casting | `eventType: "spell_cast"`, check `spell`, `spell_editor_id` |
| Buff/debuff applied | `eventType: "active_effect"`, `action: "applied"` |
| Buff/debuff expired | `eventType: "active_effect"`, `action: "removed"` |
| Quest progress | `eventType: "quest_stage"`, check `quest`, `stage` |
| Quest started/ended | `eventType: "quest_start_stop"`, check `started` boolean |
| Mod integration | `eventType: "mod_event"`, check `event_name` |
| Combat started | `eventType: "combat"`, `new_state: "Combat"` |
| Actor animations | `eventType: "animation_event"`, check `tag` |
| Equipment changes | `eventType: "equip"`, check `item`, `equipped` |

---

## Trigger File Structure

```yaml
name: "unique_trigger_name" # MUST match file name
description: "Human-readable description of what this trigger does"

# What events to match
eventCriteria:
  eventType: "spell_cast"  # Required: event type to watch
  schemaConditions:        # Optional: filter conditions
    - fieldPath: "spell"
      operator: "equals"
      value: "Fireball"
      caseSensitive: false

# How to respond when triggered
response:
  type: "player_thought"  # Response type
  content: "Template content with {{ variables }}"
  targetScope: "triggering_actor"  # Optional: who to target
  nearbyRadius: 2000               # Optional: radius for nearby scope

# Who perceives the response
audience: "player"

# Behavior settings
enabled: true
probability: 1.0        # 0.0-1.0
cooldownSeconds: 30     # Minimum seconds between triggers
priority: 1             # Higher = evaluated first
```

---

## Required Fields

### `name` (string, required)
Unique identifier for this trigger. Use snake_case or descriptive naming.

```yaml
name: "fireball_reaction"
name: "player_sleep_start_diary"
name: "combat_entered_thought"
```

### `eventCriteria` (object, required)
Defines what events this trigger responds to.

#### `eventCriteria.eventType` (string, required)
The type of event to match. Available event types:

| Event Type | Description | Key Fields |
|------------|-------------|------------|
| `spell_cast` | Actor casts a spell | `actor`, `spell`, `spell_id`, `spell_editor_id` |
| `active_effect` | Magic effect applied/removed | `target`, `caster`, `effect`, `effect_id`, `effect_editor_id`, `action` (`applied`/`removed`), `caster_uuid`, `target_uuid` |
| `hit` | Combat hit | `aggressor`, `target`, `weapon_id`, `flags` |
| `combat` | Combat state change | `actor`, `target`, `new_state` |
| `death` | Actor death | `victim`, `killer`, `death_type`, `is_dead` |
| `activation` | Object/furniture interaction | `actor`, `target_name`, `activator_editor_id` |
| `equip` | Equipment change | `actor`, `item`, `action`, `equipped` |
| `sleep_start` | Actor starts sleeping | `actor` |
| `sleep_stop` | Actor wakes up | `actor` |
| `book_read` | Book read | `book_name`, `book_title`, `book_text` |
| `quest_stage` | Quest progression | `quest`, `quest_id`, `stage` |
| `quest_start_stop` | Quest starts/stops | `quest`, `quest_id`, `started` (boolean) |
| `location_change` | Location changed | `actor`, `from_location`, `to_location` |
| `container_changed` | Items moved | `item`, `item_count`, `from_container`, `to_container` |
| `enter_bleedout` | Actor collapses | `actor` |
| `animation_event` | Animation played | `tag`, `actor_name`, `actor_form_id`, `actor_uuid`, `payload`, `graph_vars` |
| `mod_event` | SKSE mod event | `event_name`, `str_arg`, `num_arg`, `sender_name`, `sender_form_id` |
| `crime` | Criminal activity | `criminal`, `crime_type`, `victim`, `bounty` |
| `dragon_soul` | Dragon soul absorbed | `absorber`, `dragon_name` |
| `dialogue` | AI-generated dialogue | `speaker`, `dialogue`, `listener` |
| `player_thoughts` | Player internal thoughts | `player_name`, `thoughts` |
| `direct_narration` | Direct narration | `narration` |
| `*` | Wildcard - ALL events | (varies) |

> **Pro Tip**: Use `mcp_skyrimnet-mcp_get_monitored_events` to see real events and discover exact field names and values!

### `response` (object, required)
Defines how to respond when the trigger fires.

#### `response.type` (string, required)
| Type | Description |
|------|-------------|
| `player_thought` | Internal player thoughts (shown in UI) |
| `player_dialogue` | Player speaks out loud |
| `direct_narration` | Narrative text that NPCs react to |
| `persistent_event` | Event registered without triggering NPC responses |
| `diary_entry` | Creates a diary entry for target actor(s) |
| `dynamic_bio_update` | Updates dynamic biography for target actor(s) |

#### `response.content` (string, required for most types)
Template string using Inja syntax. Available variables:

```yaml
# Event context variables
{{ player_name }}          # Player character name
{{ event_json.field }}     # Access any event data field
{{ event_json.actor }}     # Actor who triggered event
{{ event_json.spell }}     # Spell name (for spell_cast)
{{ event_json.target }}    # Target of the event

# Special variables (for some response types)
{{ time_desc }}            # Relative time description
```

---

## Optional Fields

### `eventCriteria.schemaConditions` (array)
Filter events with conditions. Each condition has:

```yaml
schemaConditions:
  - fieldPath: "spell"           # Path to field in event data
    operator: "equals"           # Comparison operator
    value: "Fireball"            # Expected value
    caseSensitive: false         # Optional, default true
```

**Operators:**
- `equals` / `not_equals` - Exact match
- `contains` / `not_contains` - Substring match
- `greater_than` / `less_than` / `greater_than_or_equal` / `less_than_or_equal` - Numeric
- `starts_with` / `ends_with` - String prefix/suffix
- `matches_regex` - Regular expression match

### `audience` (string)
Who perceives/responds to the trigger output:

| Value | Description |
|-------|-------------|
| `player` | Only the player (default) |
| `originator` | Actor that caused the event |
| `target` | Target of the event |
| `originator_or_target` | Either originator or target |
| `everyone` | All nearby actors |
| `nearby_npcs` | NPCs only (excluding player) |

### `response.targetScope` (string)
For `diary_entry` and `dynamic_bio_update` types:

| Value | Description |
|-------|-------------|
| `triggering_actor` | Only the actor that triggered the event |
| `player` | Only the player character |
| `all_pinned_actors` | All tracked/pinned actors |
| `all_nearby_actors` | All actors within `nearbyRadius` |

### `response.nearbyRadius` (number)
Radius in game units for `all_nearby_actors` scope. Default: 2000

### `probability` (number)
Chance of trigger firing (0.0 to 1.0). Default: 1.0

### `cooldownSeconds` (integer)
Minimum seconds between trigger activations. Default: 0

### `priority` (integer)
Higher priority triggers are evaluated first. Default: 1

### `enabled` (boolean)
Whether this trigger is active. Default: true

---

## Examples

### Example 1: Spell Cast Reaction

```yaml
name: "healing_spell_thought"
description: "Player thinks about healing when casting restoration spells"

eventCriteria:
  eventType: "spell_cast"
  schemaConditions:
    - fieldPath: "spell"
      operator: "contains"
      value: "Heal"
      caseSensitive: false
    - fieldPath: "actor"
      operator: "equals"
      value: "{{ player_name }}"

response:
  type: "player_thought"
  content: "The warmth of restoration magic flows through my veins, mending wounds both seen and unseen."

audience: "player"
enabled: true
probability: 0.5
cooldownSeconds: 60
priority: 1
```

### Example 2: Combat Diary Entry

```yaml
name: "combat_diary_entry"
description: "Write diary entries when combat starts"

eventCriteria:
  eventType: "combat"
  schemaConditions:
    - fieldPath: "new_state"
      operator: "equals"
      value: "Combat"

response:
  type: "diary_entry"
  content: "Combat has begun. {{ event_json.actor }} faces {{ event_json.target }} in battle."
  targetScope: "all_pinned_actors"
  nearbyRadius: 3000

audience: "nearby_npcs"
enabled: true
probability: 1.0
cooldownSeconds: 120
priority: 1
```

### Example 3: Death Narration

```yaml
name: "death_narration"
description: "Narrate significant deaths"

eventCriteria:
  eventType: "death"
  schemaConditions:
    - fieldPath: "is_dead"
      operator: "equals"
      value: true
    - fieldPath: "is_summoned"
      operator: "equals"
      value: false

response:
  type: "direct_narration"
  content: "*{{ event_json.victim }} falls to the ground, slain by {{ event_json.killer }}*"

audience: "nearby_npcs"
enabled: true
probability: 1.0
cooldownSeconds: 5
priority: 2
```

### Example 4: Animation Event Trigger

```yaml
name: "jump_animation_reaction"
description: "React to actors jumping"

eventCriteria:
  eventType: "animation_event"
  schemaConditions:
    - fieldPath: "tag"
      operator: "equals"
      value: "JumpDown"

response:
  type: "player_thought"
  content: "I notice {{ event_json.actor_name }} landing from a jump."

audience: "player"
enabled: true
probability: 0.3
cooldownSeconds: 10
priority: 1
```

### Example 5: Mod Event Trigger (for mod integrations)

```yaml
name: "dirt_and_blood_wash"
description: "React to Dirt and Blood mod wash spell"

eventCriteria:
  eventType: "spell_cast"
  schemaConditions:
    - fieldPath: "spell"
      operator: "equals"
      value: "Wash and Rinse"
    - fieldPath: "spell_editor_id"
      operator: "equals"
      value: "Dirty_CleanYoSelf"

response:
  type: "direct_narration"
  content: "{{ player_name }} finds a stream and begins washing off the accumulated dirt and grime from the road."

audience: "nearby_npcs"
enabled: true
probability: 1.0
cooldownSeconds: 30
priority: 1
```

### Example 6: Active Effect Trigger

```yaml
name: "oakflesh_thought"
description: "Player thinks when casting armor spells"

eventCriteria:
  eventType: "active_effect"
  schemaConditions:
    - fieldPath: "effect"
      operator: "equals"
      value: "Armor - Oak"
      caseSensitive: false
    - fieldPath: "action"
      operator: "equals"
      value: "applied"

response:
  type: "player_thought"
  content: "My skin hardens like bark as the Oakflesh spell takes effect."

audience: "player"
enabled: true
probability: 1.0
cooldownSeconds: 30
priority: 1
```

---

## Best Practices

1. **Use the MCP server** to look up exact spell names, editor IDs, and other game data before creating triggers

2. **Start with low probability** (0.1-0.3) to test triggers without spam

3. **Use appropriate cooldowns** to prevent repetitive triggers

4. **Be specific with conditions** - overly broad triggers can cause performance issues

5. **Test incrementally** - start with one condition, verify it works, then add more

6. **Use descriptive names** that indicate what the trigger does

7. **Set appropriate priorities** - more specific triggers should have higher priority

8. **Consider audience carefully** - `nearby_npcs` will cause NPC reactions, `player` will not

9. **Use case-insensitive matching** when the exact case might vary

10. **Check for existing triggers** to avoid conflicts or duplicates

---

## Debugging Tips

- Check SkyrimNet logs for trigger loading errors
- Use a YAML validator to verify syntax
- Start with `enabled: false` and enable once confirmed correct
- Use `probability: 1.0` initially for testing, then reduce
- Use the wildcard event type `*` temporarily to see all events (then be more specific)

---

## Template Variables Reference

Variables available in `response.content`:

| Variable | Description | Example |
|----------|-------------|---------|
| `{{ player_name }}` | Player character name | "Dragonborn" |
| `{{ event_json.* }}` | Any field from event data | `{{ event_json.spell }}` |
| `{{ time_desc }}` | Relative time description | "just happened" |
| `{{ location }}` | Current location name | "Whiterun" |
| `{{ gameTimeStr }}` | In-game time string | "4E 201, 17th of Last Seed" |

For diary_entry and dynamic_bio_update responses, the target actors are determined by `targetScope`.

