local RSGCore = exports['rsg-core']:GetCoreObject()
local SpawnedProps = {}
local isBusy = false
local mineAnimation = 'amb_work@world_human_pickaxe@wall@male_d@base'
local anim = 'base'
lib.locale()

--------------------------------------
-- blips manually setin the config
--------------------------------------
CreateThread(function()
    for _,v in pairs(Config.WorkshopTents) do
        if v.showblip == true then    
            local MineBlip = BlipAddForCoords(1664425300, v.coords)
            SetBlipSprite(MineBlip, joaat('blip_poi'), true)
            SetBlipScale(MineBlip, 0.2)
            SetBlipName(MineBlip, v.name)
        end
    end
end)

--------------------------------------
-- blips for drilling locations
--------------------------------------
CreateThread(function()
    for _,v in pairs(Config.WorkshopTents) do
        if v.showblip == true then
            local DrillingBlip = BlipAddForCoords(1664425300, v.coords)
            SetBlipSprite(DrillingBlip, joaat(v.blipsprite), true)
            SetBlipScale(DrillingBlip, v.blipscale)
            SetBlipName(DrillingBlip, v.blipname)
        end
    end
end)

local LoadAnimDict = function(dict)
    local isLoaded = HasAnimDictLoaded(dict)
    while not isLoaded do
        RequestAnimDict(dict)
        Wait(0)
        isLoaded = HasAnimDictLoaded(dict)
    end
end

