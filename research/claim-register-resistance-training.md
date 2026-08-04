# Claim-Register — Pilot-Domäne: Krafttraining / Resistance Training

**Status:** Erster Pilot des grösseren Claim-Register-Systems (200-Claim/10-Domänen-Rahmenwerk).
Dieses Dokument deckt bewusst nur EINE Domäne ab — Krafttraining —, die direkt dem
Trainings-Score von Atlas One entspricht (`docs/app-logic.md`, Abschnitt 2). Ziel: die bisher nur
Tier-3-gestützten Annahmen (Huberman-Notizen in `research/sources/huberman/`) durch Tier-1/2-Evidenz
zu ersetzen oder zu bestätigen, wo möglich — und ehrlich zu benennen, wo das nicht gelingt.

## Quellen-Tier-Legende (User-Hierarchie, unverändert übernommen)

| Tier | Beschreibung | Beispiele in diesem Dokument |
|---|---|---|
| **1** | ACSM Position Stands, NIH/NIA-Ressourcen, Cochrane Reviews, PubMed-Systematic-Reviews/Meta-Analysen | ACSM 2026, ACSM 2009, Cochrane CD002759, Schoenfeld 2017, Refalo 2022, Grgic 2018, Schoenfeld/Grgic 2019, Pelland 2025, WHO 2020 |
| **2** | Fachgesellschaften, hochwertige internationale Konsenspapiere, Autoren mit konsistent starkem Publikationsrecord | Plotkin 2022 (Einzel-RCT, kein Review), Buckner 2023 (Narrative Kritik) |
| **3** | High-Signal Podcast/Creator-Figuren (Huberman, Attia, Norton etc.) | nur als Hypothesen-/Struktur-Quelle, hier NICHT als Evidenzgrundlage verwendet |
| **4** | Reddit/YouTube/Blogs | nicht verwendet |

**Wichtiger Befund vorab:** Die für dieses Pilot-Projekt wertvollste Einzelquelle ist brandneu — das
**ACSM Position Stand von 2026** ("Resistance Training Prescription for Muscle Function, Hypertrophy,
and Physical Performance in Healthy Adults", *Medicine & Science in Sports & Exercise*, April 2026,
DOI 10.1249/mss.0000000000003897, Chair: Stuart M. Phillips) — das erste grosse Update seit dem
2009er Positionspapier, ein Umbrella-Review über 137 systematische Reviews mit 30.000+ Teilnehmern.
Es wurde über mehrere unabhängige Sekundärquellen (ACSM.org, Newswise, 2minutemedicine.com) konsistent
bestätigt; das Volltext-PDF selbst lag hinter einer Bezahlschranke (Ovid, HTTP 402) und konnte nicht
direkt gelesen werden — Zahlen stammen daher aus PresseZusammenfassungen der ACSM/Fachpresse, nicht aus
dem Originaltext selbst. Das wird bei den betroffenen Claims (RT-001, RT-002, RT-009) vermerkt.

---

## Claims

### RT-001
- **Claim:** Jede Form von regelmässigem Krafttraining verbessert Kraft, Muskelmasse, Power und
  körperliche Funktion gegenüber keinem Krafttraining messbar — der grösste Einzelsprung ist der von
  "kein Training" zu "irgendein Training", nicht die Feinabstimmung der Variablen danach.
- **Population/Kontext:** Gesunde Erwachsene aller Altersgruppen (Umbrella-Review über sehr heterogene
  Studienpopulationen).
- **Endpunkt:** Kraft, Muskelquerschnitt/-masse, Power, funktionelle Leistungsfähigkeit (Gangtempo,
  Balance u.a.).
- **Effektgrösse/Richtung:** Konsistent positiv über alle 137 eingeschlossenen Reviews; keine
  gepoolte Einzel-Effektgrösse angegeben (Umbrella-Review, keine klassische Meta-Analyse).
- **Evidenztyp & Tier:** Umbrella-Review/Position Stand (Synthese von 137 systematischen Reviews,
  30.000+ Teilnehmer) — **Tier 1**.
- **Quelle:** American College of Sports Medicine (ACSM) Position Stand, "Resistance Training
  Prescription for Muscle Function, Hypertrophy, and Physical Performance in Healthy Adults",
  *Medicine & Science in Sports & Exercise*, April 2026, DOI 10.1249/mss.0000000000003897.
- **Bias/Limitationen:** Originaltext nur über PresseZusammenfassungen zugänglich (Bezahlschranke),
  keine direkte Prüfung der Primärdaten möglich; Umbrella-Reviews erben die Schwächen der
  eingeschlossenen Reviews (u.a. Publikationsbias in der Trainingsforschung generell).
- **Praktische Relevanz für Atlas One:** Bestätigt indirekt die Grundannahme des gesamten
  Trainings-Scores (14% Gewicht am Tagesscore) — Krafttraining zu tracken und zu belohnen ist
  evidenzbasiert sinnvoll. Sagt aber auch: die Feinjustierung der App-Konstanten (40/25/20/15-Gewichtung,
  RIR-Kurve, 18-Sätze-Ziel) ist evidenzmässig zweitrangig gegenüber der reinen Tatsache "trainiert /
  trainiert nicht".
