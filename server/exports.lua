-- Export Funktionen für andere Scripts

-- Füge Geld zur Stadtbank hinzu
exports('AddMoneyToTown', function(townName, amount)
    if not townName or not amount or amount <= 0 then
        return false
    end
    
    local result = MySQL.query.await('SELECT id FROM infinity_towns WHERE name = ?', {townName})
    if not result or #result == 0 then
        return false
    end
    
    MySQL.update.await('UPDATE infinity_towns SET bank = bank + ? WHERE name = ?', {
        amount,
        townName
    })
    
    print('^2[Infinity Nations]^7 $' .. amount .. ' zur Stadt ' .. townName .. ' hinzugefügt')
    return true
end)

-- Entferne Geld von Stadtbank
exports('RemoveMoneyFromTown', function(townName, amount)
    if not townName or not amount or amount <= 0 then
        return false
    end
    
    local result = MySQL.query.await('SELECT bank FROM infinity_towns WHERE name = ?', {townName})
    if not result or #result == 0 then
        return false
    end
    
    if result[1].bank < amount then
        return false
    end
    
    MySQL.update.await('UPDATE infinity_towns SET bank = bank - ? WHERE name = ?', {
        amount,
        townName
    })
    
    print('^2[Infinity Nations]^7 $' .. amount .. ' von Stadt ' .. townName .. ' entfernt')
    return true
end)

-- Füge Geld zur Nationsbank hinzu
exports('AddMoneyToNation', function(nationName, amount)
    if not nationName or not amount or amount <= 0 then
        return false
    end
    
    local result = MySQL.query.await('SELECT id FROM infinity_nations WHERE name = ?', {nationName})
    if not result or #result == 0 then
        return false
    end
    
    MySQL.update.await('UPDATE infinity_nations SET bank = bank + ? WHERE name = ?', {
        amount,
        nationName
    })
    
    print('^2[Infinity Nations]^7 $' .. amount .. ' zur Nation ' .. nationName .. ' hinzugefügt')
    return true
end)

-- Entferne Geld von Nationsbank
exports('RemoveMoneyFromNation', function(nationName, amount)
    if not nationName or not amount or amount <= 0 then
        return false
    end
    
    local result = MySQL.query.await('SELECT bank FROM infinity_nations WHERE name = ?', {nationName})
    if not result or #result == 0 then
        return false
    end
    
    if result[1].bank < amount then
        return false
    end
    
    MySQL.update.await('UPDATE infinity_nations SET bank = bank - ? WHERE name = ?', {
        amount,
        nationName
    })
    
    print('^2[Infinity Nations]^7 $' .. amount .. ' von Nation ' .. nationName .. ' entfernt')
    return true
end)

-- Hole Stadtinfo
exports('GetTownInfo', function(townName)
    local result = MySQL.query.await('SELECT * FROM infinity_towns WHERE name = ?', {townName})
    if not result or #result == 0 then
        return nil
    end
    return result[1]
end)

-- Hole Nationsinfo
exports('GetNationInfo', function(nationName)
    local result = MySQL.query.await('SELECT * FROM infinity_nations WHERE name = ?', {nationName})
    if not result or #result == 0 then
        return nil
    end
    return result[1]
end)

-- Prüfe ob Spieler Bürger einer Stadt ist
exports('IsCitizen', function(source)
    return citizens[source] ~= nil
end)

-- Hole Spieler Stadt
exports('GetPlayerTown', function(source)
    if not citizens[source] then
        return nil
    end
    
    for _, town in pairs(towns) do
        if town.id == citizens[source].town_id then
            return town.name
        end
    end
    
    return nil
end)

-- Hole Spieler Nation
exports('GetPlayerNation', function(source)
    if not citizens[source] then
        return nil
    end
    
    local town = nil
    for _, t in pairs(towns) do
        if t.id == citizens[source].town_id then
            town = t
            break
        end
    end
    
    if not town then
        return nil
    end
    
    for _, nation in pairs(nations) do
        if nation.id == town.nation_id then
            return nation.name
        end
    end
    
    return nil
end)

print('^2[Infinity Nations]^7 Exports geladen')
