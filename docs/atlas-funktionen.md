STAND: fertig (Teil 1 Nr. 1–27, Teil 2 Durchgang A und B, Rangliste).

# Atlas One: alle Funktionen und Werte

Stand des Codes: `index.html`, `WALGO_VER = 24`, Build `96-2026-10-17a`.
Zeilennummern gelten für diesen Stand.
Die Datei ändert keinen Code. Sie listet nur auf und schlägt Änderungen vor.
Ältere Übersicht: `docs/berechnungen.md` (Stand Version 20, teils veraltet).

Quellen-Kürzel:
- **Band** = Rohbytes des WHOOP 5.0 per Bluetooth.
- **4.0** = Pfad nur für das alte WHOOP 4.0. Das Gerät ist ausgemustert.
- **Export** = WHOOP-Cloud-Export (`whoopRef`, Tage mit `_src='whoop'`).
- **Apple** = Apple Health über die iPhone-App.
- **Hand** = Eingabe in der App.
- **Abgeleitet** = aus anderen Werten berechnet.

## Teil 1: Inventar

### 1. Atlas Overall (`dayScore`, Z. 2468)
- Quelle: abgeleitet aus sieben Teilwerten (`_subScores`, Z. 2026).
- Gewichte (`WEIGHTS`, Z. 2450): Schlaf 0,25, Erholung 0,20, Training 0,18, Ernährung 0,17, Basics 0,12, Supplements 0,04, Gesundheit 0,04.
- Ein Bereich ohne Daten fällt heraus. Die übrigen Gewichte werden auf 100 % hochgerechnet.
- „Gesundheit" ist immer aus: `dayActive().meds = false`, `_subScores().meds = null`.
- Danach Abzug: `min(12, stimPenalty × 0,4)` (Alkohol, Nikotin, Koffein; `stimPenalty` Z. 5900).
- Zukunftstage: 0.
- Anzeige: Dashboard, dritter Bogen „Atlas Overall" (`gaugeSmall` Z. 2844, Kachel Z. 3235), Verlauf (Z. 8386).
- Farbe: `statusCol` grün ab 65, gelb ab 50, sonst orange.

### 2. Schlaf-Teilwert (`sleepSubScore`, Z. 2008)
- Mit Band oder Export: gleich der Schlafleistung `whoop.sleepPerf` (Nr. 4).
- Ohne Messung: 0,70 × min(Schlaf/Bedarf, 1) + 0,12 × Effizienz-Anteil ((Eff − 70)/25) + 0,10 × Konsistenz.
- Gibt es nur die Stunden, zählt die eingetragene Qualität (0–10) mit 0,25.
- Mehr als Bedarf + 2 h: 5 Punkte Abzug je Stunde darüber.
- Anzeige: Dashboard-Bogen „Schlaf".

### 3. Erholung (`wComputeRecovery`, Z. 15406; Formel `wRecFormula`, Z. 15404)
- Quelle: Band (HRV, Ruhepuls) plus Schlafleistung. Export-Tage nutzen WHOOPs eigenen Wert.
- zH = (HRV − Median)/SD, zR = (Median − Ruhepuls)/SD, beide auf ±2,5 begrenzt.
- Basislinie `wBaseline` (Z. 15364): 30 Nächte davor, mindestens 4. SD = MAD × 1,4826 mit Untergrenze (Ruhepuls 2 bpm, HRV max(3, 8 % des Medians)). Bis 14 Nächte mit der Export-SD gemischt.
- Teilnächte und Nächte älterer Rechen-Version zählen nicht.
- logit = 0,83·zH + 0,11·zR + 0,286·(SP − 85)/10 + 0,878. Score = 100/(1 + e^−logit), 1–99.
- Ohne HRV keine Erholung.
- Gewichte stammen aus einer eigenen Regression auf 309 WHOOP-Tagen des Nutzers (Kommentar Z. 15409).
- Ohne Band: Mittel aus Handangaben HRV-Gefühl 3,5, Muskelkater 2,5, Stress 2,5, Trinken 1,5 (`_subScores` Z. 2037).
- Farbe `recCol`: grün ab 67, gelb ab 34, sonst rot (wie WHOOP).
- Anzeige: Dashboard-Bogen „Erholung", Teilwert im Atlas Overall.

### 4. Schlafleistung (`wComputeSleepPerf`, Z. 15433)
- Quelle: abgeleitet aus Schlafdauer, Schlafbedarf, Konsistenz.
- SP = 0,707 × min(Schlaf/Bedarf, 1) × 100 + 0,245 × Konsistenz + 3,4, auf 0–100 begrenzt.
- Fehlt die Konsistenz: Export-Median oder 65.
- Gewichte aus eigener Regression auf WHOOP-Nächten (7 Punkte Abweichung).

### 5. Schlafkonsistenz (`wComputeSleepCons`, Z. 15451)
- Quelle: Band (Einschlaf- und Aufwachzeit), 14 Tage inkl. heute, mindestens 4.
- Zirkuläre SD in Stunden, Mittel aus Einschlaf- und Aufwach-SD.
- Wert = 100 − 35 × SD, 0–100.
- Ohne Band: `sleepConsFallback` (Z. 3338) = 40 + 55 × Anteil abgehakter „Konstante Schlafzeiten".

