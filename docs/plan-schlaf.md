# Plan Schlaferkennung und Schlafphasen (Atlas One, WHOOP MG)

## STAND
Fertig: 0 (Realfall 25./26.11.), 1 Wissenschaft, 2 Anbieter, 3 Open Source, 4 Quelle der Wahrheit, 5 Lücken im Code, 6 Bauplan, 7 Testfälle. ALLE ABSCHNITTE FERTIG.
Zuständig hier: Erkennung und Phasen. Die Formel der Schlafleistung gehört Agent 5.

## 0. Realfall: erste MG-Nacht 25./26.11.

Angaben der App: Schlaf 5:49 h, 23:48 bis 06:18, Tief 1:07 h, REM 1:25 h, erholsam 2:32 h, HRV 41,4 ms, Ruhepuls 69, Atmung 16,9, SpO2 98 %, Schlafleistung 71.
Angaben des Nutzers: etwa 5 h geschlafen, davon 2:30 h erholsam, Bedarf 8 bis 8,5 h. Die Zahlen "passen nicht zusammen".

### 0.1 Rechenprobe der Erkennung (aus den App-Zahlen)
- Fenster 23:48 bis 06:18 sind 6:30 h. Schlaf 5:49 h. Wach im Fenster: 41 min (11 %). Effizienz 90 %.
- Leicht = 5:49 − 2:32 = 3:17 h. Anteile: Leicht 56 %, Tief 19 %, REM 24 %.
- Diese Anteile liegen fast genau auf dem Vorgabewert im Code: `WSTG3_PRIOR` = Wach 8 / Leicht 52 / Tief 17 / REM 23 (Z. 11914, im Code nur deklariert, nirgends benutzt). Die Schwellen `WSTG_CUT` sind laut Kommentar (Z. 11793) auf 19 % Tief und 29 % REM abgestimmt.
- Folgerung: Die Anteile sind größtenteils das Ergebnis der Eichung, nicht der Messung. Sie sind plausibel, aber nicht beweisend. Der Code selbst nennt kappa 0,132 (Z. 11713).

### 0.2 Ist die Erkennung plausibel?
- Einschlafzeit 23:48: plausibel, wenn der Nutzer gegen 23:30 bis 23:50 im Bett lag. Nicht prüfbar ohne `_slDiag`. Prüfen: `lat` (Latenz), `on`, `off`, `wake` in `whoop._slDiag` ("Diagnose kopieren").
- Differenz 5:49 h gegen "etwa 5 h": 49 min. Mögliche Ursachen, in dieser Reihenfolge:
  1. Der Nutzer unterschätzt. Menschen erinnern Wachzeiten schlecht und schätzen Schlaf im Mittel zu kurz, wenn die Nacht gestört war. Das ist ein bekannter Effekt, aber keine Beweisquelle für diesen Fall.
  2. Ruhige Wachzeit zählt als Schlaf. `wSleepStages3` wertet "wach" nur bei Pulsanstieg ≥ lokaler Median + max(8 bpm, 1,5 SD), bei großer Bewegung mit Pulsanstieg oder bei leichter Unruhe plus +3 bpm (`wk` in `wSleepStages3`, Z. 12054 ff.). Wer ruhig wach liegt, ohne dass der Puls steigt, bleibt "Leicht". Das ist die bekannte Schwäche von Handgelenk-Verfahren: hohe Empfindlichkeit für Schlaf, niedrige Spezifität für Wach (Walch 2019: Wach-Spezifität 59,6 %).
  3. Ruhepuls 69 ist hoch für Schlaf. Das spricht für eine unruhige oder belastete Nacht (spätes Essen, Alkohol, Infekt, Stress) oder für MG-Pulsoffset. Bei hohem, flachem Puls fehlt dem Stager der Kontrast "Pulsanstieg", und Wachphasen werden schlechter erkannt.
- Tiefschlaf 1:07 h bei Ruhepuls 69: Der Stager vergleicht gegen die eigene Nacht (Median, MAD). Tief entsteht also auch in einer Nacht mit hohem Puls. Absolut ist das für einen Schlaf mit RHR 69 fragwürdig. Ein Plausibilitätsfilter fehlt (siehe Abschnitt 6).
- Erholsam 2:32 h = 43 % des Schlafs. Im Normalbereich (Tief + REM etwa 35 bis 45 %), also nicht auffällig, aber durch die Eichung nahezu vorbestimmt.
- Atmung 16,9 und SpO2 98 % sind unauffällig. Sie widersprechen der Erkennung nicht.
- Urteil: Beginn und Ende sind wahrscheinlich richtig (±15 min). Die Wachzeit ist wahrscheinlich zu klein (Schlaf eher 5:15 bis 5:45 h). Die Phasenanteile sind nicht belegt. Genauer kann man ohne die Rohdaten der Nacht nicht urteilen.

### 0.3 Warum 71 "nicht aufgeht" (Beschreibung für Agent 5)
Formel im Code (`wComputeSleepPerf`, docs/berechnungen.md Z. 60): SP = 0,707 · min(Schlaf/Bedarf, 1) · 100 + 0,245 · Konsistenz + 3,4.
- Mit Schlaf 5,82 h und Bedarf 8,25 h: Verhältnis 0,705, Beitrag 49,9.
- Die Konsistenz fehlt in der ersten Nacht. Ersatz laut Doku: `whoopRef.consMed` oder 65. Beitrag 0,245 · 65 = 15,9.
- Summe: 49,9 + 15,9 + 3,4 = 69,2. Mit Konsistenz 75 bis 80 sind es 71 bis 73. Die 71 sind also die Formel, ohne Rechenfehler.
- Der Widerspruch ist inhaltlich: 41 % der Punkte kommen aus Konsistenz plus Konstante, nicht aus Schlaf. Eine Nacht mit 70 % des Bedarfs bekommt so "gut". In der ersten Nacht gibt es keine Konsistenz-Messung, der Ersatzwert 65 belohnt unbekannte Regelmäßigkeit.
- Die Formel kennt weder Effizienz, noch Wachzeit, noch erholsamen Schlaf. Sie sieht nur Dauer, Bedarf und Konsistenz.
- Für Agent 5 zu klären: Konsistenz-Ersatz bei weniger als 4 Nächten weglassen oder Score als "vorläufig" markieren; Konstante 3,4 prüfen; Effizienz und Phasen aufnehmen oder bewusst ausschließen.

### 0.4 Was der Schlaf-Score von der Erkennung braucht
Pflichtfelder je Nacht (Name im Code in Klammern, wenn vorhanden):
1. Bettzeit / Beginn der Ruhezeit (`_slDiag.w0`, bisher nur Fenster, nicht Bettzeit).
2. Einschlafzeit (`bedHour`, `hyp0`) und Aufwachzeit (`wakeHour`, `_slDiag.off`).
3. Zeit im Bett (TIB) und Schlafzeit (TST) (`sleepHours`).
4. Wachzeit nach dem Einschlafen (WASO) (`slAwake`) und Zahl der Wachphasen ≥ 2 min (`slWakes`, heute je Wach-Epoche gezählt).
5. Einschlaflatenz (`slLatency`).
6. Effizienz TST/TIB (`sleepEff`; heute TST/(Aufwachen − Einschlafen), also ohne Latenz).
7. Phasen Leicht/Tief/REM (`slLight/slDeep/slRem`) mit Vertrauen (`_stageConf`).
8. Abdeckung: Anteil gemessener Epochen im Fenster und Löcher (`_slCut`). Ohne sie darf der Score nicht als "voll" gelten.
9. Nachtart: Hauptschlaf, Teilnacht, geteilte Nacht, Nickerchen (neu).

