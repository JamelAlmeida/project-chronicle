param(
	[string]$KitRoot = "c:\Users\Jamel\Desktop\Chronicle art\Chronicle_UI_Rescue_v2",
	[string]$ProjectRoot = (Split-Path $PSScriptRoot -Parent)
)

$ErrorActionPreference = "Stop"

$frames = Join-Path $KitRoot "UI_Art\chronicle_ui_frames_bars_v2.png"
$slots = Join-Path $KitRoot "UI_Art\chronicle_ui_slots_icons_v2.png"
$character = Join-Path $KitRoot "UI_Art\chronicle_character_window_kit_v2.png"

$sourceDir = Join-Path $ProjectRoot "Assets\UI\ChronicleV2\Source"
$runtimeDir = Join-Path $ProjectRoot "Assets\UI\ChronicleV2\Runtime"
$cs = Join-Path $PSScriptRoot "ChronicleUiRescueV2Processor.cs"
$exe = Join-Path $PSScriptRoot "ChronicleUiRescueV2Processor.exe"

foreach ($path in @($frames, $slots, $character)) {
	if (-not (Test-Path -LiteralPath $path)) {
		throw "Missing source sheet: $path"
	}
}

foreach ($dir in @($sourceDir, $runtimeDir)) {
	New-Item -ItemType Directory -Force -Path $dir | Out-Null
}

Copy-Item -LiteralPath $frames -Destination (Join-Path $sourceDir "chronicle_ui_frames_bars_v2.png") -Force
Copy-Item -LiteralPath $slots -Destination (Join-Path $sourceDir "chronicle_ui_slots_icons_v2.png") -Force
Copy-Item -LiteralPath $character -Destination (Join-Path $sourceDir "chronicle_character_window_kit_v2.png") -Force

$gdignore = Join-Path $sourceDir ".gdignore"
if (-not (Test-Path $gdignore)) { Set-Content -Path $gdignore -Value "" }

$csc = @(
	"${env:WINDIR}\Microsoft.NET\Framework64\v4.0.30319\csc.exe",
	"${env:WINDIR}\Microsoft.NET\Framework\v4.0.30319\csc.exe"
) | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $csc) { throw "csc.exe not found" }

& $csc /nologo /target:exe /r:System.Drawing.dll /out:$exe $cs
if ($LASTEXITCODE -ne 0) { throw "ChronicleUiRescueV2Processor compile failed" }

$srcFrames = Join-Path $sourceDir "chronicle_ui_frames_bars_v2.png"
$srcSlots = Join-Path $sourceDir "chronicle_ui_slots_icons_v2.png"
$srcChar = Join-Path $sourceDir "chronicle_character_window_kit_v2.png"
& $exe $srcFrames $srcSlots $srcChar $runtimeDir
if ($LASTEXITCODE -ne 0) { throw "ChronicleUiRescueV2Processor failed" }

Write-Host "Processed UI Rescue V2 into:"
Write-Host "  $sourceDir"
Write-Host "  $runtimeDir"
Write-Host "Re-open Godot to refresh imports."
