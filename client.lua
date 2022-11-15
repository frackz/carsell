RegisterNetEvent("carsell:deleteveh", function()
    local car = GetVehiclePedIsIn(GetPlayerPed( -1 ), false)
    SetEntityAsMissionEntity(car, true, true )
    Citizen.InvokeNative( 0xEA386986E786A54F, Citizen.PointerValueIntInitialized(car))
end)

RegisterNetEvent("carsell:spawncar", function(vehiclehash)
    vehiclehash = tonumber(vehiclehash)
    local x,y,z = table.unpack(GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 8.0, 0.5))
    RequestModel(vehiclehash)
    
    while not HasModelLoaded(vehiclehash) do
        RequestModel(vehiclehash)
        Wait(0)
    end
    local veh = CreateVehicle(vehiclehash, x, y, z, GetEntityHeading(PlayerPedId())+90, 1, 0.0, true, false)
    SetEntityAsMissionEntity(veh, true, true)
    TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
end)