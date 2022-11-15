local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
MySQL = module("vrp_mysql", "MySQL")

--MySQL.createCommand("vRP/carsell_insert","INSERT INTO carsell (owner, license, hash, price) VALUES (@id, @plate, @hash, @price)")   
--MySQL.createCommand("vRP/get_carsell","SELECT * FROM carsell WHERE license = @plate")   
--MySQL.createCommand("vRP/get_all_carsails","SELECT * FROM carsell")   
--MySQL.createCommand("vRP/remove_carsell","DELETE FROM carsell WHERE license = @plate")

DeleteVehicle = function(source)
    TriggerClientEvent('carsell:deleteveh', source)
end

SpawnVehicle = function(source, hash)
    TriggerClientEvent('carsell:spawncar', source, hash)
end

RegisterCommand('sellcar', function(source, args)
    local price = tonumber(args[1]) or nil

    local Reply = function(message)
        TriggerClientEvent("chat:addMessage", source, {
            color = {255, 20, 147},
            args = {"Sellcar", message}
        })
    end

    if price == nil then 
        return Reply("Invalid price")
    end

    local veh = GetVehiclePedIsIn(GetPlayerPed(source), false)
    if veh == 0 then
        return Reply("You are not in a car")
    end

    local model = GetEntityModel(veh)
    local car = GetVehicleNumberPlateText(veh)
    
    local id = vRP.getUserId({source})

    MySQL.query("vRP/get_carsell", {plate=car}, function(callback)
        if table.unpack(callback) ~= nil then
            return Reply("Whoops, this car is already for sale")
        end

        DeleteVehicle(source)

        MySQL.query("vRP/carsell_insert", {id=id, plate=car, hash=model, price=tostring(price)})
        return Reply("Success! Your car is now up for sale for "..args[1]..'$')
    end)
end)

RegisterCommand('buycar', function(source, args)
    local Reply = function(message)
        TriggerClientEvent("chat:addMessage", source, {
            color = {255, 20, 147},
            args = {"Sellcar", message}
        })
    end
    local plate = args[1]
    if plate == nil then return Reply("Invalid licenseplate") end

    MySQL.query("vRP/get_carsell", {plate=plate}, function(callback)
        if table.unpack(callback) == nil then
            return Reply("Cannot find vehicle, sorry")
        end

        SpawnVehicle(source, table.unpack(callback)['hash'])

        Reply("You bought a car!")
        
        MySQL.query("vRP/remove_carsell", {plate=plate})
    end)
end)

RegisterCommand('carlist', function(source, args)
    local Reply = function(message)
        TriggerClientEvent("chat:addMessage", source, {
            color = {255, 20, 147},
            args = {"Sellcar", message}
        })
    end

    MySQL.query("vRP/get_all_carsails", {}, function(callback)
        if #callback == 0 then
            return Reply("There is no cars for sale")
        end
        for k,v in pairs(callback) do
            Reply(tostring(k)..": Car: "..v['license'].." Price: "..v['price'].."$ Owner: "..v['owner'])
        end
    end)
end)