## 1. Wissenschaftlicher Standard

Hinweis zur Quellenlage: Zahlen stammen aus den Suchtreffern. Was nicht bestätigt wurde, steht als "nicht geprüft".

### 1.1 Goldstandard PSG und AASM
- PSG wird in 30-s-Epochen nach AASM gewertet: Wach, N1, N2, N3, REM. Die Atlas-Phasen fassen N1+N2 zu "Leicht" und N3 zu "Tief". Quelle: AASM Scoring Manual (aasm.org), aus Fachwissen, nicht neu abgerufen.
- Gleiche Epochenlänge (30 s) wie das Band. Das ist der Grund, warum der Bandtakt für die Phasen passt.

### 1.2 Aktigrafie (Wach/Schlaf aus Bewegung)
- Cole-Kripke und Sadeh haben hohe Schlaf-Sensitivität (0,82 bis 0,96) und niedrige Wach-Spezifität (0,35 bis 0,68). Quelle: https://pmc.ncbi.nlm.nih.gov/articles/PMC5779275 (Vergleich an GT3X+; belegt das Muster "Wach wird als Schlaf gezählt").
- In einer Studie mit 1.440 älteren Erwachsenen lagen alle Algorithmen bei 78 bis 80 % Genauigkeit. Quelle: https://www.ncbi.nlm.nih.gov/pmc/articles/PMC12697920/ (zeigt die Obergrenze reiner Bewegung).
- van Hees 2018 (HDCZA, GGIR) bestimmt nur das Schlaffenster (SPT), nicht Schlaf/Wach. Beginn r = 0,78 (Fehler 39,9 min), Ende r = 0,81 (29,9 min) gegen Tagebuch. Quelle: https://pmc.ncbi.nlm.nih.gov/articles/PMC6113241 (genau das Verfahren in `wSleepWindow`). Folge: Das Fenster ist auf etwa ±30 bis 40 min genau, nicht auf Minuten.

### 1.3 Puls und HRV, Vier-Phasen-Einstufung
- Walch 2019 (Apple Watch, 31 Personen): Schlaf/Wach 90 % richtig, Wach-Spezifität 59,6 %; Wach/NREM/REM etwa 72 % mit Bewegung + Puls + Tagesrhythmus. Quelle: https://pmc.ncbi.nlm.nih.gov/articles/PMC6930135 (Vorbild für die "Uhrzeit-Nähe"-Merkmale; PhysioNet-Daten sind offen). Vier Phasen meldet Walch nicht.
- Beattie 2017: Vier Klassen (Wach, Leicht, Tief, REM) mit etwa 69 % Genauigkeit aus Beschleunigung + PPG. Quelle: https://iopscience.iop.org/article/10.1088/1361-6579/aa9047/meta. Kappa 0,52 wurde nicht bestätigt, nicht zitieren.
- Radha, Fonseca et al. 2021: Vier Klassen aus PPG mit Transfer-Lernen: kappa 0,65 ± 0,11, Genauigkeit 76 %. Quelle: https://www.nature.com/articles/s41746-021-00510-8.pdf (Obergrenze mit Deep Learning und Laborlabels).
- Klinische Gruppe (244 Erwachsene): Vier Klassen kappa 0,62, 76,4 %. Quelle: https://pubmed.ncbi.nlm.nih.gov/34234595/.
- PPG ist schwächer als EKG: kappa 0,56 gegen 0,60. Quelle: https://link.springer.com/doi/10.1186/s13104-020-05355-0.
- Altini und Kinnunen 2021 (Oura, 440 Nächte, 106 Personen): Beschleunigung, Temperatur, Puls, HRV und Tagesrhythmus-Modell; Aktigrafie allein kappa etwa 0,5, mit Nervensystem-Merkmalen bis 0,6. Quelle: https://pubmed.ncbi.nlm.nih.gov/34201861/.
- Fazit: Der Bestwert ohne EEG liegt bei kappa 0,6 bis 0,65 mit trainierten Modellen. Handelsgeräte liegen bei kappa 0,2 bis 0,5 (docs-Kommentar im Code, Chinoy 2021).
- Chinoy 2021 (7 Geräte): Alle überschätzen Schlaf (hohe Sensitivität, niedrige Spezifität). Beste Tiefschlaf-Sensitivität 0,56. Einige Geräte überschätzten Tiefschlaf deutlich. Quelle: https://pmc.ncbi.nlm.nih.gov/articles/PMC8120339.
- Miller, Sargent, Roach 2022 (6 Geräte): Mehrphasen-Genauigkeit Oura 61 % (kappa 0,43), Schlaf/Wach 89 % (kappa 0,51). Quelle: https://pubmed.ncbi.nlm.nih.gov/36016077/.
- Per-Phase-Sensitivität (Tief, REM) je Gerät: nur für Chinoy-Spitzenwert bestätigt (0,56). Weitere Werte nicht geprüft.

### 1.4 Folgerung für Atlas
- Ziel ist kappa ≈ 0,4 bis 0,5 mit eigener Eichung, nicht mehr. Der Code meldet 0,132 für den Port.
- Schlaf/Wach und Dauer sind belastbar (±20 min Gesamtschlaf), Phasen sind es nicht. Das muss die Oberfläche zeigen und der Score darf Phasen nicht stark gewichten.
- Wach-Spezifität ist die Schwachstelle jedes Handgelenk-Verfahrens. Genau dort liegt der Realfall (Abschnitt 0.2).

## 2. Wie Anbieter es machen

- WHOOP, Validierung 2020 (12 Erwachsene, 86 Nächte): Vier Phasen 64 % Übereinstimmung, kappa 0,47. Quelle: https://pubmed.ncbi.nlm.nih.gov/32713257/ (Miller et al.; Autor-Jahr in der Aufgabe als "Miller 2022" genannt: 2022 ist die Sechs-Geräte-Studie, 2020 die WHOOP-Studie).
- WHOOP 2021 (6 Erwachsene): Vier Phasen 63 % (automatisch), 62 % (manuelle Zeiten). Quelle: https://mdpi.com/2079-6374/11/6/185.
- WHOOP-Eingaben: Training mit PSG-Daten (CQU, Uni Arizona), neue Merkmale zu Tagesrhythmus und Nervensystem. Keine Zahlen. Quelle: https://www.community.whoop.com/t/whats-new-in-whoops-sleep-staging-algorithm-update/321.md.
- WHOOP-Erkennung: Nach dem Sync sucht WHOOP einen anhaltenden Abfall von Puls und Bewegung. Eine Lücke von etwa 50 min oder mehr beginnt ein neues Ereignis, das oft als Nickerchen läuft. Nickerchen unter etwa 15 bis 60 min werden oft nicht erkannt. Quellen sind Community-Beiträge und keine offizielle Doku: https://www.community.whoop.com/t/auto-detect-naps/7913, https://www.community.whoop.com/t/does-nap-tracking-work-for-you-with-th-5-0/5221.
- Nutzerklagen zu geteilten Nächten: WHOOP zerlegt eine Nacht in "Schlaf 1:29 h" und "Nickerchen 6:40 h" nach langem Wachliegen. Folge: niedriger Score. WHOOP hat das nur weitergegeben. Quelle: https://www.community.whoop.com/t/feature-request-recognize-sleep-periods-that-were-interrupted/11560. Lehre: Ein Nickerchen nach Mitternacht darf nicht als "kein Nachtschlaf" zählen. Der Score muss alle Schlafblöcke einer Nacht addieren.
- Apple: Nur Beschleunigung, 30-s-Epochen, vier Klassen (Wach, REM, Kern, Tief), Training an über 1.400 PSG-/EEG-Nächten. Quelle: https://www.apple.com/kr/health/pdf/Estimating_Sleep_Stages_from_Apple_Watch_Oct_2025.pdf. Puls-Anteil: nicht geprüft.
- Oura: Beschleunigung, Temperatur, Puls, HRV, Tagesrhythmus-Modell (Altini 2021, oben). Oura erreicht in 2022 und 2024 die beste Übereinstimmung unter Handelsgeräten. Quellen: https://pubmed.ncbi.nlm.nih.gov/36016077/, https://pubmed.ncbi.nlm.nih.gov/39460013/ (Fitbit überschätzt Leicht um 18 min, unterschätzt Tief um 15 min).
- Garmin, Polar, Fitbit im Einzelnen: nicht neu recherchiert. Bekannt aus Fachwissen und nicht belegt: Alle nutzen Bewegung + Puls (+ HRV) und ein trainiertes Modell; Eingabe von Bettzeit ist bei Garmin und Fitbit nicht nötig.
- Gemeinsames Muster aller Anbieter: (1) Zeitfenster zuerst aus Bewegung und Puls, (2) Phasen nur innerhalb des Fensters, (3) Nickerchen als eigene kurze Ereignisse mit Mindestdauer, (4) Training an PSG-Labels. Atlas macht (1) bis (3), aber (4) fehlt: Es gibt keine Labels für MG.

