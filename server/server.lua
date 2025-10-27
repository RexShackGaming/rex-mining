local RSGCore = exports['rsg-core']:GetCoreObject()
local PropsLoaded = false
lib.locale()

-- rate limiting tables
local miningCooldowns = {}
local drillingCooldowns = {}

---------------------------------------------
-- admin logging function
---------------------------------------------
local function AdminLog(message, playerData)
    if not Config.EnableAdminLogging then return end
    
    local logMessage = string.format('[MINING] %s | Player: %s (%s) | CitizenID: %s', 
        message, 
        playerData.name or 'Unknown',
        playerData.source or 'N/A',
        playerData.citizenid or 'N/A'
    )
    
    print(logMessage)
    
    -- optional Discord webhook
    if Config.DiscordWebhook and Config.DiscordWebhook ~= '' then
        local embed = {
            {
                ['title'] = 'Mining Admin Log',
                ['description'] = message,
                ['color'] = 3447003,
                ['fields'] = {
                    { ['name'] = 'Player', ['value'] = playerData.name or 'Unknown', ['inline'] = true },
                    { ['name'] = 'Source', ['value'] = tostring(playerData.source), ['inline'] = true },
                    { ['name'] = 'CitizenID', ['value'] = playerData.citizenid or 'N/A', ['inline'] = true },
                },
                ['footer'] = { ['text'] = os.date('%Y-%m-%d %H:%M:%S') },
            }
        }
        PerformHttpRequest(Config.DiscordWebhook, function(err, text, headers) end, 'POST', json.encode({embeds = embed}), { ['Content-Type'] = 'application/json' })
    end
end

----------------------------------------------------
-- create mining nodes commands (rock / saltrock)
----------------------------------------------------
RSGCore.Commands.Add('createrocknode', locale('sv_lang_1'), {}, false, function(source)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    local cid = Player.PlayerData.citizenid
    TriggerClientEvent('rex-mining:client:createminingnode', src, 'rock', Config.RockProp)
end, 'admin')

RSGCore.Commands.Add('createsaltrocknode', locale('sv_lang_2'), {}, false, function(source)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    local cid = Player.PlayerData.citizenid
    TriggerClientEvent('rex-mining:client:createminingnode', src, 'saltrock', Config.RockProp)
end, 'admin')

---------------------------------------------
-- get all prop data
---------------------------------------------
RSGCore.Functions.CreateCallback('rex-mining:server:getrockinfo', function(source, cb, propid)
    -- validate propid is a number
    if type(propid) ~= 'number' then
        cb(nil)
        return
    end
    
    MySQL.query('SELECT * FROM rex_mining WHERE propid = ?', {propid}, function(result)
        if result[1] then
            cb(result)
        else
            cb(nil)
        end
    end)
end)

---------------------------------------------
-- count props
---------------------------------------------
RSGCore.Functions.CreateCallback('rex-mining:server:countprop', function(source, cb, proptype)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then cb(nil) return end
    
    local citizenid = Player.PlayerData.citizenid
    local result = MySQL.prepare.await("SELECT COUNT(*) as count FROM rex_mining WHERE citizenid = ? AND proptype = ?", { citizenid, proptype })
    
    if result and Config.MaxPropsPerPlayer > 0 and result >= Config.MaxPropsPerPlayer then
        TriggerClientEvent('ox_lib:notify', src, { title = lib.locale('sv_lang_6'), type = 'error', duration = Config.NotificationDuration })
        cb(nil)
        return
    end
    
    if result then
        cb(result)
    else
        cb(nil)
    end
end)

---------------------------------------------
-- update prop data
---------------------------------------------
CreateThread(function()
    while true do
        Wait(5000)
        if PropsLoaded then
            TriggerClientEvent('rex-mining:client:updatePropData', -1, Config.Rocks)
        end
    end
end)

---------------------------------------------
-- cleanup old cooldowns (prevent memory leak)
---------------------------------------------
CreateThread(function()
    while true do
        Wait(300000) -- run every 5 minutes
        
        local currentTime = os.time()
        local cleanupThreshold = 300 -- remove entries older than 5 minutes
        
        -- cleanup mining cooldowns
        for key, timestamp in pairs(miningCooldowns) do
            if currentTime - timestamp > cleanupThreshold then
                miningCooldowns[key] = nil
            end
        end
        
        -- cleanup drilling cooldowns
        for src, timestamp in pairs(drillingCooldowns) do
            if currentTime - timestamp > cleanupThreshold then
                drillingCooldowns[src] = nil
            end
        end
        
        if Config.ServerNotify then
            print('[MINING] Cooldown tables cleaned up')
        end
    end
end)