- **Grade:** B (starke Aussage, aber nur indirekt über PresseZusammenfassung statt Primärtext geprüft).

---

### RT-002
- **Claim:** Erwachsene sollten muskelkräftigende Übungen für alle grossen Muskelgruppen an
  mindestens 2 Tagen pro Woche bei moderater oder höherer Intensität durchführen.
- **Population/Kontext:** Gesunde Erwachsene, 18–64 Jahre.
- **Endpunkt:** Globale Gesundheitsempfehlung (Mortalität, Muskelkraft/-masse, metabolische
  Gesundheit als Sekundärendpunkte der zugrunde liegenden Evidenzbasis).
- **Effektgrösse/Richtung:** "Starke Empfehlung, mittlere Evidenzsicherheit" (GRADE-System der WHO).
- **Evidenztyp & Tier:** Offizielle WHO-Leitlinie, basierend auf systematischen Reviews und
  Experten-Konsens (36 internationale Experten) — **Tier 1**.
- **Quelle:** Bull FC et al., "World Health Organization 2020 guidelines on physical activity and
  sedentary behaviour", *British Journal of Sports Medicine*, 2020.
- **Bias/Limitationen:** Globale Leitlinie, bewusst niedrigschwellig formuliert für Public-Health-Zwecke
  — sagt nichts über optimale Sätze/Intensität für Hypertrophie- oder Kraftsport-Ziele aus, nur über
  ein gesundheitliches Minimum.