## 3. Offene Nachbauten ohne Abo

Quelle der Angaben unten: `SleepStager.swift` im Repo ryanbr/noop (Paket `StrandAnalytics`), https://raw.githubusercontent.com/ryanbr/noop/main/Packages/StrandAnalytics/Sources/StrandAnalytics/SleepStager.swift. Gelesen wurde die erste Hälfte (Erkennung) und der V1-Stager. `SleepStagerV2` war nicht im gelesenen Ausschnitt. OpenVitals (sourcetms) und wearable5.0 wurden nicht gefunden oder nicht gelesen: Die Suche lieferte kein Repo mit diesen Namen. OpenStrap/edge (Flutter, Gen4 und experimentell Gen5) wurde nur über Release-Notizen gesehen: https://newreleases.io/project/github/OpenStrap/edge/release/v0.9.25-whoop5-experimental.

### 3.1 NOOP: Erkennung (`detectSleepUncached`)
| Größe | Wert | Sinn |
|---|---|---|
| `gravityStillThresholdG` | 0,01 g | Epoche still |
| `stillWindowMin` / `stillFraction` | 15 min / 0,70 | gleitendes Ruhefenster |
| `maxGapMin` | 20 min | Lücke trennt einen Lauf |
| `mergeMin` | 15 min | kürzere Läufe werden an Nachbarn gehängt |
| `minSleepMin` | 60 min | kürzeste Sitzung |
| `daytimeBandStartHour`/`EndHour` | 11 / 20 | Tagesband |
| `daytimeMinSleepMin` | 90 min | kürzestes Nickerchen am Tag |
| `daytimeRestingHRMult` | 0,95 | Puls am Tag unter 95 % der Basis |
| `nightContinuationGapMin` | 90 min | Nachtfortsetzung ohne Nickerchen-Prüfung |
| `morningStillnessWindowMin` | 180 min | Morgen-Wiedereinschlafen |
| `morningReonsetRestingHRMult` | 0,90 | strengere Pulsschwelle |
| `maxMainSleepSpanS` | 16 h | längere Spannen werden verworfen |
| `hrSleepBaselineMult` | 1,05 | Schlafband = Basis · 1,05 |
| `sparseBridgeGapMin` | 90 min | Lücke, die zwischen Schlafläufen überbrückt wird |
| `sparseBridgeActiveMaxMin` | 30 min (60 min bei Puls im Band) | ein aktiver Lauf in der Brücke |
| `offWristHRGapMin` / `maxOffWristSleepFraction` | 20 min / 0,5 | Pulslücke = abgelegt; Lauf fällt weg bei ≥ 50 % |
| `hrOnlyEpochS` / `hrOnlyAnchorPercentile` | 60 s / p10 | Erkennung nur aus Puls, wenn Bewegung fehlt |

Lehren:
- NOOP hat einen Rückfallweg "nur Puls", wenn die Bewegung dünn ist (`isGravitySparse`, `hrOnlySleepRuns`). Atlas bricht in dem Fall ab (`need_motion`, `no_sleep_window`).
- NOOP überbrückt Lücken bis 90 min und einen aktiven Lauf bis 30 bis 60 min, wenn der Puls im Schlafband bleibt. Atlas überbrückt nur bis 60 min und prüft den Puls erst ab Lücken > 45 min.
- NOOP hat Wächter gegen falsche Tag-Nickerchen: 90 min Mindestdauer, Puls < 95 % der Basis, Fenster 11 bis 20 Uhr. Atlas: 20 min, Puls ≤ Ruhepuls + 8.
- NOOP behandelt "abgelegt" als Pulslücke ≥ 20 min. Atlas hat keinen Abgelegt-Test im Schlaffenster.

### 3.2 NOOP: Schlafzustand des Bands
- NOOP liest den vom Band gespeicherten `sleep_state` (Wert 2 = Schlaf). Er dient an zwei Stellen: (1) Bestätigung eines Morgen-Wiedereinschlafens bei ≥ 60 % Epochen mit Zustand "Schlaf" (`morningReonsetBandAsleepFrac` 0,6); (2) "Wach-Veto": innere Wach-Epochen, die das Band als Schlaf wertet, werden zu Leicht (`applyBandStateWakeVeto`).
- Das Veto ist in NOOP aus (`bandStateWakeVetoEnabled = false`). Das ist ein Hinweis, dass das Band-Byte als Wach-Beleg nicht verlässlich genug war. Grund steht nicht im gelesenen Ausschnitt.
- Atlas liest dasselbe Byte (`inner[73]>>4 & 3`, Z. 10743: 0 wach, 1 ruhig, 2 Schlaf, 3 auf) und wertet es nirgends aus.

### 3.3 NOOP: Phasen (V1 `stageSession`)
- Epoche 30 s. Wach/Schlaf per Cole-Kripke auf Schwerkraft-Änderung (Teiler `ckCountDivisor`, Gewichte `ckWeights`, Schlaf wenn Summe < 1,0). Beginn = erste Folge von `onsetPersistEpochs` (Konstante dort 3) Schlaf-Epochen; Ende = letzte Schlaf-Epoche.
- Merkmale: Puls, Puls-Streuung (Differenz zweier Gauß-Filter 120 s / 600 s), RMSSD und SDNN (nur ab 5 Schlägen), Atemfrequenz und -variabilität, Bewegungsanteil, Zeit seit Beginn (0 bis 1).
- Reihenfolge: (1) Wach = Bewegung und (Pulsanstieg oder kein Puls). (2) Tief = still, RMSSD hoch oder fehlt, Puls niedrig (Perzentil 25), Atmung nicht unregelmäßig. (3) REM = still, Pulsaktivierung, Atmung unregelmäßig. (4) Rückfall REM = still, Puls und Pulsstreuung hoch, Atmung fehlt. (5) sonst Leicht.
- Perzentil-Grenzen: Puls niedrig 25, hoch 70; HRV hoch 70; Pulsstreuung hoch 65; Atemvariabilität hoch 65, niedrig 50. Bewegung: Wach ≥ 0,15, still ≤ 0,10 Anteil.
- Nachbehandlung: Mehrheitsfilter über 5 Epochen; kein REM in den ersten 15 min; später Tiefschlaf (nach dem ersten Drittel) wird Leicht, wenn es auch Tief im ersten Drittel gibt; Läufe < 3 min (6 Epochen) werden mit dem Nachbarn verschmolzen; Zeit vor Beginn und nach Ende = Wach.
- NOOP hat keine eigene Mindestdauer für Wachphasen außer dem Verschmelzen < 3 min. NOOP nennt Leicht/Tief als schwächstes Glied.
- Vergleich: Atlas hat bessere Merkmale (RMSSD, LF/HF, Viterbi) und die gleiche 15-min-REM-Regel. NOOP hat dazu die Verschmelzung kurzer Splitter und die Regel "Tief im ersten Drittel", beides fehlt in Atlas.