### 6. Schlafbedarf und Schlafschuld (`sleepNeedInfo`, Z. 3534)
- Grundbedarf: Export `needBase`, sonst `sleepBaseline` (Z. 3524): 8,0 h; ab 40 J 7,8; ab 65 J 7,6; unter 18 J 9,0; Frauen +0,2; ab 95 kg oder 192 cm +0,1.
- Bedarf = Grund + 2,85 min × Strain des Vortags + Schuld − Nickerchen des Vortags, 6–11 h.
- Schuld = 0,27 × Σ (Bedarf − Schlaf) der letzten 4 Nächte, Gewichte 1 / 0,3 / 0,09 / 0,027, nie unter 0.
- Anzeige: Schlafbedarf-Kachel (`sleepNeedTile`, Z. 3762), Schlafdetail.

### 7. Schlafdauer, Phasen, Effizienz, Wachphasen, Latenz (`wFinalizeDay0`, Z. 12198)
- Quelle: Band (Puls, RR, Beschleunigung, Handgelenkwinkel).
- Ruhefenster: `wSleepWindow` (Z. 10751), van Hees 2018 (HDCZA); ohne Winkel `wSleepWindowEnmo` (Z. 10785).
- Phasen Wach/Leicht/Tief/REM: `wSleepStages3` (Z. 11506), Viterbi (Z. 11442) über Puls, RMSSD, SDNN, LF/HF (`wLfHf` Z. 11333), Bewegung.
- Schlafdauer = Leicht + Tief + REM zwischen Einschlafen und Aufwachen (`wSleepSummary`, Z. 11480).
- Effizienz = Schlaf / (Aufwachen − Einschlafen).
- Wachphasen `slWakes`, Latenz `slLatency` (letzte Bewegung bis Einschlafen).
- Phasen fließen in keinen Score.
- Anzeige: Schlafübersicht `sleepOverviewTile` (Z. 3562), Hypnogramm `sleepHypnogram` (Z. 3608), Schlafdetail (Z. 3769).

### 8. Ruhepuls und Schlaf-Ruhepuls (`wRhrWhoop`, Z. 10472; `wNocturnalRhr`, Z. 10544)
- Quelle: Band, Puls der Schlaf-Epochen.
- min(tiefschlaf-gewichteter Puls, Median der 2. Schlafhälfte). Ohne Phasen: 5-min-Minimum.
- Gültig 30–85 bpm.
- Anzeige: Erholungszeile, Health-Tab „Herz". Fließt in Erholung, Zonen, Strain, VO₂max, Fitness-Alter.

### 9. HRV (RMSSD) und SDNN (`wHrvWhoop`, Z. 10505; `wHrvClean`, Z. 11767)
- Quelle: Band, RR-Intervalle im Schlaf.
- RR-Korrektur `wCorrectRr` (Z. 11715) nach Lipponen & Tarvainen 2019.
- 5-min-Fenster alle 30 s. Fenster mit Artefakten fallen weg (Autokorrelation < −0,35 oder Ausreißer).
- Gewichtetes Mittel (Tiefschlaf, späte Nacht) oder Median der 2. Hälfte, wenn höher. Über 180 ms: verworfen.
- Anzeige: Erholungszeile, Health-Tab, Erholung.

### 10. Atemfrequenz (`wRespRate`, Z. 11200)
- Quelle: Band, RR (RSA `wRespRSA` Z. 11154 und RIIV `wRespRIIV` Z. 11171, Lomb-Scargle Z. 11124).
- Median aus mindestens 3 lückenlosen 5-min-Fenstern.
- Nur Anzeige und Krankheits-Warnung.

### 11. Hauttemperatur
- Quelle: Band (nur 5.0), Median im Ruhefenster, Feld `skinTemp`.
- Anzeige: „Warum"-Erklärung, Krankheits-Warnung.

### 12. Strain Tag (`wComputeStrain`, Z. 15482; `wTrimpBanister`, Z. 15472)
- Mit Band: Banister-TRIMP je 30-s-Epoche ab 40 % Herzfrequenzreserve.
- Gewicht: Männer 0,64·e^(1,92·x), Frauen 0,86·e^(1,67·x), x = HFR-Anteil.
- Strain = 5,086 × ln(1 + TRIMP/5,98), 0–21 (`wStrainFromTrimp`). Eigene Eichung an 119 WHOOP-Workouts.
- Ohne Band: Sätze/26 × 7 + Cardio-min/60 × 5, oder (kcal − Grundumsatz)/900 × 11, max 21.
- Anzeige: Strain-Kachel `strainTile` (Z. 3353), Schlafbedarf des Folgetags.

### 13. VO₂max (`wVo2At`, Z. 12620; `wUpdateVo2max`, Z. 12689)
- Mit Läufen (60 Tage, ≥ 1,5 km, ≥ 10 min, Band-Puls): ACSM-Laufgleichung 3,5 + 0,2·v + 0,9·Steigung; VO₂max = 3,5 + (VO₂ − 3,5)/%HFR (`wVo2FromRuns`, Z. 12601). Median.
- Ohne Läufe: Mittel aus Uth (15,3 × HFmax/HFRuhe, `wVo2maxUth` Z. 10612) und Jurca 2005 ((2,77·Mann − 0,10·Alter − 0,17·BMI − 0,03·Ruhepuls + PA + 18,07) × 3,5).
- HFmax = max(beobachtet, Tanaka 208 − 0,7 × Alter).
- Einstufung `VO2_NORM` / `_vo2Thr` (Z. 12642): Cooper-Tabelle nach Heyward, 6 Stufen.
- Zweites „Fitness-Alter" `vo2FitAge` (Z. 12646): Alter, in dem die Stufe „Mittel" dem Wert entspricht.
- Anzeige: VO₂max-Kachel `vo2Tile` (Z. 12652), Detail `openVo2`.

