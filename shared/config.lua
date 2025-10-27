Config = Config or {}
Config.Rocks = {}

---------------------------------------------
-- deploy prop settings
---------------------------------------------
Config.ForwardDistance   = 1.5
Config.PromptGroupName   = 'Place Rock'
Config.PromptCancelName  = 'Cancel'
Config.PromptPlaceName   = 'Place'
Config.PromptRotateLeft  = 'Rotate Left'
Config.PromptRotateRight = 'Rotate Right'

---------------------------------------------
-- settings
---------------------------------------------
Config.EnableVegModifier = true -- clears vegetation around rocks (may impact performance on lower-end systems)
Config.RockProp = `mp_sca_rock_grp_l_03` -- rock prop model
Config.SaltRockProp = `mp_sca_rock_grp_l_03` -- salt rock prop model
Config.RockDriller = `p_drillpress01x` -- rock driller prop model
Config.MiningTime = 10000 -- time in ms for pickaxe mining animation (10 seconds)
Config.DrillTime = 10000 -- time in ms for each rock to be drilled (10 seconds)
Config.GemChance = 5 -- percentage chance of getting a rare gemstone (5% = 1 in 20)
Config.MaxPropsPerPlayer = 10 -- maximum mining nodes a player can place (0 = unlimited)
Config.MinPropDistance = 1.3 -- minimum distance between placed props
Config.NotificationDuration = 7000 -- duration in ms for notifications (7 seconds)

---------------------------------------------
-- cronjob (cron format: minute hour day month weekday)
---------------------------------------------
Config.MiningCronJob = '*/5 * * * *' -- reset rocks every 5 minutes
Config.ServerNotify  = false -- print server console messages for debugging

---------------------------------------------
-- security settings
---------------------------------------------
Config.EnableAdminLogging = true -- log prop creation/destruction for admin audits
Config.MaxMiningDistance = 3.0 -- maximum distance in meters player can be from rock to mine it
Config.DiscordWebhook = '' -- optional: Discord webhook URL for admin logs (leave empty to disable)

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

---------------------------------------------
-- mine locations (add manually)
---------------------------------------------
Config.MineLocations = {
    { 
        name = 'Annesburg Mine',
        prompt = 'annesburgmine',
        coords = vector3(2799.30, 1376.95, 71.30),
        showblip = true
    },
}
