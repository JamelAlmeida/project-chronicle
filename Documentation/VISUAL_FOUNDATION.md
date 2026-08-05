# Visual Foundation v0.1

## Character sprite contract

Assign a `SpriteFrames` resource to:

- Player: `Visuals/PlayerSprite`
- Slime, Goblin Scout, Crypt Guardian: `Visuals/CharacterSprite`

Preferred directional animation names use the suffixes `_down`, `_up`, `_left`, and
`_right`.

Player states:

- `idle`
- `run` (falls back to `walk` or `move`)
- `melee_attack` (falls back to `attack`)
- `dodge`
- `hurt`
- `death`

Enemy states:

- `idle`
- `walk` (falls back to `move`)
- `attack`
- `hurt`
- `death`

Generic, non-directional names are also accepted. Partial sprite sets remain visible:
the controller uses a compatible idle/default animation when a state is missing, and
uses the existing geometry placeholder when no usable animation frames exist.

Enemy death animations are detached from the defeated gameplay body so loot and enemy
removal remain immediate. The player exposes `death_presentation_delay` (default `0`)
for matching a future death clip without changing current respawn timing.

## World art layers

Hearthvale, Elderwood, and Mosscrypt provide:

- `GroundLayer`
- `PathsFloorsLayer`
- `DepthSorted/TerrainLayer`
- `DepthSorted/PropsLayer`
- `DepthSorted/FoliageDecorationsLayer`
- `CollisionLayer`
- `ForegroundOverheadLayer`
- `DepthSorted/InteractablesLayer`
- `DepthSorted/EnemiesLayer`

Place trees, standing props, and other depth-sensitive art below `DepthSorted`.
Ground and floor art uses fixed negative Z indices; overhead art uses a fixed positive
Z index.

## Optional effect registration

`CombatFeedback` exposes presentation-only slots for:

- `damage_particles`
- `enemy_death`
- `loot_sparkle`
- `weapon_trail`

Register a `PackedScene` with `CombatFeedback.register_effect(name, scene)`. Unassigned
effects are safe no-ops and do not affect combat, loot, or entity lifetime.

The player's `Camera2D` also exposes disabled-by-default smoothing and a
`request_shake()` method for subtle combat presentation.
