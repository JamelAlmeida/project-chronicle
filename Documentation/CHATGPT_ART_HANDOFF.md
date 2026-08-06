# PROJECT CHRONICLE — HANDOFF BRIEF FOR CHATGPT (ART / ART DIRECTION)

**Role split**
- **ChatGPT** = artist / art director (create approved visual assets)
- **Cursor / Engineer** = integrator (architecture, hooks, no final art)

**Do not invent final character, armor, item, enemy, environment, tile, or UI ornament art in code.**  
**All important in-game text must remain native Godot text** (titles, keybinds, HP/XP, quests, item names, cooldowns). Do not bake gameplay wording into UI images.

---

## 1. PRODUCT / VISUAL GOALS

Readability-first 2D side-scrolling fantasy RPG.

Priorities:
- Extremely readable player
- Clearly visible equipped gear
- Obvious world item drops
- Strong enemy silhouettes
- Clear platforms / traversal
- Modular reusable map assets
- Simple, digestible sprite language
- Production-friendly pipeline
- Original Chronicle identity (do not copy another game’s exact designs)

Current live build uses:
- Temporary clean neutral HUD scaffold (intentional)
- Temporary / placeholder environment blockout in places (intentional)
- Approved Adventurer kit as **default base preset only** (not a permanently fixed protagonist)

---

## 2. PLAYER ART STANDARD (LOCKED)

| Spec | Value |
|------|--------|
| Runtime frame | **96 × 112 px** |
| Center | **X = 48** |
| Standing foot baseline | **Y = 102** |
| Visible standing height | ≈ **90–96 px** |
| Sprite scale | **1.0** |
| Primary authored direction | **RIGHT** |
| Left-facing | horizontal flip |
| Collision | independent of artwork |

### Current live player art
- SpriteFrames: `Assets/Characters/Adventurer/Runtime/adventurer_kit_v1_sprite_frames.tres`
- Runtime atlases: `runtime_idle`, `runtime_run`, `runtime_walk`, `runtime_jump`, `runtime_fall`, `runtime_dash`, `runtime_melee_basic`
- This is the previously integrated Adventurer kit (default preset)

### Animations currently present
`idle`, `idle_right`, `walk`, `walk_right`, `run`, `run_right`, `jump`, `jump_right`, `fall`, `fall_right`, `dash`, `dash_right`, `dodge`, `dodge_right`, `attack`, `attack_right`, `melee_basic`, `melee_attack_right`

### Animations in the target contract but **not authored yet**
`land`, `melee_02`, `hit` (hurt), `death`

Do **not** manufacture missing animation artwork as filler.

---

## 3. MODULAR CHARACTER ARCHITECTURE (ENGINE READY)

Live hierarchy (empty layers have **no sprites**):

```
Player
└── Visuals  (= VisualRoot)
    ├── HairBack          (empty)
    ├── BaseCharacter     (temporary COMBINED Adventurer AnimatedSprite2D)
    ├── HairFront         (empty)
    ├── EquipmentVisuals
    │   ├── Cloak         (empty)
    │   ├── Legs          (empty)
    │   ├── Feet          (empty)
    │   ├── Body          (empty)
    │   ├── Hands         (empty)
    │   ├── Head          (empty)
    │   ├── MainHand      (empty)
    │   └── OffHand       (empty)
    └── CharacterFX       (empty)
```

### Critical character rule
The Adventurer is a **default base preset**.  
Chronicle will support:
- character customization
- **visible equipment** driven by what is actually equipped

Examples:
- equipped helmet → helmet visible; unequipped → selected hair visible
- equipped chest / sword / shield → matching visible pieces

**Do not design the permanent character as one permanently baked full outfit sheet.**  
When modular art is ready, layers should share animation name, frame index, frame count, timing, 96×112 canvas, X=48, Y=102.

### Target shared animation vocabulary
`idle`, `run`, `jump`, `fall`, `land`, `dash`, `melee_01`, `melee_02`, `hit`, `death`

---

## 4. EQUIPMENT / ITEM VISUAL HOOKS (ENGINE READY — UNSET)

Existing equipment system remains. Small optional hooks added:

### Inventory icon
`ItemData.icon` — UI / inventory

### World drop sprite
`ItemData.world_sprite` — optional; loot pickup prefers this, else falls back to `icon`  
**Target size:** ≈ **24–40 px** on the longest dimension for normal drops

### Visible equipped gear
`EquipmentData.appearance → EquipmentAppearanceData`
- `visual_set_id`
- `equipment_layer`
- `layer_frames` (SpriteFrames for modular layer)
- `static_texture` (optional non-animated piece)
- `hides_hair` (helmets etc.)

**No fake appearance data was filled on existing items.** Assign only when real approved art exists.

Intended slot → layer map:
| Slot | Layer |
|------|--------|
| chest | Body (+ Cloak if needed) |
| head | Head |
| hands | Hands |
| feet | Feet |
| weapon | MainHand |
| offhand | OffHand |
| legs (future) | Legs |

---

## 5. HUD GEOMETRY AUDIT (1920 × 1080) — FOR NEW UI ART

Live HUD is the **clean neutral scaffold**. Do not redesign layout. Decorative frames should fit these live sizes.

### Display
- Reference: **1920 × 1080**
- Stretch: `canvas_items` / `expand` (must stretch; not fixed-pixel only)
- HUD root: `GameHUD` CanvasLayer (layer 10)
- Backgrounds today: flat `PanelContainer` StyleBoxFlat only (old ornament disabled)

### Exact live geometry table

