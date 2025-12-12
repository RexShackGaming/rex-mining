local RSGCore = exports['rsg-core']:GetCoreObject()
local isMining = false
local isBusy = false
local mineAnimation = 'amb_work@world_human_pickaxe@wall@male_d@base'
local anim = 'base'
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
-- animation loading
-----------------------------------------------
local LoadAnimDict = function(dict)
    local isLoaded = HasAnimDictLoaded(dict)
    while not isLoaded do
        RequestAnimDict(dict)
        Wait(0)
        isLoaded = not isLoaded
    end
end

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
            -- do mining
            SetCurrentPedWeapon(cache.ped, `WEAPON_UNARMED`, true)
            if not IsPedMale(cache.ped) then
                -- female ped
                isBusy = true
                local coords = GetEntityCoords(cache.ped)
                local boneIndex = GetEntityBoneIndexByName(cache.ped, 'SKEL_R_Finger00')
                local pickaxe = CreateObject(joaat('p_pickaxe01x'), coords, true, true, true)
                SetCurrentPedWeapon(cache.ped, "WEAPON_UNARMED", true)
                FreezeEntityPosition(cache.ped, true)
                ClearPedTasksImmediately(cache.ped)
                AttachEntityToEntity(pickaxe, cache.ped, boneIndex, -0.35, -0.21, -0.39, -8.0, 47.0, 11.0, true, false, true, false, 0, true)
                TriggerEvent('rex-mining:client:animation')
                Wait(Config.MiningTime)
                ClearPedTasksImmediately(cache.ped)
                FreezeEntityPosition(cache.ped, false)
                SetEntityAsNoLongerNeeded(pickaxe)
                DeleteEntity(pickaxe)
                SetCurrentPedWeapon(cache.ped, `WEAPON_UNARMED`, true)
                FinishMining(true, oreType, zoneKey)
                isBusy = false
            else
                -- male ped
                isBusy = true
                SetCurrentPedWeapon(cache.ped, "WEAPON_UNARMED", true)
                FreezeEntityPosition(cache.ped, true)
                ClearPedTasksImmediately(cache.ped)
                TaskStartScenarioInPlace(cache.ped, joaat('WORLD_HUMAN_PICKAXE_WALL'), Config.MiningTime, true, false, false, false)
                Wait(Config.MiningTime)
                ClearPedTasksImmediately(cache.ped)
                FreezeEntityPosition(cache.ped, false)
                SetCurrentPedWeapon(cache.ped, `WEAPON_UNARMED`, true)
                FinishMining(true, oreType, zoneKey)
                isBusy = false
            end
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

---------------------------------------------
-- used for female mining animation
---------------------------------------------
AddEventHandler('rex-mining:client:animation', function()
    LoadAnimDict(mineAnimation)
    while not HasAnimDictLoaded(mineAnimation) do
        Wait(100)
    end
    TaskPlayAnim(cache.ped, mineAnimation, anim, 3.0, 3.0, -1, 1, 0, false, false, false)
end)

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

-----------------------------------------------
-- spawn rocks
-----------------------------------------------
local spawnedObjects = {}

-- function to spawn a single rock
local function SpawnRock(coords)
    local modelHash = GetHashKey("mp_sca_rock_grp_l_03")

    -- request the model
    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do
        Wait(10)
    end

    -- create the object
    local obj = CreateObject(modelHash, coords.x, coords.y, coords.z - 1.5, false, false, false)

    FreezeEntityPosition(obj, true)
    SetEntityAsMissionEntity(obj, true, true)

    table.insert(spawnedObjects, obj)
end

-- spawn all rocks from config when resource starts
Citizen.CreateThread(function()
    for _, rock in ipairs(Config.MiningZones) do
        SpawnRock(rock.coords)
    end
end)

-- clean up on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    for _, obj in ipairs(spawnedObjects) do
        if DoesEntityExist(obj) then
            DeleteEntity(obj)
        end
    end
end)

