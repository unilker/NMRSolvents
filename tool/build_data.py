"""Builds assets/data/*.json from the per-article sources in tool/sources/.

    python3 tool/build_data.py

Precedence when several articles report the same compound in the same
solvent and nucleus: Fulmer 2010 > Gottlieb 1997 > Babij 2016. Fulmer
re-measured and corrected the Gottlieb solvents, and Babij states its data
for previously reported solvents (footnote a) come from those two papers, so
the later sources only fill solvents/compounds the earlier ones lack.
Residual solvent peaks: Fulmer 2010 where available, the CIL chart for the
rest; the CIL values are kept as a second, labeled set.
"""
import json
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "sources"))
import babij2016  # noqa: E402
import chem21_2016  # noqa: E402
import cil_chart  # noqa: E402

OUT = os.path.join(HERE, "..", "assets", "data")
PRECEDENCE = ["fulmer2010", "gottlieb1997", "babij2016"]

REFERENCES = [
    dict(id="fulmer2010", short="Fulmer 2010",
         authors="G. R. Fulmer, A. J. M. Miller, N. H. Sherden, H. E. Gottlieb, A. Nudelman, "
                 "B. M. Stoltz, J. E. Bercaw, K. I. Goldberg",
         title="NMR Chemical Shifts of Trace Impurities: Common Laboratory Solvents, Organics, "
               "and Gases in Deuterated Solvents Relevant to the Organometallic Chemist",
         source="Organometallics 2010, 29, 2176-2179", doi="10.1021/om100106e"),
    dict(id="gottlieb1997", short="Gottlieb 1997", authors="H. E. Gottlieb, V. Kotlyar, A. Nudelman",
         title="NMR Chemical Shifts of Common Laboratory Solvents as Trace Impurities",
         source="J. Org. Chem. 1997, 62, 7512-7515", doi="10.1021/jo971176v"),
    dict(id="babij2016", short="Babij 2016",
         authors="N. R. Babij, E. O. McCusker, G. T. Whiteker, B. Canturk, N. Choy, L. C. Creemer, "
                 "C. V. De Amicis, N. M. Hewlett, P. L. Johnson, J. A. Knobelsdorf, F. Li, "
                 "B. A. Lorsbach, B. M. Nugent, S. J. Ryan, M. R. Smith, Q. Yang",
         title="NMR Chemical Shifts of Trace Impurities: Industrially Preferred Solvents Used in "
               "Process and Green Chemistry",
         source="Org. Process Res. Dev. 2016, 20, 661-667", doi="10.1021/acs.oprd.5b00417"),
    dict(id="prat2016", short="Prat 2016 (CHEM21)",
         authors="D. Prat, A. Wells, J. Hayler, H. Sneddon, C. R. McElroy, S. Abou-Shehada, "
                 "P. J. Dunn",
         title="CHEM21 selection guide of classical- and less classical-solvents",
         source="Green Chem. 2016, 18, 288-296", doi="10.1039/c5gc01008j"),
    dict(id="cil", short="CIL", authors="Cambridge Isotope Laboratories, Inc.",
         title="NMR Solvent Data Chart", source="isotope.com, NMR_SDC 5/15", doi=None),
]

# Solvent display names (CIL chart order) and Turkish translations.
SOLVENT_TR = {
    "acetic_acid_d4": "Asetik asit-d4", "acetone_d6": "Aseton-d6", "cd3cn": "Asetonitril-d3",
    "c6d6": "Benzen-d6", "cdcl3": "Kloroform-d", "cyclohexane_d12": "Siklohekzan-d12",
    "d2o": "Döteryum oksit", "dmf_d7": "N,N-Dimetilformamid-d7",
    "dmso_d6": "Dimetil sülfoksit-d6", "dioxane_d8": "1,4-Dioksan-d8", "ethanol_d6": "Etanol-d6",
    "cd3od": "Metanol-d4", "cd2cl2": "Diklorometan-d2", "pyridine_d5": "Piridin-d5",
    "tce_d2": "1,1,2,2-Tetrakloroetan-d2", "thf_d8": "Tetrahidrofuran-d8",
    "toluene_d8": "Toluen-d8", "tfa_d": "Trifloroasetik asit-d", "tfe_d3": "2,2,2-Trifloroetanol-d3",
    "c6d5cl": "Klorobenzen-d5",
}
# Display order: the most used NMR solvents first, then the rest of the chart.
SOLVENT_ORDER = [
    "cdcl3", "dmso_d6", "acetone_d6", "cd3od", "d2o", "c6d6", "cd3cn", "cd2cl2",
    "thf_d8", "toluene_d8", "c6d5cl", "tfe_d3", "acetic_acid_d4", "cyclohexane_d12",
    "dmf_d7", "dioxane_d8", "ethanol_d6", "pyridine_d5", "tce_d2", "tfa_d",
]
CIL_MULT = {"1": "s", "3": "t", "5": "quint", "7": "sept", "4": "q", "m": "m",
            "4x3": "qt", "4x5": "qquint", None: None}

