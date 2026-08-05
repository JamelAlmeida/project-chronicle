# Project Chronicle

## Core Philosophy

Every adventure permanently changes the world.

## Development Rules

If a feature does not make exploration more exciting...

Don't build it.

If it makes exploration more exciting...

Build it well.

Quality > Quantity

Player stories > Scripted stories

Meaningful choices > Endless content

Singleplayer First

Multiplayer Later

AI Enhances

AI Never Replaces Gameplay

## Progression Rule

> **Levels give structure. The world gives reasons. Gear gives obsession. Builds give identity. Secrets give stories.**

The planned Adventurer Era spans levels 1–40 across character, build, and world progression. Levels pace meaningful stat choices and Techniques; they do not replace exploration, authored rewards, gear pursuit, emergent identity, or world consequence. Activities should serve multiple purposes and communicate through extensible structured events rather than isolated one-off systems.

The reusable XP/level, stat allocation, Technique, quest, event-hook, milestone, UI foundation, and Level 1–5 proof foundations are the current progression layer. Forty finished levels, final UI art, hidden accomplishments, advanced combat presentation, and finished living-world art remain future work; documenting them does not expand the active milestone.

## Interface Rule

Chronicle is a desktop action RPG. Its interface is bottom-anchored, readable, dark-fantasy in tone, and MMO-inspired in usefulness without copying another game's layout. Character, inventory, Technique, and quest information belong in deliberate panels—not permanent debug dumps. Reject mobile-gacha clutter, autoplay-style controls, noisy top-screen icon fields, and decoration that obscures play. See [UI_UX_DIRECTION.md](UI_UX_DIRECTION.md).

## Current Gameplay Foundation

Project Chronicle is a **2D side-scrolling fantasy action RPG**. The player moves left and right, jumps through readable vertical spaces, uses a horizontal combat dash, and attacks in the direction the Adventurer faces. Chronicle is an action RPG first: traversal should feel responsive and forgiving rather than demand extreme platforming precision.

World maps should support solid ground, selected one-way platforms, optional elevated routes, drops, layered backgrounds and foregrounds, and clear left/right exits. Interconnected maps must preserve player state and the secure/unsecured expedition loop.

## Collision Layers

Keep these Godot 2D physics layers consistent:

1. **Player** — the Adventurer body.
2. **Terrain** — solid ground, walls, and one-way platforms.
3. **Enemies** — enemy CharacterBody2D bodies.
4. **Player Attacks** — melee and future player-owned attack hitboxes.
5. **Pickups** — loot collection areas.
6. **Transitions** — map exits, doors, caves, and portals.

Do not assign new collision layers ad hoc. Document a new responsibility here before adding another shared layer.
