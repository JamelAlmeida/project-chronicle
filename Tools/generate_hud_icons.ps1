# Generates Chronicle HUD pixel icons (32x32 nearest-neighbor PNGs).
# Premium dark-fantasy silhouettes: clear shape, brass/gold accents, readable at HUD scale.
$ErrorActionPreference = "Stop"
$outDir = Join-Path $PSScriptRoot "..\Assets\UI\Icons"
New-Item -ItemType Directory -Force -Path $outDir | Out-Null
Add-Type -AssemblyName System.Drawing

function New-Canvas {
    $bmp = New-Object System.Drawing.Bitmap 32, 32, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    for ($y = 0; $y -lt 32; $y++) {
        for ($x = 0; $x -lt 32; $x++) { $bmp.SetPixel($x, $y, [System.Drawing.Color]::Transparent) }
    }
    return $bmp
}
function Set-P($bmp, $x, $y, $color) {
    if ($x -ge 0 -and $y -ge 0 -and $x -lt 32 -and $y -lt 32) { $bmp.SetPixel([int]$x, [int]$y, $color) }
}
function Fill-R($bmp, $x, $y, $w, $h, $color) {
    for ($yy = $y; $yy -lt ($y + $h); $yy++) {
        for ($xx = $x; $xx -lt ($x + $w); $xx++) { Set-P $bmp $xx $yy $color }
    }
}
function Outline-R($bmp, $x, $y, $w, $h, $color) {
    Fill-R $bmp $x $y $w 1 $color
    Fill-R $bmp $x ($y + $h - 1) $w 1 $color
    Fill-R $bmp $x $y 1 $h $color
    Fill-R $bmp ($x + $w - 1) $y 1 $h $color
}
function Save-Icon($bmp, $name) {
    $path = Join-Path $outDir "$name.png"
    $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
    Write-Host "Wrote $name.png"
}

$ink = [System.Drawing.Color]::FromArgb(255, 14, 10, 8)
$brass = [System.Drawing.Color]::FromArgb(255, 168, 122, 46)
$gold = [System.Drawing.Color]::FromArgb(255, 232, 188, 78)
$goldLite = [System.Drawing.Color]::FromArgb(255, 255, 232, 168)
$steel = [System.Drawing.Color]::FromArgb(255, 188, 196, 206)
$steelDark = [System.Drawing.Color]::FromArgb(255, 88, 96, 108)
$teal = [System.Drawing.Color]::FromArgb(255, 56, 168, 148)
$tealDark = [System.Drawing.Color]::FromArgb(255, 24, 86, 76)
$tealLite = [System.Drawing.Color]::FromArgb(255, 140, 230, 210)
$purple = [System.Drawing.Color]::FromArgb(255, 146, 98, 220)
$purpleDark = [System.Drawing.Color]::FromArgb(255, 58, 32, 108)
$purpleLite = [System.Drawing.Color]::FromArgb(255, 210, 176, 255)
$blue = [System.Drawing.Color]::FromArgb(255, 56, 138, 228)
$blueLite = [System.Drawing.Color]::FromArgb(255, 168, 214, 255)
$green = [System.Drawing.Color]::FromArgb(255, 78, 186, 92)
$greenDark = [System.Drawing.Color]::FromArgb(255, 34, 108, 52)
$red = [System.Drawing.Color]::FromArgb(255, 208, 48, 52)
$redDark = [System.Drawing.Color]::FromArgb(255, 98, 20, 28)
$cloak = [System.Drawing.Color]::FromArgb(255, 86, 52, 34)
$skin = [System.Drawing.Color]::FromArgb(255, 214, 172, 132)
$hair = [System.Drawing.Color]::FromArgb(255, 36, 28, 24)
$parchment = [System.Drawing.Color]::FromArgb(255, 228, 208, 158)
$wood = [System.Drawing.Color]::FromArgb(255, 108, 66, 32)
$white = [System.Drawing.Color]::FromArgb(220, 255, 255, 255)

# Crest — brass-rimmed shield with short blade
$b = New-Canvas
Fill-R $b 6 4 20 22 $ink
Fill-R $b 7 5 18 20 $brass
Fill-R $b 9 7 14 16 $cloak
Fill-R $b 10 8 12 4 $gold
Fill-R $b 11 13 10 8 $cloak
Fill-R $b 14 2 4 22 $steel
Fill-R $b 13 1 6 3 $gold
Fill-R $b 12 23 8 3 $wood
Fill-R $b 15 8 2 10 $goldLite
Outline-R $b 7 5 18 20 $ink
Save-Icon $b "crest"

# Attack — sword slash with bright edge
$b = New-Canvas
Fill-R $b 3 22 8 5 $wood
Fill-R $b 5 20 5 3 $steelDark
for ($i = 0; $i -lt 16; $i++) {
    $x = 6 + $i
    $y = 22 - [math]::Floor($i * 0.95)
    Fill-R $b $x $y 3 3 $gold
    Set-P $b ($x + 1) ($y + 1) $goldLite
    Set-P $b ($x + 2) $y $white
}
Fill-R $b 20 4 8 5 $goldLite
Fill-R $b 21 5 6 3 $white
for ($i = 0; $i -lt 7; $i++) {
    Set-P $b (9 + $i) (23 - $i) ([System.Drawing.Color]::FromArgb(160, 255, 240, 170))
}
Save-Icon $b "attack"