---------------------------------------------
-- get props
---------------------------------------------
CreateThread(function()
    TriggerEvent('rex-mining:server:getProps')
    PropsLoaded = true
end)

---------------------------------------------
-- new prop
---------------------------------------------
RegisterServerEvent('rex-mining:server:newProp')
AddEventHandler('rex-mining:server:newProp', function(proptype, location, heading, hash)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end
    
    -- validate proptype
    if proptype ~= 'rock' and proptype ~= 'saltrock' then return end
    
    -- validate hash matches config
    if hash ~= Config.RockProp and hash ~= Config.SaltRockProp then return end
    
    -- check max props server-side
    local citizenid = Player.PlayerData.citizenid
    local count = MySQL.prepare.await("SELECT COUNT(*) as count FROM rex_mining WHERE citizenid = ?", { citizenid })
    if Config.MaxPropsPerPlayer > 0 and count >= Config.MaxPropsPerPlayer then
        TriggerClientEvent('ox_lib:notify', src, { title = lib.locale('sv_lang_6'), type = 'error', duration = Config.NotificationDuration })
        return
    end
    
    -- generate unique propId
    local propId
    local attempts = 0
    repeat
        propId = math.random(111111, 999999)
        local exists = MySQL.prepare.await("SELECT COUNT(*) as count FROM rex_mining WHERE propid = ?", { propId })
        attempts = attempts + 1
        if attempts > 100 then return end -- prevent infinite loop
    until exists == 0
    
    local active = 1
    local yeld = 1

    local PropData =
    {
        id = propId,
        proptype = proptype,
        x = location.x,
        y = location.y,
        z = location.z,
        h = heading,
        hash = hash,
        builder = Player.PlayerData.citizenid,
        buildttime = os.time()
    }

    table.insert(Config.Rocks, PropData)
    TriggerEvent('rex-mining:server:saveProp', PropData, propId, citizenid, proptype, active, yeld)
    TriggerEvent('rex-mining:server:updateProps')
    
    -- admin log
    AdminLog(string.format('Created %s node (ID: %s) at coords: %.2f, %.2f, %.2f', proptype, propId, location.x, location.y, location.z), {
        name = Player.PlayerData.charinfo.firstname..' '..Player.PlayerData.charinfo.lastname,
        source = src,
        citizenid = citizenid
    })

end)

---------------------------------------------
-- save props (internal only - cannot be triggered by clients)
---------------------------------------------
AddEventHandler('rex-mining:server:saveProp', function(data, propId, citizenid, proptype, active, yeld)
    local datas = json.encode(data)

    MySQL.Async.execute('INSERT INTO rex_mining (properties, propid, citizenid, proptype, active, yeld) VALUES (@properties, @propid, @citizenid, @proptype, @active, @yeld)',
    {
        ['@properties'] = datas,
        ['@propid'] = propId,
        ['@citizenid'] = citizenid,
        ['@proptype'] = proptype,
        ['@active'] = active,
        ['@yeld'] = yeld,
    })
end)

---------------------------------------------
-- distory prop
---------------------------------------------
RegisterServerEvent('rex-mining:server:destroyProp')
AddEventHandler('rex-mining:server:destroyProp', function(propid, item)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end
    
    -- verify ownership
    local result = MySQL.query.await('SELECT citizenid FROM rex_mining WHERE propid = ?', { propid })
    if not result[1] or result[1].citizenid ~= Player.PlayerData.citizenid then
        TriggerClientEvent('ox_lib:notify', src, { title = 'You do not own this rock!', type = 'error', duration = Config.NotificationDuration })
        return
    end

    for k, v in pairs(Config.Rocks) do
        if v.id == propid then
            table.remove(Config.Rocks, k)
        end
    end

    TriggerClientEvent('rex-mining:client:removePropObject', src, propid)
    TriggerEvent('rex-mining:server:PropRemoved', propid)
    TriggerEvent('rex-mining:server:updateProps')
    
    -- admin log
    AdminLog(string.format('Destroyed rock node (ID: %s)', propid), {
        name = Player.PlayerData.charinfo.firstname..' '..Player.PlayerData.charinfo.lastname,
        source = src,
        citizenid = Player.PlayerData.citizenid
    })
end)

