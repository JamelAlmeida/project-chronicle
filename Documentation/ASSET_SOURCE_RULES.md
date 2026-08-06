# Project Chronicle — Asset Source Rules

> Concise production lock for visual assets. When in doubt, prefer approved packs and archive everything else.

Related: [APPROVED_ART_ONLY.md](APPROVED_ART_ONLY.md), [ART_DIRECTION.md](ART_DIRECTION.md), [UI_UX_DIRECTION.md](UI_UX_DIRECTION.md).

---

## Approved visual source rules

1. **Only approved supplied Chronicle asset packs** are active production art for normal gameplay presentation.
2. **Old programmer art** (Polygon2D / ColorRect buildings, primitive terrain, fake windows, blocky town pieces) is **deprecated** and must not be re-enabled as presentation.
3. **Malformed generated-text UI textures** are **deprecated**.
4. **Baked example damage numbers** (`70`, `236`, `512`, `736`, `796`, `2147`, baked `CRIT!` glyph sheets) are **reference-only** — never runtime combat text.
5. **Filler action-bar icons** (sample spells, invented consumables, showcase ability stickers) are **not** used. Empty slots stay empty until real content is assigned.
6. **Runtime UI text must be native Godot text** (Labels / RichTextLabel). Ornament frames never carry gameplay strings.
7. **Cursor does not invent** final environment or final UI ornament. Integrate approved packs instead.

---

## Active approved roots

| Role | Path |
|---|---|
| Adventurer (player default preset) | `Assets/Characters/Adventurer/Runtime/` |
| Player modular pipeline (forward, empty until authored) | `Assets/Characters/Player/` |
| Environment crops (Hearthvale / Elderwood) | `Assets/Showcase/Runtime/Environment/` |
| Environment modular pipeline (forward) | `Assets/Environment/` |
| Combat FX + Showcase slime | `Assets/Showcase/Runtime/Combat/` *(slime SpriteFrames retired from live Slime scene; awaiting new enemy pack)* |
| FX modular pipeline (forward) | `Assets/FX/` |
| UI furniture (frames, bars, slots, buttons, medallions) | `Assets/Showcase/Runtime/UI/` *(legacy ornament; live HUD is flat until new pack)* |
| Assigned action icons (attack / dash / crest) | `Assets/UI/Icons/` |
| Item icons / world drops (forward) | `Assets/Items/Icons/`, `Assets/Items/WorldDrops/` |
| Enemy / item PixelArt still in live use | `Assets/PixelArt/Characters/{GoblinScout,CryptGuardian}/`, `Assets/PixelArt/Items/` |
| Fonts | `Assets/Fonts/` |

Pipeline contract: [ART_PIPELINE.md](ART_PIPELINE.md).

Mount environment art under scene node `ApprovedEnvironmentArt`. Keep gameplay collision separate under `Gameplay/Collision`.

---

## Reference-only

| Role | Path |
|---|---|
| Master mockup (visual authority) | `Assets/Showcase/Source/chronicle_master_visual_target.png` |
| Showcase source sheets | `Assets/Showcase/Source/` |
| Adventurer source sheet | `Assets/Characters/Adventurer/Source/` |
| Older UI / PixelArt source dumps | `Assets/ReferenceOnly/` |

Reference assets guide style. They are not spawned as gameplay widgets.

---

## Legacy / deprecated

| Role | Path |
|---|---|
| Hard Visual Reset archive | `LegacyVisuals/` |
| Obsolete UI generations (ChronicleV2, oldest Runtime kit) | `LegacyVisuals/UI/` |
| Filler action / sample icons | `LegacyVisuals/UI/FillerActionIcons/`, `LegacyVisuals/UI/ShowcaseFillerIcons/` |
| Baked combat number glyphs | `LegacyVisuals/Combat/BakedNumberGlyphs/` |
| Superseded PixelArt player / slime | `LegacyVisuals/Characters/` |
| Retired immersion scripts | `LegacyVisuals/Scripts/Presentation/` |
| Older Elderwood pixel pack | `LegacyVisuals/Environment/PixelArt_Elderwood/` |

Do not attach LegacyVisuals to live scenes. Do not restore ChronicleV2 as a second UI root.

---

## Action bar content rule

- Slot **frames** may remain (mockup framing).
- **Assigned** slots show that action’s real icon only.
- **Unassigned** slots stay visually empty (keybinds may remain).
- **Locked** slots show locked state only — no filler art underneath.
- Showcase mockup ability icons are art-direction reference, not production fillers.

## Damage number rule

- Display the **resolved combat amount** with Godot Labels.
- Never spawn baked example number sprites as damage output.

## UI text rule

- Expedition, quests, HP/XP, menus, damage numbers → Godot text.
- UI pack provides chrome only.