### 3.4 Was Nutzer von MG berichten
- "Whoop MG - More awake time": Einige sehen viel mehr Wachzeit (nie unter 2 h), andere unter 20 min bei unruhiger Nacht, andere deutlich weniger Schlaf als bei AutoSleep. WHOOP: Der Algorithmus wurde vor dem 5.0-Start geändert; Support bittet um Daten. Quelle: https://community.whoop.com/t/whoop-mg-more-awake-time/2541. Folge: Auch WHOOP selbst trifft die Wachzeit schlecht. Atlas muss Wachzeit als Spanne zeigen.
- Datenabriss im Schlaf: "Whoop 5.0 stopped tracking my sleep halfway through the night" (Puls brach um 4 Uhr ab, Score wurde nicht berechnet). Keine Ursache genannt. Quelle: https://www.community.whoop.com/t/whoop-5-0-stopped-tracking-my-sleep-halfway-through-the-night/8851. Das ist derselbe Fehlerfall wie die echte Nacht mit etwa 1 h erfasstem Schlaf.
- Zu frühe Erkennung am Bizepsband: https://www.community.whoop.com/t/whoop-5-0-bicep-band-detecting-sleep-too-early/14646 (Titel, nicht gelesen).

## 4. Quelle der Wahrheit und beste Methode mit MG-Daten

### 4.1 Was das Band liefert
- Puls 1 Hz, Schlagintervalle (RR) aus PPG mit Zeitrauschen (MG-Hinweis im Code), Beschleunigung 3 Achsen, SpO2 etwa alle 20 min im Schlaf, Hauttemperatur, Schritte, Aktivitätsbyte und ein Schlafzustand des Bands (`sleepState` 0 bis 3, Z. 10743).
- Nachtdaten kommen in 30-s-Epochen (`nightEpochs`, Z. 11501) mit `hr`, `rr`, `msd`/`enmo`, `za` (Winkel je Sekunde).
- Das Band hat bis etwa 14 Tage Flash. Fehlende Teile können später nachgeladen werden (docs/recherche-mg.md Q1). Eine Nacht ist darum erst nach dem letzten Abruf endgültig.

### 4.2 Es gibt keine Wahrheit für Phasen
- Es gibt keine PSG-Labels für diese Nutzerin/diesen Nutzer. Jede Phasenzahl ist Schätzung (kappa ≈ 0,1 bis 0,5).
- Wahrheit gibt es nur für: Bandsensoren (Puls, Bewegung), Zeiten der Daten (Lücken), und das, was der Nutzer meldet (Bettzeit, Aufstehen).
- Konsequenz: Die Methode muss Zeit und Dauer robust liefern und Phasen ehrlich als Schätzung. Genauigkeit der Dauer ist wichtiger als die der Phasen, weil die Schlafleistung nur die Dauer nutzt.

### 4.3 Empfohlene Methode (Schicht für Schicht)
1. Ebene A, Ruhefenster (SPT) wie heute: HDCZA aus Winkel (`wSleepWindow`), Rückfall Unruhe. Behalten, weil belegt (van Hees 2018). Neu: mehrere Fenster pro Nacht zulassen, nicht nur den längsten Block.
2. Ebene B, Schlaf/Wach je Epoche: Kombination aus (a) Bewegung (Cole-Kripke-artig, geglättet), (b) Puls gegen lokalen Schlafmedian (wie heute), (c) Band-`sleepState` als zusätzlicher Beleg, nicht als Entscheider. Begründung: NOOP nutzt das Byte, schaltet das Wach-Veto aber ab; Wert ist unklar, also zuerst nur messen (Abschnitt 6.8).
3. Ebene C, Wachphasen: Wach zählt erst ab zwei zusammenhängenden Wach-Epochen (≥ 60 s). Eine Wachphase als Störung zählt ab 2 min (Wert in der Aktigrafie-Praxis üblich: Wach ≥ 5 min trennt Aufwachen; nicht geprüft). Kurze Splitter < 3 min werden mit dem Nachbarn verschmolzen (NOOP).
4. Ebene D, Phasen: Behalten der Merkmale und des Viterbi (`wSleepStages3`). Neu: Zeit-Prior mit Schlafzyklen (Tief vorn, REM hinten), Verschmelzen von Splittern, Plausibilitätsfilter (Tief nur bei Puls unter lokalem Median − x), und die Eichung nicht auf feste Anteile, sondern auf die Quantile der eigenen Nacht beschränken.
5. Ebene E, Löcher: Messlücken nie als Schlaf und nie als Wach zählen. Sie ziehen die Abdeckung ab (Abschnitt 6.5).
6. Ebene F, Nickerchen und geteilte Nacht: [Review: an 6.2/6.6 angeglichen] Ruheblöcke ≥ 30 min (Nacht) bzw. ≥ 20 min (Nickerchen) der Nacht (Vortag 12:00 bis 12:00) werden eigene Schlafsitzungen. Hauptschlaf = Block mit dem meisten gemessenen Schlaf. Regel für weitere Blöcke steht in 6.2 Nr. 3.

### 4.4 Warum diese Methode
- Sie bleibt bei den belegten Teilen (HDCZA, Puls gegen lokales Niveau) und behebt die zwei größten Fehlerarten: verlorener Schlaf nach Datenlücke und unterschätzte Wachzeit.
- Sie braucht keine Labels, kein Training und keine neuen Sensoren.
- Sie lässt sich ohne PSG prüfen: durch Testfälle mit gebauten Nächten (Abschnitt 7) und mit der Diagnose einer echten Nacht.
- Ein trainiertes Modell (Walch/Oura-Art) wäre besser, aber es gibt keine MG-PSG-Daten. Nicht empfohlen vor Phase 8.

## 5. Lücken und Fehler im aktuellen Code

Zeilen aus index.html, Stand 26.11. Gewichtung: K = kritisch (falsche oder fehlende Nacht), H = hoch, M = mittel.

