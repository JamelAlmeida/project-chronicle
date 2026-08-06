using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;

public static class ChronicleKitProcessorV2
{
	const int FrameCanvasW = 96;
	const int FrameCanvasH = 112;
	const int FeetBaseline = 104;
	const int FramePad = 2;
	const int BgTolerance = 42;
	const int MinBlobArea = 800;

	public static int Main(string[] args)
	{
		if (args.Length < 4)
		{
			Console.WriteLine("Usage: ChronicleKitProcessorV2 <advSource> <advRuntime> <uiSource> <uiRuntime>");
			return 1;
		}
		Console.WriteLine(ProcessAdventurer(args[0], args[1]));
		Console.WriteLine(ProcessUi(args[2], args[3]));
		return 0;
	}

	public static string ProcessAdventurer(string sourcePath, string runtimeDir)
	{
		Directory.CreateDirectory(runtimeDir);
		foreach (var old in Directory.GetFiles(runtimeDir)) File.Delete(old);

		using (var source = new Bitmap(sourcePath))
		{
			byte[] pixels;
			int stride;
			LockCopy(source, out pixels, out stride);
			int w = source.Width, h = source.Height;

			FloodClearBackground(pixels, stride, w, h);
			SavePixels(pixels, stride, w, h, Path.Combine(runtimeDir, "_keyed_sheet_preview.png"));

			var blobs = FindBlobs(pixels, stride, w, h)
				.Where(b => b.Area >= MinBlobArea)
				.Where(b => b.Width >= 24 && b.Height >= 40)
				.Where(b => b.Width < w * 0.35)
				.Where(b => b.Height < h * 0.45)
				.OrderBy(b => b.CenterY).ThenBy(b => b.CenterX)
				.ToList();

			// If flood-fill still left mega-blobs, fall back to projection grid.
			if (blobs.Count < 8)
			{
				blobs = ExtractByProjection(pixels, stride, w, h);
				Console.WriteLine("Projection fallback produced " + blobs.Count + " cells");
			}

			var rows = ClusterRows(blobs, 50);
			var animMap = new Dictionary<string, List<Bitmap>>();

			for (int r = 0; r < rows.Count; r++)
			{
				var row = rows[r].OrderBy(b => b.CenterX).ToList();
				for (int i = 0; i < row.Count; i++)
				{
					string role = ClassifyFrame(r, i, row.Count, rows.Count, row[i]);
					if (role == "vfx") continue;
					var framed = ExtractNormalized(pixels, stride, w, h, row[i]);
					if (!animMap.ContainsKey(role)) animMap[role] = new List<Bitmap>();
					animMap[role].Add(framed);
					framed.Save(Path.Combine(runtimeDir, string.Format("frame_r{0}_{1:D2}_{2}.png", r, i, role)), ImageFormat.Png);
				}
			}

			WriteAnimAtlas(runtimeDir, "idle", Prefer(animMap, new[] { "idle" }, 1, 3));
			WriteAnimAtlas(runtimeDir, "run", Prefer(animMap, new[] { "run", "walk" }, 4, 8));
			WriteAnimAtlas(runtimeDir, "jump", Prefer(animMap, new[] { "jump" }, 1, 2));
			WriteAnimAtlas(runtimeDir, "fall", Prefer(animMap, new[] { "fall", "jump" }, 1, 2));
			WriteAnimAtlas(runtimeDir, "dash", Prefer(animMap, new[] { "dash" }, 2, 4));
			WriteAnimAtlas(runtimeDir, "melee_basic", Prefer(animMap, new[] { "melee", "attack" }, 3, 6));

			return string.Format(
				"Adventurer: {0} frames in {1} rows | {2}",
				blobs.Count,
				rows.Count,
				string.Join(", ", animMap.Select(kv => kv.Key + "x" + kv.Value.Count))
			);
		}
	}

