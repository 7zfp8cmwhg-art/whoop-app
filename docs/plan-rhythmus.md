# Plan: Rhythmus-Ereignisse aus PPG-Schlagabständen

## STAND: ALLE Abschnitte fertig (1–6.9). Nächster Schritt: Umsetzung nach 6.9.

Stand: 26.11.2026. Kurze Sätze. Jede Aussage hat eine Quelle (URL plus Grund).
Markierung **[nicht verifiziert]** = Primärquelle nicht gelesen. Ergänzt `docs/recherche-rhythmus.md` (dort stehen die Lipponen-Konstanten, Malik, Apple/Fitbit-Zahlen, Holter-Medianwerte). Das wird hier nicht wiederholt.

Kernfrage: Sind erkannte Ereignisse echte Extraschläge oder Messfehler?
Kurzantwort: Aus PPG-Schlagabständen allein ist das nicht sicher trennbar. Nur Muster über mehrere Nächte plus ein 30-s-EKG geben Gewissheit.

## 1. Wissenschaftlicher Standard

### 1.1 Holter-Normwerte
- Gesunde Erwachsene, gepoolte 24-h-Daten: Supraventrikuläre Last > 1000/24 h bei ca. 0 % der 18–39-Jährigen, ca. 6 % der 60–79-Jährigen. Ventrikuläre Last > 1000/24 h bei ca. 1 % bis 5 %.
  Quelle: https://heart.bmj.com/content/heartjnl/106/22/1732.full.pdf — Meta-Analyse, altersabhängige Referenzwerte.
- Gesunde Japaner (n = 365): 97,5. Perzentil einzelner SVES: 131/Tag (20–39 J.), 232/Tag (40–59 J.).
  Quelle: https://www.frontiersin.org/journals/cardiovascular-medicine/articles/10.3389/fcvm.2023.1099157/full — Referenzintervalle für Langzeit-EKG.
- Gesunde Männer 15–39 J.: 95 % haben < 2,9 ventrikuläre Extrasystolen pro Stunde. Ab 40 J.: < 36 pro Stunde.
  Quelle: https://pmc.ncbi.nlm.nih.gov/articles/PMC1232163 — Holter-Studie 1986, nur Männer, alt.
- [Review] Umrechnung: 131/Tag = 5,5/h, 232/Tag = 9,7/h (97,5. Perzentil SVES, Japan). 2,9/h aus der Studie von 1986 gilt nur für ventrikuläre Schläge und nur für Männer.
- Folgerung für Atlas: Ein gesunder junger Mensch hat im Schnitt unter 1 Extraschlag pro Stunde, oft Null. Die Atlas-Schwelle "≥ 1 pro Stunde = einige Extraschläge" liegt an der Obergrenze des Normalen, und sie zählt Messfehler mit. Siehe Abschnitt 5.
- Bereits in der Altrecherche: PVC-Last > 10 % und PAC ≥ 30/h als auffällig. Quellen dort.

### 1.2 PPG-Ektopie-Erkennung: Zahlen
- Han et al. 2020 (Smartwatch, Chon-Labor): PAC/PVC-Sensitivität 67 % (inkl. Sinusrhythmus), 86 % bei AF-Probanden. Mit PAC/PVC-Erkennung steigt die AF-Spezifität von 95,75 % auf 97,90 %.
  Quelle: https://pmc.ncbi.nlm.nih.gov/articles/PMC7582300 — Volltext, Methode Poincaré + Bewegungserkennung.
- Stand der Technik ca. 75 % Sensitivität PAC/PVC auf Alltagsdaten. Neues Modell mit Mehrkanal-Eingang: 83 % (72 Probanden).
  Quelle: https://medrxiv.org/content/10.1101/2024.12.03.24318445v1.full.pdf — Preprint, nicht begutachtet.
- Haddad et al. 2020 (Handgelenk, nur Schlagabstände): ca. 93 % Sensitivität, 98 % Spezifität in der eigenen Auswertung **[nicht verifiziert, Snippet]**.
  Quelle: https://trepo.tuni.fi/bitstream/10024/129783/1/Ectopic_Beat_Detection_from_Wrist_Optical_Signals_for_Sinus_Rhythm_and_Atrial_Fibrillation_Subjects.pdf — Titel der Arbeit passt, Zahlen aus Suchtext.
- Lehre: Selbst Forschungsmodelle mit Bewegungsfilter erreichen im Alltag nur 67–83 %. Eine reine Regel wie Lipponen ohne Signalqualität liegt darunter.
- DoubleCheck-AF: Bei Menschen mit häufigen PAC fällt die Spezifität der PPG-AF-Erkennung auf 90 %, bei PVC auf 96,6 %. Einkanal-EKG fällt bei PAC auf 83,8 %.
  Quelle: https://doi.org/10.3389/fcvm.2023.1160242 — Kontrollgruppen mit Extraschlägen als Stresstest **[Zahlen aus Snippet, nicht verifiziert]**.

### 1.3 Ektopie gegen Artefakt unterscheiden
- Kompensatorische Pause: PVC hat meist volle Pause (kurz + lang ≈ 2 × normal). PAC meist nicht (kurz + lang < 2 × normal). Ein Artefakt hat keine feste Summe. Quelle: Altrecherche (Patent 10117595, squigglylines).
- Das Muster kurz-lang mit Summe ≈ 2 × normal ist das stärkste RR-Merkmal für echte Ektopie. Eigene Folgerung aus der obigen Quelle.
- Pulsdefizit: Ein PVC füllt die Kammer schlecht. Am Handgelenk fehlt der Puls. Das PPG zeigt dann ein Intervall von ≈ 2 RR und sieht aus wie ein "verpasster Schlag". Bigeminie bei 80/min zeigt 40/min.
  Quelle: https://pmc.ncbi.nlm.nih.gov/articles/PMC8441208 — Fallbericht Smartwatch zeigt < 40/min bei PVC.
- Bewegungsartefakte liegen im Frequenzband der Herzfrequenz. Ektope Pulswellen sehen Artefakten ähnlich.
  Quelle: https://pmc.ncbi.nlm.nih.gov/articles/PMC7582300 — Han 2020, Diskussion.
- Signalqualität über Pulsamplitude, Talsohlen-Tiefe, Pulsbreite: nur ca. 45 % einer 24-h-Handgelenk-Aufnahme ist hochwertig.
  Quelle: https://www.sce.carleton.ca/faculty/adler/publications/2019/pradhan-2019-quality-PPG.pdf — Pradhan 2019, Qualitätsmaße für PPG.
