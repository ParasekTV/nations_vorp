# 👑 Bürgermeister & Gouverneur Anleitung v2.2

## 🔧 Wichtige Fixes in dieser Version:

- ✅ **Bürgermeister-Kontrollen funktionieren jetzt!**
- ✅ **Gouverneur-System hinzugefügt!**
- ✅ **Namen werden korrekt angezeigt**
- ✅ **Debug-Logs für bessere Fehlersuche**

---

## 👨‍💼 BÜRGERMEISTER SYSTEM

### 1. **Jemanden zum Bürgermeister ernennen**

Als Admin im Spiel:
```
/setmayor <player_id> <stadtname>
```

**Beispiele:**
```
/setmayor 1 Valentine
/setmayor 5 Saint Denis
/setmayor 12 Blackwater
```

**Wichtig:** Der Stadtname muss EXAKT so geschrieben werden wie in der Config!

### 2. **Als Bürgermeister die Stadt verwalten**

1. Gehe zum Rathaus deiner Stadt (Blip auf der Karte)
2. Drücke **G** wenn du in der Nähe bist
3. Das Menü öffnet sich
4. Scrolle nach unten bis zu **"🏛️ Bürgermeister Kontrolle"**
5. Jetzt siehst du alle Verwaltungsoptionen!

### 3. **Bürgermeister Funktionen:**

#### 💰 **Steuerverwaltung**
- **Banksteuer (0-100%)**: Prozentsatz der bei Banktransaktionen abgezogen wird
- **Stadtsteuer ($)**: Betrag den jeder Bürger automatisch zahlt
- **Eintrittsgeld ($)**: Einmaliger Betrag zum Beitritt

#### 🎁 **Belohnungen**
- **Geldbelohnung ($)**: Tägliches Geld für jeden Bürger
- **XP Belohnung**: Tägliche XP für jeden Bürger

*Die Belohnungen werden von der Stadtbank abgezogen!*

#### 👥 **Stadt Einstellungen**
- **Max. Bevölkerung**: Wie viele Bürger maximal beitreten können

#### 💵 **Stadtbankverwaltung**
- **Einzahlen**: Dein eigenes Geld zur Stadtbank hinzufügen
- **Abheben**: Geld von der Stadtbank nehmen

*Gut für: Stadt am Anfang finanzieren, Belohnungen sicherstellen*

#### 📢 **Nachricht des Tages (MOTD)**
- Schreibe eine Nachricht die alle Bürger sehen
- Ideal für: Ankündigungen, Events, Regeln

---

## 👑 GOUVERNEUR SYSTEM

### 1. **Jemanden zum Gouverneur ernennen**

Als Admin im Spiel:
```
/setgovernor <player_id> <nation>
```

**Beispiele:**
```
/setgovernor 1 New Hanover
/setgovernor 5 West Elizabeth
/setgovernor 12 Lemoyne
```

**Wichtig:** Der Nationsname muss EXAKT so geschrieben werden wie in der Config!

### 2. **Als Gouverneur die Nation verwalten**

1. Gehe zu IRGENDEINEM Rathaus einer Stadt in deiner Nation
2. Drücke **G**
3. Das Menü öffnet sich
4. Scrolle nach unten bis zu **"👑 Gouverneur Kontrolle"**
5. Jetzt siehst du alle Verwaltungsoptionen!

### 3. **Gouverneur Funktionen:**

#### 💰 **Nationssteuern**
- **Nationssteuer (0-100%)**: Prozentsatz der von allen Städten in der Nation eingezogen wird
- Diese Steuer wird automatisch von den Stadtbanken abgezogen
- Geht direkt in die Nationsbank

#### 💵 **Nationsbankverwaltung**
- **Einzahlen**: Dein eigenes Geld zur Nationsbank hinzufügen
- **Abheben**: Geld von der Nationsbank nehmen

*Die Nationsbank sammelt Steuern von allen Städten!*

#### 📊 **Überblick**
- Siehe alle Städte in deiner Nation
- Überblicke die gesamte Wirtschaft
- Verwalte das große Ganze

---

## 🎯 PRAKTISCHE BEISPIELE

### Beispiel 1: Stadt gründen und Wirtschaft starten

**Schritt 1:** Admin ernennt dich zum Bürgermeister
```
/setmayor 5 Valentine
```

**Schritt 2:** Du gehst zum Rathaus in Valentine

**Schritt 3:** Du öffnest das Menü (G) und siehst "🏛️ Bürgermeister Kontrolle"

**Schritt 4:** Du konfigurierst:
- Eintrittsgeld: $100 (Startkapital)
- Stadtsteuer: $50 (pro Interval)
- Tägliche Belohnung: $25 (attraktiv für Bürger)

**Schritt 5:** Du zahlst $5000 in die Stadtbank ein (für Belohnungen)

**Schritt 6:** Du setzt eine MOTD: "Willkommen in Valentine! Beste Stadt im Westen!"

**Schritt 7:** Spieler treten bei und die Stadt wächst!

### Beispiel 2: Nation verwalten

**Schritt 1:** Admin ernennt dich zum Gouverneur
```
/setgovernor 3 New Hanover
```

**Schritt 2:** Du gehst zu Valentine (oder einer anderen Stadt in New Hanover)

**Schritt 3:** Du öffnest das Menü und siehst "👑 Gouverneur Kontrolle"

**Schritt 4:** Du setzt die Nationssteuer auf 10%

**Schritt 5:** Die Städte Valentine, Strawberry etc. zahlen automatisch 10% ihrer Einnahmen an die Nation

**Schritt 6:** Du nutzt das Geld für große Projekte oder verteilst es an bedürftige Städte

