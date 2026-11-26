## STAND
26.11.: Recherche A und B fertig. Umsetzung A (Schlafleistung, Bedarf, Konsistenz) läuft. B (Pace of Aging) folgt.

# Plan: Schlaf-Score wie WHOOP und Pace of Aging

## 1. Quellen

| Quelle | URL | Warum |
|---|---|---|
| WHOOP Community (Staff-Antwort) | https://www.community.whoop.com/t/how-does-this-new-algorithm-improve-my-sleep-tracking-compared-to-the-old-version/490 | Vier Teile der neuen Schlafleistung: Stunden vs. Bedarf, Konsistenz, Effizienz, Schlafstress. Keine Gewichte. |
| Gadgets & Wearables, Mai 2025 | https://gadgetsandwearables.com/2025/05/05/whoop-new-sleep-score-metric/ | Datum der Umstellung. Vorher war die Schlafleistung nur Stunden / Bedarf. |
| WHOOP Locker, Sleep Consistency | https://whoop.com/thelocker/new-feature-sleep-consistency-why-we-track-it | Konsistenz = Wahrscheinlichkeit, an 4 Tagen zur selben Uhrzeit im selben Zustand (Schlaf/wach) zu sein. |
| WHOOP Community, Restorative in Score | https://www.community.whoop.com/t/incorporate-restorative-sleep-deep-rem-into-sleep-performance-score/9984 | Feature-Wunsch: Tief + REM zählen heute nicht in die Schlafleistung. |
| wearable5.0 (LeonardSEO), re/SCORE_MODELS.md | https://github.com/LeonardSEO/wearable5.0/blob/main/re/SCORE_MODELS.md | WHOOP 5.0/MG, Nov. 2026. Formel SP-C2 out-of-sample 1,25 Punkte. Schuld-Regel gegen die offizielle API (16 von 16 auf die ms). |
| OpenVitals (tohmsc/openvitals-public), whoop-tools/scores.py | https://github.com/tohmsc/openvitals-public/blob/main/whoop-tools/scores.py | Konsistenz-Rechnung (Minuten im gleichen Zustand an 4 Tagen), Patent-Kurve für Strain-Bedarf, lineare Mischung (ein Träger, Mai–Juni 2025, 4,9 Punkte). |
| NOOP (ryanbr/noop), docs/ANALYTICS.md | https://github.com/ryanbr/noop/blob/main/docs/ANALYTICS.md | „Rest“-Score 0,5 Dauer / 0,2 Effizienz / 0,2 Tief+REM / 0,1 Konsistenz. Laut NOOP eigene Mischung, nicht WHOOP. |
| NOOP docs/FITNESS_AGE.md | https://github.com/ryanbr/noop/blob/main/docs/FITNESS_AGE.md | Fitness-Alter nach Nes 2011. Ist kein WHOOP Age. |
| WHOOP Community, WHOOP Age und Pace | https://community.whoop.com/t/what-is-whoop-age-and-pace-of-aging/466 | 9 Metriken, 6 Monate gegen 30 Tage. |
| WHOOP Locker, Healthspan Data Meets Longevity | https://www.whoop.com/thelocker/Healthspan-Data-Meets-Longevity | Pace −1× bis 3×, wöchentlich, ab 21 Erholungen in 31 Tagen. |
| WHOOP Podcast 323 | https://www.whoop.com/thelocker/podcast-323-the-9-metrics-that-make-up-your-healthspan-with-emily-capodilupo/ | Jede Metrik gibt Jahre dazu oder ab. Break-even = gute Langzeitgesundheit. |

Nicht erreichbar: WHOOP-Locker-Seiten direkt (403), Healthspan-White-Paper. Reddit: kein Thread mit Zahlen gefunden.

## 2. Was WHOOP öffentlich sagt (Schlaf)

- Seit Mai 2025: Schlafleistung aus Stunden vs. Bedarf, Konsistenz, Effizienz, Schlafstress. Gewichte nicht veröffentlicht.
- Tief + REM (erholsamer Schlaf) zählen nicht in die Schlafleistung.
- HRV gehört zur Erholung, nicht zur Schlafleistung.
- Bedarf = Grundbedarf + Strain-Bedarf + Schlafschuld − Nickerchen (API liefert diese vier Teile).

## 3. Beste Messung der WHOOP-Formel (wearable5.0, ein Träger, 16 + 9 Nächte)

