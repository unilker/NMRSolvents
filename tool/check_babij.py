"""Cross-checks the hand transcription in sources/babij2016.py against an
independent Tesseract OCR of the table images.

Usage: python check_babij.py <table> <ocr.txt> [<ocr.txt> ...]
  table: H1 or C13
Aligns the stream of decimal numbers from both readings and prints every
place where they disagree, so each one can be re-read on the image.
"""
import difflib
import re
import sys

sys.path.insert(0, "sources")
import babij2016  # noqa: E402

NUM = re.compile(r"\d+\.\d+")


def transcription_numbers(table):
    out = []
    for c in getattr(babij2016, table):
        for row in c["rows"]:
            label = f"{c['name']} {row[0]}"
            text = " ".join([row[2] or ""] + row[3]) if table == "H1" else " ".join(row[1])
            out += [(n, label) for n in NUM.findall(text)]
    return out


def ocr_numbers(paths):
    out = []
    for p in paths:
        for line in open(p, encoding="utf-8"):
            out += [(n, line.strip()[:90]) for n in NUM.findall(line)]
    return out


def main(table, paths):
    mine = transcription_numbers(table)
    ocr = ocr_numbers(paths)
    sm = difflib.SequenceMatcher(a=[n for n, _ in mine], b=[n for n, _ in ocr], autojunk=False)
    same = 0
    for op, i1, i2, j1, j2 in sm.get_opcodes():
        if op == "equal":
            same += i2 - i1
            continue
        a = [f"{n}" for n, _ in mine[i1:i2]]
        b = [f"{n}" for n, _ in ocr[j1:j2]]
        where = mine[i1][1] if i1 < len(mine) else "(end)"
        ctx = ocr[j1][1] if j1 < len(ocr) else ""
        print(f"{op:8s} {where:40s} mine={a} ocr={b}\n         ocr line: {ctx}")
    print(f"\n{same} of {len(mine)} transcribed numbers match OCR exactly")


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2:])