---

## 🐛 PROBLEMLÖSUNG

### Problem: "Ich sehe die Bürgermeister-Kontrollen nicht!"

**Lösung 1:** Prüfe ob du wirklich Bürgermeister bist
- Der Admin muss `/setmayor <deine_id> <stadt>` eingeben
- Die Stadt muss EXAKT so geschrieben sein wie in der Config

**Lösung 2:** Prüfe die F8 Konsole
- Drücke F8 im Spiel
- Suche nach "Is Mayor: true" oder "Is Mayor: false"
- Wenn "false", bist du nicht als Mayor eingetragen

**Lösung 3:** Server neu laden
```
/restart infinity_nations_vorp
```

**Lösung 4:** Prüfe die Datenbank
- Öffne die `infinity_towns` Tabelle
- Finde deine Stadt
- Prüfe ob die `mayor_id` deinem `charidentifier` entspricht

### Problem: "Gouverneur-Kontrollen werden nicht angezeigt!"

**Lösung:** Gleiche Schritte wie bei Bürgermeister
- Prüfe mit `/setgovernor`
- Prüfe F8 Konsole: "Is Governor: true"
- Prüfe Datenbank Tabelle `infinity_nations`

### Problem: "Änderungen werden nicht gespeichert!"

**Lösung:**
1. Prüfe Server-Logs auf MySQL Fehler
2. Stelle sicher oxmysql läuft: `ensure oxmysql`
3. Prüfe ob die Tabellen existieren
4. Restart des Scripts: `/restart infinity_nations_vorp`

---

## 💡 TIPPS & TRICKS

### Für Bürgermeister:

1. **Halte die Stadtbank gefüllt**
   - Belohnungen kosten Geld!
   - Berechnung: Belohnung × Anzahl Bürger = Tägliche Kosten

2. **Balance zwischen Steuern und Belohnungen**
   - Hohe Steuern = Weniger Bürger
   - Hohe Belohnungen = Mehr Bürger (aber höhere Kosten)

3. **Nutze die MOTD**
   - Kommuniziere mit deinen Bürgern
   - Kündige Events an
   - Teile wichtige Informationen

4. **Wachstumsstrategie**
   - Anfangs: Niedriges Eintrittsgeld, hohe Belohnungen
   - Später: Erhöhe Steuern wenn die Stadt stabil ist

### Für Gouverneure:

1. **Verteile Geld weise**
   - Unterstütze neue Städte
   - Belohne erfolgreiche Bürgermeister
   - Finanziere große Projekte

2. **Kommuniziere mit Bürgermeistern**
   - Koordiniere die Wirtschaft
   - Plane gemeinsame Events
   - Verhindere Konkurrenz zwischen Städten

3. **Langfristig denken**
   - Baue Reserven auf
   - Plane für schlechte Zeiten
   - Investiere in Wachstum

---

## 📊 WIRTSCHAFTS-DASHBOARD

### Stadt-Finanzen verstehen:

**Einnahmen:**
- Eintrittsgeld (einmalig pro Bürger)
- Stadtsteuer (regelmäßig von Bürgern)
- Banksteuer (bei Transaktionen)
- Einzahlungen vom Bürgermeister

**Ausgaben:**
- Tägliche Belohnungen an Bürger
- Nationssteuern (geht an Gouverneur)

**Gewinn = Einnahmen - Ausgaben**

### Nations-Finanzen verstehen:

**Einnahmen:**
- Nationssteuern von allen Städten
- Einzahlungen vom Gouverneur

**Ausgaben:**
- Abhebungen vom Gouverneur
- (Optional: Projekte, die du programmierst)

---

## 🔄 UPDATE INSTALLATION

### Vollständige Neuinstallation (empfohlen):

1. **Stoppe den Server**

2. **Lösche den alten Ordner**
   ```
   resources/infinity_nations_vorp/
   ```

3. **Lade den neuen Ordner hoch**

4. **KEINE SQL ÄNDERUNGEN NÖTIG!**
   - Die Datenbank bleibt gleich
   - Alle Daten bleiben erhalten

5. **Starte den Server**

### Schnelle Update-Methode:

Ersetze nur diese Dateien:
- `server/server.lua` ← **WICHTIG!**
- `client/client.lua` ← **WICHTIG!**
- `html/index.html`
- `html/style.css`
- `html/script.js`

---

## 📞 SUPPORT & DEBUG

### Debug-Logs aktiviert:

Diese Version enthält Debug-Logs. Wenn etwas nicht funktioniert:

**Im Spiel (F8):**
```
Is Mayor: true/false
Is Governor: true/false
```

**In Server-Logs:**
```
[Infinity Nations] Spieler XYZ ist Bürgermeister von Valentine
[Infinity Nations] Spieler ABC ist Gouverneur von New Hanover
```

### Häufige Fehlerquellen:

1. ❌ **Stadtname falsch geschrieben**
   - Muss EXAKT wie in Config sein
   - Groß-/Kleinschreibung beachten!

2. ❌ **CharIdentifier stimmt nicht**
   - VORP nutzt `charidentifier` nicht `identifier`
   - Prüfe in der Datenbank!

3. ❌ **Script-Reihenfolge falsch**
   - vorp_core MUSS vor infinity_nations laden
   - oxmysql MUSS vor infinity_nations laden

4. ❌ **Alte Cache-Daten**
   - Lösche FiveM Cache
   - Server neu starten

---

**Viel Erfolg als Bürgermeister und Gouverneur! 🤠👑**

Bei Problemen: Prüfe zuerst die Debug-Logs in F8 und den Server-Logs!
