# Recherche: VO2max und HRV mit dem MG-Band

Stand: 25.11.2026. Kurze Sätze. Eine Quelle pro Aussage.
[nicht verifiziert] = Aussage nur aus Sekundärquelle oder eigene Herleitung.

---

## A) VO2max

### A1. So machen es die Hersteller

**WHOOP (5.0/MG)**
- Drei Stufen: passives Modell, GPS-gestütztes Modell, kalibrierte Schätzung. Quelle: https://www.whoop.com/us/en/thelocker/how-accurate-is-whoop-vo2-max/ (Snippet, Seite blockiert Abruf).
- Eingaben: u. a. Atemfrequenz, Recovery, Zeit in HF-Zonen, GPS beim Laufen. Quelle: wie oben.
- Ein Laborwert kann eingetragen werden. Er dient dann als Anker. Quelle: wie oben.
- Voraussetzung: mindestens 14 Recoveries in 21 Tagen. Update wöchentlich (dienstags). Quelle: https://www.whoop.com/ae/en/thelocker/estimate-your-vo-max-with-whoop-/ (Snippet).
- Herstellerangabe: Fehler 3,3–3,7 ml/kg/min, MAPE < 8 %. Nur interne Kreuzvalidierung. Quelle: https://www.notebookcheck.net/Whoop-releases-new-VO2-Max-tracking-feature-for-wearables.977493.0.html
- Unabhängig: 16 Athleten, grob passend, teils starke Überschätzung (Labor 54 → WHOOP 64). Quelle: https://boxlifemagazine.com/is-your-vo2-max-accurate/

**Apple (Cardio Fitness)**
- Schätzung aus der HF-Antwort beim Gehen, Laufen, Wandern im Freien. Steigung < 5 %. Quelle: https://pubmed.ncbi.nlm.nih.gov/40373042/
- Validierung (n=30): Unterschätzung um 6,07 ml/kg/min. MAPE 13,3 %. LoA −6,1 bis +18,3. Quelle: https://pubmed.ncbi.nlm.nih.gov/40373042/
- Series 7: Über- oder Unterschätzung je nach Fitness. Quelle: https://www.ncbi.nlm.nih.gov/pmc/articles/PMC11325102/
- Apple-Whitepaper: https://www.apple.com/healthcare/docs/site/Using_Apple_Watch_to_Estimate_Cardio_Fitness_with_VO2_max.pdf (Fehlerwerte nicht ausgelesen) [nicht verifiziert].

**Garmin / Firstbeat**
- Prinzip: Verhältnis HF zu Geschwindigkeit beim Laufen. Firstbeat nennt 95 % Genauigkeit (MAPE ~5 %, n=79, 2690 Läufe). Quelle: https://www.firstbeat.com/en/science-and-physiology/fitness-level/
- Peer-Review (Handgelenk-PPG, submaximaler Lauf): MAPE 5,2 %. Firstbeat-nahe Autoren. Quelle: https://mhealth.jmir.org/2017/7/e97/PDF
- HFmax 15 bpm zu niedrig → ca. 9 % Fehler. Quelle: https://the5krunner.com/garmin-features/physiology/vo2-max/ [nicht verifiziert]
- Forerunner 245: MAPE 5,7 %. Quelle: https://www.thieme-connect.com/products/ejournals/pdf/10.1055/a-1686-9068.pdf
- Zweiter Lauf senkt MAPE von ~5,6 % auf ~1,1 %. Quelle: https://jssm.org/jssm-23-351.xml-Fulltext
- Hochtrainierte: Unterschätzung ~6,3 ml/kg/min. Quelle: https://link.springer.com/article/10.1007/s00421-025-05923-x

**Polar (Fitness Test / OwnIndex)**
- Ohne Belastung. Eingaben: Ruhe-HF, HRV, Geschlecht, Alter, Größe, Gewicht, Aktivität. Ca. 5 min Liegen, morgens. Quelle: https://polar.com/img/static/whitepapers/pdf/polar-fitness-test-white-paper.pdf
- Fehlerwerte aus Whitepaper nicht auslesbar [nicht verifiziert].

**Fitbit (Cardio Fitness Score)**
- Ohne GPS: aus Ruhe-HF, Alter, Geschlecht, Gewicht. Ausgabe als Bereich. Quelle: https://support.google.com/fitbit/answer/14237924
- Mit GPS: Pace-zu-HF-Beziehung. Empfehlung ≥ 10 min, flach. Quelle: https://support.google.com/fitbit/answer/14237924
- Algorithmus proprietär. Quelle: https://pmc.ncbi.nlm.nih.gov/articles/PMC7028477

