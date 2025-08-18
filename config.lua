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
Config.EnableVegModifier = true -- if set true clears vegetation
Config.RockProp = `mp_sca_rock_grp_l_03` -- rock prop
Config.SaltRockProp = `mp_sca_rock_grp_l_03` -- rock prop
Config.RockDriller = `p_drillpress01x` -- rock driller
Config.MiningTime = 10000 -- time player mines with pickaxe
Config.DrillTime = 10000 -- time for each rock to be drilled
Config.GemChance = 5 -- 5% chance of getting a rare gemstone

---------------------------------------------
-- cronjob
---------------------------------------------
Config.MiningCronJob = '*/5 * * * *' -- reset rocks every 5 mins
Config.ServerNotify  = false

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
        blipname = 'Valentine Rock Drilling',
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
