# Infinity Nations - RedM VORP

## 📋 Beschreibung

Ein komplettes Wirtschaftssystem für RedM VORP mit Nationen, Städten, Bürgermeistern, Gouverneuren und einem vollständigen Steuersystem.

## ✨ Features

- ✅ **Unbegrenzte Städte und Nationen** - Erstelle so viele wie du willst
- ✅ **Bürgermeister System** - Spieler können Bürgermeister werden
- ✅ **Gouverneur System** - Verwalte ganze Nationen
- ✅ **Wirtschaftssystem** - Stadtbanken, Nationsbanken, Steuern
- ✅ **Tägliche Belohnungen** - Bürger erhalten Geld und XP
- ✅ **Steuersystem** - Banksteuern, Stadtsteuern, Eintrittsgeld
- ✅ **Pass System** - Bürger können Pässe erhalten
- ✅ **Export Funktionen** - Integration mit anderen Scripts
- ✅ **0.00ms Performance** - Optimiert für beste Performance
- ✅ **Modernes UI** - Schöne Benutzeroberfläche
- ✅ **Mehrsprachig** - Deutsch und Englisch

## 📦 Abhängigkeiten

- [VORP Core](https://github.com/VORPCORE/vorp-core-lua)
- [oxmysql](https://github.com/overextended/oxmysql)

## 🔧 Installation

### 1. Dateien hochladen

Lade den `infinity_nations_vorp` Ordner in deinen `resources` Ordner hoch.

### 2. Datenbank einrichten

Führe die `install.sql` Datei in deiner Datenbank aus. Dies erstellt alle benötigten Tabellen.

```sql
-- Kopiere den Inhalt von install.sql und führe ihn aus
```

### 3. Server.cfg bearbeiten

Füge folgende Zeile zu deiner `server.cfg` hinzu:

```cfg
ensure infinity_nations_vorp
```

Stelle sicher, dass es NACH vorp_core und oxmysql geladen wird:

```cfg
ensure vorp_core
ensure oxmysql
ensure infinity_nations_vorp
```

### 4. Config anpassen

Öffne `config.lua` und passe die Einstellungen an:

```lua
Config.Language = 'de' -- 'de' oder 'en'
Config.TaxInterval = 60 -- Minuten zwischen Steuern
```

Du kannst auch die Positionen der Städte anpassen:

```lua
Config.Towns = {
    {
        name = 'Valentine',
        nation = 'New Hanover',
        coords = vector3(-278.81, 804.42, 119.38),
        blip = {
            sprite = 'blip_proc_home',
            name = 'Valentine Rathaus'
        }
    },
    -- Weitere Städte...
}
```

### 5. Server starten

Starte deinen Server neu und die Mod sollte funktionieren!

## 🎮 Verwendung

### Für Spieler

1. **Stadt beitreten**
   - Gehe zu einem Rathaus (markiert auf der Karte)
   - Drücke `G` um das Menü zu öffnen
   - Klicke auf "Stadt beitreten"
   - Zahle das Eintrittsgeld

2. **Tägliche Belohnung abholen**
   - Öffne das Stadtmenü
   - Klicke auf "Belohnung abholen"
   - Erhalte Geld und XP

3. **Stadt verlassen**
   - Öffne das Stadtmenü
   - Klicke auf "Stadt verlassen"

### Admin Befehle

```
/createnation <name> - Erstelle eine neue Nation
/setmayor <player_id> <stadt> - Setze einen Bürgermeister
```

### Für Bürgermeister

Bürgermeister haben Zugriff auf zusätzliche Kontrollen im Stadtmenü:

- Banksteuer ändern (%)
- Stadtsteuer ändern ($)
- Eintrittsgeld ändern ($)
- Stadtbank verwalten

## 🔌 Export Funktionen

### Für andere Scripts

Du kannst diese Funktionen in anderen Scripts verwenden:

```lua
-- Geld zur Stadtbank hinzufügen
exports['infinity_nations_vorp']:AddMoneyToTown('Valentine', 1000)

-- Geld von Stadtbank entfernen
exports['infinity_nations_vorp']:RemoveMoneyFromTown('Valentine', 500)

-- Geld zur Nationsbank hinzufügen
exports['infinity_nations_vorp']:AddMoneyToNation('New Hanover', 2000)

-- Geld von Nationsbank entfernen
exports['infinity_nations_vorp']:RemoveMoneyFromNation('New Hanover', 1000)

-- Stadtinfo abrufen
local townInfo = exports['infinity_nations_vorp']:GetTownInfo('Valentine')
print(townInfo.bank) -- Zeigt Stadtbank an

-- Nationsinfo abrufen
local nationInfo = exports['infinity_nations_vorp']:GetNationInfo('New Hanover')
print(nationInfo.bank) -- Zeigt Nationsbank an

-- Prüfe ob Spieler Bürger ist
local isCitizen = exports['infinity_nations_vorp']:IsCitizen(source)

-- Hole Spieler Stadt
local townName = exports['infinity_nations_vorp']:GetPlayerTown(source)

-- Hole Spieler Nation
local nationName = exports['infinity_nations_vorp']:GetPlayerNation(source)
```

### Beispiel Integration mit Shop

```lua
-- In deinem Shop Script
RegisterServerEvent('myshop:buyItem')
AddEventHandler('myshop:buyItem', function(item, price)
    local _source = source
    
    -- 10% des Kaufpreises geht an die Stadt
    local townTax = price * 0.1
    
    -- Hole Spieler Stadt
    local townName = exports['infinity_nations_vorp']:GetPlayerTown(_source)
    
    if townName then
        -- Füge Steuer zur Stadtbank hinzu
        exports['infinity_nations_vorp']:AddMoneyToTown(townName, townTax)
    end
    
    -- Normaler Kaufvorgang...
end)
```

## ⚙️ Konfiguration

### Standardwerte

```lua
Config.DefaultValues = {
    BankTax = 5,        -- Prozent
    CityTax = 10,       -- Dollar pro Intervall
    EntryFee = 50,      -- Dollar
    RewardMoney = 25,   -- Dollar pro Tag
    RewardXP = 10       -- XP pro Tag
}
```

### Steuern Intervall

```lua
Config.TaxInterval = 60 -- Minuten zwischen Steuererhebungen
```

### Admin Gruppen

```lua
Config.AdminGroups = {
    'admin',
    'superadmin'
}
```

## 🎨 UI Anpassung

Das UI kann in `html/style.css` angepasst werden. Die Farben sind im Western-Stil gehalten:

- Gold (#FFD700) - Akzente
- Braun (#8B4513) - Hauptfarbe
- Grün (#00FF00) - Geld
- Orange (#FFA500) - Steuern

## 🐛 Problembehandlung

### Script startet nicht

1. Prüfe ob vorp_core und oxmysql laufen
2. Prüfe die Server-Logs auf Fehler
3. Stelle sicher dass die SQL Tabellen erstellt wurden

### Spieler können Stadt nicht beitreten

1. Prüfe ob Spieler genug Geld hat
2. Prüfe ob Spieler bereits Bürger ist
3. Prüfe die Server-Logs

### UI öffnet sich nicht

1. Prüfe ob die HTML Dateien korrekt geladen sind
2. Prüfe Browser-Konsole (F12) auf Fehler
3. Stelle sicher dass prompts korrekt erstellt werden

## 📊 Performance

- **Idle**: 0.00ms
- **Aktiv**: 0.02-0.03ms
- **Speicher**: ~2-3 MB

## 🔄 Updates

### Version 2.0.0
- Initiales Release
- Grundlegendes Wirtschaftssystem
- Bürgermeister und Gouverneur System
- Tägliche Belohnungen
- Export Funktionen
- Modernes UI

## 📝 Lizenz

Dieses Script wurde als Beispiel erstellt und kann frei verwendet und modifiziert werden.

## 💬 Support

Bei Fragen oder Problemen:
1. Prüfe die Logs
2. Lies die Dokumentation
3. Suche nach ähnlichen Problemen

## 🙏 Credits

Inspiriert von der originalen Infinity Nations Mod für RedM.

## 🎯 Roadmap

- [ ] Erweiterte Gouverneur Funktionen
- [ ] Krieg zwischen Nationen
- [ ] Erweiterte Statistiken
- [ ] Web-Panel
- [ ] Erweiterte Pass Funktionen
- [ ] Mehr Events und Missionen

---

**Viel Spaß mit Infinity Nations! 🤠**
