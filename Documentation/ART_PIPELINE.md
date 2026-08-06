# Project Chronicle — Readability-First Art Pipeline

> Engineer preparation milestone. ChatGPT is artist / art director. Cursor integrates approved assets only.
> Related: [ART_DIRECTION.md](ART_DIRECTION.md), [ASSET_SOURCE_RULES.md](ASSET_SOURCE_RULES.md), [APPROVED_ART_ONLY.md](APPROVED_ART_ONLY.md).

---

## Player technical standard

| Spec | Value |
|------|--------|
| Runtime frame | **96 × 112** px |
| Center X | **48** |
| Standing foot baseline Y | **102** |
| Visible standing height | ≈ **90–96** px |
| Sprite scale | **1.0** |
| Primary authored direction | **RIGHT** |
| Left-facing | horizontal flip (`mirror_left_from_right`) |
| Collision | independent of sprite art |

The live Adventurer kit (`Assets/Characters/Adventurer/`) is the **default base preset**, not a permanently fixed protagonist.

---

## Node mapping (live player)

Live root remains `Visuals` (alias of VisualRoot — not renamed to avoid breaking paths).

| Target name | Live node | Status |
|-------------|-----------|--------|
| VisualRoot | `Visuals` | Active |
| BaseBody | `Visuals/BaseCharacter` | Temporary **combined** Adventurer `AnimatedSprite2D` |
| HairBack | `Visuals/HairBack` | Empty hook |
| HairFront | `Visuals/HairFront` | Empty hook |
| EquipmentVisuals/* | present | Empty hooks, draw order: Cloak → Legs → Feet → Body → Hands → Head → MainHand → OffHand |
| CharacterFX | `Visuals/CharacterFX` | Empty hook |

Do not populate empty layers with programmer art.

---

## Synchronized animation contract

Future modular layers (body, hair, gear) must share:

- animation **name**
- **frame index** / **frame count** / **timing**
- **96×112** canvas
- center **X=48**, baseline **Y=102**
- authored facing **RIGHT** (+ flip for left)

### Vocabulary (target)

| Contract name | Live Adventurer kit status | Controller state today |
|---------------|----------------------------|------------------------|
| `idle` | Present (`idle` / `idle_right`) | `idle` |
| `run` | Present (`run` / `run_right`) | locomotion = `run` |
| `jump` | Present | `jump` |
| `fall` | Present | `fall` |
| `land` | **Absent** — do not invent | — |
| `dash` | Present (`dash` / `dash_right`; also used for dodge) | `dodge` → dash art |
| `melee_01` | Present as `melee_basic` / `attack` / `*_right` | `attack` |
| `melee_02` | **Absent** | — |
| `hit` | **Absent** (controller looks for `hurt`) | `hurt` |
| `death` | **Absent** | `death` |

Also present but not in the short vocabulary: `walk`, `walk_right`.

When modular art arrives, prefer the contract names above; keep aliases in `CharacterVisualController` until migration is complete.

---

## Visible equipment data hook

**Existing system kept:** `ItemData` → `EquipmentData` + `EquipmentComponent` slots (`weapon`, `offhand`, `head`, `chest`, `hands`, `feet`, `ring1`, `ring2`, `amulet`).

**Smallest future-facing hook (implemented, unset on all items):**

- `EquipmentData.appearance: EquipmentAppearanceData` (optional Resource)
- `EquipmentAppearanceData` fields: `visual_set_id`, `equipment_layer`, `layer_frames`, `static_texture`, `hides_hair`

**Not done (next integration task):** bind `equipment_changed` → layer sprites. No fake appearance data on existing items.

Slot → layer mapping (intended):

| Equipment slot | Layer node |
|----------------|------------|
| chest | Body (+ Cloak if tagged) |
| head | Head (`hides_hair` when helmet) |
| hands | Hands |
| feet | Feet |
| weapon | MainHand |
| offhand | OffHand |
| legs (future) | Legs |

---

## World-drop visual hook

**Existing:** `LootPickup` uses item icon (or ColorRect fallback).

**Hook (implemented):** `ItemData.world_sprite` optional; pickup prefers `world_sprite` then `icon`.

Target size for normal drops: **≈24–40 px** longest dimension.

Rarity presentation: use `EquipmentData.rarity` later for halo/outline — not wired yet; keep ColorRect/Polygon fallbacks disabled when a real texture exists.

---

## Environment authoring (32 px art grid)

**Art authoring grid:** primary **32×32**, optional **16** sub-grid.  
**Does not** force 32×32 collision boxes.

**Current live architecture (Elderwood):**

- `Background` (z≈-40)
- `Midground` (z≈-25)
- `ApprovedEnvironmentArt` (z≈-10) — Sprite2D props / ground crops
- `Gameplay/Collision` — StaticBody2D shapes independent of art
- Temporary gray NeutralPlayableSurface ColorRects still exist in some sideview entries

**Recommendation:** keep Sprite2D / modular prop placement first. Introduce TileMap **only** when ChatGPT delivers a coherent terrain tileset and zone authoring needs painting; do not rebuild zones now.

Support eventually: terrain tiles, platform caps/sides/corners, slopes (if gameplay supports), vegetation overlays, structures, props, foreground, midground, parallax backgrounds.

### Readability bands

| Band | Role | Live nodes (approx) |
|------|------|---------------------|
| 1. Gameplay | player, enemies, NPCs, loot, interactables, playable terrain | `Gameplay`, characters, pickups |
| 2. Midground | structures, vegetation, storytelling | `Midground`, decorative `ApprovedEnvironmentArt` |
| 3. Background | distant terrain, skyline, atmosphere, parallax | `Background` |

---

## Pixel-art import status

| Setting | Value | Notes |
|---------|-------|--------|
| `textures/canvas_textures/default_texture_filter` | **0 (Nearest)** | Good |
| `2d/snap/snap_2d_transforms_to_pixel` | **true** | Good |
| `2d/snap/snap_2d_vertices_to_pixel` | **true** | Good |
| Adventurer import mipmaps | **false** | Good |
| Player sprite scale | **1.0** | Good |
| Camera `gameplay_zoom` | **1.68** | Non-integer — softens pixels under zoom; **do not change** without art-director approval |
| Some env Sprite2D scales | e.g. 0.92 / 0.72 / 0.58 | Temporary showcase crops — replace with 1.0 modular art later |

No project-wide setting changes made in this milestone.

---

## Forward asset folders

New assets go under:

```
Assets/Characters/Player/{Source,Runtime,Customization,Equipment}/
Assets/Enemies/{Source,Runtime}/
Assets/Items/{Icons,WorldDrops}/
Assets/Environment/{Terrain,Props,Structures,Backgrounds}/{Source,Runtime}/
Assets/FX/{Source,Runtime}/
Assets/UI/  (existing Icons remain)
```

**Do not migrate** `Assets/Characters/Adventurer/` or Showcase packs in this milestone — they remain the live default until ChatGPT delivers replacements.
