# Project Chronicle — Player Update 02

STATUS: CURSOR INTEGRATION PACKAGE — CORE PLAYER MOVEMENT/REACTION FIRST PASS

## Art authority
ChatGPT = artist / art director.
Cursor = engineer / integrator.
Cursor must not redraw or invent final Chronicle art.

## Locked player technical standard
- Runtime frame: 96 × 112 px
- Center: X = 48
- Standing ground baseline: Y = 102
- Sprite scale: 1.0
- Author RIGHT, flip for LEFT where appropriate
- Gameplay collision remains independent from visual art

## Included runtime assets

### 1. S-key prone / low dodge
`Runtime/Prone/`
- 3 normalized frames + strip
- Intended as an extremely low held posture for dodging high/flying attacks.
- This is a real gameplay stance, not merely cosmetic.

### 2. Jump
`Runtime/Jump/`
- 5 normalized frames + strip
- Physics remain authoritative. Animation must not translate CharacterBody2D.

### 3. Universal hurt / hit reaction
`Runtime/Hurt/`
- 3 normalized frames + strip
- Neutral all-direction flinch.
- Do NOT interpret art as directional knockback.
- Gameplay code may apply knockback in the correct world direction independently.
- Animation communicates interruption/pain only.

### 4. Defeated pose
`Runtime/Death/adventurer_defeated_00.png`
- Single readable final defeated pose.
- Non-gory.
- May be held after the existing death transition until a multi-frame death fall is authored later.

## Approved visual reference
`Reference/approved_adventurer_visual_reference.png`
This is the hard reference for face, hair, body proportions, starter shirt/chest, pants, belt, boots, rendering and overall clean graphic-designed sprite language.

## Explicitly NOT supplied as replacement runtime art in this package
- Run: previous generated candidates are rejected for production use. KEEP current working in-game run.
- Dash: previous generated candidates are rejected for production use. KEEP current working in-game dash.
- Landing: no approved dedicated landing animation yet. Use fall/jump -> idle/run transition.
- Long Sword attack: generated attack poses are still direction/reference candidates, not permanent modular runtime art. KEEP current melee visual for this update.

Do not fabricate filler assets for the missing items.

## Current game-direction lock relevant to engineering
Chronicle is now a 45–60 minute side-scrolling fantasy action roguelike built on MMO/RPG fundamentals. Build identity develops rapidly during a run through stats, Techniques/upgrades and visible equipment. This does NOT change the scope of this art integration task.

## Visible equipment rule
The default Adventurer is only the starter/base appearance.
What is actually equipped must eventually drive visible:
- Main Hand
- Offhand
- Helm
- Cloak
- Chest
- Bracer
- Gloves
- Belt
- Pants
- Boots
Other non-visible/stat slots include neck, 2 rings and 2 trinkets unless we later art-direct visible treatment.

Starter weapons planned later:
- Apprentice Staff
- Poleaxe
- Long Sword

Do not build those visuals during this update.
