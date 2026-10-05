# Raster: woher jeder angezeigte Wert kommt

Stand: Rechen-Version `WALGO_VER = 20`, App-Stand `APP_BUILD` / `<meta name="atlas-build">` = `20-2026-10-04a`. Jede Zeile: Rohmessung → Funktion → Zeitfenster → Speicherort → wohin der Wert fließt.
Die Invarianten am Ende prüft der Selbsttest (Bandseite → Selbsttest, Abschnitt 9, `W_INVARIANTS`).

## 0. Rohdaten (WHOOP 4.0 per Bluetooth)

| Rohwert | Takt | Inhalt |
|---|---|---|
| `hr` / `hrSamples` | 1 Hz, gemittelt je 30-s-Epoche | Puls (0 = Band nicht am Arm, zählt nie) |
| `rr` | je Schlag | Schlagabstände in ms (Grundlage für HRV, Phasen, Atmung). Platzhalter 500/333/334 ms bei deutlich längerem lokalem Takt (`_wIsPh`) sind fehlende Schläge: in `wCorrectRr` nie per Spline überbrückt, vor `_wRk`, `_wSdnn` und der Atmung herausgefiltert (`_wNoPh`); gespeichert bleiben sie unverändert |
| `mags` → `enmo`, `msd` | 1 Hz | Beschleunigungsbetrag → Bewegung gegen die Schwerkraft-Referenz bzw. Unruhe innerhalb der Epoche |
| `za` | 1 Hz | Handgelenkwinkel gegen die Schwerkraft (van Hees) |
| `temp` | nur Gen5 | Hauttemperatur in °C |

Gespeichert werden die Epochen der letzten 3 Tage (`_wEpDb`), exportierbar als „Messwerte-Datei“.

## 1. Nachtwerte — `wFinalizeDay`, Nacht = Vortag 12:00 bis heute 12:00 (Tag des Aufwachens)

