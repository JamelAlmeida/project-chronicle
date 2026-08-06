using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.Runtime.InteropServices;
using System.Text;

/// <summary>
/// Crops clean isolated UI pieces from Chronicle UI Rescue V2 source sheets.
/// Skips assembled mega-layouts and baked text regions.
/// </summary>
public static class ChronicleUiRescueV2Processor
{
	public static int Main(string[] args)
	{
		if (args.Length < 4)
		{
			Console.WriteLine("Usage: ChronicleUiRescueV2Processor <frames> <slots> <character> <runtimeDir>");
			return 1;
		}

		string runtimeDir = args[3];
		Directory.CreateDirectory(runtimeDir);
		string debugDir = Path.Combine(runtimeDir, "Debug");
		Directory.CreateDirectory(debugDir);
		File.WriteAllText(Path.Combine(debugDir, ".gdignore"), "");

		foreach (var old in Directory.GetFiles(runtimeDir))
		{
			string name = Path.GetFileName(old);
			if (name.StartsWith("_")) continue;
			File.Delete(old);
		}

		var report = new StringBuilder();
		report.AppendLine(CropSheet(args[0], runtimeDir, debugDir, FramesCrops()));
		report.AppendLine(CropSheet(args[1], runtimeDir, debugDir, SlotsCrops()));
		report.AppendLine(CropSheet(args[2], runtimeDir, debugDir, CharacterCrops()));

		MakeNine(runtimeDir, "panel_main", 42);
		MakeNine(runtimeDir, "panel_tracker", 28);
		MakeNine(runtimeDir, "panel_compact", 28);
		MakeNine(runtimeDir, "panel_section", 26);
		MakeNine(runtimeDir, "panel_header", 22);
		MakeNine(runtimeDir, "bottom_hud", 20);
		MakeNine(runtimeDir, "bar_empty", 10);
		MakeNine(runtimeDir, "bar_thin", 8);
		MakeNine(runtimeDir, "btn_chrome", 16);
		MakeNine(runtimeDir, "slot_empty", 14);
		MakeNine(runtimeDir, "slot_selected", 14);

		Console.Write(report.ToString());
		File.WriteAllText(Path.Combine(runtimeDir, "_crop_report.txt"), report.ToString());
		return 0;
	}

	static Dictionary<string, Rectangle> FramesCrops()
	{
		// chronicle_ui_frames_bars_v2.png — isolated frames/bars only.
		return new Dictionary<string, Rectangle>
		{
			{ "panel_main", new Rectangle(24, 56, 838, 555) },
			{ "panel_tracker", new Rectangle(949, 46, 554, 71) },
			{ "panel_compact", new Rectangle(949, 158, 273, 188) },
			{ "panel_header", new Rectangle(1267, 158, 231, 83) },
			{ "bar_ornate", new Rectangle(940, 386, 555, 89) },
			{ "bar_empty", new Rectangle(941, 516, 560, 42) },
			{ "crest_ring", new Rectangle(51, 660, 160, 172) },
			{ "bottom_hud", new Rectangle(277, 670, 1122, 88) },
			{ "bar_segmented", new Rectangle(280, 824, 1118, 80) },
			{ "panel_small", new Rectangle(8, 874, 230, 83) },
			{ "bar_thin", new Rectangle(281, 943, 915, 31) },
			{ "divider_flourish", new Rectangle(946, 587, 290, 42) },
		};
	}

	static Dictionary<string, Rectangle> SlotsCrops()
	{
		// chronicle_ui_slots_icons_v2.png — slots, buttons, icons. No baked labels.
		return new Dictionary<string, Rectangle>
		{
			{ "slot_selected", new Rectangle(73, 78, 181, 175) },
			{ "slot_empty", new Rectangle(307, 63, 253, 207) },
			{ "btn_wide", new Rectangle(592, 64, 388, 102) },
			{ "btn_chrome", new Rectangle(593, 197, 388, 81) },
			{ "panel_section", new Rectangle(1014, 62, 211, 125) },
			{ "panel_inset", new Rectangle(1258, 61, 219, 125) },
			{ "btn_plus", new Rectangle(604, 309, 59, 58) },
			{ "btn_minus", new Rectangle(676, 309, 61, 58) },
			{ "portrait_ring", new Rectangle(794, 339, 140, 130) },
			{ "hotbar_strip", new Rectangle(78, 318, 470, 54) },
			{ "slot_square", new Rectangle(665, 679, 100, 86) },
			{ "slot_square_alt", new Rectangle(791, 682, 87, 83) },
			{ "icon_sword", new Rectangle(50, 814, 100, 109) },
			{ "icon_fire", new Rectangle(175, 816, 113, 106) },
			{ "icon_shadow", new Rectangle(304, 816, 112, 106) },
			{ "icon_mage", new Rectangle(435, 818, 111, 106) },
			{ "icon_ice", new Rectangle(564, 818, 111, 104) },
			{ "icon_nature", new Rectangle(695, 818, 110, 104) },
			{ "icon_potion", new Rectangle(839, 827, 77, 83) },
			{ "icon_bag", new Rectangle(961, 818, 112, 103) },
			{ "icon_scroll", new Rectangle(1099, 820, 104, 96) },
			{ "icon_helm", new Rectangle(1234, 822, 101, 101) },
			{ "icon_lock", new Rectangle(1366, 812, 77, 110) },
		};
	}

