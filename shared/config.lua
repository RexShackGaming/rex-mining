Config = {}

Config.MiningTime   = 10000 -- ms
Config.CooldownTime = 180000 -- ms
Config.RequiredItem = 'pickaxe' -- required item for mining
Config.GemChance    = 15 -- percentage chance (0-100)
Config.NotificationDuration = 5000 -- ms
Config.RockDriller = `p_drillpress01x` -- rock driller prop model
Config.DrillTime = 10000 -- time in ms for each rock to be drilled (10 seconds)

-- Mining Locations
Config.MiningZones = {
    { coords = vec3(2777.56, 1390.70, 70.09), radius = 2.0, type = 'rock' },
    { coords = vec3(2770.90, 1382.09, 67.83), radius = 2.0, type = 'rock' },
    { coords = vec3(2763.46, 1376.82, 67.87), radius = 2.0, type = 'rock' },
    { coords = vec3(2778.02, 1374.11, 67.97), radius = 2.0, type = 'saltrock' },
}

---------------------------------------------
-- rock drilling locations
---------------------------------------------
Config.WorkshopTents = {
    {
        drillid = 'valentinedrill',
        coords = vector4(-294.09, 974.43, 133.44, 339.37),
        blipsprite = 'blip_mp_ugc',
        blipscale = 0.2,
        blipname = 'Valentine Rock Drilling',
        showblip = true
    },
    {
        drillid = 'blackwaterdrill',
        coords = vector4(-783.67, -1504.29, 60.52, 247.55),
        blipsprite = 'blip_mp_ugc',
        blipscale = 0.2,
        blipname = 'Blackwater Rock Drilling',
        showblip = true
    },
    {
        drillid = 'tumbleweeddrill',
        coords = vector4(-5508.19, -3060.70, -2.68, 95.81),
        blipsprite = 'blip_mp_ugc',
        blipscale = 0.2,
        blipname = 'Tumbleweed Rock Drilling',
        showblip = true
    },
    {
        drillid = 'vanhorndrill',
        coords = vector4(2902.12, 544.82, 56.65, 229.91),
        blipsprite = 'blip_mp_ugc',
        blipscale = 0.2,
        blipname = 'Van-Horn Rock Drilling',
        showblip = true
    },
    {
        drillid = 'guarmadrill',
        coords = vector4(1338.89, -7380.62, 101.63, 138.06),
        blipsprite = 'blip_mp_ugc',
        blipscale = 0.2,
        blipname = 'Guarma Rock Drilling',
        showblip = false
    },
}

-- rewards setup
Config.Rewards = {
    ['rock']     = { item = 'rock',     minAmount = 1, maxAmount = 3 },
    ['saltrock'] = { item = 'saltrock', minAmount = 1, maxAmount = 2 }
}

---------------------------------------------
-- rock random outputs
---------------------------------------------
Config.RockOutputs = {
    'clay',
    'coal',
    'copper',
    'iron',
    'nitrite',
    'sulfur',
    'zinc',
    'lead'
}

---------------------------------------------
-- salt rock random outputs
---------------------------------------------
Config.SaltRockOutputs = {
    'salt'
}

---------------------------------------------
-- rare gem random outputs
---------------------------------------------
Config.GemOutputs = {
    'diamond_uncut',
    'ruby_uncut',
    'emerald_uncut',
    'opal_uncut',
    'sapphire_uncut'
}
