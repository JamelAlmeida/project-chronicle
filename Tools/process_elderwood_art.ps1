param(
    [Parameter(Mandatory = $true)][string]$GeneratedSourceDirectory,
    [string]$ProjectRoot = (Split-Path $PSScriptRoot -Parent)
)

$ErrorActionPreference = "Stop"

$processorSource = @'
using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;
using System.IO;

public static class ChronicleArtProcessor
{
    private static bool IsBackground(Color color)
    {
        return color.A == 0 || (
            color.R > 175 &&
            color.B > 140 &&
            color.G < 175 &&
            (color.R + color.B - color.G * 2) > 155
        );
    }

    private static Bitmap Extract(Bitmap source, Rectangle region)
    {
        int left = region.Right;
        int top = region.Bottom;
        int right = region.Left - 1;
        int bottom = region.Top - 1;

        for (int y = region.Top; y < region.Bottom; y++)
        {
            for (int x = region.Left; x < region.Right; x++)
            {
                if (IsBackground(source.GetPixel(x, y)))
                    continue;
                left = Math.Min(left, x);
                top = Math.Min(top, y);
                right = Math.Max(right, x);
                bottom = Math.Max(bottom, y);
            }
        }

        if (right < left || bottom < top)
            throw new InvalidDataException("No artwork found in source region " + region);

        Bitmap output = new Bitmap(right - left + 1, bottom - top + 1, PixelFormat.Format32bppArgb);
        for (int y = top; y <= bottom; y++)
        {
            for (int x = left; x <= right; x++)
            {
                Color color = source.GetPixel(x, y);
                output.SetPixel(x - left, y - top, IsBackground(color) ? Color.Transparent : color);
            }
        }
        return output;
    }

    private static Bitmap ResizeNearest(Bitmap source, int width, int height)
    {
        Bitmap output = new Bitmap(Math.Max(1, width), Math.Max(1, height), PixelFormat.Format32bppArgb);
        using (Graphics graphics = Graphics.FromImage(output))
        {
            graphics.CompositingMode = CompositingMode.SourceCopy;
            graphics.CompositingQuality = CompositingQuality.HighSpeed;
            graphics.InterpolationMode = InterpolationMode.NearestNeighbor;
            graphics.PixelOffsetMode = PixelOffsetMode.Half;
            graphics.SmoothingMode = SmoothingMode.None;
            graphics.DrawImage(
                source,
                new Rectangle(0, 0, output.Width, output.Height),
                0,
                0,
                source.Width,
                source.Height,
                GraphicsUnit.Pixel
            );
        }
        return output;
    }

    private static void SavePng(Bitmap image, string path)
    {
        Directory.CreateDirectory(Path.GetDirectoryName(path));
        image.Save(path, ImageFormat.Png);
    }

    public static void ProcessCharacter(
        string sourcePath,
        string outputPath,
        int frameWidth,
        int frameHeight,
        double scale
    )
    {
        using (Bitmap source = new Bitmap(sourcePath))
        using (Bitmap sheet = new Bitmap(frameWidth * 5, frameHeight, PixelFormat.Format32bppArgb))
        {
            for (int frame = 0; frame < 5; frame++)
            {
                int cellLeft = (int)Math.Round((double)source.Width * frame / 5.0);
                int cellRight = (int)Math.Round((double)source.Width * (frame + 1) / 5.0);
                using (Bitmap crop = Extract(
                    source,
                    new Rectangle(cellLeft, 0, cellRight - cellLeft, source.Height)
                ))
                {
                    double fit = Math.Min(
                        (double)(frameWidth - 2) / crop.Width,
                        (double)(frameHeight - 2) / crop.Height
                    );
                    double appliedScale = Math.Min(scale, fit);
                    int width = Math.Max(1, (int)Math.Round(crop.Width * appliedScale));
                    int height = Math.Max(1, (int)Math.Round(crop.Height * appliedScale));
                    using (Bitmap resized = ResizeNearest(crop, width, height))
                    using (Graphics graphics = Graphics.FromImage(sheet))
                    {
                        int x = frame * frameWidth + (frameWidth - width) / 2;
                        int y = frameHeight - height - 1;
                        graphics.CompositingMode = CompositingMode.SourceCopy;
                        graphics.DrawImageUnscaled(resized, x, y);
                    }
                }
            }
            SavePng(sheet, outputPath);
        }
    }

    public static void ProcessAsset(
        string sourcePath,
        string outputPath,
        int x,
        int y,
        int width,
        int height,
        double scale,
        int maxWidth,
        int maxHeight
    )
    {
        using (Bitmap source = new Bitmap(sourcePath))
        using (Bitmap crop = Extract(source, new Rectangle(x, y, width, height)))
        {
            double fit = Math.Min((double)maxWidth / crop.Width, (double)maxHeight / crop.Height);
            double appliedScale = Math.Min(scale, fit);
            int outputWidth = Math.Max(1, (int)Math.Round(crop.Width * appliedScale));
            int outputHeight = Math.Max(1, (int)Math.Round(crop.Height * appliedScale));
            using (Bitmap output = ResizeNearest(crop, outputWidth, outputHeight))
                SavePng(output, outputPath);
        }
    }