# Dash — motion figure with teal streaks
$b = New-Canvas
Fill-R $b 16 5 6 4 $skin
Fill-R $b 15 4 8 2 $hair
Fill-R $b 14 9 10 9 $teal
Fill-R $b 13 17 4 9 $tealDark
Fill-R $b 20 16 5 9 $tealDark
Fill-R $b 22 10 4 4 $tealLite
Fill-R $b 11 11 3 4 $teal
for ($i = 0; $i -lt 7; $i++) {
    Fill-R $b (2 + $i) (10 + $i) 5 2 ([System.Drawing.Color]::FromArgb(200, 120, 230, 200))
}
Save-Icon $b "dash"

# Technique — caster glyph spark
$b = New-Canvas
Fill-R $b 12 5 8 5 $skin
Fill-R $b 11 4 10 2 $hair
Fill-R $b 9 10 14 14 $purple
Fill-R $b 10 22 12 5 $purpleDark
Fill-R $b 7 13 3 10 $purpleDark
Fill-R $b 22 12 3 9 $purple
Fill-R $b 21 5 7 7 $gold
Fill-R $b 23 6 3 3 $goldLite
Set-P $b 24 4 $white
Set-P $b 26 7 $purpleLite
Set-P $b 22 8 $white
Outline-R $b 9 10 14 14 $ink
Save-Icon $b "technique"

# Arc slash — elongated golden crescent
$b = New-Canvas
for ($i = 0; $i -lt 22; $i++) {
    Fill-R $b (4 + $i) (25 - $i) 3 3 $gold
    Set-P $b (5 + $i) (24 - $i) $goldLite
    Set-P $b (6 + $i) (23 - $i) $white
}
Fill-R $b 2 24 6 4 $steelDark
Fill-R $b 3 23 4 2 $steel
Save-Icon $b "arc_slash"

# Pulse wave — layered arcane crescents
$b = New-Canvas
Fill-R $b 5 12 3 8 $blue
Fill-R $b 9 8 4 16 $blue
Fill-R $b 14 6 5 20 $blueLite
Fill-R $b 20 8 4 16 ([System.Drawing.Color]::FromArgb(210, 200, 236, 255))
Fill-R $b 25 11 3 10 $white
Save-Icon $b "pulse_wave"

# Verdant bloom — leaf swirl
$b = New-Canvas
Fill-R $b 14 6 4 16 $green
Fill-R $b 7 9 9 6 $greenDark
Fill-R $b 16 13 9 6 $green
Fill-R $b 9 6 7 5 $green
Fill-R $b 16 18 7 5 $greenDark
Fill-R $b 15 21 3 7 $wood
Fill-R $b 12 11 4 4 $goldLite
Save-Icon $b "verdant_bloom"

# Potion — corked red flask with highlight
$b = New-Canvas
Fill-R $b 13 2 6 3 $wood
Fill-R $b 14 4 4 4 $parchment
Fill-R $b 11 8 10 3 $steel
Fill-R $b 10 11 12 16 $redDark
Fill-R $b 11 12 10 13 $red
Fill-R $b 12 13 3 9 $goldLite
Fill-R $b 18 15 2 5 ([System.Drawing.Color]::FromArgb(170, 255, 180, 180))
Outline-R $b 10 11 12 16 $ink
Save-Icon $b "potion"

# Menu character — knight helm
$b = New-Canvas
Fill-R $b 7 8 18 16 $steel
Fill-R $b 9 5 14 5 $steel
Fill-R $b 11 3 10 3 $brass
Fill-R $b 9 12 6 6 $ink
Fill-R $b 17 12 6 6 $ink
Fill-R $b 14 14 4 7 $brass
Fill-R $b 8 21 16 4 $steelDark
Fill-R $b 14 9 4 2 $gold
Save-Icon $b "menu_character"

# Menu inventory — travel pack
$b = New-Canvas
Fill-R $b 8 10 16 16 $cloak
Fill-R $b 9 11 14 13 $wood
Fill-R $b 11 6 10 5 $brass
Fill-R $b 13 13 6 5 $gold
Fill-R $b 10 19 12 2 $ink
Outline-R $b 8 10 16 16 $ink
Save-Icon $b "menu_inventory"

# Menu techniques — spellbook
$b = New-Canvas
Fill-R $b 6 5 20 22 $purpleDark
Fill-R $b 7 6 9 20 $parchment
Fill-R $b 16 6 9 20 ([System.Drawing.Color]::FromArgb(255, 240, 224, 180))
Fill-R $b 15 5 2 22 $gold
Fill-R $b 9 11 5 2 $purple
Fill-R $b 18 14 5 2 $purple
Fill-R $b 9 16 4 2 $brass
Save-Icon $b "menu_techniques"

# Menu quests — sealed scroll
$b = New-Canvas
Fill-R $b 9 4 14 24 $parchment
Fill-R $b 7 3 18 4 $wood
Fill-R $b 7 25 18 4 $wood
Fill-R $b 11 10 10 2 $ink
Fill-R $b 11 14 10 2 $ink
Fill-R $b 11 18 8 2 $brass
Fill-R $b 8 5 2 22 ([System.Drawing.Color]::FromArgb(90, 255, 255, 255))
Fill-R $b 14 20 4 4 $gold
Save-Icon $b "menu_quests"

Write-Host "HUD icon generation complete."