	static Dictionary<string, Rectangle> CharacterCrops()
	{
		// chronicle_character_window_kit_v2.png — modular pieces only.
		// Skip the assembled mega-window (#00) to avoid nested frame-on-frame use.
		return new Dictionary<string, Rectangle>
		{
			{ "char_btn", new Rectangle(775, 46, 355, 130) },
			{ "char_btn_alt", new Rectangle(1158, 46, 356, 130) },
			{ "char_divider", new Rectangle(776, 200, 738, 26) },
			{ "char_btn_mid", new Rectangle(775, 247, 357, 114) },
			{ "equip_slot", new Rectangle(775, 444, 138, 126) },
			{ "equip_slot_b", new Rectangle(936, 444, 141, 126) },
			{ "equip_slot_c", new Rectangle(1099, 444, 143, 126) },
			{ "equip_slot_wide", new Rectangle(1258, 444, 256, 126) },
			{ "equip_slot_med", new Rectangle(774, 599, 154, 159) },
			{ "equip_slot_med_b", new Rectangle(938, 599, 160, 159) },
			{ "equip_slot_sm", new Rectangle(1312, 600, 96, 93) },
			{ "char_footer", new Rectangle(18, 830, 730, 109) },
			{ "char_divider_long", new Rectangle(774, 832, 737, 31) },
		};
	}

	static string CropSheet(
		string sourcePath,
		string runtimeDir,
		string debugDir,
		Dictionary<string, Rectangle> crops
	)
	{
		var sb = new StringBuilder();
		sb.Append(Path.GetFileName(sourcePath)).Append(": ");
		using (var source = new Bitmap(sourcePath))
		{
			foreach (var kv in crops)
			{
				var r = ClampRect(source, kv.Value);
				using (var piece = source.Clone(r, PixelFormat.Format32bppArgb))
				{
					KeyNearBlack(piece, 14);
					Bitmap trimmed;
					TrimTransparent(piece, out trimmed);
					using (trimmed)
					{
						if (trimmed.Width < 8 || trimmed.Height < 8)
						{
							sb.Append("[skip:").Append(kv.Key).Append("] ");
							continue;
						}
						string path = Path.Combine(runtimeDir, kv.Key + ".png");
						trimmed.Save(path, ImageFormat.Png);
						trimmed.Save(Path.Combine(debugDir, kv.Key + ".png"), ImageFormat.Png);
						sb.Append(kv.Key).Append(" ");
					}
				}
			}
		}
		return sb.ToString();
	}

	static void MakeNine(string runtimeDir, string name, int margin)
	{
		string src = Path.Combine(runtimeDir, name + ".png");
		if (!File.Exists(src)) return;
		File.Copy(src, Path.Combine(runtimeDir, name + "_9.png"), true);
		File.WriteAllText(
			Path.Combine(runtimeDir, name + "_9.patch.txt"),
			string.Format("left={0}\nright={0}\ntop={0}\nbottom={0}\n", margin)
		);
	}

	static void KeyNearBlack(Bitmap bmp, int threshold)
	{
		var rect = new Rectangle(0, 0, bmp.Width, bmp.Height);
		var data = bmp.LockBits(rect, ImageLockMode.ReadWrite, PixelFormat.Format32bppArgb);
		try
		{
			int stride = Math.Abs(data.Stride);
			byte[] pixels = new byte[stride * bmp.Height];
			Marshal.Copy(data.Scan0, pixels, 0, pixels.Length);
			for (int y = 0; y < bmp.Height; y++)
			{
				int row = y * stride;
				for (int x = 0; x < bmp.Width; x++)
				{
					int o = row + x * 4;
					if (pixels[o] <= threshold && pixels[o + 1] <= threshold && pixels[o + 2] <= threshold)
						pixels[o + 3] = 0;
				}
			}
			Marshal.Copy(pixels, 0, data.Scan0, pixels.Length);
		}
		finally { bmp.UnlockBits(data); }
	}

	static void TrimTransparent(Bitmap src, out Bitmap trimmed)
	{
		var rect = new Rectangle(0, 0, src.Width, src.Height);
		var data = src.LockBits(rect, ImageLockMode.ReadOnly, PixelFormat.Format32bppArgb);
		int stride = Math.Abs(data.Stride);
		byte[] pixels = new byte[stride * src.Height];
		Marshal.Copy(data.Scan0, pixels, 0, pixels.Length);
		src.UnlockBits(data);

		int minX = src.Width, minY = src.Height, maxX = -1, maxY = -1;
		for (int y = 0; y < src.Height; y++)
		{
			int row = y * stride;
			for (int x = 0; x < src.Width; x++)
			{
				if (pixels[row + x * 4 + 3] < 12) continue;
				if (x < minX) minX = x;
				if (x > maxX) maxX = x;
				if (y < minY) minY = y;
				if (y > maxY) maxY = y;
			}
		}
		if (maxX < minX)
		{
			trimmed = new Bitmap(1, 1, PixelFormat.Format32bppArgb);
			return;
		}
		int pad = 2;
		minX = Math.Max(0, minX - pad);
		minY = Math.Max(0, minY - pad);
		maxX = Math.Min(src.Width - 1, maxX + pad);
		maxY = Math.Min(src.Height - 1, maxY + pad);
		trimmed = src.Clone(new Rectangle(minX, minY, maxX - minX + 1, maxY - minY + 1), PixelFormat.Format32bppArgb);
	}

	static Rectangle ClampRect(Bitmap src, Rectangle r)
	{
		int x = Math.Max(0, Math.Min(src.Width - 1, r.X));
		int y = Math.Max(0, Math.Min(src.Height - 1, r.Y));
		int w = Math.Max(1, Math.Min(src.Width - x, r.Width));
		int h = Math.Max(1, Math.Min(src.Height - y, r.Height));
		return new Rectangle(x, y, w, h);
	}
}