| Nr | Stufe | Stelle | Befund | Folge |
|---|---|---|---|---|
| L1 | K | `_wSptPick` Z. 11157 (Ende: `best`), Aufrufer `wSleepWindow` Z. 11231, `wSleepWindowEnmo` Z. 11265 | Es gibt nur **ein** Fenster je Nacht: den längsten Block. Blöcke werden nur über Lücken ≤ 60 min (`maxGap` 120 Epochen) verbunden; Lücke ohne Epochen > 10 min teilt (`DG=20`, Z. 11173). Nach einem Datenabriss > 60 min bleibt der längere Teil, der andere Teil geht verloren. | Echter Fehlerfall: nur etwa 1 h Schlaf nach Datenabriss. Die Nacht hat zwei Teile, ein Teil ist 1 h lang, der andere fehlt oder wird als "Teilnacht" gestrichen. |
| L2 | K | `wFinalizeDay0` Z. 12685 ff., `part` ~Z. 12830 | Bei Loch, Rand-Schnitt oder Löchern im Schlaf wird `sleepHours` nicht gesetzt (nur `_slPartH`). Schlafleistung fehlt, Schlafschuld überspringt die Nacht. Gut für Ehrlichkeit, schlecht für Nutzbarkeit: Es gibt keine Untergrenze "mindestens X h gemessen". | Nacht mit 1 h Messung zeigt entweder nichts oder (bei anderem Pfad) einen falsch kleinen Wert als volle Nacht. Beides ist ein Fehler. |
| L3 | H | `wSleepWindow` Z. 11251, `wSleepWindowEnmo` Z. 11294 | Fenster < 120 Epochen (1 h) oder < 120 gemessene Epochen wird verworfen. Ein Schlaf von 1 h nach Abriss fällt durch (`no_sleep_window`). | Teilnacht < 1 h wird nicht erkannt, `_slNote='kein_schlaf'`. |
| L4 | H | `wSleepWindow` Z. 11257, `wSleepWindowEnmo` Z. 11301 | `hr_not_depressed`: Ist der mittlere Puls im Fenster ≥ Puls außerhalb, wird die **ganze Nacht** verworfen. Bei einer Nacht mit hohem Puls (Realfall: Ruhepuls 69) oder wenn "außerhalb" nur ein ruhiger Abend ist, kippt das. | Nacht ohne Ergebnis, ohne Rückfall. |
| L5 | H | `wSleepStages3` Z. 11987, `wk` Z. 12054 ff. | Wach nur bei Pulsanstieg ≥ lokal + max(8 bpm, 1,5 SD), großer Bewegung mit +3 bpm oder Unruhe mit +3 bpm. Ruhiges Wachliegen mit Schlafpuls ist unsichtbar. Das ist die Wach-Spezifitätslücke aller Handgelenkverfahren (Walch 2019: 59,6 %). | Wachzeit zu klein, Schlaf zu groß, Effizienz zu hoch (Realfall 0.2). |
| L6 | H | `WSTG_CUT` Z. 11793, `WSTG3_PRIOR` Z. 11914 | Schwellen sind auf feste Anteile (Tief 19 %, REM 29 %) geeicht, an zwei Nächten. `WSTG3_PRIOR` ist deklariert und ungenutzt. Die Phasenanteile sind darum fast unabhängig von der Nacht. | Phasen wirken plausibel, belegen nichts. Der Code nennt selbst kappa 0,132 (Z. 11713). |
| L7 | H | `sleepState` Z. 10743, 10752 | Das Byte wird gelesen und von keiner Stelle benutzt. Nicht in Epochen übernommen. | Verschenkter Beleg für Beginn, Ende, Wach und Abgelegt. |
| L8 | M | `wSleepSummary` Z. 11961, `MIN=10`; Zählung Z. 11970 | Beginn = erste Folge von 10 Nicht-Wach-Epochen (5 min), Ende = letzte solche Folge. `wakes` zählt jede Wach-Epoche-Folge, auch 30 s lang. Keine Mindestdauer für eine Störung. | `slWakes` ist aufgebläht oder nicht vergleichbar mit WHOOP. Kurze Mikrowachen zählen mit. |
| L9 | M | `wSleepSummary` Z. 11970 ff. | Effizienz = Schlaf/(Aufwachen − Einschlafen). Die Zeit im Bett vor dem Einschlafen (Latenz) fehlt im Nenner. Die Schlafleistung von WHOOP-Art nutzt die Zeit im Bett. | Effizienz zu hoch. |
| L10 | M | `wDetectNaps` Z. 12365, Aufruf Z. 13029 | Nickerchen nur nach dem Aufwachen + 30 min bis 21 Uhr, nur mit Ruhepuls (> 0), Winkelbereich < 5° je Epoche und `hr ≤ rhr + 8`, ≥ 20 min. Kein Schlaf nach Mitternacht außerhalb des Hauptfensters, keine Phasen, keine Zählung für Teile der Nacht. NOOP braucht am Tag 90 min und Puls < 95 % der Basis. | Zweiter Schlafblock der Nacht wird weder gezählt noch als Nickerchen erkannt. Ruhiges Sitzen kann als Nickerchen zählen (Puls ≤ Ruhepuls + 8 ist großzügig). |
| L11 | M | `nightEpochs` Z. 11501 | Festes Fenster Vortag 12:00 bis 12:00. Schichtarbeit, Nachtschlaf ab 11:30 oder Schlaf nach 12:00 am Folgetag werden abgeschnitten. Nickerchen vor 12:00 des Folgetages zählt zur Nacht. | Spätes Aufwachen (> 12:00) wird falsch. |
| L12 | M | `WTRANS` Z. 11915 | Feste Übergangsmatrix ohne Schlafzyklus-Prior. Wach hält 0,90 je Epoche, Tief → REM 0. Keine Zeitabhängigkeit außer `WSTG2_NIGHT_W` (0,28). | Zyklen sind nicht erzwungen. Kein Tiefschlaf-Prior "ersten Drittel", kein REM-Wachstum zur Morgenseite. |
| L13 | M | `_wOnsetLike` Z. 11951 | "Still bei Schlafpuls" zählt für die Suche nach dem Einschlafen mit. Diese Epochen bleiben Wach, verschieben aber den Beginn nach vorn. | Beginn kann zu früh liegen (um bis zu die Dauer dieser Ruhe). Prüfen am Realfall: `lat`. |
| L14 | M | `wFinalizeDay0` Z. 12690 ff. (`doNight`) | Neu gerechnet wird nur bei ≥ 95 % der Epochen der letzten Rechnung. Wird eine Nacht erst mit dem späteren Abruf vollständig (Backfill), gilt das als "mehr" und wird gerechnet; mit weniger nicht. Eine zu früh gerechnete Teilnacht kann bleiben, wenn der spätere Abruf nicht mehr Epochen bringt. | Prüfen am Fehlerfall "1 h nach Abriss": Kamen Daten später nach? `_nightEp` und `_skipN` lesen. |

### 5.1 Vermutete Ursache des Falls "nur etwa 1 h erfasst"
Nicht belegt, weil die Rohdaten der Nacht nicht vorliegen. Reihenfolge der Wahrscheinlichkeit:
1. Datenabriss > 60 min mitten in der Nacht: `_wSptPick` verbindet nicht, nimmt den längsten Block (L1). Ist er nur etwa 1 h lang, steht 1 h.
2. Das Band sendet nach dem Abriss nur dünn (alle 55 min eine Epoche, siehe Kommentar Z. 11173). Die Dichte-Regeln (`cov`, `DG`) lassen sie nicht als Ruhe gelten.
3. Die Nacht wurde zu früh gerechnet, ohne Backfill (L14).
Prüfen: in der Diagnose `_slDiag.w0/w1/ep/hr`, `_slNote`, `_slCut`, und die Epochen je Stunde. Danach L1 beheben, dann erst Parameter ändern.

## 6. Bauplan

Reihenfolge der Arbeit: 6.1 → 6.5 → 6.2 → 6.3 → 6.4 → 6.6 → 6.7 → 6.8. Jeder Schritt einzeln bauen, Selbsttest laufen lassen (aktuell 295/295), dann weiter.

