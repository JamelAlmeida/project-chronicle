# Project Chronicle — Progression Design

> **Long-term progression north star.** This document extends [PROJECT_VISION.md](PROJECT_VISION.md), [GameRules.md](GameRules.md), and [ART_DIRECTION.md](ART_DIRECTION.md) without replacing their direction, scope discipline, or originality rules.

## Progression Promise

The first complete progression arc is the **Adventurer Era, levels 1–40**. It takes an ordinary Adventurer from local survivor to a consequential figure whose choices, accomplishments, and reputation the world remembers.

> **Levels give structure. The world gives reasons. Gear gives obsession. Builds give identity. Secrets give stories.**

Levels pace the journey; they must not become the sole reason to play. Activities should primarily be worth doing because they reveal places, advance relationships and quest chains, secure rare equipment, change the world, or uncover secrets.

## Three Progression Layers

1. **Character progression** — levels, meaningful core-stat allocation, Techniques, and milestone capabilities.
2. **Build progression** — equipment, properties, synergies, titles, and playstyle-defining combinations.
3. **World progression** — quest chains, discoveries, relationships, consequences, access, and remembered deeds.

These layers should reinforce one another without collapsing into a single power score.

## Adventurer Era Milestones

- **Level 10 — The world opens:** regions, routes, quest hubs, and build options noticeably broaden.
- **Level 20 — Identity emerges:** equipment, stats, Techniques, behavior, and discoveries begin making the build clearly recognizable.
- **Level 30 — Specialization is pronounced:** specialized and unusual hybrid builds become strongly differentiated.
- **Level 40 — End of the Adventurer Era:** a future capstone should reflect the player's history. **The world begins remembering the player as someone consequential** through reactions and changed conditions—not merely a level label.

The progression system emits milestone hooks at 10, 20, 30, and 40 so future world, narrative, Technique, and UI systems can react without being embedded in Player logic. Milestones are pacing anchors, not automatic entitlement to identical rewards.

## Stats and Techniques

Core stats must be few, understandable, and meaningful. The current foundation uses **Strength, Dexterity, Vitality, and Intellect** while preserving direct combat stats and equipment bonuses. Strength supports physical damage and future stagger/heavy weapons; Dexterity supports scaling, crit, recovery, and mobility; Vitality supports HP, armor, and survival synergies; Intellect is the future base for spell power and magical resources. Base values, allocated points, equipment bonuses, Technique/effect bonuses, level growth, and derived totals remain separately queryable.

**Techniques are data-driven content**, not a rigid class tree. Definitions include ID, name, description, active/passive type, category/tags, unlock source, minimum level, prerequisites, ranks, cooldown/effect data, and a gameplay implementation handler. Techniques may eventually come from levels, teachers, quests, mastery, books, exploration, equipment, factions, titles, or hidden accomplishments.

## Activities, Events, and Quests

Activities should be multi-purpose. A cave, hunt, caravan, ruin, boss, or settlement problem should ideally serve several goals at once: exploration, combat mastery, loot pursuit, quest progress, relationship change, lore, resource acquisition, and world consequence.

Chronicle should rarely give only one reason to act. A future Goblin encounter might simultaneously contribute XP, loot, quest objectives, materials, mastery, hidden accomplishments, regional consequences, and rare-spawn progression; the current milestone implements only the shared hooks needed for systems to interact cleanly later.

Content should be event-driven and extensible. Activities emit structured events; quests, titles, NPC memory, world state, Techniques, and rewards may respond without each activity directly knowing every system. Add new event consumers without coupling them to combat or map scripts.

The quest foundation supports unavailable, available, active, ready-to-turn-in, and completed states; kill, collect, discover, interact, and future event objectives; XP, item, and Technique rewards; prerequisites; recommended levels; optional quests; and chains. Currency, reputation, titles, factions, and world-state rewards remain future extensions.

Quest chains should:

- Build context across multiple places, characters, discoveries, and decisions.
- Reward attention and exploration rather than only objective-marker completion.
- Offer rewards appropriate to the chain: authored gear, Techniques, access, relationships, information, titles, resources, or world changes.
- Preserve meaningful outcomes; not every reward should reduce to XP or currency.

## Gear and Build Identity

- **Common:** clear incremental upgrades.
- **Uncommon:** more distinctive bonuses.
- **Rare:** memorable authored items.
- **Build-defining:** mechanics capable of changing playstyle, regardless of the item's displayed rarity tier.

Gear should change decisions, attack behavior, resource patterns, defenses, movement, status interactions, or synergies—not merely increase numbers. Strong combinations may feel extraordinary, but should retain opportunity costs, weaknesses, counters, or situational limits. Rarity colors and effects remain restrained as defined by the art direction.

## Exploration and Scaling

Exploration may reward hidden maps, caves, treasure, rare enemies, Techniques, lore, titles, shortcuts, unusual gear, and discoveries about world history. Knowledge of where and under what conditions rewards appear is itself progression.

The world should **not scale perfectly to the player**. Some regions, enemies, and discoveries should be dangerous early, approachable later, or unexpectedly manageable through preparation and knowledge. Use authored ranges and readable threat signals so non-perfect scaling creates aspiration and tension rather than arbitrary punishment.

## Interface Direction

The MMO-inspired UI foundation makes progression legible without copying another game's layout or overwhelming play. It includes a bottom HUD/action-bar shell, visible keybinds and cooldown-ready Technique space, XP and health/resource presentation, compact quest tracking, and dedicated Character/Equipment, Inventory, Technique Book, and Quest Log panels.

The Character panel exposes preview space, equipment slots, level/XP, core-stat base/bonus values, derived stats, unspent points, and clickable allocation. Inventory distinguishes secured and expedition loot and preserves equip/unequip flow. Final icon art, visible equipped-gear preview, comparisons, target frames, multiple action bars, and Titles/Badges remain later work. `Tab` is reserved for a future hybrid target cycle while combat stays spatial and action-based. See [UI_UX_DIRECTION.md](UI_UX_DIRECTION.md).

## Hidden Progression Architecture

Hidden progression should eventually evaluate structured events such as enemy defeated, damage taken or avoided, dodge used, low-health survival, item equipped, Technique used, location discovered, quest completed, and expedition survived. Data-defined conditions may later produce titles, badges, accomplishments, behavior progression, world memory, secret branches, and unusual rewards. Evaluation must be deterministic, inspectable for development, and resistant to mindless repetition.

This is an architecture direction **for documentation only**. Do not implement the hidden progression event system yet.

## Later Combat Expression

Later progression may support multi-hit attacks, area-of-effect attacks, multiple simultaneous targets, enemy packs, critical hits, statuses, and dense build synergy. Rapidly stacking damage numbers must remain readable through grouping, timing, hierarchy, motion, and restrained effects so feedback never hides threats or positioning.

## Scope Boundary

The current milestone implements the reusable XP/level, stat allocation, Technique, quest, event-hook, milestone, MMO-style UI structure, and Level 1–5 proof foundations. It does **not** implement forty finished levels, final balance/content, the hidden-accomplishment evaluator, milestone narratives/world memory, final UI art or advanced hotbar systems, advanced combat presentation, or finished living-world visuals.

Continue building one stable layer at a time. Single-player-first development, exploration value, meaningful choice, authored quality, and all existing originality rules remain controlling constraints.