# Canonical impurity list: id -> (English, Turkish, formula, aliases).
IMPURITIES = {
    "water": ("Water", "Su", "H2O", ["HDO", "HOD"]),
    "acetic_acid": ("Acetic acid", "Asetik asit", "CH3COOH", ["AcOH"]),
    "acetic_anhydride": ("Acetic anhydride", "Asetik anhidrit", "(CH3CO)2O", ["Ac2O"]),
    "acetone": ("Acetone", "Aseton", "(CH3)2CO", ["propanone"]),
    "acetonitrile": ("Acetonitrile", "Asetonitril", "CH3CN", ["MeCN", "ACN"]),
    "anisole": ("Anisole", "Anisol", "C6H5OCH3", ["methoxybenzene", "metoksibenzen"]),
    "benzene": ("Benzene", "Benzen", "C6H6", []),
    "benzyl_alcohol": ("Benzyl alcohol", "Benzil alkol", "C6H5CH2OH", ["BnOH"]),
    "bht": ("BHT (2,6-di-tert-butyl-4-methylphenol)", "BHT (2,6-di-tert-bütil-4-metilfenol)",
            "C15H24O", ["butylated hydroxytoluene"]),
    "n_butanol": ("n-Butanol", "n-Bütanol", "CH3(CH2)3OH", ["1-butanol", "n-BuOH"]),
    "isobutanol": ("Isobutanol", "İzobütanol", "(CH3)2CHCH2OH", ["iso-butanol", "2-methyl-1-propanol"]),
    "tert_butanol": ("tert-Butyl alcohol", "tert-Bütil alkol", "(CH3)3COH",
                     ["tert-butanol", "t-BuOH", "tBuOH"]),
    "n_butyl_acetate": ("n-Butyl acetate", "n-Bütil asetat", "CH3COO(CH2)3CH3", ["BuOAc"]),
    "isobutyl_acetate": ("Isobutyl acetate", "İzobütil asetat", "CH3COOCH2CH(CH3)2",
                         ["iso-butyl acetate"]),
    "mtbe": ("tert-Butyl methyl ether", "tert-Bütil metil eter", "(CH3)3COCH3",
             ["MTBE", "methyl tert-butyl ether"]),
    "carbon_dioxide": ("Carbon dioxide", "Karbon dioksit", "CO2", []),
    "carbon_disulfide": ("Carbon disulfide", "Karbon disülfür", "CS2", []),
    "carbon_tetrachloride": ("Carbon tetrachloride", "Karbon tetraklorür", "CCl4", []),
    "chlorobenzene": ("Chlorobenzene", "Klorobenzen", "C6H5Cl", ["PhCl"]),
    "chloroform": ("Chloroform", "Kloroform", "CHCl3", []),
    "crown_18_6": ("18-Crown-6", "18-Taç-6", "C12H24O6", ["18-crown-6"]),
    "cyclohexane": ("Cyclohexane", "Siklohekzan", "C6H12", []),
    "cyclohexanone": ("Cyclohexanone", "Siklohekzanon", "C6H10O", []),
    "cpme": ("Cyclopentyl methyl ether", "Siklopentil metil eter", "C5H9OCH3", ["CPME"]),
    "p_cymene": ("p-Cymene", "p-Simen", "CH3C6H4CH(CH3)2", ["4-isopropyltoluene"]),
    "dce": ("1,2-Dichloroethane", "1,2-Dikloroetan", "ClCH2CH2Cl", ["DCE"]),
    "dichloromethane": ("Dichloromethane", "Diklorometan", "CH2Cl2",
                        ["DCM", "methylene chloride", "metilen klorür"]),
    "diethyl_ether": ("Diethyl ether", "Dietil eter", "(CH3CH2)2O", ["Et2O", "ether"]),
    "diglyme": ("Diglyme", "Diglim", "(CH3OCH2CH2)2O", ["bis(2-methoxyethyl) ether"]),
    "dme": ("1,2-Dimethoxyethane", "1,2-Dimetoksietan", "CH3OCH2CH2OCH3", ["DME", "glyme"]),
    "dma": ("N,N-Dimethylacetamide", "N,N-Dimetilasetamid", "CH3CON(CH3)2", ["DMA", "DMAc"]),
    "dimethyl_carbonate": ("Dimethyl carbonate", "Dimetil karbonat", "(CH3O)2CO", ["DMC"]),
    "dmf": ("N,N-Dimethylformamide", "N,N-Dimetilformamid", "HCON(CH3)2", ["DMF"]),
    "dmso": ("Dimethyl sulfoxide", "Dimetil sülfoksit", "(CH3)2SO", ["DMSO"]),
    "dmpu": ("DMPU", "DMPU", "C6H12N2O", ["1,3-dimethyl-3,4,5,6-tetrahydro-2(1H)-pyrimidinone"]),
    "dioxane": ("1,4-Dioxane", "1,4-Dioksan", "C4H8O2", ["dioxane"]),
    "ethane": ("Ethane", "Etan", "C2H6", []),
    "ethanol": ("Ethanol", "Etanol", "CH3CH2OH", ["EtOH"]),
    "ethyl_acetate": ("Ethyl acetate", "Etil asetat", "CH3COOCH2CH3", ["EtOAc", "AcOEt"]),
    "ethyl_lactate": ("L-Ethyl lactate", "L-Etil laktat", "CH3CH(OH)COOCH2CH3", ["ethyl lactate"]),
    "etbe": ("Ethyl tert-butyl ether", "Etil tert-bütil eter", "(CH3)3COCH2CH3", ["ETBE"]),
    "mek": ("Ethyl methyl ketone", "Etil metil keton", "CH3COCH2CH3",
            ["MEK", "2-butanone", "methyl ethyl ketone"]),
    "ethylbenzene": ("Ethylbenzene", "Etilbenzen", "C6H5CH2CH3", ["xylenes"]),
    "ethylene": ("Ethylene", "Etilen", "C2H4", ["ethene"]),
    "ethylene_glycol": ("Ethylene glycol", "Etilen glikol", "HOCH2CH2OH", []),
    "formic_acid": ("Formic acid", "Formik asit", "HCOOH", []),
    "glycol_diacetate": ("Glycol diacetate", "Glikol diasetat", "(CH3COOCH2)2",
                         ["ethylene glycol diacetate"]),
    "grease": ("Grease (hydrocarbon)", "Gres (hidrokarbon)", "",
               ["H grease", "Apiezon", "vacuum grease", "vakum gresi"]),
    "n_heptane": ("n-Heptane", "n-Heptan", "CH3(CH2)5CH3", ["heptane"]),
    "hexamethylbenzene": ("Hexamethylbenzene", "Hekzametilbenzen", "C6(CH3)6", []),
    "n_hexane": ("n-Hexane", "n-Hekzan", "CH3(CH2)4CH3", ["hexane", "hexanes"]),
    "hmdso": ("Hexamethyldisiloxane", "Hekzametildisiloksan", "(CH3)3SiOSi(CH3)3", ["HMDSO"]),
    "hmpa": ("Hexamethylphosphoramide", "Hekzametilfosforamid", "[(CH3)2N]3PO", ["HMPA"]),
    "hydrogen": ("Hydrogen", "Hidrojen", "H2", []),
    "imidazole": ("Imidazole", "İmidazol", "C3H4N2", []),
    "isoamyl_acetate": ("Isoamyl acetate", "İzoamil asetat", "CH3COOCH2CH2CH(CH3)2",
                        ["iso-amyl acetate", "isopentyl acetate"]),
    "isoamyl_alcohol": ("Isoamyl alcohol", "İzoamil alkol", "(CH3)2CHCH2CH2OH",
                        ["iso-amyl alcohol", "3-methyl-1-butanol"]),
    "isopropanol": ("2-Propanol", "2-Propanol (izopropanol)", "(CH3)2CHOH",
                    ["IPA", "isopropanol", "iso-propanol", "isopropyl alcohol"]),
    "isopropyl_acetate": ("Isopropyl acetate", "İzopropil asetat", "CH3COOCH(CH3)2",
                          ["iso-propyl acetate", "iPrOAc"]),
    "methane": ("Methane", "Metan", "CH4", []),
    "methanol": ("Methanol", "Metanol", "CH3OH", ["MeOH"]),
    "methyl_acetate": ("Methyl acetate", "Metil asetat", "CH3COOCH3", ["MeOAc"]),
    "methylcyclohexane": ("Methylcyclohexane", "Metilsiklohekzan", "C6H11CH3", []),
    "mibk": ("Methyl isobutyl ketone", "Metil izobütil keton", "CH3COCH2CH(CH3)2",
             ["MIBK", "methyl iso-butyl ketone"]),
    "me_thf": ("2-Methyltetrahydrofuran", "2-Metiltetrahidrofuran", "C5H10O", ["2-MeTHF"]),
    "nitromethane": ("Nitromethane", "Nitrometan", "CH3NO2", []),
    "n_pentane": ("n-Pentane", "n-Pentan", "CH3(CH2)3CH3", ["pentane"]),
    "propane": ("Propane", "Propan", "C3H8", []),
    "propylene": ("Propylene", "Propilen", "CH3CH=CH2", ["propene"]),
    "pyridine": ("Pyridine", "Piridin", "C5H5N", []),
    "pyrrole": ("Pyrrole", "Pirol", "C4H5N", []),
    "pyrrolidine": ("Pyrrolidine", "Pirolidin", "C4H9N", []),
    "silicone_grease": ("Silicone grease", "Silikon gres", "",
                        ["poly(dimethylsiloxane)", "PDMS"]),
    "sulfolane": ("Sulfolane", "Sülfolan", "C4H8SO2", []),
    "tame": ("tert-Amyl methyl ether", "tert-Amil metil eter", "CH3CH2C(CH3)2OCH3", ["TAME"]),
    "thf": ("Tetrahydrofuran", "Tetrahidrofuran", "C4H8O", ["THF"]),
    "toluene": ("Toluene", "Toluen", "C6H5CH3", []),
    "triethylamine": ("Triethylamine", "Trietilamin", "(CH3CH2)3N", ["Et3N", "TEA"]),
    "o_xylene": ("o-Xylene", "o-Ksilen", "C6H4(CH3)2", ["xylenes", "ksilen"]),
    "m_xylene": ("m-Xylene", "m-Ksilen", "C6H4(CH3)2", ["xylenes", "ksilen"]),
    "p_xylene": ("p-Xylene", "p-Ksilen", "C6H4(CH3)2", ["xylenes", "ksilen"]),
    # In D2O only (Gottlieb 1997 text).
    "sodium_formate": ("Sodium formate", "Sodyum format", "HCOONa", []),
    "sodium_acetate": ("Sodium acetate", "Sodyum asetat", "CH3COONa", ["NaOAc"]),
    "sodium_carbonate": ("Sodium carbonate", "Sodyum karbonat", "Na2CO3", []),
    "sodium_bicarbonate": ("Sodium bicarbonate", "Sodyum bikarbonat", "NaHCO3", []),
    "dss": ("Sodium 3-(trimethylsilyl)propanesulfonate", "Sodyum 3-(trimetilsilil)propansülfonat",
            "(CH3)3Si(CH2)3SO3Na", ["DSS", "reference"]),
}

