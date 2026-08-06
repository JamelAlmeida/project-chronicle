using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.Runtime.InteropServices;
using System.Text;

/// <summary>
/// Crops clean isolated pieces from Chronicle Showcase Master Pack v1 sheets.
/// Skips baked combat-number glyphs — Godot Labels remain authoritative for damage text.
/// </summary>
public static class ChronicleShowcaseMasterProcessor
{
	public static int Main(string[] args)
	{
		if (args.Length < 6)
		{
			Console.WriteLine(
				"Usage: ChronicleShowcaseMasterProcessor <uiFrames> <uiSlots> <hearthvale> <elderwood> <combat> <runtimeRoot>"
			);
			return 1;
		}

		string runtimeRoot = args[5];
		string uiDir = Path.Combine(runtimeRoot, "UI");
		string envDir = Path.Combine(runtimeRoot, "Environment");
		string combatDir = Path.Combine(runtimeRoot, "Combat");
		foreach (var dir in new[] { uiDir, envDir, combatDir })
		{
			Directory.CreateDirectory(dir);
			Directory.CreateDirectory(Path.Combine(dir, "Debug"));
			File.WriteAllText(Path.Combine(dir, "Debug", ".gdignore"), "");
		}

		var report = new StringBuilder();
		report.AppendLine(CropSheet(args[0], uiDir, UiFramesCrops()));
		report.AppendLine(CropSheet(args[1], uiDir, UiSlotsCrops()));
		report.AppendLine(CropSheet(args[2], envDir, HearthvaleCrops()));
		report.AppendLine(CropSheet(args[3], envDir, ElderwoodCrops()));
		report.AppendLine(CropSheet(args[4], combatDir, CombatCrops()));

		MakeNine(uiDir, "panel_tracker", 22);
		MakeNine(uiDir, "panel_compact", 22);
		MakeNine(uiDir, "panel_header", 20);
		MakeNine(uiDir, "panel_main", 28);
		MakeNine(uiDir, "status_island", 24);
		MakeNine(uiDir, "action_island", 18);
		MakeNine(uiDir, "menu_island", 18);
		MakeNine(uiDir, "bar_empty", 8);
		MakeNine(uiDir, "bar_thin", 6);
		MakeNine(uiDir, "bar_hp", 8);
		MakeNine(uiDir, "bar_steadfast", 8);
		MakeNine(uiDir, "xp_bar", 8);
		MakeNine(uiDir, "btn_chrome", 14);
		MakeNine(uiDir, "slot_empty", 12);
		MakeNine(uiDir, "slot_selected", 12);

		Console.Write(report.ToString());
		File.WriteAllText(Path.Combine(runtimeRoot, "_crop_report.txt"), report.ToString());
		return 0;
	}

	static Dictionary<string, Rectangle> UiFramesCrops()
	{
		// chronicle_showcase_ui_frames_bars_v1.png (1536x1024)
		return new Dictionary<string, Rectangle>
		{
			{ "panel_tracker", new Rectangle(20, 55, 420, 175) },
			{ "panel_compact", new Rectangle(520, 55, 500, 130) },
			{ "panel_header", new Rectangle(1080, 55, 390, 180) },
			{ "status_island", new Rectangle(8, 270, 1000, 220) },
			{ "crest_ring", new Rectangle(70, 300, 125, 150) },
			{ "action_island", new Rectangle(10, 515, 1000, 190) },
			{ "menu_island", new Rectangle(1040, 535, 470, 140) },
			{ "bar_steadfast", new Rectangle(12, 765, 770, 50) },
			{ "bar_hp", new Rectangle(10, 855, 775, 65) },
			{ "bar_empty", new Rectangle(10, 930, 780, 45) },
			{ "bar_thin", new Rectangle(830, 745, 680, 30) },
			{ "xp_bar", new Rectangle(970, 890, 520, 55) },
			{ "bottom_hud", new Rectangle(805, 845, 710, 145) },
			{ "divider_flourish", new Rectangle(145, 650, 860, 30) },
		};
	}

