# Project Chronicle — UI / UX Direction

Chronicle uses an original, desktop-first dark-fantasy interface with MMO-inspired information clarity. The foundation favors charcoal panels, aged brass accents, restrained color, readable typography, and bottom-screen anchoring. It must not copy another game's layout or drift into mobile-gacha clutter, autoplay controls, banner noise, or a crowded top edge.

## Gameplay HUD

- Anchor health, the reserved secondary-resource space, primary actions, panel access, and XP along the bottom.
- Keep the center action bar reusable for Technique icons, keybinds, disabled states, cooldown overlays, and later additional bars.
- Keep status messages temporary. Keep the active quest tracker compact and unobtrusive.
- Preserve space for future buffs/debuffs and a target frame without displaying empty systems now.

### Immersion-slice skin

- Prefer a cozy dark-fantasy look: dark stone bottom chrome, warm gold edging, readable red HP and blue Steadfast bars, and colorful centered action slots.
- Use **Cinzel** (weighted) for major headings, zone names, and limited combat emphasis. Use **Alegreya** (weighted) for body copy, HUD values, buttons, objectives, and item detail. Primary text is warm ivory; headings use muted gold; secondary text uses subdued gray. Dark outline/shadow keeps type readable over panels and the world.
- Keep the top-left expedition ledger and top-right quest tracker compact, framed, and quieter than the world.
- Segment the bottom adventure chrome into three islands with visible world gaps between them: left player status (crest, name/level, HP, secondary resource, XP), center action bar, and right menu access. Do not reconnect islands with a full-width background slab.
- Keep action slots centered with distinct icons, Cinzel keybind labels under each slot, and menu access grouped at the bottom-right island. Prefer light translucent slot plates with thin borders; strengthen borders only for ready/selected/hover emphasis. Locked slots use darkening plus a small lock overlay.
- Action and menu icons live in `Assets/UI/Icons` as 32×32 nearest-neighbor pixel art. They should read clearly at HUD scale without copying another game's icon language.
- Approved Character + UI Kit v1 source sheets live under `Assets/Characters/Adventurer/Source` and `Assets/UI/Source`. Runtime crops/atlases used by the Adventurer live in the matching `Runtime` folders.
- UI Rescue V2 source sheets live under `Assets/UI/ChronicleV2/Source`. Clean isolated runtime crops used by the HUD and panels live in `Assets/UI/ChronicleV2/Runtime`. Godot Labels remain authoritative for all dynamic text and keybinds. Do not stack decorative frames or use baked sheet text.
- Ordinary damage numbers use warm ivory, criticals use pale copper-gold at a larger scale, and player damage uses muted rose. Motion is short and restrained; Chronicle does not reproduce another game's iconic number palette or stacking behavior.
- World framing should feel intimate and golden-hour dense: closer camera, filled canopy, warm entry light into cooler wilderness depth.

Current bindings are `E` attack, `Space` dash, `1` or legacy `Q` primary Technique, `C` Character, `I` Inventory, `K` Technique Book, `J` Quest Log, and `F` contextual quest interaction. Number keys `1–5` establish the primary action-bar range. `Tab` is reserved for future target cycling.

## Character and Inventory

The Character panel is the build inspection center: Adventurer identity, level/XP, preview space, equipment slots, equipped items, core-stat base/bonus breakdowns, derived combat stats, unspent points, and clickable allocation. Allocation must reject unavailable points and refresh derived values immediately.

Inventory remains a separate focused panel but shares the same equipment flow. It distinguishes secured and expedition loot, supports equipping owned gear, and returns unequipped gear to inventory. Later passes may add item icons, hover comparison, richer inspection, and visible equipped appearance without coupling those features to Player logic.

## Techniques and Quests

The Technique Book lists unlocked active/passive Techniques, descriptions, sources, cooldown information, and equipped state. It is not a class tree. Future management should remain data-driven and build-oriented.

The on-screen quest tracker shows immediate opportunities and objective progress. The Quest Log provides the deliberate long-form access point. A complete journal, map integration, and advanced filtering remain later work.

## Future Targeting and Combat Feedback

Chronicle remains spatial and action-based: movement, jumping, dodging, facing, and direct attacks are primary. A later hybrid model may let `Tab` cycle nearby enemies, show a target frame, and help selected Techniques without turning combat into stationary tab-target play.

Combat feedback may later use large readable damage numbers, multi-hit stacking, critical emphasis, AoE grouping, and status/build-synergy cues. Timing and hierarchy must preserve enemy telegraphs and player positioning.

## Scope Discipline

The opening HUD and four major panels now carry the immersion-slice visual language, but they are not final production UI. Do not prematurely add full drag-and-drop hotbars, a complete cooldown ecosystem, final tooltip comparisons, titles/badges, crafting, multiplayer UI, or decorative clutter.