# Names used in each article -> canonical id.
SOURCE_NAMES = {
    "water": "water", "acetic acid": "acetic_acid", "acetic anhydride": "acetic_anhydride",
    "acetone": "acetone", "acetonitrile": "acetonitrile", "anisole": "anisole",
    "benzene": "benzene", "benzyl alcohol": "benzyl_alcohol", "BHT": "bht",
    "n-butanol": "n_butanol", "iso-butanol": "isobutanol",
    "tert-butyl alcohol": "tert_butanol", "tert-butanol": "tert_butanol",
    "n-butyl acetate": "n_butyl_acetate", "iso-butyl acetate": "isobutyl_acetate",
    "tert-butyl methyl ether": "mtbe", "carbon dioxide": "carbon_dioxide",
    "carbon disulfide": "carbon_disulfide", "carbon tetrachloride": "carbon_tetrachloride",
    "chlorobenzene": "chlorobenzene", "chloroform": "chloroform", "18-crown-6": "crown_18_6",
    "cyclohexane": "cyclohexane", "cyclohexanone": "cyclohexanone",
    "cyclopentyl methyl ether": "cpme", "p-cymene": "p_cymene", "1,2-dichloroethane": "dce",
    "dichloromethane": "dichloromethane", "diethyl ether": "diethyl_ether",
    "diglyme": "diglyme", "DME": "dme", "1,2-dimethoxyethane": "dme",
    "dimethylacetamide": "dma", "dimethyl carbonate": "dimethyl_carbonate",
    "dimethylformamide": "dmf", "dimethyl sulfoxide": "dmso", "DMPU": "dmpu",
    "1,4-dioxane": "dioxane", "dioxane": "dioxane", "ethane": "ethane", "ethanol": "ethanol",
    "ethyl acetate": "ethyl_acetate", "L-ethyl lactate": "ethyl_lactate",
    "ethyl tert-butyl ether": "etbe", "ethyl methyl ketone": "mek",
    "ethylbenzene": "ethylbenzene", "ethylene": "ethylene", "ethylene glycol": "ethylene_glycol",
    "formic acid": "formic_acid", "glycol diacetate": "glycol_diacetate",
    "H grease": "grease", "grease": "grease", "n-heptane": "n_heptane",
    "hexamethylbenzene": "hexamethylbenzene", "n-hexane": "n_hexane", "HMDSO": "hmdso",
    "HMPA": "hmpa", "hydrogen": "hydrogen", "imidazole": "imidazole",
    "iso-amyl acetate": "isoamyl_acetate", "iso-amyl alcohol": "isoamyl_alcohol",
    "2-propanol": "isopropanol", "iso-propanol": "isopropanol",
    "iso-propyl acetate": "isopropyl_acetate", "methane": "methane", "methanol": "methanol",
    "methyl acetate": "methyl_acetate", "methylcyclohexane": "methylcyclohexane",
    "methyl iso-butyl ketone": "mibk", "2-methyltetrahydrofuran": "me_thf",
    "nitromethane": "nitromethane", "n-pentane": "n_pentane", "propane": "propane",
    "propylene": "propylene", "pyridine": "pyridine", "pyrrole": "pyrrole",
    "pyrrolidine": "pyrrolidine", "silicone grease": "silicone_grease", "sulfolane": "sulfolane",
    "tert-amyl methyl ether": "tame", "tetrahydrofuran": "thf", "toluene": "toluene",
    "triethylamine": "triethylamine", "o-xylene": "o_xylene", "m-xylene": "m_xylene",
    "p-xylene": "p_xylene",
}