---------------------------------------------
-- spawn rocks
---------------------------------------------
CreateThread(function()
    while true do
        Wait(500)

        local pos = GetEntityCoords(cache.ped)
        local InRange = false

        for i = 1, #Config.Rocks do
            local prop = vector3(Config.Rocks[i].x, Config.Rocks[i].y, Config.Rocks[i].z)
            local dist = #(pos - prop)
            if dist >= 50.0 then goto continue end

            local hasSpawned = false
            InRange = true

            for z = 1, #SpawnedProps do
                local p = SpawnedProps[z]

                if p.id == Config.Rocks[i].id then
                    hasSpawned = true
                end
            end

            if hasSpawned then goto continue end

            local modelHash = Config.Rocks[i].hash
            lib.requestModel(modelHash, 5000)

            local data = {}
            data.obj = CreateObject(modelHash, Config.Rocks[i].x, Config.Rocks[i].y, Config.Rocks[i].z -1.8, false, false, false)
            SetEntityHeading(data.obj, Config.Rocks[i].h)
            SetEntityAsMissionEntity(data.obj, true)
            Wait(100)
            FreezeEntityPosition(data.obj, true)
            SetModelAsNoLongerNeeded(data.obj)

            -- rock id
            data.id = Config.Rocks[i].id

            -- veg modifiy
            if Config.EnableVegModifier then
                
                local veg_modifier_sphere = 0
                
                if veg_modifier_sphere == nil or veg_modifier_sphere == 0 then
                    local veg_radius = 3.0
                    local veg_Flags =  1 + 2 + 4 + 8 + 16 + 32 + 64 + 128 + 256
                    local veg_ModType = 1
                    
                    veg_modifier_sphere = AddVegModifierSphere(Config.Rocks[i].x, Config.Rocks[i].y, Config.Rocks[i].z, veg_radius, veg_ModType, veg_Flags, 0)
                    
                else
                    RemoveVegModifierSphere(Citizen.PointerValueIntInitialized(veg_modifier_sphere), 0)
                    veg_modifier_sphere = 0
                end
            end

            SpawnedProps[#SpawnedProps + 1] = data
            hasSpawned = false

            -- create target for the entity
			exports.ox_target:addLocalEntity(data.obj, {
				{
					name = 'mining_rock',
					icon = 'far fa-eye',
					label = locale('cl_lang_1'),
					onSelect = function()
						TriggerEvent('rex-mining:client:minerock', data.id)
					end,
					distance = 1.5,
				}
			})
            -- end of target

            ::continue::
        end

        if not InRange then
            Wait(5000)
        end
    end
end)

---------------------------------------------
-- check job / check pickaxe / do mining
---------------------------------------------
RegisterNetEvent('rex-mining:client:minerock', function(rockid)

    -- callback and get rock info
    RSGCore.Functions.TriggerCallback('rex-mining:server:getrockinfo', function(result)

        local propid = result[1].propid
        local proptype = result[1].proptype
        local active = result[1].active
        local yeld = result[1].yeld
        local Player = RSGCore.Functions.GetPlayerData()
        local job = Player.job.name
        local hasItem = RSGCore.Functions.HasItem('pickaxe')
        
        if active == 0 then
            lib.notify({ title = locale('cl_lang_2'), duration = Config.NotificationDuration, type = 'info' })
            return
        end

        -- check if you are busy
        if isBusy then
            lib.notify({ title = locale('cl_lang_3'), duration = Config.NotificationDuration, type = 'error' })
            return
        end

        -- check pickaxe
        if not hasItem then
            lib.notify({ title = locale('cl_lang_4'), duration = Config.NotificationDuration, type = 'error' })
            return
        end

        isBusy = true

        if not IsPedMale(cache.ped) then
            -- female ped
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
            TriggerServerEvent('rex-mining:server:giveyeld', propid, proptype, active, yeld)
        else
            -- male ped
            SetCurrentPedWeapon(cache.ped, "WEAPON_UNARMED", true)
            FreezeEntityPosition(cache.ped, true)
            ClearPedTasksImmediately(cache.ped)
            TaskStartScenarioInPlace(cache.ped, joaat('WORLD_HUMAN_PICKAXE_WALL'), Config.MiningTime, true, false, false, false)
            Wait(Config.MiningTime)
            ClearPedTasksImmediately(cache.ped)
            FreezeEntityPosition(cache.ped, false)
            TriggerServerEvent('rex-mining:server:giveyeld', propid, proptype, active, yeld)
        end

        isBusy = false

    end, rockid)
end)

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

---------------------------------------------
-- remove prop object
---------------------------------------------
RegisterNetEvent('rex-mining:client:removePropObject')
AddEventHandler('rex-mining:client:removePropObject', function(prop)
    for i = 1, #SpawnedProps do
        local o = SpawnedProps[i]

        if o.id == prop then
            SetEntityAsMissionEntity(o.obj, false)
            FreezeEntityPosition(o.obj, false)
            DeleteObject(o.obj)
        end
    end
end)

---------------------------------------------
-- update props
---------------------------------------------
RegisterNetEvent('rex-mining:client:updatePropData')
AddEventHandler('rex-mining:client:updatePropData', function(data)
    Config.Rocks = data
end)

---------------------------------------------
-- place prop
---------------------------------------------
RegisterNetEvent('rex-mining:client:placeNewProp')
AddEventHandler('rex-mining:client:placeNewProp', function(proptype, pHash, pos, heading)
    RSGCore.Functions.TriggerCallback('rex-mining:server:countprop', function(result)

        if CanPlacePropHere(pos) and not IsPedInAnyVehicle(cache.ped, false) and not isBusy then
            isBusy = true
            TriggerServerEvent('rex-mining:server:newProp', proptype, pos, heading, pHash)
            lib.notify({ title = locale('cl_lang_12'), type = 'success', duration = Config.NotificationDuration })
            isBusy = false
            return
        else
            lib.notify({ title = locale('cl_lang_5'), type = 'error', duration = Config.NotificationDuration })
        end

    end, proptype)

end)

---------------------------------------------
-- check to see if prop can be place here
---------------------------------------------
function CanPlacePropHere(pos)
    local canPlace = true
    for i = 1, #Config.Rocks do
        local checkprops = vector3(Config.Rocks[i].x, Config.Rocks[i].y, Config.Rocks[i].z)
        local dist = #(pos - checkprops)
        if dist < Config.MinPropDistance then
            canPlace = false
        end
    end
    return canPlace
end

---------------------------------------------
-- clean up
---------------------------------------------
AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end

    for i = 1, #SpawnedProps do
        local props = SpawnedProps[i].obj
        SetEntityAsMissionEntity(props, false)
        FreezeEntityPosition(props, false)
        DeleteObject(props)
    end
end)
