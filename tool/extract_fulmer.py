"""Extracts Tables 1 (1H) and 2 (13C) of Fulmer et al., Organometallics 2010.

Usage: python extract_fulmer.py <pdf> <page_1H> <page_13C>   (1-based pages)
Writes sources/fulmer2010.json. Output was checked against the printed page.
"""
import json
import re
import sys

from pdf_table import NUM, parse_table, rows_by_y, words

SOLVENTS = ["thf_d8", "cd2cl2", "cdcl3", "toluene_d8", "c6d6", "c6d5cl",
            "acetone_d6", "dmso_d6", "cd3cn", "tfe_d3", "cd3od", "d2o"]


def clean_name(name):
    name = name.replace("tert -", "tert-")
    # Trailing footnote marker glued to the name: "H greasef", "HMPAc".
    for word, fixed in [("H greasef", "H grease"), ("H greaseb", "H grease"),
                        ("pyrrolidineh", "pyrrolidine"),
                        ("pyrrolidinee", "pyrrolidine"), ("HMPAc", "HMPA")]:
        if name == word:
            return fixed
    return name


def parse_value(raw):
    """'2.84b' -> (2.84, None, 'b'); '0.85−0.91' -> (0.85, 0.91, None)."""
    raw = raw.replace("−", "-").strip()
    m = re.fullmatch(r"(-?\d+\.\d+)(?:-(\d+\.\d+))?([a-z]*)", raw)
    if not m:
        raise ValueError(f"unparsed value {raw!r}")
    lo = float(m[1])
    hi = float(m[2]) if m[2] else None
    return lo, hi, (m[3] or None)


def parse_mult(text):
    """'q, 7d' -> ('q', '7'); 'sc,d' -> ('s', None); 'dt, 6.4, 1.5'."""
    text = text.strip()
    mult, _, rest = text.partition(",")
    mult = mult.strip()
    # Footnote letters glued to "s": 'sc', 'sg', 'se' (+ ',d' in rest).
    if re.fullmatch(r"s[a-i]", mult):
        mult, rest = "s", ""
    j = re.sub(r"[a-z]+$", "", rest.strip().rstrip(",")).strip() or None
    if j and not re.fullmatch(r"[\d.]+(, [\d.]+)?", j):
        j = None
    return mult, j


def extract(pdf, page, label_cols, name_x_max, y_max, cols_from_header):
    ws = words(pdf, page - 1)
    if cols_from_header:
        hdr = [w for w in ws if 66 < w[1] < 68 and w[4] not in ("proton", "mult")]
        centers = [(w[0] + w[2]) / 2 for w in hdr]
    else:
        ref = [l for l in rows_by_y(ws, 120, 600) if l[0][4] == "acetic"][0]
        centers = [(w[0] + w[2]) / 2 for w in ref if NUM.match(w[4])]
    assert len(centers) == 12, centers
    cols = list(zip(SOLVENTS, centers))
    return parse_table(ws, 80, y_max, name_x_max, label_cols, cols)


def build_1h(rows):
    residual, out = {}, []
    for r in rows:
        if not (r["labels"]["proton"] + r["labels"]["mult"]).strip():
            for s, raw in r["values"].items():
                residual.setdefault(s, []).append(parse_value(raw)[0])
            continue
        label = (r["labels"]["proton"] + " " + r["labels"]["mult"]).strip()
        label = re.sub(r"\s*\d+\.\d+[−-]\d+\.\d+$", "", label)
        group, mult_text = label.split(None, 1)
        mult, j = parse_mult(mult_text)
        values = {}
        for s, raw in r["values"].items():
            lo, hi, _ = parse_value(raw)
            values[s] = {"shift": lo, **({"shiftMax": hi} if hi else {})}
        out.append(dict(compound=clean_name(r["name"]), group=group,
                        mult=mult, J=j, values=values))
    return residual, out


def build_13c(rows):
    residual, out = {}, []
    for r in rows:
        if not r["labels"]["carbon"].strip():
            for s, raw in r["values"].items():
                residual.setdefault(s, []).append(parse_value(raw)[0])
            continue
        values = {s: {"shift": parse_value(raw)[0]} for s, raw in r["values"].items()}
        out.append(dict(compound=clean_name(r["name"]),
                        group=r["labels"]["carbon"], values=values))
    return residual, out


def main(pdf, p1, p2):
    h_rows = extract(pdf, p1, [("proton", 110, 150), ("mult", 150, 182)], 110, 671, True)
    c_rows = extract(pdf, p2, [("carbon", 105, 150)], 105, 712, False)
    h_res, h1 = build_1h(h_rows)
    c_res, c13 = build_13c(c_rows)

    # Footnote b of Table 1: an HDO signal (1:1:1 t, 2J(H,D) = 1 Hz) is also
    # seen in (CD3)2SO at 3.30 and (CD3)2CO at 2.81 ppm.
    h1.append(dict(compound="water", group="HDO", mult="t", J="1",
                   values={"dmso_d6": {"shift": 3.30}, "acetone_d6": {"shift": 2.81}}))
    # Table 2 prints acetone in TFE-d3 as CO 32.35 / CH3 214.98, an evident
    # transposition; store it with the assignments swapped.
    co = next(r for r in c13 if r["compound"] == "acetone" and r["group"] == "CO")
    me = next(r for r in c13 if r["compound"] == "acetone" and r["group"] == "CH3")
    assert co["values"]["tfe_d3"]["shift"] == 32.35
    co["values"]["tfe_d3"], me["values"]["tfe_d3"] = me["values"]["tfe_d3"], co["values"]["tfe_d3"]
    co["values"]["tfe_d3"]["note"] = me["values"]["tfe_d3"]["note"] = (
        "CO/CH3 transposed in the printed table")

    json.dump(dict(ref="fulmer2010", residual_1h=h_res, residual_13c=c_res,
                   h1=h1, c13=c13),
              open("sources/fulmer2010.json", "w"), indent=1, ensure_ascii=False)
    print(len(h1), "1H rows,", len(c13), "13C rows")


if __name__ == "__main__":
    main(sys.argv[1], int(sys.argv[2]), int(sys.argv[3]))
