# Review der vier Forschungspläne (VO2max, HRV, Rhythmus, Schlaf)

## STAND
26.11.2026. ALLES FERTIG: vier Pläne geprüft und korrigiert, Querschnitt (Abschnitte 5–11) geschrieben. dann Rhythmus, Schlaf, dann Querschnitt (gemeinsame RR-Kette, Schnittstellen, WALGO_VER, Bauplan).

## 1. VO2max (fertig)
- Ruhepuls-Herkunft falsch beschrieben: Er kommt aus `wRhrWhoop`, nicht aus `wNocturnalRhr`. Korrigiert.
- Lücke 1 war durch Commit 08e04fc überholt. Korrigiert.
- Widerspruch 3–6 Nächte gegen 7-Nächte-Minimum entfernt.
- T1 falsch gerundet (BMI 24 statt 24,49). Richtig: 42,3. T13, T15 angepasst.
- Alte Lauf-Tests haben keine GPS-Marke. Sie brechen mit der GPS-Pflicht. Im Plan vermerkt.
- Neue Lücken: Ruhepuls mischt 4.0/MG und 'whoop'/'min5'; HFmax nur als ein Wert gespeichert.

## 2. HRV (fertig)
- WALGO_VER-Sprung auf 25 abgelehnt (Datenverlust in den Basislinien). Ersatz `_hrvV` plus δ-Migration.
- Lückenregel "ts ≥ 2 s" war falsch: `e.recs` hat nur Records mit Schlägen. Neu: Record-Bitmaske `sm`.
- Fenster nach Zeit statt Index.
- Winsorisieren bei Median/MAD wirkungslos, gestrichen.
- ln-Basislinie nur für MG-Tage; ms-Pfad für 4.0/Export unverändert.
- T3 falsch (62,5 → 61,8). T2, T9, T13 neu.

## 3. Rhythmus (fertig)
- Eigener Decoder-Bereich für Rhythmus nicht baubar. Neu: `WRR_MAX` 3500 für alle, Einordnung in der RR-Kette.
- MAD-Tor hätte echtes Vorhofflimmern ausgefiltert. Gilt jetzt nur für Einzelereignisse.
- Test 8 falsch (TPR 0,80, nicht 0,67). Tests 1–3, 11, 12 brauchen 20 Schläge Kontext.
- Alte `rhy`-Tage bleiben; Mehrnacht zählt nur das neue Format.

## 4. Schlaf (fertig)
- `sleepHours` neu zu definieren hätte Schlafleistung, Schuld und alte Tests gebrochen. Neu: `slMeasH`.
- Widersprüchliche Regeln für weitere Blöcke vereinheitlicht.
- Erfundene "≥ 4 h"-Regel für Ruhepuls/HRV ersetzt.
- I43, I44, I46 korrigiert.
- Schnittstelle S1 mit Zeiten in Sekunden ergänzt.

---

## 5. Gemeinsame RR-Kette (gilt für HRV, Rhythmus, Schlaf, Atmung)

Heute bereinigt jede Funktion selbst: `wHrvWhoop` und `wRhythmNight` rufen `wCorrectRr` je Fenster. `wRhythmDay` filtert 250–2500 und prüft `T[i]-T[i-1]>3`. Die Phasen nutzen `e.rr` ohne Lückenprüfung. Das ergibt drei verschiedene Lückenbegriffe.
Neu: eine Funktion `wRrChain(epochs)`. Sie läuft einmal je Nacht. Alle Nutzer lesen ihr Ergebnis.

**K1 Eingang.** Epochen der Nacht mit `recs:[{ts, rr[]}]` und der Record-Bitmaske `sm` (1 Bit je Sekunde, gesetzt = Record da). `sm` steht schon in jeder gespeicherten Epoche (Zeile 11443–11447). `epochsFor` gibt es heute nicht heraus. Neu: `epochsFor` liefert `sm` mit. Schläge in Reihenfolge `ts`, innerhalb eines Records in Paketreihenfolge.