	static Dictionary<string, Rectangle> UiSlotsCrops()
	{
		// chronicle_showcase_ui_slots_icons_v1.png (1536x1024)
		return new Dictionary<string, Rectangle>
		{
			{ "slot_empty", new Rectangle(20, 55, 130, 140) },
			{ "slot_selected", new Rectangle(190, 50, 155, 155) },
			{ "slot_square", new Rectangle(390, 55, 140, 145) },
			{ "slot_square_alt", new Rectangle(585, 55, 140, 145) },
			{ "slot_locked_frame", new Rectangle(775, 55, 145, 145) },
			{ "btn_chrome", new Rectangle(1150, 45, 295, 100) },
			{ "btn_wide", new Rectangle(1145, 160, 295, 95) },
			{ "btn_menu", new Rectangle(1145, 400, 355, 85) },
			{ "panel_section", new Rectangle(960, 385, 145, 250) },
			{ "icon_lock", new Rectangle(975, 225, 80, 110) },
			{ "icon_fire", new Rectangle(220, 770, 145, 135) },
			{ "icon_shadow", new Rectangle(420, 770, 140, 135) },
			{ "icon_slash", new Rectangle(600, 770, 140, 130) },
			{ "icon_nature", new Rectangle(800, 775, 125, 120) },
			{ "icon_potion", new Rectangle(960, 770, 105, 135) },
			{ "icon_bag", new Rectangle(1100, 770, 120, 130) },
			{ "icon_scroll", new Rectangle(1360, 770, 120, 130) },
			{ "icon_helm", new Rectangle(1245, 815, 90, 90) },
			{ "icon_sword", new Rectangle(45, 790, 125, 100) },
			{ "divider_short", new Rectangle(0, 675, 235, 35) },
		};
	}

	static Dictionary<string, Rectangle> HearthvaleCrops()
	{
		// chronicle_showcase_hearthvale_assets_v1.png (1536x1024)
		return new Dictionary<string, Rectangle>
		{
			{ "cottage_large", new Rectangle(10, 25, 450, 400) },
			{ "cottage_medium", new Rectangle(470, 80, 400, 200) },
			{ "roof_a", new Rectangle(900, 85, 200, 165) },
			{ "roof_b", new Rectangle(1100, 110, 185, 140) },
			{ "roof_c", new Rectangle(1290, 115, 155, 135) },
			{ "chimney_a", new Rectangle(1170, 25, 120, 90) },
			{ "chimney_b", new Rectangle(1335, 25, 95, 90) },
			{ "elderwood_sign", new Rectangle(1125, 400, 405, 175) },
			{ "banner_crest", new Rectangle(915, 390, 145, 290) },
			{ "lantern_post", new Rectangle(1020, 250, 490, 180) },
			{ "fence_a", new Rectangle(1220, 685, 165, 70) },
			{ "fence_b", new Rectangle(830, 790, 150, 70) },
			{ "barrels", new Rectangle(1275, 825, 245, 115) },
			{ "ground_long", new Rectangle(5, 790, 725, 180) },
			{ "stone_wall", new Rectangle(960, 800, 315, 145) },
			{ "stone_steps", new Rectangle(730, 860, 230, 85) },
			{ "grass_tuft_a", new Rectangle(720, 955, 160, 35) },
			{ "grass_tuft_b", new Rectangle(880, 955, 175, 35) },
			{ "ground_strip", new Rectangle(1070, 945, 450, 45) },
		};
	}