	static List<Blob> ExtractByProjection(byte[] pixels, int stride, int w, int h)
	{
		int[] rowCounts = new int[h];
		int[] colCounts = new int[w];
		for (int y = 0; y < h; y++)
		{
			int row = y * stride;
			for (int x = 0; x < w; x++)
			{
				if (pixels[row + x * 4 + 3] > 16)
				{
					rowCounts[y]++;
					colCounts[x]++;
				}
			}
		}

		var yBands = ContentBands(rowCounts, 12, 40);
		var result = new List<Blob>();
		foreach (var band in yBands)
		{
			int[] localCols = new int[w];
			for (int y = band.Item1; y <= band.Item2; y++)
			{
				int row = y * stride;
				for (int x = 0; x < w; x++)
				{
					if (pixels[row + x * 4 + 3] > 16) localCols[x]++;
				}
			}
			var xBands = ContentBands(localCols, 8, 20);
			foreach (var xb in xBands)
			{
				int minX = xb.Item1, maxX = xb.Item2, minY = band.Item1, maxY = band.Item2;
				// Tighten to actual opaque pixels.
				Tighten(pixels, stride, w, h, ref minX, ref maxX, ref minY, ref maxY);
				int bw = maxX - minX + 1;
				int bh = maxY - minY + 1;
				if (bw < 24 || bh < 40) continue;
				if (bw > w * 0.35) continue;
				result.Add(new Blob { MinX = minX, MaxX = maxX, MinY = minY, MaxY = maxY, Area = bw * bh });
			}
		}
		return result;
	}

	static void Tighten(byte[] pixels, int stride, int w, int h, ref int minX, ref int maxX, ref int minY, ref int maxY)
	{
		int nMinX = maxX, nMaxX = minX, nMinY = maxY, nMaxY = minY;
		bool any = false;
		for (int y = minY; y <= maxY; y++)
		{
			int row = y * stride;
			for (int x = minX; x <= maxX; x++)
			{
				if (pixels[row + x * 4 + 3] <= 16) continue;
				any = true;
				if (x < nMinX) nMinX = x;
				if (x > nMaxX) nMaxX = x;
				if (y < nMinY) nMinY = y;
				if (y > nMaxY) nMaxY = y;
			}
		}
		if (!any) return;
		minX = nMinX; maxX = nMaxX; minY = nMinY; maxY = nMaxY;
	}

	static List<Tuple<int, int>> ContentBands(int[] counts, int minContent, int minGap)
	{
		var bands = new List<Tuple<int, int>>();
		bool inBand = false;
		int start = 0;
		int gap = 0;
		for (int i = 0; i < counts.Length; i++)
		{
			if (counts[i] >= minContent)
			{
				if (!inBand)
				{
					inBand = true;
					start = i;
				}
				gap = 0;
			}
			else if (inBand)
			{
				gap++;
				if (gap >= minGap)
				{
					bands.Add(Tuple.Create(start, i - gap));
					inBand = false;
					gap = 0;
				}
			}
		}
		if (inBand) bands.Add(Tuple.Create(start, counts.Length - 1));
		return bands;
	}

	static void FloodClearBackground(byte[] pixels, int stride, int w, int h)
	{
		// Sample edge colors.
		var samples = new List<Color>();
		for (int x = 0; x < w; x += 8)
		{
			samples.Add(GetColor(pixels, stride, x, 0));
			samples.Add(GetColor(pixels, stride, x, h - 1));
		}
		for (int y = 0; y < h; y += 8)
		{
			samples.Add(GetColor(pixels, stride, 0, y));
			samples.Add(GetColor(pixels, stride, w - 1, y));
		}
		int br = (int)samples.Average(c => c.R);
		int bg = (int)samples.Average(c => c.G);
		int bb = (int)samples.Average(c => c.B);

		bool[] visited = new bool[w * h];
		var qx = new int[w * h];
		var qy = new int[w * h];
		int qh = 0, qt = 0;

		Action<int, int> enqueue = (x, y) =>
		{
			int idx = y * w + x;
			if (visited[idx]) return;
			Color c = GetColor(pixels, stride, x, y);
			if (!Near(c, br, bg, bb, BgTolerance)) return;
			visited[idx] = true;
			qx[qt] = x; qy[qt] = y; qt++;
		};

		for (int x = 0; x < w; x++) { enqueue(x, 0); enqueue(x, h - 1); }
		for (int y = 0; y < h; y++) { enqueue(0, y); enqueue(w - 1, y); }

		while (qh < qt)
		{
			int cx = qx[qh];
			int cy = qy[qh];
			qh++;
			int o = cy * stride + cx * 4;
			pixels[o] = 0; pixels[o + 1] = 0; pixels[o + 2] = 0; pixels[o + 3] = 0;
			if (cx > 0) enqueue(cx - 1, cy);
			if (cx + 1 < w) enqueue(cx + 1, cy);
			if (cy > 0) enqueue(cx, cy - 1);
			if (cy + 1 < h) enqueue(cx, cy + 1);
		}

		// Also hard-clear remaining near-bg islands that are tiny? Skip.
		// Soft-edge cleanup: clear near-bg pixels with low saturation residual.
		for (int y = 0; y < h; y++)
		{
			int row = y * stride;
			for (int x = 0; x < w; x++)
			{
				int o = row + x * 4;
				if (pixels[o + 3] == 0) continue;
				if (Near(Color.FromArgb(pixels[o + 2], pixels[o + 1], pixels[o]), br, bg, bb, BgTolerance - 8))
				{
					// Only clear if neighbors mostly transparent/bg to avoid eating cloak edges too aggressively.
					int transparentNeighbors = 0;
					for (int oy = -1; oy <= 1; oy++)
					for (int ox = -1; ox <= 1; ox++)
					{
						int nx = x + ox, ny = y + oy;
						if (nx < 0 || ny < 0 || nx >= w || ny >= h) { transparentNeighbors++; continue; }
						if (pixels[ny * stride + nx * 4 + 3] < 16) transparentNeighbors++;
					}
					if (transparentNeighbors >= 4)
					{
						pixels[o] = 0; pixels[o + 1] = 0; pixels[o + 2] = 0; pixels[o + 3] = 0;
					}
				}
			}
		}
	}