### 6.1 Epochen-Merkmale (je 30 s, existiert zum Teil)
Behalten: `hr`, `rr`/RMSSD/SDNN, LF/HF, `msd`/`enmo`, `za` (Winkel), `dz` (Winkelsprung).
Neu je Epoche:
- `bs` = Band-Schlafzustand (0 bis 3) aus Byte 73, in die Epoche übernehmen (Aggregator, nicht nur Parser).
- `cov` = Epoche vorhanden (1) oder Loch (0). Dazu `gapBefore` in Sekunden.
- `offw` = abgelegt-Verdacht: kein Puls ≥ 20 min (NOOP `offWristHRGapMin`).
- `hrRel` = Puls minus lokaler Schlafmedian (90 min je Seite, nur ruhige Epochen), bereits intern vorhanden (`hrMedLocal`), nach außen geben.
- `still` = Unruhe ≤ Schwelle (`stillCut`), `big` = große Bewegung (`moveCut` oder `dz` ≥ 20).

### 6.2 Erkennungsregeln: Fenster, Einschlafen, Aufwachen
1. Kandidaten: alle ruhigen Blöcke aus `_wSptPick`-Logik, **ohne** den Rückgabewert auf einen Block zu kürzen. Die Funktion liefert neu eine Liste von Blöcken mit Länge und Dichte.
2. Mindestdauer eines Blocks: 30 min Zeit und ≥ 30 gemessene Epochen (Nachts), 20 min für ein Nickerchen. Das bisherige 1-h-Minimum (L3) gilt nur noch für den Hauptschlaf, nicht für weitere Blöcke.
3. Hauptschlaf = Block mit der größten gemessenen Schlafzeit. Weitere Blöcke derselben Nacht (Vortag 12:00 bis 12:00) gehören zur Nacht (Art "Teil"), wenn der Abstand zum Hauptschlaf ≤ 90 min ist (NOOP `nightContinuationGapMin`), oder wenn er ≤ 3 h ist UND der Puls in der Lücke ≤ Schlafmedian + 10 liegt [3 h und +10 eigene Wahl]. Sonst sind sie Nickerchen. [Review: Vorher stand "oder" zwischen beiden Bedingungen. Damit wäre jeder Block mit ruhigem Puls in der Lücke Teil der Nacht, egal wie weit weg. 4.3 nannte 90 min. Jetzt eine Regel.]
4. Einschlafen = Beginn der ersten Folge von 10 Nicht-Wach-Epochen (5 min, unverändert) **und** Puls ≤ Schlafmedian + 3. Ist `bs` = 2 für ≥ 80 % der 10 Epochen, gilt der Beginn früher als der Beginn aus Bewegung/Puls nicht als bestätigt, sondern nur als Hinweis (Messen, 6.8).
5. Aufwachen = Ende der letzten Folge von 10 Nicht-Wach-Epochen. Folgt danach eine ruhige Phase ≥ 20 min mit Schlafpuls, ist das ein zweiter Block, nicht Verlängerung.
6. Latenz = Zeit von der Bettzeit bis zum Einschlafen. Bettzeit = Ende der letzten anhaltenden Aktivität (≥ 4 von 10 Epochen) bis 90 min zurück (wie heute). Höchstens 90 min. Ist der Beginn abgeschnitten: `null`.

### 6.3 Wachphasen und Störungen
- Eine Wachphase = ≥ 4 aufeinanderfolgende Wach-Epochen (2 min). Kürzere werden zu Leicht verschmolzen; sie zählen nicht als Störung.
- Zusätzlich: Wach-Epochen, die aus "ruhig, Schlafpuls, kein Pulsanstieg, aber Unruhe über `stillCut` und `bs` ≠ 2" entstehen, zählen als **Wach**. Das schließt die Wach-Lücke (L5). Schwelle: ≥ 6 Epochen am Stück (3 min). Messen gegen Realfall (6.8).
- `slWakes` = Zahl der Wachphasen ≥ 2 min. `slAwake` = Summe der Wachphasen ≥ 2 min plus Latenz-Anteil im Fenster. Kurze Splitter bleiben als Hinweis (`slMicro`).
- Wachphasen > 20 min trennen **nicht** die Nacht; sie bleiben im Fenster, solange der Puls ≤ Schlafmedian + 10 bleibt und Ruhe ≥ 4 von 5 Epochen. Sonst Teilung in zwei Blöcke (6.2 Nr. 3).

### 6.4 Phasen
- Merkmale und Viterbi bleiben (`wSleepStages3`).
- Neu: (a) Verschmelzen von Läufen < 3 min mit dem Nachbarn (NOOP: lighter stage wins bei Gleichstand). (b) Tief nur, wenn `hrRel` ≤ 0 und ruhige Epoche; Tief nach 50 % der Nacht nur bei ruhigem Puls (kein hartes Verbot). (c) REM ab 15 min nach Beginn (wie heute). (d) Zeit-Prior mit zwei Zyklen: Tief-Anteil im ersten Drittel × 1,3, im letzten Drittel × 0,6 (Start; Messen).
- Die Eichung `WSTG_CUT` bleibt, aber die Ausgabe trägt eine Warnung, wenn Tief außerhalb 8 bis 28 % oder REM außerhalb 12 bis 32 % des Schlafs liegt ("Anteil unsicher").
- Phasen zeigt die Oberfläche als "Schätzung". In den Score gehen sie nicht ein (heute schon so, `docs` Z. 23). Das bleibt, bis Daten dafür sprechen.
- Phasen-Vertrauen: `_stageConf` (heute niedrig/mittel). Neu "niedrig", wenn Abdeckung < 85 % oder Ruhepuls > 65 oder Rundungsraster.

### 6.5 Messlücken und Teilnächte
- Lücke = Zeit ohne Epochen > 2 min. Lücken zählen nie als Schlaf und nie als Wach.
- Gemessene Schlafzeit je Block = Summe der Schlaf-Epochen. Abdeckung = gemessene Epochen / Epochen der Zeitspanne Beginn–Ende.
- Eine Nacht mit Lücken wird **berechnet**, nicht gestrichen. [Review: korrigiert] Neues Feld `slMeasH` = gemessener Schlaf (h) für jede Nacht. `sleepHours` behält seine Bedeutung: es steht nur bei einer vollen Nacht, das heißt `sleepCover ≥ 0,85` und kein Rand abgeschnitten (`_slNote` nicht `luecke_beginn`/`luecke_ende`). Grund: `sleepHours` speist Schlafleistung, Schlafbedarf, Schlafschuld und die Brücke `dd.sleep.hours`. Die bestehenden Tests I38–I41 und Zeile 15387 ff. verlangen `sleepHours==null` bei Löchern. Dazu `sleepCover` (0 bis 1, `null` wenn ein Rand fehlt) und `_slPartH` bleibt als Alias von `slMeasH` bei Teilnächten.
- Gate für die Schlafleistung: Abdeckung ≥ 0,85 und kein Rand abgeschnitten → voll; 0,5 bis 0,85 → "teilweise" (Anzeige mit Hinweis, Score als Mindestwert aus `slMeasH`); < 0,5, Rand abgeschnitten oder gemessener Schlaf < 3 h → kein Score, aber Dauer anzeigen. Der Score gehört Agent 5; die Schwellen sind ein Vorschlag [eigene Wahl].
- Ruhepuls/HRV: [Review: korrigiert] Eine Regel "≥ 4 h" gibt es im Code nicht. Ruhepuls heute: `wRhrWhoop` = das Kleinere aus Tiefschlaf-gewichtetem Mittel und Median der 2. Schlafhälfte (mind. 60 Epochen), sonst 5-min-Minimum. Neu: beide rechnen nur über Schlaf-Epochen der Blöcke "Haupt" und "Teil", ohne Messlücken und ohne Nickerchen (Schnittstelle S1/S2 in docs/plan-review.md). Teilnächte (`luecke_*`) bleiben aus allen Basislinien draußen.
- Backfill: Nacht erst als endgültig markieren, wenn der letzte Abruf nach 12:00 Folgetag lief oder zwei Abrufe keine neuen Epochen brachten (`_nFinal`). Sonst Neuberechnung bei jedem Abruf (nicht nur bei ≥ 95 %).
- Hinweistext je Lücke bleibt (`_slCutText`).