- **Praktische Relevanz für Atlas One:** Deckt sich mit ACSM 2026 ("mindestens 2×/Woche pro
  Muskelgruppe"). Betrifft aber die **Trainingsfrequenz pro Muskelgruppe**, nicht die
  **Ruhetage-Logik der App** (2 freie Rest-Days/Kalenderwoche, `REST_FREE=2`, `index.html:1640`) — das
  sind zwei verschiedene Variablen, die die App-Doku selbst vermischt (s. Widersprüche unten). Die
  WHO-Empfehlung sagt nichts darüber aus, wie viele volle Ruhetage optimal sind.
- **Grade:** A (offizielle WHO-Leitlinie, hohe Konsensstärke).

---

### RT-003
- **Claim:** Progressives Krafttraining (Progressive Resistance Training, PRT) verbessert Muskelkraft
  bei älteren Erwachsenen mit moderatem bis grossem Effekt und verbessert auch einfache
  Alltagsfunktionen (Gehen, Treppensteigen, Aufstehen).
- **Population/Kontext:** Ältere Erwachsene (Cochrane-Review, 121 RCTs, 6.700 Teilnehmer).
- **Endpunkt:** Muskelkraft (1RM oder vergleichbar), funktionelle Tests (Gehgeschwindigkeit,
  Chair-Stand, Treppensteigen).
- **Effektgrösse/Richtung:** SMD = 0,84 (95%-CI 0,67–1,00) für Kraftzuwachs — moderater bis grosser
  Effekt.
- **Evidenztyp & Tier:** Cochrane Systematic Review/Meta-Analyse (CD002759, Liu & Latham) —
  **Tier 1**.
- **Quelle:** Liu CJ, Latham NK, "Progressive resistance strength training for improving physical
  function in older adults", *Cochrane Database of Systematic Reviews*, 2009 (mit späteren Updates).
- **Bias/Limitationen:** Fokus auf ältere Erwachsene, nicht direkt auf Hypertrophie-/Kraftsportziele
  jüngerer, trainierter Personen übertragbar; "unzureichende Evidenz zu Langzeitrisiken" laut Review
  selbst.
- **Praktische Relevanz für Atlas One:** Direkte Bestätigung des Kernprinzips hinter der
  **Progression-Komponente (40% Gewicht im Trainings-Score, `progScore`, `index.html:1656-1665`)** —
  progressive Belastungssteigerung wirkt robust. Sagt aber nichts über die konkrete
  e1RM-Vergleichslogik der App aus (Top-Satz vs. letzte Session).
- **Grade:** A.

---

### RT-004
- **Claim:** Es besteht ein dosisabhängiger (dose-response) Zusammenhang zwischen wöchentlichem
  Trainingsvolumen (Sätze pro Muskelgruppe) und Hypertrophie — mehr Sätze pro Woche führen tendenziell
  zu mehr Muskelwachstum, mit dem stärksten Effekt im Bereich 5–10+ Sätzen/Muskel/Woche.
- **Population/Kontext:** Gemischte Studienpopulationen (überwiegend junge, trainierte oder
  untrainierte Männer), 15 Studien / 34 Behandlungsgruppen.
- **Endpunkt:** Muskelquerschnitt/-hypertrophie (Ultraschall/MRT-Messungen).
- **Effektgrösse/Richtung:** +0,023 Effektgrössen-Einheiten pro zusätzlichem wöchentlichem Satz
  (~0,37% Hypertrophie-Zuwachs/Satz); Differenz hoch- vs. niedrig-Volumen-Gruppen: ES 0,241 (~3,9%
  Unterschied).
- **Evidenztyp & Tier:** Systematic Review + Meta-Analyse — **Tier 1**.
- **Quelle:** Schoenfeld BJ, Ogborn D, Krieger JW, "Dose-response relationship between weekly
  resistance training volume and increases in muscle mass: A systematic review and meta-analysis",
  *Journal of Sports Sciences*, 2017.
- **Bias/Limitationen:** Kleine Studienzahl (15), meist junge/männliche Stichproben, Ergebnis wurde
  seither methodisch kritisiert (siehe RT-014/Widersprüche — Buckner et al. 2023: Effektgrössen
  teils grösser als in Einzelstudien plausibel).
- **Praktische Relevanz für Atlas One:** Stützt grundsätzlich die **Volumen-Komponente (20% Gewicht,
  `volScore`, `index.html:1667`)** und das **18-Sätze/Tag-Ziel (`TRAIN_SETS_TARGET=18`)**. Aber: die
  Studie misst Sätze **pro Muskelgruppe pro Woche**, die App aber Gesamtvolumen (kg) **pro Tag** vs.
  einer persönlichen Baseline — das ist ein methodisch anderer Ansatz, der nicht direkt aus dieser
  Quelle validiert ist (siehe Widersprüche).
- **Grade:** B (solide, aber ältere/kleinere Meta-Analyse mit seither publizierter Kritik).

---

### RT-005
- **Claim:** Sowohl für Hypertrophie als auch für Kraft gibt es abnehmende Grenzerträge (diminishing
  returns) bei steigendem Trainingsvolumen — bei Kraft ist dieser Abflachungseffekt deutlich stärker
  ausgeprägt als bei Hypertrophie. Für Hypertrophie zeigt sich kein klares Plateau, für Kraft schon.
- **Population/Kontext:** 67 Studien, 2.058 Teilnehmer (79% männlich, Ø-Alter 25 Jahre) — überwiegend
  junge, meist untrainierte bis moderat trainierte Erwachsene.
- **Endpunkt:** Muskelhypertrophie und Maximalkraft.
- **Effektgrösse/Richtung:** Minimal wirksame Dosis bereits bei niedrigem Volumen (~4 "fraktionale"
  Sätze/Woche) erreichbar; das Volumen für den letzten Zuwachs-Schritt ist >3× so hoch wie für den
  ersten (minimal wirksamen) Schritt.
- **Evidenztyp & Tier:** Meta-Regression über 67 Studien — **Tier 1**.
- **Quelle:** Pelland JC, Remmert JF, Robinson ZP, Hinson SR, Zourdos MC, "The Resistance Training
  Dose Response: Meta-Regressions Exploring the Effects of Weekly Volume and Frequency on Muscle
  Hypertrophy and Strength Gains", *Sports Medicine*, 2025/2026.
- **Bias/Limitationen:** Überwiegend junge, männliche, wenig bis moderat trainierte Stichproben —
  Übertragbarkeit auf fortgeschrittene Athleten oder ältere Erwachsene unklar. Neue, noch nicht breit
  extern replizierte Klassifikationsmethode (direkte vs. indirekte Sätze).
- **Praktische Relevanz für Atlas One:** Wichtige Verfeinerung/Einschränkung zu RT-004: das starre
  **18-Sätze/Tag-Ziel** der App unterscheidet nicht zwischen "Minimal-Dosis erreicht" und "weiterer
  Grenzertrag" — ein Nutzer bei 10 Sätzen bekommt einen linear niedrigeren `setScore` als bei 18, obwohl
  die Evidenz nahelegt, dass der Grenznutzen ab einem gewissen Punkt stark abflacht, besonders für reine
  Kraftziele. Eine nichtlineare (statt linearer) `setScore`-Kurve wäre evidenznäher.
- **Grade:** B (aktuelle, methodisch anspruchsvolle Studie, aber neu und noch nicht breit repliziert).

---

### RT-006
- **Claim:** Bei gleichem Gesamtvolumen (volumen-äquivalent) hat die Trainingsfrequenz pro
  Muskelgruppe keinen signifikanten zusätzlichen Effekt auf Hypertrophie.
- **Population/Kontext:** 25 Studien, gemischte Trainingsstatus-Populationen.
- **Endpunkt:** Muskelhypertrophie.
- **Effektgrösse/Richtung:** Kein signifikanter Unterschied zwischen Frequenzgruppen bei
  Volumen-Konstanthaltung; praktische Empfehlung: mindestens 2×/Woche pro Muskelgruppe.
- **Evidenztyp & Tier:** Systematic Review + Meta-Analyse — **Tier 1**.
- **Quelle:** Schoenfeld BJ, Grgic J, Krieger J, "How many times per week should a muscle be trained to
  maximize muscle hypertrophy? A systematic review and meta-analysis...", *Journal of Sports Sciences*,
  2019.
- **Bias/Limitationen:** "Volumen-äquivalent" ist in der Praxis schwer sauber zu isolieren
  (Ermüdungsmanagement pro Session unterscheidet sich); wenige Studien mit >3×/Woche-Frequenz.
- **Praktische Relevanz für Atlas One:** Relevant für die **kaputte Rest-Day-Logik** der App (siehe
  `app-logic.md` Mismatch #2): Wenn Frequenz bei gleichem Volumen kaum zählt, ist ein hartes
  "2-freie-Ruhetage-pro-Woche"-Konzept ohnehin fragwürdig priorisiert — die Literatur adressiert
  ohnehin eine andere Variable (Trainingsfrequenz pro Muskelgruppe, nicht Ruhetage insgesamt).
- **Grade:** B.

---

### RT-007
- **Claim:** Bei gleichem Gesamtvolumen hat Trainingsfrequenz ebenfalls keinen signifikanten
  zusätzlichen Effekt auf Kraftzuwachs; ohne Volumen-Kontrolle steigen die rohen Effektgrössen aber
  mit der Frequenz (0,74/0,82/0,93/1,08 für 1/2/3/4+×/Woche).
- **Population/Kontext:** Gemischte Studienpopulationen, Subgruppenanalyse volumen-äquivalenter
  Studien.
- **Endpunkt:** Maximalkraft (1RM).
- **Effektgrösse/Richtung:** Volumen-äquivalente Subgruppe: nicht signifikant (p=0,421). Ohne
  Volumen-Kontrolle: signifikanter Trend (p=0,003), aber konfundiert mit höherem Gesamtvolumen bei
  höherer Frequenz.
- **Evidenztyp & Tier:** Systematic Review + Meta-Analyse — **Tier 1**.
- **Quelle:** Grgic J, Lazinica B, Mikulic P, Krieger JW, Schoenfeld BJ, "Effect of Resistance
  Training Frequency on Gains in Muscular Strength: A Systematic Review and Meta-Analysis", *Sports
  Medicine*, 2018.
- **Bias/Limitationen:** Effekt für Mehrgelenkübungen stärker als für Eingelenkübungen (u.a.
  Test-Übungs-Vertrautheit als Störfaktor) — Frequenzeffekt könnte teils ein Test-Praxis-Artefakt sein.
- **Praktische Relevanz für Atlas One:** Bestätigt RT-006 für Kraft: der entscheidende Hebel ist
  Volumen, nicht Frequenz/Ruhetage per se — spricht gegen die Priorität, die die App-Dokumentation
  (aber nicht der tatsächliche Code) der Ruhetage-Regel einräumt.
- **Grade:** B.

---

### RT-008
- **Claim:** Training bis zum Muskelversagen (momentary failure) bringt gegenüber Training mit
  Trainingsreserve für Hypertrophie nur einen trivialen, statistisch nicht robusten Vorteil.
- **Population/Kontext:** 15 Studien; nur 2 von 9 Studien in den Kernvergleichen mit trainierten
  Probanden, Rest untrainiert; Alter ca. 20–65 Jahre, gemischtes Geschlecht.
- **Endpunkt:** Muskelhypertrophie (direkte Messung).
- **Effektgrösse/Richtung:** Versagen vs. Nicht-Versagen: ES 0,12 (95%-CI −0,13 bis 0,37), p=0,343,
  nicht signifikant. Satz-Versagen (beliebige Definition) vs. Nicht-Versagen: ES 0,19 (95%-CI 0,00–0,37),
  p=0,045 — nur knapp signifikant, "trivialer" Effekt.
- **Evidenztyp & Tier:** Systematic Review + Meta-Analyse — **Tier 1**.
- **Quelle:** Refalo MC, Helms ER, Trexler ET, Hamilton DL, Fyfe JJ, "Influence of Resistance
  Training Proximity-to-Failure on Skeletal Muscle Hypertrophy: A Systematic Review with
  Meta-analysis", *Sports Medicine*, 2022.
- **Bias/Limitationen:** Keine einheitliche Definition von "Versagen" in der Literatur; Autoren
  nutzten eine angenommene Prä-Post-Korrelation (r=0,75) mangels Rohdaten — Sensitivitätsanalysen
  zeigen, dass der Effekt unter r=0,73 nicht mehr signifikant wäre; Aussagekraft für trainierte
  Athleten gering (nur 2 Studien).
- **Praktische Relevanz für Atlas One:** Direkt relevant für die **RIR-Kurve der Intensitäts-Komponente
  (25% Gewicht, `_rirScore`, `index.html:1648`)**: Das App-Optimum liegt bei 0,5–2,5 RIR (nahe, aber
  nicht bei 0 RIR) und bestraft ab 2,5 RIR steil (−22 Punkte/RIR). Diese Quelle stützt die
  Grundannahme, dass 0 RIR (echtes Muskelversagen) NICHT nötig ist — sie sagt aber nichts darüber aus,
  ob 0,5–2,5 RIR gegenüber z.B. 3–4 RIR wirklich so scharf abfallen sollte, wie es die App-Formel tut.
- **Grade:** B (solide Meta-Analyse, aber mit expliziten Autor-eigenen Einschränkungen zur statistischen
  Robustheit).

---

### RT-009
- **Claim:** Training bis zum absoluten Muskelversagen ist für allgemeine Kraft-/Hypertrophie-Ziele
  nicht notwendig — ein Abbruch bei ca. 2–3 Wiederholungen in Reserve (RIR) erzielt vergleichbare
  Ergebnisse.
- **Population/Kontext:** Gesunde Erwachsene (ACSM-2026-Umbrella-Review, allgemeine Population).
- **Endpunkt:** Kraft- und Hypertrophie-Outcomes allgemein (keine Einzel-Effektgrösse angegeben).
- **Effektgrösse/Richtung:** Qualitative Konsens-Aussage, keine gepoolte Zahl.
- **Evidenztyp & Tier:** Umbrella-Review/Position Stand — **Tier 1**.
- **Quelle:** ACSM Position Stand, "Resistance Training Prescription for Muscle Function,
  Hypertrophy, and Physical Performance in Healthy Adults", *Medicine & Science in Sports & Exercise*,
  April 2026.
- **Bias/Limitationen:** Wie RT-001 — nur über Presseberichte geprüft, Originaltext hinter
  Bezahlschranke nicht einsehbar; die Aussage "2–3 RIR reicht" ist eine Vereinfachung, die laut RT-010
  (Kassiano et al. 2026) für Hypertrophie so nicht ganz stimmt.
- **Praktische Relevanz für Atlas One:** Bemerkenswert nah an der App-Logik: das RIR-Optimum der App
  (0,5–2,5 RIR) liegt fast exakt im von ACSM 2026 genannten "ausreichend"-Bereich (2–3 RIR) — eine
  seltene direkte Bestätigung einer App-Konstante durch eine Tier-1-Quelle. Die scharfe Straf-Kurve
  jenseits 2,5 RIR (bis Floor 40) ist durch diese Quelle aber nicht explizit gestützt — ACSM sagt nur
  "2–3 RIR reicht", nicht "mehr RIR ist stark schädlich fürs Scoring".
- **Grade:** B (wichtige, aktuelle Quelle, aber nur sekundär geprüft, keine harte Zahl).

---

### RT-010
- **Claim:** In einer neueren Meta-Regression war ein niedrigerer RIR-Wert (näher am Versagen)
  signifikant mit **mehr** Hypertrophie assoziiert (negative Steigung, Konfidenzintervall schliesst
  Null aus) — für Kraftzuwachs zeigte sich dagegen kein bedeutsamer RIR-Zusammenhang.
- **Population/Kontext:** Meta-Regression über mehrere Studien zu progressiver Belastungssteigerung,
  adjustiert für Last, Volumen-Berechnungsmethode, Interventionsdauer und Trainingsstatus.
- **Endpunkt:** Muskelhypertrophie und Maximalkraft, in Beziehung zu geschätztem RIR.
- **Effektgrösse/Richtung:** Für Hypertrophie: negative marginale Steigung für geschätztes RIR in
  allen "best-fit"-Modellen, CI schliesst den Nullpunkt aus. Für Kraft: Steigungen für RIR
  durchgängig vernachlässigbar/nicht signifikant.
- **Evidenztyp & Tier:** Meta-Analyse/Meta-Regression, publiziert in *Medicine & Science in Sports &
  Exercise*, 2026 — nominell **Tier 1**, aber siehe Limitation unten.
- **Quelle:** Kassiano W et al. (Erstautor gemäss Sekundärquellen; vollständige Autorenliste nicht
  unabhängig verifiziert), "Progressive Overload Affects the Magnitude of Muscle Hypertrophy",
  *Medicine & Science in Sports & Exercise*, 2026.
- **Bias/Limitationen:** **Wichtiger Hinweis zur Quellenqualität:** Der PubMed-Abstract war beim
  Abruf durch ein CAPTCHA blockiert; alle Angaben stammen aus einer Sekundär-Aggregation
  (Suchmaschinen-Snippet), nicht aus direkt gelesenem Primärtext. Autorenliste und Details sollten vor
  Weiterverwendung gegen die Originalpublikation geprüft werden.
- **Praktische Relevanz für Atlas One:** Wichtigster **Widerspruch** im gesamten Register (siehe
  Abschnitt unten): steht in Spannung zu RT-009 (ACSM: "2–3 RIR reicht") und RT-008 (Refalo: Versagen
  bringt nur trivialen Zusatznutzen). Die App-Formel behandelt 0,5–2,5 RIR als **flaches Plateau**
  (85–100 Punkte, kein Unterschied zwischen 0,5 und 2,5 RIR) — dieser Befund legt nahe, dass selbst
  innerhalb dieses Bereichs "näher an 0" tendenziell noch etwas besser für Hypertrophie sein könnte,
  was für ein leicht abfallendes statt flaches Optimum sprechen würde.
- **Grade:** C (inhaltlich interessant und aktuell, aber wegen ungeprüfter Primärquelle nicht höher
  gradierbar, bis der Volltext eingesehen werden kann).

---

### RT-011
- **Claim:** Sowohl reine Lastprogression (mehr Gewicht, gleiche Wiederholungszahl) als auch reine
  Wiederholungsprogression (mehr Wiederholungen, gleiche Last) sind über 8 Wochen wirksame Strategien
  für Kraft- und Muskelzuwachs bei trainierten Personen; Lastprogression war für Maximalkraft leicht
  überlegen, für Muskelausdauer gleichwertig.
- **Population/Kontext:** 43 Personen mit ≥1 Jahr konsistenter Unterkörper-Krafttrainingserfahrung.
- **Endpunkt:** Unterkörper-Hypertrophie, Maximalkraft, Muskelausdauer.
- **Effektgrösse/Richtung:** Beide Gruppen verbesserten sich; Lastprogression signifikant stärker nur
  bei Maximalkraft, sonst keine Gruppenunterschiede.
- **Evidenztyp & Tier:** Einzelnes randomisiert-kontrolliertes Experiment (kein Review/keine
  Meta-Analyse) — **Tier 2** (methodisch sauber, aber Einzelstudie, kleine Stichprobe).
- **Quelle:** Plotkin DL et al., "Progressive overload without progressing load? The effects of load
  or repetition progression on muscular adaptations", *PeerJ*, 2022.
- **Bias/Limitationen:** Kleine Stichprobe (n=43), nur 8 Wochen, nur Unterkörper, nur trainierte
  Personen — Übertragbarkeit auf Anfänger oder Langzeit-Verläufe unklar.
- **Praktische Relevanz für Atlas One:** Direkt relevant für die **Progression-Komponente**
  (`_exProgress`, `index.html:1656-1665`), die primär e1RM-Veränderung (also Lastprogression) misst
  und Volumenzuwachs nur als Bonus behandelt. Diese Quelle stützt, dass e1RM/Last ein sinnvoller
  Leitindikator ist, zeigt aber auch, dass eine **rein last-basierte Progressionsmetrik einen
  gleichwertigen Fortschrittspfad (Wiederholungs-Progression) leicht unterbewerten könnte**, wenn er
  nicht ebenfalls über e1RM-Schätzung erfasst wird (was `_exProgress` laut Doku aber tut, sofern
  Wiederholungen mit eingerechnet werden).
- **Grade:** B (gute interne Validität, aber Einzelstudie, kleine Stichprobe → nicht A).

---

### RT-012
- **Claim:** Ältere Erwachsene (65+) sollten funktionelles Balance- und Krafttraining bei moderater
  oder höherer Intensität an mindestens 3 Tagen pro Woche durchführen (mehr als die
  2-Tage-Empfehlung für jüngere Erwachsene), zur Sturzprävention und Erhalt der Funktionsfähigkeit.
- **Population/Kontext:** Erwachsene ≥65 Jahre.
- **Endpunkt:** Funktionelle Kapazität, Sturzrisiko.
- **Effektgrösse/Richtung:** "Starke Empfehlung, hohe Evidenzsicherheit" (höchste GRADE-Einstufung
  im gesamten WHO-2020-Dokument).
- **Evidenztyp & Tier:** Offizielle WHO-Leitlinie — **Tier 1**.
- **Quelle:** Bull FC et al., "World Health Organization 2020 guidelines on physical activity and
  sedentary behaviour", *British Journal of Sports Medicine*, 2020; ergänzend NIA (National
  Institute on Aging/NIH), "Exercise and Physical Activity for Older Adults" (fortlaufend
  aktualisierte Verbraucherressource, empfiehlt ebenfalls ≥2 Tage/Woche Muskelkräftigung als Teil von
  drei Bewegungsarten).
- **Bias/Limitationen:** Globale Konsens-Leitlinie, nicht spezifisch für Hypertrophie-/Leistungsziele;
  NIA-Ressource ist eine Verbraucher-Zusammenfassung, kein Primärforschungsdokument.
- **Praktische Relevanz für Atlas One:** Die App personalisiert das 18-Sätze/Tag-Ziel und die
  Ruhetage-Logik **nicht nach Alter**. Diese Quelle legt nahe, dass ältere Nutzer tendenziell eine
  **höhere**, nicht niedrigere Mindestfrequenz brauchen (Sturzprävention/Funktionserhalt) — ein für
  Atlas One bislang nicht abgebildeter Personalisierungsfaktor.
- **Grade:** A.

---

### RT-013
- **Claim:** Das 2009er ACSM-Positionspapier empfahl für Kraftausdauer/Hypertrophie-Zonen (6–12RM)
  Satzpausen von 1–2 Minuten und für schwere Lasten (1–6RM, Kraft-/Poweraufbau) 3–5 Minuten Pause
  zwischen Sätzen; Trainingsintensität sollte für Fortgeschrittene periodisiert zwischen 1–12RM
  variieren mit Schwerpunkt auf 1–6RM.
- **Population/Kontext:** Gesunde erwachsene Trainierende, gestaffelt nach Trainingserfahrung
  (Anfänger 8–12RM; Fortgeschrittene 1–12RM periodisiert).
- **Endpunkt:** Programmgestaltungs-Empfehlung (kein einzelner Studienoutcome, sondern
  Experten-Konsens auf Basis der damaligen Literatur).
- **Effektgrösse/Richtung:** Nicht anwendbar (Empfehlung, keine gepoolte Effektgrösse).
- **Evidenztyp & Tier:** ACSM Position Stand (2009) — **Tier 1**, aber historisch: teilweise durch
  ACSM 2026 (RT-001/RT-009) relativiert ("Equipment-/RM-Zonen-Feinsteuerung weniger wichtig als
  Konsistenz").
- **Quelle:** American College of Sports Medicine Position Stand, "Progression Models in Resistance
  Training for Healthy Adults", *Medicine and Science in Sports and Exercise*, 41(3):687-708, 2009.
- **Bias/Limitationen:** 17 Jahre alt, mittlerweile durch ACSM 2026 als "erstes grosses Update seit
  2009" explizit weiterentwickelt — als alleinstehende, unaktualisierte Quelle mit Vorsicht zu
  verwenden.
- **Praktische Relevanz für Atlas One:** Die App trackt keine **Satzpausen-Länge** überhaupt (weder im
  Trainings-Score noch sonstwo laut `app-logic.md`) — eine Lücke, die diese Quelle aufzeigt: Pausenlänge
  ist eine evidenzbasierte, aber in Atlas One komplett ungenutzte Stellschraube.
- **Grade:** B (historisch fundiert, aber veraltet gegenüber RT-001/RT-009).

---

## Widersprüche / offene Fragen

**1. RIR-Optimum: flaches Plateau vs. kontinuierlicher Gradient.**
Die App behandelt 0,5–2,5 RIR als gleichwertiges Optimum (85–100 Punkte, kein interner Gradient) und
bestraft alles darüber steil. ACSM 2026 (RT-009) und Refalo et al. 2022 (RT-008) stützen die
Grundaussage "Versagen ist nicht nötig", was zur groben Formkurve passt. Kassiano et al. 2026 (RT-010)
deutet dagegen an, dass *innerhalb* des RIR-Bereichs ein kontinuierlicher (nicht plateauförmiger)
Zusammenhang zwischen RIR und Hypertrophie besteht — niedrigeres RIR wäre demnach tendenziell immer
noch leicht im Vorteil, selbst innerhalb von 0,5–2,5. Da RT-010 aber nur über eine nicht direkt
einsehbare Sekundärquelle geprüft werden konnte, ist dieser Widerspruch als "beobachtet, aber mit
Vorbehalt" zu behandeln — er rechtfertigt Beobachtung, aber noch keine Code-Änderung.

**2. Wie belastbar ist der Volumen-Dosis-Zusammenhang wirklich?**
Schoenfeld et al. 2017 (RT-004) — die meistzitierte Quelle für "mehr Sätze = mehr Wachstum" — wird von
Buckner, Moreno & Baxter (2023, *Trainology* 12(2)) methodisch kritisiert: Die in der zugrunde
liegenden Literatur berichteten Muskeldicke-Zuwächse (0,6–0,72 cm) seien deutlich grösser als in
vergleichbaren Studien sonst beobachtet (0,1–0,25 cm), mehrere Studien an bereits trainierten Personen
zeigten zudem ähnliches Wachstum bei niedrigerem wie höherem Volumen. Buckner et al. fordern
Replikation statt fester Sätze-Zielwerte. Das relativiert die evidenzbasierte Rechtfertigung für ein
starres 18-Sätze/Tag-Ziel in der App zusätzlich zu der in RT-005 (Pelland et al.) beschriebenen
Abflachung der Grenzerträge. **Einordnung:** Buckner et al. ist eine narrative Kritik (kein eigener
Review/keine Meta-Analyse) und daher nur Tier 2 — sie widerlegt RT-004 nicht, relativiert aber dessen
Sicherheit.

**3. Trainingsfrequenz/Ruhetage: Die App misst die falsche Variable — und implementiert selbst das
nicht.**
Die Frequenz-Literatur (RT-006, RT-007) untersucht, wie oft **eine einzelne Muskelgruppe pro Woche**
trainiert wird — nicht, wie viele volle Ruhetage ein Nutzer pro Woche einlegt. Für Atlas Ones
"2-freie-Ruhetage-pro-Kalenderwoche"-Konzept (`REST_FREE=2`) konnte **keine passende Tier-1/2-Quelle**
gefunden werden, die genau diese Variable (volle Trainingsfreie Tage/Woche als Scoring-Grösse)
untersucht — das ist eine ehrliche Lücke, kein Rechercheversehen. Hinzu kommt (bereits in
`app-logic.md` dokumentiert): Diese Regel existiert im tatsächlichen Scoring-Code ohnehin nicht
(`trainScore` gibt an Ruhetagen schlicht 0 zurück und `trainActive` schliesst den Tag ganz aus der
Tagesscore-Gewichtung aus) — sie ist nur als Anzeige-Text vorhanden. Die Recherche unterstreicht also:
selbst wenn man die Ruhetage-Logik reparieren wollte, gibt es aktuell keine belastbare externe
Evidenzquelle für den Schwellenwert "2 pro Woche" — dieser wäre ein reiner Design-Heuristik-Wert, kein
literaturbasierter.

---

## Quellenkarte — Krafttraining

**Organisationen/Institutionen:**
- **ACSM (American College of Sports Medicine)** — mit Abstand wichtigste Quelle für diese Domäne;
  sowohl das historische 2009er Positionspapier als auch das brandneue 2026er Update (April 2026,
  MSSE) sind die massgeblichen Referenzdokumente für Krafttraining-Programmgestaltung.
- **WHO** — globale Mindestempfehlungen (Frequenz-Schwellenwerte für Erwachsene/Ältere), gut für
  Populations-Segmentierung (18–64 vs. 65+), nicht für Feinabstimmung von Sätzen/RIR.
- **Cochrane** — v.a. stark für ältere Erwachsene/klinische Populationen (CD002759); für junge,
  gesunde Hypertrophie-/Kraftsport-Zielgruppen weniger einschlägige Cochrane-Reviews gefunden.
- **NIA/NIH** — gute Tier-1-Ergänzung speziell für die Altersgruppen-Personalisierung, die Atlas One
  aktuell fehlt.

**Wiederkehrende Autoren/Journale (PubMed/Sports-Science):**
- **Brad J. Schoenfeld** — mit Abstand produktivster Autor zu Volumen- und Frequenz-Dosis-Wirkung
  (Erstautor RT-004, Co-Autor RT-006, Co-Autor des ACSM-2026-Positionspapiers) — zentrale Figur, deren
  Arbeiten sowohl die Grundlage als auch einen Teil der Kritik in diesem Feld bilden.
- **Jozo Grgic** — führend bei Frequenz-Meta-Analysen (RT-007).
- **James W. Krieger** — Ko-Autor mehrerer Kernstudien, bekannt für methodische Meta-Analyse-Strenge.
- **Eric R. Helms, Milo Wolf, Martin C. Refalo** — "Proximity-to-failure"/RIR-Autorengruppe (RT-008).
- **Jared C. Pelland, Michael C. Zourdos** — aktuelle Dosis-Response-Meta-Regressions-Arbeit (RT-005),
  Teil der RTS(Reactive Training Systems)/RPE-Autonomietrainings-Forschungslinie.
- **Stuart M. Phillips** (McMaster University) — Chair des ACSM-2026-Updates, langjährig führende
  Stimme zur Muskelproteinsynthese/Trainingsphysiologie.
- **Samuel L. Buckner** — kritische Gegenstimme zur Volumen-Dosis-Literatur (Widerspruch 2 oben).
- **Journal *Sports Medicine*** — Publikationsort der meisten hier zitierten hochwertigen
  systematischen Reviews/Meta-Analysen (RT-007, RT-008, RT-005, teils RT-004-verwandte Arbeiten).
- **SportRxiv** — Preprint-Server, auf dem aktuelle Arbeiten (z.B. RT-005) vor Journal-Veröffentlichung
  kursieren; nützlich für Frühwarnung, aber noch nicht peer-reviewed im Preprint-Stadium.

---

## Anmerkung zur Methodik dieses Piloten

Alle Zahlen/Zitate stammen aus öffentlich zugänglichen Abstracts, PubMed/PMC-Volltexten oder
Presseberichten seriöser Fachmedien (ACSM.org, Newswise, 2minutemedicine.com) — es wurde keine Quelle
erfunden. Zwei Einschränkungen sind oben explizit vermerkt: (a) das ACSM-2026-Volltext-PDF war hinter
einer Bezahlschranke (Ovid, HTTP 402) nicht einsehbar, Zahlen stammen aus Presseberichten; (b) der
Kassiano-et-al.-2026-PubMed-Abstract war durch ein CAPTCHA blockiert und wurde nur über eine
Sekundärquelle geprüft (RT-010, deshalb auf Grade C herabgestuft statt A/B). Beide Fälle sind im
jeweiligen Claim als Limitation ausgewiesen, nicht stillschweigend übernommen.