| Wert | Quelle | Funktion | Zeitpunkt/Fenster | Speicherort | fließt in |
|---|---|---|---|---|---|
| Ruhefenster (SPT) | `za` (sonst `msd`) | `wSleepWindow` = van Hees 2018 / HDCZA: Winkel je 5 s, absolute Änderung, gleitender 5-min-Median, Schwelle 10. Perzentil × 15 (0,13–0,5°); Ruheblöcke ≥ 30 min, Lücken < 60 min überbrückt (`_wSptPick`; Blocklänge und Lücke in **Zeit** aus `t`, nicht in Epochen-Indizes. Ein ruhiger Lauf wird an **jedem Loch ohne Epochen > 10 min** in dichte Teilblöcke geteilt, Randepochen > 2 min neben dem Nachbarn fallen weg, erst dann Länge und Abdeckung (≥ minLen/2 Epochen, ≥ 50 % der Zeitspanne belegt) — vereinzelte stille Epochen hängen nie an der Nacht. Teilblöcke werden über Lücken ≤ 60 min verbunden, **Abdeckung je Verlängerung**: was hinter der Lücke angehängt wird (Teilblock samt der Teilblöcke, die ohne Loch > 10 min an ihm hängen), muss so lang sein wie die Lücke oder mit ihr zu ≥ 50 % mit Epochen belegt sein — kurze stille Schübe (12/40 Epochen alle 55 min) hängen so nie an der Nacht; der verbundene Block beginnt und endet mit einem dichten Teilblock; fällt er durch die Abdeckung, gilt seine längste bestehende Kette aus Teilblöcken (nie null, nie ein Sprung zu einem fremden Block wie dem Nachmittag davor); ein Fenster mit < 120 gemessenen Epochen wird verworfen), nur wenn der Puls in der Lücke unter dem Wachpuls − 3 und ≤ Puls des Nachbarblocks + 10 liegt (Couch-Abend bleibt draußen); längster Block; Puls im Fenster < außerhalb. Ohne Winkel: `wSleepWindowEnmo` (Unruhe, Blöcke ≥ 5 min, gleiche Lückenregel) | Nacht (Vortag 12:00 bis 12:00 Ortszeit, auch an Tagen der Zeitumstellung) | `whoop._slDiag.w0/w1/m` (`hdcza`/`msd`); `hours` = Ende − Beginn + 30 s, `asleepHours` = gemessene ruhige Epochen | Phasen, alles Folgende |
| Phasen Wach/Leicht/Tief/REM | `hr`, `rr` (Rk, SDNN, LF/HF), `hrSamples`, `msd`, `za` | `wSleepStages3` (Viterbi) | Ruhefenster, je 30 s | `slDeep/slRem/slLight/slAwake`, `hyp`, `slWakes` | nur Anzeige (Schätzung, in keinem Score) |
| Einschlafen / Aufwachen | Phasen | `wSleepSummary`: erste / letzte Strecke ≥ 5 min; für den Beginn zählt auch „still bei Schlafpuls“ (keine Bewegung, kein Pulsanstieg, Puls ≤ Schlafmedian + 3) — diese Epochen bleiben Wachzeit | Ruhefenster | `bedHour`, `wakeHour`, `hyp0` | Schlafkonsistenz, Basic „Konstante Schlafzeiten“, Energiekurve (Aufwachzeit), Nickerchen-Suche |
| Einschlaflatenz | `msd`/`enmo` > 0,02 g oder Winkelsprung ≥ 30° | `wFinalizeDay` | letzte aktive Bewegung bis 2 h vor dem Einschlafen | `slLatency` | Anzeige |
| Schlafdauer | Phasen | `wSleepSummary` (Leicht + Tief + REM) | Einschlafen bis Aufwachen | `sleepHours`, Brücke `dd.sleep.hours` | Schlafleistung, Schlafschuld der Folgetage, Energiekurve, Atlas-Schlaf |
| Effizienz | Phasen | Schlaf / (Aufwachen − Einschlafen) | dto. | `sleepEff` | Anzeige |
| Ruhepuls | `hr` der Schlaf-Epochen | `wRhrWhoop`: min(Tiefschlaf-gewichtet, **Median 2. Schlafhälfte**); zu wenig Tiefschlaf: Median 2. Hälfte; ohne Phasen: 5-min-Minimum (`wNocturnalRhr`) | Schlaf | `rhr` (nur 30–85, sonst fehlend + `_rhrNote`) | Erholung (11 %), Basislinie, Zonen/Strain/Kalorien (Bezug), VO₂max |
| HRV (RMSSD) | `rr` der Schlaf-Epochen | `wHrvWhoop`: 5-min-Fenster alle 30 s, Fehlschläge korrigiert (`wCorrectRr`, Fenster nur mit ≥ 70 % sauberen Schlägen), **Artefakt-Fenster verworfen** (Lag-1-Autokorr. < −0,35 oder > Median + 5 robuste SD), **kein statistischer Rauschabzug** (wie Kubios/Lipponen-Tarvainen; nur ein erkanntes Rundungsraster wird exakt abgezogen); gewichtetes Mittel (Tiefschlaf, spätere Nacht) oder Median der 2. Hälfte, wenn höher. Ohne ≥ 6 Fenster: `wHrvClean` über die Nacht | Schlaf ohne Wach-Epochen | `hrvMs`, `_hrvRaw`, `_hrvMethod`, `_hrvNoiseF` (angewandter Faktor, Fenster: 1), `_hrvWin`, `_hrvRej`, `_hrvMode` (> 180 ms: fehlend + `_hrvNote`) | Erholung (83 %), Basislinie |
| SDNN | `rr` | `wHrvClean` | Schlaf | `sdnnMs` | Anzeige |
| Atemfrequenz | `rr` | `wRespRate` (RSA + RIIV): nur 5-min-Fenster aus 10 lückenlosen Epochen, RSA nur bei ≥ 70 % Schlagabdeckung; Median ≥ 3 Fenster | Schlaf | `respRate` | Anzeige (Gewicht 0 in der Erholung) |
| Erste Schlafstunden belastet | `hr`, 5-min-RMSSD | `wFinalizeDay`: Puls der ersten 3 h − Puls 2. Hälfte ≥ 4 oder HRV früh/spät < 0,75 | Schlaf | `_earlyLoad {hrDelta, hrvRatio}` | nur Hinweis (Schlafübersicht, Coach-Snapshot), ändert keinen Wert |
| Hauttemperatur | `temp` (Gen5) | Median | Ruhefenster | `skinTemp` | „Warum“-Erklärung |
| Abdeckung / Version | Epochen mit Puls | Zählung | Nacht | `_nightEp`, `_avN`, `_ftN` (nur wenn die Nacht neu gerechnet wurde), `_skipN`, `_slNote` | Schutz vor Teil-Daten, Abgleich (s. u.) |
| Nacht unvollständig | Zeitstempel `t` der Nacht-Epochen | `wFinalizeDay`: Loch ohne Epochen ≥ 30 min, das ≤ 15 min vor dem Ruhefenster endet (`luecke_beginn`) oder ≤ 15 min nach ihm beginnt (`luecke_ende`); oder die Daten beginnen ≤ 15 min vor dem Fenster, obwohl der Zeitraum (Vortag 12:00) ≥ 30 min früher anfängt; oder die Nacht-Epochen enden ≥ 30 min vor 12:00 und ≤ 15 min nach dem Fenster, und **danach** gibt es Daten (nach 12:00 oder am Folgetag) — ohne spätere Daten (Abruf am Morgen) zählt das fehlende Ende nicht. **Ruhe am anderen Ende des Lochs** (30 min davor bzw. danach: ≥ 30 Epochen, < 30 % aktive Bewegung, Puls-Median ≤ Fensterpuls + 10): dann zählt das Loch auch, wenn es bis 60 min vor dem Fenster endet bzw. bis 60 min nach ihm beginnt (Ruheblock vor dem Loch, den das Fenster nicht mehr erreicht — z. B. Schlaf bis 2:00, Loch 70/90 min). **Geprüft am gemessenen Einschlafen/Aufwachen** (`wSleepSummary`), vor der Latenz: Beginn — der Schnitt bleibt, wenn Einschlafen < 5 min nach dem Lochende liegt oder die ersten gemessenen Epochen am Loch schon Schlaf sind (keine Wachphase im Fenster vor dem Einschlafen, keine aktive Bewegung zwischen Loch und Fenster); Ende — er bleibt nur, wenn das Aufwachen < 5 min vor dem Lochbeginn liegt **und** danach keine Wachphase/aktive Bewegung gemessen ist. Gestrichen wird ein Schnitt aber nur, wenn am anderen Ende des Lochs keine Daten oder keine Ruhe liegen (Schlaf, Loch, gemessen wach, wieder Schlaf bleibt unvollständig); sonst gilt gemessene Wach-/Latenz-Epochen = Beginn/Ende beobachtet, kein Schnitt. **Löcher im Schlaf**: Zeit ohne Epochen zwischen Einschlafen und Aufwachen (je Schritt − 30 s, ab 2 min) ≥ 30 min zusammen → `luecke_mitte` | Nacht | `_slNote`, `_slCut {s,e,s0,e1,h}` (`s`/`e`: bis/ab wann Daten fehlen; `s0`/`e1`: anderes Ende des Lochs, null = davor/danach keine Daten; `h`: Löcher im Schlaf [von, bis], höchstens 20 gespeichert; `hn`/`hs`: wahre Zahl und Summe in s aller Löcher, im Text „weitere n Löcher“/„zusammen …“), `_slPartH` (Schlaf im gemessenen Teil), `_slPartDrop` | Hinweis „Nacht unvollständig — Loch von 0:00 bis 3:00“ (gab es davor/danach Daten) bzw. „Daten fehlen bis 4:03“ (Schlafübersicht, Bandseite, Coach-Snapshot); **kein** `sleepHours`, keine Brücke `sleep.hours`, kein `bedHour` (Beginn fehlt) bzw. `wakeHour` (Ende fehlt), keine Einschlafdauer und kein „erste Schlafstunden“-Hinweis bei fehlendem Beginn → Schlafleistung fehlt, Schlafschuld überspringt die Nacht. **Erholungs-Eingänge der Teilnacht**: Ruhepuls/HRV/SDNN/Atemfrequenz nur, wenn der gemessene Schlaf ≥ 4 h ist **und** die zweite Nachthälfte abdeckt (Ende gemessen, darin < 15 min ohne Daten) — sonst fehlen sie (`_slPartDrop`, kein `_earlyLoad`) und damit die Erholung; Teilnächte zählen **nie** in die Basislinie (`wBaseline`); eine Erholung aus einer Teilnacht trägt überall den gelben Hinweis „Nacht unvollständig“ (Startseite, Teilwerte, Erholungszeile, Verlauf, WHOOP-Seite) und im Coach-Snapshot `nacht_unvollstaendig` |

