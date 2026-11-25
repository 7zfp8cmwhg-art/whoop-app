# Recherche: Extraschläge vs. Messfehler in Handgelenk-PPI

Stand: 25.11.2026. Kurze Sätze. Jede Aussage hat eine Quelle.
Markierung **[nicht verifiziert]** = Primärquelle nicht gelesen oder nur Sekundärquelle.

## 1. Lipponen & Tarvainen 2019 (Kubios „Automatic correction“)

Originalpaper (J Med Eng Technol 43(3)) war gesperrt (HTTP 403). Die Regeln stammen aus der Open-Source-Umsetzung in NeuroKit2. Diese folgt dem Paper.
Quelle Code: https://raw.githubusercontent.com/neuropsychology/NeuroKit/master/neurokit2/signal/signal_fixpeaks.py
Quelle Paper (Abstract): https://informahealthcare.com/doi/abs/10.1080/03091902.2019.1640306

Konstanten (NeuroKit-Default):
- c1 = 0,13. c2 = 0,17. alpha = 5,2.
- Fenster für Schwellen: 91 Schläge. Median-Fenster: 11 Schläge.

Reihen:
- dRR[i] = RR[i] − RR[i−1].
- Th1 = alpha × Quartilsabstand/2 von dRR im 91er-Fenster. dRR wird durch Th1 geteilt.
- mRR[i] = RR[i] − Median11(RR). Negative mRR werden verdoppelt.
- Th2 = alpha × (Q3−Q1)/2 von mRR im 91er-Fenster. mRR wird normiert.
- S11 = dRR[i].
- S12 = max(dRR[i−1], dRR[i+1]) wenn dRR[i] > 0, sonst min(...).
- S21 = dRR[i].
- S22 = min(dRR[i+1], dRR[i+2]) wenn dRR[i] ≥ 0, sonst max(...).

Klassen (alle dRR, mRR normiert):
- Normal: |dRR| ≤ 1 und |mRR| ≤ 3.
- Ektop: (dRR > 1 und S12 < −c1·dRR − c2) oder (dRR < −1 und S12 > −c1·dRR + c2).
- Lang: dRR > 1 und S22 < −1. Kurz: dRR < −1 und S22 > 1. Zusätzlich lang/kurz: |mRR| > 3.
- Verpasst (missed): Lang und |RR/2 − Median| < Th2.
- Extra: Kurz und |RR[i] + RR[i+1] − Median| < Th2.
- Rest von lang/kurz: „long/short“ (fehlplatziert).

Kubios-Beschreibung: Ektop = Muster −/+/− oder +/−/+ in dRR. Lang = +/−. Kurz = −/+. Missed/Extra über Vergleich mit Median der umgebenden 10 RR. Schwelle = Quartilsabweichung der 90 umgebenden Schläge × 5,2. Korrektur: Ektop/lang/kurz interpoliert, missed → Schlag eingefügt, extra → Schlag entfernt.
Quelle: https://www.kubios.com/blog/preprocessing-of-hrv-data/

Kubios Schwellen-Filter (separates Verfahren): sehr niedrig 0,45 s, niedrig 0,35 s, mittel 0,25 s, stark 0,15 s, sehr stark 0,05 s. Vergleich mit medianem Lokalwert.
Quelle: https://www.kubios.com/blog/preprocessing-of-hrv-data/

Validierung (Autoren = Kubios-Gründer, Interessenkonflikt): Fehler < 2 % bei missed/extra. Sensitivität 100 % bei simulierten missed/extra.
Quelle: https://informahealthcare.com/doi/abs/10.1080/03091902.2019.1640306 (via Suche)

Wichtig: Das Verfahren unterscheidet NICHT zwischen echtem Extraschlag und Sensor-Fehler. „Ektop“ heißt nur „Muster wie Extraschlag“.

## 2. Extraschläge aus RR/PPI erkennen

Kompensatorische Pause:
- PVC: meist volle kompensatorische Pause. RR(kurz) + RR(lang) ≈ 2 × normales RR.
  Quelle (Patent, nutzt PPG-Peak-Intervalle): https://image-ppubs.uspto.gov/dirsearch-public/print/downloadPdf/10117595
- PAC: meist nicht-kompensatorisch. RR(1) + RR(2) < 2 × normales RR.
  Quelle: https://squigglylines.substack.com/p/premature-complexes (via Suche)