### 14. Fitness-Alter und „Pace of Aging" (`fitnessAgeAt`, Z. 3497; `paceOfAging`, Z. 3509)
- Quelle: Band (Ruhepuls-Median 7 Nächte, mindestens 4; Zonen-Minuten).
- FA = Alter + (rC·(Ruhepuls − 65) − pC·(PA − 5)) / aC. Männer 0,155 / 0,226 / 0,296, Frauen 0,114 / 0,198 / 0,247 (Nes 2011).
- PA-Index = Häufigkeit × Intensität × Dauer (0–15).
- Häufigkeit aus aktiven Tagen der letzten 7 (≥ 15 min ab Zone 2): 0 → 0; 1 → 0,5; 2 → 1; 3–4 → 2,5; ≥ 5 → 5.
- Intensität aus Anteil Zone 4–5: < 15 % → 1; < 50 % → 2; sonst 3.
- Dauer aus mittleren aktiven Minuten: < 15 → 0,1; < 30 → 0,38; < 60 → 0,75; sonst 1.
- „Pace" = FA heute − FA vor 84 Tagen.
- Anzeige: `agingOrb`, Aufschlüsselung `agingBreakdownModal`, Anzeige ±5 J.

### 15. Zonen und Zone 2 (`wZoneOf`, Z. 11828; `wZoneDay`, Z. 11839)
- Quelle: Band, Puls je 30 s.
- Zonen nach Herzfrequenzreserve (Karvonen): Z1 50–60 %, Z2 60–70 %, Z3 70–80 %, Z4 80–90 %, Z5 ab 90 %.
- Einheit = mindestens 10 min ab Zone 2, Lücken bis 2 min überbrückt.
- Zone-2-Minuten `z2BoutMin` = Minuten in Zone 2 innerhalb solcher Einheiten.
- Cardio-Minuten je Tag `cardioDayMin` (Z. 5985) = max(eingetragen, `z2BoutMin`).
- Anzeige: Cardio-Wertung, Basics (Ziel 175 min in 7 Tagen, `HP_CARDIO_TARGET` Z. 5994).

### 16. Strain je Workout und Trainingswerte (`wTrainLoad`, Z. 11926; `trainingDayScore`, Z. 2124)
- Quelle: Band-Puls im Fenster „Training beginnen" bis „Beenden", höchstens 2 h.
- Je Satz: Spitzenpuls, Belastung (`effort`), Strain, Puls-Erholung nach 2 min.
- Trainings-Score Krafttag: 40 % Progression (e1RM gegen letzte Einheit), 25 % Intensität (Ø RIR, mit Band 30 % gemessene Belastung), 20 % Volumen gegen Median der letzten 6 Trainingstage, 15 % Arbeitssätze gegen Ziel.
- Rest-Day: kein Trainings-Score. Er zählt nicht in den Atlas Overall.
- Anzeige: Trainingsseite, Teilwert „Training".

### 17. Kalorien
- Band (`wDayKcal`, Z. 11649): je 30 s ab 40 % HFR Keytel 2005 (`wKeytelKcalMin`, Z. 10644), sonst Grundumsatz. Nicht getragene Zeit = Grundumsatz.
- Grundumsatz im Band-Pfad: revidierte Harris-Benedict (`wBmrKcalDay`, Z. 10649).
- Grundumsatz im Ziel-Pfad: Mifflin-St-Jeor oder Katch-McArdle (`kcalBreakdown`, Z. 3873).
- Training ohne Band (`estimateTrainingKcal`, Z. 2085): MET 4–6,5 je RIR × Gewicht × Sätze × 3,5 min; Cardio 7 MET.
- Anzeige: Ziele-Seite, Kalorienziel, Strain ohne Band.

### 18. Schritte (`stepsDay`, Z. 3730; `stepsCalib`, Z. 3723)
- Quelle: Apple (iPhone-Schritte je Stunde) und Band (5.0: Schrittzähler `stepTkHr`; 4.0: Bewegungsmenge `moveHr`, nur 4.0).
- Eichung Band → Schritte: gewichteter Median des Verhältnisses iPhone/Band je Stunde, 14 Tage, mindestens 6 Paare.
- Je Stunde gilt das iPhone, wenn es ≥ 50 % der Band-Schätzung hat oder die Schätzung < 300 ist. Sonst die Band-Schätzung.
- Anzeige: Erholungsliste „Schritte", Detail `openSteps`.

