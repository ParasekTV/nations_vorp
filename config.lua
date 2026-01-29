Config = {}

-- Sprache
Config.Language = 'de' -- 'de' oder 'en'

-- Performance
Config.CheckDistance = 2.0 -- Distanz zum Interagieren mit Punkten
Config.DrawMarkerDistance = 10.0 -- Distanz zum Anzeigen von Markern

-- Marker Einstellungen
Config.UseMarkers = true
Config.MarkerType = 0x94FDAE17 -- Prompts für RedM
Config.MarkerColor = {r = 255, g = 255, b = 0, a = 200}

-- Steuern
Config.TaxInterval = 60 -- Minuten zwischen Steuererhebungen
Config.MaxPopulation = 100 -- Maximale Bevölkerung pro Stadt (Standard)

-- Belohnungen
Config.DailyRewardEnabled = true
Config.RewardInterval = 1440 -- Minuten (1440 = 24 Stunden)

-- Standardwerte für neue Städte
Config.DefaultValues = {
    BankTax = 5, -- Prozent
    CityTax = 10, -- Dollar pro Intervall
    EntryFee = 50, -- Dollar
    RewardMoney = 25, -- Dollar pro Tag
    RewardXP = 10 -- XP pro Tag
}

-- Admin Gruppen (Wer kann Städte/Nationen erstellen)
Config.AdminGroups = {
    'admin',
    'superadmin'
}

-- Texte
Config.Texts = {
    de = {
        ['open_menu'] = 'Drücke ~COLOR_GOLD~[G]~q~ um das Städtemenü zu öffnen',
        ['not_citizen'] = 'Du bist kein Bürger dieser Stadt',
        ['already_citizen'] = 'Du bist bereits Bürger einer Stadt',
        ['joined_city'] = 'Du bist der Stadt beigetreten: ',
        ['left_city'] = 'Du hast die Stadt verlassen',
        ['not_enough_money'] = 'Du hast nicht genug Geld',
        ['daily_reward'] = 'Tägliche Belohnung erhalten: ',
        ['tax_collected'] = 'Steuern eingezogen: ',
        ['mayor'] = 'Bürgermeister',
        ['governor'] = 'Gouverneur',
        ['citizen_count'] = 'Bürger',
        ['vagabond'] = 'Vagabund',
        ['city_bank'] = 'Stadtbank: $',
        ['nation_bank'] = 'Nationsbank: $'
    },
    en = {
        ['open_menu'] = 'Press ~COLOR_GOLD~[G]~q~ to open town menu',
        ['not_citizen'] = 'You are not a citizen of this town',
        ['already_citizen'] = 'You are already a citizen of a town',
        ['joined_city'] = 'You joined the town: ',
        ['left_city'] = 'You left the town',
        ['not_enough_money'] = 'You don\'t have enough money',
        ['daily_reward'] = 'Daily reward received: ',
        ['tax_collected'] = 'Tax collected: ',
        ['mayor'] = 'Mayor',
        ['governor'] = 'Governor',
        ['citizen_count'] = 'Citizens',
        ['vagabond'] = 'Vagabond',
        ['city_bank'] = 'Town Bank: $',
        ['nation_bank'] = 'Nation Bank: $'
    }
}

-- Städte Positionen (Beispiele)
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
    {
        name = 'Blackwater',
        nation = 'West Elizabeth',
        coords = vector3(-813.82, -1324.66, 43.88),
        blip = {
            sprite = 'blip_proc_home',
            name = 'Blackwater Rathaus'
        }
    },
    {
        name = 'Saint Denis',
        nation = 'Lemoyne',
        coords = vector3(2509.69, -1309.58, 48.95),
        blip = {
            sprite = 'blip_proc_home',
            name = 'Saint Denis Rathaus'
        }
    },
    {
        name = 'Strawberry',
        nation = 'West Elizabeth',
        coords = vector3(-1791.49, -386.87, 160.33),
        blip = {
            sprite = 'blip_proc_home',
            name = 'Strawberry Rathaus'
        }
    },
    {
        name = 'Rhodes',
        nation = 'Lemoyne',
        coords = vector3(1361.06, -1301.71, 77.77),
        blip = {
            sprite = 'blip_proc_home',
            name = 'Rhodes Rathaus'
        }
    }
}

-- Item Belohnungen (optional)
Config.RewardItems = {
    enabled = false,
    items = {
        {name = 'bread', amount = 2},
        {name = 'water', amount = 1}
    }
}
