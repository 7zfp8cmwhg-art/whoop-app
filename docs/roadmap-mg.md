# Roadmap Atlas × WHOOP 5.0 MG (Stand 21.11.2026)

Regel: Keine IPA, bevor jede Phase grün ist. Jede Phase hat ein Abnahmekriterium und einen Beleg.

## Phase 1 – Bestandsliste
Jede Funktion, jeder Messwert: Quelle (Band-Byte / Apple Health / manuell), Formel, Anzeigeort.
Abnahme: Liste in docs/atlas-funktionen.md, jeder Eintrag mit Code-Stelle.

## Phase 2 – Logik-Prüfung, doppelter Durchlauf
Durchlauf A: jede Formel gegen mindestens 2 Referenzen (WHOOP-Doku, NOOP, OpenVitals, wearable5.0, Studien).
Durchlauf B: Gegenprüfung der Gewichtungen und Verteilungen (Recovery, Strain, Schlaf, Atlas Overall, Basics).
Abnahme: Tabelle behalten / korrigiert / entfernt, mit Begründung und Quelle.

## Phase 3 – Coach-Wissen
Ist: "How not to die" eingearbeitet; testomangel.com eingearbeitet; "Gut aussehen auf Cycle" nur als Name; Bloodwork-Guide fehlt.
Abnahme: alle Guides als Regeln im Coach, Kontrollfragen richtig beantwortet.

## Phase 4 – Datenweg Band → Morgenwerte (Developer-Framework)
1. Lückenloses Protokoll im Swift-Code je Stufe: Verbinden, Abo, Verlauf-Start, Seiten, Datensätze, Bestätigung, Block gespeichert, JS-Übernahme, Tag abgeschlossen, Anzeige.
2. Hypothesen einzeln prüfen: Hintergrund-Wiederherstellung (willRestoreState setzt Abo und Abruf fort?), App vom Nutzer beendet, JS läuft im Hintergrund nicht, Übernahme beim Öffnen, Nacht-Abschluss vor Aufwachen, Abruf-Takt, Bestätigung/Trim, 2-Nächte-Rückholung.
3. Swift-Protokollcode als macOS-Testpaket mit Golden-Fixtures (wearable5.0, echter MG-Rahmen).
4. Replay: aufgezeichnete Rahmen durch Swift- und JS-Pfad, deterministisch.
5. Schleife: alle Tests → Fehler → Fix → alle Tests, bis grün.
Abnahme: simulierte Nacht ergibt um 07:00 alle Morgenwerte ohne Nutzeraktion; 2 vergangene Nächte werden geholt.
Grenze: Der echte Funkweg ist erst mit dem Band belegt (eine Nacht nach Phase 8).

## Phase 5 – Recherche aktueller Nachbauten (ohne Abo)
NOOP, OpenVitals/sourcetms, wearable5.0 und weitere, Stand 2025/26: Wie kommen Nachtwerte morgens an? Verbindung über Nacht oder Abruf beim Öffnen? Blutdruck, EKG, Schritte, Strain.
Abnahme: Vergleich pro Funktion mit Quelle; alte "geht nicht"-Quellen verworfen.

## Phase 6 – Herzseite neu
Seite vollständig lesen, Zielbild im Detail beschreiben, nachbauen in Atlas-Design (Tokens aus bestehender App).
Herz-Grafik neu: Schlag im echten Takt (RR), Systole/Diastole, ruhig, hochwertig.
Abnahme: Screenshots mobil, hell und dunkel; jeder Punkt des Zielbilds abgehakt.

## Phase 7 – Jede Funktion Ende-zu-Ende
Strain, Schritte, Schlaf, Erholung, HRV, Ruhepuls, Schlaf-Ruhepuls, SpO2, Haut, Atmung, EKG, Blutdruck, Training, Stack.
Abnahme: Selbsttest und E2E grün, jede Anzeige mit Wert.

## Phase 8 – Freigabe
Checkliste komplett grün → IPA bauen → eine echte Nacht → Diagnose prüfen.