### 19. Blut-O₂ (SpO₂)
- Quelle: Band 5.0 (`wparseV18` Z. 10306, Byte 74, 70–100 %). Im Schlaf etwa alle 20 min ein 30-s-Fenster.
- Wert = Median von mindestens 3 Fenstern, eine Nachkommastelle; dazu Minimum und Anzahl (Z. 12480).
- Export: `spo2_percentage`.
- Anzeige: Erholungsliste „Blut-O₂", Hinweis „unter 90 % öfter: ärztlich abklären" (Z. 8391).

### 20. Tagesstress (`wDayStress`, Z. 12097; Kachel `stressTile`, Z. 3168)
- Quelle: Band, Puls je 30 s, Bewegung (ENMO), RMSSD je 5 min.
- Zusatzpuls = Puls − (ruhiger Wachpuls + k1·log10(1 + ENMO₂/0,01) + k2·log10(1 + ENMO₁₀/0,01)).
- Stress = 3 × Mittel(Zusatzpuls / (20 % HFR), ln(Basis-RMSSD / RMSSD) / ln 3). Ohne RMSSD: 2,7 × Puls-Anteil.
- Stufen: < 1 entspannt, < 2 normal, sonst angespannt (`_stZ`, Z. 3159).
- Schlaf-Stress: gleiche Form, Puls gegen Ruhepuls + 2, Skala max(8, 10 % HFR).
- Sauna `wDetectHeat` (Z. 12024) und Training werden ausgenommen.

### 21. Krankheits-Warnung (`illnessWatch`, Z. 15619; Banner `illnessBanner`)
- Quelle: Band oder Export. Mittel der letzten 2 Tage gegen Mittel der Tage 3–30, mindestens 14 Tage.
- Signale: Ruhepuls ≥ Basis + 5, HRV ≤ 0,8 × Basis, Hauttemperatur ≥ Basis + 0,6 °C, Atemfrequenz ≥ Basis + 1,5/min.
- Banner erst ab 2 Signalen. Teilnächte zählen nicht.

### 22. Energiekurve und Leistungsfenster (`energyModel`, Z. 2568; `performanceZones`, Z. 2621)
- Drei-Prozess-Modell (Åkerstedt & Folkard): S = 2,4 + (S0 − 2,4)·e^(−0,0353·t), C = 2,52·cos(2π(x − 16,8)/24), W = −5,72·e^(−1,51·t).
- S0 = 14,3 − 7,3 × max(0, 1 − Schlaf/Bedarf).
- Dazu: Mittagstief, Mahlzeiten ≥ 400 kcal, Koffein (Halbwertszeit 5 h), Niveau aus Erholung, Schlafleistung, Ernährung.
- Skala 3–100 %. Abgleich mit Energie-Einträgen (`energyCalib`, Z. 2607): Verschiebung ±20.
- Leistungsfenster: Phasen über max(58, 82 % des Gipfels); Gym-Fenster 14:30–18:30.

### 23. Basics (`hubermanScore`, Z. 5995)
- Quelle: Hand (Haken) und Band (`wAutoBasics`, Z. 15515: „Konstante Schlafzeiten" ±30 min vom Median, „Kein Essen" ≥ 2,5 h vor dem Einschlafen).
- Gewichte `HP_WEIGHTS` (Z. 5990): Schlafzeiten 10, Licht 9, Cardio 9, je 6 für Bett, Kühle, Dunkel, Wärme, kein Essen; 5 für Koffein, Trinken, Atmung, NSDR; 4 Sonnenuntergang, Kälte; 3 Maske, Theanin.
- Wert = Σ erfüllte Gewichte / Σ alle × 100.

### 24. Ernährung (`nutParts`, Z. 2419) und Supplements (`suppNeedScore`, Z. 2438)
- Ernährung: kcal 40, Protein 20, Carbs 15, Fett 10, „clean" 15. Bereich ±5 % voll. Abzüge Samenöl, Süßstoff, Lektine bis 25.
- Supplements: alle genommen 100, 1 fehlt 90, 2 fehlen 80, sonst Anteil (max 70). Kreatin fehlt: max 50.

### 25. EKG (`wparseEcg17`, Z. 4339; `ecgSvg`, Z. 4390)
- Quelle: Band 5.0, 30 s Fingerkontakt am Verschluss.
- Anzeige nur als Rohkurve. Keine Rhythmus-Einordnung, keine mV-Skala, keine Abtastrate.

### 26. Blutdruck (`bpClass`, Z. 8093; `bpCat`, Z. 8094; Erholungsliste Z. 3288)
- Quelle: Hand.
- Klassen `BP_CLASSES` (Z. 8088): Ziel < 120/80, erhöht ab 120/80, kritisch ab 136/86, „sehr hoch" ab 180/110. Unter 90/60: „niedrig".
- Erholungsliste nutzt eigene Farben: orange über 135/85, gelb ab 130/80 (Ø 7 Tage).
- Gesundheits-Score `healthScore` (Z. 8100) fließt nicht mehr in den Atlas Overall.

