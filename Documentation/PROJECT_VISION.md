# Project Chronicle — Project Vision

> **North Star document.** When in doubt about direction, scope, or priorities, return here.

This vision builds on and preserves the principles in [GameRules.md](GameRules.md):

- Every adventure permanently changes the world.
- If a feature does not make exploration more exciting, don't build it. If it does, build it well.
- Quality over quantity. Player stories over scripted stories. Meaningful choices over endless content.
- Single-player first. Multiplayer later.
- AI enhances. AI never replaces gameplay.

---

## What Project Chronicle Is

Project Chronicle is a **single-player-first, 2D side-scrolling fantasy action RPG** built in **Godot 4.7.1**.

Multiplayer is a possible future expansion but must **never** dictate current architecture or slow development of the single-player game.

The game takes inspiration from the **emotional atmosphere** of old-world fantasy adventure: long journeys, ancient magic, forgotten ruins, mages, warriors, rogues, villages, monsters, and the passage of time. *Frieren* is an atmospheric inspiration, but the game must have its **own original** world, characters, lore, visual identity, mechanics, and terminology.

The game is **not** intended to be:

- "Stardew Valley with combat"
- "Dark and Darker in 2D"

### Core identity

**A high-risk living fantasy RPG where every adventure can change both your character and the history of the world.**

### Progression identity

> **Levels give structure. The world gives reasons. Gear gives obsession. Builds give identity. Secrets give stories.**

The **Adventurer Era spans levels 1–40** through three connected layers: character progression, build progression, and world progression. At level 10 the world noticeably opens; by level 20 build identity starts becoming clear; at level 30 specialization is pronounced; and level 40 ends the era as the world begins remembering the player as someone consequential. See [PROGRESSION_DESIGN.md](PROGRESSION_DESIGN.md) for stats, data-driven Techniques, multi-purpose activities, extensible events, quest chains and rewards, gear rarity, exploration scaling, planned UI, hidden progression architecture, and later combat expression.

The reusable technical progression foundation and Level 1–5 proof are the current layer. Finished Level 1–40 content and its later world, UI, accomplishment, combat-presentation, and visual systems remain deliberately scoped for future milestones.

### Gameplay presentation

Chronicle is presented from the side. Exploration unfolds across interconnected maps with solid terrain, layered platforms, drops, elevated routes, hidden paths, and landmarks that make each region memorable. Verticality should create optional discoveries and tactical choices without turning Chronicle into a precision-platforming game; it remains an action RPG first.

The Adventurer must have a readable side-view silhouette. Weapons, armor, and unusual equipment should eventually change that silhouette so accomplishments and build identity are visible in play.

---

## Core Player Fantasy

The player begins as an **ordinary adventurer**, not a predetermined chosen hero.

**The world does not revolve around the player.**

Through exploration, survival, discoveries, relationships, combat, equipment, choices, and accomplishments, the player gradually creates their own identity and legend.

The game should eventually make players feel:

- "I wonder what's beyond that forest."
- "I have incredible loot. Should I risk going deeper?"
- "I can't believe I found this weapon."
- "This build is ridiculous."
- "That town remembers what I did."
- "I caused this."
- "This world feels different from my last playthrough."
- "I have history here."

---

## Primary Gameplay Loop

```
Town / Safe Haven
  → Prepare
  → Choose equipment and supplies
  → Enter dangerous wilderness
  → Explore
  → Fight
  → Discover
  → Acquire increasingly valuable loot
  → Decide whether to push deeper or return safely
  → Survive the journey home
  → Bank loot
  → Craft / trade / equip / upgrade
  → Learn new rumors and information
  → Observe consequences in the world
  → Prepare for the next adventure
```

### Fundamental tension

**"Do I leave with what I have, or risk it for what might be ahead?"**

Exploration must become increasingly **dangerous** and increasingly **rewarding**.

---

## High Risk / High Reward

Risk is a central pillar.

- The wilderness should feel **dangerous**.
- Returning to civilization should feel **relieving**.
- Valuable discoveries create tension because continuing an expedition risks losing what the player is carrying.

Death should **matter**. The exact long-term death system is **not finalized** — do not hardcode permanent death rules yet.

Potential future consequences may include:

- Dropped carried loot
- Corpse recovery
- Injuries
- World time passing
- Other meaningful consequences

---

## Combat

Combat is **real-time, responsive, readable, and skill-based**.

It should eventually support:

- Melee weapons
- Bows / projectiles
- Shields
- Parries
- Dodging
- Magic
- Status effects
- Weapon abilities
- Enemy weaknesses
- Bosses
- Build synergies

**Avoid stat-check-only combat.**

Player positioning, timing, preparation, equipment, knowledge, and mechanical execution should matter.

---

## Emergent Identity — No Traditional Classes

Project Chronicle does **not** use a traditional "choose your class" system. The player begins simply as an **Adventurer**.

Their effective class and identity emerge organically from:

**Equipment + Stats + Techniques + Titles / Badges + Player Behavior + Accomplishments**

