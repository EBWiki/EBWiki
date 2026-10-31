#!/usr/bin/env python3
"""Contrast matrix for a brand palette.

Usage: python3 contrast_matrix.py palette.json [--out DIR]

Palette JSON, either form:
  {"name": "site", "colors": {"ink": "#111111", "paper": "#ffffff"}}
  {"name": "site", "colors": [{"name": "ink", "hex": "#111", "role": "text"}],
   "pairs": [{"fg": "ink", "bg": "paper", "use": "body"}]}
"pairs" is optional. When given, the markdown lists those real pairings first.

Writes <name>-contrast.png, <name>-contrast.md and <name>-cvd.png.
Contrast math: WCAG 2.2 relative luminance and contrast ratio
  https://www.w3.org/TR/WCAG22/#dfn-relative-luminance
Color-blind simulation: Machado, Oliveira and Fernandes 2009, severity 1.0,
applied in linear RGB
  https://www.inf.ufrgs.br/~oliveira/pubs_files/CVD_Simulation/CVD_Simulation.html
"""
import argparse, json, math, os, sys
from PIL import Image, ImageDraw, ImageFont

TEXT_AA = 4.5   # normal text, WCAG 1.4.3
LARGE_AA = 3.0  # large text (24px, or 18.66px bold) and UI parts, WCAG 1.4.3 and 1.4.11

MACHADO = {
    "protanopia": [[0.152286, 1.052583, -0.204868],
                   [0.114503, 0.786281, 0.099216],
                   [-0.003882, -0.048116, 1.051998]],
    "deuteranopia": [[0.367322, 0.860646, -0.227968],
                     [0.280085, 0.672501, 0.047413],
                     [-0.011820, 0.042940, 0.968881]],
}

def parse_hex(h):
    h = h.strip().lstrip("#")
    if len(h) in (3, 4):
        h = "".join(c * 2 for c in h[:3])
    if len(h) not in (6, 8):
        raise ValueError(f"bad hex color: {h!r}")
    return tuple(int(h[i:i + 2], 16) for i in (0, 2, 4))

def to_hex(rgb):
    return "#" + "".join(f"{max(0, min(255, round(v))):02x}" for v in rgb)

def _lin(c):
    c = c / 255.0
    return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4

def _unlin(c):
    c = max(0.0, min(1.0, c))
    return 255 * (12.92 * c if c <= 0.0031308 else 1.055 * c ** (1 / 2.4) - 0.055)

def luminance(rgb):
    r, g, b = (_lin(v) for v in rgb)
    return 0.2126 * r + 0.7152 * g + 0.0722 * b

def contrast(a, b):
    la, lb = sorted((luminance(a), luminance(b)), reverse=True)
    return (la + 0.05) / (lb + 0.05)

def grade(ratio):
    if ratio >= TEXT_AA:
        return "AA"
    if ratio >= LARGE_AA:
        return "large only"
    return "fail"

def simulate(rgb, kind):
    m = MACHADO[kind]
    lin = [_lin(v) for v in rgb]
    out = [sum(m[i][j] * lin[j] for j in range(3)) for i in range(3)]
    return tuple(_unlin(v) for v in out)

def _lab(rgb):
    r, g, b = (_lin(v) for v in rgb)
    x = (0.4124 * r + 0.3576 * g + 0.1805 * b) / 0.95047
    y = 0.2126 * r + 0.7152 * g + 0.0722 * b
    z = (0.0193 * r + 0.1192 * g + 0.9505 * b) / 1.08883
    f = lambda t: t ** (1 / 3) if t > 0.008856 else 7.787 * t + 16 / 116
    fx, fy, fz = f(x), f(y), f(z)
    return 116 * fy - 16, 500 * (fx - fy), 200 * (fy - fz)

def delta_e(a, b):
    return math.dist(_lab(a), _lab(b))

def load_palette(path):
    with open(path) as fh:
        data = json.load(fh)
    cols = data["colors"]
    if isinstance(cols, dict):
        cols = [{"name": k, "hex": v} for k, v in cols.items()]
    colors = [{"name": c["name"], "hex": c["hex"], "role": c.get("role", ""),
               "rgb": parse_hex(c["hex"])} for c in cols]
    return data.get("name", os.path.splitext(os.path.basename(path))[0]), colors, data.get("pairs", [])

def matrix(colors):
    return [[contrast(f["rgb"], b["rgb"]) for b in colors] for f in colors]

def _font(size, bold=False):
    p = "/usr/share/fonts/truetype/dejavu/DejaVuSans%s.ttf" % ("-Bold" if bold else "")
    try:
        return ImageFont.truetype(p, size)
    except OSError:
        return ImageFont.load_default()

