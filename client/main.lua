local activeJob = false
local currentNPC, destination, timer = nil, nil, 0
local inTaxi = false
local npcEntity = nil
local showTimer3D = false
local vehicleEntity = nil
local timerStarted = false
local lib = exports.ox_lib
local currentNPCBlip, destinationBlip = nil, nil
local pickupCoordsUsed = {}
local allowTaxiDelete = false

function Draw3DText(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    DrawText(_World3dToScreen2d(x, y, z))
end

function _World3dToScreen2d(x, y, z)
    local _, _x, _y = World3dToScreen2d(x, y, z)
    SetDrawOrigin(x, y, z, 0)
    ClearDrawOrigin()
    return _x, _y
end

local function removeBlipIfExists(blip)
    if blip and DoesBlipExist(blip) then
        RemoveBlip(blip)
        return nil
    end
    return blip
end

CreateThread(function()
    local blip = AddBlipForCoord(Config.JobBlip.coords)
    SetBlipSprite(blip, Config.JobBlip.sprite)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.9)
    SetBlipColour(blip, Config.JobBlip.color)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(Config.JobBlip.label)
    EndTextCommandSetBlipName(blip)

    RequestModel(Config.StartNPC.model)
    while not HasModelLoaded(Config.StartNPC.model) do Wait(0) end
    npcEntity = CreatePed(0, Config.StartNPC.model, Config.StartNPC.coords.xyz, Config.StartNPC.coords.w, false, true)
    FreezeEntityPosition(npcEntity, true)
    SetEntityInvincible(npcEntity, true)
    SetBlockingOfNonTemporaryEvents(npcEntity, true)

    CreateThread(function()
        while true do
            Wait(0)
            local player = PlayerPedId()
            local coords = GetEntityCoords(player)
            local dist = #(coords - Config.StartNPC.coords.xyz)

            if dist < 2.0 then
                ESX.ShowHelpNotification("Druk op ~INPUT_CONTEXT~ om een taxi job te starten")
                if IsControlJustReleased(0, 38) then
                    TriggerEvent('esx_taxi:startJob')
                    Wait(1000)
                end
            else
                Wait(500)
            end
        end
    end)
end)

RegisterNetEvent('esx_taxi:startJob', function()
    ESX.TriggerServerCallback('esx_taxi:canStartJob', function(canStart)
        if not canStart then
            lib:notify({title = 'Taxi Job', description = 'Je bent geen taxi chauffeur.', type = 'error'})
            return
        end

        local model = GetHashKey(Config.TaxiVehicleModel)
        RequestModel(model)
        while not HasModelLoaded(model) do Wait(0) end

        vehicleEntity = CreateVehicle(model, Config.TaxiSpawn.coords.xyz, Config.TaxiSpawn.coords.w, true, false)
        TaskWarpPedIntoVehicle(PlayerPedId(), vehicleEntity, -1)
        inTaxi = true
        spawnPickupNPC()
    end)
end)

RegisterCommand('stoptaxi', function()
    if activeJob then
        finishJob(false)
    elseif vehicleEntity and DoesEntityExist(vehicleEntity) then
        stopTaxiJobCompletely()
    else
        lib:notify({title = 'Taxi Job', description = 'Je hebt geen actieve job of taxi.', type = 'error'})
    end
end)

function stopTaxiJobCompletely()
    currentNPCBlip = removeBlipIfExists(currentNPCBlip)
    destinationBlip = removeBlipIfExists(destinationBlip)

    if currentNPC and DoesEntityExist(currentNPC) then
        DeleteEntity(currentNPC)
        currentNPC = nil
    end

    activeJob, showTimer3D, timerStarted = false, false, false
    allowTaxiDelete = true

    lib:notify({title = 'Taxi Job', description = 'Je hebt de job gestopt. Breng de taxi terug.', type = 'error'})
end

