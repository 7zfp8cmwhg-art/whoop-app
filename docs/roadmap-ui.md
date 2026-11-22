# UI-Umbau (Wunsch vom 22.11.2026)

Regel: nach jedem Schritt prüfen (Selbsttest, Seiten-Durchlauf, Screenshot iPhone-Breite), Logik und Verknüpfungen im Code gegenlesen, dann committen.

## 1 · Navigation
- Unten: Atlas | Stack & Gesundheit | Heute (Mitte) | Essen | Strength.
- Einstellungen: Zahnrad oben rechts neben „‹ Heute ›“.
- Begrüßung: Guten Morgen (bis 12) / Tag (bis 18) / Abend. Vorhanden, wird beim Öffnen neu gesetzt.
- Stack und Gesundheit raus aus dem Coach, eigener Tab mit Unter-Tabs „Herz“, „Stack“, „Labor“.

## 2 · Einstellungen (STE, kurz, iPhone-Breite)
- Profil: Gewicht, Größe, Geburtstag, Aktivitätslevel. Dazu eine Empfehlung aus den Schritten der letzten 14 Tage.
- Körperfett: gemessen (Waage) oder Schätzung, sichtbar markiert.
- Ziel: Kalorienbedarf plus Ziel, wie bisher.
- Training: Gym-Varianten (GER, West, BRU …) aus dem Trainings-Tracker. Dieselbe Liste in beiden Orten: Ändern an einer Stelle ändert die andere. Vorlagen und Plan bleiben.
- Labor bleibt.
- Verlauf: neue Seite (Schritt 3).
- Verbindungen: Cloud-Sync oben, dann WHOOP-Band, WHOOP-Verlauf, Withings, Apple Health, Health Report. Ganz unten Developer-Test und „Atlas AI testen“.

## 3 · Verlauf neu
- Gruppen je Score: Schlaf, Erholung, Atlas Overall. Darunter jeweils die Werte, die einfließen. Klare Trennlinien.
- Jede Grafik passt zum Wert: Einheit, Achsen, Skala (z. B. 0–100 %, bpm, ms, h, kcal), Zielbereich, Zeitraum 7/30/90 Tage.

## 4 · Herzseite
- Quelle (sourcetms OpenVitals) erneut lesen. Aufbau und Fazit-Logik ableiten.
- Herz-Grafik sauber neu: klare Linien, ruhiger Schlag im echten Takt, kein Flackern.
- Verknüpfungen: Herz-Werte mit Stack (z. B. Blutdruck/Hämatokrit unter Testosteron) und Labor.

## 5 · Gegenprüfung
- Jede Änderung im Code gegenlesen: Verknüpfungen, Daten, Logik. Kritikpunkte verbessern.

## Stand 22.11.
- 1 Navigation: erledigt.
- 2 Einstellungen: erledigt (Aktivitaets-Empfehlung, Waagen-Koerperfett, Gym-Liste synchron, Verbindungen-Reihenfolge).
- 3 Verlauf: erledigt (6 Abschnitte, 26 Grafiken).
- 4 Herzseite: erledigt (3D-Drahtgitter-Herz, 4 Kacheln mit Normalwert, eine Tab-Reihe, Karte Herz & Stack).
- 5 Gegenpruefung: Selbsttest 295/295, alle Seiten und Tabs ohne Fehler, node --check, Screenshots iPhone-Breite.

# Runde 2 (Wunsch vom 22.11. abends)
Erledigt: Stack-Wochendosis nach Kalenderwochen (vorher 350 statt 150), Kontrollplan ausgeblendet, Archiv entfernt.
Offen, in dieser Reihenfolge:
1. Stress wie WHOOP (Hauptziel): recherchieren, was WHOOP misst (koerperlich + psychisch? Aktivitaet raus?), Skala, Farben, Darstellung. Dann Logik und Grafik danach.
2. Dashboard: alles, was das MG kann, inkl. Hauttemperatur (wie WHOOP).
3. Herzseite aussagekraeftig: Einschaetzungen statt nur Werte (Tagesfazit, SpO2-Aussage, Hauttemperatur + Krankheitserkennung, EKG-Ergebnis), Blutdruck eintragen direkt darunter + taegliche Erinnerung, "Herz & Stack" aufklappbar mit ALLEN Pflichtwerten aus den Guides.
4. Herz-Grafik runder und vollstaendig (Kreis und Punktmuster sauber im Bild).
5. Heute-Tab deutlich besser.
6. Labor-Seite: Blut-, Vitamin-, Methylierungswerte eingeben, Darstellung einheitlich (Impeccable).
7. Aerztlicher Report: Export in den Einstellungen.
Grenzen: EKG braucht Finger am Band (kein Automatik-EKG moeglich), Blutdruck liefert das Band nicht.
