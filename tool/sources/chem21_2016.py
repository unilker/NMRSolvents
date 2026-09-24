"""Prat et al., "CHEM21 selection guide of classical- and less
classical-solvents", Green Chem. 2016, 18, 288-296. DOI 10.1039/c5gc01008j.

Table 7 (53 classical solvents) and Table 8 (less classical solvents) are
images in the PDF; transcribed by hand and checked with tool/check_chem21.py
against the paper's own scoring rules (Tables 4-6) and an OCR pass.

Row: (name, family, bp, fp, worst H3xx, H4xx, safety, health, env,
      ranking by default, ranking after discussion)
bp/fp are strings as printed ("na", ">200", ">100"); H columns are "None"
(no statement after full REACh registration) or "n.a." (not registered).
Rankings: rec, prob, haz, hh (highly hazardous).
For Table 8 the default ranking was confirmed as final ("The solvent sub-team
decided to confirm the ranking by default as final ranking ... for all these
less common solvents"), and a CAS number is given.
"""

TABLE7 = [
    ("Water", "Water", "100", "na", "None", "None", 1, 1, 1, "rec", "rec"),
    ("MeOH", "Alcohols", "65", "11", "H301", "None", 4, 7, 5, "prob", "rec"),
    ("EtOH", "Alcohols", "78", "13", "H319", "None", 4, 3, 3, "rec", "rec"),
    ("i-PrOH", "Alcohols", "82", "12", "H319", "None", 4, 3, 3, "rec", "rec"),
    ("n-BuOH", "Alcohols", "118", "29", "H318", "None", 3, 4, 3, "rec", "rec"),
    ("t-BuOH", "Alcohols", "82", "11", "H319", "None", 4, 3, 3, "rec", "rec"),
    ("Benzyl alcohol", "Alcohols", "206", "101", "H302", "None", 1, 2, 7, "prob", "prob"),
    ("Ethylene glycol", "Alcohols", "198", "116", "H302", "None", 1, 2, 5, "rec", "rec"),
    ("Acetone", "Ketones", "56", "-18", "H319", "None", 5, 3, 5, "prob", "rec"),
    ("MEK", "Ketones", "80", "-6", "H319", "None", 5, 3, 3, "rec", "rec"),
    ("MIBK", "Ketones", "117", "13", "H319", "None", 4, 2, 3, "rec", "rec"),
    ("Cyclohexanone", "Ketones", "156", "43", "H332", "None", 3, 2, 5, "rec", "prob"),
    ("Methyl acetate", "Esters", "57", "-10", "H302", "None", 5, 3, 5, "prob", "prob"),
    ("Ethyl acetate", "Esters", "77", "-4", "H319", "None", 5, 3, 3, "rec", "rec"),
    ("i-PrOAc", "Esters", "89", "2", "H319", "None", 4, 2, 3, "rec", "rec"),
    ("n-BuOAc", "Esters", "126", "22", "H336", "None", 4, 2, 3, "rec", "rec"),
    ("Diethyl ether", "Ethers", "34", "-45", "H302", "None", 10, 3, 7, "haz", "hh"),
    ("Diisopropyl ether", "Ethers", "69", "-28", "H336", "None", 9, 3, 5, "haz", "haz"),
    ("MTBE", "Ethers", "55", "-28", "H315", "None", 8, 3, 5, "haz", "haz"),
    ("THF", "Ethers", "66", "-14", "H351", "None", 6, 7, 5, "prob", "prob"),
    ("Me-THF", "Ethers", "80", "-11", "H318", "None", 6, 5, 3, "prob", "prob"),
    ("1,4-Dioxane", "Ethers", "101", "12", "H351", "None", 7, 6, 3, "prob", "haz"),
    ("Anisole", "Ethers", "154", "52", "None", "None", 4, 1, 5, "prob", "rec"),
    ("DME", "Ethers", "85", "-6", "H360", "None", 7, 10, 3, "haz", "haz"),
    ("Pentane", "Hydrocarbons", "36", "-40", "H304", "H411", 8, 3, 7, "haz", "haz"),
    ("Hexane", "Hydrocarbons", "69", "-22", "H361", "H411", 8, 7, 7, "haz", "haz"),
    ("Heptane", "Hydrocarbons", "98", "-4", "H304", "H410", 6, 2, 7, "prob", "prob"),
    ("Cyclohexane", "Hydrocarbons", "81", "-17", "H304", "H410", 6, 3, 7, "prob", "prob"),
    ("Me-cyclohexane", "Hydrocarbons", "101", "-4", "H304", "H411", 6, 2, 7, "prob", "prob"),
    ("Benzene", "Hydrocarbons", "80", "-11", "H350", "None", 6, 10, 3, "haz", "hh"),
    ("Toluene", "Hydrocarbons", "111", "4", "H351", "None", 5, 6, 3, "prob", "prob"),
    ("Xylenes", "Hydrocarbons", "140", "27", "H312", "None", 4, 2, 5, "prob", "prob"),
    ("DCM", "Halogenated", "40", "na", "H351", "None", 1, 7, 7, "haz", "haz"),
    ("Chloroform", "Halogenated", "61", "na", "H351", "None", 2, 7, 5, "prob", "hh"),
    ("CCl4", "Halogenated", "77", "na", "H351", "H420", 2, 7, 10, "haz", "hh"),
    ("DCE", "Halogenated", "84", "13", "H350", "None", 4, 10, 3, "haz", "hh"),
    ("Chlorobenzene", "Halogenated", "132", "29", "H332", "H411", 3, 2, 7, "prob", "prob"),
    ("Acetonitrile", "Aprotic polar", "82", "2", "H319", "None", 4, 3, 3, "rec", "prob"),
    ("DMF", "Aprotic polar", "153", "58", "H360", "None", 3, 9, 5, "haz", "haz"),
    ("DMAc", "Aprotic polar", "166", "70", "H360", "None", 1, 9, 5, "haz", "haz"),
    ("NMP", "Aprotic polar", "202", "96", "H360", "None", 1, 9, 7, "haz", "haz"),
    ("DMPU", "Aprotic polar", "246", "121", "H361", "None", 1, 6, 7, "prob", "prob"),
    ("DMSO", "Aprotic polar", "189", "95", "None", "None", 1, 1, 5, "rec", "prob"),
    ("Sulfolane", "Aprotic polar", "287", "177", "H360", "None", 1, 9, 7, "haz", "haz"),
    ("HMPA", "Aprotic polar", ">200", "144", "H350", "None", 1, 9, 7, "haz", "hh"),
    ("Nitromethane", "Aprotic polar", "101", "35", "H302", "None", 10, 2, 3, "haz", "hh"),
    ("Methoxy-ethanol", "Miscellaneous", "125", "42", "H360", "None", 3, 9, 3, "haz", "haz"),
    ("Carbon disulfide", "Miscellaneous", "46", "-30", "H361", "H412", 9, 7, 7, "haz", "hh"),
    ("Formic acid", "Acids", "101", "49", "H314", "None", 3, 7, 3, "prob", "prob"),
    ("Acetic acid", "Acids", "118", "39", "H314", "None", 3, 7, 3, "prob", "prob"),
    ("Ac2O", "Acids", "139", "49", "H314", "None", 3, 7, 3, "prob", "prob"),
    ("Pyridine", "Amines", "115", "23", "H302", "None", 4, 2, 3, "rec", "haz"),
    ("TEA", "Amines", "89", "-6", "H314", "None", 6, 7, 3, "prob", "haz"),
]