The game should observe how the player actually plays rather than forcing them down a predetermined class tree. Players and the community may naturally give builds names such as Knight, Ninja, Blood Mage, Paladin, Fortress Knight, or Shadowblade, but these identities arise from gameplay systems rather than a mandatory class-selection screen.

**A player's "class" is ultimately the story of what they became.**

A player should be able to begin a new playthrough thinking:

- "I'm rushing the katana and building a ninja."
- "I'm finding Excalibur, a shield, and a lifesteal ring."
- "I'm making a blood mage."
- "I'm playing a poison rogue."
- "I'm becoming a heavily armored paladin."

Weapons and equipment should change **how** the player plays, not simply provide larger numbers.

### Examples of eventual build-defining properties

- Attack behavior changes
- Unique abilities
- Dodge interactions
- Blocking interactions
- Spell modifications
- Elemental interactions
- Lifesteal
- Critical-hit mechanics
- Summons
- Status effects
- Conditional bonuses
- Equipment-set bonuses

Gear sets may provide increasingly transformative bonuses for wearing multiple pieces.

Legendary / signature equipment should feel memorable and connected to the world's history.

**Specific final items and balance are intentionally not locked yet.**

### Build freedom

Do **not** create rigid class restrictions such as:

- Warriors cannot cast spells.
- Mages cannot equip swords.
- Rogues must wear light armor.

Equipment requirements, opportunity costs, stats, synergies, and mechanics should naturally shape builds instead. Strange hybrid builds should be possible and sometimes extremely powerful when intelligently assembled.

### Titles and badges

Titles and badges are meaningful progression systems, not merely achievements. They may be earned through:

- Unusual accomplishments
- Repeated behavior
- Exploration
- Combat mastery
- Surviving dangerous situations
- Defeating specific enemies in unusual ways
- Equipment or build specialization
- Faction relationships
- Discoveries
- World events
- Secret conditions

Some should be visible progression goals, while many should remain hidden until discovered.

Examples of the design philosophy include:

- **Iron Will** — earned through repeatedly surviving combat while critically wounded; may provide a defensive benefit.
- **The Unbroken** — earned through extraordinary defensive accomplishments; may enhance blocking or armor-oriented builds.
- **Ghost of Elderwood** — could emerge from exceptional agile or stealth-oriented play.
- **The Crimson Hunger** — could emerge from extensive lifesteal or blood-oriented gameplay.
- **The Fool Who Returned** — could be awarded for surviving an expedition the player was dramatically underprepared for.

These names, conditions, and effects are examples only and are **not final content**.

### Titles can affect gameplay

Certain titles or badges may grant:

- Passive effects
- Stat modifications
- Unusual mechanics
- Resistances
- NPC reactions
- Reputation changes
- Dialogue options
- Access to techniques
- Interactions with equipment or world systems

Avoid making every title a simple numerical stat increase. The most memorable rewards should sometimes alter possibilities or mechanics.

### Behavioral progression

Repeated player behavior may cause the character to develop naturally. Examples include:

- Frequent blocking leading to defensive mastery opportunities
- Repeatedly surviving poison leading to potential poison-related progression
- Extensive fire-magic use leading to fire-related mastery or discoveries
- Specializing in katana combat leading to relevant techniques or titles
- Defeating enemies through reflected damage leading to an unusual defensive reward

This must **not** become an easily exploitable system where mindlessly repeating an action automatically grants unlimited power. Important progression should combine behavior with accomplishments, discoveries, challenges, world conditions, or diminishing thresholds.

### Discovery philosophy

Project Chronicle should intentionally contain mechanics players are not explicitly told about. The desired community experience includes:

- "Wait, how did you unlock that?"
- "I didn't even know that title existed."
- "Apparently if you defeat this enemy under these conditions something happens."

Player knowledge is itself a form of progression. These systems should encourage experimentation, community discoveries, guides, theorycrafting, challenge runs, and multiple playthroughs.

### World integration

Titles should eventually represent things that actually happened in the world. NPCs may recognize important titles, factions may react differently, legends may spread, and some titles may become part of Chronicle's historical simulation.

### Development rule

Do **not** implement the full Titles / Badges / Behavioral Progression system yet. This section establishes long-term architecture and design direction only.

Future gameplay systems must avoid assumptions that require traditional fixed classes or rigid skill trees.

---

## Build Philosophy

- Strong builds should sometimes feel almost **unfair** when assembled correctly.
- The player should enjoy discovering combinations and synergies.
- Powerful builds should still have weaknesses, counters, opportunity costs, or situations where other builds excel.
- Multiple playthroughs should encourage dramatically different approaches.
- Knowledge of where equipment, spells, materials, bosses, factions, and secrets can be found becomes part of player mastery.

---

## Knowledge Is Progression

Character statistics are only **one** form of progression.

**The player themselves should learn the world.**

Examples:

- Where rare equipment can be found
- Hidden dungeon entrances
- Monster weaknesses
- Rare crafting ingredients
- Faction behavior
- Dangerous regions
- Unusual spell interactions
- World events

Experienced players should be capable of deliberately pursuing unusual builds much earlier than inexperienced players.

---

## Living World

The eventual world should continue existing beyond the immediate player.

