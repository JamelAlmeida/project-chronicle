param(
    [string]$SourcePath = (Join-Path $PSScriptRoot "adventurer_directional_source.png"),
    [string]$OutputPath = (Join-Path (Split-Path $PSScriptRoot -Parent) "adventurer_base_32x48.png")
)

$processorSource = @'
using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.Runtime.InteropServices;

public static class AdventurerSpriteProcessor
{
    private const int GridSize = 4;
    private const int FrameWidth = 32;
    private const int FrameHeight = 48;
    private const int ContentWidth = 30;
    private const int ContentHeight = 44;
    private const int FeetBaseline = 46;

    public static string Process(string sourcePath, string outputPath)
    {
        using (Bitmap source = new Bitmap(sourcePath))
        {
            Rectangle sourceRect = new Rectangle(0, 0, source.Width, source.Height);
            BitmapData data = source.LockBits(
                sourceRect,
                ImageLockMode.ReadWrite,
                PixelFormat.Format32bppArgb
            );
            int byteCount = Math.Abs(data.Stride) * source.Height;
            byte[] pixels = new byte[byteCount];
            Marshal.Copy(data.Scan0, pixels, 0, byteCount);

            int[] minX = new int[GridSize * GridSize];
            int[] minY = new int[GridSize * GridSize];
            int[] maxX = new int[GridSize * GridSize];
            int[] maxY = new int[GridSize * GridSize];
            for (int i = 0; i < minX.Length; i++)
            {
                minX[i] = source.Width;
                minY[i] = source.Height;
                maxX[i] = -1;
                maxY[i] = -1;
            }

            for (int y = 0; y < source.Height; y++)
            {
                for (int x = 0; x < source.Width; x++)
                {
                    int offset = y * data.Stride + x * 4;
                    byte blue = pixels[offset];
                    byte green = pixels[offset + 1];
                    byte red = pixels[offset + 2];
                    bool isBackground =
                        red > 180 && blue > 180 && green < 110
                        && Math.Abs(red - blue) < 110;

                    if (isBackground)
                    {
                        pixels[offset] = 0;
                        pixels[offset + 1] = 0;
                        pixels[offset + 2] = 0;
                        pixels[offset + 3] = 0;
                        continue;
                    }

                    pixels[offset + 3] = 255;
                    int column = Math.Min(GridSize - 1, x * GridSize / source.Width);
                    int row = Math.Min(GridSize - 1, y * GridSize / source.Height);
                    int index = row * GridSize + column;
                    minX[index] = Math.Min(minX[index], x);
                    minY[index] = Math.Min(minY[index], y);
                    maxX[index] = Math.Max(maxX[index], x);
                    maxY[index] = Math.Max(maxY[index], y);
                }
            }

            Marshal.Copy(pixels, 0, data.Scan0, byteCount);
            source.UnlockBits(data);

            int maxWidth = 0;
            int maxHeight = 0;
            for (int i = 0; i < minX.Length; i++)
            {
                if (maxX[i] < minX[i] || maxY[i] < minY[i])
                    throw new InvalidDataException("A generated frame contains no character pixels.");
                maxWidth = Math.Max(maxWidth, maxX[i] - minX[i] + 1);
                maxHeight = Math.Max(maxHeight, maxY[i] - minY[i] + 1);
            }

            double scale = Math.Min(
                (double)ContentWidth / maxWidth,
                (double)ContentHeight / maxHeight
            );
            using (Bitmap output = new Bitmap(
                FrameWidth * GridSize,
                FrameHeight * GridSize,
                PixelFormat.Format32bppArgb
            ))
            {
                for (int index = 0; index < GridSize * GridSize; index++)
                {
                    int cropWidth = maxX[index] - minX[index] + 1;
                    int cropHeight = maxY[index] - minY[index] + 1;
                    int width = Math.Max(1, (int)Math.Round(cropWidth * scale));
                    int height = Math.Max(1, (int)Math.Round(cropHeight * scale));
                    int frameColumn = index % GridSize;
                    int frameRow = index / GridSize;
                    int startX = frameColumn * FrameWidth + (FrameWidth - width) / 2;
                    int startY = frameRow * FrameHeight + FeetBaseline - height;

                    for (int y = 0; y < height; y++)
                    {
                        int sourceY = minY[index] + Math.Min(
                            cropHeight - 1,
                            y * cropHeight / height
                        );
                        for (int x = 0; x < width; x++)
                        {
                            int sourceX = minX[index] + Math.Min(
                                cropWidth - 1,
                                x * cropWidth / width
                            );
                            output.SetPixel(startX + x, startY + y, source.GetPixel(sourceX, sourceY));
                        }
                    }
                }

                Directory.CreateDirectory(Path.GetDirectoryName(outputPath));
                output.Save(outputPath, ImageFormat.Png);
            }

            return String.Format(
                "Wrote {0} ({1}x{2}, {3}x{4} frames, scale={5:F4})",
                outputPath,
                FrameWidth * GridSize,
                FrameHeight * GridSize,
                FrameWidth,
                FrameHeight,
                scale
            );
        }
    }
}
'@

Add-Type -TypeDefinition $processorSource -ReferencedAssemblies System.Drawing
[AdventurerSpriteProcessor]::Process($SourcePath, $OutputPath)
