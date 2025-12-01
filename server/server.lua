local RSGCore = exports['rsg-core']:GetCoreObject()
local drillingCooldowns = {}
lib.locale()

-----------------------------------------------
-- check player have a pickaxe
-----------------------------------------------
RSGCore.Functions.CreateCallback('rex-mining:server:HasPickaxe', function(source, cb, item)
    local Player = RSGCore.Functions.GetPlayer(source)
    if Player and Player.Functions.GetItemByName(item) then
        cb(true)
    else
        cb(false)
    end
end)

-----------------------------------------------
-- reward player after successful mining
-----------------------------------------------
RegisterNetEvent('rex-mining:server:MineReward', function(oreType)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    local rewardData = Config.Rewards[oreType]

    if not Player or not rewardData then return end

    local amount = math.random(rewardData.minAmount, rewardData.maxAmount)

    if Player.Functions.AddItem(rewardData.item, amount) then
        TriggerClientEvent('rsg-inventory:client:ItemBox', src, RSGCore.Shared.Items[rewardData.item], 'add', amount)
        
        lib.notify(src, {
            title = locale('mining_success') or 'Mining Success',
            description = 'You collected ' .. amount .. 'x ' .. RSGCore.Shared.Items[rewardData.item].label,
            type = 'success',
            icon = 'gem'
        })
    else
        lib.notify(src, {
            title = 'Inventory',
            description = locale('inventory_full'),
            type = 'error'
        })
    end
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