FAMILIES = {
    "Water": ("Water", "Su"), "Alcohols": ("Alcohols", "Alkoller"),
    "Ketones": ("Ketones", "Ketonlar"), "Esters": ("Esters", "Esterler"),
    "Ethers": ("Ethers", "Eterler"), "Hydrocarbons": ("Hydrocarbons", "Hidrokarbonlar"),
    "Halogenated": ("Halogenated", "Halojenli"),
    "Aprotic polar": ("Aprotic polar", "Aprotik polar"),
    "Miscellaneous": ("Miscellaneous", "Diğer"), "Acids": ("Acids", "Asitler"),
    "Amines": ("Amines", "Aminler"),
}

# CHEM21 name as printed -> (id, impurity ids it rates, names for solvents we
# have no NMR data for). Linked entries take their names from IMPURITIES.
CHEM21_NAMES = {
    "Water": ("water", ["water"]), "MeOH": ("methanol", ["methanol"]),
    "EtOH": ("ethanol", ["ethanol"]), "i-PrOH": ("isopropanol", ["isopropanol"]),
    "n-BuOH": ("n_butanol", ["n_butanol"]), "t-BuOH": ("tert_butanol", ["tert_butanol"]),
    "Benzyl alcohol": ("benzyl_alcohol", ["benzyl_alcohol"]),
    "Ethylene glycol": ("ethylene_glycol", ["ethylene_glycol"]),
    "Acetone": ("acetone", ["acetone"]), "MEK": ("mek", ["mek"]),
    "MIBK": ("mibk", ["mibk"]), "Cyclohexanone": ("cyclohexanone", ["cyclohexanone"]),
    "Methyl acetate": ("methyl_acetate", ["methyl_acetate"]),
    "Ethyl acetate": ("ethyl_acetate", ["ethyl_acetate"]),
    "i-PrOAc": ("isopropyl_acetate", ["isopropyl_acetate"]),
    "n-BuOAc": ("n_butyl_acetate", ["n_butyl_acetate"]),
    "Diethyl ether": ("diethyl_ether", ["diethyl_ether"]),
    "Diisopropyl ether": ("diisopropyl_ether", [], "Diisopropyl ether", "Diizopropil eter"),
    "MTBE": ("mtbe", ["mtbe"]), "THF": ("thf", ["thf"]), "Me-THF": ("me_thf", ["me_thf"]),
    "1,4-Dioxane": ("dioxane", ["dioxane"]), "Anisole": ("anisole", ["anisole"]),
    "DME": ("dme", ["dme"]), "Pentane": ("n_pentane", ["n_pentane"]),
    "Hexane": ("n_hexane", ["n_hexane"]), "Heptane": ("n_heptane", ["n_heptane"]),
    "Cyclohexane": ("cyclohexane", ["cyclohexane"]),
    "Me-cyclohexane": ("methylcyclohexane", ["methylcyclohexane"]),
    "Benzene": ("benzene", ["benzene"]), "Toluene": ("toluene", ["toluene"]),
    "Xylenes": ("xylenes", ["o_xylene", "m_xylene", "p_xylene"], "Xylenes", "Ksilenler"),
    "DCM": ("dichloromethane", ["dichloromethane"]),
    "Chloroform": ("chloroform", ["chloroform"]),
    "CCl4": ("carbon_tetrachloride", ["carbon_tetrachloride"]), "DCE": ("dce", ["dce"]),
    "Chlorobenzene": ("chlorobenzene", ["chlorobenzene"]),
    "Acetonitrile": ("acetonitrile", ["acetonitrile"]), "DMF": ("dmf", ["dmf"]),
    "DMAc": ("dma", ["dma"]),
    "NMP": ("nmp", [], "N-Methyl-2-pyrrolidone (NMP)", "N-Metil-2-pirolidon (NMP)"),
    "DMPU": ("dmpu", ["dmpu"]), "DMSO": ("dmso", ["dmso"]),
    "Sulfolane": ("sulfolane", ["sulfolane"]), "HMPA": ("hmpa", ["hmpa"]),
    "Nitromethane": ("nitromethane", ["nitromethane"]),
    "Methoxy-ethanol": ("methoxyethanol", [], "2-Methoxyethanol", "2-Metoksietanol"),
    "Carbon disulfide": ("carbon_disulfide", ["carbon_disulfide"]),
    "Formic acid": ("formic_acid", ["formic_acid"]), "Acetic acid": ("acetic_acid", ["acetic_acid"]),
    "Ac2O": ("acetic_anhydride", ["acetic_anhydride"]), "Pyridine": ("pyridine", ["pyridine"]),
    "TEA": ("triethylamine", ["triethylamine"]),
    "i-Butanol": ("isobutanol", ["isobutanol"]),
    "i-Amyl alcohol": ("isoamyl_alcohol", ["isoamyl_alcohol"]),
    "1,3-Propane diol": ("propanediol", [], "1,3-Propanediol", "1,3-Propandiol"),
    "Glycerol": ("glycerol", [], "Glycerol", "Gliserol"),
    "i-Butyl acetate": ("isobutyl_acetate", ["isobutyl_acetate"]),
    "i-Amyl acetate": ("isoamyl_acetate", ["isoamyl_acetate"]),
    "Glycol diacetate": ("glycol_diacetate", ["glycol_diacetate"]),
    "γ-Valerolactone": ("gvl", [], "γ-Valerolactone", "γ-Valerolakton"),
    "Diethyl succinate": ("diethyl_succinate", [], "Diethyl succinate", "Dietil süksinat"),
    "TAME": ("tame", ["tame"]), "CPME": ("cpme", ["cpme"]), "ETBE": ("etbe", ["etbe"]),
    "D-Limonene": ("limonene", [], "D-Limonene", "D-Limonen"),
    "Turpentine": ("turpentine", [], "Turpentine", "Terebentin"),
    "p-Cymene": ("p_cymene", ["p_cymene"]),
    "Dimethyl carbonate": ("dimethyl_carbonate", ["dimethyl_carbonate"]),
    "Ethylene carbonate": ("ethylene_carbonate", [], "Ethylene carbonate", "Etilen karbonat"),
    "Propylene carbonate": ("propylene_carbonate", [], "Propylene carbonate", "Propilen karbonat"),
    "Cyrene": ("cyrene", [], "Cyrene (dihydrolevoglucosenone)", "Cyrene (dihidrolevoglukozenon)"),
    "Ethyl lactate": ("ethyl_lactate", ["ethyl_lactate"]),
    "Lactic acid": ("lactic_acid", [], "Lactic acid", "Laktik asit"),
    "TH-furfuryl alcohol": ("thfa", [], "Tetrahydrofurfuryl alcohol", "Tetrahidrofurfuril alkol"),
}