**Oura (Cardio Capacity)**
- Start: Profildaten, Populationsmittel. Quelle: https://support.ouraring.com/hc/en-us/articles/28336620578835
- 6-min-Gehtest draußen: Distanz + HF. Kein Laufband. Quelle: https://support.ouraring.com/hc/en-us/articles/28336620578835
- Neu: automatisch aus GPS-Workouts. Quelle: https://ouraring.com/blog/de/cardio-effort-automatic-vo2max/

**Meta-Analyse (INTERLIVE, 14 Studien)**
- Ruhe-basierte Geräte: Bias +2,17, LoA −13,1 bis +17,4 ml/kg/min. Quelle: https://pmc.ncbi.nlm.nih.gov/articles/PMC9213394
- Belastungs-basierte Geräte: Bias −0,09, LoA ca. ±9,9. Besser, aber individuell großer Fehler. Quelle: https://pmc.ncbi.nlm.nih.gov/articles/PMC9213394

### A2. Publizierte Gleichungen

**Uth 2004 (HFmax/HFruhe)**
- VO2max = 15,3 × HFmax/HFruhe (Männer). SEE 2,7 ml/kg/min (~4,5 %). Nur 46 trainierte Männer. Quelle: https://link.springer.com/doi/10.1007/s00421-003-0988-y
- Frauen: Faktor 14,5. Kreuzvalidierte SEE 0,22 l/min (~6,8 %). Quelle: https://www.thieme-connect.com/products/ejournals/html/10.1055/s-2005-837443
- Mit Alters-HFmax statt gemessen: SEE ~7,8 %. Quelle: https://link.springer.com/doi/10.1007/s00421-003-0988-y [nicht verifiziert, aus Snippet]
- Hinweis: Uth nutzt Ruhe-HF im Liegen, wach. Nächtliches HF-Minimum liegt tiefer. Das würde überschätzen. [nicht verifiziert, eigene Ableitung]

**Nes 2011 (HUNT)**
- Ohne Belastung. Eingaben: Alter, Aktivitätsindex, Taillenumfang, Ruhe-HF. n=4637. SEE 5,70 (Männer), 5,14 (Frauen). Quelle: https://pubmed.ncbi.nlm.nih.gov/21502897/
- Männer: 100,27 − 0,296·Alter + 0,226·PA − 0,369·Taille − 0,155·RHF. Quelle (Sekundärtabelle): https://pmc.ncbi.nlm.nih.gov/articles/PMC7428991/table/jah35165-tbl-0001 [Koeffizienten im Original prüfen]

**Jurca 2005**
- Eingaben: Geschlecht, Alter, BMI, Ruhe-HF, Aktivität. SEE 1,45–1,97 MET (≈ 5,1–6,9 ml/kg/min). R 0,72–0,80. Quelle: https://www.unm.edu/~lkravitz/Sports%20Physiology/Jurca.pdf

**ACSM-Gleichungen (Geschwindigkeit in m/min)**
- Gehen: VO2 = 0,1·v + 1,8·v·Steigung + 3,5. Gültig ca. 50–100 m/min. Quelle: https://www.unm.edu/%7errobergs/478Steady%20State%20VO2%20Prediction%20Equations.doc
- Laufen: VO2 = 0,2·v + 0,9·v·Steigung + 3,5. Gültig > 134 m/min. Quelle: wie oben.
- Entwickelt an wenigen erwachsenen Männern. Quelle: https://frontiersin.org/journals/sports-and-active-living/articles/10.3389/fspor.2024.1522214/pdf

### A3. Empfehlung für unsere Daten

1. **Stufe 1 (immer):** Nes 2011 als Basis. Ruhe-HF = Nacht-Ruhe-HF, gemittelt über 7 Nächte. Fehler ±5–6 ml/kg/min ehrlich anzeigen.
   Begründung: Ruhe-basierte Schätzung streut stark (INTERLIVE, s. o.).
2. **Uth nur ergänzend.** Nur mit gemessener HFmax. Sonst ~8 % Fehler. Quelle: s. A2.
3. **Stufe 2 (bevorzugt):** Handy-GPS-Lauf oder zügiges Gehen. ACSM-VO2 je Segment aus Geschwindigkeit. Regression HF gegen VO2. Extrapolation auf HFmax. Das ist das Firstbeat-Prinzip. Quelle: https://mhealth.jmir.org/2017/7/e97/PDF
4. **Mindestdaten Stufe 2:**
   - ≥ 10 min, flach. Quelle: https://support.google.com/fitbit/answer/14237924
   - Steigung < 5 %. Quelle: https://pubmed.ncbi.nlm.nih.gov/40373042/
   - Mehrere Einheiten mitteln. Zweiter Lauf senkt den Fehler deutlich. Quelle: https://jssm.org/jssm-23-351.xml-Fulltext
   - Konstante Abschnitte (≥ 2–3 min gleiche Pace), Belastung deutlich über Ruhe [nicht verifiziert, Praxiswert].
