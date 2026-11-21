# Herzseite: Zielbild

Vorbild: OpenVitals (sourcetms.com/notes/reaing-my-old-whoop).
Umsetzung in Atlas-Optik. Keine neue Bildsprache.

## Was das Vorbild zeigt

### Herz (Hauptseite)
- Dunkler Grund. Ein Herz, im Code gezeichnet, auf einem Punktraster.
- Das Herz schlägt im Takt, den das Band sendet.
- Um das Herz stehen Beschriftungen: Puls jetzt, HRV heute, niedrigster Puls, Ø Puls.
- Darunter ein Pulsstreifen (letzte Sekunden, live).
- Darunter der Pulsverlauf des Tages.
- Karte "Letzte Nacht": Schlafdauer, Einschlaf- und Aufwachzeit, Wachphasen, Ruhepuls.
  Beispiel: 5 h 30 min, 2:08–8:05, 3× wach, Ruhepuls 45.
- Seitenleiste bzw. Reiter: Herz, Heute, Archiv, Gerät.
- Rechte Spalte: heute gemessene Zeit, gespeicherte Datensätze.

### Heute
- Großer Puls jetzt.
- Min, Max und Ø des Tages.
- Rote Spur der letzten Werte.
- Nur Daten, die das Band heute gemessen hat.

### Archiv
- Alte Daten hinter einem Kalender.
- Alte Werte erscheinen nie als "heute".

### Tagesansicht
- Erholung: "Noch kein Wert". Zurückgehalten bis 3 eigene Nächte da sind (0 von 3).
- Tages-Strain: zurückgehalten, bis der Tag vorbei ist.
- Schlaf: Dauer und Leistung, als Schätzung markiert.
- Atemfrequenz.

### Stress
- 0 bis 3, nur in Ruhe und wach.
- Fehlen Daten, steht dort "Kann gerade nichts sagen".

### Gerät
- Akku von Band und Akkupack getrennt.
- Abdeckung: Anteil des Tages mit Puls (heute, gestern).
- Gespeicherte Datensätze, Firmware-Protokoll.

### Morgen-Ampel
- Grün, Gelb oder Rot aus Ruhepuls und HRV gegen den eigenen Normalwert.
- Warnung erst nach drei schlechten Nächten in Folge.

### Nicht im Vorbild
- Kein Blutdruck, kein EKG, kein Blut-O₂.
- Atlas zeigt Blutdruck (Manschette/Eintrag) und EKG (nur MG) trotzdem als datierte Kacheln.

## Grundsätze
- Jeder Wert trägt sein Datum.
- Kein Wert ist besser als ein geratener. Fehlt etwas, steht "–" oder ein kurzer Hinweis.
- Schätzungen sind als Schätzung markiert.
- Kein Medizinprodukt.

## Umsetzung in Atlas

### Reiter
- Herz · Heute · Archiv. Gerät bleibt auf der Band-Seite.

### Herz-Karte (Hero)
- Ein Panel. Oben links "Puls jetzt" mit Live-Status (Punkt grün = live).
- Mitte: anatomisch angedeutetes Herz als SVG.
  - Linienzeichnung mit feinen Konturen: Kammern, Vorhöfe, Aorta, Lungenarterie, Herzkranzgefäße.
  - Feines Punktraster dahinter, wie im Vorbild.
  - Keine Comic-Herzform.
- Das Herz schlägt im echten Takt des Live-Pulses.
  - Gibt es RR-Abstände, nimmt jeder Schlag den echten Abstand.
  - Systole: kurz und kräftig (etwa 35 % des Schlags). Diastole: ruhig.
  - Kein Live-Puls: Herz steht still, leicht gedimmt.
  - prefers-reduced-motion: kein Schlagen, nur der Wert.
- Vier Werte am Herz: Puls jetzt, HRV (datiert), Ruhepuls (datiert), Ø heute.
- Darunter der echte Live-Pulsstreifen (#vitStrip), letzte 60 s. Kein erfundenes EKG.
- Hinweiszeile: "Live vom Band" oder warum kein Live-Puls da ist.

### Darunter
- Morgen-Ampel (nur wenn Ruhepuls, HRV und Normalwert da sind).
- Warnung nach 3 schlechten Nächten.
- Herzfrequenz heute: Tageskurve, Schlaf blau hinterlegt, Min/Ø/Max wach, Schlaf-Ruhepuls, Abdeckung.
- Letzte Nacht (datiert).
- Kacheln: Blutdruck, EKG, Blut-O₂, Hauttemperatur (datiert, sonst "–").

### Heute
- Großer Puls jetzt, Live-Streifen, Tagesverlauf, Stress, Strain, Schritte.

### Archiv
- Monatskalender, Punkt in Erholungsfarbe, grau = nur Messwerte.

## Gestaltung
- Tokens der App: --panel, --line, --txt, --mut, --mut2, --red, --green, --amber, --blue, --rad.
- Klassen: .panel, .lab, .xs, .mut, .kpi, .chip.
- Hell und dunkel über die vorhandenen Variablen.
- Puls-Rot als einzige Akzentfarbe der Seite.