### 27. Blutwerte und Stack
- Blutwerte: Hand. Liste `BLOODREF` (Z. 1317) mit „Optimalbereichen" aus dem Guide MuscleMarvin und testomangel.com.
- `matchRef` (Z. 1425): längster passender Name. `refStatus` (Z. 1426): niedrig/ok/hoch gegen `refRange` (Z. 1402, Alters- und Geschlechtsanpassung).
- Freies Testosteron (`freeTestoVermeulen`, Z. 4468): Vermeulen 1999, Albumin-Standard 43 g/l.
- Stack (Z. 4488–4640): Logbuch für Substanzen. Plan, Einnahme, Adhärenz 28 Tage (`stackAdherence`), Talspiegel-Termin (`stackNextTrough`), Warnungen aus Blutwerten (`stackAlerts`, Z. 4528), fällige Marker (`stackBloodPlan`).
- Anzeige: Health-Tab, Stack-Seite.

## Teil 2: Logik-Prüfung

Durchgang A vergleicht die Formel mit Quellen.
Durchgang B prüft Gewichte, Spannen, Doppelzählung und Genauigkeit der Anzeige.
„Eigene Eichung" heißt: Die Konstanten stammen aus einer Regression auf den WHOOP-Daten des Nutzers. Die Rechnung steht im Code, nicht in einer Veröffentlichung.
„Keine Quelle" heißt: Ich habe keine Referenz gefunden.

Quellen:
- [W1] WHOOP Recovery: https://www.whoop.com/thelocker/how-does-whoop-recovery-work-101/
- [W2] WHOOP Strain: https://www.whoop.com/thelocker/how-does-whoop-strain-work-101/
- [N1] NOOP ANALYTICS.md: https://github.com/ParthJadhav/noop/blob/main/docs/ANALYTICS.md
- [N2] NOOP FitnessAgeEngine.swift: https://github.com/ParthJadhav/noop/blob/main/Packages/StrandAnalytics/Sources/StrandAnalytics/FitnessAgeEngine.swift
- [P1] Plews 2012, ln RMSSD: https://pubmed.ncbi.nlm.nih.gov/22367011/
- [P2] AIS HRV Best Practice (ln RMSSD, 7-Tage-Mittel): https://www.ais.gov.au/__data/assets/pdf_file/0013/1130260/HRV-BPG_FINAL.pdf
- [K1] Keytel 2005: https://pubmed.ncbi.nlm.nih.gov/15966347/
- [U1] Uth 2004: https://link.springer.com/doi/10.1007/s00421-003-0988-y
- [J1] Jurca 2005: https://www.unm.edu/~lkravitz/Sports%20Physiology/Jurca.pdf
- [H1] Nes 2011 (HUNT): https://www.qxmd.com/r/21502897
- [E1] ESC 2024 Blutdruck: https://www.escardio.org/Guidelines/Clinical-Practice-Guidelines/Elevated-Blood-Pressure-and-Hypertension
- [E2] Kommentar zu ESC 2024 (120–139/70–89, Heim 135/85): https://www.revespcardiol.org/en-comments-on-2024-esc-guidelines-articulo-S1885585725000477
- [B1] NT-proBNP 125 pg/ml (ESC, nicht akut): https://pmc.ncbi.nlm.nih.gov/articles/PMC9799346
- [S1] SpO₂ am Handgelenk, RMSE 2–3,4 %: https://arxiv.org/pdf/2505.20846 und https://ieeexplore.ieee.org/document/9176081
- [C1] Chinoy 2021, Schlafphasen von Wearables: https://pmc.ncbi.nlm.nih.gov/articles/PMC8120339

### Tabelle: Urteil je Wert