	static bool Near(Color c, int r, int g, int b, int tol)
	{
		return Math.Abs(c.R - r) <= tol && Math.Abs(c.G - g) <= tol && Math.Abs(c.B - b) <= tol;
	}

	static Color GetColor(byte[] pixels, int stride, int x, int y)
	{
		int o = y * stride + x * 4;
		return Color.FromArgb(pixels[o + 3], pixels[o + 2], pixels[o + 1], pixels[o]);
	}

	static string ClassifyFrame(int row, int index, int rowCount, int totalRows, Blob b)
	{
		if (b.Width > b.Height * 1.45f) return "vfx";
		if (row == 0) return index == 0 ? "idle" : "walk";
		if (row == 1) return "run";
		if (row == 2)
		{
			if (index <= 1) return index == 0 ? "jump" : "fall";
			if (index <= 4) return "dash";
			return "attack";
		}
		if (row == 3)
		{
			if (index <= 1) return "dash";
			return "idle";
		}
		if (row >= 4)
		{
			if (b.Width > b.Height * 1.2f) return "vfx";
			return "melee";
		}
		return "misc";
	}

	static List<Bitmap> Prefer(Dictionary<string, List<Bitmap>> map, string[] names, int minCount, int maxCount)
	{
		foreach (var name in names)
		{
			if (map.ContainsKey(name) && map[name].Count > 0)
				return PickList(map[name], minCount, maxCount);
		}
		foreach (var kv in map)
			if (kv.Value.Count > 0) return PickList(kv.Value, minCount, maxCount);
		return new List<Bitmap>();
	}

	static List<Bitmap> PickList(List<Bitmap> source, int minCount, int maxCount)
	{
		var list = source.Take(maxCount).ToList();
		while (list.Count < minCount && source.Count > 0)
			list.Add(source[list.Count % source.Count]);
		return list;
	}

	static void WriteAnimAtlas(string runtimeDir, string name, List<Bitmap> frames)
	{
		if (frames == null || frames.Count == 0) return;
		using (var atlas = new Bitmap(FrameCanvasW * frames.Count, FrameCanvasH, PixelFormat.Format32bppArgb))
		using (var g = Graphics.FromImage(atlas))
		{
			g.Clear(Color.Transparent);
			g.InterpolationMode = System.Drawing.Drawing2D.InterpolationMode.NearestNeighbor;
			g.PixelOffsetMode = System.Drawing.Drawing2D.PixelOffsetMode.Half;
			for (int i = 0; i < frames.Count; i++)
				g.DrawImageUnscaled(frames[i], i * FrameCanvasW, 0);
			atlas.Save(Path.Combine(runtimeDir, "runtime_" + name + ".png"), ImageFormat.Png);
		}
		File.WriteAllText(
			Path.Combine(runtimeDir, "runtime_" + name + ".meta.txt"),
			string.Format("frame_w={0}\nframe_h={1}\ncount={2}\n", FrameCanvasW, FrameCanvasH, frames.Count)
		);
	}

