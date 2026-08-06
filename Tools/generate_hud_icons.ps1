# Generates Chronicle HUD pixel icons (32x32 nearest-neighbor PNGs).
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
function Save-Icon($bmp, $name) {
    $path = Join-Path $outDir "$name.png"
    $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
    Write-Host "Wrote $name.png"
}

$ink = [System.Drawing.Color]::FromArgb(255, 16, 12, 10)
$brass = [System.Drawing.Color]::FromArgb(255, 176, 126, 48)
$gold = [System.Drawing.Color]::FromArgb(255, 236, 196, 88)
$goldLite = [System.Drawing.Color]::FromArgb(255, 255, 236, 170)
$steel = [System.Drawing.Color]::FromArgb(255, 198, 204, 212)
$steelDark = [System.Drawing.Color]::FromArgb(255, 110, 118, 128)
$teal = [System.Drawing.Color]::FromArgb(255, 64, 168, 148)
$tealDark = [System.Drawing.Color]::FromArgb(255, 28, 84, 74)
$purple = [System.Drawing.Color]::FromArgb(255, 148, 98, 220)
$purpleDark = [System.Drawing.Color]::FromArgb(255, 68, 38, 118)
$blue = [System.Drawing.Color]::FromArgb(255, 64, 142, 228)
$blueLite = [System.Drawing.Color]::FromArgb(255, 160, 210, 255)
$green = [System.Drawing.Color]::FromArgb(255, 86, 186, 96)
$greenDark = [System.Drawing.Color]::FromArgb(255, 42, 118, 58)
$red = [System.Drawing.Color]::FromArgb(255, 210, 52, 52)
$redDark = [System.Drawing.Color]::FromArgb(255, 112, 24, 28)
$cloak = [System.Drawing.Color]::FromArgb(255, 92, 58, 38)
$skin = [System.Drawing.Color]::FromArgb(255, 214, 172, 132)
$hair = [System.Drawing.Color]::FromArgb(255, 42, 32, 28)
$parchment = [System.Drawing.Color]::FromArgb(255, 226, 206, 156)
$wood = [System.Drawing.Color]::FromArgb(255, 118, 72, 34)
$white = [System.Drawing.Color]::FromArgb(230, 255, 255, 255)

# Crest — round shield with short blade
$b = New-Canvas
Fill-R $b 7 5 18 20 $brass
Fill-R $b 8 6 16 18 $ink
Fill-R $b 9 7 14 14 $cloak
Fill-R $b 10 8 12 4 $brass
Fill-R $b 14 3 4 20 $steel
Fill-R $b 13 2 6 3 $gold
Fill-R $b 12 22 8 3 $wood
Fill-R $b 15 9 2 8 $goldLite
Save-Icon $b "crest"

# Attack — bright crescent slash
$b = New-Canvas
for ($i = 0; $i -lt 14; $i++) {
    $x = 5 + $i
    $y = 21 - [math]::Floor($i * 0.9)
    Fill-R $b $x $y 3 3 $gold
    Set-P $b ($x + 1) ($y + 1) $goldLite
}
Fill-R $b 18 5 8 4 $goldLite
Fill-R $b 4 22 7 4 $wood
Fill-R $b 5 21 5 2 $steel
for ($i = 0; $i -lt 8; $i++) {
    Set-P $b (8 + $i) (24 - $i) ([System.Drawing.Color]::FromArgb(150, 255, 240, 160))
}
Save-Icon $b "attack"

# Dash — runner + streaks
$b = New-Canvas
Fill-R $b 15 6 5 4 $skin
Fill-R $b 14 5 7 2 $hair
Fill-R $b 13 10 9 8 $teal
Fill-R $b 12 18 4 8 $tealDark
Fill-R $b 19 17 5 8 $tealDark
Fill-R $b 21 11 4 3 $teal
Fill-R $b 10 12 3 3 $teal
for ($i = 0; $i -lt 6; $i++) {
    Fill-R $b (3 + $i) (11 + $i) 4 1 ([System.Drawing.Color]::FromArgb(190, 140, 240, 210))
}
Save-Icon $b "dash"