| Nr. | Wert | Urteil | Grund (A = Quelle, B = Gewichte/Genauigkeit) | Quelle | Vorschlag (nicht angewendet) |
|---|---|---|---|---|---|
| 1 | Atlas Overall | korrigieren | B: „Gesundheit" hat Gewicht 0,04, ist aber immer aus. B: Schlaf zählt dreifach: Schlaf-Teilwert 25 %, Schlafleistung in der Erholung, Basic „Schlafzeiten" (Gewicht 10). B: Kommentar Z. 2443 nennt alte Gewichte. Keine Quelle für die Gewichte. | keine | `meds` aus `WEIGHTS` und `USAGE_ITEMS` streichen. Kommentar Z. 2443 löschen. Doppelzählung offenlegen oder Basic `sleepreg` aus dem Basics-Score nehmen, solange Band-Schlaf da ist. |
| 1a | Verhaltens-Abzug `stimPenalty` (Z. 5900) | behalten, kennzeichnen | Keine Quelle für 0,6 je g Alkohol, 1,2 je mg Nikotin, 4 je Koffein-Einheit über 4. | keine | Im Info-Text „Faustregel, keine Studie" ergänzen. |
| 2 | Schlaf-Teilwert ohne Band | behalten | Gewichte 0,70/0,12/0,10/0,25 ohne Quelle. Der Abzug ab Bedarf + 2 h ist plausibel, aber ohne Quelle. | keine | Keine Änderung. |
| 3 | Erholung | korrigieren | A: WHOOP nutzt HRV, Ruhepuls, Schlaf, Atmung; HRV dominiert [W1]. NOOP genauso [N1]. Gewichte = eigene Eichung (r 0,93). B: HRV ist schief verteilt. Der z-Wert auf rohen ms bewertet einen Anstieg stärker als einen gleich großen Abfall. Standard ist ln RMSSD [P1][P2]. | W1, N1, P1, P2 | In `wComputeRecovery` (Z. 15420) und `wBaseline` (Z. 15364) für `hrvMs` mit ln(HRV) rechnen: Median und MAD von ln-Werten, zH = (ln HRV − Median)/SD. Danach Gewichte neu eichen. |
| 4 | Schlafleistung | behalten | A: WHOOP: Bedarf erreicht plus Konsistenz/Effizienz [W1]. Gewichte = eigene Eichung (7 Punkte Abweichung). | W1 | Keine Änderung. |
| 5 | Schlafkonsistenz | behalten, kennzeichnen | Zirkuläre SD ist korrekt. Faktor 35 je Stunde hat keine Quelle. | keine | Im Info-Text „eigene Skala" nennen. |
| 6 | Schlafbedarf, Schuld | behalten | A: WHOOP-Prinzip Grund + Strain + Schuld − Nickerchen. Konstanten 2,85 min und 0,27 = eigene Eichung (6 min Abweichung). Altersnorm 7–9 h (NSF) passt. | W1 | Keine Änderung. |
| 7 | Schlafphasen | korrigieren | A: Wearables überschätzen Leichtschlaf, Phasen sind schwach [C1]. B: Schwellen `WSTG_CUT` (Z. 11312) sind auf die WHOOP-4.0-Anteile des Nutzers gestellt (REM 29 %). Das erzwingt die Verteilung. Minuten wirken genauer als sie sind. | C1 | Phasen-Minuten auf 5 min runden. Hinweis „Schätzung" an das Hypnogramm. Schwellen an der 5.0-Zeit neu prüfen. |
| 7a | Schlafdauer, Effizienz, Latenz | behalten | A: van Hees 2018 (HDCZA) ist veröffentlicht. Wach-Erkennung bleibt die Schwäche aller Wearables [C1]. | C1 | Keine Änderung. |
| 8 | Ruhepuls | behalten | A: WHOOP misst im Schlaf [W1]. Gültigkeit 30–85 bpm schützt vor Ausreißern. | W1 | Keine Änderung. |
| 9 | HRV, SDNN | behalten | A: RR-Korrektur nach Lipponen & Tarvainen 2019. WHOOP misst HRV im Schlaf [W1]. B: Ganzzahl in ms ist ausreichend. | W1 | Keine Änderung. |
| 10 | Atemfrequenz | behalten | A: RSA + RIIV, Fusion nach Karlen 2013 (Code-Kommentar). Kommentar Z. 11102 sagt „nur Gen4". Ob der Wert am 5.0 entsteht, konnte ich nicht prüfen. | keine geprüft | Kommentar Z. 11102 an die 5.0 anpassen oder Wert am 5.0 ausblenden. |
| 11 | Hauttemperatur | behalten | A: Anzeige als Abweichung vom eigenen Normalwert, wie WHOOP. | N1 | Keine Änderung. |
| 12 | Strain Tag | behalten | A: Banister-TRIMP mit 0,64/1,92 und 0,86/1,67 wie NOOP [N1]. Log-Skala 0–21 wie WHOOP [W2]. Abbildung 5,086·ln(1 + T/5,98) = eigene Eichung (1,1 Punkte). Schwelle 40 % HFR = eigene Eichung. WHOOP zählt auch Muskel-Last [W2]; die fehlt. | W2, N1 | Keine Änderung. Info-Text: „ohne Muskel-Last". |
| 12a | Strain ohne Band (Z. 15496) | behalten, kennzeichnen | Sätze/26 × 7 und kcal/900 × 11: keine Quelle. | keine | Als „grobe Schätzung" anzeigen. |
| 13 | VO₂max | korrigieren | A: Uth 15,3 gilt laut Studie nur für gut trainierte Männer [U1]; die App nutzt 15,3 auch für Frauen (Z. 10611). Jurca-Koeffizienten stimmen [J1]. ACSM-Laufgleichung gilt erst ab ~8 km/h; `wVo2FromRuns` (Z. 12601) prüft das nicht. Der Lauf-Puls ist das Mittel inkl. Aufwärmen. B: Anzeige mit einer Nachkommastelle bei ±10–15 % Fehler. Normtabelle (Cooper/Heyward) stimmt mit den Werten überein. | U1, J1 | In `wVo2FromRuns` Läufe unter 8 km/h verwerfen. Für Frauen und ohne Läufe nur Jurca nutzen oder Uth als „nur für trainierte Männer belegt" kennzeichnen. VO₂max als ganze Zahl anzeigen. |
| 13a | Zweites Fitness-Alter `vo2FitAge` (Z. 12646) | entfernen | B: Die App zeigt zwei verschiedene Fitness-Alter (VO₂max-Kachel und `agingOrb`). Beide heißen gleich und widersprechen sich. `_vo2Thr` begrenzt das Alter auf 25–65, also ist der Wert unter 25 und über 65 flach. | keine | `vo2FitAge` und die Anzeige „Fitness-Alter" in `vo2Tile` und `openVo2` streichen. Nur `fitnessAgeAt` behalten. |
| 14 | Fitness-Alter (HUNT) | korrigieren | A: Koeffizienten 0,155/0,226/0,296 und 0,114/0,198/0,247 stimmen mit Nes 2011 und NOOP [H1][N2]. B: Häufigkeit: 1 aktiver Tag ergibt 0,5 („seltener als 1×/Woche"), 2 Tage ergeben 1 („1×/Woche"). 1 Tag ist aber „1×/Woche", 2 Tage sind „2–3×/Woche". NOOP hat denselben Versatz [N2]. Die HUNT-Fragebogen-Kodierung selbst konnte ich nicht im Volltext prüfen. Intensitäts-Grenzen 15 %/50 % haben keine Quelle. | H1, N2 | In `fitnessAgeAt` (Z. 3503): `freq = n<1?0 : n===1?1 : n<=5?2.5 : 5` (1 Tag → 1; 2–5 → 2,5; 6–7 → 5). Vorher die Originalkodierung im HUNT-Fragebogen prüfen. |
| 14a | „Pace of Aging" | behalten | Nur Differenz zweier Werte mit ±5 J Fehler. | H1 | Erst ab einer Änderung ≥ 1 J anzeigen. |
| 15 | Zonen, Zone 2 | behalten | A: Karvonen ist Standard. NOOP nutzt % vom Maxpuls [N1]. Zone 2 = 60–70 % HFR ist eine Näherung an LT1, keine Messung. | N1 | Keine Änderung. |
| 16 | Trainings-Score | behalten, kennzeichnen | Gewichte 40/25/20/15 ohne Quelle. | keine | Keine Änderung. |
| 17 | Kalorien Band | korrigieren | A: Keytel-Koeffizienten und Einheit kJ → kcal stimmen [K1]. Keytel ist nur für Belastung geeicht (35–80 % VO₂max) [K1]. B: Unter 40 % HFR zählt nur der Grundumsatz. Alltagsbewegung und Thermogenese fehlen. Der Tageswert liegt deshalb zu tief. B: Zwei Formeln für den Grundumsatz (Harris-Benedict im Band, Mifflin im Ziel). | K1 | In `wDayKcal` (Z. 11649) unter der Schwelle Grundumsatz × 1,2 statt × 1,0 rechnen oder den Wert „aktive kcal" nennen. Eine Grundumsatz-Formel für beide Pfade (Mifflin). |
| 18 | Schritte | behalten | Eichung gegen das iPhone ist datengetrieben. Für den 4.0-Pfad (Bewegungsmenge) gibt es keine Quelle; das Gerät ist ausgemustert. | keine | 4.0-Zweig `moveHr` später entfernen. |
| 19 | SpO₂ | korrigieren | A: Handgelenk-SpO₂ irrt um 2–3,4 % RMSE [S1]. B: Die App zeigt eine Nachkommastelle (Z. 8730, 12480). Das Band liefert ganze Prozent. | S1 | In `wFinalizeDay0` (Z. 12480) `Math.round(med(wm))` statt `r1`. In `_fmtU` (Z. 8731) `%O` ohne Nachkommastelle. |
| 20 | Tagesstress | behalten, kennzeichnen | A: WHOOP Stress 0–3 aus Puls und HRV gegen Basis (WHOOP-Seite nicht abgerufen). Skalen 20 % HFR und ln 3 haben keine Quelle. | keine | Info-Text: „eigene Skala". |
| 21 | Krankheits-Warnung | behalten | A: Schwellen und Fenster gleich NOOP `evaluateIllness` [N1]. Hinweis erst ab 2 Signalen, kein Befund. | N1 | Keine Änderung. |
| 22 | Energiekurve | behalten, kennzeichnen | A: Drei-Prozess-Modell, Konstanten 2,4 / 14,3 / 0,0353 / 2,5 / 16,8 / −5,72 / −1,51 stimmen mit Åkerstedt & Folkard (Literatur, Link nicht abgerufen). B: Niveau-Zuschläge (Erholung, Ernährung, Koffein 1,7) ohne Quelle. Prozent wirkt wie ein Messwert. | keine abgerufen | Info-Text: „Modell, kein Messwert". |
| 23 | Basics | behalten, kennzeichnen | Gewichte heißen „nach Evidenzstärke", aber ohne Quelle. Cardio-Ziel 175 min liegt in der WHO-Spanne 150–300 min. | keine | Info-Text: Gewichte sind eigene Einschätzung. |
| 24 | Ernährung, Supplements | behalten, kennzeichnen | Gewichte und Abzüge (Samenöl, Lektine) ohne Quelle. Kreatin-Deckel ist eine persönliche Regel. | keine | Keine Änderung. |
| 25 | EKG | behalten | Nur Rohkurve, keine Diagnose. Das ist korrekt, weil mV-Skala und Abtastrate unbelegt sind. | keine | Keine Änderung. |
| 26 | Blutdruck | korrigieren | A: ESC 2024: erhöht = 120–139 / 70–89 (Praxis); Hypertonie zu Hause ab 135/85 [E1][E2]. B: `BP_CLASSES` setzt „kritisch" erst ab 136/86. 135/85 gilt dann als „erhöht", obwohl es laut ESC zu Hause schon Hypertonie ist. B: Diastolisch 70–79 gilt als „Ziel", laut ESC schon „erhöht". B: Die Erholungsliste (Z. 3288) nutzt andere Grenzen (> 135/85, ≥ 130/80). Zwei Ampeln für denselben Wert. | E1, E2 | `BP_CLASSES`: `{n:'erhöht',s:120,d:70}`, `{n:'Hypertonie',s:135,d:85}`, `{n:'sehr hoch',s:180,d:110}`. Erholungsliste über `bpClass` färben. |
| 27 | Blutwerte | korrigieren | B: Die eingegebene Einheit wird nie umgerechnet. `bloodByMarker` (Z. 1413) speichert `unit`, aber `refStatus` (Z. 1426) vergleicht den Rohwert mit dem Bereich der Referenz-Einheit. Testosteron 20 nmol/l gegen 500–900 ng/dl ergibt „niedrig". `freeTestoLatest` (Z. 4473) prüft die Einheit der Referenz statt der Eingabe; ein Wert in nmol/l wird mit 0,0347 multipliziert. A: NT-proBNP obere Grenze 50 pg/ml; ESC nutzt 125 pg/ml [B1]. eGFR über 130 gilt als „hoch", ist aber kein Befund. Die übrigen Bereiche sind „Optimalbereiche" aus einem Bodybuilding-Guide, keine Laborgrenzen. B: `matchRef` sucht Teilstrings: „ast" oder „alt" können in anderen Namen treffen. | B1 | Einheiten-Tabelle je Marker (z. B. Testosteron nmol/l × 28,84 = ng/dl, Glukose mmol/l × 18 = mg/dl, LDL mmol/l × 38,67 = mg/dl). In `bloodByMarker` vor `refStatus` umrechnen; unbekannte Einheit: Status „Einheit prüfen". In `freeTestoLatest` die Einheit des Eintrags prüfen. NT-proBNP `hi:125`. eGFR ohne obere Grenze. `matchRef` an Wortgrenzen. Bereiche als „Guide-Optimum" beschriften. |
| 27a | Freies Testosteron | behalten | A: Vermeulen 1999, Kt 1e9, Ka 3,6e4 (Code-Selbsttest I-Zeile Z. 13874). Wert hängt am Fehler aus Nr. 27. | keine abgerufen | Nach der Einheiten-Korrektur keine Änderung. |
| 27b | Stack | behalten | Nur Logbuch und Termine. Keine Dosis-Empfehlung. | keine | Keine Änderung. |