**K2 Wertklasse je Schlag.**
- `v < 300` oder `v > 3500`: Klasse `gap`. Lauf endet.
- Platzhalter (`_wIsPh(v, lokaler Median)`: 500/333/334 bei Median > 1,3·v): Klasse `ph`. Lauf endet. Zählt als fehlender Schlag.
- `2000 < v ≤ 3500`: Klasse `long`. HRV: Artefakt wie heute in `wCorrectRr`. Rhythmus: Kandidat für Pause.
- sonst: Klasse `n` (Kandidat).
- Decoder: `WRR_MAX` von 2500 auf 3500. `WRR_MIN` bleibt 200. Gilt nur für neue Daten.

**K3 Lücke.** Vor dem ersten Schlag eines Records endet der Lauf, wenn
- (a) zwischen dem vorigen Schlag-Record und diesem Record eine Sekunde ohne Record liegt (Bit in `sm` fehlt, auch über Epochengrenzen), oder
- (b) `(Δts·1000 − rr) > 1000 ms` (heutige Regel aus `wCorrectRr`, Zeile 12220).
- Fehlt `sm` (sehr alte Epoche), gilt nur (b).
- Sekunden mit Record, aber ohne Schlag, sind KEINE Lücke. Das ist der Normalfall bei Puls < 60 und bei langen Pausen.

**K4 Läufe.** Ein Lauf ist die längste Folge ohne Schnitt nach K2/K3. Ausgabe: `{beats:[{t, rr, cls, run}], runs:[[i0,i1],…], missS}`. `t` = Record-Sekunde. `missS` = Summe fehlender Sekunden.

**K5 Nutzer.**
- HRV: `wCorrectRr(rr)` je Lauf, ohne `ts` (die Lücken sind schon geschnitten). Fenster nach Zeit (5 min, Schritt 30 s), nur innerhalb eines Schlafblocks.
- Rhythmus: Klassen nach plan-rhythmus 6.2 auf den rohen Läufen. Schwellen nur innerhalb eines Laufs.
- Atmung (`wRespRate`) und Phasen-Merkmale (RMSSD je Epoche): Differenzen nur innerhalb eines Laufs.
- Eigene Tore je Nutzer bleiben getrennt: HRV ≥ 70 % der erwarteten Schläge; Rhythmus ≥ 85 % und MAD-Tor nur für Einzelereignisse. Die Kette selbst hat keine Schwelle außer K2/K3.

Tests der Kette: HRV T2 (a, b, c), Rhythmus 6, 12, 14. Zusatz K-T1: 10 min RR 1250 ms ohne Verlust → 1 Lauf (bei 48/min hat jede 5. Sekunde keinen Schlag). K-T2: ein Wert 2600 bei M 1300 bleibt als `long` erhalten (heute verworfen).

## 6. Schnittstellen

**S1 Schlaf → HRV, Ruhepuls, Rhythmus.** `slp = {blocks:[{t0,t1,kind}], on, off, stageAt(t)}`. Zeiten in Sekunden Unix. `kind` = 'haupt' | 'teil' | 'nap'. `on`/`off` = Einschlafen/Aufwachen des Hauptschlafs. HRV und Ruhepuls nutzen nur Epochen mit `stageAt(t) !== 'wake'` in 'haupt' und 'teil'. Nickerchen nie. Rhythmus nutzt den Schlaf für "Ruhe" (Merkmal 3) und die Nennerzeit.
Reihenfolge in `wFinalizeDay0`: (1) Epochen, (2) `wRrChain`, (3) Fenster und Phasen → `slp`, (4) Ruhepuls, (5) HRV, (6) Atmung, (7) Rhythmus, (8) Tageswerte, (9) Erholung (in `wDeriveFrom`).
Gespeichert: `blocks` (kompakt), `slMeasH` (h), `sleepCover` (0–1 oder null), `sleepHours` (h, nur volle Nacht, Bedeutung unverändert), `slLatency` (min), `bedHour`/`wakeHour` (Stunde mit Bruchteil).

**S2 Ruhepuls-Definition (VO2max, Erholung, Zonen).** `whoop.rhr` = `wRhrWhoop` über die Schlaf-Epochen aus S1. Rückfall ohne Phasen: 5-min-Minimum. Die Methode steht in `_rhrMethod`. VO2max nimmt den Median aus vollständigen Nächten desselben Bandtyps; 'min5'-Nächte nur bei Mangel (plan-vo2max 6.1). Der Ruhepuls kommt damit aus demselben Schlaf wie die HRV.