---------------------------------------------
-- mining main menu selector
---------------------------------------------
RegisterNetEvent('rex-mining:client:miningmenu', function(mineid, jobaccess)
    if Config.JobLockMining then
        local PlayerData = RSGCore.Functions.GetPlayerData()
        local playerjob = PlayerData.job.name
        local playerlevel = PlayerData.job.grade.level
        if playerjob ~= jobaccess then
            lib.notify({ title = locale('cl_lang_16'), duration = Config.NotificationDuration, type = 'error' })
            return
        end
        if playerlevel == 0 then
            TriggerEvent('rex-mining:client:openRecruitMenu', mineid)
        end
        if playerlevel == 1 then
            TriggerEvent('rex-mining:client:openMinerMenu', mineid)
        end
        if playerlevel == 2 then
            TriggerEvent('rex-mining:client:openFormanMenu', mineid)
        end
    else
        TriggerEvent('rex-mining:client:drillrocksinput')
    end
end)

---------------------------------------------
-- recruit menu
---------------------------------------------
RegisterNetEvent('rex-mining:client:openRecruitMenu', function(mineid)
    lib.registerContext(
        {
            id = 'mining_recruit_menu',
            title = locale('cl_lang_18'),
            position = 'top-right',
            options = {
                {   title = locale('cl_lang_19'),
                    description = locale('cl_lang_20'),
                    icon = 'box-open',
                    onSelect = function()
                        TriggerServerEvent('rex-mining:server:openRecruitStorage', 'recruit_'..mineid)
                    end
                },
            }
        }
    )
    lib.showContext('mining_recruit_menu')
end)

---------------------------------------------
-- miner menu
---------------------------------------------
RegisterNetEvent('rex-mining:client:openMinerMenu', function(mineid)
    lib.registerContext(
        {
            id = 'mining_miner_menu',
            title = locale('cl_lang_21'),
            position = 'top-right',
            options = {
                {   title = locale('cl_lang_22'),
                    description = locale('cl_lang_23'),
                    icon = 'fa-solid fa-bore-hole',
                    event = 'rex-mining:client:drillrocksinput',
                },
                {   title = locale('cl_lang_24'),
                    description = locale('cl_lang_25'),
                    icon = 'box-open',
                    onSelect = function()
                        TriggerServerEvent('rex-mining:server:openRecruitStorage', 'recruit_'..mineid)
                    end
                },
                {   title = locale('cl_lang_26'),
                    description = locale('cl_lang_27'),
                    icon = 'box-open',
                    onSelect = function()
                        TriggerServerEvent('rex-mining:server:openMinerStorage', 'miners_'..mineid)
                    end
                },
            }
        }
    )
    lib.showContext('mining_miner_menu')
end)

---------------------------------------------
-- forman menu
---------------------------------------------
RegisterNetEvent('rex-mining:client:openFormanMenu', function(mineid)
    lib.registerContext(
        {
            id = 'mining_forman_menu',
            title = locale('cl_lang_28'),
            position = 'top-right',
            options = {
                {   title = locale('cl_lang_22'),
                    description = locale('cl_lang_23'),
                    icon = 'fa-solid fa-bore-hole',
                    event = 'rex-mining:client:drillrocksinput',
                },
                {   title = locale('cl_lang_29'),
                    description = locale('cl_lang_30'),
                    icon = 'fa-solid fa-user-tie',
                    event = 'rsg-bossmenu:client:mainmenu',
                },
                {   title = locale('cl_lang_24'),
                    description = locale('cl_lang_25'),
                    icon = 'box-open',
                    onSelect = function()
                        TriggerServerEvent('rex-mining:server:openRecruitStorage', 'recruit_'..mineid)
                    end
                },
                {   title = locale('cl_lang_26'),
                    description = locale('cl_lang_27'),
                    icon = 'box-open',
                    onSelect = function()
                        TriggerServerEvent('rex-mining:server:openMinerStorage', 'miners_'..mineid)
                    end
                },
            }
        }
    )
    lib.showContext('mining_forman_menu')
end)
