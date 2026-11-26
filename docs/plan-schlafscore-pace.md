## STAND
26.11.: A und B umgesetzt und committet. Selbsttest 308 von 308. www/index.html kopiert.

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

### 6.1 Warum es nicht mehr angezeigt wurde
Commit `000de85` (19.11., „Fitness age (Nes 2011 / HUNT3) instead of heuristic bio age and pace multiplier“) hat Bio-Alter und Pace-Multiplikator ersetzt. `paceOfAging()` gab danach nur noch `{pace:null, change}` zurück. Das Feld hieß „Fitness-Alter“ und zeigte die Änderung gegen vor 12 Wochen. `AGE_META`, `contribRow` und `bioBreakdown` blieben als toter Code stehen. Kein Fehler, sondern eine bewusste Ersetzung.

### 6.2 Was WHOOP öffentlich sagt
- 9 Metriken: Schlafdauer, Schlaf-Konsistenz, Zeit in Zone 1–3, Zeit in Zone 4–5, Krafttraining, Schritte, VO₂max, Ruhepuls, Magermasse.
- WHOOP Age aus 6 Monaten. Jede Metrik gibt Jahre dazu oder ab. Break-even = gute Langzeitgesundheit.
- Pace of Aging aus den letzten 30 Tagen gegen WHOOP Age, −1× bis 3×. Update wöchentlich (Sonntag). Start ab 21 Erholungen in 31 Tagen.
- Jahre je Metrik und die Pace-Formel sind nicht veröffentlicht (White Paper nicht erreichbar).

### 6.3 Entscheidung B
Jahre je Metrik aus Sterblichkeits-Studien. Umrechnung: Jahre = 11,6 · ln(HR). Grund: Das Sterberisiko steigt um ~9 % je Lebensjahr (Spiegelhalter, BMJ 2016;355:i6584, „effective age“), 1/ln(1,09) = 11,6.

| Metrik | Quelle | Punkte (Wert → Jahre) |
|---|---|---|
| Schlafdauer | Cappuccio 2010, Sleep 33:585: kurz HR 1,12, lang HR 1,30 | 5,5 h → +1,3; 7–8 h → 0; 9,5 h → +3,0 |
| Schlaf-Konsistenz | Windred 2024, Sleep 47:zsad253: Quintil 1 ~1,25 × Risiko | 50 % → +2,6; 80 % → 0. **Zuordnung % ↔ Quintil ist eine Annahme.** |
| Zone 1–3 | Lee 2022, Circulation 146:523: 150–299 min HR 0,80; 300–599 HR 0,74 | 0 → +2,6; 150 → 0; 300 → −0,9 |
| Zone 4–5 | Lee 2022: 75–149 min HR 0,81; 150–299 HR 0,71 | 0 → +2,4; 75 → 0; 150 → −1,5 |
| Krafttraining | Momma 2022, BJSM 56:755: 10–17 % weniger bei 30–60 min | 0 → +1,9; 30 → 0 |
| Schritte | Paluch 2022, Lancet Public Health 7:e219: Quartile 3500/7000/9000/10900, HR 1/0,60/0,55/0,47 | 3500 → +5,9; 7000 → 0; 9000 → −1,0; 10900 → −2,8 |
| VO₂max | Kodama 2009, JAMA 301:2024: HR 0,87 je MET | −1,6 J je 3,5 ml/kg/min über der Mitte „Mittel“ der Altersnorm, ±6 J |
| Ruhepuls | Zhang 2016, CMAJ 188:E53: HR 1,09 je 10 bpm | +1,0 J je 10 bpm über 60, ±4 J |
| Magermasse | — | noch keine Daten in Atlas, „bald“ |

- Bio-Alter = Alter + Summe der Jahre (6-Monats-Werte). Stand letzter Sonntag.
- Pace = 1 + 2 · (Summe 30 Tage − Summe 6 Monate), begrenzt −1 bis 3. **Eigene Ableitung**: WHOOP Age ist ein 6-Monats-Schnitt. Bleiben die 30-Tage-Werte, wandert es in 0,5 Jahren um die Differenz. 1× = ein Jahr pro Jahr. Die Spanne −1…3 entspricht genau ±1 Jahr Differenz.
- Fitness-Alter (Nes 2011) bleibt als Zeile und in der Aufschlüsselung.
- Beobachtete Studien, keine Ursache-Wirkung. Schritte haben die größte Spanne. WHOOP-Werte können abweichen.

## 7. Was nicht geprüft werden konnte
- Echte WHOOP-Werte des Nutzers (kein Export im Repo). SP-C2 ist an einem fremden Träger gemessen.
- Gewicht von Effizienz und Schlafstress in WHOOPs Schlafleistung.
- Faktor der Schuld (1/2 oder 9/14).
- Ob der Strain-Bedarf (Patent-Kurve) zu Atlas' Strain-Skala passt. Atlas bleibt bei 2,85 min je Punkt.
- WHOOPs Jahre je Metrik und die Pace-Formel.
