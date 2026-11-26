# Plan: nächtliche HRV (RMSSD) und ihre Basislinie

## STAND
Fertig: 1, 2, 3, 4, 5a, 5, 6, 7. Der Plan ist vollständig.
Stand: 26.11.2026. Jeder Abschnitt wird nach dem Schreiben sofort gespeichert.

Messpunkt der ersten MG-Nacht (25./26.11.): HRV 41,4 ms, Methode „keine“, Ruhepuls 69, Schlaf 5:49 h.
Der Nutzer sagt: früher war die HRV oft höher (4.0 / WHOOP-App).
„Methode keine“ heißt im Code: kein Rundungsraster erkannt, kein Rauschabzug. Der Wert ist die ungeschönte, nur von Fehlschlägen bereinigte Fenster-RMSSD.

Hinweis zu den Quellen: „[Forum]“ = Erfahrungsbericht, kein Messwert. „[eigen]“ = eigene Herleitung oder eigene Schwelle, nicht aus der Literatur. Was ich nicht finden konnte, steht als „nicht gefunden“.

---

## 1. Wissenschaftlicher Standard

**Definition.** RMSSD = Wurzel aus dem Mittel der quadrierten Differenzen aufeinanderfolgender NN-Intervalle. Quelle: Task Force 1996, https://pubmed.ncbi.nlm.nih.gov/8598068/ (Standarddefinition der Kurzzeit-HRV; den genauen Wortlaut zur Aufnahmelänge habe ich nicht im Volltext geprüft). Kurzzeit = ca. 5 min, Werte aus 24 h, 5 min und < 5 min sind nicht austauschbar: https://www.frontiersin.org/articles/10.3389/fpubh.2017.00258/pdf (Übersicht Shaffer/Ginsberg).

**Artefakte und Extraschläge.**
- Lipponen und Tarvainen 2019: Schwellen aus der Verteilung der Differenzen, mitlaufend, plus Schlagklassen (Extraschlag, fehlender, zusätzlicher, unklarer Schlag). Empfindlichkeit für echte Extraschläge ca. 97 %, Spezifität ca. 99,9 %. Quelle: https://informahealthcare.com/doi/abs/10.1080/03091902.2019.1640306. Das ist das Verfahren in Kubios. Die Autoren sind Kubios-Gründer. Der Atlas-Code nutzt es in `wCorrectRr` (c1 0,13, c2 0,17, α 5,2, Fenster 91).
- Fehler wachsen mit dem Artefaktanteil (1, 3, 6 %): https://www.ncbi.nlm.nih.gov/pmc/articles/PMC7074236/. Ein einziger Artefakt kann RMSSD um > 250 % erhöhen: https://jssm.org/jssm-21-260.xml-Fulltext. Darum nie über eine Lücke differenzieren.

**PPG gegen EKG.**
- WHOOP 2.0 gegen EKG im Schlaf: lnRMSSD-Bias 1,66 %, Grenzen ±5,93 %. Quelle: https://acuresearchbank.acu.edu.au/download/70f2691b687e5a4e0997266c34d00cec8a8d37a2d38cbc0f8233bfe57a4c56d9/950087/OA_Bellenger_2021_Wrist_based_photoplethysmography_assessment_of_heart.pdf. Das gilt für die ältere Bauart, nicht für die MG.
- 536 Nächte gegen Polar H10: WHOOP 4.0 MAPE 8,2 %, Oura Gen4 6,0 %, Garmin 10,5 %: https://www.ncbi.nlm.nih.gov/pmc/articles/PMC12367097/.
- Die Fehlerrichtung von Handgelenk-PPG ist in der Literatur nicht einheitlich. Bei 1000 Hz leicht erhöht (1–8 %), bei Patienten zu niedrig (SDNN, RMSSD, pNN50). RMSSD ist laut Vorabdruck „fast nie“ äquivalent zwischen PRV und HRV, wenn die Pulslaufzeit schwankt. Quellen: https://www.frontiersin.org/journals/physiology/articles/10.3389/fphys.2025.1630032/pdf und https://medrxiv.org/content/10.1101/2023.08.24.23294449v1.full.pdf.
- Abtastrate: ca. 100–200 Hz für < 2 % Bias, 40–50 Hz gibt < 20 % Bias; Interpolation hilft bei 20–50 Hz: https://pmc.ncbi.nlm.nih.gov/articles/PMC9474518 (Treffer der Suche, nicht im Volltext geprüft).