### 6.6 Nickerchen
- Regel: Block ≥ 20 min, Puls ≤ Schlafmedian + 5 oder ≤ Ruhepuls + 5, Unruhe ≤ `stillCut`, Winkelbereich < 5° (wie heute), kein Abgelegt-Verdacht.
- Am Tag (11:00 bis 20:00) zusätzlich Puls < 95 % der Tagesbasis und ≥ 30 min, sonst nur "Ruhephase" (NOOP: 90 min; Atlas wählt 30 min, weil Atlas Nickerchen für die Schlafschuld nutzt und keine Phasen braucht).
- Nach Mitternacht erkannte Blöcke außerhalb des Hauptschlafs (Abstand > 3 h) sind Nickerchen derselben Nacht und zählen in die Schlafzeit der Nacht (WHOOP-Nutzerklagen, Abschnitt 2).
- Nickerchen haben keine Phasen. Ausgabe: Beginn, Ende, Minuten.

### 6.7 Ausgaben für den Schlaf-Score
Felder (neu oder geklärt), je Nacht:
| Feld | Bedeutung |
|---|---|
| `bedHour`, `wakeHour` | Einschlaf-/Aufwachzeit (ist da) |
| `tibMin` | Zeit im Bett = Aufwachen − Bettzeit |
| `sleepHours` | Schlaf einer vollen Nacht (Bedeutung unverändert, siehe 6.5) |
| `slMeasH` | gemessener Schlaf jeder Nacht (neu) |
| `sleepCover` | Abdeckung 0 bis 1 |
| `slAwake`, `slWakes`, `slMicro` | Wachzeit, Zahl ≥ 2 min, Zahl kürzerer |
| `slLatency` | Minuten oder `null` |
| `sleepEff` | Schlaf / TIB (mit Latenz im Nenner) |
| `slDeep`, `slRem`, `slLight` + `_stageConf` | Schätzung |
| `blocks` | Liste `{t0, t1, kind}`; t0/t1 in Sekunden Unix, kind 'haupt'/'teil'/'nap'. Gespeichert kompakt als `[[t0,t1,'h'|'t'|'n'], …]` |
| `_slNote` | volle Nacht, Teil, geteilt, kein_schlaf |
Dabei bleibt die Zuordnung: Brücke `dd.sleep.hours` nur bei Abdeckung ≥ 0,85.

[Review: neu] Schnittstelle zu HRV, Ruhepuls und Rhythmus (S1): `wFinalizeDay0` gibt intern ein Objekt `slp = {blocks, on, off, stageAt(t), epochs}` weiter. `on`/`off` = Einschlafen/Aufwachen des Hauptschlafs in Sekunden. HRV und Ruhepuls nutzen nur Epochen mit `stageAt(t) !== 'wake'` in Blöcken 'haupt'/'teil'. Heute bekommen sie Indizes (`win0`, `stg.stages`, `ssum.on`, `ssum.off`). Nach dem Umbau gelten Zeiten, weil Indizes über Lücken springen.

### 6.8 Messen vor dem Umbau
- Die Diagnose der Nacht 25./26.11. auswerten (Band-Seite "Diagnose kopieren"): `_slDiag` (w0, w1, on, off, wake, lat, ep, hr), `hyp`, `hrs`.
- `sleepState`-Byte je 30 s im Schlaf auswerten: Anteil "2" im erkannten Schlaf, Anteil "0/1" in Wach-Epochen, Übereinstimmung mit Atlas-Wach. Entscheidung: Nur wenn ≥ 85 % Übereinstimmung im Schlaf **und** Wach-Epochen von Atlas zu ≥ 50 % bestätigt werden, nutzt der Stager `bs` als Beleg.
- Ohne Messung kein Umbau der Wach-Regeln (6.3, zweiter Punkt) und keine Zeit-Prior (6.4 d). Reihenfolge der Messung: Nacht 1 (Realfall) → drei weitere MG-Nächte.

## 7. Testfälle (Selbsttest-Nummern I42 ff., synthetische Nächte)

Aufbau: Epochen alle 30 s mit `hr`, `msd`, `za`, `bs`. "Schlaf" = hr 54 ± 2, msd 0,0003, za-Änderung < 1°. "Wach ruhig" = hr 58, msd 0,004. "Wach aktiv" = hr 78, msd 0,05, dz ≥ 30. Zeiten Ortszeit. Bestehende Fälle I22, I38 bis I41 bleiben grün.

| Nr | Eingang | Erwartung |
|---|---|---|
| I42 | Volle Nacht 23:30 bis 06:30 Schlaf, 20 min Latenz davor (aktiv bis 23:10, ruhig bis 23:30), keine Löcher | Einschlafen 23:30 ± 5 min, Aufwachen 06:30 ± 5 min, `sleepCover` 1, `slLatency` 20 ± 5, `_slNote` leer, `sleepHours` 7,0 ± 0,1 |
| I43 | Datenabriss: Schlaf 23:30 bis 02:30, Loch 02:30 bis 04:00 (keine Epoche), Schlaf 04:00 bis 05:00, Daten bis 12:00 | Zwei Blöcke, beide gewertet. `slMeasH` = 4,0 ± 0,2, `sleepCover` = 4,0/5,5 ≈ 0,73, `sleepHours` fehlt (Abdeckung < 0,85), `_slNote` = `luecke_mitte`, `blocks` zählt 2, Dauer nicht 1,0 h (Fehlerfall heute) |
| I44 | Nur ein Teil: Daten ab 03:00 bis 06:30 (Beginn fehlt), Schlaf durchgehend | Aufwachen 06:30, `bedHour` fehlt, `slLatency` `null`, `slMeasH` 3,5 ± 0,2, `sleepHours` fehlt, `sleepCover` `null` (Rand fehlt; vorher stand "< 0,5", das war mit der Definition in 6.5 nicht rechenbar), `_slNote` = `luecke_beginn`, Score-Gate "kein Score" |
| I45 | Geteilte Nacht: Schlaf 22:30 bis 01:30, wach ruhig im Bett (Puls 58) 01:30 bis 02:40 (70 min), Schlaf 02:40 bis 06:30 | Eine Nacht. Wach 70 min zählt als `slAwake` (≥ 60 min, `slWakes` = 1), `sleepHours` = 6,83 ± 0,2 (3 h + 3 h 50 min), `blocks` 1 oder 2 mit Art Haupt/Teil, **nicht** "Nickerchen" |
| I46 | Wie I45, aber Schlaf 21:00 bis 00:00, Wachphase 4 h (aufgestanden: hr 75, msd 0,03), Schlaf 04:00 bis 07:00 | Abstand 4 h > 3 h: zweiter Block ist Nickerchen ('nap'). `blocks` = 2, `slMeasH` des Hauptschlafs 3,0 h, Nickerchen 180 min in `naps`. Ob die Nachtsumme 6,0 h ist, entscheidet Agent 5 (Score). Kein Verwerfen eines Blocks. [Review: Zeiten ergänzt; Summenregel an Agent 5 verwiesen] |
| I47 | Kurzes Mikrowachen: Schlaf 23:30 bis 06:30 mit 6 × 60 s Wach (hr 66, msd 0,01) | `slWakes` = 6 nur wenn jede ≥ 2 min; bei 60 s: `slWakes` = 0, `slMicro` = 6; `sleepHours` ≥ 6,9 |
| I48 | Ruhiges Wachliegen: Schlaf 23:30 bis 03:00, dann 40 min ruhig wach (hr 55 = Schlafpuls, msd 0,003, `bs` = 0), dann Schlaf bis 06:30 | Heute: Schlaf 7 h, Wach 0. Soll nach 6.3 (nur mit Messung 6.8): `slAwake` ≥ 30 min. Bis zur Messung: Test markiert als "bekannte Lücke", erwartet `slAwake` 0 und Hinweis `lowWakeSpec` |
| I49 | Nickerchen am Tag: 14:00 bis 14:35 (hr 58, ruhepuls 55, msd 0,0005, za ruhig) nach Nacht bis 07:00 | `naps` = [14:00 bis 14:35, 35 min], `napMin` 35; Sitzen 14:00 bis 14:20 mit hr 70 → kein Nickerchen |
| I50 | Dünner Abend: 12 ruhige Epochen im Abstand von 55 min (wie I34) | Kein Fenster, kein Schlaf (`kein_schlaf`), `sleepHours` fehlt |
| I51 | Hoher Puls: Schlaf 23:30 bis 06:30 mit hr 69 ± 3, Abend davor hr 66 ± 5 | Fenster erkannt (kein `hr_not_depressed`-Verwerfen, weil kein Rückfall-Verwerfen mehr), Ruhepuls 66 bis 69, `_stageConf` = niedrig |
| I52 | Abgelegt: kein Puls 01:00 bis 02:00, Epochen mit msd 0 und za konstant | Block endet vor 01:00 oder Lücke zählt als nicht gemessen; Schlafzeit enthält die Stunde nicht; `offw` gesetzt |
| I53 | Backfill: erste Rechnung mit Daten bis 03:00 (3,5 h), spätere Rechnung mit Daten bis 06:30 | Zweite Rechnung ersetzt die erste (6.5 `_nFinal` nicht gesetzt), `sleepHours` ≈ 7 h; kein `_skipN` |
| I54 | Realfall-Nachbau: Fenster 23:48 bis 06:18, Schlaf 5:49 h, 41 min Wach, hr 69 im Mittel | `sleepHours` 5,8 ± 0,15, `sleepEff` nach 6.7 = Schlaf / (Aufwachen − Bettzeit) ≤ 89 %, Anteile im Bereich 8 bis 28 % Tief und 12 bis 32 % REM, sonst Hinweis "Anteil unsicher" |
| I55 | Band-Zustand: `bs` = 2 durchgehend, Atlas-Wach aktiv (hr 78, msd 0,05) für 10 Epochen | `bs` allein hebt Wach nicht auf (Wach bleibt); Diagnose zählt Übereinstimmung `bsAgree` |