---------------------------------------------
-- update props (internal only - cannot be triggered by clients)
---------------------------------------------
AddEventHandler('rex-mining:server:updateProps', function()
    local src = source
    TriggerClientEvent('rex-mining:client:updatePropData', src, Config.Rocks)
end)

---------------------------------------------
-- remove props (internal only - cannot be triggered by clients)
---------------------------------------------
AddEventHandler('rex-mining:server:PropRemoved', function(propId)
    local result = MySQL.query.await('SELECT * FROM rex_mining')

    if not result then return end

    for i = 1, #result do
        local propData = json.decode(result[i].properties)

        if propData.id == propId then

            MySQL.Async.execute('DELETE FROM rex_mining WHERE id = @id', { ['@id'] = result[i].id })
            MySQL.update('DELETE FROM inventories WHERE identifier = ?', { 'stash_'..result[i].propid })

            for k, v in pairs(Config.Rocks) do
                if v.id == propId then
                    table.remove(Config.Rocks, k)
                end
            end
        end
    end
end)

---------------------------------------------
-- get props (internal only - cannot be triggered by clients)
---------------------------------------------
AddEventHandler('rex-mining:server:getProps', function()
    local result = MySQL.query.await('SELECT * FROM rex_mining')

    if not result[1] then return end

    for i = 1, #result do
        local propData = json.decode(result[i].properties)
        if Config.ServerNotify then
            print(locale('sv_lang_3')..propData.proptype..locale('sv_lang_4')..propData.id)
        end
        table.insert(Config.Rocks, propData)
    end
end)

---------------------------------------------
-- remove item (DISABLED - security risk)
---------------------------------------------
-- This event has been disabled as it allows clients to remove any item without validation
-- RegisterServerEvent('rex-mining:server:removeitem')
-- AddEventHandler('rex-mining:server:removeitem', function(item, amount)
--     local src = source
--     local Player = RSGCore.Functions.GetPlayer(src)
--     Player.Functions.RemoveItem(item, amount)
--     TriggerClientEvent('rsg-inventory:client:ItemBox', src, RSGCore.Shared.Items[item], 'remove')
-- end)

---------------------------------------------
-- give player mining yeld
---------------------------------------------
RegisterServerEvent('rex-mining:server:giveyeld')
AddEventHandler('rex-mining:server:giveyeld', function(propid, item, active, amount)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end
    
    -- rate limiting (prevent spam)
    local cooldownKey = src..'-'..propid
    if miningCooldowns[cooldownKey] and os.time() - miningCooldowns[cooldownKey] < 5 then
        return -- too fast, ignore
    end
    miningCooldowns[cooldownKey] = os.time()
    
    -- validate rock exists and is active
    local result = MySQL.query.await('SELECT * FROM rex_mining WHERE propid = ?', { propid })
    if not result[1] then return end
    
    -- distance validation (anti-teleport)
    local playerCoords = GetEntityCoords(GetPlayerPed(src))
    local rockCoords = vector3(result[1].properties and json.decode(result[1].properties).x or 0, result[1].properties and json.decode(result[1].properties).y or 0, result[1].properties and json.decode(result[1].properties).z or 0)
    local distance = #(playerCoords - rockCoords)
    
    if distance > Config.MaxMiningDistance then
        if Config.EnableAdminLogging then
            print(string.format('[MINING ANTICHEAT] Player %s (%s) attempted to mine from %s meters away!', GetPlayerName(src), src, distance))
        end
        return
    end
    
    local result = MySQL.query.await('SELECT * FROM rex_mining WHERE propid = ?', { propid })
    if not result[1] then return end
    if result[1].active ~= 1 then
        TriggerClientEvent('ox_lib:notify', src, { title = locale('cl_lang_2'), type = 'error', duration = Config.NotificationDuration })
        return
    end
    
    -- use database values, not client values
    local dbPropType = result[1].proptype
    local dbYeld = result[1].yeld
    
    -- mark as inactive FIRST (prevent double mining)
    local updated = MySQL.update.await('UPDATE rex_mining SET active = ? WHERE propid = ? AND active = ?', { 0, propid, 1 })
    if updated == 0 then return end -- rock already mined
    
    -- validate item exists in shared items
    if not RSGCore.Shared.Items[dbPropType] then
        print(string.format('[MINING ERROR] Item "%s" does not exist in RSGCore.Shared.Items!', dbPropType))
        return
    end
    
    -- give rewards
    Player.Functions.AddItem(dbPropType, dbYeld)
    TriggerClientEvent('rsg-inventory:client:ItemBox', src, RSGCore.Shared.Items[dbPropType], 'add', dbYeld)
end)

