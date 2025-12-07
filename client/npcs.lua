local spawnedPeds = {}
local lastDistanceCheck = {}
lib.locale()

-- optimized NPC spawning with reduced polling frequency
Citizen.CreateThread(function()
    while true do
        Wait(1000) -- Increased from 500ms to 1000ms
        local playerCoords = GetEntityCoords(PlayerPedId())
        local currentTime = GetGameTimer()
        
        for k,v in pairs(Config.WorkshopTents) do
            -- Rate limiting per location
            if not lastDistanceCheck[k] or currentTime - lastDistanceCheck[k] > 800 then
                local distance = #(playerCoords - v.npccoords.xyz)

                if distance < Config.DistanceSpawn and not spawnedPeds[k] then
                    local spawnedPed = NearPed(v.npcmodel, v.npccoords, v.mineid, v.jobaccess, v.scenario)
                    if spawnedPed then
                        spawnedPeds[k] = { spawnedPed = spawnedPed }
                        lastDistanceCheck[k] = currentTime
                    end
                elseif distance >= Config.DistanceSpawn and spawnedPeds[k] then
                    -- Optimized fade out with fewer steps
                    if Config.FadeIn and DoesEntityExist(spawnedPeds[k].spawnedPed) then
                        for i = 255, 0, -85 do -- Fewer iterations (3 vs 5)
                            Wait(30) -- Reduced wait time
                            SetEntityAlpha(spawnedPeds[k].spawnedPed, math.max(i, 0), false)
                        end
                    end
                    if DoesEntityExist(spawnedPeds[k].spawnedPed) then
                        DeletePed(spawnedPeds[k].spawnedPed)
                    end
                    spawnedPeds[k] = nil
                    lastDistanceCheck[k] = currentTime
                end
            end
        end
    end
end)

function NearPed(npcmodel, npccoords, mineid, jobaccess, scenario)
    if not npcmodel or not npccoords or not mineid or not jobaccess then
        return nil
    end
    
    RequestModel(npcmodel)
    local attempts = 0
    while not HasModelLoaded(npcmodel) and attempts < 100 do -- Prevent infinite loop
        Wait(50)
        attempts = attempts + 1
    end
    
    if not HasModelLoaded(npcmodel) then
        return nil
    end
    
    local spawnedPed = CreatePed(npcmodel, npccoords.x, npccoords.y, npccoords.z - 1.0, npccoords.w, false, false, 0, 0)
    
    if not DoesEntityExist(spawnedPed) then
        return nil
    end
    
    -- Batch entity setup for better performance
    SetEntityAlpha(spawnedPed, 0, false)
    SetRandomOutfitVariation(spawnedPed, true)
    SetEntityCanBeDamaged(spawnedPed, false)
    SetEntityInvincible(spawnedPed, true)
    FreezeEntityPosition(spawnedPed, true)
    SetBlockingOfNonTemporaryEvents(spawnedPed, true)
    SetPedCanBeTargetted(spawnedPed, false)
    SetPedFleeAttributes(spawnedPed, 0, false)
    TaskStartScenarioInPlace(spawnedPed, scenario, 0, true)
    
    -- Optimized fade in with fewer iterations
    if Config.FadeIn then
        for i = 0, 255, 85 do -- Fewer iterations (3 vs 5)
            Wait(30) -- Reduced wait time
            SetEntityAlpha(spawnedPed, math.min(i, 255), false)
        end
        SetEntityAlpha(spawnedPed, 255, false) -- Ensure full opacity
    else
        SetEntityAlpha(spawnedPed, 255, false)
    end
    
    -- Target setup
    exports.ox_target:addLocalEntity(spawnedPed, {
        {
            name = 'npc_mining',
            icon = 'far fa-eye',
            label = locale('cl_lang_17'),
            onSelect = function()
                TriggerEvent('rex-mining:client:miningmenu',  mineid, jobaccess)
            end,
            distance = 3.0
        }
    })
    
    return spawnedPed
end

-- cleanup
AddEventHandler("onResourceStop", function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    for k,v in pairs(spawnedPeds) do
        if v and v.spawnedPed and DoesEntityExist(v.spawnedPed) then
            DeletePed(v.spawnedPed)
        end
        spawnedPeds[k] = nil
    end
end)
