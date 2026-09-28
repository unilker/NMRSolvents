"""Build store/web/privacy.html from PRIVACY.md.

The page is published with GitHub Pages (.github/workflows/pages.yml) and its
address is given to Google Play and the App Store as the privacy policy. PRIVACY.md stays the single
source; CI checks that the page is up to date.

Handles only the Markdown PRIVACY.md uses: #/## headings, "- " bullets
(with indented continuation lines), paragraphs, **bold**, *italic* and bare
URLs.
"""

import html
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


def inline(text: str) -> str:
    text = html.escape(text, quote=False)
    text = re.sub(r"\*\*(.+?)\*\*", r"<strong>\1</strong>", text)
    text = re.sub(r"\*(.+?)\*", r"<em>\1</em>", text)
    return re.sub(r"(https?://[^\s<]+)", r'<a href="\1">\1</a>', text)


def blocks(md: str):
    """Yield (kind, text) with kind in h1, h2, li, p."""
    kind, lines = None, []
    for raw in md.splitlines() + [""]:
        line = raw.rstrip()
        starts = (
            line.startswith("# ")
            or line.startswith("## ")
            or line.startswith("- ")
            or not line
        )
        if starts and kind:
            yield kind, " ".join(lines)
            kind, lines = None, []
        if not line:
            continue
        if line.startswith("## "):
            yield "h2", line[3:]
        elif line.startswith("# "):
            yield "h1", line[2:]
        elif line.startswith("- "):
            kind, lines = "li", [line[2:]]
        elif kind:
            lines.append(line.strip())
        else:
            kind, lines = "p", [line.strip()]


def render(md: str) -> str:
    body, in_list = [], False
    for kind, text in blocks(md):
        if kind == "li" and not in_list:
            body.append("<ul>")
            in_list = True
        elif kind != "li" and in_list:
            body.append("</ul>")
            in_list = False
        body.append(f"<{kind}>{inline(text)}</{kind}>")
    if in_list:
        body.append("</ul>")
    content = "\n".join(body)
    return f"""<!DOCTYPE html>
<html lang="tr">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Gizlilik Politikası / Privacy Policy – NMR Çözücü Safsızlıkları</title>
<!-- Generated from PRIVACY.md by tool/store/make_privacy_html.py -->
<style>
  :root {{ --fg: #1a1a1a; --muted: #555; --accent: #1565c0; --bg: #fff; }}
  @media (prefers-color-scheme: dark) {{
    :root {{ --fg: #e8e8e8; --muted: #aaa; --accent: #90caf9; --bg: #121212; }}
  }}
  body {{ margin: 0 auto; max-width: 720px; padding: 24px 16px 48px;
         font: 16px/1.6 system-ui, -apple-system, "Segoe UI", Roboto, sans-serif;
         color: var(--fg); background: var(--bg); }}
  h1 {{ font-size: 1.6rem; line-height: 1.3; }}
  h2 {{ margin-top: 2rem; color: var(--accent); }}
  a {{ color: var(--accent); overflow-wrap: anywhere; }}
  li {{ margin: .4rem 0; }}
</style>
</head>
<body>
{content}
</body>
</html>
"""


def main() -> None:
    md = (ROOT / "PRIVACY.md").read_text(encoding="utf-8")
    out = ROOT / "store" / "web" / "privacy.html"
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(render(md), encoding="utf-8")
    print(f"wrote {out.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
