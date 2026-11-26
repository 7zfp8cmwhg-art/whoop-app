# Plan: VO2max aus Handgelenkdaten

## STAND: Abschnitte fertig: 1, 2, 3, 4, 5, 6. Plan komplett. Offen nur die Punkte mit [offen].

Stand: 26.11.2026. Erweitert docs/recherche-vo2-hrv.md (Teil A). Wiederholt dort Gesagtes nicht.
[nicht verifiziert] = nur Sekundärquelle oder eigene Herleitung.

---

## 1. Goldstandard und Genauigkeit der Schätzmethoden

**Goldstandard**
- Goldstandard ist die Spiroergometrie (CPET) bis zur Erschöpfung. Man misst Sauerstoffaufnahme direkt mit Atemgasanalyse.
- Alle Uhren-Werte sind Schätzungen. Der Fehler gegen CPET gilt als einziges echtes Maß.

**Nicht-Belastungs-Formeln (nur Ruhedaten, Alter, Körper)**
- Jurca 2005: SEE 1,45–1,97 MET (ca. 5–7 ml/kg/min). Quelle: https://www.unm.edu/~lkravitz/Sports%20Physiology/Jurca.pdf. Grund: Originalarbeit mit Gleichung und Fehlermaß.
- Nes 2011 (HUNT): SEE 5,70 (Männer), 5,14 (Frauen). Quelle: https://pubmed.ncbi.nlm.nih.gov/21502897/. Grund: Abstract nennt n und SEE.
- Uth 2004: SEE ca. 4,5 % mit gemessener HFmax, ca. 7,8 % mit Alters-HFmax. Quelle: https://link.springer.com/doi/10.1007/s00421-003-0988-y. Grund: Originalarbeit, nur 46 trainierte Männer.

**Submaximale Geräteschätzung (Belastung, HF gegen Tempo)**
- Meta-Analyse INTERLIVE (14 Studien, n=403): Belastungs-basierte Geräte Bias −0,09, LoA ca. ±9,9 ml/kg/min. Ruhe-basierte Bias +2,17, LoA −13,1 bis +17,4. Quelle: https://pmc.ncbi.nlm.nih.gov/articles/PMC9213394. Grund: einzige gepoolte Auswertung.
- Fazit der Autoren: gut für Gruppen, schwach für Einzelne. Quelle: https://link.springer.com/10.1007/s40279-021-01639-y. Grund: Sports Medicine 2022, gleiche Arbeit.
- Garmin/Firstbeat: MAPE ca. 5 % (Firstbeat-Studie), 5,2 % (Handgelenk-PPG-Studie), 5,7 % (Forerunner 245). Quellen: https://www.firstbeat.com/en/science-and-physiology/fitness-level/ ; https://mhealth.jmir.org/2017/7/e97/PDF ; https://www.thieme-connect.com/products/ejournals/pdf/10.1055/a-1686-9068.pdf. Grund: Herstellerangabe und zwei Peer-Reviews.
- Garmin 920XT MAPE 7,3 %, andere Uhren > 10 %. Quelle: https://www.ncbi.nlm.nih.gov/pmc/articles/PMC6747132/ (Passler 2019). Grund: fünf Handgelenkgeräte gegen Gasanalyse.
- Apple Watch: Bias −6,07 ml/kg/min, MAPE 13,3 %, LoA −6,1 bis +18,3 (n=30). Quelle: https://pubmed.ncbi.nlm.nih.gov/40373042/. Grund: unabhängige Validierung.
- Polar Fitness Test (ohne Belastung), Fitbit Cardio Fitness (Ruhepuls oder GPS), Samsung, Oura Cardio Capacity: keine verlässlichen unabhängigen MAPE-Werte gefunden [nicht verifiziert]. Quellen zu Verfahren: https://polar.com/img/static/whitepapers/pdf/polar-fitness-test-white-paper.pdf ; https://support.google.com/fitbit/answer/14237924 ; https://support.ouraring.com/hc/en-us/articles/28336620578835.
- Hochtrainierte werden meist unterschätzt (Garmin ca. −6,3). Quelle: https://link.springer.com/article/10.1007/s00421-025-05923-x. Grund: Studie an Elite-Läufern.
- Ein zweiter Lauf senkt den Fehler stark (MAPE 5,6 % → 1,1 %). Quelle: https://jssm.org/jssm-23-351.xml-Fulltext. Grund: Wiederholungsmessung mittelt Rauschen.

**Folge für Atlas**
- Ehrliche Fehlerspanne: Ruhe-Schätzung ±5–6 ml/kg/min (1 SEE). Lauf-Schätzung ±3–5 ml/kg/min bei gemessener HFmax.
- Einzelwerte nie auf Nachkommastellen genau anzeigen. Trend zählt mehr als Betrag.

---

## 2. So rechnet und zeigt WHOOP 5.0 den Wert

