# Approved Art Only — Production Rule

> Effective from the **Hard Visual Reset** milestone onward.

> **Source lock:** See [ASSET_SOURCE_RULES.md](ASSET_SOURCE_RULES.md) for the active / reference / legacy split, action-bar content rule, damage-number rule, and UI text rule.

## Rule

Approved supplied Chronicle asset packs are the **only** visual source of truth for normal gameplay presentation.

### Cursor must not

- Invent final environment artwork
- Create replacement buildings from `Polygon2D` / `ColorRect`
- Create final UI ornament from primitive geometry
- Treat previous failed visual passes (programmer blockouts, improvised immersion generators, retired UI skins) as active presentation
- Use baked example damage-number sprites or filler action-bar icons as production content

### Cursor is responsible for

- Processing, slicing, placing, animating, layering, and integrating **approved** art packs
- Keeping gameplay systems, collision, and Control/script bindings intact while visuals are swapped
- Mounting approved art under clear scene nodes such as `ApprovedEnvironmentArt`
- Recreating HUD/windows from the approved mockup using `Assets/Showcase/Runtime/UI/` ornament crops and native Godot text

### Primitive shapes remain allowed for

- Invisible collision (`StaticBody2D` / `CollisionShape2D` / `Area2D`)
- Debug visualization
- Temporary developer-only tools

They must **not** appear in normal gameplay presentation.

## Scene structure principle

```
WorldScene
├── Background
├── Midground
├── Gameplay
│   ├── Collision
│   ├── Player
│   ├── Enemies
│   ├── Loot
│   └── Interactions
├── ApprovedEnvironmentArt
├── Foreground
└── FX
```

Approved artwork and gameplay collision stay separate.

## Legacy safety

Uncertain or retired visuals live under `LegacyVisuals/` and `Assets/ReferenceOnly/`. They are not attached to active play scenes. Do not permanently destroy uncertain assets without an archive path.

## Related

- [ASSET_SOURCE_RULES.md](ASSET_SOURCE_RULES.md) — active / reference / legacy inventory + content rules
- [ART_DIRECTION.md](ART_DIRECTION.md) — visual identity north star
- [UI_UX_DIRECTION.md](UI_UX_DIRECTION.md) — HUD/panel direction (approved packs only after reset)
- [LegacyVisuals/README.md](../LegacyVisuals/README.md) — retired visual archive