**S3 HRV → Erholung.** Je Nacht: `hrvMs` (ms, Anzeige, Name unverändert), `hrvLn` (neu), `_hrvV` (neu, 2), `_hrvOldMs` (neu, nur Übergang). Erholung für MG-Tage: zH aus `hrvLn` gegen ln-Basislinie. Für 4.0- und Export-Tage: unverändert ms.

## 7. Entscheidung WALGO_VER

**Entscheidung: `WALGO_VER` bleibt 24. Kein Sprung.**
Gründe:
1. `wBaseline` (Zeile 15988) zählt keine Band-Nacht mit `_avN < WALGO_VER` für HRV, Ruhepuls und Atmung.
2. Rohdaten liegen nur 3 Tage (`WEP_KEEP_DAYS=3`, Zeile 11542). Ältere Nächte sind nicht neu rechenbar.
3. `wRecomputeStored` rechnet nach einem Sprung die Erholung aller Bandtage neu. Auch die 4.0-Tage verlören ihre Basislinie.
4. Ein Sprung würde also Nächte aus der Rechnung werfen. Die Regel "keine Daten verlieren" verbietet das.

Ersatz:
- Neues Feld `_hrvV` (Wert 2) je Nacht. Neue Konstante `WHRV_VER=2`.
- `sameN` (Zeile 12714) und die Signatur in `wHealNights` (Zeile 13596) prüfen zusätzlich `_hrvV===WHRV_VER`. So rechnet jede Nacht mit Rohdaten einmal neu. `_avN` bleibt 24.
- Beim Neurechnen bleibt der alte Wert: `_hrvOldMs` = altes `hrvMs`.
- δ = Median von `ln(_hrvOldMs) − hrvLn` über alle so gerechneten Nächte. Speicher: neues Feld `S.whoopMig = {hrvDelta, n, date}`. Kein bestehender Schlüssel ändert sich.
- MG-Nächte ohne Rohdaten bleiben in der Basislinie: `hrvLn = ln(hrvMs) − δ`. Ihr `hrvMs` bleibt unverändert stehen.
- Bis n ≥ 3 gilt δ als vorläufig. Die Erholung trägt dann "vorläufig".
- 4.0-Nächte und Export-Tage: kein Feld ändert sich. Ihre Erholung rechnet weiter in ms.
- "Messwerte-Datei einspielen" bleibt der Weg, alte Nächte echt neu zu rechnen.
Lage heute: Die erste MG-Nacht war 25./26.11. Alle MG-Nächte liegen noch in den 3 Tagen Rohdaten. Je früher Schritt 5 kommt, desto kleiner ist der Übergang.

## 8. Bauplan (eine Reihenfolge, kleine Schritte)

Jeder Schritt: Selbsttest grün (heute 295/295), dann weiter. "Gleich" heißt: alle gespeicherten Felder der Testnächte gleich wie vorher (Vergleich per JSON vor/nach).