**Schreibregel Nacht:** Neu gerechnet wird nur mit mindestens 95 % der Nacht-Epochen der letzten Rechnung (alte Stände: Fensterlänge bzw. Schlafstunden als Untergrenze). Dann werden **alle** Nachtfelder (`W_NIGHT_F`) neu gesetzt oder gelöscht — nie bleibt ein Wert einer früheren Rechnung neben neuen stehen. Schlafdauer, Effizienz, Bett-/Aufwachzeit und die Brücke `sleep.hours` nur mit Phasen-Ergebnis (`wSleepSummary`); ohne Phasen `_slNote='keine_phasen'` und dann **auch kein Ruhepuls, keine HRV, keine Atemfrequenz, keine Hauttemperatur** (die Erholung bekäme sonst Werte aus einem Fenster ohne Schlaf-Ergebnis). Teilnacht siehe Zeile „Nacht unvollständig“. Mit weniger Daten (Teil-Datei, Live-Abgleich mitten in der Nacht eines schon gerechneten Tages) bleibt die Nacht unverändert (`_skipN`).

## 2. Tageswerte — `wFinalizeDay`, Kalendertag 0–24 Uhr

| Wert | Quelle | Funktion | Fenster | Speicherort | fließt in |
|---|---|---|---|---|---|
| Kalorien (Band) | `hr` | `wDayKcal`: Keytel ab Ruhepuls + 40 % HFR, sonst Grundumsatz; nicht getragen = Grundumsatz | Tag (≥ 50 % getragen) | `kcalBand`, `_kcalCov` | Anzeige; Strain nur ohne Puls-TRIMP |
| Pulszonen | `hr` | `wZoneOf` (Karvonen, Z1 50 % … Z5 90 % HFR) | Tag | `zMin`, `z13Min`, `z45Min`, `z2BoutMin` | Anzeige, Cardio-Wertung |
| Tages-Strain | `hr` | `wTrimpBanister` (ab 40 % HFR; Männer 0,64·e^1,92x, Frauen 0,86·e^1,67x, unbekannt: Männer) → `wStrainFromTrimp` = 5,086·ln(1 + TRIMP/5,98) | Tag | `trimpDay` → `strain` = `dayStrain`; Abdeckung `_dayEp` | Schlafbedarf des Folgetags (2,85 min je Punkt), Anzeige — unter 2600 Epochen mit „x von 24 h gemessen“ (Strain-Zeile, Schlafbedarf) |
| Erkannte Einheiten | `hr`, `msd` | `wZoneDay` (≥ 10 min ab Zone 2) | Tag | `bandWorkouts`, Laufen → `cardioSessions` (auto) | Cardio-Wertung im Trainings-Score; Diktat ohne Uhrzeit wird über die Dauer zugeordnet |
| Nickerchen | `za`, `msd`, `hr` ≤ Ruhepuls + 8 | `wDetectNaps` (≥ 20 min) | Aufwachen + 30 min bis 21 Uhr | `naps`, `napMin` | Schlafbedarf des Folgetags (abgezogen) |
| Trainingswerte | `hr`, Satz-Uhrzeiten | `wTrainLoad`: „Training beginnen“ bis „Beenden“, **höchstens 2 h**; ohne Ende: Puls fällt 10 min unter Ausgang + 12 | Einheit | `trainLoad[sid]` (Spitzenpuls je Satz, Belastung, Strain, Erholung 2 min) | Trainings-Score Intensität (30 %, nur bestehende Einheiten: `_trainEffort`) |
| Bewegungsvolumen | `enmo` | Summe | Tag | `_moveIdx` | Anzeige |
| Maxpuls | `hr` ≥ 100 mit Bewegung, 2 min gehalten; WHOOP-Export | `wHrMaxObs` | laufend | `whoopBand.hrMaxObs`, `whoopRef.hrMax` | Zonen, Strain, Kalorien, VO₂max |