- Drei Stufen: passiv, GPS-gestützt, mit Laborwert kalibriert. Quelle: https://www.whoop.com/us/en/thelocker/how-accurate-is-whoop-vo2-max/. Grund: offizieller WHOOP-Artikel.
- Freigabe: mindestens 14 Recoveries in den letzten 21 Tagen. Update wöchentlich dienstags. Vorher zeigt die Trendansicht, wie viele Recoveries fehlen. Quelle: https://www.whoop.com/ae/en/thelocker/estimate-your-vo-max-with-whoop-/. Grund: offizielle Hilfe.
- GPS-Stufe: nur wenn in den letzten 90 Tagen ein Außenlauf mit GPS vorliegt (laut Patent mindestens 15 min). Quelle: https://the5krunner.com/2026/11/03/quick-read-whoop-vo2-max-patent. Grund: Bericht zur Patentanmeldung US 2026/0263002 [Sekundärquelle].
- Passive Stufe: Basis ist die Schlaf-Herzfrequenz der Nacht. Dazu Alter und Gewicht. Dazu Zeit in HF-Zonen beim Training. Quelle: gleiche. Grund: Patent-Bericht. Keine Formeln, keine Fehlerwerte veröffentlicht.
- Nach Ende der GPS-Läufe bleibt die passive Schätzung, korrigiert um die zuletzt gemessene Differenz zur GPS-Stufe. Quelle: gleiche. Grund: Patent-Bericht.
- Laborwert mit Testdatum: wird Anker, korrigiert spätere und zuletzt auch frühere Werte. Quelle: https://www.whoop.com/ae/en/thelocker/how-accurate-is-whoop-vo2-max/. Grund: offizieller Artikel.
- Herstellerfehler: 3,3–3,7 ml/kg/min, MAPE < 8 %. Quelle: https://www.notebookcheck.net/Whoop-releases-new-VO2-Max-tracking-feature-for-wearables.977493.0.html. Grund: Pressebericht der Herstellerangabe; nur interne Validierung.
- Anekdote: Labor 54, WHOOP 64 (Überschätzung bei Athleten). Quelle: https://boxlifemagazine.com/is-your-vo2-max-accurate/. Grund: kleine Vergleichsstudie, 16 Athleten.
- Reddit/Forum-Stimmen: nicht ausgewertet (Zugriff nicht erreicht) [offen].

**Folge für Atlas**
- Das Muster "Nacht-HF + Profil als Basis, Lauf als Korrektur, Labor als Anker" ist das Ziel.
- Wir kennen WHOOPs Gewichte nicht. Wir bauen keine Kopie, sondern ein offenes Modell mit gleichem Aufbau.

---

## 3. So machen es die Open-Source-Apps ohne Abo

**NOOP (github.com/ryanbr/noop)**
- Datei: `Packages/StrandAnalytics/Sources/StrandAnalytics/FitnessAgeEngine.swift` (Android-Zwilling `android/app/src/main/java/com/noop/analytics/FitnessAgeEngine.kt`).
- Funktion `FitnessAgeEngine.estimateVO2max(age:sex:waistCm:restingHR:paIndex:)`: Nes 2011 mit Taillenumfang. Männer 100,27 − 0,296·Alter + 0,226·PA − 0,369·Taille − 0,155·RHR. Frauen 74,74 − 0,247·Alter + 0,198·PA − 0,259·Taille − 0,114·RHR. SEE 5,70 / 5,14.
- Funktion `physicalActivityIndexFromStrain(activeDaysPerWeek:meanActiveStrain:)`: baut den HUNT-Aktivitätsindex aus aktiven Tagen und Strain nach.
- Fallback ohne Taille (Test `StrandTests/Vo2maxFallbackTests.swift`): Uth 15,3 × Tanaka-HFmax / RHR. Der Test rechnet 15,3 × 180 / 60 = 45,9.
- Fitness-Alter: Nes-Gleichung umgekehrt. Die Taille fällt heraus. Das ist dieselbe Idee wie unser `fitnessAgeAt`.
- NOOP rechnet keinen Lauf-basierten VO2max. Es gibt keine ACSM-Läufe und keine 14-Nächte-Regel in den gefundenen Dateien.
- Folge: NOOP ist für uns ein Beleg für Nes, aber keine Vorlage für die Lauf-Stufe.

**wearable5.0 (github.com/LeonardSEO/wearable5.0)**
- Protokoll-Bibliothek für WHOOP 5.0/MG (Decoder, `re/SCORE_MODELS.md`, `re/score_formulas.py`). Keine VO2max-Treffer im Dateibaum oder in den Dateinamen.

**OpenVitals**
- Das Repo `sourcetms/OpenVitals` existiert nicht (GitHub-Abfrage: nicht gefunden). Ähnliche Projekte: https://github.com/tohmsc/openvitals-public (WHOOP 4.0, `whoop-tools/metrics.py`, `scores.py`) und https://github.com/klinikal/openvitals. Kein VO2max-Treffer in den Dateinamen. Inhalt nicht geprüft [offen].

