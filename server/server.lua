local VORPcore = {}
local nations = {}
local towns = {}
local citizens = {}

TriggerEvent("getCore", function(core)
    VORPcore = core
end)

-- Hilfsfunktionen
function _T(str)
    if Config.Texts[Config.Language] and Config.Texts[Config.Language][str] then
        return Config.Texts[Config.Language][str]
    end
    return str
end

function GetPlayerGroup(source)
    local User = VORPcore.getUser(source)
    if not User then return nil end
    local Character = User.getUsedCharacter
    return Character.group
end

function IsAdmin(source)
    local group = GetPlayerGroup(source)
    for _, adminGroup in pairs(Config.AdminGroups) do
        if group == adminGroup then
            return true
        end
    end
    return false
end

-- Datenbank Initialisierung
CreateThread(function()
    -- Erstelle Tabellen wenn nicht vorhanden
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS `infinity_nations` (
            `id` INT(11) NOT NULL AUTO_INCREMENT,
            `name` VARCHAR(50) NOT NULL,
            `governor_id` VARCHAR(50) NULL DEFAULT NULL,
            `bank` DOUBLE NOT NULL DEFAULT 0,
            `tax_rate` INT(11) NOT NULL DEFAULT 5,
            `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (`id`),
            UNIQUE INDEX `name` (`name`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])

    MySQL.query([[
        CREATE TABLE IF NOT EXISTS `infinity_towns` (
            `id` INT(11) NOT NULL AUTO_INCREMENT,
            `name` VARCHAR(50) NOT NULL,
            `nation_id` INT(11) NOT NULL,
            `mayor_id` VARCHAR(50) NULL DEFAULT NULL,
            `bank` DOUBLE NOT NULL DEFAULT 0,
            `bank_tax` INT(11) NOT NULL DEFAULT 5,
            `city_tax` DOUBLE NOT NULL DEFAULT 10,
            `entry_fee` DOUBLE NOT NULL DEFAULT 50,
            `max_population` INT(11) NOT NULL DEFAULT 100,
            `reward_money` DOUBLE NOT NULL DEFAULT 25,
            `reward_xp` INT(11) NOT NULL DEFAULT 10,
            `motd` TEXT NULL DEFAULT NULL,
            `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (`id`),
            UNIQUE INDEX `name` (`name`),
            INDEX `nation_id` (`nation_id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])

    MySQL.query([[
        CREATE TABLE IF NOT EXISTS `infinity_citizens` (
            `id` INT(11) NOT NULL AUTO_INCREMENT,
            `character_id` VARCHAR(50) NOT NULL,
            `town_id` INT(11) NOT NULL,
            `has_passport` TINYINT(1) NOT NULL DEFAULT 0,
            `join_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            `last_reward` TIMESTAMP NULL DEFAULT NULL,
            PRIMARY KEY (`id`),
            UNIQUE INDEX `character_id` (`character_id`),
            INDEX `town_id` (`town_id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])

    Wait(1000)
    
    -- Lade alle Nationen
    LoadNations()
    -- Lade alle Städte
    LoadTowns()
    
    print('^2[Infinity Nations]^7 Datenbank initialisiert')
end)

-- Lade Nationen aus Datenbank
function LoadNations()
    local result = MySQL.query.await('SELECT * FROM infinity_nations', {})
    nations = {}
    
    if result then
        for _, nation in pairs(result) do
            nations[nation.id] = nation
        end
        print('^2[Infinity Nations]^7 ' .. #result .. ' Nationen geladen')
    end
end

-- Lade Städte aus Datenbank
function LoadTowns()
    local result = MySQL.query.await('SELECT * FROM infinity_towns', {})
    towns = {}
    
    if result then
        for _, town in pairs(result) do
            towns[town.id] = town
        end
        print('^2[Infinity Nations]^7 ' .. #result .. ' Städte geladen')
    end
end

-- Erstelle Nationen und Städte aus Config
CreateThread(function()
    Wait(2000)
    
    -- Erstelle Nationen
    local nationsList = {}
    for _, townConfig in pairs(Config.Towns) do
        if not nationsList[townConfig.nation] then
            nationsList[townConfig.nation] = true
        end
    end
    
    for nationName, _ in pairs(nationsList) do
        local result = MySQL.query.await('SELECT id FROM infinity_nations WHERE name = ?', {nationName})
        if not result or #result == 0 then
            MySQL.insert.await('INSERT INTO infinity_nations (name) VALUES (?)', {nationName})
            print('^2[Infinity Nations]^7 Nation erstellt: ' .. nationName)
        end
    end
    
    Wait(1000)
    LoadNations()
    
    -- Erstelle Städte
    for _, townConfig in pairs(Config.Towns) do
        local result = MySQL.query.await('SELECT id FROM infinity_towns WHERE name = ?', {townConfig.name})
        if not result or #result == 0 then
            -- Finde Nation ID
            local nationId = nil
            for id, nation in pairs(nations) do
                if nation.name == townConfig.nation then
                    nationId = id
                    break
                end
            end
            
            if nationId then
                MySQL.insert.await([[
                    INSERT INTO infinity_towns 
                    (name, nation_id, bank_tax, city_tax, entry_fee, reward_money, reward_xp) 
                    VALUES (?, ?, ?, ?, ?, ?, ?)
                ]], {
                    townConfig.name,
                    nationId,
                    Config.DefaultValues.BankTax,
                    Config.DefaultValues.CityTax,
                    Config.DefaultValues.EntryFee,
                    Config.DefaultValues.RewardMoney,
                    Config.DefaultValues.RewardXP
                })
                print('^2[Infinity Nations]^7 Stadt erstellt: ' .. townConfig.name)
            end
        end
    end
    
    Wait(1000)
    LoadTowns()
end)

-- Spieler verbinden
AddEventHandler('playerConnecting', function()
    local _source = source
    Wait(2000)
    
    local User = VORPcore.getUser(_source)
    if not User then return end
    local Character = User.getUsedCharacter
    if not Character then return end
    
    LoadPlayerCitizenship(_source, Character.charIdentifier)
end)

function LoadPlayerCitizenship(source, charId)
    local result = MySQL.query.await('SELECT * FROM infinity_citizens WHERE character_id = ?', {charId})
    
    if result and #result > 0 then
        citizens[source] = result[1]
    else
        citizens[source] = nil
    end
end

-- Hole Stadtinfo
RegisterServerEvent('infinity_nations:requestTownInfo')
AddEventHandler('infinity_nations:requestTownInfo', function(townName)
    local _source = source
    
    -- Finde Stadt
    local townData = nil
    for _, town in pairs(towns) do
        if town.name == townName then
            townData = town
            break
        end
    end
    
    if not townData then
        TriggerClientEvent('vorp:TipRight', _source, 'Stadt nicht gefunden', 3000)
        return
    end
    
    -- Hole Bürger Anzahl
    local citizenCount = MySQL.scalar.await('SELECT COUNT(*) FROM infinity_citizens WHERE town_id = ?', {townData.id}) or 0
    
    -- Hole Nation Info
    local nationData = nations[townData.nation_id]
    
    -- Prüfe ob Spieler Bürger ist
    local User = VORPcore.getUser(_source)
    if not User then 
        print('^1[Infinity Nations ERROR]^7 User not found for source: ' .. _source)
        return 
    end
    
    local Character = User.getUsedCharacter
    if not Character then 
        print('^1[Infinity Nations ERROR]^7 Character not found for source: ' .. _source)
        return 
    end
    
    -- DEBUG: Zeige alle möglichen Identifier
    print('^3[Infinity Nations DEBUG]^7 ==========================================')
    print('^3[Infinity Nations DEBUG]^7 Player: ' .. Character.firstname .. ' ' .. Character.lastname)
    print('^3[Infinity Nations DEBUG]^7 Character.charIdentifier: ' .. tostring(Character.charIdentifier))
    print('^3[Infinity Nations DEBUG]^7 Character.identifier: ' .. tostring(Character.identifier))
    print('^3[Infinity Nations DEBUG]^7 Character.charidentifier: ' .. tostring(Character.charidentifier))
    print('^3[Infinity Nations DEBUG]^7 Town Mayor ID: ' .. tostring(townData.mayor_id))
    if nationData then
        print('^3[Infinity Nations DEBUG]^7 Nation Governor ID: ' .. tostring(nationData.governor_id))
    end
    print('^3[Infinity Nations DEBUG]^7 ==========================================')
    
    local isCitizen = false
    local isMayor = false
    local isGovernor = false
    
    if citizens[_source] and citizens[_source].town_id == townData.id then
        isCitizen = true
    end
    
    -- Versuche verschiedene Identifier-Formate
    local playerIdentifier = Character.charIdentifier or Character.identifier or Character.charidentifier
    
    -- WICHTIG: Konvertiere zu String für Vergleich
    playerIdentifier = tostring(playerIdentifier)
    local mayorIdStr = tostring(townData.mayor_id)
    local governorIdStr = nationData and tostring(nationData.governor_id) or nil
    
    print('^3[Infinity Nations DEBUG]^7 Using playerIdentifier: "' .. playerIdentifier .. '" (type: ' .. type(playerIdentifier) .. ')')
    print('^3[Infinity Nations DEBUG]^7 Comparing with mayor_id: "' .. mayorIdStr .. '" (type: ' .. type(mayorIdStr) .. ')')
    print('^3[Infinity Nations DEBUG]^7 Are they equal? ' .. tostring(playerIdentifier == mayorIdStr))
    
    if townData.mayor_id and playerIdentifier and playerIdentifier == mayorIdStr then
        isMayor = true
        print('^2[Infinity Nations]^7 ✓ Spieler ' .. Character.firstname .. ' ist Bürgermeister von ' .. townData.name)
    else
        print('^1[Infinity Nations]^7 ✗ Spieler ' .. Character.firstname .. ' ist NICHT Bürgermeister')
        if townData.mayor_id then
            print('^1[Infinity Nations]^7   Grund: IDs stimmen nicht überein')
            print('^1[Infinity Nations]^7   Player ID: "' .. playerIdentifier .. '" (type: ' .. type(playerIdentifier) .. ')')
            print('^1[Infinity Nations]^7   Mayor ID:  "' .. mayorIdStr .. '" (type: ' .. type(mayorIdStr) .. ')')
        else
            print('^1[Infinity Nations]^7   Grund: Kein Bürgermeister gesetzt')
        end
    end
    
    if nationData and nationData.governor_id and playerIdentifier and playerIdentifier == governorIdStr then
        isGovernor = true
        print('^2[Infinity Nations]^7 ✓ Spieler ' .. Character.firstname .. ' ist Gouverneur von ' .. nationData.name)
    else
        if nationData and nationData.governor_id then
            print('^1[Infinity Nations]^7 ✗ Spieler ' .. Character.firstname .. ' ist NICHT Gouverneur')
            print('^1[Infinity Nations]^7   Player ID: "' .. playerIdentifier .. '" (type: ' .. type(playerIdentifier) .. ')')
            print('^1[Infinity Nations]^7   Governor ID:  "' .. governorIdStr .. '" (type: ' .. type(governorIdStr) .. ')')
        end
    end
    
    -- Hole Mayor und Governor Namen
    local mayorName = 'Keiner'
    local governorName = 'Keiner'
    
    if townData.mayor_id then
        local mayorResult = MySQL.query.await('SELECT firstname, lastname FROM characters WHERE charidentifier = ?', {townData.mayor_id})
        if mayorResult and #mayorResult > 0 then
            mayorName = mayorResult[1].firstname .. ' ' .. mayorResult[1].lastname
        end
    end
    
    if nationData and nationData.governor_id then
        local govResult = MySQL.query.await('SELECT firstname, lastname FROM characters WHERE charidentifier = ?', {nationData.governor_id})
        if govResult and #govResult > 0 then
            governorName = govResult[1].firstname .. ' ' .. govResult[1].lastname
        end
    end
    
    print('^3[Infinity Nations DEBUG]^7 Sending to client:')
    print('^3[Infinity Nations DEBUG]^7   isCitizen: ' .. tostring(isCitizen))
    print('^3[Infinity Nations DEBUG]^7   isMayor: ' .. tostring(isMayor))
    print('^3[Infinity Nations DEBUG]^7   isGovernor: ' .. tostring(isGovernor))
    
    TriggerClientEvent('infinity_nations:receiveTownInfo', _source, {
        town = townData,
        nation = nationData,
        citizenCount = citizenCount,
        isCitizen = isCitizen,
        isMayor = isMayor,
        isGovernor = isGovernor,
        mayorName = mayorName,
        governorName = governorName
    })
end)

-- Trete Stadt bei
RegisterServerEvent('infinity_nations:joinTown')
AddEventHandler('infinity_nations:joinTown', function(townName)
    local _source = source
    local User = VORPcore.getUser(_source)
    if not User then return end
    local Character = User.getUsedCharacter
    
    -- Prüfe ob bereits Bürger
    if citizens[_source] then
        TriggerClientEvent('vorp:TipRight', _source, _T('already_citizen'), 3000)
        return
    end
    
    -- Finde Stadt
    local townData = nil
    for _, town in pairs(towns) do
        if town.name == townName then
            townData = town
            break
        end
    end
    
    if not townData then return end
    
    -- Prüfe Geld
    if Character.money < townData.entry_fee then
        TriggerClientEvent('vorp:TipRight', _source, _T('not_enough_money'), 3000)
        return
    end
    
    -- Ziehe Eintrittsgeld ab
    Character.removeCurrency(0, townData.entry_fee)
    
    -- Füge zu Stadtbank hinzu
    MySQL.update.await('UPDATE infinity_towns SET bank = bank + ? WHERE id = ?', {
        townData.entry_fee,
        townData.id
    })
    
    -- Füge Bürger hinzu
    MySQL.insert.await('INSERT INTO infinity_citizens (character_id, town_id) VALUES (?, ?)', {
        Character.charIdentifier,
        townData.id
    })
    
    -- Lade Bürgerschaft neu
    LoadPlayerCitizenship(_source, Character.charIdentifier)
    
    TriggerClientEvent('vorp:TipRight', _source, _T('joined_city') .. townData.name, 5000)
    TriggerClientEvent('infinity_nations:updateCitizenship', _source)
end)

-- Verlasse Stadt
RegisterServerEvent('infinity_nations:leaveTown')
AddEventHandler('infinity_nations:leaveTown', function()
    local _source = source
    local User = VORPcore.getUser(_source)
    if not User then return end
    local Character = User.getUsedCharacter
    
    if not citizens[_source] then
        TriggerClientEvent('vorp:TipRight', _source, _T('not_citizen'), 3000)
        return
    end
    
    -- Entferne Bürger
    MySQL.update.await('DELETE FROM infinity_citizens WHERE character_id = ?', {
        Character.charIdentifier
    })
    
    citizens[_source] = nil
    
    TriggerClientEvent('vorp:TipRight', _source, _T('left_city'), 5000)
    TriggerClientEvent('infinity_nations:updateCitizenship', _source)
end)

-- Tägliche Belohnung
RegisterServerEvent('infinity_nations:claimReward')
AddEventHandler('infinity_nations:claimReward', function()
    local _source = source
    local User = VORPcore.getUser(_source)
    if not User then return end
    local Character = User.getUsedCharacter
    
    if not citizens[_source] then
        TriggerClientEvent('vorp:TipRight', _source, _T('not_citizen'), 3000)
        return
    end
    
    -- Prüfe letzte Belohnung
    local lastReward = citizens[_source].last_reward
    if lastReward then
        local lastRewardTime = os.time({
            year = tonumber(os.date('%Y', lastReward)),
            month = tonumber(os.date('%m', lastReward)),
            day = tonumber(os.date('%d', lastReward)),
            hour = tonumber(os.date('%H', lastReward)),
            min = tonumber(os.date('%M', lastReward)),
            sec = tonumber(os.date('%S', lastReward))
        })
        
        local timeDiff = os.time() - lastRewardTime
        local minTime = Config.RewardInterval * 60
        
        if timeDiff < minTime then
            local remaining = math.ceil((minTime - timeDiff) / 60)
            TriggerClientEvent('vorp:TipRight', _source, 'Belohnung verfügbar in ' .. remaining .. ' Minuten', 3000)
            return
        end
    end
    
    -- Hole Stadt
    local townData = towns[citizens[_source].town_id]
    if not townData then return end
    
    -- Prüfe Stadtbank
    if townData.bank < townData.reward_money then
        TriggerClientEvent('vorp:TipRight', _source, 'Stadtbank hat nicht genug Geld', 3000)
        return
    end
    
    -- Gebe Belohnungen
    Character.addCurrency(0, townData.reward_money)
    Character.addXp(townData.reward_xp)
    
    -- Ziehe von Stadtbank ab
    MySQL.update.await('UPDATE infinity_towns SET bank = bank - ? WHERE id = ?', {
        townData.reward_money,
        townData.id
    })
    
    -- Update letzte Belohnung
    MySQL.update.await('UPDATE infinity_citizens SET last_reward = NOW() WHERE character_id = ?', {
        Character.charIdentifier
    })
    
    LoadPlayerCitizenship(_source, Character.charIdentifier)
    
    TriggerClientEvent('vorp:TipRight', _source, _T('daily_reward') .. '$' .. townData.reward_money .. ' & ' .. townData.reward_xp .. ' XP', 5000)
end)

-- Bürgermeister: Update Steuern
RegisterServerEvent('infinity_nations:updateTax')
AddEventHandler('infinity_nations:updateTax', function(townName, taxType, value)
    local _source = source
    local User = VORPcore.getUser(_source)
    if not User then return end
    local Character = User.getUsedCharacter
    
    -- Finde Stadt
    local townData = nil
    for _, town in pairs(towns) do
        if town.name == townName then
            townData = town
            break
        end
    end
    
    if not townData then return end
    
    -- Prüfe ob Bürgermeister
    if townData.mayor_id ~= Character.charIdentifier then
        TriggerClientEvent('vorp:TipRight', _source, 'Du bist nicht der Bürgermeister dieser Stadt', 3000)
        return
    end
    
    -- Update basierend auf Typ
    if taxType == 'bank' then
        MySQL.update.await('UPDATE infinity_towns SET bank_tax = ? WHERE id = ?', {
            value,
            townData.id
        })
        TriggerClientEvent('vorp:TipRight', _source, 'Banksteuer auf ' .. value .. '% gesetzt', 3000)
    elseif taxType == 'city' then
        MySQL.update.await('UPDATE infinity_towns SET city_tax = ? WHERE id = ?', {
            value,
            townData.id
        })
        TriggerClientEvent('vorp:TipRight', _source, 'Stadtsteuer auf $' .. value .. ' gesetzt', 3000)
    elseif taxType == 'entry' then
        MySQL.update.await('UPDATE infinity_towns SET entry_fee = ? WHERE id = ?', {
            value,
            townData.id
        })
        TriggerClientEvent('vorp:TipRight', _source, 'Eintrittsgeld auf $' .. value .. ' gesetzt', 3000)
    elseif taxType == 'reward_money' then
        MySQL.update.await('UPDATE infinity_towns SET reward_money = ? WHERE id = ?', {
            value,
            townData.id
        })
        TriggerClientEvent('vorp:TipRight', _source, 'Tägliche Geldbelohnung auf $' .. value .. ' gesetzt', 3000)
    elseif taxType == 'reward_xp' then
        MySQL.update.await('UPDATE infinity_towns SET reward_xp = ? WHERE id = ?', {
            value,
            townData.id
        })
        TriggerClientEvent('vorp:TipRight', _source, 'Tägliche XP-Belohnung auf ' .. value .. ' gesetzt', 3000)
    elseif taxType == 'max_population' then
        MySQL.update.await('UPDATE infinity_towns SET max_population = ? WHERE id = ?', {
            value,
            townData.id
        })
        TriggerClientEvent('vorp:TipRight', _source, 'Maximale Bevölkerung auf ' .. value .. ' gesetzt', 3000)
    elseif taxType == 'motd' then
        MySQL.update.await('UPDATE infinity_towns SET motd = ? WHERE id = ?', {
            value,
            townData.id
        })
        TriggerClientEvent('vorp:TipRight', _source, 'Nachricht des Tages aktualisiert', 3000)
    end
    
    -- Lade Städte neu
    LoadTowns()
    
    -- Update UI
    TriggerClientEvent('infinity_nations:updateCitizenship', _source)
    Wait(500)
    TriggerServerEvent('infinity_nations:requestTownInfo', townName)
end)

-- Bürgermeister: Geld abheben
RegisterServerEvent('infinity_nations:withdrawMoney')
AddEventHandler('infinity_nations:withdrawMoney', function(townName, amount)
    local _source = source
    local User = VORPcore.getUser(_source)
    if not User then return end
    local Character = User.getUsedCharacter
    
    -- Finde Stadt
    local townData = nil
    for _, town in pairs(towns) do
        if town.name == townName then
            townData = town
            break
        end
    end
    
    if not townData then return end
    
    -- Prüfe ob Bürgermeister
    if townData.mayor_id ~= Character.charIdentifier then
        TriggerClientEvent('vorp:TipRight', _source, 'Du bist nicht der Bürgermeister dieser Stadt', 3000)
        return
    end
    
    -- Prüfe Stadtbank
    if townData.bank < amount then
        TriggerClientEvent('vorp:TipRight', _source, 'Stadtbank hat nicht genug Geld', 3000)
        return
    end
    
    -- Ziehe von Stadtbank ab und gebe Spieler
    MySQL.update.await('UPDATE infinity_towns SET bank = bank - ? WHERE id = ?', {
        amount,
        townData.id
    })
    
    Character.addCurrency(0, amount)
    
    LoadTowns()
    
    TriggerClientEvent('vorp:TipRight', _source, '$' .. amount .. ' von Stadtbank abgehoben', 3000)
end)

-- Bürgermeister: Geld einzahlen
RegisterServerEvent('infinity_nations:depositMoney')
AddEventHandler('infinity_nations:depositMoney', function(townName, amount)
    local _source = source
    local User = VORPcore.getUser(_source)
    if not User then return end
    local Character = User.getUsedCharacter
    
    -- Finde Stadt
    local townData = nil
    for _, town in pairs(towns) do
        if town.name == townName then
            townData = town
            break
        end
    end
    
    if not townData then return end
    
    -- Prüfe ob Bürgermeister
    if townData.mayor_id ~= Character.charIdentifier then
        TriggerClientEvent('vorp:TipRight', _source, 'Du bist nicht der Bürgermeister dieser Stadt', 3000)
        return
    end
    
    -- Prüfe Spieler Geld
    if Character.money < amount then
        TriggerClientEvent('vorp:TipRight', _source, 'Du hast nicht genug Geld', 3000)
        return
    end
    
    -- Ziehe von Spieler ab und füge zu Stadtbank hinzu
    Character.removeCurrency(0, amount)
    
    MySQL.update.await('UPDATE infinity_towns SET bank = bank + ? WHERE id = ?', {
        amount,
        townData.id
    })
    
    LoadTowns()
    
    TriggerClientEvent('vorp:TipRight', _source, '$' .. amount .. ' zur Stadtbank hinzugefügt', 3000)
end)

-- Steuern System
CreateThread(function()
    while true do
        Wait(Config.TaxInterval * 60 * 1000)
        
        -- Sammle Steuern von allen Bürgern
        for _, town in pairs(towns) do
            local townCitizens = MySQL.query.await('SELECT character_id FROM infinity_citizens WHERE town_id = ?', {town.id})
            
            if townCitizens then
                local totalTax = 0
                
                for _, citizen in pairs(townCitizens) do
                    -- Hier könnte man Geld vom Spieler abziehen wenn online
                    -- Für jetzt fügen wir nur zur Stadtbank hinzu
                    totalTax = totalTax + town.city_tax
                end
                
                if totalTax > 0 then
                    MySQL.update.await('UPDATE infinity_towns SET bank = bank + ? WHERE id = ?', {
                        totalTax,
                        town.id
                    })
                    
                    print('^2[Infinity Nations]^7 ' .. town.name .. ' sammelte $' .. totalTax .. ' an Steuern')
                end
            end
        end
    end
end)

-- Admin Befehle
RegisterCommand('createnation', function(source, args, rawCommand)
    if source == 0 or IsAdmin(source) then
        if #args < 1 then
            TriggerClientEvent('vorp:TipRight', source, 'Verwendung: /createnation <name>', 3000)
            return
        end
        
        local nationName = table.concat(args, ' ')
        
        local result = MySQL.query.await('SELECT id FROM infinity_nations WHERE name = ?', {nationName})
        if result and #result > 0 then
            TriggerClientEvent('vorp:TipRight', source, 'Nation existiert bereits', 3000)
            return
        end
        
        MySQL.insert.await('INSERT INTO infinity_nations (name) VALUES (?)', {nationName})
        LoadNations()
        
        TriggerClientEvent('vorp:TipRight', source, 'Nation ' .. nationName .. ' erstellt', 5000)
    end
end, false)

RegisterCommand('setmayor', function(source, args, rawCommand)
    if source == 0 or IsAdmin(source) then
        if #args < 2 then
            if source > 0 then
                TriggerClientEvent('vorp:TipRight', source, 'Verwendung: /setmayor <player_id> <stadt>', 3000)
            else
                print('Verwendung: /setmayor <player_id> <stadt>')
            end
            return
        end
        
        local targetId = tonumber(args[1])
        local townName = table.concat(args, ' ', 2)
        
        print('^3[Infinity Nations]^7 /setmayor command received')
        print('^3[Infinity Nations]^7   Target ID: ' .. targetId)
        print('^3[Infinity Nations]^7   Town Name: ' .. townName)
        
        local targetUser = VORPcore.getUser(targetId)
        if not targetUser then
            local msg = 'Spieler mit ID ' .. targetId .. ' nicht gefunden oder nicht online'
            if source > 0 then
                TriggerClientEvent('vorp:TipRight', source, msg, 3000)
            end
            print('^1[Infinity Nations ERROR]^7 ' .. msg)
            return
        end
        
        local targetChar = targetUser.getUsedCharacter
        if not targetChar then
            local msg = 'Spieler hat keinen Character geladen'
            if source > 0 then
                TriggerClientEvent('vorp:TipRight', source, msg, 3000)
            end
            print('^1[Infinity Nations ERROR]^7 ' .. msg)
            return
        end
        
        -- DEBUG: Zeige Character Identifier
        print('^3[Infinity Nations DEBUG]^7 Target Character Info:')
        print('^3[Infinity Nations DEBUG]^7   Name: ' .. targetChar.firstname .. ' ' .. targetChar.lastname)
        print('^3[Infinity Nations DEBUG]^7   charIdentifier: ' .. tostring(targetChar.charIdentifier))
        print('^3[Infinity Nations DEBUG]^7   identifier: ' .. tostring(targetChar.identifier))
        print('^3[Infinity Nations DEBUG]^7   charidentifier: ' .. tostring(targetChar.charidentifier))
        
        -- Finde Stadt
        local townData = nil
        for _, town in pairs(towns) do
            if town.name == townName then
                townData = town
                break
            end
        end
        
        if not townData then
            local msg = 'Stadt "' .. townName .. '" nicht gefunden'
            if source > 0 then
                TriggerClientEvent('vorp:TipRight', source, msg, 3000)
            end
            print('^1[Infinity Nations ERROR]^7 ' .. msg)
            print('^1[Infinity Nations ERROR]^7 Verfügbare Städte:')
            for _, town in pairs(towns) do
                print('^1[Infinity Nations ERROR]^7   - ' .. town.name)
            end
            return
        end
        
        -- Verwende das richtige Identifier-Feld
        local charId = targetChar.charIdentifier or targetChar.identifier or targetChar.charidentifier
        
        print('^2[Infinity Nations]^7 Setting mayor:')
        print('^2[Infinity Nations]^7   Character ID: ' .. tostring(charId))
        print('^2[Infinity Nations]^7   Town: ' .. townData.name)
        print('^2[Infinity Nations]^7   Town ID: ' .. townData.id)
        
        MySQL.update.await('UPDATE infinity_towns SET mayor_id = ? WHERE id = ?', {
            charId,
            townData.id
        })
        
        LoadTowns()
        
        -- Verify update
        Wait(500)
        local verifyResult = MySQL.query.await('SELECT mayor_id FROM infinity_towns WHERE id = ?', {townData.id})
        if verifyResult and #verifyResult > 0 then
            print('^2[Infinity Nations]^7 Verification - Mayor ID in DB: ' .. tostring(verifyResult[1].mayor_id))
        end
        
        local successMsg = targetChar.firstname .. ' ' .. targetChar.lastname .. ' ist jetzt Bürgermeister von ' .. townName
        if source > 0 then
            TriggerClientEvent('vorp:TipRight', source, successMsg, 5000)
        end
        TriggerClientEvent('vorp:TipRight', targetId, 'Du bist jetzt Bürgermeister von ' .. townName, 5000)
        print('^2[Infinity Nations]^7 ✓ ' .. successMsg)
    end
end, false)

RegisterCommand('setgovernor', function(source, args, rawCommand)
    if source == 0 or IsAdmin(source) then
        if #args < 2 then
            if source > 0 then
                TriggerClientEvent('vorp:TipRight', source, 'Verwendung: /setgovernor <player_id> <nation>', 3000)
            else
                print('Verwendung: /setgovernor <player_id> <nation>')
            end
            return
        end
        
        local targetId = tonumber(args[1])
        local nationName = table.concat(args, ' ', 2)
        
        print('^3[Infinity Nations]^7 /setgovernor command received')
        print('^3[Infinity Nations]^7   Target ID: ' .. targetId)
        print('^3[Infinity Nations]^7   Nation Name: ' .. nationName)
        
        local targetUser = VORPcore.getUser(targetId)
        if not targetUser then
            local msg = 'Spieler mit ID ' .. targetId .. ' nicht gefunden oder nicht online'
            if source > 0 then
                TriggerClientEvent('vorp:TipRight', source, msg, 3000)
            end
            print('^1[Infinity Nations ERROR]^7 ' .. msg)
            return
        end
        
        local targetChar = targetUser.getUsedCharacter
        if not targetChar then
            local msg = 'Spieler hat keinen Character geladen'
            if source > 0 then
                TriggerClientEvent('vorp:TipRight', source, msg, 3000)
            end
            print('^1[Infinity Nations ERROR]^7 ' .. msg)
            return
        end
        
        -- DEBUG: Zeige Character Identifier
        print('^3[Infinity Nations DEBUG]^7 Target Character Info:')
        print('^3[Infinity Nations DEBUG]^7   Name: ' .. targetChar.firstname .. ' ' .. targetChar.lastname)
        print('^3[Infinity Nations DEBUG]^7   charIdentifier: ' .. tostring(targetChar.charIdentifier))
        print('^3[Infinity Nations DEBUG]^7   identifier: ' .. tostring(targetChar.identifier))
        print('^3[Infinity Nations DEBUG]^7   charidentifier: ' .. tostring(targetChar.charidentifier))
        
        -- Finde Nation
        local nationData = nil
        for _, nation in pairs(nations) do
            if nation.name == nationName then
                nationData = nation
                break
            end
        end
        
        if not nationData then
            local msg = 'Nation "' .. nationName .. '" nicht gefunden'
            if source > 0 then
                TriggerClientEvent('vorp:TipRight', source, msg, 3000)
            end
            print('^1[Infinity Nations ERROR]^7 ' .. msg)
            print('^1[Infinity Nations ERROR]^7 Verfügbare Nationen:')
            for _, nation in pairs(nations) do
                print('^1[Infinity Nations ERROR]^7   - ' .. nation.name)
            end
            return
        end
        
        -- Verwende das richtige Identifier-Feld
        local charId = targetChar.charIdentifier or targetChar.identifier or targetChar.charidentifier
        
        print('^2[Infinity Nations]^7 Setting governor:')
        print('^2[Infinity Nations]^7   Character ID: ' .. tostring(charId))
        print('^2[Infinity Nations]^7   Nation: ' .. nationData.name)
        print('^2[Infinity Nations]^7   Nation ID: ' .. nationData.id)
        
        MySQL.update.await('UPDATE infinity_nations SET governor_id = ? WHERE id = ?', {
            charId,
            nationData.id
        })
        
        LoadNations()
        
        -- Verify update
        Wait(500)
        local verifyResult = MySQL.query.await('SELECT governor_id FROM infinity_nations WHERE id = ?', {nationData.id})
        if verifyResult and #verifyResult > 0 then
            print('^2[Infinity Nations]^7 Verification - Governor ID in DB: ' .. tostring(verifyResult[1].governor_id))
        end
        
        local successMsg = targetChar.firstname .. ' ' .. targetChar.lastname .. ' ist jetzt Gouverneur von ' .. nationName
        if source > 0 then
            TriggerClientEvent('vorp:TipRight', source, successMsg, 5000)
        end
        TriggerClientEvent('vorp:TipRight', targetId, 'Du bist jetzt Gouverneur von ' .. nationName, 5000)
        print('^2[Infinity Nations]^7 ✓ ' .. successMsg)
    end
end, false)

-- Gouverneur: Geld von Nationsbank abheben
RegisterServerEvent('infinity_nations:governor_withdrawMoney')
AddEventHandler('infinity_nations:governor_withdrawMoney', function(nationId, amount)
    local _source = source
    local User = VORPcore.getUser(_source)
    if not User then return end
    local Character = User.getUsedCharacter
    
    local nationData = nations[nationId]
    if not nationData then return end
    
    -- Prüfe ob Gouverneur
    if not nationData.governor_id or nationData.governor_id ~= Character.charIdentifier then
        TriggerClientEvent('vorp:TipRight', _source, 'Du bist nicht der Gouverneur dieser Nation', 3000)
        return
    end
    
    -- Prüfe Nationsbank
    if nationData.bank < amount then
        TriggerClientEvent('vorp:TipRight', _source, 'Nationsbank hat nicht genug Geld', 3000)
        return
    end
    
    MySQL.update.await('UPDATE infinity_nations SET bank = bank - ? WHERE id = ?', {
        amount,
        nationData.id
    })
    
    Character.addCurrency(0, amount)
    LoadNations()
    
    TriggerClientEvent('vorp:TipRight', _source, '$' .. amount .. ' von Nationsbank abgehoben', 3000)
end)

-- Gouverneur: Geld zu Nationsbank einzahlen
RegisterServerEvent('infinity_nations:governor_depositMoney')
AddEventHandler('infinity_nations:governor_depositMoney', function(nationId, amount)
    local _source = source
    local User = VORPcore.getUser(_source)
    if not User then return end
    local Character = User.getUsedCharacter
    
    local nationData = nations[nationId]
    if not nationData then return end
    
    -- Prüfe ob Gouverneur
    if not nationData.governor_id or nationData.governor_id ~= Character.charIdentifier then
        TriggerClientEvent('vorp:TipRight', _source, 'Du bist nicht der Gouverneur dieser Nation', 3000)
        return
    end
    
    -- Prüfe Spieler Geld
    if Character.money < amount then
        TriggerClientEvent('vorp:TipRight', _source, 'Du hast nicht genug Geld', 3000)
        return
    end
    
    Character.removeCurrency(0, amount)
    
    MySQL.update.await('UPDATE infinity_nations SET bank = bank + ? WHERE id = ?', {
        amount,
        nationData.id
    })
    
    LoadNations()
    
    TriggerClientEvent('vorp:TipRight', _source, '$' .. amount .. ' zur Nationsbank hinzugefügt', 3000)
end)

-- Gouverneur: Nationssteuern ändern
RegisterServerEvent('infinity_nations:governor_updateTax')
AddEventHandler('infinity_nations:governor_updateTax', function(nationId, taxRate)
    local _source = source
    local User = VORPcore.getUser(_source)
    if not User then return end
    local Character = User.getUsedCharacter
    
    local nationData = nations[nationId]
    if not nationData then return end
    
    -- Prüfe ob Gouverneur
    if not nationData.governor_id or nationData.governor_id ~= Character.charIdentifier then
        TriggerClientEvent('vorp:TipRight', _source, 'Du bist nicht der Gouverneur dieser Nation', 3000)
        return
    end
    
    MySQL.update.await('UPDATE infinity_nations SET tax_rate = ? WHERE id = ?', {
        taxRate,
        nationData.id
    })
    
    LoadNations()
    
    TriggerClientEvent('vorp:TipRight', _source, 'Nationssteuer auf ' .. taxRate .. '% gesetzt', 3000)
end)

-- DEBUG BEFEHL: Zeige meine Character Info
RegisterCommand('mycharid', function(source, args, rawCommand)
    local User = VORPcore.getUser(source)
    if not User then 
        print('User not found')
        return 
    end
    
    local Character = User.getUsedCharacter
    if not Character then 
        print('Character not found')
        return 
    end
    
    print('^3[Character Info]^7 ==========================================')
    print('^3[Character Info]^7 Name: ' .. Character.firstname .. ' ' .. Character.lastname)
    print('^3[Character Info]^7 charIdentifier: ' .. tostring(Character.charIdentifier))
    print('^3[Character Info]^7 identifier: ' .. tostring(Character.identifier))
    print('^3[Character Info]^7 charidentifier (lowercase): ' .. tostring(Character.charidentifier))
    print('^3[Character Info]^7 ==========================================')
    
    TriggerClientEvent('vorp:TipRight', source, 'Character Info in Server-Logs!', 3000)
end, false)

-- DEBUG BEFEHL: Prüfe Mayor Status
RegisterCommand('checkmayorstatus', function(source, args, rawCommand)
    if #args < 1 then
        TriggerClientEvent('vorp:TipRight', source, 'Verwendung: /checkmayorstatus <stadtname>', 3000)
        return
    end
    
    local townName = table.concat(args, ' ')
    local User = VORPcore.getUser(source)
    if not User then return end
    local Character = User.getUsedCharacter
    if not Character then return end
    
    -- Finde Stadt
    local townData = nil
    for _, town in pairs(towns) do
        if town.name == townName then
            townData = town
            break
        end
    end
    
    if not townData then
        TriggerClientEvent('vorp:TipRight', source, 'Stadt nicht gefunden', 3000)
        return
    end
    
    local playerIdentifier = Character.charIdentifier or Character.identifier or Character.charidentifier
    
    -- WICHTIG: Konvertiere beide zu String
    playerIdentifier = tostring(playerIdentifier)
    local mayorIdStr = tostring(townData.mayor_id)
    
    print('^3[Mayor Check]^7 ==========================================')
    print('^3[Mayor Check]^7 Player: ' .. Character.firstname .. ' ' .. Character.lastname)
    print('^3[Mayor Check]^7 Town: ' .. townData.name)
    print('^3[Mayor Check]^7 Your ID: "' .. playerIdentifier .. '" (type: ' .. type(playerIdentifier) .. ')')
    print('^3[Mayor Check]^7 Mayor ID in DB: "' .. mayorIdStr .. '" (type: ' .. type(mayorIdStr) .. ')')
    print('^3[Mayor Check]^7 Length Your ID: ' .. string.len(playerIdentifier))
    print('^3[Mayor Check]^7 Length Mayor ID: ' .. string.len(mayorIdStr))
    print('^3[Mayor Check]^7 Are they equal? ' .. tostring(playerIdentifier == mayorIdStr))
    
    -- Prüfe Byte für Byte
    if playerIdentifier ~= mayorIdStr then
        print('^3[Mayor Check]^7 Byte comparison:')
        for i = 1, math.max(string.len(playerIdentifier), string.len(mayorIdStr)) do
            local c1 = string.sub(playerIdentifier, i, i)
            local c2 = string.sub(mayorIdStr, i, i)
            if c1 ~= c2 then
                print('^1[Mayor Check]^7   Position ' .. i .. ': "' .. c1 .. '" vs "' .. c2 .. '" DIFFERENT!')
            end
        end
    end
    print('^3[Mayor Check]^7 ==========================================')
    
    if playerIdentifier == mayorIdStr then
        TriggerClientEvent('vorp:TipRight', source, 'DU BIST BÜRGERMEISTER! ✓', 5000)
    else
        TriggerClientEvent('vorp:TipRight', source, 'Du bist NICHT Bürgermeister. Check Server-Logs!', 5000)
    end
end, false)

print('^2[Infinity Nations]^7 Server erfolgreich gestartet')