**Schreibregel Tag:** wie Nacht, Schwelle 98 % der Tages-Epochen (`_dayEp`; alt: gemessene `_kcalCov`/`_moveCov`, fehlen beide, aber `trimpDay`/`zMin` stehen da: 2400). Version/Zeit `_avD`/`_ftD` nur, wenn der Tag neu gerechnet wurde; `_av` = min(`_avN`, `_avD`). Trainingswerte mit Teil-Daten: fehlende Einheiten ergänzt, eine vorhandene nur ersetzt, wenn die neuen Daten mindestens so viel ihrer Zeit abdecken.

## 3. Abgeleitete Werte — `wDeriveDay`, immer aufsteigend über `wDeriveFrom(ab Tag)`

| Wert | Eingänge | Formel | Speicherort | fließt in |
|---|---|---|---|---|
| Schlafkonsistenz | `bedHour`, `wakeHour` der letzten 14 Tage (inkl. heute, ≥ 4) | 100 − 35 · zirkuläre SD (h) | `sleepCons` | Schlafleistung |
| Schlafbedarf | Grundbedarf (`whoopRef.needBase`, sonst Altersnorm), `dayStrain` und `napMin` des Vortags, Schlaf/Bedarf der 7 Vornächte | Grund + 2,85·Strain + Schuld − Nickerchen, 6–11 h; Schuld = 0,27 · Σ 0,3ᵏ·(Bedarf − Schlaf) | `sleepNeed`, `sleepDebt` | Schlafleistung, Energiekurve, Schuld der Folgetage |
| Schlafleistung | `sleepHours`, `sleepNeed`, `sleepCons` (fehlt: `whoopRef.consMed` oder 65) | 0,707·min(Schlaf/Bedarf, 1)·100 + 0,245·Konsistenz + 3,4 | `sleepPerf`, Brücke `dd.sleep.quality` = SP/10 | Erholung, **Atlas-Schlaf-Teilwert (identisch)**, Energiekurve |
| Erholung | `hrvMs`, `rhr`, Basislinien (30 Tage davor, ab 4 Nächten, **ohne Band-Nächte älterer Rechen-Version** (`_avN`/`_av` < `WALGO_VER`, Rohdaten weg) **und ohne Teilnächte** (`_slNote` `luecke_*`); sonst WHOOP-Export; SD robust über MAD, bis 14 Nächte mit Export-SD gemischt), `sleepPerf` | zH = (HRV − Med)/SD, zR = (Med − RHR)/SD, je ±2,5; logit = 0,83·zH + 0,11·zR + 0,286·(SP − 85)/10 + 0,878 → 1–99 %; **ohne HRV keine Erholung** | `recoveryScore`, `_recIn` (alle Eingänge), Brücke `dd.recovery.hrv` = Score/10 | Atlas-Erholung (20 %), Energiekurve, „Warum“-Erklärung |
| Strain | `trimpDay`; ohne Band: Sätze, Cardio-Minuten, Kalorien | s. o. | `strain`, `dayStrain` | Schlafbedarf Folgetag |
| Basics automatisch | `bedHour/wakeHour` (±30 min vom Median 14 Nächte); Einschlafen vs. letzte Mahlzeit des Vortags (≥ 2,5 h) | `wAutoBasics` | `protocol.sleepreg`, Vortag `protocol.nofood` | Basics-Score |

