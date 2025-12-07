Config = {}

---------------------------------
-- settings
---------------------------------
Config.MiningTime              = 10000 -- ms
Config.CooldownTime            = 180000 -- ms
Config.RequiredItem            = 'pickaxe' -- required item for mining
Config.GemChance               = 15 -- percentage chance (0-100)
Config.NotificationDuration    = 5000 -- ms
Config.RockDriller             = `p_drillpress01x` -- rock driller prop model
Config.DrillTime               = 10000 -- time in ms for each rock to be drilled (10 seconds)
Config.JobLockMining           = false -- toggle on/off job requirement for mining
Config.RecruitStorageMaxWeight = 4000000
Config.RecruitStorageMaxSlots  = 100
Config.MinerStorageMaxWeight   = 4000000
Config.MinerStorageMaxSlots    = 100

---------------------------------
-- npc settings
---------------------------------
Config.DistanceSpawn = 20.0
Config.FadeIn = true

--------------------------------
-- Mining Locations
--------------------------------
Config.MiningZones = {
    --------------------------
    -- annesburg mine
    --------------------------
    { coords = vec3(2791.4697265625, 1345.1380615234376, 71.91378021240235),    radius = 2.0, type = 'rock' },
    { coords = vec3(2793.626708984375, 1336.0570068359376, 71.92117309570313),  radius = 2.0, type = 'rock' },
    { coords = vec3(2780.24169921875, 1335.8101806640626, 71.5442886352539),    radius = 2.0, type = 'rock' },
    { coords = vec3(2767.23388671875, 1337.0699462890626, 70.95378112792969),   radius = 2.0, type = 'saltrock' },
    { coords = vec3(2765.5029296875, 1335.658447265625, 70.78048706054688),     radius = 2.0, type = 'rock' },
    { coords = vec3(2761.82861328125, 1331.6224365234376, 70.52594757080078),   radius = 2.0, type = 'rock' },
    { coords = vec3(2752.021484375, 1332.12109375, 70.63470458984375),          radius = 2.0, type = 'rock' },
    { coords = vec3(2741.38134765625, 1319.45458984375, 70.48382568359375),     radius = 2.0, type = 'saltrock' },
    { coords = vec3(2745.58837890625, 1325.2091064453126, 70.48372650146485),   radius = 2.0, type = 'rock' },
    { coords = vec3(2761.119384765625, 1310.7445068359376, 70.49114227294922),  radius = 2.0, type = 'rock' },
    { coords = vec3(2760.796142578125, 1304.12744140625, 70.49578857421875),    radius = 2.0, type = 'rock' },
    { coords = vec3(2755.88916015625, 1301.888427734375, 70.4975814819336),     radius = 2.0, type = 'saltrock' },
    { coords = vec3(2738.291748046875, 1309.3807373046876, 70.39374542236328),  radius = 2.0, type = 'rock' },
    { coords = vec3(2735.927978515625, 1309.5782470703126, 70.37593078613281),  radius = 2.0, type = 'rock' },
    { coords = vec3(2718.755859375, 1307.8685302734376, 70.2322006225586),      radius = 2.0, type = 'rock' },
    { coords = vec3(2713.54052734375, 1308.1812744140626, 70.25575256347656),   radius = 2.0, type = 'saltrock' },
    { coords = vec3(2711.83154296875, 1314.4696044921876, 70.2629165649414),    radius = 2.0, type = 'rock' },
    { coords = vec3(2716.714599609375, 1314.705810546875, 70.26507568359375),   radius = 2.0, type = 'rock' },
    { coords = vec3(2727.734375, 1319.8328857421876, 70.22930908203125),        radius = 2.0, type = 'rock' },
    { coords = vec3(2731.578369140625, 1318.081298828125, 70.22589111328125),   radius = 2.0, type = 'saltrock' },
    { coords = vec3(2736.048583984375, 1322.33984375, 70.19818878173828),       radius = 2.0, type = 'rock' },
    { coords = vec3(2733.84033203125, 1328.4901123046876, 70.18203735351563),   radius = 2.0, type = 'rock' },
    { coords = vec3(2728.3525390625, 1329.7330322265626, 70.15768432617188),    radius = 2.0, type = 'rock' },
    { coords = vec3(2731.616455078125, 1332.7449951171876, 70.17938232421875),  radius = 2.0, type = 'saltrock' },
    { coords = vec3(2739.888427734375, 1339.1622314453126, 69.70467376708985),  radius = 2.0, type = 'rock' },
    { coords = vec3(2742.882568359375, 1347.59521484375, 68.63679504394531),    radius = 2.0, type = 'rock' },
    { coords = vec3(2749.873779296875, 1347.125244140625, 69.15619659423828),   radius = 2.0, type = 'rock' },
    { coords = vec3(2765.419921875, 1351.198974609375, 71.07604217529297),      radius = 2.0, type = 'saltrock' },
    { coords = vec3(2761.34619140625, 1358.7442626953126, 70.99369049072266),   radius = 2.0, type = 'rock' },
    { coords = vec3(2765.982177734375, 1366.232177734375, 71.02310943603516),   radius = 2.0, type = 'rock' },
    { coords = vec3(2763.967529296875, 1364.6925048828126, 71.0881118774414),   radius = 2.0, type = 'rock' },
    { coords = vec3(2779.3095703125, 1371.5987548828126, 68.38038635253906),    radius = 2.0, type = 'saltrock' },
    { coords = vec3(2778.156005859375, 1381.4931640625, 68.48554992675781),     radius = 2.0, type = 'rock' },
    { coords = vec3(2779.03076171875, 1377.4268798828126, 68.3793716430664),    radius = 2.0, type = 'rock' },
    { coords = vec3(2772.770751953125, 1368.3590087890626, 68.31623840332031),  radius = 2.0, type = 'rock' },
    { coords = vec3(2753.31103515625, 1368.2064208984376, 68.40861511230469),   radius = 2.0, type = 'saltrock' },
    { coords = vec3(2746.0869140625, 1366.9554443359376, 68.78707122802735),    radius = 2.0, type = 'rock' },
    { coords = vec3(2740.212158203125, 1369.9141845703126, 69.02835083007813),  radius = 2.0, type = 'rock' },
    { coords = vec3(2737.818115234375, 1356.1986083984376, 68.78072357177735),  radius = 2.0, type = 'rock' },
    { coords = vec3(2740.609130859375, 1377.5894775390626, 69.14989471435547),  radius = 2.0, type = 'saltrock' },
    { coords = vec3(2743.1064453125, 1384.3988037109376, 69.06208038330078),    radius = 2.0, type = 'rock' },
    { coords = vec3(2742.830810546875, 1396.9949951171876, 69.29539489746094),  radius = 2.0, type = 'rock' },
    { coords = vec3(2724.53515625, 1391.2403564453126, 69.29977416992188),      radius = 2.0, type = 'rock' },
    { coords = vec3(2724.401611328125, 1397.712890625, 69.2967300415039),       radius = 2.0, type = 'saltrock' },
    --------------------------
    -- gaptooth mine
    --------------------------
    { coords = vec3(-5962.111328125, -3218.07666015625, -21.03051567077636),    radius = 2.0, type = 'rock' },
    { coords = vec3(-5961.6826171875, -3211.577392578125, -21.02172470092773),  radius = 2.0, type = 'rock' },
    { coords = vec3(-5967.36083984375, -3204.54345703125, -20.88662719726562),  radius = 2.0, type = 'rock' },
    { coords = vec3(-5960.54248046875, -3192.346923828125, -21.10622787475586), radius = 2.0, type = 'saltrock' },
    { coords = vec3(-5958.52783203125, -3188.994873046875, -21.13970375061035), radius = 2.0, type = 'rock' },
    { coords = vec3(-5955.8564453125, -3180.30517578125, -21.84871482849121),   radius = 2.0, type = 'rock' },
    { coords = vec3(-5961.78515625, -3173.27001953125, -22.58561706542968),     radius = 2.0, type = 'rock' },
    { coords = vec3(-5966.97900390625, -3172.76513671875, -23.5033893585205),   radius = 2.0, type = 'saltrock' },
    { coords = vec3(-5969.8837890625, -3170.76806640625, -24.24051094055175),   radius = 2.0, type = 'rock' },
    { coords = vec3(-5975.6240234375, -3167.875732421875, -25.00465202331543),  radius = 2.0, type = 'rock' },
    { coords = vec3(-5979.07958984375, -3165.752685546875, -25.97180366516113), radius = 2.0, type = 'rock' },
    { coords = vec3(-5981.2080078125, -3161.576904296875, -26.08867454528808),  radius = 2.0, type = 'saltrock' },
    { coords = vec3(-5976.26123046875, -3219.142822265625, -21.04885864257812), radius = 2.0, type = 'rock' },
    { coords = vec3(-5969.7919921875, -3214.953369140625, -21.09965133666992),  radius = 2.0, type = 'rock' },
    { coords = vec3(-5972.939453125, -3205.176025390625, -18.96175765991211),   radius = 2.0, type = 'rock' },
    { coords = vec3(-5962.1748046875, -3222.4931640625, -21.0845890045166),     radius = 2.0, type = 'saltrock' },
    { coords = vec3(-5962.7822265625, -3224.797607421875, -21.09444236755371),  radius = 2.0, type = 'rock' },
    { coords = vec3(-5957.90869140625, -3234.35009765625, -19.95751953125),     radius = 2.0, type = 'rock' },
    { coords = vec3(-5955.3564453125, -3243.451904296875, -21.04887962341308),  radius = 2.0, type = 'rock' },
    { coords = vec3(-5964.81689453125, -3195.2392578125, -21.07339096069336),   radius = 2.0, type = 'rock' },
}