    public static void ProcessIconSheet(string sourcePath, string outputDirectory)
    {
        string[] names = {
            "slime_gel.png",
            "swift_katana.png",
            "bloodfang_blade.png",
            "crimson_leech_ring.png"
        };
        using (Bitmap source = new Bitmap(sourcePath))
        {
            for (int index = 0; index < names.Length; index++)
            {
                int left = (int)Math.Round((double)source.Width * index / names.Length);
                int right = (int)Math.Round((double)source.Width * (index + 1) / names.Length);
                using (Bitmap crop = Extract(
                    source,
                    new Rectangle(left, 0, right - left, source.Height)
                ))
                {
                    double scale = Math.Min(30.0 / crop.Width, 30.0 / crop.Height);
                    int width = Math.Max(1, (int)Math.Round(crop.Width * scale));
                    int height = Math.Max(1, (int)Math.Round(crop.Height * scale));
                    using (Bitmap resized = ResizeNearest(crop, width, height))
                    using (Bitmap icon = new Bitmap(32, 32, PixelFormat.Format32bppArgb))
                    using (Graphics graphics = Graphics.FromImage(icon))
                    {
                        graphics.CompositingMode = CompositingMode.SourceCopy;
                        graphics.DrawImageUnscaled(resized, (32 - width) / 2, (32 - height) / 2);
                        SavePng(icon, Path.Combine(outputDirectory, names[index]));
                    }
                }
            }
        }
    }
}
'@

Add-Type -TypeDefinition $processorSource -ReferencedAssemblies System.Drawing

$pixelRoot = Join-Path $ProjectRoot "Assets\PixelArt"
$sourceRoot = Join-Path $pixelRoot "Source\ElderwoodBenchmark"
$characterRoot = Join-Path $pixelRoot "Characters"
$environmentRoot = Join-Path $pixelRoot "Environment\Elderwood"
$iconRoot = Join-Path $pixelRoot "Items"

New-Item -ItemType Directory -Force -Path $sourceRoot, $characterRoot, $environmentRoot, $iconRoot | Out-Null

$sourceFiles = @(
    "slime_source.png",
    "goblin_scout_source.png",
    "crypt_guardian_source.png",
    "elderwood_props_source.png",
    "elderwood_ruins_source.png",
    "elderwood_terrain_source.png",
    "loot_icons_source.png"
)
foreach ($sourceFile in $sourceFiles) {
    Copy-Item (Join-Path $GeneratedSourceDirectory $sourceFile) (Join-Path $sourceRoot $sourceFile) -Force
}
Set-Content -Path (Join-Path $sourceRoot ".gdignore") -Value "# Generated source/reference artwork. Final game assets live outside this folder."

[ChronicleArtProcessor]::ProcessCharacter(
    (Join-Path $sourceRoot "slime_source.png"),
    (Join-Path $characterRoot "Slime\slime_states_48x40.png"),
    48, 40, 0.25
)
[ChronicleArtProcessor]::ProcessCharacter(
    (Join-Path $sourceRoot "goblin_scout_source.png"),
    (Join-Path $characterRoot "GoblinScout\goblin_scout_states_48x56.png"),
    48, 56, 0.25
)
[ChronicleArtProcessor]::ProcessCharacter(
    (Join-Path $sourceRoot "crypt_guardian_source.png"),
    (Join-Path $characterRoot "CryptGuardian\crypt_guardian_states_80x80.png"),
    80, 80, 0.25
)

