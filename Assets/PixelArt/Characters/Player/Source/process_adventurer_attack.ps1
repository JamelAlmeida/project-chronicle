param(
    [string]$SourcePath = (Join-Path $PSScriptRoot "adventurer_attack_source.png"),
    [string]$OutputPath = (Join-Path (Split-Path $PSScriptRoot -Parent) "adventurer_attack_112x48.png")
)

$processorSource = @'
using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;

public static class AdventurerAttackProcessor
{
    private const int Columns = 3;
    private const int Rows = 4;
    private const int FrameWidth = 112;
    private const int FrameHeight = 48;
    private const int FeetBaseline = 46;

    private static bool IsBackground(Color color)
    {
        return color.R > 60
            && color.B > 60
            && color.G < 130
            && color.R + color.B > color.G * 3
            && Math.Abs(color.R - color.B) < 100;
    }

    public static string Process(string sourcePath, string outputPath)
    {
        using (Bitmap source = new Bitmap(sourcePath))
        {
            Rectangle[] bounds = new Rectangle[Columns * Rows];
            int maxWidth = 0;
            int maxHeight = 0;

            for (int row = 0; row < Rows; row++)
            {
                for (int column = 0; column < Columns; column++)
                {
                    int left = source.Width * column / Columns;
                    int right = source.Width * (column + 1) / Columns;
                    int top = source.Height * row / Rows;
                    int bottom = source.Height * (row + 1) / Rows;
                    int minX = right;
                    int minY = bottom;
                    int maxX = left - 1;
                    int maxY = top - 1;

                    for (int y = top; y < bottom; y++)
                    {
                        for (int x = left; x < right; x++)
                        {
                            if (IsBackground(source.GetPixel(x, y)))
                                continue;
                            minX = Math.Min(minX, x);
                            minY = Math.Min(minY, y);
                            maxX = Math.Max(maxX, x);
                            maxY = Math.Max(maxY, y);
                        }
                    }

                    if (maxX < minX || maxY < minY)
                        throw new InvalidDataException("An attack frame contains no character pixels.");

                    Rectangle frameBounds = new Rectangle(
                        minX,
                        minY,
                        maxX - minX + 1,
                        maxY - minY + 1
                    );
                    int index = row * Columns + column;
                    bounds[index] = frameBounds;
                    maxWidth = Math.Max(maxWidth, frameBounds.Width);
                    maxHeight = Math.Max(maxHeight, frameBounds.Height);
                }
            }

            double scale = Math.Min(
                (double)(FrameWidth - 2) / maxWidth,
                (double)(FrameHeight - 3) / maxHeight
            );

            using (Bitmap output = new Bitmap(
                FrameWidth * Columns,
                FrameHeight * Rows,
                PixelFormat.Format32bppArgb
            ))
            {
                for (int index = 0; index < bounds.Length; index++)
                {
                    Rectangle crop = bounds[index];
                    int outputWidth = Math.Max(1, (int)Math.Round(crop.Width * scale));
                    int outputHeight = Math.Max(1, (int)Math.Round(crop.Height * scale));
                    int frameColumn = index % Columns;
                    int frameRow = index / Columns;
                    int cellLeft = source.Width * frameColumn / Columns;
                    int cellRight = source.Width * (frameColumn + 1) / Columns;
                    double cellCenter = (cellLeft + cellRight) * 0.5;
                    int startX = frameColumn * FrameWidth
                        + FrameWidth / 2
                        + (int)Math.Round((crop.Left - cellCenter) * scale);
                    int startY = frameRow * FrameHeight + FeetBaseline - outputHeight;

                    for (int y = 0; y < outputHeight; y++)
                    {
                        int sourceY = crop.Top + Math.Min(
                            crop.Height - 1,
                            y * crop.Height / outputHeight
                        );
                        for (int x = 0; x < outputWidth; x++)
                        {
                            int sourceX = crop.Left + Math.Min(
                                crop.Width - 1,
                                x * crop.Width / outputWidth
                            );
                            Color sourceColor = source.GetPixel(sourceX, sourceY);
                            output.SetPixel(
                                startX + x,
                                startY + y,
                                IsBackground(sourceColor) ? Color.Transparent : sourceColor
                            );
                        }
                    }
                }

                Directory.CreateDirectory(Path.GetDirectoryName(outputPath));
                output.Save(outputPath, ImageFormat.Png);
            }

            return String.Format(
                "Wrote {0} ({1}x{2}, {3}x{4} frames, scale={5:F4})",
                outputPath,
                FrameWidth * Columns,
                FrameHeight * Rows,
                FrameWidth,
                FrameHeight,
                scale
            );
        }
    }
}
'@

Add-Type -TypeDefinition $processorSource -ReferencedAssemblies System.Drawing
[AdventurerAttackProcessor]::Process($SourcePath, $OutputPath)