Jeder abgeleitete Wert wird gesetzt **oder gelöscht**; Brücken (`_band_*`) nur, solange dort noch der Bandwert steht (Handeingaben bleiben). Ein Zeitstempel `_bt` entsteht nur, wenn sich etwas geändert hat.

## 4. Verbraucher

| Anzeige | liest |
|---|---|
| Atlas Score (`dayScore`) | Gewichte Schlaf .25, Erholung .20, Training .18, Ernährung .17, Basics .12, Supplements .04, Gesundheit .04. Schlaf = `sleepPerf`, sonst eigene Formel mit Handangaben; Erholung = `recoveryScore`, sonst Handangaben |
| Energiekurve (`energyModel`) | `wakeHour`, `sleepNeed`, `sleepHours` (gemessen vor eingetragen), Erholung, `sleepPerf`, Koffein-Uhrzeiten |
| VO₂max (`wUpdateVo2max`) | GPS-Läufe ≥ 10 min mit Band-Puls (ACSM + Swain, Median); sonst Uth 15,3·HFmax/Ruhepuls (Median der 14 letzten plausiblen Nächte) → `whoopBand.vo2max` |
| Coach-Snapshot | dieselben gespeicherten Objekte `whoop`, `sleep`, `recovery` und die Teilwerte (inaktive Teilwerte laut `dayActive` als `null`, nie als Standardwert — heute und je Tag im Verlauf `historie_alle_tage`); `nacht_unvollstaendig` (true bei `luecke_*`) + Hinweistext, im Verlauf je Tag |
| Bandseite | Ruhepuls, HRV (Methode, Fenster, verworfene Fenster, Güte), Schlaf, VO₂max, Ruhefenster-Diagnose |
| Schlafübersicht (`sleepOverviewTile` → `sleepHypnogram`) | `hyp`/`hyp0` (Bahnen Wach/REM/Leicht/Tief, Zeitachse Einschlafen–Aufwachen; Achsenende = gespeichertes Aufwachen `_slDiag.off`, sonst `wakeHour`; fehlende 30-s-Schritte stehen in `hyp` als `g<n>` und bleiben leer, Bettzeit ≈ Einschlafen − `slLatency`); Minuten und Anteile aus demselben Verlauf (ohne Verlauf: `sl*`-Summen); erholsamer Schlaf = Tief + REM; `_earlyLoad`-Hinweis |

## 5. Wann gerechnet wird

| Anlass | Ablauf |
|---|---|
| Band-Abgleich | je fertigem Tag `wFinalizeDay` → `wDeriveFrom(frühester Tag)` → VO₂max |
| Messwerte-Datei | `wFinalizeDay` je Tag der Datei → `wDeriveFrom(erster Tag)` → VO₂max |
| neue Rechen-Version | jedes Gerät beim Start (auch ohne Band) einmal `wRecomputeStored`: lokale Epochen neu, `wRepairOld` → `wDeriveFrom()`, VO₂max, dann hochladen. Merker nur lokal (`localStorage` `…wRawVer`), nicht im Konto |
| neue App-Version | offener Tab prüft alle 5 min und beim Zurückkehren den Kopf der ausgelieferten Datei (`atlas-build`); ist er neuer: `_atlasStale` — kein `wFinalizeDay`, kein Upload — und Neuladen, sobald kein Band-Abgleich, Lauf, Cardio, Krafttraining, keine Eingabe, kein Diktat, kein Upload und 20 s nichts gespeichert. iPhone-App (gebündelt): kein Neuladen, Schutz über den Server-Abgleich |
| WHOOP-Export | Cloud-Tage + `whoopRef`, dann `wDeriveFrom()` |
| Abgleich zwischen Geräten | Nacht- und Tagesteil getrennt (`_wMergeBand`): je Teil höhere Rechen-Version (`_avN`/`_avD`, alt `_av`), dann mehr Rohdaten (`_nightEp`/`_dayEp`), dann neuere Rechnung (`_ftN`/`_ftD`); gemischte Tage werden neu abgeleitet (`_wAfterMerge`). **Server (Worker `POST /state`) wendet dieselbe Regel an**: geschützt sind nur Bandtage (`whoop._src='band'`) — deren Nacht- bzw. Tagesteil von einem Client mit älterer Rechen-Version, weniger Rohdaten oder älterer Rechnung nicht überschrieben wird; bleibt der Nachtteil vom Konto, nimmt der Server auch die vom Band geschriebenen Brücken `sleep.hours`/`quality` und `recovery.hrv` (samt `_band_*`) vom Konto, sofern der gesendete Wert selbst eine Band-Brücke ist oder fehlt (von Hand Eingetragenes bleibt); alle übrigen Felder schreibt der Client wie gesendet. Der Client leitet danach jeden Bandtag neu ab, dessen whoop sich gegenüber dem lokalen Stand ändert oder dessen Brücken nicht zum eigenen whoop passen (`_wBridgeOff`), ab dem frühesten solchen Tag (`wDeriveFrom`) — beim Abruf (`pullState`) **vor** dem Vergleich (ändert das Ableiten etwas: neu zeichnen und hochladen), vor jedem Upload auch bei gleichem Stand, sobald Brücken abweichen, und nach einer `merged`-Antwort (ändert das Ableiten etwas: erneut hochladen); Antwort `merged` + Stand, den der Client übernimmt; `reload`, wenn die mitgeschickte Rechen-Version (`algo` im Body) älter ist |

