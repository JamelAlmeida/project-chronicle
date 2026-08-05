# Project Chronicle — Art Direction

> **Visual north star.** This document defines Project Chronicle's visual identity and should be used to judge environments, characters, creatures, equipment, effects, UI, and generated zones.

This direction supports the principles in [PROJECT_VISION.md](PROJECT_VISION.md) and [GameRules.md](GameRules.md): exploration must be inviting, wilderness must feel dangerous, returning home must feel relieving, loot must enable memorable builds, and quality takes priority over quantity.

---

## Visual Identity

Project Chronicle is an original side-view fantasy pixel-art action RPG.

Its visual philosophy draws broad inspiration from three sources:

### World of Warcraft inspiration

- Memorable fantasy regions with extremely distinct identities
- The sense of inhabiting one large, coherent fantasy world
- Iconic gear silhouettes
- Powerful environmental storytelling
- Equipment that visually communicates accomplishment
- Cozy settlements contrasted against dangerous wilderness

### MapleStory inspiration

- Immediately appealing pixel-art charm
- Highly readable characters and monsters
- Visually addictive equipment and loot
- Strong item icons
- Memorable monster personalities
- Satisfying cosmetic progression
- Equipment that is exciting simply to look at

### Project Chronicle's own identity

- More grounded and mature than MapleStory
- More intimate and pixel-art-focused than World of Warcraft
- Ancient, mysterious, beautiful, and occasionally melancholic
- A contemplative old-world fantasy atmosphere
- Warm civilization contrasted with dangerous wilderness
- Expressive characters without extreme chibi proportions
- Gorgeous environments that preserve combat readability
- Original characters, creatures, equipment, regions, and visual language

The game should look charming enough to invite exploration, but dangerous enough that entering the wilderness creates tension.

---

## Core Look

### Technical target

- Modern, handcrafted-looking pixel art
- Flexible environment modules guided by gameplay readability rather than a mandatory tile size
- Humanoids approximately 32×48 pixels as a guideline, not an absolute restriction
- Crisp nearest-neighbor rendering
- Side-view character and world presentation
- Detailed but readable silhouettes
- Detailed layered backgrounds with clear distant, mid-background, gameplay, foreground, and atmospheric depth
- Restrained lighting and magic
- Strong equipment silhouettes

Pixel detail must serve form and readability. Texture, decoration, lighting, and environmental layers should never make the player, enemies, attacks, hazards, or loot difficult to read.

### Shape, color, and atmosphere

- Favor clear large and medium shapes before small pixel detail.
- Give each region a recognizable palette, silhouette vocabulary, materials, architecture, vegetation, and mood.
- Use warm light and signs of life to define civilization.
- Use uncertainty, occlusion, age, scale, and controlled darkness to define wilderness and ruins.
- Keep natural environments comparatively grounded so rare magic and exceptional equipment retain visual power.

---

## Player Character

The starting character is a neutral **Adventurer**, not a Warrior, Mage, Rogue, or other visually predetermined class.

### Starting identity

- Dark travel clothing
- Boots
- Belt and pouches
- Short cloak or mantle
- Readable hair and head silhouette
- Practical adventurer appearance

The base character should look prepared to travel but not yet legendary. Equipment progressively transforms the character and communicates the history of what they have become.

### Equipment-driven identity

A player should eventually recognize another build from its silhouette and equipment before seeing its statistics:

- **Katana / agile build:** lighter silhouette, layered cloth, fast weapon presentation
- **Fortress / defense build:** heavy plate, shield, broad and imposing silhouette
- **Blood / lifesteal build:** dark metal with restrained crimson accents
- **Mage build:** robes, staffs, and controlled magical effects
- **Rogue build:** lighter gear, daggers, hooded or stealth-oriented silhouette

These are visual tendencies, not class uniforms. There is no mandatory visual class identity, and unusual hybrid combinations must remain visually possible.

---

## Equipment and Loot

Loot must look desirable. Finding, inspecting, equipping, and displaying equipment is a central part of Chronicle's visual reward loop.

Important equipment should feature:

- Distinct silhouettes
- Strong icon art
- Restrained rarity presentation
- Memorable names
- Recognizable visual themes
- Visibly different equipped appearances where practical

Avoid progression in which every sword, shield, robe, or ring looks nearly identical and only its numbers change. Visual distinction should communicate function, history, rarity, and accomplishment without relying on excessive glow.

Legendary equipment must look genuinely special. Its appeal should come from authored shape language, materials, details, animation, history, and controlled effects—not merely a brighter outline or a larger particle cloud.

### Current example equipment

#### Swift Katana

