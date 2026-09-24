"""Checks the CHEM21 transcription (sources/chem21_2016.py) two ways:

1. Against the paper's own rules: health score from the worst H3xx statement
   (Table 4, +1 if bp < 85 °C), environment score from bp and H4xx (Table 5),
   and the ranking by default from the three scores (Table 6). A misread
   number almost always breaks one of these.
2. Against an OCR text of the table images (optional arguments): every
   transcribed bp, fp and H statement must appear on the OCR line of that
   solvent.

Usage: python3 tool/check_chem21.py [table7_ocr.txt table8_ocr.txt]
"""
import os
import re
import sys

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "sources"))
import chem21_2016 as c  # noqa: E402

HEALTH = {  # Table 4
    **dict.fromkeys(["H341", "H351", "H361"], 6),
    **dict.fromkeys(["H340", "H350", "H360"], 9),
    **dict.fromkeys(["H304", "H371", "H373"], 2),
    "H334": 4,
    **dict.fromkeys(["H370", "H372"], 6),
    **dict.fromkeys(["H302", "H312", "H332", "H336"], 2),
    **dict.fromkeys(["H301", "H311", "H331"], 6),
    **dict.fromkeys(["H300", "H310", "H330"], 9),
    **dict.fromkeys(["H315", "H317", "H319", "H335"], 2),
    "H318": 4,
    "H314": 7,
}


def num(s):
    return float(s.lstrip("<>")) if s not in ("na", "n.a.") else None


def health(name, bp, h3):
    if name == "Water":
        return 1
    base = {"None": 1, "n.a.": 5}.get(h3, HEALTH.get(h3))
    b = num(bp)
    return base + (1 if base > 1 and b is not None and b < 85 and not bp.startswith(">") else 0)


def env(name, bp, h4):
    if name == "Water":
        return 1
    if h4 == "H420":
        return 10
    b = num(bp)
    if bp.startswith(">"):
        bp_score = 7 if b >= 200 else 5
    elif 70 <= b <= 139:
        bp_score = 3
    elif 50 <= b <= 69 or 140 <= b <= 200:
        bp_score = 5
    else:
        bp_score = 7
    h4_score = {"None": 3, "n.a.": 5}.get(h4) or (5 if h4 in ("H412", "H413") else 7)
    return max(bp_score, h4_score)


def ranking(s, h, e):  # Table 6, most stringent first
    scores = [s, h, e]
    if any(x >= 8 for x in scores) or sum(x >= 7 for x in scores) >= 2:
        return "haz"
    if any(x == 7 for x in scores) or sum(4 <= x <= 6 for x in scores) >= 2:
        return "prob"
    return "rec"


# Printed values the rules do not reproduce, kept as printed:
# DME health 10 (H360 = 9, +1 for bp < 85 °C; bp is printed as 85, likely
# rounded from just below 85).
KNOWN = {("DME", "health")}


def rows():
    for r in c.TABLE7:
        name, _, bp, fp, h3, h4, s, h, e, default, _final = r
        yield 7, name, bp, fp, h3, h4, s, h, e, default
    for r in c.TABLE8:
        name, _, _cas, bp, fp, h3, h4, s, h, e, default = r
        yield 8, name, bp, fp, h3, h4, s, h, e, default


def main(ocr_paths):
    problems = 0
    for table, name, bp, fp, h3, h4, s, h, e, default in rows():
        exp_h, exp_e, exp_r = health(name, bp, h3), env(name, bp, h4), ranking(s, h, e)
        for label, got, want in (("health", h, exp_h), ("env", e, exp_e),
                                 ("ranking", default, exp_r)):
            if got != want and (name, label) not in KNOWN:
                problems += 1
                print(f"T{table} {name}: {label} transcribed {got}, rules give {want}")
    print(f"rule check: {problems} disagreement(s) in {len(c.TABLE7) + len(c.TABLE8)} rows")

    if ocr_paths:
        ocr = "\n".join(open(p, encoding="utf-8").read() for p in ocr_paths)
        ocr = ocr.replace("—", "-").replace("–", "-")
        misses = 0
        for table, name, bp, fp, h3, h4, *_ in rows():
            tokens = [t for t in (bp, fp, h3, h4) if t not in ("None", "na", "n.a.")]
            key = name.split()[0].split("-")[-1][:5]
            lines = [l for l in ocr.splitlines() if key.lower() in l.lower()]
            for t in tokens:
                if not any(t.lstrip("<>-") in l for l in lines):
                    misses += 1
                    print(f"T{table} {name}: '{t}' not found on OCR line(s) {lines[:1]}")
        print(f"OCR check: {misses} value(s) to re-read on the image")
    if problems:
        sys.exit(1)


if __name__ == "__main__":
    main(sys.argv[1:])
