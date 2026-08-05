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