- Elegant, narrow silhouette
- Immediate quick and agile identity
- Subtle cool-metal highlights
- A refined profile that remains readable at gameplay scale

#### Bloodfang Blade

- Dangerous asymmetric blade
- Dark steel
- Restrained crimson or blood motif
- Immediately reads as rare without becoming visually noisy

#### Crimson Leech Ring

- Dark metal
- Large, deep-red gemstone
- Slightly ominous rather than cartoonishly evil
- Strong, recognizable inventory icon

---

## Characters and Monsters

Characters and monsters should be **readable, memorable, and personality-rich**. Enemy readability begins with silhouette, posture, scale, movement, and color grouping—not detail alone.

Not every monster should be a grotesque, generic fantasy creature. Some may be charming while still dangerous. Personality should strengthen recognition and anticipation in combat.

### Slime

- Expressive and appealing silhouette
- Satisfying squash-and-stretch animation
- Visually charming without becoming childish
- Clear anticipation and impact poses

### Goblin Scout

- Compact, mischievous character
- Nimble and aggressive silhouette
- Movement and posture that communicate opportunism
- Clearly distinguishable from humanoid NPCs

### Crypt Guardian

- Ancient and imposing
- Heavy armor, stone, and undead visual qualities
- Slow visual weight and substantial silhouette
- Immediately reads as a significant threat

---

## Regional Art Direction

Every region requires a distinct palette, material language, landmark vocabulary, environmental story, and emotional purpose while remaining part of the same coherent world.

### Hearthvale — Home

Hearthvale represents **home**.

Visual ingredients:

- Timber-framed fantasy buildings
- Worn cobblestone
- Warm windows
- Fireplaces and chimneys
- Lanterns
- An inn
- Market stalls
- Gardens
- A fountain or well
- Small environmental stories
- Visible NPC activity

Color and emotional direction:

- Amber light
- Warm wood
- Aged stone
- Life, safety, and comfort

Returning to Hearthvale after a dangerous expedition should create immediate visual relief.

### Elderwood — First Visual Benchmark

Elderwood is Chronicle's first visual benchmark and the preferred setting for its first commercially polished screenshot.

Desired look:

- Ancient temperate fantasy forest
- Side-scrolling trails with solid ground, roots, ledges, and readable elevation changes
- Optional elevated routes that reward curiosity without demanding precision-platformer execution
- Huge old trees
- Moss-covered stones
- Broken ruins
- Bushes
- Flowers
- Mushrooms
- Small streams where appropriate
- Shafts or pockets of light
- Darker, deeper sections
- Environmental clutter arranged intentionally rather than randomly

Emotional direction:

> Beautiful enough to invite exploration; dangerous enough to create uncertainty.

Elderwood should demonstrate the full balance between charm, mystery, combat readability, authored composition, and wilderness tension.

### Mosscrypt — Buried History

Visual ingredients:

- Ancient burial architecture
- Dark masonry
- Collapsed sections
- Moss and roots reclaiming stone
- Candles and torches
- Tombs
- Bones used sparingly
- Deep shadows
- Greenish, damp environmental accents
- Occasional restrained supernatural illumination

Mosscrypt should feel older than Hearthvale, as though history has literally been buried there.

---

## Environment Composition

Environment detail should create story, hierarchy, navigation, and mood.

- Compose intentional clusters and quiet spaces; do not fill every tile.
- Use paths, clearings, sightlines, landmarks, light, and material changes to guide exploration.
- Layer foreground, play space, and background without hiding combat information.
- Place clutter according to believable causes: growth, travel, weather, habitation, conflict, collapse, or ritual.
- Let architecture, remains, repairs, camps, tracks, and resource use imply events without exposition.
- Preserve strong negative space around combat areas, interactables, and important loot.

### Finished living-world target

Finished maps should feel like **living fantasy places**, not static platform layouts. Their architecture should be capable of supporting layered parallax; moving clouds and distant environmental motion; swaying foliage and animated grass/flowers; drifting leaves, particles, fog, mist, waterfalls, insects, birds, and small ambient creatures; restrained glowing mushrooms or magic; animated props and appropriate background NPC/world activity; environmental lighting changes; strong landmarks; foreground framing; and subtle screen-space atmosphere. These layers should create depth and life without obscuring routes, hazards, enemies, loot, or combat effects.

This is a future visual target, **not part of the current implementation scope**. Add it incrementally only after gameplay readability and the current benchmark needs are secure.

---

## User Interface

Chronicle's UI combines elegant dark-fantasy presentation, satisfying RPG gear readability, and clear pixel-art item icons.

### Visual ingredients