# Technique — cloaked caster + spark
$b = New-Canvas
Fill-R $b 13 6 6 4 $skin
Fill-R $b 12 5 8 2 $hair
Fill-R $b 10 10 12 13 $purple
Fill-R $b 11 22 10 5 $purpleDark
Fill-R $b 8 13 3 9 $purpleDark
Fill-R $b 21 12 3 8 $purple
Fill-R $b 22 6 5 5 $gold
Set-P $b 24 5 $white
Set-P $b 25 7 $goldLite
Set-P $b 23 8 $white
Save-Icon $b "technique"

# Arc slash — long golden cut
$b = New-Canvas
for ($i = 0; $i -lt 20; $i++) {
    Fill-R $b (5 + $i) (24 - $i) 2 2 $gold
    Set-P $b (6 + $i) (23 - $i) $goldLite
}
Fill-R $b 3 24 5 3 $steelDark
Fill-R $b 4 23 3 2 $steel
Save-Icon $b "arc_slash"

# Pulse wave — layered blue crescents
$b = New-Canvas
Fill-R $b 6 13 3 6 $blue
Fill-R $b 10 9 4 14 $blue
Fill-R $b 15 7 4 18 $blueLite
Fill-R $b 20 9 4 14 ([System.Drawing.Color]::FromArgb(200, 190, 235, 255))
Fill-R $b 25 12 3 8 $white
Save-Icon $b "pulse_wave"

# Verdant bloom — leaf swirl
$b = New-Canvas
Fill-R $b 14 7 4 15 $green
Fill-R $b 8 10 8 5 $greenDark
Fill-R $b 16 14 8 5 $green
Fill-R $b 10 7 6 4 $green
Fill-R $b 16 18 6 4 $greenDark
Fill-R $b 15 21 3 6 $wood
Fill-R $b 12 12 3 3 $goldLite
Save-Icon $b "verdant_bloom"

# Potion — corked red flask
$b = New-Canvas
Fill-R $b 13 3 6 3 $wood
Fill-R $b 14 5 4 4 $parchment
Fill-R $b 11 9 10 3 $steel
Fill-R $b 10 12 12 15 $redDark
Fill-R $b 11 13 10 12 $red
Fill-R $b 12 14 3 8 $goldLite
Fill-R $b 18 16 2 4 ([System.Drawing.Color]::FromArgb(160, 255, 180, 180))
Save-Icon $b "potion"

# Menu character — helmet
$b = New-Canvas
Fill-R $b 8 9 16 14 $steel
Fill-R $b 10 6 12 5 $steel
Fill-R $b 12 4 8 3 $brass
Fill-R $b 10 13 5 5 $ink
Fill-R $b 17 13 5 5 $ink
Fill-R $b 14 15 4 6 $brass
Fill-R $b 9 20 14 3 $steelDark
Save-Icon $b "menu_character"

# Menu inventory — pack
$b = New-Canvas
Fill-R $b 9 11 14 15 $cloak
Fill-R $b 10 12 12 12 $wood
Fill-R $b 12 7 8 5 $brass
Fill-R $b 14 14 4 4 $gold
Fill-R $b 11 18 10 2 $ink
Save-Icon $b "menu_inventory"

# Menu techniques — book
$b = New-Canvas
Fill-R $b 7 6 18 20 $purpleDark
Fill-R $b 8 7 8 18 $parchment
Fill-R $b 16 7 8 18 ([System.Drawing.Color]::FromArgb(255, 238, 222, 178))
Fill-R $b 15 6 2 20 $gold
Fill-R $b 10 11 4 2 $purple
Fill-R $b 18 14 4 2 $purple
Save-Icon $b "menu_techniques"

# Menu quests — scroll
$b = New-Canvas
Fill-R $b 10 5 12 22 $parchment
Fill-R $b 8 4 16 4 $wood
Fill-R $b 8 24 16 4 $wood
Fill-R $b 12 11 8 2 $ink
Fill-R $b 12 15 8 2 $ink
Fill-R $b 12 19 6 2 $brass
Fill-R $b 9 5 2 22 ([System.Drawing.Color]::FromArgb(80, 255, 255, 255))
Save-Icon $b "menu_quests"

Write-Host "HUD icon generation complete."