Alte Werte vor Version 10 ohne Rohdaten: Ruhepuls/HRV/Erholung zählen nicht mehr, die Zahlen bleiben in `_oldVals` nachvollziehbar.

## 6. Diktat

| Schritt | Funktion | Regel |
|---|---|---|
| Sprache → Text | Browser-Spracherkennung | — |
| Text → JSON | Worker `/voice` (Groq oder Haiku) | Katalog (ids + Namen) im Prompt; Mittel als `{id, name}`, unbekannt `id: null`; Verneintes nicht; Uhrzeiten nur, wenn genannt |
| JSON → Vorschau | `voiceItems` | Tag = angezeigter Tag (oder Vortag bei `day: -1`); Supplements/Medikamente/Peptide per id, sonst Name (`_vMatch`: exakt, Wortanfang ≥ 4, Teilstück ≥ 6 Zeichen), dazu Suche im Diktat an Wortgrenzen (`_vInText`): Verneinung je Teilsatz (Trennung an . , ; ! ? „aber“, „sondern“, „und dann“; kein*/nicht/nichts/ohne/vergessen irgendwo im Teilsatz); Funde nur aus dem Text erscheinen als „im Text erkannt“; keine Dubletten; unbekannte ids/Mittel → „Nicht zugeordnet“; neues Supplement nur aus einem Namen, beim Speichern nie doppelt |
| Anwenden | `voiceCommit` | gleiche Felder wie die Handeingabe: `supp/med/pep[id]` = Tagesziel, `stim.caffeine` + `cafAt` (Uhrzeit, heute sonst „jetzt“, anderer Tag ohne Uhrzeit leer), `_saveCardio` (Minuten in `cardioMin`; ohne Uhrzeit `estT`), `training[]`, Schlaf nur ohne Bandschlaf |

## 7. Invarianten (Selbsttest)

