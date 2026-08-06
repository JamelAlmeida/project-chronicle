param(
	[string]$KitRoot = "c:\Users\Jamel\Desktop\Chronicle art\Chronicle_Character_UI_Kit_v1",
	[string]$ProjectRoot = (Split-Path $PSScriptRoot -Parent)
)

$ErrorActionPreference = "Stop"

$characterSource = Join-Path $KitRoot "Character\chronicle_adventurer_sideview_sheet_v1.png"
$uiSource = Join-Path $KitRoot "UI\chronicle_ui_modular_kit_v1.png"
$advSourceDir = Join-Path $ProjectRoot "Assets\Characters\Adventurer\Source"
$advRuntimeDir = Join-Path $ProjectRoot "Assets\Characters\Adventurer\Runtime"
$uiSourceDir = Join-Path $ProjectRoot "Assets\UI\Source"
$uiRuntimeDir = Join-Path $ProjectRoot "Assets\UI\Runtime"
$cs = Join-Path $PSScriptRoot "ChronicleKitProcessor.cs"
$exe = Join-Path $PSScriptRoot "ChronicleKitProcessor.exe"

foreach ($dir in @($advSourceDir, $advRuntimeDir, $uiSourceDir, $uiRuntimeDir)) {
	New-Item -ItemType Directory -Force -Path $dir | Out-Null
}

Copy-Item -LiteralPath $characterSource -Destination (Join-Path $advSourceDir "chronicle_adventurer_sideview_sheet_v1.png") -Force
Copy-Item -LiteralPath $uiSource -Destination (Join-Path $uiSourceDir "chronicle_ui_modular_kit_v1.png") -Force

foreach ($dir in @($advSourceDir, $uiSourceDir)) {
	$gdignore = Join-Path $dir ".gdignore"
	if (-not (Test-Path $gdignore)) { Set-Content -Path $gdignore -Value "" }
}

$csc = @(
	"${env:WINDIR}\Microsoft.NET\Framework64\v4.0.30319\csc.exe",
	"${env:WINDIR}\Microsoft.NET\Framework\v4.0.30319\csc.exe"
) | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $csc) { throw "csc.exe not found" }

& $csc /nologo /target:exe /r:System.Drawing.dll /out:$exe $cs
if ($LASTEXITCODE -ne 0) { throw "ChronicleKitProcessor compile failed" }

$advSrcOut = Join-Path $advSourceDir "chronicle_adventurer_sideview_sheet_v1.png"
$uiSrcOut = Join-Path $uiSourceDir "chronicle_ui_modular_kit_v1.png"
& $exe $advSrcOut $advRuntimeDir $uiSrcOut $uiRuntimeDir
if ($LASTEXITCODE -ne 0) { throw "ChronicleKitProcessor failed" }

Write-Host "Processed kit into:"
Write-Host "  $advRuntimeDir"
Write-Host "  $uiRuntimeDir"
Write-Host "Re-open Godot to refresh imports / SpriteFrames if atlases changed."
