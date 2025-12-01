local RSGCore = exports['rsg-core']:GetCoreObject()
local isMining = false
local pickaxeProp = nil
local zoneCooldowns = {}
lib.locale()

-----------------------------------------------
-- cleanup pickaxe prop if resource stops
-----------------------------------------------
AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        if pickaxeProp then DeleteObject(pickaxeProp) end
    end
end)

-----------------------------------------------
-- main prompt + cooldown loop
-----------------------------------------------
CreateThread(function()
    while true do
        local sleep = 1000
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local now = GetGameTimer()

        if not isMining then
            for k, v in pairs(Config.MiningZones) do
                local dist = #(playerCoords - v.coords)
                local cooldownEnd = zoneCooldowns[k] or 0
                local onCooldown = now < cooldownEnd

                if dist < 5.0 then
                    sleep = 0

                    if dist < v.radius then
                        if onCooldown then
                            local remaining = math.ceil((cooldownEnd - now) / 1000)
                            lib.showTextUI(locale('cooldown_text') .. ' ' .. remaining .. 's', { position = "left-center" })
                        else
                            lib.showTextUI(locale('prompt_text') .. ' [E]', { position = "left-center" })
                        end

                        if IsControlJustReleased(0, 0xCEFD9220) then -- E key
                            if not onCooldown then
                                AttemptMine(v.type, k)
                            end
                        end
                    else
                        lib.hideTextUI()
                    end
                end
            end
        end
        Wait(sleep)
    end
end)

-----------------------------------------------
-- attempt to start mining
-----------------------------------------------
function AttemptMine(oreType, zoneKey)
    if isMining then return end

    RSGCore.Functions.TriggerCallback('rex-mining:server:HasPickaxe', function(hasItem)
        if hasItem then
            StartMiningAnimation(oreType, zoneKey)
        else
            lib.notify({
                title = 'Mining',
                description = locale('no_pickaxe'),
                type = 'error',
                icon = 'hammer'
            })
        end
    end, Config.RequiredItem)
end

-----------------------------------------------
-- mining animation handler
-----------------------------------------------
function StartMiningAnimation(oreType, zoneKey)
    isMining = true
    lib.hideTextUI()

    if not IsPedMale(cache.ped) then
        -- Female ped animation with pickaxe prop
        local boneIndex = GetEntityBoneIndexByName(cache.ped, 'SKEL_R_Finger00')
        pickaxeProp = CreateObject(joaat('p_pickaxe01x'), GetEntityCoords(cache.ped), true, true, true)
        SetCurrentPedWeapon(cache.ped, "WEAPON_UNARMED", true)
        FreezeEntityPosition(cache.ped, true)
        ClearPedTasksImmediately(cache.ped)
        AttachEntityToEntity(pickaxe, cache.ped, boneIndex, -0.35, -0.21, -0.39, -8.0, 47.0, 11.0, true, false, true, false, 0, true)
        TriggerEvent('rex-mining:client:animation')
        
        Wait(Config.MiningTime)

        ClearPedTasksImmediately(cache.ped)
        FreezeEntityPosition(cache.ped, false)
        SetEntityAsNoLongerNeeded(pickaxeProp)
        DeleteEntity(pickaxeProp)
        pickaxeProp = nil

        FinishMining(true, oreType, zoneKey)
    else
        -- Male ped scenario
        SetCurrentPedWeapon(cache.ped, "WEAPON_UNARMED", true)
        FreezeEntityPosition(cache.ped, true)
        ClearPedTasksImmediately(cache.ped)
        TaskStartScenarioInPlace(cache.ped, joaat('WORLD_HUMAN_PICKAXE_WALL'), Config.MiningTime, true, false, false, false)
        
        Wait(Config.MiningTime)
        
        ClearPedTasksImmediately(cache.ped)
        FreezeEntityPosition(cache.ped, false)
        
        FinishMining(true, oreType, zoneKey)
    end
end

-----------------------------------------------
-- finish mining and apply cooldown
-----------------------------------------------
function FinishMining(success, oreType, zoneKey)
    local playerPed = PlayerPedId()
    
    ClearPedTasks(playerPed)
    if pickaxeProp then 
        DeleteObject(pickaxeProp) 
        pickaxeProp = nil 
    end
    FreezeEntityPosition(playerPed, false)
    isMining = false

    if success then
        -- apply cooldown to this specific zone
        zoneCooldowns[zoneKey] = GetGameTimer() + Config.CooldownTime
        
        TriggerServerEvent('rex-mining:server:MineReward', oreType)
    else
        lib.notify({ 
            title = 'Mining', 
            description = locale('canceled'), 
            type = 'warning' 
        })
    end
end