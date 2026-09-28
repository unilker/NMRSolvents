"""Check the store texts in store/listing/*.md against their length limits.

Each field is a "## Name (limit)" heading followed by the text. Limits are
counted in characters, as Google Play and App Store Connect count them.
"""

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
HEADING = re.compile(r"^## (.+) \((\d+)\)$")


def fields(md: str):
    name, limit, lines = None, 0, []
    for line in md.splitlines() + ["## end (0)"]:
        m = HEADING.match(line)
        if m:
            if name:
                yield name, limit, "\n".join(lines).strip()
            name, limit, lines = m[1], int(m[2]), []
        elif name:
            lines.append(line)


def main() -> int:
    errors = 0
    for path in sorted((ROOT / "store" / "listing").glob("*.md")):
        for name, limit, text in fields(path.read_text(encoding="utf-8")):
            n = len(text)
            ok = 0 < n <= limit
            if "keyword" in name.lower() or "kelime" in name.lower():
                ok = ok and ", " not in text
            print(f"{'ok ' if ok else 'BAD'} {path.name}: {name}: {n}/{limit}")
            errors += not ok
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
