ESX = exports['es_extended']:getSharedObject()

ESX.RegisterServerCallback('esx_taxi:canStartJob', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    cb(xPlayer.getJob().name == Config.RequiredJob)
end)

RegisterNetEvent('esx_taxi:finishJob', function(reward)
    local xPlayer = ESX.GetPlayerFromId(source)
    if reward and reward > 0 then
        xPlayer.addMoney(reward)
    end
end)

ESX.RegisterServerCallback('esx_taxi:canStartJob', function(src, cb)
    local xPlayer = ESX.GetPlayerFromId(src)
    cb(xPlayer.getJob().name == Config.RequiredJob)
end)

RegisterNetEvent('esx_taxi:rewardPlayer', function(amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        xPlayer.addMoney(amount)
    end
end)