	static Bitmap ExtractNormalized(byte[] pixels, int stride, int srcW, int srcH, Blob blob)
	{
		int x0 = Math.Max(0, blob.MinX - FramePad);
		int y0 = Math.Max(0, blob.MinY - FramePad);
		int x1 = Math.Min(srcW - 1, blob.MaxX + FramePad);
		int y1 = Math.Min(srcH - 1, blob.MaxY + FramePad);
		int bw = x1 - x0 + 1;
		int bh = y1 - y0 + 1;

		using (var cropped = new Bitmap(bw, bh, PixelFormat.Format32bppArgb))
		{
			var rect = new Rectangle(0, 0, bw, bh);
			var data = cropped.LockBits(rect, ImageLockMode.WriteOnly, PixelFormat.Format32bppArgb);
			try
			{
				byte[] dest = new byte[Math.Abs(data.Stride) * bh];
				for (int y = 0; y < bh; y++)
					Buffer.BlockCopy(pixels, (y0 + y) * stride + x0 * 4, dest, y * data.Stride, bw * 4);
				Marshal.Copy(dest, 0, data.Scan0, dest.Length);
			}
			finally { cropped.UnlockBits(data); }

			var canvas = new Bitmap(FrameCanvasW, FrameCanvasH, PixelFormat.Format32bppArgb);
			using (var g = Graphics.FromImage(canvas))
			{
				g.Clear(Color.Transparent);
				g.InterpolationMode = System.Drawing.Drawing2D.InterpolationMode.NearestNeighbor;
				g.PixelOffsetMode = System.Drawing.Drawing2D.PixelOffsetMode.Half;
				float scale = Math.Min((FrameCanvasW - 8f) / bw, (FeetBaseline - 8f) / bh);
				int dw = Math.Max(1, (int)Math.Round(bw * scale));
				int dh = Math.Max(1, (int)Math.Round(bh * scale));
				int dx = (FrameCanvasW - dw) / 2;
				int dy = FeetBaseline - dh;
				g.DrawImage(cropped, new Rectangle(dx, dy, dw, dh), new Rectangle(0, 0, bw, bh), GraphicsUnit.Pixel);
			}
			return canvas;
		}
	}

	static void LockCopy(Bitmap source, out byte[] pixels, out int stride)
	{
		var rect = new Rectangle(0, 0, source.Width, source.Height);
		var data = source.LockBits(rect, ImageLockMode.ReadOnly, PixelFormat.Format32bppArgb);
		try
		{
			stride = Math.Abs(data.Stride);
			pixels = new byte[stride * source.Height];
			Marshal.Copy(data.Scan0, pixels, 0, pixels.Length);
		}
		finally { source.UnlockBits(data); }
	}

	static void SavePixels(byte[] pixels, int stride, int w, int h, string path)
	{
		using (var bmp = new Bitmap(w, h, PixelFormat.Format32bppArgb))
		{
			var rect = new Rectangle(0, 0, w, h);
			var data = bmp.LockBits(rect, ImageLockMode.WriteOnly, PixelFormat.Format32bppArgb);
			try
			{
				for (int y = 0; y < h; y++)
					Marshal.Copy(pixels, y * stride, IntPtr.Add(data.Scan0, y * data.Stride), w * 4);
			}
			finally { bmp.UnlockBits(data); }
			bmp.Save(path, ImageFormat.Png);
		}
	}

	static List<Blob> FindBlobs(byte[] pixels, int stride, int w, int h)
	{
		bool[] visited = new bool[w * h];
		var blobs = new List<Blob>();
		var qx = new int[w * h];
		var qy = new int[w * h];

		for (int y = 0; y < h; y++)
		for (int x = 0; x < w; x++)
		{
			int idx = y * w + x;
			if (visited[idx]) continue;
			if (pixels[y * stride + x * 4 + 3] < 16) { visited[idx] = true; continue; }

			int qh = 0, qt = 0;
			qx[qt] = x; qy[qt] = y; qt++;
			visited[idx] = true;
			int minX = x, maxX = x, minY = y, maxY = y, area = 0;
			while (qh < qt)
			{
				int cx = qx[qh], cy = qy[qh]; qh++;
				area++;
				if (cx < minX) minX = cx; if (cx > maxX) maxX = cx;
				if (cy < minY) minY = cy; if (cy > maxY) maxY = cy;
				for (int oy = -1; oy <= 1; oy++)
				for (int ox = -1; ox <= 1; ox++)
				{
					if (ox == 0 && oy == 0) continue;
					int nx = cx + ox, ny = cy + oy;
					if (nx < 0 || ny < 0 || nx >= w || ny >= h) continue;
					int nidx = ny * w + nx;
					if (visited[nidx]) continue;
					visited[nidx] = true;
					if (pixels[ny * stride + nx * 4 + 3] < 16) continue;
					qx[qt] = nx; qy[qt] = ny; qt++;
				}
			}
			blobs.Add(new Blob { MinX = minX, MaxX = maxX, MinY = minY, MaxY = maxY, Area = area });
		}
		return blobs;
	}