- Eine Studie, die Pulsamplitude gezielt zur Trennung Ektopie/Artefakt prüft, wurde nicht gefunden.
- Lipponen & Tarvainen 2019: trennt nur Muster (ektop, lang, kurz, verpasst, extra). Es kennt keine Ursache. Details in der Altrecherche.

### 1.4 AF-Erkennung aus PPG
- Dash et al. 2009: Kombination aus RMSSD, Wendepunkt-Anteil (Turning Points Ratio) und Shannon-Entropie. MIT-BIH AF-DB: Sensitivität 94,4 %, Spezifität 95,1 %. Mit anderen Arrhythmien: 90,2 % und 91,2 %. Wendepunkt-Anteil für Zufallsreihen = 2/3.
  Quelle: https://link.springer.com/article/10.1007/s10439-009-9740-z — Originalarbeit. Die genauen Schwellen (0,1 und 0,54–0,77) stehen im Volltext https://biosignal.uconn.edu/wp-content/uploads/sites/2503/2018/09/10_Dash_2009_AnnalsBME.pdf **[Schwellen nicht neu geprüft, nur aus Altrecherche]**.
- Wichtig: Dash arbeitete mit EKG-RR in Segmenten fester Länge. Es nutzt 3 Merkmale, nicht 2. Atlas nutzt 2 (nRMSSD + TPR) und keine Entropie. Siehe Abschnitt 5.
- Apple Heart Study: 0,52 % der 419 000 Teilnehmer bekamen eine Meldung. PPV der Meldung 0,84. Beim EKG-Patch zeigten nur 34 % Vorhofflimmern (Patch ca. 13 Tage nach Meldung).
  Quelle: https://escholarship.org/content/qt5n08v244/qt5n08v244.pdf — Perez 2019 NEJM, Apple finanziert.
- Fitbit und Apple: Alle PPG-Warnungen brauchen Ruhe, mehrere Fenster und mehrere Bestätigungen. Details in der Altrecherche.
- Gemeinsame Regel der Hersteller: PPG warnt nur vor AF. Kein Hersteller meldet einzelne PAC/PVC.
  Quelle: https://www.ccjm.org/content/91/1/23.full.pdf — Cleveland Clinic Journal, Wearables sind vor allem für AF validiert.

## 2. Wie die Hersteller es machen

| Hersteller | Funktion | Signal | Ziel | Quelle |
|---|---|---|---|---|
| WHOOP MG | Heart Screener (EKG, 30 s) | Einkanal-EKG | AF, normal, ≤ 50, ≥ 100 | https://www.accessdata.fda.gov/cdrh_docs/pdf24/K243236.pdf — FDA-Schreiben K243236 |
| WHOOP | IHRN (Irregular Heart Rhythm Notifications) | PPG-Puls | AF-Episoden, nicht jede | https://apps.apple.com/gb/app/id933944389 — Indikationstext, Meldung nicht bei jeder Episode |
| Apple | IRN | PPG, 1-min-Tachogramme, nur Ruhe | AF | https://www.apple.com/legal/ifu/irnf/irn-ifu-2-en_US.pdf — Gebrauchsanweisung |
| Fitbit | Irregular Rhythm | PPG, 5-min-Fenster, 11 in Folge | AF | https://pmc.ncbi.nlm.nih.gov/articles/9640290 — Fitbit Heart Study |
| Samsung | IHRN | PPG im Hintergrund, dann EKG | AF | https://www.samsung.com/ae/support/apps-services/real-time-atrial-fibrillation-notifications-with-samsung-health-monitor/ |
| Garmin, Oura, Withings | — | keine belastbaren Algorithmus-Details gefunden | — | **[nicht verifiziert]** |
| KardiaMobile | Einkanal-EKG am Finger | EKG | AF, normal, unklar; "unclassified" bei PVC-lastigen Aufnahmen | **[nicht verifiziert]**, nicht recherchiert |

- WHOOP trennt zwei Dinge: Das EKG (Heart Screener, FDA-zugelassen) bestätigt. Die PPG-Meldung (IHRN) warnt nur und ist opportunistisch. Genau diese Rollenteilung gilt auch für Atlas.
- Sensitivität/Spezifität des WHOOP-IHRN: nicht gefunden.
- Praxis: Nutzer berichten, dass Uhren PVC-reiche Aufnahmen als "nicht eindeutig" melden und dass PVC falsche Niedrigpuls-Werte erzeugen. Quellen: https://connect.mayoclinic.org/comment/1468080 und https://pmc.ncbi.nlm.nih.gov/articles/PMC8441208 — Forum bzw. Fallbericht. Reddit-Threads wurden nicht gefunden.
- Klinische Warnung: Wearable-Alarme erzeugen Folgekosten und Folgetests durch Fehlalarme.
  Quelle: https://abcnews.com/Health/eds-bombarded-apple-watch-afib-alerts/story?id=89229659 — Notaufnahmen nach Apple-Watch-Alarmen.
- Folgerung: Kein Hersteller zeigt Einzelereignisse pro Minute. Alle zeigen eine Gesamtbewertung über mehrere Messungen. Atlas zeigt jedes Ereignis als Punkt. Das ist für Neugier gut, aber die Zahl darf nicht als Diagnose wirken.

## 3. Open-Source-Apps ohne Abo

Suche am 26.11.2026. Ergebnis: Keine der Apps erkennt Extraschläge oder Rhythmus. Alle bereinigen nur RR für HRV.