5. **Schritte ohne GPS:** Kadenz × Schrittlänge (Körpergröße) als Notlösung [nicht verifiziert]. Fehler größer.
6. **Freigabe:** Wie WHOOP erst nach 14 Nächten in 21 Tagen. Quelle: https://www.whoop.com/ae/en/thelocker/estimate-your-vo-max-with-whoop-/
7. **Laborwert-Anker** erlauben. Quelle: https://www.whoop.com/us/en/thelocker/how-accurate-is-whoop-vo2-max/

---

## B) HRV

### B1. So machen es die Hersteller

- **WHOOP:** RMSSD in 5-min-Fenstern, Schritt 30 s, ganze Nacht. Wachphasen raus. Gewichtetes Mittel. Mehr Gewicht für Tiefschlaf und spätere Nacht. „Nur SWS" ist veraltet. Quelle: https://www.community.whoop.com/t/hrv-extreme-spikes/6472/31
- **Oura:** RMSSD, 5-min-Proben über die Nacht, Mittel und Maximum. Quelle: https://www.tryterra.co/research/how-hrv-actually-works [Sekundärquelle]
- **Garmin:** RMSSD über die Nacht. HRV-Status aus Mehrnächte-Baseline. Details widersprüchlich. Quelle: https://the5krunner.com/2025/05/20/hrv-everything-you-need-to-know-garmin-whoop-oura-hrv-hrv4training-training-readiness/ [nicht verifiziert]
- **Apple:** SDNN, sporadische Messungen. Nicht mit RMSSD vergleichbar. Quelle: https://tryterra.co/research/HRV-metric-discrepancy

### B2. Best Practice nächtlicher RMSSD aus Handgelenk-PPG

**Fensterlänge**
- 60 s reichen für lnRMSSD (vs. 5 min). Quelle: https://www.jssm.org/jssm-13-535.xml-abst
- 5-min-Fenster sind Standard bei WHOOP. Quelle: https://www.community.whoop.com/t/hrv-extreme-spikes/6472/31

**Schlafabschnitt**
- Ganze Nacht nutzen, nicht ein einzelnes 5-min-Stück. Einzelstücke sind sehr verrauscht. Quelle: https://medium.com/@altini_marco/what-you-need-to-know-about-heart-rate-variability-hrv-data-collected-during-the-night-eb3913ffdcf
- Erste Nachthälfte ist oft gedrückt. Zweite Hälfte höher. Quelle: https://marcoaltini.substack.com/p/heart-rate-variability-hrv-measurement

**Artefakte**
- Malik-Regel: > 20 % Abweichung zum Nachbar = Artefakt/Extrasystole. Bis 30 % tolerierbar. Quelle: https://www.ncbi.nlm.nih.gov/pmc/articles/PMC7074236/
- Lipponen–Tarvainen: adaptive Schwellen aus Verteilung der Differenzen. Restfehler < 2–8 %. Quelle: https://informahealthcare.com/doi/abs/10.1080/03091902.2019.1640306
- Ein einziges Artefakt kann RMSSD um > 250 % erhöhen. Quelle: https://jssm.org/jssm-21-260.xml-Fulltext
- Bias steigt mit Artefaktanteil (1, 3, 6 %). Quelle: https://www.ncbi.nlm.nih.gov/pmc/articles/PMC7074236/
- Feste „5 %-korrigiert"-Grenze: in keiner Quelle gefunden [nicht verifiziert].

**PPG vs. EKG**
- WHOOP 2.0 vs. EKG im Schlaf: lnRMSSD-Bias 1,66 %, LoA ±5,93 %. Das liegt nahe an der SWC. Quelle: https://acuresearchbank.acu.edu.au/download/70f2691b687e5a4e0997266c34d00cec8a8d37a2d38cbc0f8233bfe57a4c56d9/950087/OA_Bellenger_2021_Wrist_based_photoplethysmography_assessment_of_heart.pdf
- 536 Nächte vs. Polar H10: WHOOP 4.0 MAPE 8,2 %, Oura Gen4 6,0 %, Garmin 10,5 %. Quelle: https://www.ncbi.nlm.nih.gov/pmc/articles/PMC12367097/

