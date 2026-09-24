"""Generates the app icon as SVG: a magnifier over the red "impurity" peak
of a white NMR spectrum on a blue background.

    python3 tool/icon/make_icon.py

Writes assets/icon/icon.svg (full icon), icon_foreground.svg (motif on a
transparent background, sized for the Android adaptive-icon safe zone) and
icon_background.svg. tool/icon/render.js turns them into the PNGs used by
flutter_launcher_icons (see pubspec.yaml).
"""
import math
import os

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "assets", "icon")

BASE = 700            # spectrum baseline
CX, CY, R = 512, 420, 140   # magnifier lens
LENS_BASE = CY + 78   # baseline of the magnified peak inside the lens
MOTIF_CENTER = (512, 480)


def spectrum(peaks, x0, x1, base, step=1.0):
    """Sum of Lorentzians (center, height, half-width) as an SVG path."""
    pts = []
    x = x0
    while x <= x1:
        y = sum(h * w * w / ((x - c) ** 2 + w * w) for c, h, w in peaks)
        pts.append(f"{x:.1f},{base - y:.1f}")
        x += step
    return "M" + " L".join(pts)


def multiplet(center, n, spacing, height, width):
    coeff = [math.comb(n - 1, k) for k in range(n)]
    start = center - spacing * (n - 1) / 2
    return [(start + i * spacing, height * c / max(coeff), width) for i, c in enumerate(coeff)]


# A quartet and a triplet (white) around one singlet (the impurity).
SPEC = spectrum(multiplet(300, 4, 24, 230, 5) + multiplet(728, 3, 26, 270, 5), 170, 854, BASE, 1.5)
PEAK = spectrum([(512, 420, 7)], 450, 574, BASE, 0.5)
ZOOM = spectrum([(CX, 190, 30)], CX - R, CX + R, LENS_BASE)

DEFS = f"""<defs>
  <linearGradient id="bg" x1="0" y1="0" x2="1" y2="1">
    <stop offset="0" stop-color="#1E88E5"/><stop offset="1" stop-color="#0D3C8C"/>
  </linearGradient>
  <radialGradient id="shine" cx="0.3" cy="0.2" r="0.9">
    <stop offset="0" stop-color="#ffffff" stop-opacity="0.18"/>
    <stop offset="1" stop-color="#ffffff" stop-opacity="0"/>
  </radialGradient>
  <clipPath id="lens"><circle cx="{CX}" cy="{CY}" r="{R}"/></clipPath>
  <filter id="shadow" x="-20%" y="-20%" width="140%" height="140%">
    <feDropShadow dx="0" dy="10" stdDeviation="14" flood-color="#000" flood-opacity="0.35"/>
  </filter>
</defs>"""

BACKGROUND = """<rect width="1024" height="1024" fill="url(#bg)"/>
<rect width="1024" height="1024" fill="url(#shine)"/>"""

MOTIF = f"""<line x1="170" y1="{BASE}" x2="854" y2="{BASE}" stroke="#fff" stroke-opacity="0.45" stroke-width="8" stroke-linecap="round"/>
<path d="{SPEC}" fill="none" stroke="#fff" stroke-width="16" stroke-linejoin="round" stroke-linecap="round"/>
<path d="{PEAK}" fill="none" stroke="#fff" stroke-width="18" stroke-linejoin="round" stroke-linecap="round"/>
<g filter="url(#shadow)">
  <circle cx="{CX}" cy="{CY}" r="{R}" fill="#fff"/>
  <g clip-path="url(#lens)">
    <line x1="{CX - R}" y1="{LENS_BASE}" x2="{CX + R}" y2="{LENS_BASE}" stroke="#E53935" stroke-opacity="0.35" stroke-width="6"/>
    <path d="{ZOOM}" fill="none" stroke="#E53935" stroke-width="16" stroke-linejoin="round" stroke-linecap="round"/>
  </g>
  <circle cx="{CX}" cy="{CY}" r="{R}" fill="none" stroke="#fff" stroke-width="28"/>
  <line x1="613" y1="521" x2="712" y2="620" stroke="#fff" stroke-width="46" stroke-linecap="round"/>
</g>"""


def scaled(content, factor):
    cx, cy = MOTIF_CENTER
    return (f'<g transform="translate({cx} {cy}) scale({factor}) translate({-cx} {-cy})">'
            f"{content}</g>")


def svg(body):
    return f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1024 1024">{DEFS}{body}</svg>\n'


def main():
    os.makedirs(OUT, exist_ok=True)
    files = {
        # Full icon: the motif enlarged by 20 % (approved design).
        "icon.svg": svg(BACKGROUND + scaled(MOTIF, 1.2)),
        # Adaptive icon: flutter_launcher_icons insets the foreground by 16 %
        # (roughly the 72/108 part a launcher shows), and launchers may crop
        # to the 66/108 safe circle; at 1.1 the motif stays inside it.
        "icon_foreground.svg": svg(scaled(MOTIF, 1.1)),
        "icon_background.svg": svg(BACKGROUND),
    }
    for name, content in files.items():
        with open(os.path.join(OUT, name), "w") as f:
            f.write(content)
    print("wrote", ", ".join(files))


if __name__ == "__main__":
    main()
