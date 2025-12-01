Config = {}

Config.MiningTime   = 10000 -- ms
Config.CooldownTime = 180000 -- ms
Config.RequiredItem = 'pickaxe'

-- Mining Locations
Config.MiningZones = {
    { coords = vec3(2777.56, 1390.70, 70.09), radius = 2.0, type = 'rock' },
    { coords = vec3(2770.90, 1382.09, 67.83), radius = 2.0, type = 'rock' },
    { coords = vec3(2763.46, 1376.82, 67.87), radius = 2.0, type = 'rock' },
    { coords = vec3(2778.02, 1374.11, 67.97), radius = 2.0, type = 'saltrock' },
}

-- rewards setup
Config.Rewards = {
    ['rock']     = { item = 'rock',     minAmount = 1, maxAmount = 3 },
    ['saltrock'] = { item = 'saltrock', minAmount = 1, maxAmount = 2 }
}