### WHOOP 4.0 (ausgemustert)
- `wparseR24` (Z. 10338), `_WHR_OFF` (Z. 10337): Records des 4.0.
- `WACF1_FLOOR` (Z. 10589): Kommentar sagt „gen5/MG fällt durch". Damit kann am 5.0 jedes HRV-Fenster als Artefakt gelten. Ich habe nicht geprüft, ob der Wert nur für 4.0 gilt.
- `WSTG_CUT` (Z. 11312): auf 4.0-Nächte gestellt.
- Schritte über `moveHr`: nur 4.0.
- Basislinie aus 4.0-Exporttagen (Z. 9866): Startwerte vor eigenen 5.0-Nächten.

## Rangliste der Befunde (gefährlichster falscher Gesundheitswert zuerst)

1. **Blutwerte ohne Einheiten-Umrechnung** — `refStatus` Z. 1426, `bloodByMarker` Z. 1413, `freeTestoLatest` Z. 4473. Falsches „niedrig"/„hoch" und falsches freies Testosteron. Das kann zu falschen Entscheidungen unter TRT führen.
2. **Blutdruck-Grenzen** — `BP_CLASSES` Z. 8088, `bpClass` Z. 8093, Erholungsliste Z. 3288. 135/85 zu Hause gilt nicht als Hypertonie. 70–79 diastolisch gilt als Ziel. Zwei Ampeln.
3. **Blut-Referenzbereiche** — `BLOODREF` Z. 1317: NT-proBNP 50 statt 125 (Fehlalarm), eGFR > 130 als „hoch", Guide-Optimum ohne Kennzeichnung; `matchRef` Z. 1425 Teilstring-Treffer.
4. **Zwei Fitness-Alter** — `vo2FitAge` Z. 12646 gegen `fitnessAgeAt` Z. 3497. Entfernen.
5. **VO₂max-Schätzung** — `wVo2FromRuns` Z. 12601 (kein 8-km/h-Check), `WUTH_K` Z. 10611 (Uth für Frauen nicht belegt), Anzeige mit Nachkommastelle.
6. **Erholung auf rohen HRV-ms** — `wComputeRecovery` Z. 15406/15420, `wBaseline` Z. 15364. ln RMSSD nutzen.
7. **Kalorien Band zu niedrig** — `wDayKcal` Z. 11649; zwei Grundumsatz-Formeln (Z. 10649 gegen `kcalBreakdown` Z. 3873).
8. **SpO₂ mit falscher Genauigkeit** — Z. 12480, `_fmtU` Z. 8731.
9. **Fitness-Alter Häufigkeits-Stufen** — `fitnessAgeAt` Z. 3503.
10. **Schlafphasen auf alte WHOOP-Anteile gestellt** — `WSTG_CUT` Z. 11312, Anzeige `sleepHypnogram` Z. 3608.
11. **Atlas Overall: totes Gewicht und Schlaf dreifach** — `WEIGHTS` Z. 2450, `USAGE_ITEMS`, `dayActive`, Kommentar Z. 2443.
12. **Atemfrequenz-Kommentar „nur Gen4"** — Z. 11102; `WACF1_FLOOR` Z. 10589 am 5.0 ungeprüft.