# Table 7 footnote c: solid at 20 °C.
TABLE7_SOLID = {"t-BuOH", "DMSO", "Sulfolane"}

# (name, family, CAS, bp, fp, worst H3xx, H4xx, safety, health, env, ranking)
TABLE8 = [
    ("i-Butanol", "Alcohols", "78-83-1", "107", "28", "H318", "None", 3, 4, 3, "rec"),
    ("i-Amyl alcohol", "Alcohols", "123-51-3", "131", "43", "H315", "None", 3, 2, 3, "rec"),
    ("1,3-Propane diol", "Alcohols", "504-63-2", "214", ">100", "None", "None", 1, 1, 7, "prob"),
    ("Glycerol", "Alcohols", "56-81-5", "290", "177", "None", "None", 1, 1, 7, "prob"),
    ("i-Butyl acetate", "Esters", "110-19-0", "115", "22", "H336", "None", 4, 2, 3, "rec"),
    ("i-Amyl acetate", "Esters", "123-92-2", "142", "25", "None", "None", 3, 1, 5, "rec"),
    ("Glycol diacetate", "Esters", "111-55-7", "186", "82", "None", "None", 1, 1, 5, "rec"),
    ("γ-Valerolactone", "Esters", "108-29-2", "207", "100", "n.a.", "n.a.", 1, 5, 7, "prob"),
    ("Diethyl succinate", "Esters", "123-25-1", "218", "91", "n.a.", "n.a.", 1, 5, 7, "prob"),
    ("TAME", "Ethers", "994-05-8", "86", "-7", "H302", "None", 6, 2, 3, "rec"),
    ("CPME", "Ethers", "5614-37-9", "106", "-1", "H302", "H412", 7, 2, 5, "prob"),
    ("ETBE", "Ethers", "637-92-3", "72", "-19", "H336", "None", 7, 3, 3, "prob"),
    ("D-Limonene", "Hydrocarbons", "5989-27-5", "175", "49", "H304", "H400", 4, 2, 7, "prob"),
    ("Turpentine", "Hydrocarbons", "8006-64-2", "166", "38", "H302", "H411", 4, 2, 7, "prob"),
    ("p-Cymene", "Hydrocarbons", "99-87-6", "177", "27", "n.a.", "n.a.", 4, 5, 5, "prob"),
    ("Dimethyl carbonate", "Aprotic polar", "616-38-6", "90", "16", "None", "None", 4, 1, 3, "rec"),
    ("Ethylene carbonate", "Aprotic polar", "96-49-1", "248", "143", "H302", "None", 1, 2, 7, "prob"),
    ("Propylene carbonate", "Aprotic polar", "108-32-7", "242", "132", "H319", "None", 1, 2, 7, "prob"),
    ("Cyrene", "Aprotic polar", "53716-82-8", "203", "61", "H319", "None", 1, 2, 7, "prob"),
    ("Ethyl lactate", "Miscellaneous", "687-47-8", "155", "47", "H318", "None", 3, 4, 5, "prob"),
    ("Lactic acid", "Miscellaneous", "50-21-5", "230", "113", "H318", "None", 1, 4, 7, "prob"),
    ("TH-furfuryl alcohol", "Miscellaneous", "97-99-4", "178", "75", "H360", "None", 1, 9, 5, "haz"),
]

# Table 8 footnotes: c water sensitive, d solid at 20 °C.
TABLE8_NOTES = {"Dimethyl carbonate": "water_sensitive", "Ethylene carbonate": "solid"}