Long-term systems **may** include:

- NPC schedules
- NPC relationships and memories
- Aging, births, and deaths
- Settlements growing or declining
- Factions, trade, and wars
- Monster populations and migration
- Ecological consequences
- Discoveries, political changes, historical events
- Rumors and legends

These systems must be introduced **gradually**. Do **not** attempt to simulate the entire world during early development.

---

## World Memory

The world should remember meaningful events.

Player actions can eventually influence:

- NPC opinions
- Settlements and factions
- Available resources
- Future quests
- Rumors and historical records
- Later generations

Consequences do not always need to be immediate. Something the player does early in a playthrough might matter many in-game years later.

---

## Time and Legacy

Time is an important thematic element.

- NPCs may eventually age.
- Children may become adults.
- Settlements may transform.
- Famous adventurers may die.
- Ruins may appear where places once stood.

The player's actions may become stories, myths, titles, monuments, items, or historical events.

Long-term legacy systems are **aspirational** and should not be implemented until the core RPG is excellent.

---

## AI Philosophy

**AI is not the game.**

The game must remain enjoyable if all generative AI functionality is disabled.

Traditional deterministic game systems handle:

- Combat, physics, inventory, equipment
- Economy, crafting, schedules, statistics
- Spawning and world rules

Future AI acts more like a **World Director / Dungeon Master**.

AI may eventually help:

- Generate contextual dialogue
- Interpret world events
- Create rumors and contextual quests
- Summarize historical events
- Evolve NPC motivations
- React narratively to simulation state
- Connect otherwise separate events into stories

AI should react to **structured game state** rather than inventing arbitrary facts that contradict the simulation.

**AI should enhance emergence, not replace handcrafted mechanics.**

---

## NPC Philosophy

NPCs should eventually possess structured state such as:

- Personality, relationships, memories
- Profession, knowledge, goals, fears, opinions
- Current emotional state

NPCs should **not** simply be unlimited open-ended chatbots.

AI-generated dialogue should be grounded in what that NPC actually knows and has experienced.

---

## World Generation

The long-term dream is a world capable of producing enormous amounts of emergent adventure and history.

**"Infinite" does not mean** randomly generating meaningless content forever.

It means systems combine to continuously produce new situations, consequences, discoveries, relationships, and stories.

**Quality and coherence** are more important than literal infinite map size.

---

## Visual Identity

The game uses **2D pixel art**.

Desired feeling:

- Side-view characters and layered side-scrolling environments
- Interconnected maps with readable vertical exploration
- Visible equipment as a major expression of progression and emergent identity
- Old-world fantasy, mysterious, beautiful, occasionally melancholic
- Cozy civilization contrasted with dangerous wilderness
- Ancient ruins, forests, mountains, caves, magical environments
- Warm inns and villages
- Readable action combat

The atmosphere may evoke the contemplative feeling of fantasy journeys such as *Frieren*, while remaining completely original.

---

## Emotional Pillars

| Pillar | Player feeling |
|--------|----------------|
| **Wonder** | "What's over there?" |
| **Risk** | "Should I keep going?" |
| **Discovery** | "What the hell did I just find?" |
| **Mastery** | "I know how this world works now." |
| **Power** | "This build is insane." |
| **Comfort** | "I made it home." |
| **Consequence** | "That happened because of me." |
| **Legacy** | "The world remembers." |

---

## Development Priority

Approximate order:

1. Movement and game feel
2. Combat
3. Enemies
4. Loot
5. Inventory
6. Equipment
7. Build system
8. Exploration
9. Small polished world
10. NPCs
11. Quests / events
12. World simulation
13. AI Director
14. Expanded procedural / emergent systems
15. Multiplayer — **only if** the single-player game succeeds and it makes sense

---

## Current Target

**Do not attempt to build the complete dream immediately.**

The immediate goal is first to establish a stable **side-scrolling gameplay foundation**, then build it into a polished vertical slice containing approximately:

- One small settlement
- Wilderness
- One cave / dungeon
- Several enemy types
- One boss
- Meaningful loot
- Several genuinely different builds
- NPCs
- A basic economy
- Risk / reward expeditions
- Enough world reactivity to demonstrate the long-term concept

The vertical slice should prove:

> **"Is exploring, fighting, finding equipment, creating builds, taking risks, returning home, and seeing the world react genuinely fun?"**

The current progression foundation supports the vertical slice; hidden accomplishment evaluation, final MMO-inspired UI, advanced multi-target presentation, finished Level 1–40 content, and living-world visuals do not expand this immediate implementation scope.

---

## Engineering Principles

- **Godot 4.7.1**
- Single-player first
- Data-driven content
- Modular systems and reusable components
- Avoid giant scripts
- Avoid premature complexity
- Do not hardcode individual items into Player logic
- Preserve working systems
- Implement one stable layer at a time
- Build systems that can expand later without building hypothetical future systems now

---

## Final Rule

Whenever implementing a feature, ask:

**Does this strengthen exploration, risk, discovery, builds, consequence, or the feeling of inhabiting a living fantasy world?**

If not, question whether the feature belongs in Project Chronicle.