# Deuterated solvent -> CHEM21 entry of the unlabeled compound.
SOLVENT_CHEM21 = {
    "cdcl3": "chloroform", "dmso_d6": "dmso", "acetone_d6": "acetone", "cd3od": "methanol",
    "d2o": "water", "c6d6": "benzene", "cd3cn": "acetonitrile", "cd2cl2": "dichloromethane",
    "thf_d8": "thf", "toluene_d8": "toluene", "c6d5cl": "chlorobenzene",
    "acetic_acid_d4": "acetic_acid", "cyclohexane_d12": "cyclohexane", "dmf_d7": "dmf",
    "dioxane_d8": "dioxane", "ethanol_d6": "ethanol", "pyridine_d5": "pyridine",
}


def build_chem21():
    entries = []
    rows = [(7, r[0], r[1], None, *r[2:]) for r in chem21_2016.TABLE7] + [
        (8, r[0], r[1], r[2], *r[3:], r[-1]) for r in chem21_2016.TABLE8]
    for table, printed, family, cas, bp, fp, h3, h4, safety, health, env, default, final in rows:
        cid, impurity_ids, *names = CHEM21_NAMES[printed]
        if names:
            en, tr = names
        else:
            en, tr = IMPURITIES[impurity_ids[0]][:2]
        e = dict(id=cid, name={"en": en, "tr": tr}, printed=printed,
                 family={"en": FAMILIES[family][0], "tr": FAMILIES[family][1]},
                 bp=bp, fp=fp, h3=h3, h4=h4, safety=safety, health=health, env=env,
                 rankDefault=default, rank=final, table=table, impurities=impurity_ids)
        if cas:
            e["cas"] = cas
        if printed in chem21_2016.TABLE7_SOLID or chem21_2016.TABLE8_NOTES.get(printed) == "solid":
            e["note"] = "solid"
        elif chem21_2016.TABLE8_NOTES.get(printed) == "water_sensitive":
            e["note"] = "water_sensitive"
        entries.append(e)
    ids = [e["id"] for e in entries]
    assert len(ids) == len(set(ids)), "duplicate CHEM21 ids"
    return entries