Abnahme: Alle neuen Tests grün, alte 295/295 grün (I38–I41 und die Rand-Tests ab Zeile 15387 bleiben unverändert gültig, weil `sleepHours` seine Bedeutung behält), die echte Nacht 25./26.11. mit `_slDiag` verglichen mit Handangabe (Nutzer: etwa 5 h).

## Quellenliste (alle abgerufen oder als Suchtreffer gesehen)
- https://pmc.ncbi.nlm.nih.gov/articles/PMC6113241 (van Hees 2018, HDCZA)
- https://pmc.ncbi.nlm.nih.gov/articles/PMC5779275 (Cole-Kripke, Sadeh Spezifität)
- https://www.ncbi.nlm.nih.gov/pmc/articles/PMC12697920/ (Aktigrafie-Vergleich MESA)
- https://pmc.ncbi.nlm.nih.gov/articles/PMC6930135 (Walch 2019)
- https://iopscience.iop.org/article/10.1088/1361-6579/aa9047/meta (Beattie 2017)
- https://www.nature.com/articles/s41746-021-00510-8.pdf (Radha, Fonseca 2021)
- https://pubmed.ncbi.nlm.nih.gov/34234595/ ; https://link.springer.com/doi/10.1186/s13104-020-05355-0 (PPG-Staging)
- https://pubmed.ncbi.nlm.nih.gov/34201861/ (Altini, Oura 2021)
- https://pmc.ncbi.nlm.nih.gov/articles/PMC8120339 (Chinoy 2021)
- https://pubmed.ncbi.nlm.nih.gov/36016077/ (Miller 2022, sechs Geräte)
- https://pubmed.ncbi.nlm.nih.gov/32713257/ ; https://mdpi.com/2079-6374/11/6/185 (WHOOP-Validierung)
- https://pubmed.ncbi.nlm.nih.gov/39460013/ (Apple, Oura, Fitbit 2024)
- https://www.apple.com/kr/health/pdf/Estimating_Sleep_Stages_from_Apple_Watch_Oct_2025.pdf (Apple Weißbuch)
- WHOOP-Community-Links in Abschnitt 2 und 3 (Nutzerberichte, keine Studien)
- https://github.com/ryanbr/noop (SleepStager.swift, Rohdatei in Abschnitt 3)

---

## Review (26.11.2026, Kritiker)

Code-Bezüge geprüft (11157–11301, 11713, 11793, 11914–11915, 11951–11985, 10743/10752, 12365, 13029, 12709–12716, 12830–12841). Alle stimmen. `WSTG3_PRIOR` ist wirklich ungenutzt. `sleepState` wird nur geparst.
Geändert:
1. **`sleepHours` behält seine Bedeutung.** Der Plan wollte es für jede Nacht mit Lücken setzen. Das hätte Schlafleistung, Schlafbedarf, Schuld und die Brücke `dd.sleep.hours` verändert und die Tests I38–I41 gebrochen. Neu: Feld `slMeasH` für den gemessenen Schlaf.
2. 4.3 F und 6.2 Nr. 3 widersprachen sich (20/30 min, 90 min/3 h, "oder"). Jetzt eine Regel: ≤ 90 min immer Teil; ≤ 3 h nur mit Schlafpuls in der Lücke; sonst Nickerchen.
3. 6.5: Die Regel "≥ 4 h" für Ruhepuls/HRV gibt es nicht. Durch die echte Regel ersetzt.
4. 6.7: Schnittstelle S1 (`slp` mit Zeiten in Sekunden) für HRV, Ruhepuls und Rhythmus ergänzt. Felder `blocks` und `slMeasH` mit Einheiten.
5. I43, I44, I46 korrigiert. I44: `sleepCover` ist bei fehlendem Rand nicht rechenbar → `null`; der Code heißt `luecke_beginn`, nicht "Anfang". I46: Zeiten ergänzt, sonst ist "Abstand > 3 h" nicht prüfbar.
Nachgerechnet und richtig: 0.1 (6:30 h Fenster, 41 min wach, 90 %, Anteile 56/19/24 %; sie decken sich mit `WSTG3_PRIOR` ohne Wach: 57/18/25 %), 0.3 (69,2 Punkte), I43 (0,73), I45 (6,83 h), I47 (≥ 6,9 h), I54 (349/390 = 89 %).
Eigene Wahl, bleibt markiert: 30/20 min Blöcke, 3 h, +10/+5 bpm, 2-min-Wachphase, ×1,3/×0,6 Zeit-Prior, 8–28 %/12–32 %, 85 %/50 % Abdeckung, 85 %/50 % für `bs`.
Risiko: Neuberechnung bei jedem Abruf (6.5 Backfill) kostet Rechenzeit am Handy. Der Code-Kommentar Zeile 12711 nennt Sekunden je Nacht. Nur rechnen, wenn neue Epochen dazukamen.
Hinweis: `bs` gibt es nur bei MG (v18). 4.0-Records (v24) haben kein Schlafzustand-Byte. `bs` ist dort `null`.