| Element | X | Y | W | H | Type |
|---------|---|---|---|---|------|
| ExpeditionPanel | 16 | 12 | 220 | 71 | PanelContainer |
| QuestTracker | 1640 | 12 | 264 | 118 | PanelContainer |
| BottomHUD scaffold | 16 | 928 | 1888 | 140 | MarginContainer |
| PlayerStatus island | 16 | 928 | 697 | 116 | PanelContainer |
| ActionBarShell island | 723 | 928 | 941 | 116 | PanelContainer |
| MenuButtons island | 1674 | 928 | 230 | 116 | PanelContainer |
| ExperienceBar / XP | 16 | 1050 | 1888 | 18 | ProgressBar strip |
| ZoneBanner | 780 | 72 | 360 | 70 | PanelContainer |

### Three visual HUD islands (preserve)
Gaps: Status→Action **10px**, Action→Menu **10px**, islands→XP **6px**.

**Important:** BottomHUD scaffold is wide (1888). Final decorative art should **NOT** necessarily become one continuous giant bar. Dress the three islands separately.

### Expedition panel
- Padding: 10 H / 8 V
- Title + body + inventory hint are **Godot Labels**

### Quest tracker
- Padding: 10 H / 8 V
- Title + RichTextLabel body are **Godot text**

### Player status bars
| Bar | Outer size | Thickness |
|-----|------------|-----------|
| HP | 677 × 24 | 24 |
| Steadfast | 677 × 18 | 18 |
| XP (separate full-width strip) | 1888 × 18 | 18 |

Values / labels = Godot text over bars.

### Action bar
| Spec | Value |
|------|--------|
| Slots | **8** (Attack, Dash, Hotbar 1–5, Reserved) |
| Authored slot min | **58 × 72** |
| Live slot size | **58 × 104** (row stretches height) |
| Gap | **6** |
| Slot strip span | **506** centered in shell |
| Icon region | **50 × 40** |
| Keybind | Godot Label under icon |
| Cooldown | Godot Label overlay |
| Empty slots | **must stay empty** (no filler icons) |

Assigned icons today: gameplay `Assets/UI/Icons/attack.png`, `dash.png` only. Hotbar empty unless technique has real icon.

### Menu buttons (2×2 grid)
Each button **104 × 40**; h/v gap **6**; labels are Godot Button text (`CHARACTER [C]`, etc.).

### Safe NinePatch margins (technical)
| Asset | Suggested corner margins L/R/T/B |
|-------|----------------------------------|
| Large panel frame | 16 / 16 / 16 / 16 |
| Compact tracker | 12 / 12 / 12 / 12 |
| Action slot | ≤ 8 / 8 / 8 / 8 |
| Menu button | 10 / 10 / 8 / 8 |
| Status panel | 16 / 16 / 14 / 14 |

Prefer: NinePatch / StyleBoxTexture for stretchable frames; fixed TextureRect for icons; stretchable bar fills.

### Old UI art status
Showcase/Legacy UI ornament files still exist on disk but are **not loaded by live HUD**. Do not restore old ornament; deliver a new modular pack sized to the table above.

---

## 6. ENVIRONMENT AUTHORING STANDARD

| Spec | Value |
|------|--------|
| Primary art module | **32 × 32 px** |
| Optional detail sub-grid | **16 px** |
| Collision | **not** required to be 32×32 boxes |

Live zones already separate:
1. **Gameplay layer** — player, enemies, loot, interactables, playable terrain  
2. **Midground** — structures, vegetation, storytelling  
3. **Background** — distant terrain, skyline, atmosphere / parallax  

Engine recommendation: modular Sprite2D props first; TileMap only when a real terrain tileset is delivered. Do not rebuild current blockout yet.

Needed eventually: terrain tiles, platform caps/sides/corners, slopes (if gameplay supports), grass overlays, structures, props, foreground, midground, backgrounds.

---

## 7. PIXEL RENDERING NOTES (FOR ARTISTS)

- Project default filter: **Nearest**
- Pixel snap: ON
- Player scale: **1.0** (good)
- Camera zoom currently **1.68** (non-integer — softens pixels; engineer will not change without art-director request)
- Some temporary environment sprites use non-1.0 scales — replace later with 1.0 modular pieces

---

## 8. WHERE TO DROP NEW ASSETS

Forward-only folders (empty until you supply art):

```
Assets/Characters/Player/{Source,Runtime,Customization,Equipment}/
Assets/Enemies/{Source,Runtime}/
Assets/Items/{Icons,WorldDrops}/
Assets/Environment/{Terrain,Props,Structures,Backgrounds}/{Source,Runtime}/
Assets/FX/{Source,Runtime}/
```

Keep **Source** (raw) and **Runtime** (Godot-ready) separate.  
Do not relocate the live Adventurer kit until modular replacements are ready.

Full engineer contract: `Documentation/ART_PIPELINE.md`

---

## 9. WHAT CHATGPT SHOULD CREATE NEXT (SUGGESTED ORDER)

1. **Modular UI ornament pack** sized to the HUD geometry table (three islands + expedition + quest tracker + slots + buttons + bars) — frames only, **no baked text**
2. **Player modular layer sheets** (96×112, shared timing) for base body + hair, then equipment layers
3. **World-drop sprites** (24–40 px) separate from inventory icons
4. **32×32 environment modules** for readable platforms / terrain / props
5. Enemy silhouette packs as needed

---

## 10. WHAT ENGINEER WILL NOT DO

- Invent final art or programmer-art “finals”
- Redesign HUD layout / restore old UI ornament
- Change movement, combat, collision, camera, quests, inventory balance
- Populate empty equipment layers with fake gear
- Fill every item with placeholder appearance data

---

*Generated from live 1920×1080 HUD geometry audit + readability-first art pipeline preparation milestone.*