def load_json(name):
    with open(os.path.join(HERE, "sources", name)) as f:
        return json.load(f)


def sig(solvent, nucleus, shift, ref, mult=None, j=None, assignment=None,
        shift_max=None, note=None):
    s = {"solvent": solvent, "nucleus": nucleus, "shift": shift}
    if shift_max is not None and shift_max != shift:
        s["shift"], s["shiftMax"] = min(shift, shift_max), max(shift, shift_max)
    if mult:
        s["mult"] = mult
    if j:
        s["J"] = j
    if assignment:
        s["assignment"] = assignment
    if note:
        s["note"] = note
    s["ref"] = ref
    return s


def from_table(data, ref):
    """Fulmer/Gottlieb extractor output -> {id: [signal]}."""
    out = {}
    for nucleus, key in (("1H", "h1"), ("13C", "c13")):
        for row in data[key]:
            cid = SOURCE_NAMES[row["compound"]]
            for solvent, v in row["values"].items():
                out.setdefault(cid, []).append(sig(
                    solvent, nucleus, v["shift"], ref,
                    mult=row.get("mult"), j=row.get("J"), assignment=row["group"],
                    shift_max=v.get("shiftMax"), note=v.get("note")))
    return out


CELL = re.compile(
    r"^(?P<lo>-?\d+\.\d+)(?:-(?P<hi>\d+\.\d+))?"
    r"(?:,\s*(?P<mult>[a-z ]+?)(?:\s*\((?P<j>[\d., ]+)\))?)?"
    r"(?:\s*\[(?P<od>\d+\.\d+)(?:,\s*(?P<odmult>[a-z]+))?\])?$")