**Weitere**
- Goose (https://github.com/b-nnett/goose) und GooseAndroid (https://github.com/dsp515/GooseAndroid): BLE-Client für 5.0. VO2max nicht geprüft [offen].
- OpenStrap (https://github.com/OpenStrap) zielt auf 4.0. Nicht geprüft [offen].

**Ergebnis**
- Keine freie App rechnet VO2max aus Läufen mit Bandpuls. Atlas ist hier weiter als NOOP.
- Der Taillenumfang fehlt in Atlas. Nes ohne Taille ist nur mit Annäherung über den BMI möglich.

---

## 4. Wahrheitsquelle und beste Methode mit MG-Daten

**Wahrheitsquelle**
- Die Wahrheit ist ein Labortest (CPET). Siehe Abschnitt 1.
- Der Nutzer kann einen Laborwert mit Datum eintragen. Er ist der Anker für alle Schätzungen.
- Ohne Laborwert ist jeder Wert eine Schätzung mit Fehlerspanne.

**Rangfolge der Methoden (genau zu grob)**
1. Laborwert (Anker, Datum).
2. Lauf-Schätzung: GPS-Tempo gegen Bandpuls, Firstbeat-Prinzip. Fehler ca. 4–6 % bei gemessener HFmax. Quelle: https://mhealth.jmir.org/2017/7/e97/PDF. Grund: Handgelenk-PPG-Studie mit MAPE 5,2 %.
3. Passive Schätzung: Jurca 2005 aus Alter, Geschlecht, BMI, Ruhepuls, Aktivität. Fehler ca. 5–7 ml/kg/min. Quelle: https://www.unm.edu/~lkravitz/Sports%20Physiology/Jurca.pdf.
4. Optional mit Taillenumfang: Nes 2011. Quelle: https://pubmed.ncbi.nlm.nih.gov/21502897/. NOOP nutzt genau diese Variante (siehe Abschnitt 3).

**Empfohlene Methode: drei Stufen wie WHOOP, offen gerechnet**
- Stufe A (immer, passiv): Jurca. Ohne Uth. Grund: Uth reagiert stark auf den Ruhepuls. Der Band-Ruhepuls ist ein Schlafpuls, kein Puls im Sitzen. [Review: korrigiert] Er kommt zuerst aus `wRhrWhoop` (Zeile 10900): das Kleinere aus Tiefschlaf-gewichtetem Mittel und Median der 2. Schlafhälfte. Nur ohne Phasen gilt das 5-min-Minimum `wNocturnalRhr` (Zeile 11022). Das Minimum liegt laut Code-Kommentar ca. 6 bpm tiefer. Die Methode steht je Nacht in `_rhrMethod` ('whoop' oder 'min5'). 5 bpm weniger Ruhepuls erhöhen Uth bei HFmax 190 um ca. 5 ml/kg/min (15,3·190/50 − 15,3·190/55 = 5,3). Bei Jurca sind es 5·0,03·3,5 = 0,5. [Rechnung eigene Herleitung, nachgerechnet]
- Stufe B (Läufe): ACSM-Tempo gegen Puls im stabilen Teil des Laufs, %HFR = %VO2R. Median über die letzten bis zu 5 Läufe in 90 Tagen. Grund: mehrere Läufe senken den Fehler stark. Quelle: https://jssm.org/jssm-23-351.xml-Fulltext.
- Stufe C (Anker und Versatz): Differenz zwischen Lauf-Wert und passivem Wert wird gemerkt. Fällt der letzte Lauf aus dem 90-Tage-Fenster, gilt passiv plus gemerkter Versatz. Der Versatz verfällt mit Halbwertszeit 90 Tage. Ein Laborwert ersetzt den Versatz. Grund: WHOOP beschreibt dasselbe Muster. Quelle: https://the5krunner.com/2026/11/03/quick-read-whoop-vo2-max-patent. [Halbwertszeit ist unsere Wahl, nicht veröffentlicht.]
- Maxpuls: gemessen, wenn plausibel. Sonst Tanaka 208 − 0,7·Alter. Ein falscher HFmax um 15 bpm bringt ca. 9 % Fehler. Quelle: https://the5krunner.com/garmin-features/physiology/vo2-max/ [nicht verifiziert].

**Warum so**
- Die MG liefert 1 Hz Puls vom Handgelenk, GPS kommt vom Handy. Beides reicht für Stufe B.
- Nur der Nachtpuls ist immer da. Darum braucht es Stufe A.
- Bewegungsstörungen im PPG-Puls machen den Maxpuls anfällig. Darum die Plausibilitätsregeln in Abschnitt 6.

---

## 5. Lücken und Fehler im aktuellen Atlas-Code (index.html)

Zeilen vom 26.11.2026.

| Nr | Stelle | Problem | Schwere |
|---|---|---|---|
| 1 | `wVo2At` 13125, `WUTH_K` 11091 | [Review: Stand seit Commit 08e04fc] Uth zählt nur noch mit gemessenem HFmax (`measured`, Zeile 13125) und wird dann mit Jurca gemittelt. Ohne Messung gilt Jurca allein. Rest-Problem: Uth ist an trainierten Männern geeicht und reagiert stark auf den Schlaf-Ruhepuls. Mit Messung überschätzt das weiter. | mittel |
| 2 | `wHrMaxObs` 10326, Erfassung 13058–13068 | Maxpuls = 4 Epochen ≥ 100 bpm mit Bewegung. Kein Obergrenzen-Check. Ein PPG-Artefakt (Schritt-Rhythmus) hebt HFmax. Das verfälscht Läufe und Uth. | hoch |
| 3 | `wVo2FromRuns` 13091–13107 | Nutzt `band.avgHr` der ganzen Einheit. Aufwärmen, Pulsdrift und Pausen sind enthalten. Kein Test auf gleichmäßiges Tempo. | hoch |
| 4 | `wVo2FromRuns` 13091 | Akzeptiert manuelle Distanz (`km`) ohne GPS-Nachweis. Laufband und Schätzwerte verfälschen. Es gibt `mode:'gps'` und `c.trk`, beides wird nicht geprüft. | mittel |
| 5 | `wVo2At` 13118 | Mit Läufen zählt nur der Lauf-Median. Kein Versatz zur passiven Schätzung. Läuft der letzte Lauf nach 60 Tagen aus, springt der Wert auf die passive Zahl. Die Kurve hat Stufen. | hoch |
| 6 | `wVo2FromRuns` 13091 | Fenster 60 Tage, Median ohne Gewichtung, Grenzen 20–90 sind weit. WHOOP nutzt 90 Tage für die GPS-Stufe. Kein Mindestwert für Anzahl der Läufe als Konfidenz. | mittel |
| 7 | `wVo2maxFromSegment` 11106 | Zweite, abweichende Lauf-Rechnung (360 s, HFR 0,4–1,0). Nirgends aufgerufen. Tote Funktion mit anderen Regeln. | niedrig |
| 8 | `wUpdateVo2max` 13184–13205 | Doppelte Logik zu `wVo2At` (eigener Ruhepuls, eigener Lauf-Aufruf). Der Else-Zweig mit `wVo2maxUth` ist faktisch tot. Schreibt `whoop.vo2max` nur für heute, überschreibt täglich. Kein Verlauf. | mittel |
| 9 | `_vo2Nights` 13128 | Zählt jede Nacht mit `rhr > 0`. `fitnessAgeAt` 3644 schließt Teilnächte aus (`_wPartNight`), VO2max nicht. Die 14-Nächte-Regel zählt also zu großzügig. Teilnächte haben einen höheren Ruhepuls. | mittel |
| 10 | `wVo2At` 13111–13116 | Wert ab 3 Nächten sichtbar, `prelim` erst unter 14. WHOOP zeigt vor 14 nichts. Ok mit "vorläufig", aber ab 3 Nächten ist Median-Ruhepuls dünn. | niedrig |
| 11 | `wVo2At` 13119 | Fehlendes Gewicht oder Größe: Stillschweigend BMI 24. Fehlendes Alter: stillschweigend 30. Keine Warnung, keine Senkung der Konfidenz. | hoch |
| 12 | `wVo2At` 13120–13122 | Aktivitätscode aus Trainingstagen der letzten 28 Tage. Jurcas PA-Skala hat andere Stufen. Die Werte 0 / 0,32 / 1,06 / 1,76 / 3,03 sind nicht gegen das Original geprüft. Intensität fehlt. | mittel |
| 13 | `wVo2At` 13113 | HFmax = max(gemessen, Tanaka). Liegt gemessen unter Tanaka, gilt Tanaka. Das ist ok. Liegt gemessen darüber, gilt es ohne Plausibilität (siehe Nr. 2). | mittel |
| 14 | Anzeige `openVo2` 13156 ff. | Eine Nachkommastelle und große Zahl. Keine Fehlerspanne bei Läufen. Text "±10–15 %" nur bei Schätzung. Das täuscht Genauigkeit vor. Das Dashboard zeigt schon ganze Zahlen. | mittel |
| 15 | `vo2Series` 13130 | Rechnet alte Tage mit heutigem Profil und heutigem HFmax. Ein neuer HFmax schreibt die ganze Kurve um. | niedrig |
| 16 | `VO2_NORM` 13134, `fitnessAgeAt` 3644 | Zwei verschiedene "Fitness-Alter" aus zwei Methoden (Normtabelle gegen Nes). Kann sich widersprechen. | mittel |
| 17 | `wVo2FromRuns` 13091 | Bergab, Wind, Hitze und Treppen sind nicht berücksichtigt. Nur Anstieg zählt. Hitze erhöht den Puls und senkt die Schätzung. | niedrig |
| 18 | ganze Kette | Kein Laborwert-Anker. WHOOP hat ihn. | mittel |
| 19 | `wVo2At` 13114 | [Review: neu] Der Ruhepuls-Median mischt 4.0- und MG-Nächte, Teilnächte und beide Ruhepuls-Methoden (`_rhrMethod` 'whoop' und 'min5', ca. 6 bpm Abstand). Beim Bandwechsel springt der Wert. | mittel |
| 20 | `wHrMaxObs` 10326, 13067 | [Review: neu] Gespeichert ist nur ein einziger Höchstwert (`cfg.hrMaxObs`, `hrMaxObsDate`). Eine Regel "an zwei Tagen" (6.3) braucht ein neues Tagesfeld. `wHrMaxObs` nimmt dazu den Export-Wert `whoopRef.hrMax` (4.0-Zeit). | mittel |

**Was schon gut ist**
- Rückfall ohne Läufe ist gekennzeichnet (`src`). Quelle: Code 13118, 13126.
- Langlauf (Ski) zählt nicht als Lauf. Tempo ≥ 134 m/min nötig (ACSM-Gültigkeit). Anstieg geht in die Formel ein.
- Ruhepuls: Median der letzten 14 plausiblen Nächte (30–85 bpm). [Review: aber siehe Lücke 19]
- Bestehende Tests: `wVo2FromRuns` 54,4 (Zeile 15033), Anstieg 15727.

---

## 6. Bauplan

Alle Werte in ml/kg/min. Rundung erst bei der Anzeige.

### 6.1 Eingaben
- Alter (aus Geburtsdatum), Geschlecht, Gewicht, Größe. Fehlt eines davon: keine passive Schätzung. Meldung "Profil ergänzen: Gewicht/Größe/Alter". Kein stilles Standardalter und kein Standard-BMI mehr (Lücke 11).
- Ruhepuls RHR: Median der letzten 14 vollständigen Nächte mit Wert 30–85 bpm. Teilnächte (`_wPartNight`) zählen nicht. Mindestens 7 gültige Nächte. Unter 7: kein Wert (siehe 6.6). [Review: der Satz "3–6 Nächte vorläufig" widersprach 6.6 und T17; gestrichen.]
- [Review: neu] Gleiche Definition wie im Schlafplan: Ruhepuls = `whoop.rhr` der Nacht, gerechnet nur im Schlaf der Nacht (Haupt- und Teilblöcke, ohne Messlücken, siehe docs/plan-review.md, Schnittstelle S2). Nur Nächte desselben Bandtyps wie der Tag (`_gen`). Nächte mit `_rhrMethod==='min5'` zählen nur, wenn weniger als 7 Nächte mit 'whoop' da sind. Grund: 'min5' liegt ca. 6 bpm tiefer. Das ist 0,6 ml/kg/min bei Jurca, aber viel bei %HFR (6.4).
- HFmax: siehe 6.3.
- Läufe: `cardioSessions` mit Art Lauf (`cxKind==='run'`).
- Optional: Laborwert mit Datum. Optional: Taillenumfang in cm.

### 6.2 Stufe A: passiver Wert
- BMI = Gewicht / (Größe in m)².
- PA-Code aus Trainingstagen pro Woche (Mittel der letzten 28 Tage): < 0,5 → 0. < 1,5 → 0,32. < 3 → 1,06. < 5 → 1,76. sonst 3,03. [Werte aus Original prüfen, sonst Tabelle ersetzen: offen]
- MET = 18,07 + 2,77·(Mann=1, Frau=0) − 0,10·Alter − 0,17·BMI − 0,03·RHR + PA-Code.
- VO2_passiv = MET · 3,5. Quelle der Formel: Jurca 2005 (Abschnitt 1).
- Geschlecht "divers/andere": mit Frauen-Term rechnen und "±7" statt "±6" anzeigen.
- Mit Taillenumfang: Nes 2011 nach NOOP-Koeffizienten (Abschnitt 3) als Ersatz für Jurca. PA-Index nach `physicalActivityIndexFromStrain`-Idee. Nur bauen, wenn der Nutzer die Taille einträgt. [Phase 2]
- Uth entfällt aus dem Wert. `wVo2maxUth` bleibt nur für Tests und Anzeige "Verhältnis Max/Ruhe".

### 6.3 Maxpuls
- Tanaka = 208 − 0,7·Alter.
- Gemessen (`wHrMaxObs`) zählt nur, wenn: Tanaka − 5 ≤ gemessen ≤ Tanaka + 12, und mindestens zwei verschiedene Tage einen Wert ≥ 97 % davon haben. Sonst gilt Tanaka. [Grenzen sind Praxiswerte, eigene Wahl. Tanaka 2001 nennt eine SD von ca. 10 bpm, nicht im Original geprüft.]
- [Review: neu] Dafür braucht es ein Tagesfeld `whoop.hrMaxDay` (höchster plausibler Puls des Tages, gleiche Erfassung wie Zeile 13058–13068). Heute gibt es nur einen Gesamtwert. `cfg.hrMaxObs` bleibt unverändert stehen (keine Daten löschen).
- Flag `hrMaxMeasured` = true, wenn der gemessene Wert gilt.

### 6.4 Stufe B: Lauf-Wert
Ein Lauf zählt, wenn alle Punkte stimmen:
1. Art Lauf, nicht Ski.
2. Distanz aus GPS (`mode==='gps'` oder `c.trk`/`c.route`). Manuelle Distanz zählt nicht.
3. Dauer ≥ 10 min, Distanz ≥ 1,5 km.
4. Stabiler Teil: Puls-Serie `band.ser` ab Minute 3 bis Ende. Mindestens 6 min. Pulssteigung im Teil ≤ 3 bpm pro 5 min. Tempo-Streuung (Variationskoeffizient) ≤ 12 %. Fehlt `ser`, zählt `avgHr`, aber der Lauf gilt als "grob" und hat halbes Gewicht.
5. Mittleres Tempo v ≥ 134 m/min. [Review: v muss aus demselben stabilen Teil kommen wie der Puls (GPS-Spur `c.trk` mit Zeit). Ohne Zeit in der Spur: v aus der ganzen Einheit, Lauf gilt als "grob".]
6. Mittlere Steigung < 5 %. Anstieg geht in die Formel ein (6.4 unten).
7. %HFR f = (HF_Teil − RHR) / (HFmax − RHR) liegt in 0,55–0,92.

Rechnung je Lauf:
- vert = Höhenmeter Anstieg je Minute.
- VO2_Lauf = 3,5 + 0,2·v + 0,9·vert.
- VO2max_Lauf = 3,5 + (VO2_Lauf − 3,5) / f.
- Gültig nur 25–85.

Wert Stufe B: Median der bis zu 5 jüngsten gültigen Läufe der letzten 90 Tage. Mit Gewicht: grober Lauf 0,5, sonst 1. Ab 3 Läufen "normal". Bei 1–2 Läufen "vorläufig".

### 6.5 Stufe C: Versatz und Anker
- Versatz = VO2_Lauf-Wert − VO2_passiv am Tag des jüngsten gültigen Laufs. Begrenzt auf ±12.
- Ohne gültigen Lauf der letzten 90 Tage: Wert = VO2_passiv + Versatz · 0,5^((Tage seit letztem Lauf − 90) / 90). Bis 90 Tage gilt Faktor 1 (Stufe B ist dann noch aktiv).
- Laborwert mit Datum: Versatz_Labor = Labor − VO2_passiv am Testtag. Gilt als Versatz, bis ein jüngerer gültiger Lauf ihn ersetzt. Rückwirkend auf Verlauf ab Testtag anwenden. Spanne dann ±3.
- Kein Lauf, kein Labor: Versatz = 0.

### 6.6 Wert, Konfidenz, Anzeige
| Zustand | Wert | Spanne | Etikett |
|---|---|---|---|
| Nur passiv, RHR ≥ 7 Nächte | VO2_passiv | ±6 | "Schätzung" |
| Läufe ≥ 3, HFmax gemessen | Stufe B | ±4 | "aus Läufen" |
| Läufe ≥ 3, HFmax nach Tanaka | Stufe B | ±6 | "aus Läufen" |
| Läufe 1–2 | Stufe B | ±6 | "vorläufig" |
| Passiv + Versatz (Läufe älter als 90 Tage) | Stufe C | ±5 | "Schätzung mit Versatz" |
| Laborwert aktiv | Stufe C | ±3 | "Labor-geeicht" |

- "vorläufig" gilt zusätzlich, wenn weniger als 14 vollständige Nächte in den letzten 21 Tagen vorliegen (WHOOP-Regel, Abschnitt 2). Das ersetzt `_vo2Nights`, jedoch ohne Teilnächte.
- Unter 7 gültigen Nächten: kein Wert. Text "Noch X Nächte, dann zeigt Atlas VO₂max."
- Anzeige als ganze Zahl, dazu Spanne: "48 (±5)". Dashboard und Detailfenster gleich (Lücke 14).
- Erklärtext im Detailfenster nennt die Quelle des Werts (Läufe, passiv, Labor) und was fehlt. Beispiel: "Ein GPS-Lauf von 10 min macht den Wert genauer." Kurze Sätze.
- Einstufung (`vo2Cat`) bleibt. Das Fitness-Alter aus `vo2FitAge` zeigt die Spanne nicht an. Unter "vorläufig" kein Fitness-Alter.
- Zeitreihe: Wochenwerte (Median), wie WHOOP. Wert nur bei neuem Lauf oder neuer Nacht neu rechnen. Alte Tage nicht mit neuem HFmax umschreiben: Tageswert in `whoop.vo2maxCalc` speichern (Lücke 15).
- Warnung bei Sprung > 4 gegenüber Vorwoche ohne neuen Lauf: Text "Wert springt wegen neuem Lauf/Ruhepuls."

### 6.7 Randfälle
- Ruhepuls ≥ HFmax − 20: ungültig, kein Lauf-Wert.
- Alter < 18 oder > 80: Wert zeigen, aber Einstufungstabelle klemmt auf 25–65 (bestehend). Hinweis zeigen.
- Gehen, Wandern, Ski, Rad: kein Lauf-Wert (Lücke 17). Gehen mit ACSM-Gehformel ist Phase 2.
- Laufband: kein Lauf-Wert (keine GPS-Distanz).
- Hitze, Krankheit, Alkohol am Vortag: Lauf trägt den Wert nicht, wenn die Erholung dieser Nacht < 33 % lag [Praxiswert, offen].
- Neues Band oder Reset: Versatz bleibt, HFmax-Messung wird neu aufgebaut.
- Zwei Läufe am selben Tag: beide zählen, jeder mit Gewicht.

### 6.8 Umbau-Reihenfolge
1. `wVo2At` neu: Uth raus, Profilpflicht, Teilnächte raus, 7-Nächte-Minimum, Konfidenzfeld.
2. HFmax-Plausibilität in `wHrMaxObs`-Nutzung (nicht in der Erfassung 13058).
3. `wVo2FromRuns` auf stabilen Teil umbauen, GPS-Pflicht, 90 Tage, bis 5 Läufe.
4. Versatz (Stufe C) und Laborwert-Anker.
5. `wUpdateVo2max` auf `wVo2At` stützen. `wVo2maxFromSegment` löschen.
6. Anzeige: ganze Zahl plus Spanne, Etikett, Erklärtext.
7. Tests (6.9).

### 6.9 Testfälle
Neue Funktionen heißen im Plan `vo2Passive(profil, rhr, paCode)` und `vo2Run(lauf, rhr, hrMax)`. Namen frei wählbar.

| Nr | Eingabe | Erwartung |
|---|---|---|
| T1 | Mann, 40 J, 75 kg / 175 cm (BMI 24,49, ungerundet wie in 6.2 und im Code), RHR 55, PA-Code 1,06 | MET 12,09, VO2_passiv 42,3 (±0,1). Etikett "Schätzung", Spanne ±6. Anzeige "42 (±6)". [Review: alt 12,17 / 42,6 / 43 galt nur mit gerundetem BMI 24.] |
| T2 | Frau, 35 J, BMI 22, RHR 60, PA-Code 0,32 | MET 9,35, VO2_passiv 32,7 (±0,1). |
| T3 | Mann, 25 J, BMI 22, RHR 45, PA-Code 3,03 | VO2_passiv 57,0 (±0,1). `vo2Cat` = 5 (höchste Stufe; Grenze 52,5 für Alter 25). [Review: `vo2Cat` liefert eine Stufenzahl 0–5, keinen Text.] |
| T4 | Lauf 5 km in 25 min, GPS, stabiler Teil Puls 160, RHR 50, HFmax 190, Steigung 0 | v 200 m/min, f 0,786, VO2max_Lauf 54,4 (±0,1). Entspricht bestehendem Test Zeile 15033. [Review: Der alte Test hat keine GPS-Marke (`km:5, sec:1500`). Mit GPS-Pflicht muss er `mode:'gps'` bekommen, sonst wird er rot.] |
| T5 | wie T4, 120 Höhenmeter Anstieg | vert 4,8 m/min, VO2max_Lauf 59,9 (±0,1). Bestehender Test 15727 bleibt grün (v1 > v0 + 3), aber nur mit `mode:'gps'` im Test-Lauf (wie T4). |
| T6 | Lauf 8 km in 45 min, GPS, Puls 150, RHR 55, HFmax 185 | v 177,8 m/min, f 0,731, VO2max_Lauf 52,2 (±0,1). |
| T7 | Lauf 5 km in 25 min, Puls 185, RHR 50, HFmax 190 | f 0,964 > 0,92: Lauf verworfen. Kein Lauf-Wert. |
| T8 | 3 km in 30 min (100 m/min), Puls 130 | v < 134: verworfen (Gehtempo). |
| T9 | Lauf 5 km in 25 min ohne GPS (manuelle Distanz) | verworfen. |
| T10 | Alter 40 (Tanaka 180), gemessener Max 215 an einem Tag | 215 > 192: ignoriert. HFmax = 180. `hrMaxMeasured` false. Spanne bei Läufen ±6. |
| T11 | Alter 40, gemessener Max 188 an zwei Tagen (≥ 97 %) | 180 − 5 ≤ 188 ≤ 192: gilt. HFmax 188. `hrMaxMeasured` true. |
| T12 | Läufe 54,4 / 50,0 / 58,0 (alle gültig, gleiches Gewicht) | Median 54,4. Anzeige 54 (±4 oder ±6 je nach HFmax). Etikett "aus Läufen". |
| T13 | Ein gültiger Lauf (54,4), passiv 42,3 am Lauftag (T1) | Etikett "vorläufig". Versatz +12,1, begrenzt auf +12,0. [Review: Zahl an T1 angepasst; der Test prüft jetzt die Grenze.] |
| T14 | Letzter Lauf vor 180 Tagen, Versatz +10, passiv heute 43 | Faktor 0,5^((180 − 90) / 90) = 0,5. Wert 43 + 5 = 48. Etikett "Schätzung mit Versatz". |
| T15 | Passiv 42,3, Laborwert 50 am Testtag | Versatz +7,7. Wert 50,0 am Testtag. Spanne ±3. Etikett "Labor-geeicht". |
| T16 | 10 vollständige Nächte in 21 Tagen, RHR da | Wert da, Etikett "vorläufig" (< 14). |
| T17 | 5 gültige Nächte | Kein Wert. Text "Noch 2 Nächte, dann zeigt Atlas VO₂max." |
| T18 | Gewicht oder Größe fehlt | Keine passive Schätzung. Meldung "Profil ergänzen". Kein stiller BMI 24. |
| T19 | 14 Nächte, davon 4 Teilnächte | Zählt 10. Etikett "vorläufig". |
| T20 | Lauf mit `ser`, Puls steigt in 5 min um 8 bpm | Drift > 3: verworfen oder als "grob" mit halbem Gewicht, wenn `ser` fehlt. Hier verworfen. |

### 6.10 Offene Punkte
- PA-Codes von Jurca (0,32 / 1,06 / 1,76 / 3,03) und deren Zuordnung zu Trainingstagen gegen das Original prüfen.
- Unterschied Nacht-Minimum-Ruhepuls zu Sitz-Ruhepuls messen und ggf. als Versatz in die Lauf-Rechnung nehmen [nicht verifiziert].
- Reddit- und Forenberichte zur WHOOP-Genauigkeit sammeln. Zugriff nicht erreicht.
- Inhalt von OpenVitals-Forks, Goose, OpenStrap nach VO2max durchsuchen.
- Samsung, Oura, Polar, Fitbit: keine unabhängigen Fehlerwerte gefunden.

---

## Review (26.11.2026, Kritiker)

Geprüft gegen index.html (16 868 Zeilen). Zeilennummern stimmen bis auf ±2.
Geändert:
1. Abschnitt 4: Der Ruhepuls ist nicht das Nacht-Minimum. Er kommt zuerst aus `wRhrWhoop` (Tiefschlaf-gewichtet oder Median 2. Hälfte, das Kleinere). `wNocturnalRhr` ist nur der Rückfall ohne Phasen.
2. Lücke 1: Seit Commit 08e04fc gilt Uth nur mit gemessenem HFmax. Schwere auf "mittel" gesenkt.
3. Neue Lücken 19 (Ruhepuls mischt Bandtypen, Teilnächte und Methoden) und 20 (HFmax nur als ein Wert gespeichert).
4. 6.1: Widerspruch "3–6 Nächte vorläufig" gegen 6.6 "unter 7 kein Wert" gestrichen. Es gilt: unter 7 kein Wert.
5. 6.1: Ruhepuls-Definition an den Schlafplan gebunden (Schnittstelle S2 in docs/plan-review.md).
6. 6.3: Die Zwei-Tage-Regel braucht ein neues Tagesfeld `whoop.hrMaxDay`.
7. 6.4: Tempo und Puls müssen aus demselben Teil des Laufs kommen.
8. T1 nachgerechnet: BMI 24,49 ergibt MET 12,09 und 42,3 (nicht 12,17 / 42,6). T13 und T15 folgen daraus (Versatz +12,1 → +12,0; Labor +7,7).
9. T3: `vo2Cat` gibt eine Stufe 0–5 zurück.
10. T4/T5: Die alten Tests 15033 und 15727 haben keine GPS-Marke. Mit GPS-Pflicht müssen sie `mode:'gps'` bekommen.
Nachgerechnet und richtig: T2 (32,7), T3 (57,0), T4 (54,4), T5 (59,9), T6 (52,2), T7 (f 0,964), T10/T11 (Tanaka 180, Grenze 192), T14 (48), T17.
Eigene Wahl, bleibt markiert: PA-Zuordnung zu Trainingstagen, %HFR 0,55–0,92, Versatz ±12, Halbwertszeit 90 Tage, HFmax-Grenzen −5/+12, Spannen ±3/±4/±5/±6.
Offen bleibt: Die PA-Koeffizienten 0 / 0,32 / 1,06 / 1,76 / 3,03 passen zu Jurca 2005 (Stufen 1–5 der Aktivitätsskala). Die Zuordnung "Trainingstage je Woche → Stufe" ist eigene Wahl [nicht verifiziert].