- Charcoal and black panels
- Aged metal
- Restrained gold or brass accents
- Subtle ornamental corners
- Excellent icon readability
- Carefully used rarity colors
- Highly readable typography

The equipment screen should make players want to collect things. Item silhouettes, equipped appearance, comparison information, and meaningful properties should remain easy to understand.

The planned interface may draw on the information clarity of MMO RPGs while remaining original and appropriate to a single-player side-scrolling game. A future character panel should make level, XP, meaningful core stats, equipment, Techniques, titles, milestone progress, and build comparisons easy to scan. It must not reproduce another game's UI layout. The current progression panel is a functional prototype; the finished panel is **not part of the current implementation scope**.

### Avoid

- Generic mobile-game UI
- Excessive glowing borders
- Clutter
- Cheap-looking fantasy parchment used everywhere
- Rarity effects that overwhelm item art
- Decoration that reduces readability

---

## Combat Effects

Combat presentation should eventually support:

- Weapon arcs
- Trails
- Hit flashes
- Hit pause
- Damage particles
- Restrained screen shake
- Loot sparkle
- Spell effects
- Enemy telegraphs
- Readable multi-hit, area-of-effect, and multi-target feedback
- Enemy-pack clarity
- Critical-hit, status, and build-synergy feedback
- Rapidly stacking damage numbers with clear timing and hierarchy

Effects must communicate timing, direction, force, damage, and danger. They must never obscure enemy telegraphs, hazards, projectiles, or the player's position.

Use short-lived, shaped effects with deliberate color and value separation. Strong effects should be reserved for strong events so ordinary attacks do not exhaust the visual range.

These advanced combat visuals are a later target and are **not part of the current implementation scope**.

---

## Magic

Magic is special. The ordinary world should not constantly glow.

Natural environments, common equipment, and everyday civilization should remain comparatively grounded. Magical colors and illumination become more impressive through contrast and scarcity.

Use magical light, particles, emissive colors, and distortion with restraint. Their hue, shape, rhythm, and source should communicate a specific school, origin, creature, item, or historical force rather than serving as generic fantasy decoration.

---

## Procedural World Art Requirements

Future generated zones must look **authored**.

Procedural generation should compose:

- Terrain
- Paths
- Landmarks
- Vegetation clusters
- Ruins
- Resources
- Enemy territory
- Points of interest

Composition must follow biome-specific artistic rules for density, clustering, spacing, palette, materials, landmark frequency, traversal, narrative logic, and threat escalation.

Do not scatter objects randomly or uniformly across maps. Generated worlds must preserve the strong regional identities, meaningful composition, and environmental storytelling expected from handcrafted fantasy RPG zones.

---

## First Polished Benchmark Scene

The first polished benchmark scene is set in **Elderwood** and contains:

- Player Adventurer
- Slime
- Goblin Scout
- Swift Katana
- Grass variants
- Dirt trail
- Large trees
- Rocks
- Bushes
- Flowers and mushrooms
- Mossy ancient ruins
- Sword attack VFX
- Loot pickup
- Polished basic HUD

This scene is the visual proof for side-view character scale, layered environmental depth, vertical exploration, combat readability, item appeal, effects restraint, and UI cohesion.

Once it achieves strong visual cohesion, its quality and visual language become the benchmark for expanding the rest of Chronicle. New work should meet that standard rather than merely increasing asset quantity.

---

## Inspiration and Originality Rule

World of Warcraft and MapleStory are design inspirations only.

Never directly reproduce their:

- Characters
- Creatures
- Environments
- Icons
- Equipment
- UI layouts
- Races
- Factions
- Logos
- Specific visual assets

Do not trace, recolor, closely imitate, or assemble recognizable elements from those works. References should be translated into high-level principles—regional identity, readability, equipment desire, personality, contrast, and progression—then resolved through Chronicle's own lore, shapes, palettes, materials, proportions, motifs, and authored assets.

Project Chronicle must develop a recognizable visual identity of its own.

---

## Visual Review Checklist

Before approving visual work, ask:

1. Is it immediately readable at gameplay scale?
2. Does it strengthen exploration, risk, discovery, builds, comfort, or the sense of a living fantasy world?
3. Does it belong unmistakably to its region while remaining coherent with Chronicle?
4. Does detail feel intentional rather than uniformly scattered?
5. Does equipment communicate function, identity, and accomplishment through silhouette?
6. Are magic, rarity, lighting, and effects restrained enough to preserve their impact?
7. Does it preserve combat clarity?
8. Is it original rather than a reproduction of an inspiration?
9. Does it meet the Elderwood benchmark for cohesion and craft?