| id | Regel |
|---|---|
| I1 | Ruhepuls nie über dem Median-Puls der zweiten Schlafhälfte; synthetische Nacht: 51 ± 1 |
| I2 | HRV: Artefakt-Fenster fallen weg, Wert bleibt der der sauberen Nacht (±10 %); synthetische Nacht: 24,6 ± 1 ms, Faktor 1 |
| I3 | Weniger Rohdaten ersetzen nie Nacht- oder Tageswerte aus mehr Rohdaten |
| I4 | Gleiche Rohdaten ergeben exakt gleiche Nachtwerte |
| I5 | Volle Nacht ohne Schlaf: alte Nachtwerte und Brücke verschwinden |
| I6 | Ohne Rohdaten der Nacht kein Ruhepuls, keine HRV, kein Schlaf |
| I7 | Ableitung aufsteigend ist ein Fixpunkt; Nachrechnen ohne Änderung setzt keinen neuen Zeitstempel |
| I8 | Erholung rechnet sich exakt aus den gespeicherten Eingängen nach; feste Formelwerte 71 / 89 / 21 |
| I9 | Schlafleistung aus Schlaf, gespeichertem Bedarf und Konsistenz |
| I10 | Schlafbedarf aus Grundbedarf, Strain und Nickerchen des Vortags und Schuld |
| I11 | Brücken `dd.sleep` / `dd.recovery` gleich ihrer Quelle |
| I12 | Atlas-Teilwerte Schlaf/Erholung und Strain lesen dieselben Zahlen |
| I13 | Nicht mehr belegte abgeleitete Werte und Brücken werden gelöscht |
| I14 | Abgleich: höhere Rechen-Version schlägt späteres Nachrechnen mit alten Rohwerten |
| I15 | Trainingsfenster: Start bis Beenden, höchstens 2 h |
| I16 | Trainings-Belastung nur aus Einheiten, die es im Tag noch gibt |
| I17 | Diktat: Supplements per id, Name und Wortgrenze, verneinte nicht, keine Dubletten |
| I18 | Diktat: unbekannte ids/Mittel nie eingetragen, sondern angezeigt |
| I19 | Diktat: neues Supplement genau einmal angelegt und abgehakt |
| I20 | Diktat: Koffein-Uhrzeiten, Cardio mit/ohne Uhrzeit und Minuten wie bei Handeingabe |
| I21 | Cardio ohne Uhrzeit bekommt den Puls der passenden erkannten Phase, nie aus geratener Zeit |
| I22 | Schlaffenster: kurze Unruhe teilt die Nacht nicht (Nacht 3./4.10. nachgebaut: Beginn ≤ 1:30, Ende ≥ 10:00, Couch-Abend draußen) |
| I23 | Abgleich je Teil: übersprungene Nacht mit alten Werten verliert gegen volle Nacht der aktuellen Version |
| I24 | Alter Tag ohne Zähler, aber mit Strain/Zonen: Teil-Datei überschreibt ihn nicht |
| I25 | Platzhalter-Schläge nie überbrückt, nie in SDNN/Rk |
| I26 | Atemfrequenz nur aus lückenlosen 5-min-Fenstern |
| I27 | Basislinie ohne Band-Nächte alter Rechen-Version, Export-Tage zählen |
| I28 | Strain: Banister-Gewichtung je Geschlecht |
| I29 | Hypnogramm: vier Bahnen, Minuten/Anteile aus demselben Verlauf |
| I30 | Veralteter Tab rechnet und lädt nichts hoch; Rohdaten-Version nur lokal |
| I31 | Ruhezeit nach Zeit: stilles Nickerchen, 9 h ohne Epochen, Nacht → nur die Nacht; Loch < 60 min in der Nacht zählt zur Fensterlänge |
| I32 | Hypnogramm: fehlende Epochen als `g<n>` gespeichert, leer gezeichnet, Achsenende = gespeichertes Aufwachen |
| I33 | Abgleich: Bandtag mit geändertem whoop oder abweichender Band-Brücke wird ab dem frühesten Tag neu abgeleitet |
| I34 | Ruhezeit nur aus gemessener Ruhe (12 stille Epochen im Abstand von 55 min → kein Fenster, keine Schlafdauer); erzwungen ohne Phasen (`wSleepStages3` → null): `keine_phasen`, keine Schlafdauer/Uhrzeiten, Brücke weg, kein Ruhepuls/HRV/Atemfrequenz |
| I35 | Abgleich (`whoopSyncSelfTest`, fetch-Attrappe): Abruf, Upload und `merged`-Antwort — neu abgeleitete Brücken werden gezeichnet und hochgeladen |
| I36 | Dichte 7-h-Nacht + 4/8/12 stille Einzel-Epochen bzw. 4/8 stille Schübe à 12 und 40 Epochen im Abstand von 55 min, dann wach: Fenster ≈ 7 h, Ende = Ende der dichten Nacht (± 3 min), über Winkel (`hdcza`) und Bewegung (`msd`) |
| I37 | Wie 3./4.10. ohne Winkel: ruhiger Nachmittag 14:00–16:30, Nacht dicht 23:30–3:00, danach nur alle 55 min eine Epoche → Fenster 23:30–3:00, nie am Nachmittag |
| I38 | Nacht wie I22 ohne Epochen 0:00–3:00 → `luecke_beginn`, `_slCut.s` = 3:00, kein `bedHour`/`sleepHours`/Brücke/Schlafleistung, Ruhepuls bleibt (≥ 4 h mit 2. Hälfte), Text „Loch von 0:00 bis 3:00“; ohne Epochen 6:00–8:00 → `luecke_ende`, kein `wakeHour`, kein Ruhepuls/HRV/Erholung, „Loch von 6:00 bis 8:00“; Loch 5:00–14:00 mit Daten bis 16:00 → `luecke_ende`, keine Schlafdauer/Aufwachzeit/Brücke, „Loch von 5:00 bis 14:00“; Schlaf, Loch 2:00–3:15, gemessen wach 3:15–3:27, wieder Schlaf → `luecke_*` mit `s0` = 2:00, kein `sleepHours`/`bedHour`/Brücke; Aufwachen 5:00, 3,5 min gemessen wach, Loch bis 14:00 (Daten bis 16:00) → kein Hinweis, dieselben Werte wie ohne spätere Daten; Schlaf bis 2:00 + Loch 70/90 min → `luecke_beginn`, `s0` = 2:00, `s` = Lochende; gespiegelt Loch ab 6:00 70/90 min, danach Ruhe → `luecke_ende`; dieselbe Nacht ohne spätere Daten (Abruf am Morgen) → kein Hinweis; volle Nacht → kein Hinweis |
| I39 | Daten beginnen 11 min vor dem Ruhefenster, gemessene Wachepochen vor dem Einschlafen (wie Sa 3.10. 1:59/2:10/2:29) → kein Hinweis, volle Schlafdauer (≥ 8 h, ± 0,25 h zur vollen Nacht), Bettzeit und Brücke da |
| I40 | Drei Löcher à 55 min im Schlaf (3:00, 5:00, 7:00) → `luecke_mitte`, `_slCut.h` mit 3 Löchern, Text „Loch von 3:00 bis 3:55“, kein `sleepHours`/Brücke/Schlafleistung, Bett- und Aufwachzeit bleiben; Loch in der 2. Hälfte → kein Ruhepuls/HRV/Atemfrequenz/Erholung (`_slPartDrop`); `hn` = 3, `hs` ≈ 3 × 55 min; Loch 2:00–2:50 → `luecke_*`, keine Schlafdauer/Brücke/Schlafleistung, „Loch von 2:00 bis 2:50“; Text mit `hn` = 25 bei 4 gespeicherten Löchern → „weitere 22 Löcher“, Summe aus `hs` |
| I41 | Teilnacht mit HRV 200/Ruhepuls 40 zählt nicht in die Basislinie (n = 4, Median 50/56); Coach-Snapshot: `nacht_unvollstaendig` true, inaktive Teilwerte `null` — auch im Verlauf (Tag mit Schlaf, ohne Mahlzeiten → `nut` null) |

