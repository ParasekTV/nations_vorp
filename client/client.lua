local VORPcore = {}
local prompts = {}
local currentTown = nil
local playerData = {}

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

-- Erstelle Prompts
CreateThread(function()
    Wait(1000)
    
    for _, town in pairs(Config.Towns) do
        local promptGroup = GetRandomIntInRange(0, 0xffffff)
        local prompt = PromptRegisterBegin()
        
        PromptSetControlAction(prompt, 0x760A9C6F) -- G Key
        local label = CreateVarString(10, 'LITERAL_STRING', _T('open_menu'))
        PromptSetText(prompt, label)
        PromptSetEnabled(prompt, 1)
        PromptSetVisible(prompt, 1)
        PromptSetStandardMode(prompt, 1)
        PromptSetGroup(prompt, promptGroup)
        PromptRegisterEnd(prompt)
        
        prompts[town.name] = {
            prompt = prompt,
            group = promptGroup,
            coords = town.coords
        }
    end
end)

-- Hauptloop
CreateThread(function()
    while true do
        local sleep = 1000
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        
        for townName, promptData in pairs(prompts) do
            local distance = #(playerCoords - promptData.coords)
            
            if distance < Config.DrawMarkerDistance then
                sleep = 0
                
                if distance < Config.CheckDistance then
                    PromptSetActiveGroupThisFrame(promptData.group, CreateVarString(10, 'LITERAL_STRING', townName))
                    
                    if PromptHasStandardModeCompleted(promptData.prompt) then
                        OpenTownMenu(townName)
                    end
                end
            end
        end
        
        Wait(sleep)
    end
end)

-- Öffne Stadtmenü
function OpenTownMenu(townName)
    currentTown = townName
    TriggerServerEvent('infinity_nations:requestTownInfo', townName)
end

-- Empfange Stadtinfo
RegisterNetEvent('infinity_nations:receiveTownInfo')
AddEventHandler('infinity_nations:receiveTownInfo', function(data)
    playerData = data
    
    -- Debug Logs
    print('^3[Infinity Nations Client]^7 Stadtinfo empfangen:')
    print('^3  Stadt:^7 ' .. data.town.name)
    print('^3  Is Citizen:^7 ' .. tostring(data.isCitizen))
    print('^3  Is Mayor:^7 ' .. tostring(data.isMayor))
    print('^3  Is Governor:^7 ' .. tostring(data.isGovernor))
    if data.town.mayor_id then
        print('^3  Mayor ID:^7 ' .. data.town.mayor_id)
    end
    
    -- Bereite Daten für NUI vor
    local nuiData = {
        action = 'openMenu',
        data = {
            town = data.town,
            nation = data.nation,
            citizenCount = data.citizenCount,
            isCitizen = data.isCitizen,
            isMayor = data.isMayor,
            isGovernor = data.isGovernor,
            mayorName = data.mayorName,
            governorName = data.governorName
        }
    }
    
    print('^3[Infinity Nations Client]^7 Sende an NUI:')
    print('^3  isCitizen:^7 ' .. tostring(nuiData.data.isCitizen))
    print('^3  isMayor:^7 ' .. tostring(nuiData.data.isMayor))
    print('^3  isGovernor:^7 ' .. tostring(nuiData.data.isGovernor))
    
    SendNUIMessage(nuiData)
    SetNuiFocus(true, true)
end)

-- NUI Callbacks
RegisterNUICallback('close', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('joinTown', function(data, cb)
    TriggerServerEvent('infinity_nations:joinTown', currentTown)
    -- UI schließen und NUI-Focus deaktivieren
    SendNUIMessage({ action = 'closeMenu' })
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('leaveTown', function(data, cb)
    TriggerServerEvent('infinity_nations:leaveTown')
    -- UI schließen und NUI-Focus deaktivieren
    SendNUIMessage({ action = 'closeMenu' })
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('claimReward', function(data, cb)
    TriggerServerEvent('infinity_nations:claimReward')
    cb('ok')
end)

RegisterNUICallback('updateTax', function(data, cb)
    -- Nur für Bürgermeister
    if playerData.isMayor then
        TriggerServerEvent('infinity_nations:updateTax', currentTown, data.taxType, data.value)
    end
    cb('ok')
end)

RegisterNUICallback('withdrawMoney', function(data, cb)
    if playerData.isMayor then
        TriggerServerEvent('infinity_nations:withdrawMoney', currentTown, data.amount)
        SetNuiFocus(false, false)
    end
    cb('ok')
end)

RegisterNUICallback('depositMoney', function(data, cb)
    if playerData.isMayor then
        TriggerServerEvent('infinity_nations:depositMoney', currentTown, data.amount)
        SetNuiFocus(false, false)
    end
    cb('ok')
end)

RegisterNUICallback('updateNationTax', function(data, cb)
    if playerData.isGovernor then
        TriggerServerEvent('infinity_nations:governor_updateTax', data.nationId, data.taxRate)
    end
    cb('ok')
end)

RegisterNUICallback('governorWithdrawMoney', function(data, cb)
    if playerData.isGovernor then
        TriggerServerEvent('infinity_nations:governor_withdrawMoney', data.nationId, data.amount)
        SetNuiFocus(false, false)
    end
    cb('ok')
end)

RegisterNUICallback('governorDepositMoney', function(data, cb)
    if playerData.isGovernor then
        TriggerServerEvent('infinity_nations:governor_depositMoney', data.nationId, data.amount)
        SetNuiFocus(false, false)
    end
    cb('ok')
end)

-- Update Bürgerschaft
RegisterNetEvent('infinity_nations:updateCitizenship')
AddEventHandler('infinity_nations:updateCitizenship', function()
    if currentTown then
        TriggerServerEvent('infinity_nations:requestTownInfo', currentTown)
    end
end)

-- Erstelle Blips
CreateThread(function()
    Wait(2000)
    
    for _, town in pairs(Config.Towns) do
        local blip = Citizen.InvokeNative(0x554D9D53F696D002, 1664425300, town.coords) -- BlipAddForCoords
        SetBlipSprite(blip, GetHashKey(town.blip.sprite), 1)
        Citizen.InvokeNative(0x9CB1A1623062F402, blip, town.blip.name) -- SetBlipName
    end
end)

-- DEBUG BEFEHL: Test UI mit Fake-Daten
RegisterCommand('testmayorui', function()
    print('^3[Client Test]^7 Öffne UI mit Test-Daten (isMayor = true)')
    
    SendNUIMessage({
        action = 'openMenu',
        data = {
            town = {
                name = 'TEST TOWN',
                bank = 10000,
                bank_tax = 5,
                city_tax = 10,
                entry_fee = 50,
                max_population = 100,
                reward_money = 25,
                reward_xp = 10,
                motd = 'Test Nachricht',
                mayor_id = 'test123'
            },
            nation = {
                name = 'TEST NATION',
                bank = 50000,
                tax_rate = 5
            },
            citizenCount = 25,
            isCitizen = true,
            isMayor = true,  -- WICHTIG: TRUE!
            isGovernor = false,
            mayorName = 'Test Mayor',
            governorName = 'Test Governor'
        }
    })
    SetNuiFocus(true, true)
end, false)

print('^2[Infinity Nations]^7 Client erfolgreich gestartet')
