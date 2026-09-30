# App Review information (App Store)

Answer to Apple's "Guideline 2.1 – Information Needed" request for the first submission.
Paste it as the reply in App Store Connect and keep it in *App Review Information → Notes*
for future submissions. Attach the screen recording to the reply.

---

Hello App Review team,

Thank you for reviewing NMR Solvent Impurities. Please find the requested information below.

1. SCREEN RECORDING
A screen recording captured on a physical iPhone running the latest iOS is attached. It starts with launching the app and shows the typical flow: browsing a solvent, searching an impurity, a single-peak and a multiple-peak search, saving a result as a record, viewing it in the Records tab, and the Settings / About page. The app has no account registration or login, no user-generated content shared with others, and no paid content or in-app purchases.

2. PURPOSE AND TARGET AUDIENCE
NMR Solvent Impurities is an offline reference for chemists who record NMR spectra: university and high-school chemistry students, researchers and laboratory technicians. Almost every NMR spectrum contains small signals that do not belong to the sample: the residual peak of the deuterated solvent, water, and traces of common laboratory solvents and reagents. Identifying them normally means scanning large printed tables in journal articles. The app lets users enter what they see (solvent, chemical shift in ppm and splitting pattern, e.g. "1.26 ppm triplet in CDCl3") and instantly lists the matching impurities with the literature values and their sources. It also shows solvent properties, a green-chemistry (CHEM21) solvent guide, and lets users save their results for a sample on the device.

3. HOW TO USE THE MAIN FEATURES
No login, credentials or sample files are needed; all data are built into the app.
- Peak search tab: keep the solvent CDCl3, type 1.26 as the chemical shift and tap "t triplet". Ethyl acetate, ethanol and other candidates are listed with their literature values and sources.
- Multiple peaks: in the same tab switch to "Multiple peaks" and paste "2.05 s; 4.12 q; 1.26 t". Ethyl acetate is ranked first with 3 of 3 signals matched.
- Tap "Save results", enter any sample name (e.g. "Test 1") and tap Save. The result appears in the Records tab, where it can be opened, edited, copied as text or deleted.
- Solvents tab: tap a solvent (e.g. CDCl3) for its residual peaks and physical properties; "CHEM21 guide" shows the green-chemistry ranking.
- Impurities tab: search by name, abbreviation or formula (e.g. "EtOAc").
- Settings tab: language (English/Turkish), colour theme, light/dark mode, and "About the app" with the developer, the data sources and the license.

4. EXTERNAL SERVICES
None. The app makes no network connections and uses no external services: no data providers, authentication, payment, analytics, advertising or AI services. All reference data are bundled with the app. Records and settings are stored only on the device. The app is built with the open-source Flutter framework.

5. REGIONAL DIFFERENCES
There are none. The app works and shows the same content in all regions. The interface is shown in English or Turkish depending on the device language.

6. REGULATED INDUSTRY / THIRD-PARTY MATERIAL
The app does not operate in a regulated industry and is not a medical or diagnostic tool. The chemical shift values are factual scientific data compiled from peer-reviewed publications and a manufacturer's public solvent chart. Every value is shown with its source, and the full references (with DOIs) are listed in the app and in the description:
- H. E. Gottlieb, V. Kotlyar, A. Nudelman, J. Org. Chem. 1997, 62, 7512 (doi:10.1021/jo971176v)
- G. R. Fulmer et al., Organometallics 2010, 29, 2176 (doi:10.1021/om100106e)
- N. R. Babij et al., Org. Process Res. Dev. 2016, 20, 661 (doi:10.1021/acs.oprd.5b00417)
- D. Prat et al., Green Chem. 2016, 18, 288 (CHEM21) (doi:10.1039/c5gc01008j)
- Cambridge Isotope Laboratories, NMR Solvent Data Chart
No copyrighted text, figures or tables are reproduced; only the numerical values are used, with attribution. The app states that it is not affiliated with the publishers or with Cambridge Isotope Laboratories. The developer, Dr. İlker Ün, is a chemist and Chief Senior Researcher at TÜBİTAK National Metrology Institute (UME), working on quantitative NMR. The app is free, contains no ads and is open source (GPL-3.0): https://github.com/unilker/NMRSolvents
App page and privacy policy: https://kimyager.net/en/apps/nmr-solvent-impurities/

Kind regards,
Dr. İlker Ün