$propsSource = Join-Path $sourceRoot "elderwood_props_source.png"
$propsImage = [System.Drawing.Image]::FromFile($propsSource)
$propsCoordinateScale = [double]$propsImage.Width / 1024.0
$propsImage.Dispose()
$props = @(
    @("tree_ancient_a.png", 45, 5, 300, 275, 0.40, 128, 120),
    @("tree_ancient_b.png", 340, 0, 335, 285, 0.40, 144, 128),
    @("tree_ancient_c.png", 665, 0, 285, 285, 0.40, 128, 120),
    @("rock_large.png", 35, 270, 225, 155, 0.38, 88, 64),
    @("rock_medium.png", 245, 265, 180, 160, 0.38, 72, 60),
    @("rock_small.png", 405, 280, 145, 125, 0.38, 56, 44),
    @("bush_dark.png", 695, 280, 140, 130, 0.38, 56, 48),
    @("bush_flower.png", 830, 280, 150, 130, 0.38, 60, 48),
    @("grass_tuft.png", 45, 405, 95, 85, 0.35, 32, 28),
    @("flowers.png", 400, 405, 115, 90, 0.35, 40, 28),
    @("mushrooms.png", 665, 400, 145, 105, 0.35, 48, 36),
    @("fallen_log.png", 35, 475, 300, 190, 0.38, 112, 72),
    @("stump.png", 315, 475, 180, 190, 0.38, 68, 68),
    @("mossy_pillar.png", 475, 465, 135, 210, 0.38, 52, 80),
    @("ruined_arch.png", 585, 485, 225, 190, 0.38, 88, 84),
    @("carved_stone.png", 805, 450, 180, 225, 0.38, 68, 84)
)
foreach ($prop in $props) {
    [ChronicleArtProcessor]::ProcessAsset(
        $propsSource,
        (Join-Path $environmentRoot $prop[0]),
        [int]([double]$prop[1] * $propsCoordinateScale),
        [int]([double]$prop[2] * $propsCoordinateScale),
        [int]([double]$prop[3] * $propsCoordinateScale),
        [int]([double]$prop[4] * $propsCoordinateScale),
        [double]$prop[5] / $propsCoordinateScale,
        $prop[6],
        $prop[7]
    )
}

$ruinsSource = Join-Path $sourceRoot "elderwood_ruins_source.png"
$ruinsImage = [System.Drawing.Image]::FromFile($ruinsSource)
$ruinsCoordinateScale = [double]$ruinsImage.Width / 1024.0
$ruinsImage.Dispose()
$ruins = @(
    @("broken_wall_corner.png", 65, 115, 390, 230, 0.30, 120, 72),
    @("broken_wall_tall.png", 480, 100, 370, 260, 0.30, 112, 80),
    @("broken_wall_end.png", 190, 350, 245, 240, 0.30, 76, 76),
    @("waystone_fragment.png", 620, 350, 210, 245, 0.30, 68, 80)
)
foreach ($ruin in $ruins) {
    [ChronicleArtProcessor]::ProcessAsset(
        $ruinsSource,
        (Join-Path $environmentRoot $ruin[0]),
        [int]([double]$ruin[1] * $ruinsCoordinateScale),
        [int]([double]$ruin[2] * $ruinsCoordinateScale),
        [int]([double]$ruin[3] * $ruinsCoordinateScale),
        [int]([double]$ruin[4] * $ruinsCoordinateScale),
        [double]$ruin[5] / $ruinsCoordinateScale,
        $ruin[6],
        $ruin[7]
    )
}

$terrainSource = Join-Path $sourceRoot "elderwood_terrain_source.png"
$terrainImage = [System.Drawing.Image]::FromFile($terrainSource)
$terrainCoordinateScale = [double]$terrainImage.Width / 819.0
$terrainImage.Dispose()
$terrainNames = @(
    "grass_a.png", "grass_b.png", "grass_dark.png", "grass_deep.png",
    "worn_ground.png", "path_center.png", "path_edge_left.png", "path_edge_right.png",
    "path_corner_a.png", "path_corner_b.png", "path_bend_a.png", "path_bend_b.png"
)
$terrainX = @(48, 235, 423, 610)
$terrainY = @(21, 194, 369)
for ($row = 0; $row -lt 3; $row++) {
    for ($column = 0; $column -lt 4; $column++) {
        $index = $row * 4 + $column
        [ChronicleArtProcessor]::ProcessAsset(
            $terrainSource,
            (Join-Path $environmentRoot $terrainNames[$index]),
            [int]([double]$terrainX[$column] * $terrainCoordinateScale),
            [int]([double]$terrainY[$row] * $terrainCoordinateScale),
            [int](160.0 * $terrainCoordinateScale),
            [int](157.0 * $terrainCoordinateScale),
            1.0,
            32,
            32
        )
    }
}

[ChronicleArtProcessor]::ProcessAsset(
    $terrainSource,
    (Join-Path $environmentRoot "grass_fill.png"),
    [int](88.0 * $terrainCoordinateScale),
    [int](61.0 * $terrainCoordinateScale),
    [int](80.0 * $terrainCoordinateScale),
    [int](80.0 * $terrainCoordinateScale),
    1.0,
    32,
    32
)
[ChronicleArtProcessor]::ProcessAsset(
    $terrainSource,
    (Join-Path $environmentRoot "path_fill.png"),
    [int](88.0 * $terrainCoordinateScale),
    [int](226.0 * $terrainCoordinateScale),
    [int](80.0 * $terrainCoordinateScale),
    [int](90.0 * $terrainCoordinateScale),
    1.0,
    32,
    32
)

[ChronicleArtProcessor]::ProcessIconSheet(
    (Join-Path $sourceRoot "loot_icons_source.png"),
    $iconRoot
)

Write-Host "Processed Elderwood benchmark artwork into $pixelRoot"