Vorzeitigkeit:
- Malik-Regel: Intervall weicht > 20 % vom vorigen ab → ektop oder Artefakt. Konvention, nicht validiert.
  Quelle: https://www.frontiersin.org/journals/physiology/articles/10.3389/fphys.2019.00693/epub
  Malik-Original nicht gelesen **[nicht verifiziert]**.
- Altes Monitor-Patent: Kurz+Lang < 1,25 × vorheriges RR als Kriterium.
  Quelle: https://image-ppubs.uspto.gov/dirsearch-public/print/downloadPdf/4417306
- Feste Grenze „RR < 80–85 % vom Median“ in einer Leitlinie: **nicht gefunden**.

Genauigkeit Handgelenk-PPG:
- Han et al. 2020 (Smartwatch, Poincaré + Vektor-Ähnlichkeit, mit Bewegungserkennung): Sensitivität 86 % (AF-Probanden), 67 % mit Sinusrhythmus. Spezifität 97 %, PPV 81 %, Genauigkeit 92 %.
  Quelle: https://doaj.org/article/b1fcf600b411496583c2e298eff30331 (DOI 10.3390/s20195683). Konkrete Schwellen im Volltext nicht lesbar **[nicht verifiziert]**.
- Gottbrecht et al. (Preprint 2024): Stand der Technik ca. 75 % Sensitivität PAC/PVC. Eigenes Modell 83 %.
  Quelle: https://medrxiv.org/content/10.1101/2024.12.03.24318445v1.full.pdf+html
- CinC 2026: PAC vs. PVC aus nur 2 IBI-Merkmalen, F1 0,76 (real). Merkmale nicht genannt.
  Quelle: https://cinc.org/2026/Program/accepted/166.html
- Solosenko et al.: 6 Merkmale (Pulsleistung + Peak-Intervalle). Manche PVC-Typen sind im PPG nicht erkennbar.
  Quelle: https://epubl.ktu.edu/object/elaba:26455153/26455153.pdf (via Suche). Zahlen **[nicht verifiziert]**.
- Polanía, Mol, Bashar: **nicht geprüft**.

Ektopie vs. Artefakt:
- Verpasster Schlag: RR ≈ 2 × Median. Extra-Erkennung: zwei kurze RR, Summe ≈ 1 Median. (Regeln siehe Abschnitt 1.)
- Falle: Ein PVC füllt die Kammer schlecht. Der Puls am Handgelenk fehlt dann („Pulsdefizit“). Das PPG sieht ein Intervall ≈ 2 RR. Das sieht aus wie ein „verpasster Schlag“.
  Quelle: https://pmc.ncbi.nlm.nih.gov/articles/PMC8441208
- Der Schlag nach der Pause ist kräftiger (post-extrasystolische Potenzierung). PVC kann sehr früh kommen.
  Quelle: https://cinc.org/archives/2025/pdf/CinC2025-115.pdf (via Suche)
- Bewegung erzeugt viele Artefakte im PPG. Das stört mehr als Ektopie.
  Quelle: https://marcoaltini.substack.com/p/data-quality-for-heart-rate-variability
- Folgerung (eigene, keine Quelle): Ein „missed“ nach Lipponen kann im PPG auch ein PVC ohne Puls sein. Ohne Amplitude oder EKG nicht trennbar.

## 3. Consumer-Geräte

Apple IRN:
- 1-Minuten-Tachogramme, nur in Ruhe. Klassifikation regulär/irregulär nach Variation der Pulsintervalle.
  Quelle: https://escholarship.org/content/qt5n08v244/qt5n08v244.pdf (Perez 2019, NEJM)
- Meldung erst nach Bestätigung „auf mehreren Messungen“.
  Quelle: https://www.apple.com/legal/ifu/irnf/irn-ifu-2-en_US.pdf
- „5 Checks über mindestens 65 Minuten“: nur Sekundärquelle **[nicht verifiziert]**. „5 von 6 in 48 h“: **nicht verifiziert**.
  Quelle: https://www.idownloadblog.com/?p=683718
- Ziel nur AFib. Keine Meldung ≠ keine Krankheit. Sensitivität 88,6 %, Spezifität 99,3 %.
  Quelle: https://www.apple.com/legal/ifu/irnf/irn-ifu-2-en_US.pdf
