"""Extracts Tables 1 (1H) and 2 (13C) of Gottlieb, Kotlyar, Nudelman,
J. Org. Chem. 1997.

Usage: python extract_gottlieb.py <pdf> <page_1H> <page_13C>   (1-based pages)
Writes sources/gottlieb1997.json. Output was checked against the printed page.
"""
import json
import re
import sys

from extract_fulmer import parse_mult, parse_value
from pdf_table import NUM, parse_table, rows_by_y, words

SOLVENTS = ["cdcl3", "acetone_d6", "dmso_d6", "c6d6", "cd3cn", "cd3od", "d2o"]


def columns(ws):
    ref = [l for l in rows_by_y(ws, 70, 120) if l[0][4] == "acetic"][0]
    centers = [(w[0] + w[2]) / 2 for w in ref if NUM.match(w[4])]
    assert len(centers) == 7, centers
    return list(zip(SOLVENTS, centers))


def clean_name(name):
    name = re.sub(r"(BHT|HMPA|grease”|grease)[a-z]$", r"\1", name)
    return name.replace("H 2O", "water").replace("“grease”", "grease")


def main(pdf, p1, p2):
    ws = words(pdf, p1 - 1)
    rows = parse_table(ws, 60, 650, 150, [("proton", 150, 212), ("mult", 212, 250)],
                       columns(ws))
    h1 = []
    for r in rows:
        group = r["labels"]["proton"].replace(" ", "")
        group = re.sub(r"(OH)[a-z]$", r"\1", group)  # 'OHc' footnote
        if not r["values"] or (not group and not r["labels"]["mult"]):
            continue  # solvent residual row, or a footnote mark on its own line
        mult, j = parse_mult(r["labels"]["mult"].replace("sep,", "sept,"))
        values = {}
        for s, raw in r["values"].items():
            lo, hi, _ = parse_value(raw)
            values[s] = {"shift": lo, **({"shiftMax": hi} if hi else {})}
        h1.append(dict(compound=clean_name(r["name"]), group=group or "OH",
                       mult=mult, J=j, values=values))

    ws = words(pdf, p2 - 1)
    rows = parse_table(ws, 78, 750, 140, [("carbon", 140, 183)], columns(ws))
    c13 = []
    for r in rows:
        values = {s: {"shift": parse_value(raw)[0]} for s, raw in r["values"].items()}
        c13.append(dict(compound=clean_name(r["name"]),
                        group=r["labels"]["carbon"].replace(" ", ""), values=values))

    json.dump(dict(ref="gottlieb1997", h1=h1, c13=c13),
              open("sources/gottlieb1997.json", "w"), indent=1, ensure_ascii=False)
    print(len(h1), "1H rows,", len(c13), "13C rows")


if __name__ == "__main__":
    main(sys.argv[1], int(sys.argv[2]), int(sys.argv[3]))