**Fensterlänge.** 60 s reichen für lnRMSSD (https://www.jssm.org/jssm-13-535.xml-abst). 5 min ist der Hersteller-Standard (WHOOP, Oura). Fünf Minuten geben stabilere Einzelwerte. Quelle für die Nacht: https://medium.com/@altini_marco/what-you-need-to-know-about-heart-rate-variability-hrv-data-collected-during-the-night-eb3913ffdcf (ganze Nacht statt einzelner 5-min-Stück).

**Schlafphase.**
- RMSSD steigt vom Einschlafen zum ersten Tiefschlaf und bleibt dann hoch und stabil. Im letzten REM vor dem Aufwachen fällt sie. Quelle: https://www.ncbi.nlm.nih.gov/pmc/articles/PMC7046589/ (Kinder und Jugendliche; für Erwachsene nur als Richtung).
- REM = mehr sympathisch, Puls höher und unruhiger; N2 ruhig. Mittelwerte über die ganze Nacht verdecken Stufenunterschiede. Quelle: https://www.frontiersin.org/journals/cardiovascular-medicine/articles/10.3389/fcvm.2020.00019/pdf (Treffer der Suche, nicht im Volltext geprüft).
- Folge: der Nachtwert hängt vom Phasenmix ab. Eine Nacht mit viel REM oder kurzem Tiefschlaf liest niedriger, ohne dass „die Erholung“ schlechter ist. Darum gewichtet WHOOP (Abschnitt 2).
- Erste Nachthälfte ist oft gedrückt (Spät-Essen, Alkohol, Training), zweite höher: https://marcoaltini.substack.com/p/heart-rate-variability-hrv-measurement.

**lnRMSSD, Basislinie, SWC.**
- RMSSD ist rechtsschief. Darum ln. Quelle: https://www.ais.gov.au/__data/assets/pdf_file/0013/1130260/HRV-BPG_FINAL.pdf (AIS-Leitfaden: lnRMSSD, 7-Tage-Mittel, SWC, CV).
- Plews et al.: 7-Tage-Rollmittel von lnRMSSD ist aussagekräftiger als ein Einzelwert; Veränderungen außerhalb der SWC-Spanne (Basis ± 0,5 SD) zählen. Quellen: Plews 2013, Sports Med, https://pubmed.ncbi.nlm.nih.gov/23852425/ (PMID aus dem Gedächtnis, Titel „Training adaptation and heart rate variability in elite endurance athletes“, nicht im Volltext geprüft); die 0,5-SD-Regel steht in einer Abschlussarbeit, die Plews 2013 zitiert: https://dspace.umh.es/jspui/bitstream/11000/27132/1/TFG-Carrillo%20de%20Le%c3%b3n%2c%20Alejandro.pdf. Das „60-Tage-Normalband“ habe ich bei Plews nicht gefunden; es kommt von HRV4Training: https://hrv4training.com/faq.html.
- Altini: Basislinie = 7-Tage-Mittel von rMSSD, Normalbereich = erwarteter Bereich ohne Stressor, CV als zweite Größe: https://marcoaltini.substack.com/p/variability-in-variability.
- CV des 7-Tage-lnRMSSD sinkt vor Übertraining: https://pubmed.ncbi.nlm.nih.gov/22367011/.
- Tag-zu-Tag-Schwankung 5–20 ms ist normal: https://hrv4training.com/faq.html. Für die Anzeige heißt das: eine einzelne Nacht ist nie „schlecht“, nur der Trend zählt.

---

## 2. Wie die Hersteller rechnen

**WHOOP.**
- Staff-Aussage: HRV wird in überlappenden 5-min-Fenstern berechnet, alle 30 s weiter, über den ganzen Schlaf. Wachphasen raus. Gewichtetes Mittel; Fenster, die wahrscheinlich im Tiefschlaf liegen, und spätere Fenster zählen mehr. Die alte Aussage „nur Tiefschlaf“ sei überholt. Quelle: https://www.community.whoop.com/t/hrv-extreme-spikes/6472/31 [Forum, Mitarbeiter]. Die genauen Gewichte sind nicht öffentlich.
- Ältere Aussage in einem WHOOP-Forschungs-FAQ: der Wert stamme meist aus dem letzten 5-min-Stück der letzten Tiefschlafphase: https://www.sensorlab.arizona.edu/sites/default/files/2023-05/WHOOP%20Unite%20Research%20FAQs_0.pdf (Bauart 4.0, wohl überholt).
- WHOOP filtert die Intervalle mit einem eigenen, nicht öffentlichen Filter vor der Rechnung (Hinweis in der Validierungsliteratur): https://www.ncbi.nlm.nih.gov/pmc/articles/PMC8160717 (Treffer der Suche).
- Fazit: Atlas macht das schon so (`wHrvWhoop`). Die Gewichtsformel ist erfunden, aber in der Richtung belegt.

**Oura.** Mittel aller 5-min-RMSSD-Proben im Schlaf. Ein Intervall zählt nur, wenn 8 aufeinanderfolgende Intervalle als normal gelten. Keine weitere Gewichtung veröffentlicht. Quellen: https://support.ouraring.com/hc/en-us/articles/360025441974 und https://ouraring.com/blog/wp-content/uploads/2018/10/The-HRV-of-the-Ring-Comparison-of-OURA-Ring-to-ECG.pdf.

**Garmin.** Nachtwert aus dem ganzen Schlaf. HRV-Status = 7-Tage-Mittel gegen persönliche Basislinie, Status erst nach 3 Wochen Daten, Basislinie ändert sich langsam. Quelle: https://www.garmin.co.jp/minisite/garmin-technology/health-science/hrv-status und https://www8.garmin.com/manuals/webhelp/marqcommander/EN-US/GUID-9282196F-D969-404D-B678-F48A13D8D0CB.html. Ob Firstbeat und 5-min-Fenster genau so gelten: nicht gefunden.

**Polar Nightly Recharge.** HRV (RMSSD), Puls und Atmung aus den ersten ca. 4 Stunden Schlaf; Vergleich mit den letzten 28 Nächten; Skala −10…+10. Quelle: https://support.polar.com/en/nightly-recharge-recovery-measurement. Polar setzt auf den frühen Schlaf, WHOOP auf Tiefschlaf und späte Nacht. Das sind zwei verschiedene Definitionen. Zahlen sind nie zwischen Herstellern vergleichbar.

**Apple.** SDNN, nur gelegentliche Messungen (ca. 1 min). Nicht mit RMSSD vergleichbar. Quellen: https://medium.com/@marco_alt/on-heart-rate-variability-and-the-apple-watch-24f50e8e7bc0 und https://tryterra.co/research/HRV-metric-discrepancy. Eine neue RMSSD-Art in HealthKit wird berichtet (eine Quelle, nicht bestätigt): https://gadgetsandwearables.com/?p=18600667.

**Fitbit.** RMSSD aus dem Puls im Schlaf; zählt die längste Schlafperiode der letzten 24 h, Perioden unter 3 h entfallen. Quellen: https://support.google.com/fitbit/answer/14236917 und https://community.fitbit.com/t5/Other-Inspire-Trackers/Inspire-HR-HRV-data-missing/td-p/5360192 [Forum, Moderator]. Das stützt die Regel „Mindestschlaf“ in Abschnitt 7.

**Genauigkeit im Vergleich.** WHOOP für Trends brauchbar, leicht zu niedrig: https://the5krunner.com/2025/10/06/garmin-beaten-by-oura-whoop-in-hrv-accuracy-showdown. WHOOP gegen Polar: HRV konsistent: https://www.trainerroad.com/forum/t/whoop-instead-of-hrm/61888/26 [Forum].

**MG gegen 4.0 [Forum].** Mehrere Nutzer berichten niedrigere HRV nach dem Wechsel auf 5.0/MG. Zahlen: „von ca. 55 auf 38–40“, „von Mitte 50 auf Mitte 40“, „über 50 % Abfall“. Nach Rückwechsel auf die 4.0 wieder die alten Werte. Genannte Ursache: die MG sitzt am Handgelenk, die 4.0 oft am Bizeps; einer sah nach einigen Nächten am Bizeps wieder bessere HRV. Support: falsches Tragen oder Hautempfindlichkeit; keine offizielle Erklärung. Quelle: https://community.whoop.com/t/drop-in-hrv-after-switching-to-whoop-5-0-and-wearing-it-on-wrist-anyone-else/1714. Weitere Klagen über schlechtere Pulsgenauigkeit der MG: https://community.whoop.com/t/whoop-5-0-hr-inaccurate-much-worse-than-4-0/2381 und Tragehinweis (eine Fingerbreite über dem Handgelenkknochen): https://www.community.whoop.com/t/strain-on-mg-is-lower-for-same-activities-than-with-my-4-0/2034. Reddit-Beiträge: bei der Suche nicht gefunden.

---

## 3. Offene Apps ohne Abo

**NOOP** (https://github.com/ryanbr/noop, Ordner `Packages/StrandAnalytics/Sources/StrandAnalytics/`). Dateien selbst gelesen.
- `HRVAnalyzer.swift`: RMSSD und SDNN nach Task Force 1996. Bereichsfilter 300–2000 ms. Malik-Regel: Abweichung > 20 % vom Median der 4 Nachbarn (Radius 2) = raus. Mindestens 20 saubere Intervalle (`minBeats`). Die Datei nennt selbst: Kubios/Lipponen sei auf dem Gerät nicht verfügbar, Malik sei die einfachere Näherung.
- Lückensicher: `cleanRRGapAware`, `rmssdGapAware`. Eine Differenz zählt nur, wenn beide Schläge im Original direkt aufeinander folgten.
- `SleepStager.sessionHrvWindows`: Fenster 5 min **ohne Überlappung**, ein Fenster zählt ab 20 sauberen Schlägen. Nacht = einfaches Mittel der Fenster. Jedes Fenster trägt seine Schlafphase.
- Schalter `deepHrvWindow` (#141): nur Tiefschlaf-Fenster, „WHOOP-artig“. Standard ist die ganze Nacht. Der Tracer gibt je Nacht drei Werte aus: ganze Nacht, nur Tief, letzte Tiefschlaf-Folge (`lastDeepRun`).
- Täglicher Wert = Mittel der Sitzungen, gewichtet nach Dauer.
- Abdeckungsprüfung (`classifyCoverage`, `rrCoverage`): Summe der RR-Zeit gegen Wanduhr. Zu hohe Abdeckung (doppelte Schläge) = RMSSD verweigert (`successiveDiffIsTrustworthy`, #1118), damit keine falsche Zahl in die Basislinie läuft. `beatAccurateFraction`: Anteil der Schläge, deren Zeitstempel-Abstand zum RR-Wert passt (Toleranz 0,5 s); unter 0,5 sind die Werte keine echten Schlag-zu-Schlag-Messungen. Für Oura gefunden: 2,6–6,6 %.
- Kommentar im Code: die RR der WHOOP 5/MG seien PPG-abgeleitet und verrauschter als die der 4.0; ein Jitter-Ausschlag bläht RMSSD, darum die Malik-Bereinigung (#262/#235).
- `Baselines.swift`: Exponentielles Mittel, Halbwertszeit 14 Nächte (Mitte) und 21 (Streuung). Winsorisieren bei ±3 Streuungen, harter Ausreißer ab 5. Start ab 4 Nächten, volles Vertrauen ab 14. Junge Basislinie (< 8 Nächte): Halbwertszeit 3, Ausreißer-Tor aus, Streuung ×2,5. Grund: ein zu hoher Start verankerte die Basislinie 2–3 Wochen (Reddit-Bericht, im Code zitiert). Mindeststreuung 5 ms linear.
- Bereitschaft (`readiness_hrv_ln`) rechnet in ln, Streuungsuntergrenze 0,08 ln; Kommentar: echte Nacht-zu-Nacht-Streuung ca. 0,10 ln. Die Erholung (`RecoveryScorer`) bleibt linear.
- Der NOOP-Eintrag für Oura: „HRV nicht möglich, gebündelte Intervalle blähen die Streuung; keine Zahl anzeigen“. Gleiche Haltung wie „kein erfundener Wert“.

**OpenWhoop** (https://openwhoop-d68.pages.dev/, Seite war beim Abruf nicht erreichbar; Angabe aus Suchtreffer): RMSSD aus RR zwischen 02:00 und 06:00, Malik-Filter, nicht klinisch validiert.

**OpenStrap** (https://github.com/OpenStrap/research, im Code zitiert): `rr_correction.dart` (Lipponen/Peltola), Messung der Lag-1-Autokorrelation: Gen4 −0,06…−0,32, Gen5/MG −0,43…−0,52. Nicht neu geprüft; der Atlas-Code zitiert es bei `WACF1_FLOOR`.

**OpenVitals (sourcetms) und wearable5.0:** unter diesen Namen nichts gefunden (GitHub-Seite lieferte 404, Suche ohne Treffer). Weitere NOOP-Forks nennen sich ähnlich (app-noop/noop, NoopApp/noop). In keiner gefundenen Quelle ist die MG-RR-Dekodierung belegt. Die Suche ergab, das RR-Paketformat sei nur für die 4.0 beschrieben. Das Atlas-Projekt dekodiert die MG selbst (`wparseV18` und `wparseR24`, Zeilen 10734–10790).

---

## 4. MG-Besonderheiten

**Was der Atlas-Code über die Daten weiß** (Zeilen 10734–10790):
- Das Band schickt eine Sekunden-Zusammenfassung. Je Sekunde stehen bis zu 4 (v18) oder 8 (v24) RR-Werte als Ganzzahl in ms. Auflösung also 1 ms im Wert, aber jeder Wert hat Zeitstempel nur auf die Sekunde (`rec.ts`).
- Die Zeitstempel der Schläge im Fenster sind darum nur grob: `ts*1000` je Record, mehrere Schläge teilen sich eine Sekunde. Echte Schlagzeiten lassen sich nur aus der Summe der Intervalle ableiten.
- Platzhalter: bei fehlendem Schlag meldet das Band oft genau 500 / 333 / 334 ms (`_wIsPh`). Diese sind fehlende Schläge und werden nicht überbrückt.
- Rundungsraster: `wBeatGrid` prüft Raster von 40 … 4 ms. Bei der Messnacht stand „keine“. Es liegt also kein grobes Raster vor (ein 25-Hz-Raster hätte 40 ms gegeben). Die Quantisierung ist demnach nicht das Problem.
- Rauschen: nach OpenStrap (und Atlas-Kommentaren) hat jede MG-Nacht Lag-1-ACF −0,43…−0,52 der Differenzen.

**Zwei Dinge, die ACF nicht beweist [eigen].** Eine einzelne Sinus-Atmung gibt Differenzen mit Lag-1-ACF = cos(2π·f_Atmung/f_Puls). Bei 15 Atemzügen/min und 60/min Puls ist das 0; bei 50/min Puls −0,31; bei 20 Atemzügen/min und 50/min Puls −0,81. Ein ACF von −0,45 ist also auch reine Physiologie bei hoher Atemfrequenz und niedrigem Schlafpuls. Rauschen und Physiologie sind aus der ACF allein nicht zu trennen.
Folgerung: ein statistischer Rauschabzug aus der ACF ist unzuverlässig. Beispiel mit dem Modell des Atlas-Codes (Rauschvarianz je Intervall σ²): bei angenommener echter ACF −0,2 sind 83 % der Differenz-Varianz Rauschen (wahre RMSSD ca. 41 % des Messwerts, also 41 → 17 ms); bei angenommenen −0,35 sind es 67 % (41 → 24 ms). Je nach Annahme ändert sich das Ergebnis um den Faktor 2. Darum gilt: **kein Abzug**, bis es einen Referenzwert gibt (Abschnitt 5).

**Lücken.**
- Das Band sendet pro Sekunde einen Record. Fehlt ein Record, fehlt mindestens ein Schlag. `wCorrectRr` erkennt eine Lücke nur, wenn `(ts[k]−ts[k−1]) − rr[k] > 1000 ms` (Zeile 12220). Im Schlaf mit Puls < 60 (RR > 1000 ms) wird dadurch **ein fehlender Record nicht als Lücke erkannt** (2000 − 1100 = 900 < 1000). Der Code differenziert dann über das Loch. Das hebt RMSSD leicht an.
- Besser: Record-Zeitstempel springt um ≥ 2 s = Lücke, Lauf beenden. Das ist genau, weil Records im 1-s-Takt kommen.

**Jitter und Ausreißer.** Ein Ausreißer-Fenster (RMSSD weit über dem Rest der Nacht) fällt in `wHrvWhoop` weg (Median + 5 robuste SD). Die ACF-Grenze ist für MG ausgeschaltet (`window._wFinGen===5`, Zeile 11000), sonst gäbe es nie Fenster. Das ist richtig, aber `_wFinGen` ist eine globale Variable (Zeile 12692): zerbrechlich.

**Sensor und Sitz [Forum und eigen].** Die MG sitzt am Handgelenk. Dort sind Perfusion und Bewegungsstörung schlechter als am Oberarm. Nutzerberichte zeigen niedrigere HRV nach Wechsel Bizeps → Handgelenk. Das Muster passt zu stärkerer Bereinigung (Spline ersetzt echte Spitzen) oder zu geringerer Pulsamplitude; belegt ist es nicht.

---

## 5a. Sind MG-Werte und 4.0-/WHOOP-App-Werte vergleichbar?

**Kurz: Nein, nicht in ms. Der Trend innerhalb der MG-Nächte ist vergleichbar.**

Gründe:
1. Anderer Sensor, anderer Sitz. Forum-Berichte zeigen Abfälle um 20–50 % nach dem Wechsel auf die MG am Handgelenk, mit Rückkehr nach Rückwechsel (Abschnitt 2).
2. Anderer Rechenweg. Die App-Zahl kommt aus WHOOPs Cloud (eigener Filter, eigene Gewichte, eigenes Staging). Atlas rechnet aus den Roh-Intervallen mit eigenem Staging. Gleiche Nacht, andere Fenster, andere Zahl.
3. Anderes Rauschen. MG-Intervalle haben stärkeres Zeitrauschen (OpenStrap). Rauschen hebt RMSSD, Bereinigung senkt sie. Die Richtung des Nettoeffekts ist ohne Referenz offen.
4. Die Nacht ist kurz und der Ruhepuls hoch (5:49 h, RHR 69). Das kann echt niedrige HRV sein.

Mögliche Ursachen für 41,4 ms (nach Wahrscheinlichkeit; alle ungeprüft):
- A. Echte Nacht: erste Nacht mit neuem Band, kurz, RHR 69. Gegenprobe: Nächte 2–5 abwarten.
- B. Gewichtung und Staging: Atlas gewichtet Tiefschlaf bis 2× (`1+deep/10`) und späte Nacht 0,6–1,4×. Erkennt das Staging am Handgelenk kaum Tiefschlaf, fehlt dieses Gewicht. Gegenprobe: drei Werte je Nacht ausgeben wie NOOP (ganze Nacht ungewichtet, gewichtet, nur Tiefschlaf).
- C. Bereinigung kappt echte Variabilität: Schwelle `cleanFraction ≥ 0,7` lässt bis 30 % korrigierte oder verworfene Schläge zu. Gegenprobe: Anteil `_hrvFixed`/`_hrvClean` je Nacht ansehen.
- D. Sitz und Hautkontakt der MG (Forum). Gegenprobe: Band eine Fingerbreite über dem Handgelenkknochen, eng, und Nächte vergleichen.
- E. Frühere Zahl stammte aus dem WHOOP-Export oder der WHOOP-App. Das ist eine andere Skala.

**Folgen für die Basislinie.**
- MG-Nächte nur mit MG-Nächten vergleichen. `wBaseline` tut das (`g5`, Zeile 15982). Das bleibt Pflicht.
- Der Export-Startwert (`S.whoopRef.base.hrvMs`) wird für MG schon ausgelassen (`ref=null` für g5). Richtig. Er darf auch nicht als Streuungs-Vorgabe zurückkehren.
- Bis 4 MG-Nächte: „Kalibrierung“. Bis 14 Nächte: „vorläufig“. Erst danach voller Wert.
- Alte 4.0-HRV nie als ms neben MG-HRV in Diagrammen. Wenn nötig, als z-Wert.
- Die Oberfläche braucht den Hinweis „MG-Skala, nicht mit der WHOOP-App vergleichbar“. `_hrvGenNote` liegt schon im Tag, ist aber nur auf der Bandseite sichtbar. Er gehört auf die Herz-Seite neben die HRV-Zahl.
- Die Erholung nutzt z = (HRV − Median)/SD. Eine feste Verschiebung der Skala (z. B. MG immer 20 % niedriger) kürzt sich dort heraus, wenn Median und SD aus denselben MG-Nächten stammen. Das ist der eigentliche Schutz. Rechnen in ln macht den Schutz auch bei Verhältnisfehlern gültig (Abschnitt 7).

---

## 5. Quelle der Wahrheit und beste Methode mit MG-Daten

**Wahrheit.** Der Nachtwert einer EKG-Brustgurt-Aufzeichnung (Polar H10, R-Zacken, Lipponen-Korrektur, 5-min-Fenster, lnRMSSD, gleiche Gewichte). PPG ist nur ein Ersatz dafür. Beleg: Validierungsstudien messen alle gegen EKG oder H10 (Abschnitt 1). Eine MG-Referenz gegen EKG fehlt in der Literatur (nicht gefunden).

**Beste Methode mit den Daten, die die MG liefert.** Das ist die Methode, die Atlas schon fast hat, mit sechs Korrekturen:
1. Nur Schlaf, Wachphasen und Bewegung raus (WHOOP, Oura, Fitbit machen das).
2. Fehlschläge nach Lipponen/Tarvainen korrigieren. Wo zwei oder mehr Schläge hintereinander falsch sind: Lauf trennen, nie überbrücken (Kubios-Praxis, `wCorrectRr` tut das).
3. Lücken exakt trennen (Record-Zeitstempel), sonst steigt RMSSD.
4. 5-min-Fenster mit 30 s Schritt, ln, gewichteter Mittelwert in ln. Grund: ln ist normalverteilt genug, ein Ausreißer-Fenster zählt nicht überproportional (AIS-Leitfaden).
5. Genug saubere Nacht verlangen (Abschnitt 7), sonst keine Zahl. Grund: ein Wert aus 10 Minuten ist kein Nachtwert (Fitbit verlangt 3 h Schlaf).
6. **Kein** statistischer Rauschabzug, solange es keine Referenz gibt (Abschnitt 4, Herleitung: Faktor 2 Unsicherheit). Die Basislinie braucht keine „wahre“ ms-Zahl, nur eine stabile Skala.

**Warum das reicht.** Recovery misst Abweichung von der eigenen Basislinie. Ein stabiler Messfehler (gleiches Rauschen jede Nacht) kürzt sich in z = (ln HRV − μ)/σ heraus. Es zählt, dass die Methode jede Nacht gleich rechnet und die Basislinie nur aus Nächten derselben Methode und Version besteht (`_avN`-Regel gibt es schon).

**Referenz nachholen (zwei Wege, beide eigene Idee).**
- A. Polar H10 oder jeder EKG-Gurt für 3–5 Nächte parallel. Dann Abzugsfaktor oder Offset als feste, belegte Zahl ableiten. Das ist der saubere Weg.
- B. Das 30-s-Finger-EKG der MG (`ecgAnalyze`, Zeile 4547). Während der Aufnahme laufen die PPG-Intervalle des Bandes weiter. RMSSD der EKG-R-Zacken gegen RMSSD der Band-Intervalle desselben Zeitraums. Einschränkung: die EKG-Abtastrate ist nicht belegt („aus Messwerten/Dauer geschätzt“), 30 s sind nur ca. 30 Schläge, der Finger-EKG-Moment ist Wachruhe, nicht Schlaf. Taugt als Plausibilitätstest über viele Aufnahmen (≥ 20), nicht als Eichung.

---

## 6. Lücken und Fehler im Atlas-Code

Stand: `index.html`, `WALGO_VER = 24` (Zeile 13560). Zeilen sind die Zeilen im Dokument am 26.11.

| # | Befund | Ort | Wirkung | Schwere |
|---|---|---|---|---|
| L1 | Mindestdaten: `wHrvWhoop` verlangt nur **6 Fenster** (`all.length<6`, `vals.length<6`). 6 Fenster im 30-s-Schritt decken nur 7,5 min. | 10996, 11001 | Ein Nachtwert aus 7,5 min Daten wird angezeigt und fließt in Basislinie und Erholung. Fitbit verlangt ≥ 3 h Schlaf. | hoch |
| L2 | Lückenerkennung: `(ts[k]−ts[k−1]) − rr[k] > 1000`. Bei RR > 1000 ms (Schlafpuls < 60) wird ein fehlender 1-s-Record nicht erkannt. | 12220 (`wCorrectRr`) | Differenz über ein Loch hebt RMSSD. Im Schlaf bei vielen Menschen genau der Normalfall. | mittel |
| L3 | Mittelwert linear: `wm` mittelt RMSSD in ms. Die Erholung rechnet z in ms (`zH`, Zeile 16036) mit linearer Basislinie. | 11005, 15982 ff., 16036 | Ausreißer-Fenster ziehen den Wert nach oben; die Streuung hängt am Niveau. Plews/AIS: ln. | mittel |
| L4 | Sauber-Schwelle `cleanFraction ≥ 0,7` (bis 30 % korrigiert/verworfen) und `n ≥ 100` Paare. Kubios nennt bei Artefakten > 5 % „gering/mittel“; ab 3–6 % wächst der Fehler. | 10979, 10990–10992, 12562 | Fenster mit viel Spline-Ersatz zählen gleich wie saubere. Bei MG-Jitter ist das besonders wahrscheinlich. | mittel |
| L5 | Rückfall ohne Fenster: bei < 6 Fenstern gilt `wHrvClean` über die ganze Nacht, bei erkanntem ACF < −0,2 mit **Rauschabzug** (`WHRV_RHO = −0,2`). Das ist eine andere Methode als die Fenster-Nächte. | 12158, 12248–12290, 12888 | Eine Nacht mit anderer Methode läuft ohne Marke in dieselbe Basislinie. Der Abzug hängt an einer Annahme (Abschnitt 4). | hoch |
| L6 | Ausreißer-Filter nur nach oben und linear: `hi = md + 5·max(1,4826·MAD, 0,1·md)`. Kein Filter nach unten. | 10997–10999 | Niedrige Fenster aus Überkorrektur oder Bewegung bleiben. | niedrig |
| L7 | ACF-Fenster-Filter ist für MG abgeschaltet über die Global-Variable `window._wFinGen===5`. Die Variable wird in `wFinalizeDay` gesetzt. | 11000, 11083, 12692 | Zerbrechlich: wer `wHrvWhoop` außerhalb von `wFinalizeDay` aufruft (Test, Rechnung für einen anderen Tag), bekommt das falsche Verhalten. | niedrig |
| L8 | Gewichte `w=(1+deep/10)·(0,6+0,8·pos)` sind erfunden. Im Code steht selbst, der Puls im „Tiefschlaf“ liege am Handgelenk oft höher als im Leichtschlaf. Tiefschlaf-Erkennung ist damit unsicher. | 10994 | Nachtwert hängt an der Staging-Qualität. Es gibt keine Diagnose, die zeigt, wie viel die Gewichte ändern. | mittel |
| L9 | Plausibilität nur nach oben (> 180 ms). Kein unterer Grenzwert, keine Prüfung auf „Wert aus fast keinem Schlaf“. | 12895 | 8 ms oder 300 ms-Spitzen sind nur durch 180 gefiltert. | niedrig |
| L10 | Basislinie MG: ohne Export-Startwert (`ref=null`) wird die Streuung bei 4–13 Nächten **nicht** mit einem Vorwert gemischt. SD aus 4 Nächten per MAD ist sehr unsicher; Untergrenze nur `max(3, 8 % von med)`. | 15982 ff. (`wBaseline`), Zeile `if(ref&&out.length<14)` | Erholung der ersten 2 Wochen springt stark (z mit zu enger SD). NOOP löst das mit schnellem Anpassen und aufgeblasener Streuung. | hoch (Anfang) |
| L11 | Keine Winsorisierung in der Basislinie. Median/MAD ist robust, aber eine Reihe niedriger Nächte (Infekt, Alkohol) verschiebt den Median in 7–10 Nächten. WHOOP macht das auch, Plews nutzt 7-Tage-Mittel plus 60-Tage-Band. | `wBaseline` | Bewusste Wahl, aber nicht dokumentiert. | niedrig |
| L12 | Keine Abdeckungsprüfung (ΣRR gegen Wanduhr, wie NOOP `classifyCoverage`, Obergrenze 1,10). Doppelte Records sind je Sekunde ausgeschlossen (Bitmaske `tsm`, Zeile 11441), aber doppelte Schläge innerhalb eines Records oder gebündelte Intervalle werden nicht erkannt. | `WDayAgg.add` | Ein Kodierfehler der MG (z. B. Records mit Summe ≠ 1000 ms) bliebe unbemerkt. | niedrig |
| L13 | Methodenmarke „keine“ in `_hrvMethod` sagt nicht, was passiert ist. Es gibt keine Nebenwerte (ganze Nacht ungewichtet, nur Tiefschlaf, Anteil korrigierter Schläge je Nacht, Anzahl und Spanne gültiger Fenster) für die Fehlersuche, die MG-Werte so dringend brauchen. | 12904, 11013 | Die Frage „warum 41,4?“ ist nicht beantwortbar. | mittel |
| L14 | Doku veraltet: `docs/berechnungen.md` Zeile 29 sagt „oder Median der 2. Hälfte, wenn höher“. Der Code hat das entfernt (Kommentar Zeile 11006–11010: „Die Nacht zählt jetzt ganz“). | berechnungen.md:29 | Doku und Code widersprechen sich. | niedrig |
| L15 | Recovery-Gewicht 0,83·zH wurde an WHOOPs 4.0-Daten in **ms-z** gefittet (Kommentar bei `wComputeRecovery`, 309 Tage, 7,4 Punkte Abweichung). Auf MG-ln-z übertragen ist das nicht geprüft. | 16024 ff., 16022 | Bei Umstellung auf ln-z muss der Fit neu geprüft werden (Testfall T9). | mittel |

**Was schon gut ist (nicht anfassen):** Fenster 5 min/30 s wie WHOOP, Lipponen-Korrektur mit Spline und Laufschnitt, Platzhalter 500/333/334 nie überbrücken (`_wIsPh`), Teilnächte nie in die Basislinie (`_wPartNight`), MG nur gegen MG (`g5`), „ohne HRV keine Erholung“, Rohdaten-Version (`_avN`) in der Basislinie, Rauschabzug in den Fenstern aus.

---

## 7. Bauanleitung

Ziel: eine Rechnung, ein Wert je Nacht, jede Nacht gleich.

**[Review: geändert] `WALGO_VER` bleibt 24.** Grund: `wBaseline` (Zeile 15988) wirft jede Band-Nacht mit `_avN < WALGO_VER` aus den Basislinien von HRV, Ruhepuls und Atmung. Rohdaten liegen nur 3 Tage (`WEP_KEEP_DAYS=3`, Zeile 11542). Ein Sprung auf 25 löscht also alle älteren Nächte aus den Basislinien. `wRecomputeStored` rechnet danach die Erholung ALLER Bandtage neu, auch der 4.0-Tage. Deren Erholung fiele auf den Export-Startwert oder ganz weg. Stattdessen gilt eine eigene HRV-Version `_hrvV` (neu, Wert 2) mit Übergang ohne Datenverlust. Regeln: docs/plan-review.md, Abschnitt "Entscheidung WALGO_VER".

### 7.1 Schritte der Nacht-HRV

Eingang: [Review: Schnittstelle festgelegt] Die Schlagliste der Nacht aus `wRrChain` (Regel K1–K5, docs/plan-review.md) und das Schlafobjekt `slp` aus dem Schlafplan (Schnittstelle S1): `slp.blocks` (Haupt- und Teilblöcke, Sekunden Unix), `slp.stageAt(t)` ('wake'|'light'|'deep'|'rem'), `slp.on`/`slp.off` (Sekunden). Nickerchen zählen nicht.

1. **Schlafmenge.** Nur Epochen im Schlaffenster. Epochen mit Phase „wach“ fallen weg. Teilnacht (`_wPartNight`) = kein HRV-Wert für die Basislinie (besteht).
2. **Rohfilter.** RR im Bereich 300–2000 ms. Platzhalter 500/333/334 bei langem lokalen Takt (`_wIsPh`) = fehlender Schlag, Klasse „x“ (besteht).
3. **Lücken** [NEU, L2; Review: korrigiert]. Es gilt die gemeinsame RR-Kette `wRrChain` aus docs/plan-review.md (Regel K3). Kurz: Ein Lauf endet, wenn zwischen zwei Schlag-Records eine Sekunde **ohne Record** liegt (Bitmaske `sm` der Epoche) **oder** wenn `(Δts − rr) > 1000 ms` (alte Regel bleibt zusätzlich). Achtung: Der Plan sagte vorher "ts springt ≥ 2 s". Das ist falsch. `e.recs` speichert nur Records MIT Schlägen (Zeile 11469). Bei Puls < 60 hat fast jede 10. Sekunde keinen Schlag. Die alte Formulierung hätte bei jedem langsamen Schlag geschnitten.
4. **Korrektur** (`wCorrectRr`, besteht). Einzelner falscher Schlag = Spline. Zwei oder mehr falsche Schläge in Folge = Lauf trennen. Zähle `corrected` und `dropped`.
5. **Fenster.** 5 min (10 Epochen), Schritt 1 Epoche (30 s). [Review] Fenster nach Zeit, nicht nach Index: alle 10 Epochen von t0 bis t0+300 s müssen vorhanden sein und im selben Schlafblock liegen. Heute zählt der Code Indizes (`a..a+10`, Zeile 10987). Fehlt eine Epoche, spannt ein "5-min-Fenster" sonst mehr Zeit. Ein Fenster zählt nur, wenn:
   - höchstens 1 Wach-Epoche (besteht);
   - `cleanFraction ≥ 0,85` [NEU, L4; war 0,7; eigene Schwelle. Review: erst setzen, wenn die Diagnose (7.3) die Verteilung von `cleanFraction` über ≥ 3 MG-Nächte zeigt. Bei MG-Jitter kann 0,85 zusammen mit Schritt 9 jede Nacht ohne Wert lassen. Bis dahin 0,7 lassen.];
   - Paare in den Läufen ≥ 70 % der erwarteten Schläge (300 s × mittlerer Puls / 60) [NEU; war fest 100; eigene Schwelle].
6. **Fenster-RMSSD.** √(mittel(ΔRR²)) über Differenzen **innerhalb** der Läufe. `r = ln(RMSSD)`.
7. **Artefakt-Fenster.** Verwirf Fenster mit `r > Median(r) + 4·max(1,4826·MAD(r), 0,15)` [NEU: ln statt linear, L6; Parameter eigene Wahl, prüfen]. Nach unten kein Schnitt. ACF nur melden (`_acf1`), nicht filtern (MG-Regel bleibt, aber als Parameter `gen` statt Global, L7).
8. **Rauschabzug.** Keiner. Ein erkanntes Rundungsraster wird exakt abgezogen (besteht, Sheppard). Der Rückfall `wHrvClean` mit `rauschabzug` für das Nachtmittel entfällt (L5). Reicht die Fensterzahl nicht, gibt es keinen Wert.
9. **Mindestdaten** [NEU, L1]. Die Vereinigung der gültigen Fenster deckt ≥ 60 min Nacht ab (Vereinigung der Zeitspannen, nicht Fensterzahl) **und** ≥ 25 % der Schlafzeit. Zusätzlich: gültige Fenster aus mindestens 2 der 3 Nachtdrittel (Drittel der Spanne `slp.on` bis `slp.off`). Sonst `hrvMs` fehlt, `_hrvNote='zu_wenig_saubere_daten'`, keine Erholung. „Gut“ (Anzeige ohne Hinweis) ab ≥ 120 min. Eigene Schwellen; Fitbit nutzt 3 h Schlaf als Mindestperiode, Polar die ersten 4 h.
10. **Gewichte.** Beibehalten `w = (1 + deep/10)·(0,6 + 0,8·pos)` bis die Diagnose (7.3) belegt, dass sie etwas bringen. Nur ein einziges Gewichtsschema für Basislinie und Anzeige.
11. **Nachtwert.** `lnHRV = Σ w·r / Σ w`, `HRV = exp(lnHRV)`, gerundet auf 0,1 ms. Speichere beides: `hrvMs` und `hrvLn`.
12. **Plausibilität.** `10 ≤ HRV ≤ 180` [NEU unterer Wert, L9]. Sonst `_hrvNote='unplausibel'`, kein Wert.
13. **Marken.** `_hrvMethod` = `'fenster_ln_gewichtet'` (+ `'+raster_Xms'` falls Raster). `_hrvConf='eingeschränkt'` bei MG bleibt, bis Referenz da ist.

### 7.2 Basislinie

- **Skala:** ln. Speichere je Nacht `hrvLn`. Ältere Nächte ohne `hrvLn`: `ln(hrvMs)`.
- **Nächte:** die letzten 30 Tage vor dem Tag. Nur MG-Nächte (`_gen===5`, `_src==='band'`), nur Nächte mit `_avN ≥ WALGO_VER` (bleibt 24), keine Teilnächte, nur Nächte mit `hrvMs` (Schritt 9 lässt es sonst fehlen). [Review] Nächte mit `_hrvV===2` liefern `hrvLn`. Ältere MG-Nächte ohne Rohdaten bleiben drin: `hrvLn = ln(hrvMs) − δ`. δ = Median von `ln(_hrvOldMs) − hrvLn` über die Nächte, die mit beiden Methoden gerechnet wurden (Migration, docs/plan-review.md). Ohne δ (noch keine solche Nacht): δ = 0 und die Erholung trägt "vorläufig".
- **Mitte:** Median von `hrvLn`. **Streuung:** 1,4826·MAD. Untergrenze 0,10 ln (NOOP-Kommentar: gemessen ca. 0,10 ln). [eigen: war 8 % von med ≈ 0,077 ln].
- [Review] Eigene Funktion `wBaselineLn('hrvLn', …)` oder Feld `hrvLn` in `wBaseline`. Der ms-Pfad `wBaseline('hrvMs')` bleibt unverändert für 4.0-Tage und Export-Tage. So ändert sich keine Erholung der 4.0-Zeit.
- **Wenig Nächte** [NEU, L10]: bei n < 14 wird die Streuung mit einem Vorwert 0,14 ln gemischt: `σ = (σ_n·n + 0,14·(14−n))/14`. Grund: SD aus 4 Nächten ist zufällig (NOOP „early-life“: zu enge Streuung ließ Charge auf 1–2 fallen). Der Vorwert 0,14 ist eigene Schätzung; mit den ersten 14 MG-Nächten prüfen und ersetzen.
- **Start:** ab 4 Nächten „vorläufig“ (Hinweis „n/14“), ab 14 „voll“. Unter 4: keine Erholung (besteht, „Kalibrierung“).
- **Ausreißer:** [Review: gestrichen] Winsorisieren ändert Median und MAD nicht. Ein begrenzter Wert bleibt auf derselben Seite und behält seinen Rang. NOOP braucht es, weil NOOP ein exponentielles Mittel rechnet. Atlas bleibt bei Median/MAD. Das ist schon robust. L11 ist damit nur Doku.
- **Export-Werte, 4.0-Nächte:** nie in die MG-Basislinie. Auch nicht als Vorwert für die Streuung.
- **Anzeige:** 7-Tage-Mittel von `hrvLn` (zurück in ms) und Normalband = Mitte ± 0,5 σ (SWC nach Plews). Tag-zu-Tag-CV als Zweitwert. Hinweis „MG-Skala“ neben der Zahl.

### 7.3 Einspeisung in die Erholung

- `zH = clamp((hrvLn − μ)/σ, −2,5, 2,5)`. Statt ms jetzt ln. Nur für MG-Tage (`g5`). 4.0- und Export-Tage rechnen weiter in ms. `zR` und `sp` unverändert.
- `wRecFormula` bleibt zunächst gleich (0,83·zH …). Vor dem Umstellen offline prüfen: dieselbe Logistik auf den 309 WHOOP-Export-Tagen, einmal mit ms-z, einmal mit ln-z. Nehme ln, wenn die mittlere Abweichung zu WHOOPs Erholung nicht schlechter als 7,4 Punkte wird. Sonst Koeffizient neu anpassen.
- Ohne gültige HRV keine Erholung (besteht).
- Hinweis „vorläufig“ bei n < 14 Nächten an der Erholung.
- **Diagnose** (nur Anzeige, ändert nichts): je Nacht drei Werte speichern: `_hrvAllUnw` (ganze Nacht ungewichtet, ln-Mittel), `_hrvDeep` (nur Tiefschlaf-Fenster), `_hrvLastSws` (letzte Tiefschlaf-Folge, wie NOOP `lastDeepRun`); dazu `_hrvFixedPct`, `_hrvValidMin`, `_hrvWin`, `_hrvRej`, `_acf1`. [Review] Dazu `_hrvOldMs` (Wert nach alter Methode, nur in der Übergangszeit) und `_hrvV`. 14 Nächte sammeln, dann entscheiden, ob die Gewichte in Schritt 10 bleiben.

### 7.4 Testfälle (Eingabe → erwartete Ausgabe)

Alle als reine Funktionstests im bestehenden Prüfblock (Zeile 14470–15300: `ck`, `ckI`) aufnehmen.

**T1: Definition.** 300 Schläge, RR wechselt 800/840/800/840 … (alle Differenzen ±40). Ohne Artefakt. → Fenster-RMSSD = 40,0 ms (±0,1). `_hrvFixed` = 0.

**T2: Lücke trennt den Lauf** [Review: neu gefasst]. 300 Schläge RR 1100/1140 im Wechsel. Schlagzeit = Summe der RR. `ts` = ganze Sekunde der Schlagzeit. Jede Sekunde hat einen Record (`sm`-Bit gesetzt), auch ohne Schlag. (a) Ohne Verlust: → 1 Lauf, RMSSD = 40,0 (±0,1). Prüft, dass Sekunden ohne Schlag NICHT schneiden. (b) Der Record der Sekunde mit Schlag 151 fehlt (Bit gelöscht, Schlag entfernt). → 2 Läufe, RMSSD = 40,0 (±0,1). Die alte Regel `(Δts − rr) > 1000` findet das nicht (Δts 2000 − 1140 = 860) und liefert 1 Lauf mit einer Differenz über das Loch. (c) Wie (b), aber RR nach dem Loch 900/940: alte Regel ergibt eine Zusatzdifferenz von 200 bis 240 ms, neue Regel 2 Läufe und 40,0.

**T3: Ein Extraschlag.** 300 Schläge 800/840 im Wechsel (gerade Stelle 800). Schlag 151 (sonst 840) wird 480, Schlag 152 (sonst 800) wird 1160. Folge: …, 800, 480, 1160, 840, …. → ohne Korrektur: drei Differenzen −320, +680, −320 statt ±40. Summe 299·1600 − 3·1600 + 667 200 = 1 140 800; /299 = 3815 → RMSSD **61,8 ms** [Review: alt 62,5 passte zu keiner Folge]. Mit Korrektur: RMSSD = 40 ± 2 ms, `corrected ≥ 1`, Fenster zählt (cleanFraction ≥ 0,7 bzw. 0,85).

**T4: ln-Mittel.** Vier gleich gewichtete gültige Fenster mit RMSSD 30, 30, 30, 120. → Nachtwert = exp(Mittel ln) = (30³·120)^(1/4) = **42,4 ms** (lineares Mittel wäre 52,5). `hrvLn` = 3,748.

**T5: Mindestdaten.** Nachtdaten, aus denen nur 30 gültige, aufeinanderfolgende Fenster entstehen (Vereinigung = 29·30 + 300 = 1170 s = 19,5 min). → `hrvMs` fehlt, `_hrvNote='zu_wenig_saubere_daten'`, keine Erholung. (Die alte Regel `< 6` würde den Wert zulassen.) Gegenprobe: gültige Fenster über 90 min in allen 3 Dritteln → Wert vorhanden, „vorläufig“ nicht gesetzt ab 120 min.

**T6: Basislinie und Erholung.** 14 MG-Nächte mit HRV 40, 42, 38, 41, 43, 39, 40, 41, 42, 40, 39, 41, 40, 42 (Median 40,5). Heute 41,4. Ruhepuls gleich Median (zR = 0), Schlafleistung 85. → σ = Untergrenze 0,10 (die MAD aus diesen Werten liegt darunter), z = (ln 41,4 − ln 40,5)/0,10 = 0,22, logit = 0,83·0,22 + 0,878 = 1,061 → **Erholung 74 %**.

**T7: MG nur gegen MG.** 10 Nächte `_gen=4` mit HRV 80, dazu 3 MG-Nächte mit HRV 40, heute MG 41. → `wBaseline` = null (n = 3 < 4), keine Erholung, Text „Kalibrierung 3/4“. Mit der vierten MG-Nacht: Median = 40, 4.0-Nächte nicht eingerechnet.

**T8: Wenige Nächte, Streuung.** 4 MG-Nächte 40, 41, 40, 41 (MAD 0,5 ms; ln-SD ca. 0,018, unter der Untergrenze 0,10). → σ gemischt = (0,10·4 + 0,14·10)/14 = **0,129** (Untergrenze 0,10 wäre kleiner). Heute 36: z = ln(36/40,5)/0,129 = −0,91 statt −1,18 mit Untergrenze 0,10. Erholung hängt damit nicht an einer zufällig engen Streuung.

**T9: Ausreißer.** 14 Nächte um 40 ms plus eine Nacht 150 ms (nach Plausibilität 180 erlaubt) und eine 12 ms. → Median bleibt 40 (±1), σ bleibt an der Untergrenze 0,10 (robust durch MAD, ohne Winsorisieren).

**T10: Plausibilität.** Fensterwerte ergeben 200 ms; ein zweiter Fall 8 ms. → in beiden Fällen kein `hrvMs`, `_hrvNote='unplausibel'`.

**T11: Jitter wird nicht abgezogen.** Wahres RR konstant 1000 ms, dazu weißes Rauschen σ = 20 ms je Intervall (ganzzahlig gerundet, fester Seed). → Fenster-RMSSD ≈ 20·√2 = 28,3 ms (±2), ACF ≈ −0,5, `_hrvMethod` ohne `rauschabzug`. (Der Test hält die bekannte Überschätzung fest. Er soll nach einer H10-Eichung angepasst werden, nicht still.)

**T12: Rückfall entfernt.** Nacht mit 5 gültigen Fenstern aber 8 h Rohdaten, ACF −0,45. → kein Wert (statt Rauschabzug-Wert). `_hrvMethod` bleibt leer.

**T13: Übergang ohne Verlust** [Review: neu gefasst]. 10 MG-Nächte ohne Rohdaten mit `hrvMs` 45 und ohne `_hrvV`. 3 MG-Nächte mit Rohdaten: alt 45, neu 43 (`_hrvOldMs`=45, `hrvLn`=ln 43). → δ = ln(45/43) = 0,0455. Alle 13 Nächte zählen. Alte Nächte gehen mit ln 45 − 0,0455 = ln 43,0 ein. Median = ln 43,0. Keine Nacht fällt heraus. `_avN` bleibt 24 an allen Nächten. Zusatz: Ein 4.0-Tag mit Erholung behält nach dem Umbau dieselbe `recoveryScore` (ms-Pfad unverändert).

### 7.5 Reihenfolge der Arbeit

1. Diagnose (7.3, nur Anzeige) und Test T1–T5 zuerst: ändert keine Zahl, zeigt aber, warum 41,4 ms.
2. L2 (Lücke) und L1/Schritt 9 (Mindestdaten): kleine Eingriffe, hohe Wirkung.
3. ln-Mittel und ln-Basislinie samt Vorwert-Streuung (L3, L10). `WALGO_VER` bleibt 24; `_hrvV=2` plus Migration (δ). Erholung gegen Export-Tage prüfen (T6, L15).
4. Rückfall `rauschabzug` entfernen (L5). Doku `berechnungen.md` Zeile 29 angleichen (L14).
5. H10-Parallelnächte: erst danach über einen Rauschabzug oder einen MG-Offset entscheiden.

**Kurzantwort auf die Frage des Nutzers:** 41,4 ms sind nicht falsch, aber nicht mit der alten Zahl vergleichbar. Die MG liest nach Forumberichten oft 20–50 % tiefer als die 4.0, schon durch den Sitz am Handgelenk. Die Erholung korrigiert das über die eigene MG-Basislinie. Bis 14 Nächte stehen, ist die Erholung nur vorläufig.

---

## Review (26.11.2026, Kritiker)

Code-Bezüge geprüft. Zeilen stimmen (10979–11013, 12220, 12895, 13560, 15982). Das Verhalten ist richtig beschrieben.
Geändert:
1. **WALGO_VER bleibt 24.** Der Plan wollte 25. Das hätte alle Nächte älter als 3 Tage aus den Basislinien geworfen (`wBaseline` Zeile 15988, `WEP_KEEP_DAYS=3`). `wRecomputeStored` hätte dann auch die Erholung der 4.0-Tage neu gerechnet. Ersatz: Feld `_hrvV=2`, Messung des Methodensprungs δ an Nächten mit Rohdaten, alte Nächte mit `ln(hrvMs) − δ`. Details in docs/plan-review.md.
2. **Lückenregel 7.1 Schritt 3 war falsch.** `e.recs` speichert nur Records mit Schlägen (Zeile 11469). "ts springt ≥ 2 s" schneidet bei Puls < 60 ständig. Neu: fehlende Sekunde in der Record-Bitmaske `sm` oder alte Regel. Gemeinsam mit Rhythmus und Schlaf (Regel K3).
3. Fenster nach Zeit statt Index (Schritt 5).
4. `cleanFraction 0,85` erst nach der Diagnose setzen. Sonst droht eine MG-Nacht ohne jeden Wert.
5. Winsorisieren gestrichen. Bei Median/MAD ändert es nichts.
6. ln-Basislinie nur für MG-Tage. Der ms-Pfad bleibt für 4.0 und Export.
7. T2 neu: prüft auch, dass Sekunden ohne Schlag nicht schneiden. T3 nachgerechnet: 61,8 ms statt 62,5 (die alte Zahl passte zu keiner Folge). T9 und T13 neu gefasst.
Nachgerechnet und richtig: T4 (42,4 ms, ln 3,748), T5 (19,5 min), T6 (Median 40,5, z 0,22, Erholung 74 %), T8 (σ 0,129, z −0,91 / −1,18), T11 (28,3 ms, ACF −0,5).
Eigene Wahl, bleibt markiert: 60 min / 25 % / 2 von 3 Dritteln, 0,85, 70 % der Schläge, Artefakt-Schnitt 4·max(…, 0,15), Vorwert σ 0,14, Untergrenze 0,10, Plausibilität 10–180.
Widerspruch zu anderen Plänen: keiner mehr. Fenster und Lücken folgen der gemeinsamen RR-Kette.
