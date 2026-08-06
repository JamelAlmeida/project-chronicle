# Legacy Visuals Archive

Retired during the **Hard Visual Reset**. These assets and scripts are kept for rollback safety. They must not render in normal gameplay.

## Contents

| Path | What it was |
|---|---|
| `Scripts/Presentation/hearthvale_immersion.gd` | Procedural Polygon2D/Line2D Hearthvale settlement generator |
| `Scripts/Presentation/showcase_immersion.gd` | Previous Elderwood Showcase dressing pass |
| `Scripts/Presentation/elderwood_immersion.gd` | Orphaned Elderwood ColorRect/Polygon immersion |
| `Scripts/Presentation/elderwood_art_dressing.gd` | Orphaned top-down Elderwood dressing |
| `UI/Runtime/` | Oldest UI kit from an early visual pass |
| `UI/ChronicleV2/` | UI Rescue V2 ornament skins |
| `UI/ShowcaseRuntimeUI/` | Showcase Master Pack UI crops (retired from active HUD) |
| `Environment/PixelArt_Elderwood/` | Earlier PixelArt Elderwood environment pack |

## Active approved packs (not archived)

`Assets/Showcase/Runtime/Environment` and `Assets/Showcase/Runtime/Combat` remain on disk for the next approved-art integration milestone. They are **not** auto-placed by immersion scripts after this reset.

## Re-enable policy

Do not re-attach these scripts to zone scenes. Integrate approved packs deliberately under `ApprovedEnvironmentArt` / HUD theme wiring with `USE_ORNAMENT_SKINS` only when a new approved UI pack is signed off.