| Nr | Schritt | Abnahme |
|---|---|---|
| 1 | Diagnose nur anzeigen: HRV-Nebenwerte (`_hrvAllUnw`, `_hrvDeep`, `_hrvFixedPct`, `_hrvValidMin`, Verteilung `cleanFraction`), `sleepState`-Statistik je Nacht, `_slDiag` kopierbar | Keine Zahl ändert sich ("gleich"). Diagnose der Nacht 25./26.11. lesbar |
| 2 | `epochsFor` gibt `sm` heraus. `e.rr` bleibt auf ≤ 2500 gefiltert, damit alte Nutzer gleich rechnen | "gleich" |
| 3 | `wRrChain` (K1–K5) als reine Funktion mit Tests. Noch kein Nutzer | K-T1, K-T2, HRV T2 a–c, Rhythmus 6/12/14 grün |
| 4 | `WRR_MAX` 3500 im Decoder | MG-Referenz-Test (Zeile 14460) grün; Wert 2600 kommt durch; HRV/Phasen dank Schritt 2 "gleich" |
| 5 | HRV-Fenster auf `wRrChain`, Fenster nach Zeit. Methode sonst gleich | T1, T3 grün. Nacht ohne Lücken: `hrvMs` gleich (±0,1) |
| 6 | Schlaf-Blöcke: `_wSptPick` gibt Liste; `blocks`, `slMeasH`, `sleepCover`; `sleepHours` unverändert | I42–I47, I49–I53 grün; I38–I41 und Rand-Tests 15387 ff. unverändert grün |
| 7 | Schnittstelle S1: Ruhepuls und HRV lesen `slp` (Zeiten statt Indizes) | Nacht mit einem Block: `rhr`, `hrvMs` gleich. I43: HRV aus beiden Blöcken |
| 8 | HRV-Methode 2: Mindestdaten, ln-Mittel, kein Rückfall, 10–180, `_hrvV`, `_hrvOldMs` | HRV T4, T5, T10, T12 grün |
| 9 | Migration δ und ln-Basislinie (nur MG), Erholung ln (nur MG) | HRV T6, T7, T8, T9, T13 grün. Alle 4.0-Tage: `recoveryScore` gleich. Keine Nacht fällt aus einer Basislinie |
| 10 | Offline-Prüfung ln-z gegen 309 Export-Tage (L15) | mittlere Abweichung ≤ 7,4 Punkte, sonst Koeffizient neu |
| 11 | Rhythmus: Tor, Klassen, Score, `rhy.v=2`, Raten, Texte | Rhythmus-Tests 1–14, Rate-, Mindestdaten-Test grün; alte `rhy` lesbar |
| 12 | `wRhythmNight` entfernen | keine Anzeige ändert sich |
| 13 | `ecgEctopy` | EKG-Test (1 PVC bei 70/min ≠ "unregelmäßig") grün |
| 14 | VO2max 6.1–6.3: Profilpflicht, Ruhepuls nach S2, `hrMaxDay` | VO2 T1–T3, T10, T11, T16–T19 grün |
| 15 | VO2max 6.4–6.6: Läufe mit GPS und stabilem Teil, Versatz, Labor, Anzeige | VO2 T4–T9, T12–T15, T20 grün; alte Tests 15033/15727 mit `mode:'gps'` |
| 16 | Schlaf-Wachregeln, `bs`, Zeit-Prior (plan-schlaf 6.3, 6.4 d) — erst nach Messung 6.8 | I48 von "bekannte Lücke" auf echt; I55 grün |
| 17 | docs/berechnungen.md angleichen (Zeile 29, HRV, Schlaf, Rhythmus) | Doku nennt dieselben Regeln wie der Code |

Schritte 11–15 hängen nicht an 6–10 und können parallel laufen. Schritt 16 hängt an echten Nächten.

## 9. Felder und Funktionen, die sich ändern

Neue Felder je Nacht (`whoop`): `hrvLn`, `_hrvV`, `_hrvOldMs`, `_hrvAllUnw`, `_hrvDeep`, `_hrvLastSws`, `_hrvFixedPct`, `_hrvValidMin`, `slMeasH`, `sleepCover`, `blocks`, `slMicro`, `tibMin`, `_nFinal`, `hrMaxDay`, `vo2maxCalc`. Im Objekt `rhy`: `v`, Score je Ereignis (Index 5), neue Klassen.
Neue globale Felder: `S.whoopMig` (δ), Laborwert VO2max mit Datum im Profil.
Geänderte Bedeutung: keine. `sleepHours`, `hrvMs`, `rhr`, `_avN`, `recoveryScore` behalten ihre Bedeutung.
Nicht mehr geschrieben: `whoop.rhythm` (alt, ohne Anzeige). Bestehende Werte bleiben.
Konstanten: `WRR_MAX` 2500 → 3500. Neu `WHRV_VER=2`. `WALGO_VER` bleibt 24.
Neue Funktionen: `wRrChain`, `wRhythmGate`, `wRhythmScore`, `ecgEctopy`, `wBaselineLn` (oder Feld in `wBaseline`), `vo2Passive`, `vo2Run`.
Geänderte Funktionen: `WDayAgg.epochsFor` (gibt `sm`), `wparseV18`/`wparseR24` (Grenze), `wCorrectRr` (ohne `ts` aufrufbar), `wHrvWhoop` (Zeitfenster, ln, Mindestdaten, `gen` als Parameter statt `window._wFinGen`), `wHrvClean` (kein Rauschabzug-Rückfall für die Nacht), `wRhrWhoop` (liest `slp`), `wRespRate` (Läufe), `_wSptPick`/`wSleepWindow`/`wSleepWindowEnmo` (Blockliste), `wSleepSummary` (Wachphasen ≥ 2 min, TIB), `wFinalizeDay0` (Reihenfolge S1, `sameN` mit `_hrvV`), `wHealNights` (Signatur), `wBaseline`, `wComputeRecovery` (ln nur MG), `wRhythmDay`, `_ctxRhyNights`, `vitContext`, `vitRhythm`, `RHY_T`, `ecgAnalyze`, `wVo2At`, `wVo2FromRuns`, `wUpdateVo2max`, `_vo2Nights`, `vo2Series`, `openVo2`.
Entfernt: `wRhythmNight`, `wVo2maxFromSegment` (tot).