---------------------------------
-- give drilling output to player
---------------------------------
RegisterNetEvent('rex-mining:server:finishdrilling', function(item)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end
    
    -- rate limiting (prevent spam)
    if drillingCooldowns[src] and os.time() - drillingCooldowns[src] < 2 then
        return -- too fast, ignore
    end
    drillingCooldowns[src] = os.time()
    
    -- validate item type
    if item ~= 'rock' and item ~= 'saltrock' then return end
    
    -- verify player has the item
    local hasItem = exports['rsg-inventory']:HasItem(src, item, 1)
    if not hasItem then
        TriggerClientEvent('ox_lib:notify', src, { title = locale('cl_lang_10'), type = 'error', duration = Config.NotificationDuration })
        return
    end
    
    if item == 'rock' then
        local randomItem = Config.RockOutputs[math.random(#Config.RockOutputs)]
        if not randomItem or not RSGCore.Shared.Items[randomItem] then
            print(string.format('[MINING ERROR] Random item "%s" does not exist in RSGCore.Shared.Items!', tostring(randomItem)))
            return
        end
        
        -- validate source item exists
        if not RSGCore.Shared.Items[item] then
            print(string.format('[MINING ERROR] Item "%s" does not exist in RSGCore.Shared.Items!', item))
            return
        end
        
        Player.Functions.RemoveItem(item, 1)
        Player.Functions.AddItem(randomItem, 1)
        TriggerClientEvent('ox_lib:notify', src, {
            title = locale('sv_lang_7'),
            description = '1x '..RSGCore.Shared.Items[randomItem].label,
            type = 'success',
            duration = Config.NotificationDuration 
        })
        
        local gemchance = math.random(100)
        if gemchance <= Config.GemChance then
            local randomGem = Config.GemOutputs[math.random(#Config.GemOutputs)]
            if randomGem and RSGCore.Shared.Items[randomGem] then
                Player.Functions.AddItem(randomGem, 1)
                TriggerClientEvent('ox_lib:notify', src, { 
                    title = locale('sv_lang_7'),
                    description = '1x '..RSGCore.Shared.Items[randomGem].label..' (Rare!)',
                    type = 'success',
                    duration = Config.NotificationDuration 
                })
            end
        end
    end
    
    if item == 'saltrock' then
        local randomItem = Config.SaltRockOutputs[math.random(#Config.SaltRockOutputs)]
        if not randomItem or not RSGCore.Shared.Items[randomItem] then
            print(string.format('[MINING ERROR] Random item "%s" does not exist in RSGCore.Shared.Items!', tostring(randomItem)))
            return
        end
        
        -- validate source item exists
        if not RSGCore.Shared.Items[item] then
            print(string.format('[MINING ERROR] Item "%s" does not exist in RSGCore.Shared.Items!', item))
            return
        end
        
        Player.Functions.RemoveItem(item, 1)
        Player.Functions.AddItem(randomItem, 1)
        TriggerClientEvent('ox_lib:notify', src, { 
            title = locale('sv_lang_7'),
            description = '1x '..RSGCore.Shared.Items[randomItem].label,
            type = 'success',
            duration = Config.NotificationDuration 
        })
    end
end)

---------------------------------------------
-- mining cronjob
---------------------------------------------
lib.cron.new(Config.MiningCronJob, function ()

    local result = MySQL.query.await('SELECT * FROM rex_mining')

    if not result then goto continue end

    for i = 1, #result do

        local propid   = result[i].propid
        local proptype = result[i].proptype
        local active   = result[i].active
        local yeld     = result[i].yeld
        local newyeld  = math.random(3)

        if active == 0 then
            MySQL.update('UPDATE rex_mining SET active = ? WHERE propid = ?', { 1, propid })
            MySQL.update('UPDATE rex_mining SET yeld = ? WHERE propid = ?', { newyeld, propid })
        end

    end

    ::continue::

    if Config.ServerNotify then
        print(locale('sv_lang_5'))
    end

end)