Der Selbsttest sichert `S` beim Start und setzt es am Ende immer zurück (kein 2020-Testtag bleibt stehen); Testtage früherer Läufe (`2020-*`, Band, ohne Mahlzeiten/Training/Journal) werden dabei entfernt (nur lokal gespeichert, kein Upload).

## Tagesstress und Sauna (ab Version 21)

| Wert | Quelle | Funktion | Zeitpunkt/Fenster | Speicherort | fließt in |
|---|---|---|---|---|---|
| Tagesstress 0–3 je 5 min | Puls je 30 s; RMSSD je 5 min (wCorrectRr, ≥ 70 % saubere Schläge — tagsüber liefert das WHOOP 4.0 nur selten Einzelschläge) | wDayStress | Aufwachen bis letzte Messung; nur ruhige Epochen (Feinbewegung SD < 0,02 g) außerhalb von Schlaf, Nickerchen, Training/Cardio (geloggt oder Band-Workout, ±5 min) und Sauna samt Abklingen | whoop.stress {avg, lo, mid, hi (min), act, t0, ser, hb, base, h0, b0, tr} | Dashboard-Kachel „Tagesstress", Detailansicht |
| Puls-Anteil | (Puls − ruhiger Wachpuls) / (20 % HFR), 0..1 | wDayStress | ruhiger Wachpuls = Median der h0 der letzten 14 Tage (≥ 3), sonst Ruhepuls + 15 | stress.hb, stress.h0 | Stress = 3 × Mittel(Puls-, HRV-Anteil); ohne Einzelschläge 2,7 × Puls-Anteil |
| HRV-Anteil | ln(Tagesbasis / RMSSD) / ln 3, 0..1 | wDayStress, _wRmssdSlot | Tagesbasis = Median der b0 der letzten 14 Tage (≥ 3), sonst 75 % der Nacht-HRV-Basis | stress.base, stress.b0 | Stress |
| Sauna | Puls ≥ Ruhepuls + 30 (mind. 85; Hysterese −8) bei reglosem Handgelenk | wDetectHeat | Beginn = Start des Anstiegs (3-min-Vergleich), Ende = Ende des Plateaus am Höhepunkt; Abklingen bis Ausgangspuls + 10 (max. 30 min) separat; Gänge ≤ 25 min Pause = eine Sitzung, ≥ 8 min gesamt | whoop.heat [{s, e, rounds, peak, pre, min, dec}]; Antwort Ja/Nein in dd.heatAns | Stress (ausgenommen), Kachel/Detail (Bereich „Sauna") |

Sauna gegen Cardio (auch ungeloggt) — alle Prüfungen müssen passen: Feinbewegung SD < 0,006 g in ≥ 85 % der Epochen; 80 % des Anstiegs frühestens nach 4 min; ≤ 20 % der Minuten mit Abfall > 3 bpm im Anstieg; Abfall in 2 min nach dem Höhepunkt < 40 bpm; ein Gang ≤ 40 min; Anstieg ≥ 40 % der Gangdauer (kein Plateau); vorher in Ruhe (≤ Ruhepuls + 22), außer direkt nach einem erkannten Gang. Stresstest: 5 Zufallsserien × 100 Saunen + 1.100 Fallen (Standrad mit/ohne Feinzittern, Rad-Intervalle, Laufband, Rudern, Krafttraining, Sitzen nach Lauf, Stress im Sitzen/Auto, Fieber, Spaziergang): 500/500 erkannt, 0/5.500 Fehlalarme, Beginn 95 % ≤ 1,5 min, Ende 95 % ≤ 0,5 min. Selbsttest I42.

Fremd abgeholte Daten: Steht der Lesezeiger des Bandes beim Verbinden > 30 min hinter der letzten von Atlas gelesenen Messung, hat ein anderes Gerät die Zeit dazwischen geholt (whoopBand.lostGaps) — Hinweis im Dashboard.
