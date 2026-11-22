# Recherche: Blutdruck vom WHOOP MG über BLE

Stand: 2026-11-22. Nur Recherche. Kein Code geändert.

## Urteil

- Blutdruck vom Band: **nein**.
- Das Band sendet keinen BP-Wert. Es gibt keinen BP-Record, kein BP-Kommando, kein BP-Feld.
- Rohsignale sind **teilweise** da (PPG, ECG). Ein BP-Schätzer wäre Eigenbau.
- Ein ehrlicher Eigenbau ist ein Trend-Signal mit Manschetten-Kalibrierung. Keine Messung.

## 1. Protokoll-Repos

Gesucht: blood pressure, BP, systolic, diastolic, calibration, cuff, PTT, pulse wave, PWV.

- LeonardSEO/wearable5.0: kein Treffer in FINDINGS.md und `protocol/whoop5_protocol.json`.
  https://github.com/LeonardSEO/wearable5.0
- OpenStrap/protocol: kein Treffer in `dart_header.json` und `lib/`.
  https://github.com/OpenStrap/protocol
- b-nnett/goose: kein Treffer.
  https://github.com/b-nnett/goose
- ryanbr/noop: BP nur im "Lab Book" (Werte von Hand eintragen).
  Limitations-Tabelle: Blood pressure = none für WHOOP 4 und 5.
  `Strand/Screens/NoopLimitationsView.swift`.
  Optik-Doku sagt: BP ist "not expected to be a hidden scalar in this record".
  https://github.com/ryanbr/noop/blob/main/docs/WHOOP5_OPTICAL_EXPERIMENT.md
- ribhupanwar/whoop-mg-client: App zeigt "Blood pressure is not measured by STRAP".
  `ios/Strap/HealthHubView.swift`. BP nur als Screenshot der WHOOP-App (OCR).
  https://github.com/ribhupanwar/whoop-mg-client
- sennnen/maverick: "Not computed on-strap". Kein BP-String in Config, Konsole, Paketen.
  https://github.com/sennnen/maverick/blob/main/docs/protocol/whoop-raw-afe.md
  Achtung: Die Aussage dort "cloud-derived from ECG + PPG (pulse-transit)" ist unbelegt.
  WHOOP nennt kein ECG für BP. Das MG-ECG braucht Fingerkontakt. BP läuft über Nacht.
- Breite GitHub-Codesuche ("blood_pressure", "systolic", "bp_calib" + whoop): nur Cloud-API-Clients und Lab-Logs.

## 2. Was WHOOP selbst sagt

- Eingaben: Herzfrequenz, HRV, Pulswellen-Muster. Über Nacht. Eine Tagesschätzung.
  https://www.whoop.com/us/en/thelocker/blood-pressure-insights/
- Kalibrierung: drei Manschetten-Werte in der App. Neuer Wert etwa alle 30 Tage.
- Nur Mitgliedschaft "Life". Beta. Manschette nicht enthalten.
- Ort der Berechnung: nicht offiziell genannt. Kein BP auf dem Draht. Also App oder Cloud.
- Genauigkeit laut WHOOP: 10.746 Messpaare. Innerhalb 10 mmHg: 88,68 % systolisch, 96,57 % diastolisch.
  https://www.whoop.com/ae/en/thelocker/blood-pressure-insights-accuracy/
- Nicht unabhängig validiert. Keine FDA-Zulassung.
- FDA: Warning Letter Juli 2025. Closeout Juni 2026 nach Umbenennung zu "wellness signal". Das ist keine Clearance.
  https://the5krunner.com/2026/08/21/blood-pressure-watch-accuracy/
  https://www.whoop.com/us/en/thelocker/why-whoop-stands-behind-blood-pressure-insights/
- Nutzer berichten: Wert wiederholt oft nur die letzte Manschetten-Messung.
  https://www.community.whoop.com/t/blood-pressure-insights/7539

## 3. Offene Methoden und Signale

Methoden:
- PWA (Pulswellen-Analyse): Merkmale der PPG-Kurve + Regression. Mit Kalibrierung pro Person.
- PAT/PTT (Pulsankunftszeit): ECG-R-Zacke bis PPG-Fuß. Braucht ECG und PPG gleichzeitig.

Validierung:
- Benchmark González et al. 2023 (Sci Data). 11 ML-Modelle. Offener Code und Daten.
  Viele Modelle schlagen einen trivialen Mittelwert kaum.
  https://doi.org/10.1038/s41597-023-02020-6
  https://github.com/inventec-ai-center/bp-benchmark
- Moulaeifard, Charlton, Strodthoff 2025: bestes Modell MAE 9,0/5,8 mmHg mit Kalibrierung, 13,9/8,5 ohne.
  https://arxiv.org/pdf/2502.19167
- Benchmark 2026: kein Modell erfüllt AAMI/ISO 81060-2 (ME < 5, SD < 8 mmHg).
  https://arxiv.org/html/2602.04725
- Mukkamala: kalibrierte Geräte geben oft nur den Kalibrierwert zurück. ESH empfiehlt sie nicht klinisch.
  https://mdedge.com/jcomjournal/article/263558/hypertension/cuffless-blood-pressure-monitors-still-numbers-game

Signale vom MG:
- 1 Hz HR und RR-Intervalle (R18): ja. Reicht nur für ein HR/HRV-Regressionsmodell. Schwach.
- R20 Optik (nach Kommando 107 ENABLE_OPTICAL_DATA): 25 Hz pro Kanal. HR daraus MAE ~2 bpm.
  Für Kurvenform (Dikrotie, Anstiegszeit) knapp. wearable5.0 FINDINGS §4.
- R26: 40-s-Bursts mit 25 Hz, etwa alle 19 min nachts. FINDINGS §11.
- Raw-AFE (Opcode 63, Paket 43): 100 Hz PPG + ECG. Auf FW 50.33.2.0 belegt.
  Auf FW 50.41.1.0 öffnet der Stream nicht mehr. maverick whoop-raw-afe.md.
- ECG nur mit Fingerkontakt. Also PAT nur als Spot-Messung, nicht nachts.

## Was ein ehrlicher Eigenbau braucht

1. Eigene Manschetten-Werte (validiertes Oberarmgerät). Mehrere, zu verschiedenen Zeiten.
2. Nächtliche PPG-Bursts (R26/R20) speichern. Merkmale pro Nacht bilden.
3. Einfaches Modell pro Person: Abweichung vom Kalibrierwert aus HR, HRV, PPG-Merkmalen.
4. Immer gegen Baseline testen: "letzter Manschetten-Wert". Nur zeigen, wenn besser.
5. Ausgabe als Trend ("höher als deine Basis"). Keine mmHg-Diagnose. Hinweis "keine Messung".
6. Regulatorik: als Wellness-Signal kennzeichnen. Keine Hypertonie-Aussagen.

Ohne Punkt 4 zeigt die App nur den Kalibrierwert mit Rauschen. Genau das berichten WHOOP-Nutzer.
