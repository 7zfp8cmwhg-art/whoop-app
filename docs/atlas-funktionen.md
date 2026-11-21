STAND: Teil 1 fertig bis Nr. 14 (Fitness-Alter). Offen: Inventar ab Nr. 15, Phase 2 (Quellen-Prüfung).

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
- Gewichte (`WEIGHTS`, Z. 2448): Schlaf 0,25, Erholung 0,20, Training 0,18, Ernährung 0,17, Basics 0,12, Supplements 0,04, Gesundheit 0,04.
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
