param(
	[string]$KitRoot = "c:\Users\Jamel\Desktop\Chronicle art\Chronicle_Showcase_Master_Pack_v1",
	[string]$ProjectRoot = (Split-Path $PSScriptRoot -Parent)
)

$ErrorActionPreference = "Stop"

$uiFrames = Join-Path $KitRoot "01_UI\chronicle_showcase_ui_frames_bars_v1.png"
$uiSlots = Join-Path $KitRoot "01_UI\chronicle_showcase_ui_slots_icons_v1.png"
$hearthvale = Join-Path $KitRoot "02_ENVIRONMENT\chronicle_showcase_hearthvale_assets_v1.png"
$elderwood = Join-Path $KitRoot "02_ENVIRONMENT\chronicle_showcase_elderwood_assets_v1.png"
$combat = Join-Path $KitRoot "03_COMBAT\chronicle_showcase_combat_fx_slimes_v1.png"
$target = Join-Path $KitRoot "00_TARGET\chronicle_master_visual_target.png"

$sourceDir = Join-Path $ProjectRoot "Assets\Showcase\Source"
$runtimeDir = Join-Path $ProjectRoot "Assets\Showcase\Runtime"
$cs = Join-Path $PSScriptRoot "ChronicleShowcaseMasterProcessor.cs"
$exe = Join-Path $PSScriptRoot "ChronicleShowcaseMasterProcessor.exe"

foreach ($path in @($uiFrames, $uiSlots, $hearthvale, $elderwood, $combat, $target)) {
	if (-not (Test-Path -LiteralPath $path)) {
		throw "Missing source sheet: $path"
	}
}

foreach ($dir in @($sourceDir, $runtimeDir)) {
	New-Item -ItemType Directory -Force -Path $dir | Out-Null
}

Copy-Item -LiteralPath $uiFrames -Destination (Join-Path $sourceDir "chronicle_showcase_ui_frames_bars_v1.png") -Force
Copy-Item -LiteralPath $uiSlots -Destination (Join-Path $sourceDir "chronicle_showcase_ui_slots_icons_v1.png") -Force
Copy-Item -LiteralPath $hearthvale -Destination (Join-Path $sourceDir "chronicle_showcase_hearthvale_assets_v1.png") -Force
Copy-Item -LiteralPath $elderwood -Destination (Join-Path $sourceDir "chronicle_showcase_elderwood_assets_v1.png") -Force
Copy-Item -LiteralPath $combat -Destination (Join-Path $sourceDir "chronicle_showcase_combat_fx_slimes_v1.png") -Force
Copy-Item -LiteralPath $target -Destination (Join-Path $sourceDir "chronicle_master_visual_target.png") -Force

$gdignore = Join-Path $sourceDir ".gdignore"
if (-not (Test-Path $gdignore)) { Set-Content -Path $gdignore -Value "" }

$csc = @(
	"${env:WINDIR}\Microsoft.NET\Framework64\v4.0.30319\csc.exe",
	"${env:WINDIR}\Microsoft.NET\Framework\v4.0.30319\csc.exe"
) | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $csc) { throw "csc.exe not found" }

& $csc /nologo /target:exe /r:System.Drawing.dll /out:$exe $cs
if ($LASTEXITCODE -ne 0) { throw "ChronicleShowcaseMasterProcessor compile failed" }

& $exe `
	(Join-Path $sourceDir "chronicle_showcase_ui_frames_bars_v1.png") `
	(Join-Path $sourceDir "chronicle_showcase_ui_slots_icons_v1.png") `
	(Join-Path $sourceDir "chronicle_showcase_hearthvale_assets_v1.png") `
	(Join-Path $sourceDir "chronicle_showcase_elderwood_assets_v1.png") `
	(Join-Path $sourceDir "chronicle_showcase_combat_fx_slimes_v1.png") `
	$runtimeDir
if ($LASTEXITCODE -ne 0) { throw "ChronicleShowcaseMasterProcessor failed" }

Write-Host "Processed Showcase Master Pack into:"
Write-Host "  $sourceDir"
Write-Host "  $runtimeDir"
Write-Host "Re-open Godot to refresh imports."
