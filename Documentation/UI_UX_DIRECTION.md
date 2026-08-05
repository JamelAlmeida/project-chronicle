# Project Chronicle — UI / UX Direction

Chronicle uses an original, desktop-first dark-fantasy interface with MMO-inspired information clarity. The foundation favors charcoal panels, aged brass accents, restrained color, readable typography, and bottom-screen anchoring. It must not copy another game's layout or drift into mobile-gacha clutter, autoplay controls, banner noise, or a crowded top edge.

## Gameplay HUD

- Anchor health, the reserved secondary-resource space, primary actions, panel access, and XP along the bottom.
- Keep the center action bar reusable for Technique icons, keybinds, disabled states, cooldown overlays, and later additional bars.
- Keep status messages temporary. Keep the active quest tracker compact and unobtrusive.
- Preserve space for future buffs/debuffs and a target frame without displaying empty systems now.

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

This foundation is structural, not the final art pass. Do not prematurely add full drag-and-drop hotbars, a complete cooldown ecosystem, final tooltip comparisons, titles/badges, crafting, multiplayer UI, or decorative clutter.