function getNewPickupLocation()
    if #Config.NPCLocations == 1 then
        return Config.NPCLocations[1]
    end

    local available = {}
    for i, loc in ipairs(Config.NPCLocations) do
        if not pickupCoordsUsed[i] then
            table.insert(available, {index = i, coords = loc})
        end
    end

    if #available == 0 then
        pickupCoordsUsed = {}
        return Config.NPCLocations[1]
    end

    local chosen = available[math.random(#available)]
    pickupCoordsUsed[chosen.index] = true
    return chosen.coords
end

function spawnPickupNPC()
    local pickupLoc = getNewPickupLocation()
    RequestModel('a_m_m_business_01')
    while not HasModelLoaded('a_m_m_business_01') do Wait(0) end

    currentNPC = CreatePed(0, 'a_m_m_business_01', pickupLoc.xyz, pickupLoc.w, false, true)
    SetBlockingOfNonTemporaryEvents(currentNPC, true)
    SetEntityAsMissionEntity(currentNPC, true, true)

    currentNPCBlip = AddBlipForEntity(currentNPC)
    SetBlipSprite(currentNPCBlip, 280)
    SetBlipColour(currentNPCBlip, 5)
    SetBlipRoute(currentNPCBlip, true)

    CreateThread(function()
        while not IsPedInAnyVehicle(currentNPC, false) do
            Wait(1000)
            local playerCoords = GetEntityCoords(PlayerPedId())
            if #(playerCoords - GetEntityCoords(currentNPC)) < 5.0 then
                TaskEnterVehicle(currentNPC, vehicleEntity, -1, 2, 1.0, 1, 0)
            end
        end

        RemoveBlip(currentNPCBlip)
        Wait(2000)
        startDestination()
    end)
end

function startDestination()
    destination = Config.Destinations[math.random(#Config.Destinations)]
    destinationBlip = AddBlipForCoord(destination)
    SetBlipRoute(destinationBlip, true)

    timer = Config.TimerDuration
    timerStarted = true
    activeJob = true
    showTimer3D = true

    CreateThread(function()
        local lastHealth = GetEntityHealth(vehicleEntity)
        while activeJob do
            Wait(1000)

            if not Config.DisableTimer then
                timer = timer - 1
                if timer <= 0 then
                    finishJob(false)
                    return
                end
            end

            if currentNPC and destination and #(GetEntityCoords(vehicleEntity) - destination) < 10.0 and IsPedInVehicle(currentNPC, vehicleEntity, false) then
                finishJob(true)
                return
            end

            local currentHealth = GetEntityHealth(vehicleEntity)
            if currentHealth < lastHealth then
                timer = math.max(0, timer - Config.CrashPenalty)
                exports.ox_lib:notify({title = 'Taxi Job', description = 'Je botste! Tijd verminderd.', type = 'error'})
                lastHealth = currentHealth
            end
        end
    end)

    CreateThread(function()
        while activeJob do
            Wait(0)
            if showTimer3D and vehicleEntity then
                local coords = GetEntityCoords(vehicleEntity)
                local mins = math.floor(timer / 60)
                local secs = math.floor(timer % 60)
                Draw3DText(coords.x, coords.y, coords.z + 1.5, string.format("⏱️ %02d:%02d", mins, secs))
            end
        end
    end)
end

function finishJob(success)
    if destinationBlip and DoesBlipExist(destinationBlip) then
        RemoveBlip(destinationBlip)
        destinationBlip = nil
    end

    if currentNPC and DoesEntityExist(currentNPC) then
        TaskLeaveVehicle(currentNPC, vehicleEntity, 0)
        Wait(2000)

        if success then
            local reward = math.random(Config.RewardMin, Config.RewardMax)
            TriggerServerEvent('esx_taxi:rewardPlayer', reward)
            exports.ox_lib:notify({title = 'Taxi Job', description = 'Goed gedaan! NPC is afgeleverd.', type = 'success'})
        else
            exports.ox_lib:notify({title = 'Taxi Job', description = 'Te laat! NPC is boos en betaalt niet.', type = 'error'})
        end

        DeleteEntity(currentNPC)
        currentNPC = nil
    end

    if currentNPCBlip and DoesBlipExist(currentNPCBlip) then
        RemoveBlip(currentNPCBlip)
        currentNPCBlip = nil
    end

    showTimer3D = false
    activeJob = false
    timerStarted = false

    if success and #pickupCoordsUsed < #Config.NPCLocations then
        spawnPickupNPC()
    else
        pickupCoordsUsed = {}
        exports.ox_lib:notify({title = 'Taxi Job', description = "Alle NPC's zijn afgezet! Breng de taxi terug.", type = 'inform'})
        allowTaxiDelete = true

        if DoesBlipExist(destinationBlip) then
            RemoveBlip(destinationBlip)
        end
        destinationBlip = AddBlipForCoord(Config.TaxiDelete.coords)
        SetBlipSprite(destinationBlip, 524)
        SetBlipColour(destinationBlip, 3)
        SetBlipRoute(destinationBlip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Taxi Terugbrengpunt")
        EndTextCommandSetBlipName(destinationBlip)
    end
end

CreateThread(function()
    while true do
        Wait(0)
        if allowTaxiDelete and vehicleEntity and DoesEntityExist(vehicleEntity) then
            local playerCoords = GetEntityCoords(PlayerPedId())
            local markerCoords = Config.TaxiDelete.coords
            local dist = #(playerCoords - markerCoords.xyz)

            if dist < 20.0 then
                DrawMarker(1, markerCoords.x, markerCoords.y, markerCoords.z - 1.0, 0, 0, 0, 0, 0, 0, 2.0, 2.0, 1.0, 255, 255, 0, 100, false, false, 2, false, nil, nil, false)
                if dist < 2.0 then
                    ESX.ShowHelpNotification("Druk op ~INPUT_CONTEXT~ om de taxi in te leveren")
                    if IsControlJustReleased(0, 38) then
                        DeleteEntity(vehicleEntity)
                        vehicleEntity = nil
                        allowTaxiDelete = false
                        lib:notify({title = 'Taxi Job', description = 'Taxi succesvol ingeleverd.', type = 'success'})
                        destinationBlip = removeBlipIfExists(destinationBlip)
                    end
                end
            end
        end
    end
end)