**Timing-Jitter (unser Fall: ACF lag-1 der Differenzen −0,43…−0,52)**
- Zufällige Fehler von 10–100 ms je Intervall änderten HRV kaum. Einzelartefakte schon. Quelle: https://jssm.org/jssm-21-260.xml-Fulltext
- PPG-Intervallfehler typisch SD 1–10 ms. Quelle: https://link.springer.com/10.1038/s41598-023-50701-4
- Eigene Herleitung [nicht verifiziert in Literatur]:
  - Weißes Rauschen je RR-Intervall (Varianz σ²) gibt bei ΔRR eine lag-1-ACF von −0,5. Unsere Werte passen dazu. Das Rauschen dominiert also die Differenzen.
  - Schätzer: σ² ≈ −γ1, mit γ1 = Autokovarianz lag-1 der ΔRR.
  - Korrektur: RMSSD_korr = √(mean(ΔRR²) + 2·γ1). Bei negativem Radikanden auf 0 kappen. Fenster verwerfen.
  - Echte ΔRR haben meist γ1 ≥ 0. Dann ist die Korrektur eher konservativ.
  - Bei Jitter auf Zeitstempeln wäre die ACF −0,67. Dann gilt ein anderer Faktor (Rauschvarianz = −1,5·γ1).
  - Sheppard-Korrektur für Quantisierung q: Varianz je Intervall q²/12, je Differenz q²/6.
  - Vorher an Polar-H10-Parallelnächten prüfen.

**Berichten**
- lnRMSSD verwenden. 7-Tage-Rollmittel. SWC und CV nutzen. Quelle: https://www.ais.gov.au/__data/assets/pdf_file/0013/1130260/HRV-BPG_FINAL.pdf
- CV des 7-Tage-lnRMSSD sinkt vor Übertraining. Quelle: https://pubmed.ncbi.nlm.nih.gov/22367011/
- Baseline = 7-Tage-Mittel. Normalbereich aus 60 Tagen. Quelle: https://hrv4training.com/faq.html
- Tag-zu-Tag-Schwankung 5–20 ms ist normal. Quelle: https://hrv4training.com/faq.html
- SWC = 0,5 × SD (oder 0,5 × CV): genaue Plews-Formel nicht bestätigt [nicht verifiziert].

### B3. Erfahrungen aus Foren

- WHOOP vs. Polar: Ruhe- und Schlaf-HF „spot on", HRV konsistent. Quelle: https://www.trainerroad.com/forum/t/whoop-instead-of-hrm/61888/26
- WHOOP überschätzt HF beim Training vs. Brustgurt. Quelle: https://www.community.whoop.com/t/polar-chest-strap-vs-whoop/5359
- WHOOP für Trends brauchbar, leicht zu niedrig. Quelle: https://the5krunner.com/2025/10/06/garmin-beaten-by-oura-whoop-in-hrv-accuracy-showdown
- OpenWhoop: RMSSD 02–06 Uhr, Malik-Filter, nicht klinisch validiert. Quelle: https://openwhoop-d68.pages.dev/
- OpenStrap-eigene RR-Doku nicht gefunden. Quelle: https://github.com/OpenStrap [nicht verifiziert]

---

## Empfehlung für die App (kurz)

**HRV**
1. Nur Schlaf. Wach- und Bewegungsphasen per Accelerometer raus.
2. RMSSD in 5-min-Fenstern, Schritt 30 s (wie WHOOP).
3. Artefakte: Malik 20 % gegen lokalen Median, besser Lipponen–Tarvainen.
4. Fenster nur mit ≥ 80 % sauberen Beats [eigene Schwelle, nicht verifiziert].
5. Jitter-Korrektur per γ1 (s. o.), erst nach H10-Abgleich aktiv.
6. Nachtwert: Median der Fenster. Optional höheres Gewicht für 2. Nachthälfte.
7. Mindestens 2 h gültige Fenster pro Nacht [eigene Schwelle, nicht verifiziert].
8. Anzeige: lnRMSSD, 7-Tage-Mittel, Normalbereich aus 60 Tagen, CV.

**VO2max**
1. Basis: Nes 2011 mit 7-Nacht-Ruhe-HF. Fehler ±5–6 anzeigen.
2. Besser: GPS-Lauf/Gehen ≥ 10 min, flach (< 5 %), ACSM + HF-Regression bis HFmax.
3. Mehrere Einheiten mitteln. Laborwert als Anker erlauben.
4. Freigabe erst nach 14 Nächten in 21 Tagen.
