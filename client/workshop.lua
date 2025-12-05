local RSGCore = exports['rsg-core']:GetCoreObject()
local campSpawned = false
local SpawnedDrillCampBlips = {}
lib.locale()

--------------------------------------
-- blips
--------------------------------------
CreateThread(function()
    for _, v in pairs(Config.WorkshopTents) do
        if v.showblip then
            local DrillCampBlip = BlipAddForCoords(1664425300, v.blipcoords)
            SetBlipSprite(DrillCampBlip, joaat(v.blipsprite), true)
            SetBlipScale(DrillCampBlip, v.blipscale)
            SetBlipName(DrillCampBlip, v.blipname)
            SpawnedDrillCampBlips[#SpawnedDrillCampBlips + 1] = DrillCampBlip
        end
    end
end)

--------------------------------------
-- spawn drill camp
--------------------------------------
local spawnCamp = function()
    if campSpawned then
        Citizen.InvokeNative(0x58AC173A55D9D7B4, campSpawned)
        Wait(250)
    else
        local propsetName = "pg_mp_workshop03x"
        local propsetHash = GetHashKey(propsetName)

        Citizen.InvokeNative(0xF3DE57A46D5585E9, propsetHash)
        while not Citizen.InvokeNative(0x48A88FC684C55FDC, propsetHash) do
            Wait(50)
        end

        if Citizen.InvokeNative(0x48A88FC684C55FDC, propsetHash) then
            for k,v in pairs(Config.WorkshopTents) do
                campSpawned = Citizen.InvokeNative(
                    0x899C97A1CCE7D483,
                    propsetHash,
                    v.coords.x,
                    v.coords.y,
                    v.coords.z,
                    0,
                    v.coords.w,
                    1200.0,
                    false,
                    true
                )
            end
        end
        Citizen.InvokeNative(0xB1964A83B345B4AB, propsetHash)
    end
end

CreateThread(function()
    Wait(5000)
    spawnCamp()
end)

---------------------------------------------
-- target for use drill
---------------------------------------------
CreateThread(function()
    for _, v in pairs(Config.WorkshopTents) do
        exports.ox_target:addModel(v.drillmodel, {
            {
                name = 'miningdrill',
                icon = 'far fa-eye',
                label = locale('cl_lang_6'),
                onSelect = function()
                    TriggerEvent('rex-mining:client:drillrocksinput', v.jobaccess)
                end,
                distance = 2.0
            }
        })
    end
end)

---------------------------------------------
-- choose between rock / saltrock amount
---------------------------------------------
RegisterNetEvent('rex-mining:client:drillrocksinput', function(jobaccess)
    local PlayerData = RSGCore.Functions.GetPlayerData()
    local playerjob = PlayerData.job.name

    if playerjob ~= jobaccess then
        lib.notify({ title = locale('cl_lang_16'), duration = Config.NotificationDuration, type = 'error' })
        return
    end

    local input = lib.inputDialog('Drill Rocks', {
        { 
            type = 'select',
            default = 'rock',
            options = {
                { label = locale('cl_lang_7'), value = 'rock' },
                { label = locale('cl_lang_8'), value = 'saltrock' }
            },
            required = true
        },
        { 
            type = 'number',
            label = locale('cl_lang_9'),
            default = 1,
            min = 1,
            max = 100,
            required = true
        },
    })
    if not input then return end
    
    local amount = tonumber(input[2])
    if not amount or amount < 1 or amount > 100 then
        lib.notify({ title = locale('cl_lang_13'), duration = Config.NotificationDuration, type = 'error' })
        return
    end
    
    local hasItem = RSGCore.Functions.HasItem(input[1], amount)
    if not hasItem then 
        lib.notify({ title = locale('cl_lang_10'), duration = Config.NotificationDuration, type = 'error' }) 
        return
    end
    TriggerEvent('rex-mining:client:dodrilling', input[1], amount)
end)

----------------------------------------------------
-- drill rocks function
----------------------------------------------------
local function DrillingRocks(item, amount)
    local totalAmount = amount
    local DrillingRemaining = amount
    CreateThread(function()
        while DrillingRemaining > 0 do
            LocalPlayer.state:set("inv_busy", true, true) -- lock inventory
            local currentDrill = totalAmount - DrillingRemaining + 1
            local progressLabel = locale('cl_lang_14'):format(currentDrill, totalAmount)
            
            local success = lib.progressBar({
                duration = Config.DrillTime,
                position = 'bottom',
                useWhileDead = false,
                canCancel = true,
                disableControl = true,
                disable = {
                    move = true,
                    mouse = false,
                },
                label = progressLabel,
                anim = {
                    dict = 'mech_inventory@crafting@fallbacks',
                    clip = 'full_craft_and_stow',
                    flag = 27,
                },
            })
            
            if not success then
                LocalPlayer.state:set("inv_busy", false, true)
                return
            end
            
            DrillingRemaining = DrillingRemaining - 1
            TriggerServerEvent('rex-mining:server:finishdrilling', item)
            Wait(100)
        end
        LocalPlayer.state:set("inv_busy", false, true) -- unlock inventory
    end)
end

---------------------------------------------
-- drill them rocks
---------------------------------------------
RegisterNetEvent('rex-mining:client:dodrilling', function(item, amount)
    local hasItem = RSGCore.Functions.HasItem(item, amount)
    if hasItem then
        DrillingRocks(item, amount)
    else
        lib.notify({ title = locale('cl_lang_10'), duration = Config.NotificationDuration, type = 'error' })
    end
end)