	static Dictionary<string, Rectangle> ElderwoodCrops()
	{
		// chronicle_showcase_elderwood_assets_v1.png (1536x1024)
		return new Dictionary<string, Rectangle>
		{
			{ "tree_ancient", new Rectangle(0, 15, 380, 540) },
			{ "forest_cluster_a", new Rectangle(330, 25, 530, 270) },
			{ "forest_cluster_b", new Rectangle(850, 35, 650, 270) },
			{ "platform_wide", new Rectangle(390, 300, 545, 385) },
			{ "platform_ledge", new Rectangle(225, 305, 420, 135) },
			{ "ruined_arch", new Rectangle(1235, 310, 280, 235) },
			{ "stone_arch_piece", new Rectangle(1100, 315, 145, 160) },
			{ "waystone", new Rectangle(920, 310, 160, 165) },
			{ "lantern_ruin", new Rectangle(1405, 550, 85, 170) },
			{ "platform_corner", new Rectangle(0, 555, 425, 225) },
			{ "platform_mid", new Rectangle(650, 570, 380, 155) },
			{ "rock_cluster", new Rectangle(1225, 565, 185, 155) },
			{ "platform_low", new Rectangle(0, 705, 630, 270) },
			{ "mushrooms", new Rectangle(920, 845, 65, 70) },
			{ "bush_dark", new Rectangle(850, 865, 70, 60) },
			{ "grass_dark_a", new Rectangle(620, 875, 55, 55) },
			{ "grass_dark_b", new Rectangle(670, 880, 90, 60) },
			{ "fireflies", new Rectangle(1030, 900, 480, 95) },
			{ "rubble", new Rectangle(1000, 810, 190, 85) },
		};
	}

	static Dictionary<string, Rectangle> CombatCrops()
	{
		// chronicle_showcase_combat_fx_slimes_v1.png (1536x1024)
		// Slime idle/hop frames — skip baked damage glyphs (Godot Labels own that).
		return new Dictionary<string, Rectangle>
		{
			{ "slime_idle_00", new Rectangle(0, 100, 95, 100) },
			{ "slime_idle_01", new Rectangle(110, 95, 130, 105) },
			{ "slime_idle_02", new Rectangle(265, 85, 175, 120) },
			{ "slime_idle_03", new Rectangle(455, 50, 200, 150) },
			{ "slime_idle_04", new Rectangle(655, 45, 290, 160) },
			{ "slime_idle_05", new Rectangle(955, 95, 270, 110) },
			{ "slime_idle_06", new Rectangle(1255, 145, 200, 60) },
			{ "slime_hop_00", new Rectangle(0, 300, 100, 100) },
			{ "slime_hop_01", new Rectangle(115, 285, 150, 110) },
			{ "slime_hop_02", new Rectangle(285, 280, 165, 115) },
			{ "slime_hop_03", new Rectangle(470, 245, 190, 150) },
			{ "slime_hop_04", new Rectangle(665, 220, 295, 175) },
			{ "slime_hop_05", new Rectangle(970, 290, 250, 105) },
			{ "slime_hop_06", new Rectangle(1255, 340, 205, 60) },
			{ "slash_a", new Rectangle(0, 445, 380, 150) },
			{ "slash_b", new Rectangle(345, 465, 375, 120) },
			{ "slash_c", new Rectangle(0, 645, 420, 160) },
			{ "slash_d", new Rectangle(460, 640, 290, 150) },
			{ "hit_spark_a", new Rectangle(775, 440, 200, 150) },
			{ "hit_spark_b", new Rectangle(1015, 430, 165, 150) },
			{ "hit_spark_c", new Rectangle(1255, 425, 195, 155) },
			{ "loot_sparkle", new Rectangle(800, 650, 280, 140) },
			// Do NOT crop hit_burst — that sheet region is baked "2147! CRIT!" example glyphs.
			// Runtime damage numbers are always Godot Labels driven by resolved combat amounts.
		};
	}

	static string CropSheet(string sourcePath, string runtimeDir, Dictionary<string, Rectangle> crops)
	{
		var sb = new StringBuilder();
		sb.Append(Path.GetFileName(sourcePath)).Append(": ");
		string debugDir = Path.Combine(runtimeDir, "Debug");
		using (var source = new Bitmap(sourcePath))
		{
			foreach (var kv in crops)
			{
				var r = ClampRect(source, kv.Value);
				using (var piece = source.Clone(r, PixelFormat.Format32bppArgb))
				{
					KeyNearBlack(piece, 18);
					Bitmap trimmed;
					TrimTransparent(piece, out trimmed);
					using (trimmed)
					{
						if (trimmed.Width < 6 || trimmed.Height < 6)
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
