"""Reconstructs a numeric table from a PDF page's word coordinates.

Used once to transcribe literature tables; results are checked by eye against
the rendered page before being committed under tool/sources/.
"""
import re

import pymupdf


def words(pdf, page_index):
    return pymupdf.open(pdf)[page_index].get_text("words")


def rows_by_y(ws, y_min, y_max, tol=2.0):
    """Groups words into lines by their baseline (y1), top to bottom.

    Superscripts sit slightly higher but share y1 within tol with their line.
    """
    ws = sorted((w for w in ws if y_min <= w[1] < y_max), key=lambda w: (w[3], w[0]))
    lines = []
    for w in ws:
        if lines and abs(lines[-1][0] - w[3]) <= tol:
            lines[-1][1].append(w)
        else:
            lines.append([w[3], [w]])
    return [sorted(l[1], key=lambda w: w[0]) for l in lines]


NUM = re.compile(r"^(−|-)?\d+\.\d+")


def parse_table(ws, y_min, y_max, name_x_max, label_cols, value_cols):
    """label_cols: list of (key, x_lo, x_hi) for text columns (proton, mult).

    value_cols: list of (key, x_center); numeric words go to the nearest center.
    Returns a list of dict rows: name (carried over from the row above when
    blank), labels, values {key: raw token}.
    """
    out = []
    name = None
    for line in rows_by_y(ws, y_min, y_max):
        name_words = [w[4] for w in line if w[0] < name_x_max]
        labels = {k: " ".join(w[4] for w in line if lo <= w[0] < hi)
                  for k, lo, hi in label_cols}
        first_val_x = min(c for _, c in value_cols) - 20
        vals = {}
        for w in line:
            if w[0] < first_val_x:
                continue
            cx = (w[0] + w[2]) / 2
            key = min(value_cols, key=lambda kc: abs(kc[1] - cx))[0]
            vals[key] = (vals[key] + " " + w[4]) if key in vals else w[4]
        if name_words:
            new = " ".join(name_words)
            # A line with a name but no values continues the previous name
            # (e.g. "solvent residual" / "signals").
            if not vals and not any(labels.values()):
                name = (name + " " + new) if name else new
                continue
            name = new
        out.append(dict(name=name, labels=labels, values=vals, y=line[0][3]))
    return out