def parse_babij_cell(cell):
    if cell.startswith("-"):
        return None  # not observed / reacts with the solvent
    m = CELL.match(cell)
    if not m:
        raise ValueError(f"bad Babij cell {cell!r}")
    lo, hi = float(m["lo"]), float(m["hi"]) if m["hi"] else None
    note = None
    if m["od"]:
        note = f"–OD isotopomer: {m['od']}" + (f" ({m['odmult']})" if m["odmult"] else "")
    return lo, hi, m["mult"], m["j"], note


def from_babij():
    out, ratings = {}, {}
    for nucleus, table in (("1H", babij2016.H1), ("13C", babij2016.C13)):
        for c in table:
            cid = SOURCE_NAMES[c["name"]]
            ratings[cid] = c["rating"]
            for row in c["rows"]:
                if nucleus == "1H":
                    group, mult, j, cells = row
                else:
                    (group, cells), mult, j = row, None, None
                for solvent, cell in zip(babij2016.SOLVENTS, cells):
                    parsed = parse_babij_cell(cell)
                    if not parsed:
                        continue
                    lo, hi, cell_mult, cell_j, note = parsed
                    # A cell's own multiplicity replaces the column default.
                    out.setdefault(cid, []).append(sig(
                        solvent, nucleus, lo, "babij2016",
                        mult=cell_mult or mult, j=cell_j if cell_mult else j,
                        assignment=group, shift_max=hi, note=note))
    return out, ratings


def gottlieb_d2o_salts():
    g = "gottlieb1997"
    return {
        "sodium_formate": [sig("d2o", "13C", 171.67, g)],
        "sodium_acetate": [sig("d2o", "13C", 182.02, g, assignment="CO"),
                           sig("d2o", "13C", 23.97, g, assignment="CH3")],
        "sodium_carbonate": [sig("d2o", "13C", 168.88, g)],
        "sodium_bicarbonate": [sig("d2o", "13C", 161.08, g)],
        "dss": [sig("d2o", "1H", 2.91, g, assignment="CH2(1)"),
                sig("d2o", "1H", 1.76, g, assignment="CH2(2)"),
                sig("d2o", "1H", 0.63, g, assignment="CH2(3)"),
                sig("d2o", "1H", 0.00, g, mult="s", assignment="Si(CH3)3",
                    note="reference, δ 0"),
                sig("d2o", "13C", 54.90, g, assignment="CH2(1)"),
                sig("d2o", "13C", 19.66, g, assignment="CH2(2)"),
                sig("d2o", "13C", 15.56, g, assignment="CH2(3)"),
                sig("d2o", "13C", -2.04, g, assignment="Si(CH3)3")],
    }


def merge(sources):
    """Keeps, per (compound, solvent, nucleus), the signals of the first
    source in PRECEDENCE that has any."""
    merged = {}
    for cid in IMPURITIES:
        chosen = []
        taken = set()
        for ref in PRECEDENCE:
            by_key = {}
            for s in sources.get(ref, {}).get(cid, []):
                by_key.setdefault((s["solvent"], s["nucleus"]), []).append(s)
            for key, sigs in by_key.items():
                if key not in taken:
                    taken.add(key)
                    chosen += sigs
        merged[cid] = chosen
    return merged


