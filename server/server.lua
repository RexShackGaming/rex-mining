local RSGCore = exports['rsg-core']:GetCoreObject()
local PropsLoaded = false
lib.locale()

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
    local citizenid = Player.PlayerData.citizenid
    local result = MySQL.prepare.await("SELECT COUNT(*) as count FROM rex_mining WHERE citizenid = ? AND proptype = ?", { citizenid, proptype })
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
    local propId = math.random(111111, 999999)
    local Player = RSGCore.Functions.GetPlayer(src)
    local citizenid = Player.PlayerData.citizenid
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

end)

---------------------------------------------
-- save props
---------------------------------------------
RegisterServerEvent('rex-mining:server:saveProp')
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

    for k, v in pairs(Config.Rocks) do
        if v.id == propid then
            table.remove(Config.Rocks, k)
        end
    end

    TriggerClientEvent('rex-mining:client:removePropObject', src, propid)
    TriggerEvent('rex-mining:server:PropRemoved', propid)
    TriggerEvent('rex-mining:server:updateProps')
end)

---------------------------------------------
-- update props
---------------------------------------------
RegisterServerEvent('rex-mining:server:updateProps')
AddEventHandler('rex-mining:server:updateProps', function()
    local src = source
    TriggerClientEvent('rex-mining:client:updatePropData', src, Config.Rocks)
end)

---------------------------------------------
-- remove props
---------------------------------------------
RegisterServerEvent('rex-mining:server:PropRemoved')
AddEventHandler('rex-mining:server:PropRemoved', function(propId)
    local result = MySQL.query.await('SELECT * FROM rex_mining')

    if not result then return end

    for i = 1, #result do
        local propData = json.decode(result[i].properties)

        if propData.id == propId then

            MySQL.Async.execute('DELETE FROM rex_mining WHERE id = @id', { ['@id'] = result[i].id })
			MySQL.update('DELETE FROM inventories WHERE identifier = ?', { 'stash'..result[i].propid })

            for k, v in pairs(Config.Rocks) do
                if v.id == propId then
                    table.remove(Config.Rocks, k)
                end
            end
        end
    end
end)

---------------------------------------------
-- get props
---------------------------------------------
RegisterServerEvent('rex-mining:server:getProps')
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
-- remove item
---------------------------------------------
RegisterServerEvent('rex-mining:server:removeitem')
AddEventHandler('rex-mining:server:removeitem', function(item, amount)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    Player.Functions.RemoveItem(item, amount)
    TriggerClientEvent('rsg-inventory:client:ItemBox', src, RSGCore.Shared.Items[item], 'remove')
end)

---------------------------------------------
-- give player mining yeld
---------------------------------------------
RegisterServerEvent('rex-mining:server:giveyeld')
AddEventHandler('rex-mining:server:giveyeld', function(propid, item, active, amount)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    Player.Functions.AddItem(item, amount)
    TriggerClientEvent('rsg-inventory:client:ItemBox', src, RSGCore.Shared.Items[item], 'add', amount)
    MySQL.update('UPDATE rex_mining SET active = ? WHERE propid = ?', { 0, propid })
end)

---------------------------------
-- give drilling output to player
---------------------------------
RegisterNetEvent('rex-mining:server:finishdrilling', function(item)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end
    if item == 'rock' then
        local randomItem = Config.RockOutputs[math.random(#Config.RockOutputs)]
        Player.Functions.RemoveItem(item, 1)
        Player.Functions.AddItem(randomItem, 1)
        TriggerClientEvent('rNotify:ShowAdvancedRightNotification', src, "1 x "..RSGCore.Shared.Items[randomItem].label, "generic_textures" , "tick" , "COLOR_PURE_WHITE", 4000)
        local gemchance = math.random(100)
        if gemchance <= Config.GemChance then
            local randomGem = Config.GemOutputs[math.random(#Config.GemOutputs)]
            Player.Functions.AddItem(randomGem, 1)
            TriggerClientEvent('rNotify:ShowAdvancedRightNotification', src, "1 x "..RSGCore.Shared.Items[randomGem].label, "generic_textures" , "tick" , "COLOR_PURE_WHITE", 4000)
        end
    end
    if item == 'saltrock' then
        local randomItem = Config.SaltRockOutputs[math.random(#Config.SaltRockOutputs)]
        Player.Functions.RemoveItem(item, 1)
        Player.Functions.AddItem(randomItem, 1)
        TriggerClientEvent('rNotify:ShowAdvancedRightNotification', src, "1 x "..RSGCore.Shared.Items[randomItem].label, "generic_textures" , "tick" , "COLOR_PURE_WHITE", 4000)
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
            MySQL.update('UPDATE rex_mining SET yeld = ? WHERE propid = ?', { 1, newyeld })
        end

    end

    ::continue::

    if Config.ServerNotify then
        print(locale('sv_lang_5'))
    end

end)