## 10. Risiken

1. MG-Nächte ganz ohne HRV: 0,85-Schwelle plus 60-min-Minimum können bei MG-Jitter jede Nacht leeren. Gegenmittel: Schritt 1 zuerst, Schwelle danach.
2. δ aus wenigen Nächten ist unsicher. Gegenmittel: "vorläufig" bis n ≥ 3; nach 30 Tagen ist δ ohne Wirkung.
3. Rechenzeit am Handy: `wRrChain` einmal je Nacht ist billiger als heute (heute `wCorrectRr` je Fenster, ca. 800-mal). Backfill-Neuberechnung bei jedem Abruf kostet aber Sekunden. Nur bei neuen Epochen rechnen.
4. Speicher: `WRR_MAX` 3500 und `blocks` erhöhen die Daten kaum. Das IDB-Problem vom 24./25.11. (Commit c50d0d3) betrifft Epochen, nicht Tagesfelder.
5. Die Erholung ändert sich für MG-Tage durch ln und neue Streuung. Der Fit (7,4 Punkte) ist an ms geprüft. Schritt 10 vor der Freigabe.
6. Rhythmus-Zahlen fallen nach dem Umbau stark. Das ist gewollt, wirkt aber wie ein Fehler. Text in der App nennt den Methodenwechsel.
7. Alte Tests prüfen alte Annahmen (z. B. Lauf ohne GPS). Sie müssen angepasst werden, nicht gelöscht.
8. Zwei andere Agenten (Schlafscore, Pace of Aging) lesen Schlaffelder. Sie brauchen `slMeasH`, `sleepCover`, `blocks` aus S1. `sleepHours` bleibt, also bricht nichts.

## 11. Was nur eine echte Nacht prüfen kann

- Ob Sekunden ohne Record bei der MG überhaupt vorkommen und wie oft (Bitmaske `sm` je Nacht auszählen).
- Verteilung von `cleanFraction` und Anzahl gültiger HRV-Fenster je MG-Nacht. Danach 0,85 und 60 min festlegen.
- δ zwischen alter und neuer HRV-Methode.
- Ob `sleepState` (Byte 73) mit Atlas-Schlaf übereinstimmt (≥ 85 % / ≥ 50 %, plan-schlaf 6.8).
- Ob ruhiges Wachliegen erkannt wird (Nutzer: ca. 5 h, App: 5:49 h).
- Echte Rate von Rhythmus-Mustern je saubere Stunde und Anteil Messfehler nach dem neuen Tor.
- Ob Werte über 2500 ms überhaupt vom Band kommen (nach `WRR_MAX` 3500).
- Ruhepuls-Abstand zwischen 'whoop' und 'min5' an MG-Nächten.
- Für VO2max: Lauf mit GPS-Spur und `band.ser`, um den stabilen Teil zu prüfen.
- Nichts davon ersetzt eine Referenz: Polar H10 für HRV und Rhythmus, Labortest für VO2max.
