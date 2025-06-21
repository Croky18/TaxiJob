-- config.lua
Config = {}

Config.TaxiVehicleModel = 'taxi'
Config.TimerDuration = 120 -- seconds
Config.RewardMin = 100
Config.RewardMax = 500
Config.CrashPenalty = 5
Config.RequiredJob = 'taxi'
Config.DisableTimer = false -- Zet op true om timer uit te schakelen

Config.JobBlip = {
    coords = vector3(895.12, -179.94, 74.7),
    sprite = 198,
    color = 5,
    label = 'Taxi Job'
}

Config.StartNPC = {
    coords = vector4(899.6158, -172.1919, 73.0701, 233.6279),
    model = 's_m_m_gentransport'
}

Config.TaxiSpawn = {
    coords = vector4(898.1276, -182.6070, 73.7920, 329.8305)
}

Config.TaxiDelete = {
    coords = vector3(906.2138, -186.0108, 73.9983) -- pas aan naar jouw gewenste locatie
}

Config.NPCLocations = { -- ophallen
    vector4(6.5842, -378.7643, 39.4659, 68.1560),
    vector4(150.1825, -922.5225, 30.0654, 74.3562),
    vector4(411.6149, -994.2573, 29.4114, 85.2642),
}

Config.Destinations = { --levery
    vector3(942.4927, -506.3526, 60.0049),
    vector3(-673.21, -244.27, 36.52),
    vector3(378.53, -181.67, 58.01),
}