def build_solvents(fulmer):
    solvents = []
    fulmer_ids = set(fulmer["residual_1h"]) | set(fulmer["residual_13c"])
    water = {r_solvent: v for r in fulmer["h1"] if r["compound"] == "water" and r["group"] == "OH"
             for r_solvent, v in r["values"].items()}

    def num(x):
        return float(x.split("-")[0]) if x else None

    rows = list(cil_chart.SOLVENTS) + [dict(id="c6d5cl", name="Chlorobenzene-d5",
                                            formula="C6D5Cl", h1=[], c13=[], hod=None)]
    for c in rows:
        sid = c["id"]
        residual = []
        if sid in fulmer_ids:
            residual += [dict(nucleus="1H", shift=v, ref="fulmer2010")
                         for v in fulmer["residual_1h"].get(sid, [])]
            residual += [dict(nucleus="13C", shift=v, ref="fulmer2010")
                         for v in fulmer["residual_13c"].get(sid, [])]
        for nucleus, key, jkey in (("1H", "h1", "JHD"), ("13C", "c13", "JCD")):
            for shift, mult, j in c[key]:
                p = dict(nucleus=nucleus, shift=shift, ref="cil")
                if CIL_MULT[mult]:
                    p["mult"] = CIL_MULT[mult]
                if j is not None:
                    p[jkey] = j
                residual.append(p)
        # Fulmer lists residual shifts without multiplicity; take it from the
        # matching CIL peak (same nucleus, within 0.1 ppm 1H / 1 ppm 13C).
        for p in residual:
            if p["ref"] != "fulmer2010":
                continue
            window = 0.1 if p["nucleus"] == "1H" else 1.0
            cil = [q for q in residual if q["ref"] == "cil" and q["nucleus"] == p["nucleus"]
                   and abs(q["shift"] - p["shift"]) <= window and q.get("mult")]
            if cil:
                p["mult"] = min(cil, key=lambda q: abs(q["shift"] - p["shift"]))["mult"]
        s = dict(id=sid, name={"en": c["name"], "tr": SOLVENT_TR[sid]}, formula=c["formula"],
                 residual=residual)
        if sid in water:
            s["water"] = dict(shift=water[sid]["shift"], ref="fulmer2010")
        elif c.get("hod"):
            s["water"] = dict(shift=num(c["hod"]), ref="cil")
        if c.get("hod"):
            s["hodCil"] = c["hod"]
        for k, jk in (("density", "density"), ("mp", "meltingPoint"), ("bp", "boilingPoint"),
                      ("dielectric", "dielectric"), ("mw", "molecularWeight")):
            if c.get(k) is not None:
                s[jk] = c[k]
        if c.get("h1_note"):
            s["note"] = c["h1_note"]
        if sid in SOLVENT_CHEM21:
            s["chem21"] = SOLVENT_CHEM21[sid]
        if sid != "c6d5cl":
            s["storage"] = cil_chart.STORAGE.get(sid, cil_chart.DEFAULT_STORAGE)
        solvents.append(s)
    assert sorted(SOLVENT_ORDER) == sorted(x["id"] for x in solvents)
    return sorted(solvents, key=lambda x: SOLVENT_ORDER.index(x["id"]))


def main():
    fulmer = load_json("fulmer2010.json")
    gottlieb = load_json("gottlieb1997.json")
    babij, ratings = from_babij()
    g = from_table(gottlieb, "gottlieb1997")
    for cid, sigs in gottlieb_d2o_salts().items():
        g.setdefault(cid, []).extend(sigs)
    merged = merge({"fulmer2010": from_table(fulmer, "fulmer2010"),
                    "gottlieb1997": g, "babij2016": babij})

    chem21 = build_chem21()
    chem21_by_impurity = {i: e["id"] for e in chem21 for i in e["impurities"]}
    # Babij 2016 marks each solvent with a CHEM21 triangle; the original
    # guide (Prat 2016) is used instead. Differences are listed for review.
    rank_of = {e["id"]: e["rank"] for e in chem21}
    for cid, babij_rank in sorted(ratings.items()):
        if cid in chem21_by_impurity and rank_of[chem21_by_impurity[cid]] != babij_rank:
            print(f"  CHEM21 differs from Babij for {cid}: "
                  f"{rank_of[chem21_by_impurity[cid]]} (Prat) vs {babij_rank} (Babij)")

    impurities = []
    for cid, (en, tr, formula, aliases) in IMPURITIES.items():
        signals = merged[cid]
        assert signals, f"no data for {cid}"
        imp = dict(id=cid, name={"en": en, "tr": tr}, formula=formula, aliases=aliases,
                   signals=signals)
        if cid in chem21_by_impurity:
            imp["chem21"] = chem21_by_impurity[cid]
        if cid == "anisole":
            imp["note"] = ("In D2O a second set of resonances was observed: "
                           "6.79, t (7.9); 6.50-6.43, m; 3.08, s (Babij 2016).")
        impurities.append(imp)

    solvents = build_solvents(fulmer)
    os.makedirs(OUT, exist_ok=True)
    for name, obj in (("references", REFERENCES), ("solvents", solvents),
                      ("impurities", impurities), ("chem21", chem21)):
        with open(os.path.join(OUT, f"{name}.json"), "w", encoding="utf-8") as f:
            json.dump(obj, f, ensure_ascii=False, indent=1)
            f.write("\n")
    n = sum(len(i["signals"]) for i in impurities)
    print(f"{len(solvents)} solvents, {len(impurities)} impurities, {n} signals, "
          f"{len(chem21)} CHEM21 entries")


if __name__ == "__main__":
    main()