	static List<List<Blob>> ClusterRows(List<Blob> blobs, int rowTolerance)
	{
		var rows = new List<List<Blob>>();
		foreach (var blob in blobs.OrderBy(b => b.CenterY))
		{
			List<Blob> target = null;
			foreach (var row in rows)
			{
				float avg = (float)row.Average(b => b.CenterY);
				if (Math.Abs(avg - blob.CenterY) <= rowTolerance) { target = row; break; }
			}
			if (target == null) { target = new List<Blob>(); rows.Add(target); }
			target.Add(blob);
		}
		return rows;
	}

	public static string ProcessUi(string sourcePath, string runtimeDir)
	{
		Directory.CreateDirectory(runtimeDir);
		foreach (var old in Directory.GetFiles(runtimeDir))
		{
			string name = Path.GetFileName(old);
			if (name.StartsWith("_")) continue;
			File.Delete(old);
		}

		using (var source = new Bitmap(sourcePath))
		{
			// Coordinates inspected against 1536x1024 modular kit.
			var crops = new Dictionary<string, Rectangle>
			{
				{ "panel_expedition", new Rectangle(28, 28, 360, 200) },
				{ "panel_empty_large", new Rectangle(28, 250, 420, 240) },
				{ "panel_empty_wide", new Rectangle(470, 250, 520, 160) },
				{ "panel_compact", new Rectangle(470, 28, 300, 180) },
				{ "menu_btn_chrome", new Rectangle(820, 40, 250, 54) },
				{ "action_slot", new Rectangle(120, 560, 72, 72) },
				{ "action_slot_selected", new Rectangle(408, 560, 72, 72) },
				{ "hotbar_slots", new Rectangle(40, 548, 760, 96) },
				{ "hud_crest_bar", new Rectangle(40, 660, 900, 120) },
				{ "crest_icon", new Rectangle(52, 680, 88, 88) },
				{ "bar_frame_thin", new Rectangle(40, 800, 620, 34) },
				{ "bar_frame_fill_ref", new Rectangle(40, 840, 620, 34) },
				{ "icon_scroll", new Rectangle(40, 900, 72, 72) },
				{ "icon_book", new Rectangle(130, 900, 72, 72) },
				{ "icon_potion", new Rectangle(220, 900, 72, 72) },
				{ "marker_diamond", new Rectangle(320, 910, 48, 48) },
			};

			var sb = new StringBuilder();
			foreach (var kv in crops)
			{
				var r = ClampRect(source, kv.Value);
				using (var piece = source.Clone(r, PixelFormat.Format32bppArgb))
				{
					// Strip pure black kit backdrop around pieces.
					KeyNearBlack(piece, 18);
					string path = Path.Combine(runtimeDir, kv.Key + ".png");
					piece.Save(path, ImageFormat.Png);
					sb.Append(kv.Key + " ");
				}
			}

			WritePatch(runtimeDir, "panel_expedition", 30);
			WritePatch(runtimeDir, "panel_empty_large", 30);
			WritePatch(runtimeDir, "panel_empty_wide", 28);
			WritePatch(runtimeDir, "panel_compact", 24);
			WritePatch(runtimeDir, "action_slot", 14);
			WritePatch(runtimeDir, "bar_frame_thin", 10);
			WritePatch(runtimeDir, "menu_btn_chrome", 12);
			WritePatch(runtimeDir, "hud_crest_bar", 22);

			return "UI crops: " + sb.ToString();
		}
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

	static Rectangle ClampRect(Bitmap src, Rectangle r)
	{
		int x = Math.Max(0, Math.Min(src.Width - 1, r.X));
		int y = Math.Max(0, Math.Min(src.Height - 1, r.Y));
		int w = Math.Max(1, Math.Min(src.Width - x, r.Width));
		int h = Math.Max(1, Math.Min(src.Height - y, r.Height));
		return new Rectangle(x, y, w, h);
	}

	static void WritePatch(string runtimeDir, string name, int margin)
	{
		string src = Path.Combine(runtimeDir, name + ".png");
		if (!File.Exists(src)) return;
		File.Copy(src, Path.Combine(runtimeDir, name + "_9.png"), true);
		File.WriteAllText(
			Path.Combine(runtimeDir, name + "_9.patch.txt"),
			string.Format("left={0}\nright={0}\ntop={0}\nbottom={0}\n", margin)
		);
	}

	class Blob
	{
		public int MinX, MaxX, MinY, MaxY, Area;
		public int Width { get { return MaxX - MinX + 1; } }
		public int Height { get { return MaxY - MinY + 1; } }
		public float CenterX { get { return (MinX + MaxX) * 0.5f; } }
		public float CenterY { get { return (MinY + MaxY) * 0.5f; } }
	}
}
