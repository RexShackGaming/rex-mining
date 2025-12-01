local RSGCore = exports['rsg-core']:GetCoreObject()
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