---------------------------------------------
-- rock drilling locations
---------------------------------------------
Config.WorkshopTents = {
    {
        mineid = 'annesburgmine',
        name = 'Annesburg Mining Camp',
        coords = vector4(2818.82, 1359.12, 70.62, 236.61),
        blipcoords = vector3(2818.82, 1359.12, 70.62),
        blipsprite = 'blip_region_caravan',
        blipscale = 0.2,
        blipname = 'Annesburg Mining Camp',
        drillmodel = `p_drillpress01x`,
        npcmodel = `u_m_m_bht_mineforeman`,
        npccoords = vector4(2818.06, 1360.32, 70.68, 45.27),
        scenario = 'WORLD_HUMAN_CLIPBOARD',
        jobaccess = 'annesburgminer',
        showblip = true
    },
    {
        mineid = 'gaptoothmine',
        name = 'Gaptooth Mining Camp',
        coords = vector4(-5972.25, -3240.97, -21.65, 156.29),
        blipcoords = vector3(-5972.25, -3240.97, -21.65),
        blipsprite = 'blip_region_caravan',
        blipscale = 0.2,
        blipname = 'Gaptooth Mining Camp',
        drillmodel = `p_drillpress01x`,
        npcmodel = `u_m_m_bht_mineforeman`,
        npccoords = vector4(-5970.84, -3240.00, -21.65, 339.70),
        scenario = 'WORLD_HUMAN_CLIPBOARD',
        jobaccess = 'gaptoothminer',
        showblip = true
    },
}

--------------------------------
-- rewards setup
--------------------------------
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
    'nitrate',
    'sulfur',
    'zinc',
    'lead',
    'gold',
    'silver'
}

---------------------------------------------
-- salt rock random outputs
---------------------------------------------
Config.SaltRockOutputs = {
    'salt',
    'nitrate',
    'sulfur'
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