- PPV pro Tachogramm 0,71. PPV pro Meldung 0,84.
  Quelle: https://escholarship.org/content/qt5n08v244/qt5n08v244.pdf

Fitbit:
- 5-Minuten-Tachogramme alle 2,5 min (50 % Überlappung). 11 irreguläre in Folge → Meldung (≥ 30 min). PPV 98,2 %.
- Sehr kurze AFib-Episoden werden verpasst.
  Quelle: https://pmc.ncbi.nlm.nih.gov/articles/9640290 und https://www.massgeneral.org/news/press-release/fitness-trackers-may-diagnose-potentially-irregular-heartbeats

Samsung: IHRN prüft periodisch im Hintergrund, Ziel AFib, schlägt EKG vor.
Quelle: https://www.samsung.com/ae/support/apps-services/real-time-atrial-fibrillation-notifications-with-samsung-health-monitor/

WHOOP IHRN: PPG-Pulsdaten, Ziel AFib, opportunistisch, ab 22 Jahren, nicht bei bekannter AFib. US-Status unklar.
Quelle: https://apps.apple.com/gb/app/id933944389 und https://community.whoop.com/t/is-ihrn-available-in-the-us/477

Garmin, Oura: keine belastbaren Algorithmus-Details gefunden **[nicht verifiziert]**.

Gemeinsam: Kein Gerät meldet Extraschläge (PAC/PVC) per PPG. Alle zielen auf AFib.
Eine Uhr kann PAC und PVC nicht trennen.
Quelle: https://connect.mayoclinic.org/comment/1468183/ (Forum)

## 4. Klinische Zahlen

- Gesunde 25–41 J. (n=2048, 24-h-Holter): 69 % mit ≥ 1 PVC. Median 2 PVC/24 h.
  Quelle: https://pmc.ncbi.nlm.nih.gov/articles/PMC7358889 (via Suche)
- 40–75 % haben PVC im 24–48-h-Holter.
  Quelle: https://marcoaltini.substack.com/p/on-hrv-and-arrhythmia
- PVC-Last > 10 %: häufige Grenze für Kardiomyopathie-Risiko. > 24 %: hohe Vorhersagekraft.
  Quelle: https://www.uscjournal.com/articles/Idiopathic-Frequent-Premature-Ventricular
- Aber: Last allein kein unabhängiger Prädiktor (2025).
  Quelle: https://pubmed.ncbi.nlm.nih.gov/39945713/
- Kein definitiver Grenzwert in der Literatur.
  Quelle: https://pmc.ncbi.nlm.nih.gov/articles/PMC6786912 (via Suche)
- PAC: „Exzessiv“ = ≥ 30 SVES/h oder Salven ≥ 20. Bei 14,6 % gesunder 55–75-Jähriger. Mehr AFib und Schlaganfall (HR 2,79).
  Quelle: https://research.regionh.dk/da/publications/excessive-supraventricular-ectopic-activity-and-increased-risk-of/

## 5. Erfahrungen aus der Praxis

- Altini: Ektopie gibt es auch mit Brustgurt/EKG. Jede RR-Reihe braucht Artefakt-Bereinigung.
  Quelle: https://medium.com/swlh/artifact-removal-for-ppg-based-heart-rate-variability-hrv-analysis-5c7d08b6523a
- Altini: Nachtdaten sind durch Ektopie verfälscht. Artefakte erhöhen HRV nur. Messung morgens empfohlen.
  Quelle: https://marcoaltini.substack.com/p/on-hrv-and-arrhythmia
- Fitbit-Nutzer mit PVC: Puls ok, aber HRV und Schlafphasen fehlten.
  Quelle: https://community.fitbit.com/t5/Product-Feedback/Daily-ventricular-premature-irregular-heartbeat-report-extrasystoles-AKA/idc-p/4579007/highlight/true
- Bigeminie (jeder 2. Schlag PVC) bei 80/min → Handgelenk zeigt 40/min.
  Quelle: https://theskepticalcardiologist.substack.com/p/are-your-palpitations-due-to-benign-premature-ventricular-contractions-pvcs
- Polar H10 + Kubios: RR nahe am EKG. PVC-Erkennung aus RR allein nicht validiert.
  Quelle: https://mdpi.com/1424-8220/22/17/6536
- Reddit-Threads (r/whoop, r/Garmin, r/AppleWatch): **nicht gefunden**.