def draw_grid(name, colors, mx, path):
    n, cell, head = len(colors), 120, 150
    img = Image.new("RGB", (head + n * cell, head + n * cell + 40), "white")
    d = ImageDraw.Draw(img)
    f, fb = _font(13), _font(15, True)
    d.text((10, 10), f"{name}: rows = text, columns = background", fill="black", font=fb)
    for j, c in enumerate(colors):
        x = head + j * cell
        d.rectangle([x, 40, x + cell - 4, head - 6], fill=c["hex"], outline="#999999")
        d.text((x + 4, head - 40), c["name"][:14], fill="black", font=f, stroke_width=2, stroke_fill="white")
    for i, fg in enumerate(colors):
        y = head + i * cell
        d.text((6, y + 40), f"{fg['name'][:16]}\n{fg['hex']}", fill="black", font=f)
        for j, bg in enumerate(colors):
            x = head + j * cell
            r = mx[i][j]
            d.rectangle([x, y, x + cell - 4, y + cell - 4], fill=bg["hex"])
            d.text((x + 8, y + 8), "Aa", fill=fg["hex"], font=_font(30, True))
            g = grade(r)
            badge = {"AA": "#0b6b2e", "large only": "#8a5a00", "fail": "#b00020"}[g]
            d.rectangle([x, y + cell - 40, x + cell - 4, y + cell - 4], fill=badge)
            d.text((x + 6, y + cell - 37), f"{r:.2f}:1\n{g}", fill="white", font=f)
    d.text((10, head + n * cell + 10), "AA = 4.5:1 normal text. large only = 3:1 to 4.49:1 (large text, icons, borders). fail = under 3:1.", fill="black", font=f)
    img.save(path)

def draw_cvd(name, colors, path):
    kinds = ["original", "protanopia", "deuteranopia"]
    sw, lab = 110, 130
    img = Image.new("RGB", (lab + len(colors) * sw, 60 + len(kinds) * (sw + 10)), "white")
    d = ImageDraw.Draw(img)
    f = _font(13)
    d.text((10, 10), f"{name}: color-blind simulation (Machado 2009, full severity)", fill="black", font=_font(15, True))
    for k, kind in enumerate(kinds):
        y = 40 + k * (sw + 10)
        d.text((6, y + sw // 2 - 8), kind, fill="black", font=f)
        for j, c in enumerate(colors):
            rgb = c["rgb"] if kind == "original" else simulate(c["rgb"], kind)
            x = lab + j * sw
            d.rectangle([x, y, x + sw - 6, y + sw - 6], fill=to_hex(rgb), outline="#999999")
            d.text((x + 4, y + 4), f"{c['name'][:12]}\n{to_hex(rgb)}", fill="black", font=f, stroke_width=2, stroke_fill="white")
    img.save(path)

def cvd_clashes(colors, min_de=12.0):
    """Pairs that look distinct normally but close under simulation.
    The 12 Delta E cutoff is a working heuristic, unverified."""
    out = []
    for i in range(len(colors)):
        for j in range(i + 1, len(colors)):
            a, b = colors[i]["rgb"], colors[j]["rgb"]
            if delta_e(a, b) < min_de:
                continue
            for kind in MACHADO:
                de = delta_e(simulate(a, kind), simulate(b, kind))
                if de < min_de:
                    out.append((colors[i]["name"], colors[j]["name"], kind, de))
    return out

def markdown(name, colors, mx, pairs):
    idx = {c["name"]: i for i, c in enumerate(colors)}
    L = [f"# Contrast matrix: {name}", "",
         "Thresholds from [WCAG 2.2 1.4.3](https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html) "
         "and [1.4.11](https://www.w3.org/WAI/WCAG22/Understanding/non-text-contrast.html): "
         "4.5:1 normal text, 3:1 large text and UI parts.", ""]
    if pairs:
        L += ["## Pairings in use", "", "Text on background, use, ratio, result", ""]
        for p in pairs:
            r = mx[idx[p["fg"]]][idx[p["bg"]]]
            need = LARGE_AA if p.get("large") or p.get("ui") else TEXT_AA
            ok = "pass" if r >= need else "FAIL"
            L.append(f"- {p['fg']} on {p['bg']} ({p.get('use', '')}): {r:.2f}:1, needs {need}:1, {ok}")
        L.append("")
    L += ["## Full grid (each text color on each background)", ""]
    for i, fg in enumerate(colors):
        cells = [f"on {colors[j]['name']} {mx[i][j]:.2f} {grade(mx[i][j])}" for j in range(len(colors)) if j != i]
        L.append(f"- {fg['name']} ({fg['hex']}): " + ", ".join(cells))
    L += ["", "## Color-blind check", ""]
    cl = cvd_clashes(colors)
    if cl:
        L += [f"- {a} and {b} look alike under {k} (Delta E {de:.1f}). Do not rely on color alone to tell them apart." for a, b, k, de in cl]
    else:
        L.append("- No pair collapses under protanopia or deuteranopia at the Delta E 12 cutoff (heuristic, unverified).")
    return "\n".join(L) + "\n"

def run(path, out):
    name, colors, pairs = load_palette(path)
    os.makedirs(out, exist_ok=True)
    mx = matrix(colors)
    slug = name.lower().replace(" ", "-")
    files = {k: os.path.join(out, f"{slug}-{k}") for k in ("contrast.png", "contrast.md", "cvd.png")}
    draw_grid(name, colors, mx, files["contrast.png"])
    draw_cvd(name, colors, files["cvd.png"])
    with open(files["contrast.md"], "w") as fh:
        fh.write(markdown(name, colors, mx, pairs))
    return files

if __name__ == "__main__":
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("palette")
    ap.add_argument("--out", default=".")
    a = ap.parse_args()
    for v in run(a.palette, a.out).values():
        print(v)