- Schlafleistung SP-C2 = 94,81929 − 4,67893 · x^−2,88390 + 0,23588 · (Konsistenz − 80). x = Schlaf / Bedarf. Konsistenz fehlt → 80.
- Ausgeschlossen: reines Schlaf/Bedarf und jede Funktion nur von Schlaf/Bedarf.
- Effizienz ging nicht ein (Fehler trotzdem 1,25). Schlafstress: einzige Fehlnacht hatte langen Stress. Kein Gewicht bekannt.
- Schuld (API, 16 von 16 auf 1 ms): Schuld = min(127,8 min, f · (Bedarf − Schlaf)) der letzten Hauptnacht, f = 1/2 oder 9/14. Ohne Schlaf-Eintrag bleibt die Schuld stehen.
- Strain-Bedarf: Patent-Kurve 1,7 h / (1 + e^((17 − Strain)/3,5)) (OpenVitals) und SN-PE (wearable5.0) stimmen auf ±1,5 min überein.

OpenVitals' lineare Mischung (0,678·Stunden% + 0,676·Effizienz + 0,35·Konsistenz − 62,4) ist älter (Mai–Juni 2025) und ungenauer (4,9). Sie wird nicht genutzt.

## 4. Realer Fall 25./26.11. (erste MG-Nacht)

App: Schlaf 5:49 h (5,82 h), Tief 1:07, REM 1:25, HRV 41,4 ms, Score 71.

Alte Formel: 0,707 · min(Schlaf/Bedarf, 1) · 100 + 0,245 · Konsistenz + 3,4.
- Bedarf 8,25 h → Anteil 70,5 % → 49,9 Punkte.
- Konsistenz fehlt (erste Nacht) → Ersatz 65 → 15,9 Punkte. Mit 75–80: 18,4–19,6.
- Konstante 3,4.
- Summe 69–73 → angezeigt 71. Rund 41 % der Punkte kommen aus Ersatz-Konsistenz und Konstante, nicht aus dem Schlaf.
- Die alte Formel war eine lineare Anpassung über Export-Nächte vor und nach der WHOOP-Umstellung (7 Punkte Fehler).

Wie WHOOP rechnen würde:
- Bis Mai 2025: 5,82 / 8,25 = 71 %.
- Seit Mai 2025 (SP-C2, Konsistenz neutral 80): x = 0,705 → 94,82 − 4,679 · 2,74 = **82**.
  Bei Bedarf 8,5 h: 81. Langer Schlafstress senkt den Wert (Größe unbekannt).
- Ehrliches Ergebnis: Der 2025/26-WHOOP-Score ist bei 70 % Bedarf milder als die Intuition. Er bestraft erst unter ~60 % stark (x = 0,5 → 60, x = 0,4 → 29).

HRV 41 ms: gehört in die Erholung. Sie wird nicht in den Schlaf-Score gemischt. Hinweis in der App.
Tief/REM: zählen bei WHOOP nicht. Sie sind bei uns Schätzungen (Kappa ~0,13). Sie bleiben draußen.

## 5. Entscheidung A

1. Schlafleistung = SP-C2 (Quelle wearable5.0, ein Träger, als „gemessen, nicht veröffentlicht“ markiert). Begrenzt auf 0–100.
2. Konsistenz wie WHOOP: Anteil der 288 Fünf-Minuten-Schritte des Tages, in denen die letzten 4 Nächte (Einschlafen–Aufwachen) übereinstimmen. Korrektur auf WHOOP-Skala 1,004 · p − 8,859 (OpenVitals, 8,2 Punkte Fehler). Weniger als 4 Nächte → fehlt → im Score neutral 80.
3. Schlafschuld wie die API: 1/2 · (Bedarf − Schlaf) der letzten Nacht, höchstens 127,8 min, nie negativ. Nacht ohne Schlaf: Schuld bleibt. f = 1/2 statt 9/14 (offen, der kleinere Wert).
4. Strain-Bedarf und Grundbedarf bleiben (2,85 min je Punkt). Grund: `whoopRef.needBase` wurde beim Import mit 2,85 · Strain herausgerechnet. Eine neue Kurve bräuchte einen neuen Import.
5. Effizienz, Schlafstress, Tief/REM: kein Gewicht (keine Quelle). Sie stehen als eigene Zeilen daneben.
6. In der Schlafübersicht steht „Stunden vs. Bedarf“ als eigene Zeile. So sieht man die 70 %.

Nicht umgesetzt: Abdeckungs-Schwelle (Vorschlag Schlaf-Agent, sleepCover ≥ 0,85). Das Feld gibt es noch nicht; es gehört zur Erkennung.

## 6. Pace of Aging (B)

Folgt.