- **NOOP** (https://github.com/ryanbr/noop, Forks u. a. NoopApp/noop). Companion für WHOOP 4.0 und 5.0, SQLite lokal.
  - Datei `Packages/StrandAnalytics/HRVAnalyzer.swift`. Doku: "RMSSD + SDNN ... with range + Malik ectopic filtering".
  - Konstanten: `rrMinMs = 300`, `rrMaxMs = 2000`, `ectopicThreshold = 0.20`, `ectopicWindowRadius = 2` (5-Schlag-Median ohne den Prüfling), `minBeats = 20`, `defaultSpotMaxRejectedFraction = 0.35`.
  - Funktionen: `rangeFilter(_:)`, `rejectEctopic(_:)`, `cleanRR(_:)`, `cleanRRGapAware(_:)` (Flag `contiguous`, damit Differenzen nicht über Lücken laufen).
  - Datei sagt selbst: ahmt Kubios/Lipponen nach, kennt kein "missed" und kein "extra". Es gibt keine Ereigniszählung.
  - Tabelle `rrInterval` in `Database.swift` (`WhoopStore`).
  - Quelle: https://github.com/ryanbr/noop — Repo-Seite und Datei gelesen.
- **OpenWhoop** (Web-App, Domain nicht erreichbar). Laut Suche: 5.0 nur "Live HR + HRV · beta" über das Standardprofil 0x2A37, RR in 1/1024 s. Kein EKG. **[nicht verifiziert, Suchtext]**
- **OpenStrap / edge** (https://github.com/OpenStrap): nur WHOOP 4.0, laut Suche. Keine Rhythmus-Funktion gefunden. **[nicht verifiziert]**
- **bWanShiTong/reverse-engineering-whoop-post**: Protokoll-Doku 4.0, RR-Kodierung "nicht vollständig dokumentiert". https://github.com/bWanShiTong/reverse-engineering-whoop-post
- **OpenVitals (sourcetms)** und **wearable5.0**: Suche ergab keine Treffer. **[nicht gefunden]**
- Kein öffentliches Dekodieren des MG-EKG gefunden. Atlas ist hier vor den Projekten.

Lehre für Atlas:
1. Das Malik-Fenster von NOOP (5 Schläge, 20 %) ist für HRV gedacht. Es fängt Rhythmus nicht ab.
2. Die Lücken-Markierung `contiguous` ist gut. Atlas prüft Lücken nur halb (Abschnitt 5, Fehler 3).
3. Es gibt keine Vorlage zum Abschreiben. Atlas braucht eine eigene Regel plus Signalqualität.


## 4. Wahrheitsquelle und bestes Verfahren mit MG-Daten

### 4.1 Rangfolge der Beweise
1. **30-s-EKG vom Band** (Einkanal, Finger). Sieht R-Zacken direkt. Zeigt Vorzeitigkeit, Pause und bei guter Rate die QRS-Breite. Stärkster Beweis, aber nur 30 s und nur auf Abruf. Quelle: FDA K243236 (Abschnitt 2), Heart Screener klassifiziert AF, normal, ≤ 50, ≥ 100.
2. **Mehrere Nächte mit gleichem Muster** (Zeit, Rate, Form). Zufällige Messfehler wiederholen sich nicht gleich. Prinzip aus Apple/Fitbit: Meldung erst nach Wiederholung (Abschnitt 2).
3. **Ereignis mit sauberem Umfeld** (ruhig, Signalqualität gut, Muster kurz-lang mit Summe ≈ 2 × normal).
4. **Einzelnes RR-Muster** ohne Umfeld: schwächster Beweis. Aussagen darüber sind "Muster", nie "Extraschlag".

### 4.2 Warum nicht mehr aus PPG-RR herauszuholen ist
- PPG-RR misst die Pulswelle, nicht die Zacke. Ein Extraschlag ohne Puls fehlt komplett (Pulsdefizit, PMC8441208).
- Gleiche RR-Folge kann PVC ohne Puls oder Messlücke sein. Das ist physikalisch nicht trennbar. Ohne Pulsamplitude ist "miss" immer mehrdeutig.
- Wellenform pro Schlag liefert das Band nur 1 Hz (Grün-PPG-Rohwert `ppgGreen` je Sekunde), nicht pro Schlag. Eine Amplitude je Schlag ist darum nicht möglich. Eigene Beobachtung aus `wparseR24`, Zeile 10788.
- Konsequenz: Atlas sagt "Muster" und "wahrscheinlich echt/Messfehler" nach Score. Atlas sagt nie "PVC" oder "PAC".

### 4.3 Bestes erreichbares Verfahren (empfohlen)
1. **Rohkette bereinigen:** Platzhalter-RR (500, 333, 334 ms) entfernen und als Lücke markieren. RR nur 300–2000 ms (wie NOOP). Zeitlücken aus `ts` prüfen (Summe RR gegen ts-Abstand).
2. **Qualitätsfenster:** Ereignis zählt nur in 5-min-Fenstern mit ≥ 90 % brauchbaren RR, ohne Bewegung, ohne Wachphase ±2 min. Das ist das Rate-pro-Stunde-Nenner-Fenster.
3. **Erkennung:** Lipponen/Kubios-Regeln (Altrecherche) liefern Kandidaten. Danach eigene Klassen mit festen Schwellen (Abschnitt 6).
4. **Score echt-gegen-Artefakt** je Ereignis aus 5 Merkmalen (6.4).
5. **Bestätigung über Nächte:** Rate je Stunde sauberer Daten, mindestens 3 von 7 Nächten mit gleicher Klasse.
6. **EKG-Bestätigung:** Nach einer Auffälligkeit schlägt Atlas ein 30-s-EKG vor. Nur ein EKG ändert die Aussage von "Muster" auf "im EKG bestätigt".

### 4.4 Wie das 30-s-EKG ein PPG-Ereignis bestätigt
- Was das EKG kann: Es zählt vorzeitige Schläge in den 30 s und prüft, ob die Folge kurz-lang mit Summe ≈ 2 × normal vorkommt. Dann ist ein PVC wahrscheinlich.
- Was es nicht kann: Es bestätigt nur, was in diesen 30 s passiert. Kein Ereignis im EKG widerlegt die Nacht nicht, weil Ektopie selten ist (z. B. 1 pro Stunde).
- Regel: Das EKG bestätigt die **Art** der Ereignisse (Ektopie ja/nein), nicht die **Häufigkeit**.
- Gleiches Verfahren wie ein Holter: R-Zacken, RR-Folge, Lipponen-Klassen auf der EKG-RR-Reihe. `ecgAnalyze` (Zeile 4551) erzeugt die RR-Reihe `rr` schon, wertet aber nur nRMSSD und TPR aus. Ergänzung in 6.7.
- Falle: Ein einzelner PVC in 30 s erhöht nRMSSD stark, die Klasse "unregelmäßig" kommt dann fälschlich. Darum zuerst Extraschläge entfernen, dann nRMSSD/TPR rechnen (wie Atlas es schon in `wRhythmDay` für die Phasen macht).
- Einkanal-EKG hat bei häufigen PAC eine schwächere Spezifität (83,8 %, DoubleCheck-AF, Abschnitt 1.2). Ein EKG "unregelmäßig" bei vielen Extraschlägen bleibt also eine Frage an den Arzt.


## 5. Lücken und Fehler im aktuellen Atlas-Code

Stand `index.html`, 16 868 Zeilen. Zeilennummern vom 26.11.2026. Reihenfolge = Schwere.

**F1 (hoch): Keine Signalqualität.** `wRhythmDay` (10944) prüft nur Bewegung (`_wCalm`, 12494) und Schlaf. Es gibt kein Qualitätsfenster, keinen Anteil brauchbarer RR, keine Prüfung der Schlagzeiten. Im Schlaf gilt jede Epoche als ruhig: `calm=inS(e.t)||...` (10947). Bewegung im Schlaf (Umdrehen) zählt also mit.

**F2 (hoch): Platzhalter-RR werden nicht entfernt.** Das Band liefert bei fehlenden Schlägen Platzhalter 500/333/334 ms. `wCorrectRr` kennt sie (`_wIsPh`, 12191) und markiert sie als Lücke. `wRhythmDay` kennt sie nicht (10947 filtert nur 250–2500). Ein Platzhalter von 500 ms zwischen 900-ms-Schlägen wird als "Extraschlag-Muster" oder "unklar" gezählt. Das ist ein reiner Messfehler.

**F3 (hoch): Lückenprüfung ist unvollständig.** Zeile 10956: `T[i]-T[i-1]>3` prüft nur den Abstand vor dem Schlag i. Die Schläge i+1 und i+2 und das 11er-Median-Fenster laufen über Lücken. Außerdem tragen mehrere RR eines 1-s-Records denselben Zeitstempel `T`. Eine Lücke innerhalb weniger Sekunden bleibt unsichtbar. `wCorrectRr` prüft `ts[k]-ts[k-1]-rr[k]>1000` (12196 ff.). Das fehlt hier.

**F4 (hoch): Unterlaufene RR-Werte verschwinden stumm.** `WRR_MIN/WRR_MAX = 200/2500` im Decoder (10731), dann 250–2500 in `wRhythmDay` (10947). Ein verworfener Wert hinterlässt keine Lücke. Folgen:
- Bei Puls < 48/min ist ein Aussetzer (≈ 2 × 1250 ms) > 2500 ms und wird verworfen. Gerade lange Pausen (≥ 2,5 s) sind klinisch am wichtigsten und gehen verloren.
- Ein verworfener kurzer Wert (< 250 ms) lässt die Folge "normal" aussehen.

**F5 (hoch): "ect" hat keine Mindest-Vorzeitigkeit.** Zeile 10959 prüft nur `|d|>1` (Schwelle aus der Streuung, 5,2 × Quartilsabstand) und das Muster. Bei ruhiger Nacht ist die Schwelle klein. Atmungsbedingte Schwankung (RSA) und PPG-Rauschen erzeugen dann das Muster −/+ ohne echte Vorzeitigkeit. Die Vorzeitigkeit `e[2]` (10964) wird gespeichert, aber nicht zum Filtern genutzt. Malik: > 20 % (Altrecherche).

**F6 (hoch): Schwellen aus verrauschten Daten.** `th1/th2` (10953) nutzen 91 Schläge ohne Rücksicht auf Qualität, Bewegung oder Lücken. Nach Bewegung sind die Schwellen groß (Ereignisse gehen verloren). In sauberen Phasen sind sie klein (Fehlalarme). Fester Mindestwert fehlt (`||1` in 10954 ist nur ein Divisionsschutz).

**F7 (hoch): Wort "Messfehler" ist falsch gesetzt.** `RHY_T` (6445): `extra` = "Messfehler (doppelt erkannt)" ist plausibel. `ls` = "unklar" wird in `vitContext` (6419) als Messfehler gezählt: `art=r.n.extra+r.n.ls`. Zu lange/kurze Schläge können aber auch echte Ektopie sein. Das Fazit "Die Messfehler überwiegen" (6420) stützt sich auf diese Summe. Die Klasse `miss` fließt weder in `ect` noch in `art` ein. Pausen fehlen im Urteil.

**F8 (hoch): Wiederholung gilt als Beweis.** `_ctxRhyNights` (6398): ≥ 3 von 7 Nächten mit `ect/h ≥ 1` heißt "spricht für echte Extraschläge" (6420). Ein systematischer Fehler (Bandsitz, Schlafposition, starke RSA) wiederholt sich jede Nacht. Wiederholung beweist nur Stabilität des Musters. Die Schwelle 1/h ist ohne Quelle.

**F9 (mittel): Schwellenwerte der Anzeige passen nicht zu den Normwerten.** `vitRhythm` (6451): `ectH>=1` = "Einige Extraschläge" (amber). Holter-Gesunde: Median 2 PVC/24 h (Altrecherche), 95 % der jungen Männer < 2,9 PVC/h. 1/h ist also nicht auffällig, aber auch kein Befund aus einer Messung mit ca. 70 % Sensitivität und unbekannter Spezifität. Rot ab 30/h oder 10 % der Schläge (6451) ist für PPG nicht begründet. Eine PPG-Messung kann die 10-%-Last nicht belegen.

**F10 (mittel): Nenner der Rate stimmt nicht.** `calmS/calmD` (10967) zählen 0,5 min je ruhige Epoche, auch wenn keine oder wenige RR vorliegen (Band lose, Funklücke). Die Rate je Stunde wird dadurch zu niedrig oder, bei Lücken in Datenblöcken, schief. Es zählen nur Zeiten mit brauchbaren RR.

**F11 (mittel): Zwei Verfahren nebeneinander.** `wRhythmNight` (10976, Aufruf 12889) zählt alles ≠ 'n' aus `wCorrectRr` als "odd" und speichert `whoop.rhythm` (`pct`, `perH`). Diese Zahl hat keine Anzeige (Suche nach `.rhythm`: nur der Aufruf). Totes Ergebnis mit anderer Definition. Entfernen oder vereinheitlichen.

**F12 (mittel): Unregelmäßige Phase zu anfällig.** Zeilen 10969–10973: 5-min-Block, ≥ 30 RR, nRMSSD ≥ 0,1 und TPR 0,54–0,77, dann 6 Blöcke in Folge (30 min). Probleme:
- Keine Qualitätsprüfung. Weißes Rauschen im PPG hat TPR ≈ 0,67 und hohe nRMSSD. Das ist exakt das Fenster.
- Junge Schläfer haben RMSSD 80–100 ms bei RR 1000 ms, also nRMSSD ≈ 0,1 in gesunden Nächten.
- Entfernte Ereignisse werden nicht als Lücke geführt. `arr` (10972) verbindet die Nachbarn. Der Sprung über eine Lücke zählt als normale Differenz.
- `bad=new Set(ev.map(x=>x[0]))` (10969) entfernt per Zeitstempel. Alle RR desselben 1-s-Records fallen mit weg.
- Nur 2 der 3 Dash-Merkmale (Shannon-Entropie fehlt). Dash nutzt feste Segmentlängen und ROC-Schwellen (Abschnitt 1.4). Die Atlas-Werte stammen aus der Altrecherche, nicht aus dem Volltext **[Schwellen nicht neu geprüft]**.

**F13 (niedrig): Ereignisliste gekappt.** `ev.slice(0,600)` (10975). Bei vielen Fehlalarmen fehlen später am Tag Ereignisse in der Zeitleiste, die Zähler `n` stimmen aber. Anzeige und Zähler weichen ab. Der Cap zeigt auch: 600 Ereignisse pro Tag wären ca. 25/h und damit sicher Artefakt.

**F14 (niedrig): EKG-Auswertung kennt keine Einzelereignisse.** `ecgAnalyze` (4551) wertet nur nRMSSD und TPR (Zeile 4569 ff.). Ein einzelner PVC kann nRMSSD ≥ 0,1 erzeugen und "unregelmäßig" auslösen. Das EKG nutzt die bereits berechnete RR-Reihe nicht zur Bestätigung von Nachtereignissen. Außerdem keine Ausreißerbereinigung vor TPR.

**F15 (niedrig): Doppelte Quellen der Wahrheit im Text.** `vitContext` (6419), `vitRhythm` (6451) und `rhyTap` (6447) formulieren Aussagen getrennt. `vitContext` sagt "spricht für echte Extraschläge", `vitRhythm` sagt "Extraschlag-Muster". Wortwahl muss eine Stelle steuern (6.6).

Prioritäten: F1–F5 vor allem anderen. Nach dem Umbau fallen die Zahlen deutlich. Das ist gewollt.


## 6. Bauplan

M bedeutet: lokaler Median-RR. Alle RR in ms. "Sauber" heißt: bestanden im Qualitätstor 6.1.

### 6.1 Vorverarbeitung und Qualitätstor
Schritt A, pro RR (neue Funktion `wRhythmPrep`):
1. [Review: korrigiert] Es gibt nur einen Decoder. Ein "eigener Rhythmus-Pfad" mit anderer Grenze ist so nicht baubar: `wparseV18`/`wparseR24` verwerfen Werte außerhalb `WRR_MIN/MAX` schon beim Lesen (Zeile 10740, 10785). Neu: `WRR_MAX` auf 3500 für alle. Die gemeinsame RR-Kette (`wRrChain`, docs/plan-review.md, Regel K2) markiert danach: 300–2000 = normal für HRV, 2000–3500 = lang (HRV: Artefakt `long` wie heute in `wCorrectRr`; Rhythmus: Kandidat Pause). < 300 und > 3500: Lücke, nie stumm verwerfen. Gilt nur für neue Daten. Gespeicherte Rohdaten haben die alte Grenze.
2. Platzhalter 500/333/334 ms mit Nachbarn > 1,3 × (`_wIsPh`, 12191): Lücke.
3. Zeitprüfung [Review: an Regel K3 angeglichen]: Lücke vor einem Schlag, wenn zwischen seinem Record und dem vorigen Schlag-Record eine Sekunde ohne Record liegt (Bitmaske `sm`) oder `(Δts − rr) > 1000 ms`. Eine echte lange Pause (z. B. 3,2 s) hat Records ohne Schlag und schneidet darum NICHT.
4. Lücke = Lauf endet. Kein Median, keine Differenz, keine Schwelle über Lücken (behebt F2, F3, F4, F12).

Schritt B, Qualitätsfenster (neue Funktion `wRhythmGate`), 5 min, Raster 5 min:
- ≥ 85 % der erwarteten Schläge vorhanden (erwartet = 5 min × Median-Puls). Lücken ≤ 3 s je Stück, höchstens 3 Lücken.
- Keine Bewegung: alle 30-s-Epochen `_wCalm` UND `enmo < 0,03`. Im Schlaf gilt das auch (behebt F1). Ausnahme: Epochen, die das Hypnogramm als Wach führt, zählen nicht.
- Höchstens 1 Wach-Epoche (30 s) im Fenster, nicht am Rand ±2 min einer längeren Wachphase.
- Anteil Platzhalter < 5 %.
- Lokale Streuung: Median-Absolutabweichung der RR ≤ 15 % von M (sonst Rauschen oder Bewegung). [Review: Diese Regel gilt NUR für die Zählung von Einzelereignissen. Für die unregelmäßige Phase (6.9 Schritt 4) gilt sie nicht. Echtes Vorhofflimmern hat oft eine MAD von 10–20 % und fiele sonst immer durch. Der Wert 15 % ist eigene Wahl.]
- Nur bestandene Fenster liefern Ereignisse UND Nennerzeit (behebt F10).

### 6.2 Klassen je Ereignistyp
M = Median der 10 Nachbar-RR im selben Lauf, ohne bereits markierte Ereignis-RR. Nachbarn i−1 und i+2 müssen innerhalb ±15 % von M liegen (sonst "unklar", kein Ereignis). [Review] In einer Bigeminie sind fast alle Nachbarn selbst kurz oder lang. Dort gilt M = Median des letzten normalen Laufs davor (≥ 10 Schläge). Grenzen 0,40/0,80/0,95/1,40/2,15/±15 % sind eigene Wahl auf Basis von Malik (20 %) und der Ausgleichspause.

| Typ | Regel (alle müssen gelten) | Deutscher Name | Zählt als |
|---|---|---|---|
| PREM | 0,40·M ≤ RR[i] ≤ 0,80·M; RR[i+1] ≥ 0,95·M; S = RR[i]+RR[i+1] in 1,40·M … 2,15·M | Vorzeitiger Schlag (Herzstolperer) | Muster Extraschlag |
| PREM-komp | PREM und S/(2·M) ≥ 0,90 | typisch Kammer (PVC-Muster) | Untertyp, nur Text "ähnelt" |
| PREM-nicht | PREM und S/(2·M) < 0,90 | typisch Vorhof (PAC-Muster) | Untertyp, nur Text "ähnelt" |
| PAUSE | 1,8·M ≤ RR[i] ≤ 2,2·M; i−1 und i+1 normal | Aussetzer | eigene Zählung, nie in Extraschlag-Rate |
| LANGPAUSE | RR[i] > 2,2·M und RR[i] ≥ 2000 ms | lange Pause | eigene Zählung, ab 3000 ms melden "EKG empfohlen" |
| DOPPEL | RR[i] und RR[i+1] jeweils 0,25·M … 0,75·M und \|RR[i]+RR[i+1]−M\| ≤ 0,12·M | Doppelschlag | Messfehler |
| ÜBERSPRUNG | wie PAUSE, aber Score < 40 (6.3) oder Bewegung/Lücke in ±30 s | Übersprung | Messfehler |
| BIGEMINIE | ≥ 6 PREM im Wechsel mit Normalschlag, alle S/(2·M) 0,9–1,1 | Wechselmuster | Hinweis, kein Zähler je Einzelereignis |
| UNKLAR | Lipponen-Klasse ls, aber keine Regel oben | unklar | weder Muster noch Messfehler |

Wichtige Unterschiede zum alten Code:
- PREM braucht ≥ 20 % Vorzeitigkeit (Malik) UND eine Ausgleichs-Summe. Nur RSA oder Rauschen reichen nicht (behebt F5).
- UNKLAR (alt `ls`) zählt nirgends als Messfehler (behebt F7).
- DOPPEL/ÜBERSPRUNG heißen Messfehler. PAUSE heißt "Aussetzer" mit Zusatz: Messlücke oder Extraschlag ohne Puls (Pulsdefizit).

### 6.3 Score "echt oder Messfehler" je Ereignis (0–100)
Fünf Merkmale mit je 0 oder 20 Punkten. Neue Funktion `wRhythmScore(ev,ctx)`.
1. **Muster passt eng:** PREM mit S/(2·M) 0,85–1,15, bzw. PAUSE mit RR/M 1,9–2,1.
2. **Umfeld sauber:** je 20 Schläge davor und danach alle ±15 % von M, lokales nRMSSD ohne das Ereignis < 0,08.
3. **Ruhe:** Schlaf (nicht Wach) und keine Bewegung ±60 s.
4. **Einzelstehend:** kein weiteres Ereignis (außer BIGEMINIE) in ±10 Schlägen. Ein Cluster von ≥ 3 Ereignissen in 20 Schlägen ist Artefakt-verdächtig.
5. **Zeit passt:** kein Platzhalter, keine Lücke, RR-Summe stimmt mit `ts` (Abweichung ≤ 15 %) in ±10 Schlägen.

Einstufung:
- ≥ 80: wahrscheinlich echt (Muster).
- 40–79: unsicher.
- < 40: wahrscheinlich Messfehler.
Veto: Punkte 3 oder 5 = 0 setzt den Score auf höchstens 39.
Es wird nur "Muster" gesagt. Auch bei 100 ist das keine Diagnose (4.2).

### 6.4 Raten und Nacht-/Mehrnacht-Bewertung
- **Rate** = Ereignisse mit Score ≥ 80, je Stunde sauberer Fensterzeit (nur `wRhythmGate`). Eigene Raten für PREM und PAUSE.
- **Mindestdaten:** ≥ 2 h saubere Fensterzeit je Nacht. Sonst "zu wenig saubere Daten, keine Rate".
- **Qualitätsanzeige:** Anteil sauberer Zeit an der Ruhezeit. Unter 40 %: "Signal zu unruhig". Anteil Messfehler an allen Ereignissen > 60 %: "Bandsitz prüfen".
- **Stufen je Nacht** (PREM-Rate je saubere Stunde; Anker: 95. Perzentil junger Gesunder ca. 3/h, Abschnitt 1.1; PAC "gehäuft" ab 30/h, Altrecherche):
  - < 3/h: unauffällig
  - 3 bis < 15/h: einzelne Muster
  - 15 bis < 30/h: häufige Muster
  - ≥ 30/h: sehr häufig (Langzeit-EKG empfehlen)
  Diese Grenzen sind eigene Wahl auf Basis der Quellen, nicht validiert. Nach dem Umbau mit eigenen 14 Nächten prüfen.
- **Belastung (% der Schläge):** nicht anzeigen. PPG sieht 67–83 % der Ereignisse (Abschnitt 1.2) und sagt nichts über PVC-Last.
- **Mehrnacht:** "wiederkehrend" erst bei ≥ 3 von 7 Nächten mit Rate ≥ 3/h UND ≥ 2 h saubere Daten in jeder gezählten Nacht UND Messfehler-Anteil im Mittel < 50 %. Das bedeutet nur: Muster wiederholt sich. Es sagt nichts über echt (F8).
- **EKG-Bestätigung:** siehe 6.7. Nur ein EKG im Sieben-Tage-Fenster darf "im EKG bestätigt" auslösen.


Hinweis zur Tabelle 6.2: Die Prüfung BIGEMINIE läuft vor PREM. Bei Bigeminie entfällt die Nachbarregel (i+2 ist selbst ein vorzeitiger Schlag).

### 6.5 Anzeige
- Hauptzeile: Stufe der Nacht (6.4) in Worten, Rate je saubere Stunde, saubere Stunden. Beispiel: "Einzelne Muster · 4 pro Stunde · 5,5 h saubere Daten".
- Daneben getrennt: Aussetzer (Zahl), Messfehler (Zahl, grau), "unsicher" (Zahl, grau).
- Zeitleiste: nur Ereignisse mit Score ≥ 80 als farbige Punkte. Score 40–79 als hohler Punkt. Messfehler als graue Striche (wie bisher).
- Tippen auf einen Punkt: Uhrzeit, Typ, Vorzeitigkeit in %, Summe S in % von 2·M, Score, Grund (zum Beispiel "Umfeld unruhig").
- Qualitätszeile: "Saubere Zeit: 62 % der Ruhezeit." Bei < 40 % statt Stufe: "Signal zu unruhig für eine Aussage."
- Mehrnacht: "In 4 von 7 Nächten wiederkehrend." Ohne das Wort "echt".
- Herz-Fazit (`vitContext`): ein Satz je Befund. Er nutzt dieselben Zahlen wie `vitRhythm` (eine Quelle der Wahrheit, F15).
- Ereignisliste `slice(0,600)` (F13) ersetzen durch Zähler plus Liste der 200 besten nach Score.

### 6.6 Wortregeln
- Immer "Muster" oder "Herzstolperer-Muster". Nie "Diagnose", nie "du hast", nie "PVC/PAC" als Befund. "ähnelt einem Kammer-/Vorhof-Muster" nur im Tipp-Text.
- Jede Seite mit Rhythmus-Aussage trägt: "Screen, keine Diagnose. Ein Pulssensor unterscheidet Vorhof- und Kammer-Extraschläge nicht. Gewissheit gibt nur ein EKG."
- "Aussetzer" immer mit Zusatz: "Messlücke oder Extraschlag ohne tastbaren Puls".
- "Unregelmäßiger Puls" statt "Vorhofflimmern". AF steht nur im Hinweis "kann Vorhofflimmern oder Extraschläge zeigen".
- Handlungshinweise nach Stufe:
  - unauffällig: nichts.
  - einzelne: "Spürst du Stolpern: 30-s-EKG am Band."
  - häufige/sehr häufige: "Langzeit-EKG (24–48 h) beim Arzt ansprechen."
  - LANGPAUSE ≥ 3 s, unregelmäßige Phase oder Symptome (Brustschmerz, Atemnot, Schwindel, Ohnmacht): "Ärztlich abklären. Bei akuten Beschwerden Notruf."
- Keine rote Farbe für eine einzelne Nacht. Rot erst bei ≥ 30/h an ≥ 2 Nächten oder im EKG bestätigter Unregelmäßigkeit.
- Stil: kurz, aktiv, ein Gedanke pro Satz (Nutzer-Vorgabe STE).

### 6.7 EKG bestätigt PPG-Befund
Neue Funktion `ecgEctopy(rr)` im Anschluss an `ecgAnalyze` (4551), gleiche RR-Reihe `rr` (Sekunden).
1. Gültigkeit wie bisher (≥ 20 s, HF 30–200, Abgleich mit Bandpuls).
2. M = Median von `rr`. Regeln PREM und PAUSE aus 6.2 anwenden (ohne Score, ohne Bewegungstor).
3. Ergebnis:
   - ≥ 2 PREM in 30 s: "Im EKG: vorzeitige Schläge (n). Das passt zum Muster aus der Nacht." Merker `ecg.ect=n` mit Datum.
   - 1 PREM: "Im EKG: ein vorzeitiger Schlag."
   - 0: "Im EKG: keine vorzeitigen Schläge in 30 s. Das widerlegt die Nacht nicht." (Ereignisse sind selten.)
4. Danach erst nRMSSD/TPR berechnen, ohne die PREM-Schläge und ohne ihre Nachbarn. Bleibt die Reihe regelmäßig: Klasse "regelmäßig mit Extraschlägen" statt "unregelmäßig". Bleibt sie unregelmäßig: wie bisher.
5. Wirkung auf die Nacht: Ein EKG mit ≥ 2 PREM in den letzten 7 Tagen setzt die Mehrnacht-Zeile auf "im EKG bestätigt". Ein EKG ohne PREM ändert nichts.
6. Grenze: Einkanal-EKG trennt PAC/PVC nicht sicher (QRS-Breite bei ca. 128–250 Hz unsicher) und hat bei vielen PAC schwächere Spezifität (83,8 %, Abschnitt 1.2). Atlas nennt keinen Untertyp aus dem EKG.
7. Hinweis: Atlas sollte ein EKG vorschlagen, wenn (a) Stufe ≥ "einzelne Muster" in 2 Nächten, (b) LANGPAUSE, oder (c) Symptom-Eingabe. Eine Taste "Jetzt gestolpert" im Live-Bild, die die letzten 60 s RR markiert, ist optional.

### 6.8 Testfälle
Alle mit M = 1000 ms Kontext, sofern nicht anders genannt. "1000×5" heißt fünf Schläge um 1000 ± 15 ms. [Review] Wo ein Score geprüft wird, braucht Merkmal 2 je 20 Schläge davor und danach. Dort steht darum 1000×20. Mit nur 5 Schlägen wäre Merkmal 2 = 0 und der Score 80. Alle in Schlaf, ruhig, Qualitätstor bestanden, wenn nicht anders gesagt.

| # | RR-Folge (ms) | Erwartete Klasse | Score | Zählt in Rate |
|---|---|---|---|---|
| 1 | 1000×20, 650, 1350, 1000×20 | PREM-komp (S/2M = 1,00; Vorzeitigkeit 35 %) | 100 | ja |
| 2 | 1000×20, 700, 1050, 1000×20 | PREM-nicht (S/2M = 0,875; Vorzeitigkeit 30 %) | 100 | ja |
| 3 | 1000×20, 2010, 1000×20 | PAUSE (RR/M = 2,01) | 100 | Aussetzer-Zähler, nicht Extraschlag-Rate |
| 4 | 1000×5, 480, 520, 1000×5 | DOPPEL (Summe 1000) | n. a. | nein, Messfehler |
| 5 | 1000×4, 2000, 1000×5 mit Bewegung (`enmo` 0,06) im Fenster | Fenster fällt durch das Tor, kein Ereignis. Minuten zählen nicht. | n. a. | nein |
| 6 | 900, 910, 500, 905, 895, 900, 910 | 500 ist Platzhalter (900 > 1,3 × 500), Lücke, Lauf geteilt, kein Ereignis | n. a. | nein |
| 7 | RSA: 1000, 1080, 1120, 1080, 1000, 920, 880, 920, 1000, 1080 | kein Ereignis (kleinster Wert 0,88·M, über 0,80·M) | n. a. | nein |
| 8 | [Review: neu gefasst] Zufallsfolge mit festem Startwert, 30 min, gleichverteilt 600–1100 ms (ca. 2100 Schläge, 6 Fenster) | Kein PREM (Nachbarn außerhalb ±15 %). Je Fenster nRMSSD ≈ 0,33 ± 0,03 und TPR 0,67 ± 0,05 → "unregelmäßig". Nach 6 Fenstern in Folge: Phase. Das MAD-Tor (≈ 17 %) gilt hier nicht (siehe 6.1). Die alte 12er-Beispielfolge ergab nachgerechnet MAD 16,8 %, nRMSSD 0,33 und TPR 0,80. Sie läge außerhalb 0,54–0,77 und taugt nicht als Test. | n. a. | Phase, nicht Rate |
| 9 | 1000×6, (700, 1300)×6, 1000×6 | BIGEMINIE (6 Wechsel, S/2M = 1,00) | n. a. | Hinweis, EKG empfehlen |
| 10 | 750×10, 1500×10 (Bigeminie mit Pulsdefizit, Band sieht nur jeden 2. Schlag) | kein Ereignis, regelmäßig. Bekannte Grenze (4.2). Test dokumentiert, dass Atlas hier nichts behauptet. | n. a. | nein |
| 11 | M = 1300: 1300×20, 2600, 1300×20 | PAUSE (RR/M = 2,0). Der alte Code verwirft 2600 schon im Decoder (Grenze 2500, F4). Neu sichtbar mit `WRR_MAX` 3500. | 100 | Aussetzer |
| 12 | 1000×20, 3200, 1000×20; die 3 Sekunden der Pause haben Records ohne Schlag | LANGPAUSE (≥ 3000 ms): Hinweis "ärztlich abklären". Kein Lückenschnitt (K3). | 80 (Merkmal 1 ist nur für PREM/PAUSE definiert) | Aussetzer, rot nur nach Wiederholung |
| 13 | 1000, 700, 1300, 1000, 650, 1350, 1000, 720, 1280, 1000 | 3 PREM in 10 Schlägen, kein Wechselmuster. Merkmal 2 und 4 = 0 → Score 60 → "unsicher" | 60 | nein |
| 14 | 1000×5, Funklücke 4 s (4 Sekunden ohne Record, `sm`-Bits fehlen), 1000×5 | Lauf geteilt, kein Ereignis über die Lücke | n. a. | nein |

Zusätzliche Prüfungen:
- Tabelle 1–14 als Regressionstest: Eingabe als RR-Liste plus Stub-Epochen, Ausgabe = Klasse.
- Regel-Test F2: Folge 900, 910, 500, 905 darf im alten Code ein Ereignis ergeben und im neuen keines.
- Rate-Test: 3 saubere Stunden mit 6 Score-80-Ereignissen ergeben 2,0/h = unauffällig. 2 saubere Stunden mit 10 Ereignissen ergeben 5/h = einzelne Muster.
- Mindestdaten-Test: 1,5 h saubere Zeit ergibt "zu wenig saubere Daten".
- EKG-Test (6.7): 30 s EKG mit 1 PVC bei 70/min darf nicht "unregelmäßig" ergeben.

### 6.9 Umbau-Reihenfolge (Funktionen und Zeilen)
1. `wRhythmPrep`, `wRhythmGate` neu. `wRhythmDay` (10944) ruft sie auf. F1–F4, F6, F10.
2. Klassenregeln 6.2 in `wRhythmDay` statt Zeilen 10956–10965. Lipponen bleibt als Kandidatenliste, Klassen kommen aus 6.2. F5, F7.
3. `wRhythmScore` neu, Ereignisformat erweitern: `[t, cls, vorzeitig%, S%, schlaf, score]`. Alte Einträge ohne Score bleiben lesbar (Score fehlt = unsicher).
4. Unregelmäßige Phase (10968–10973): Lauf-Differenzen statt `arr` über Lücken, `bad` nach Index statt Zeitstempel, nur Fenster aus `wRhythmGate`, Entropie ergänzen sobald Dash-Schwelle aus dem Volltext geprüft ist. F12.
5. `RHY_T` (6445), `vitRhythm` (6451), `vitContext` Zeile 6419, `_ctxRhyNights` (6398): neue Stufen, Wortregeln 6.6, Mehrnacht 6.4. F7–F9, F15.
6. `wRhythmNight` (10976) und den Aufruf bei 12889 entfernen oder auf neue Zahlen setzen. F11. [Review] Beim Entfernen das alte Feld `whoop.rhythm` an Tagen ohne Rohdaten stehen lassen. Zeile 12889 löscht es heute bei jeder Neuberechnung (`delete dd.whoop.rhythm`); das ist erlaubt, weil der Wert nirgends angezeigt wird.
7. `ecgEctopy` (6.7) und `ecgAnalyze` anpassen. F14.
8. Tage neu berechnen: alte `whoop.rhy` aus Rohdaten neu erzeugen, weil das Format wechselt. [Review] Rohdaten gibt es nur 3 Tage. Ältere `rhy` bleiben im alten Format stehen (nicht löschen). Neues Feld `rhy.v=2`. Die Mehrnacht-Zählung (6.4, `_ctxRhyNights`) zählt nur Nächte mit `rhy.v===2`. Alte Klassen ('ect', 'miss', 'extra', 'ls') bleiben in `RHY_T` lesbar.
9. Prüfen mit den eigenen 14 Nächten: erwartete Fehlalarmrate sinkt stark. Schwellen 6.4 danach anpassen.

Offene Punkte (nicht gelöst):
- Dash-2009-Schwellen (0,1; 0,54–0,77) und Entropie-Grenze nicht im Volltext geprüft.
- Haddad-2020-Zahlen nur aus Suchtext.
- WHOOP-IHRN-Genauigkeit, Garmin, Oura, Withings, KardiaMobile: keine belastbaren Angaben gefunden.
- Pulsamplitude je Schlag fehlt im 1-Hz-Strom. Falls das Band je Schlag Qualität liefert (Rohpaket prüfen, `wparseR24` ab Zeile 10780), wäre das der größte Gewinn für die Trennung echt/Artefakt.
- Schwellen 6.4 sind eigene Wahl und brauchen Kalibrierung.

---

## Review (26.11.2026, Kritiker)

Code-Bezüge geprüft (10944–10982, 10731, 12191–12221, 6398, 6419, 6445, 6451, 4551). Alle stimmen. F1–F15 beschreiben das Verhalten richtig.
Geändert:
1. 6.1 A.1: Ein eigener Decoder-Bereich nur für Rhythmus ist nicht baubar. Neu: `WRR_MAX` 3500 für alle, Einordnung in der gemeinsamen RR-Kette (K2).
2. 6.1 A.3: Lückenregel an die gemeinsame Regel K3 angeglichen (Record-Bitmaske `sm`). Lange Pausen schneiden nicht.
3. 6.1 B: Das MAD-Tor gilt nur für Einzelereignisse, nicht für die unregelmäßige Phase. Sonst fiele echtes Vorhofflimmern durch.
4. 6.2: M in einer Bigeminie aus dem letzten normalen Lauf.
5. Tests 1–3, 11, 12: Kontext 1000×20, sonst wäre der Score 80 statt 100. Test 12: Score 80 (Merkmal 1 gilt nur für PREM/PAUSE).
6. Test 8 war falsch: Die Beispielfolge ergibt MAD 16,8 %, nRMSSD 0,33, TPR 0,80. Neu als seeded Zufallsfolge.
7. Test 11: Satz zur alten Grenze richtiggestellt. Test 14: Funklücke als fehlende Records definiert.
8. 6.9: alte `rhy` bleiben; Mehrnacht zählt nur `rhy.v===2`.
9. 1.1: Umrechnung 131/Tag = 5,5/h ergänzt. 2,9/h gilt nur für ventrikuläre Schläge bei Männern.
Nachgerechnet und richtig: Tests 1 (S/2M 1,00), 2 (0,875), 3 (2,01), 4 (DOPPEL), 6 (Platzhalter), 7 (0,88·M), 13 (Score 60), Raten 2,0/h und 5/h.
Eigene Wahl, bleibt markiert: alle Grenzen in 6.2, Score-Punkte 6.3, Stufen 3/15/30 pro Stunde, Mindestdaten 2 h, 85 %-Tor.
Offen bleibt: Dash-Schwellen nicht im Volltext geprüft; Haddad-Zahlen nur aus Suchtext.
