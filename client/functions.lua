ESX = {}
Core = {}
ESX.PlayerData = {}
ESX.PlayerLoaded = false
Core.Input = {}
ESX.UI = {}
ESX.UI.Menu = {}
ESX.UI.Menu.RegisteredTypes = {}
ESX.UI.Menu.Opened = {}

local isDebug = false
local MAX_DEFORM_ITERATIONS = 50
local DEFORMATION_DAMAGE_THRESHOLD = 0.05

ESX.Game = {}
ESX.Game.Utils = {}

ESX.Scaleform = {}
ESX.Scaleform.Utils = {}

ESX.Streaming = {}
local GU = {}
GU.Time = 0

exports("GetVehicleDeformation", GetVehicleDeformation)
exports("SetVehicleDeformation", SetVehicleDeformation)
-- DEFORMATION

AddStateBagChangeHandler('deformation' --[[key filter]], nil --[[bag filter]], function(bagName, key, value, _unused, replicated)
	Wait(100)
	local entity = GetEntityFromStateBagName(bagName)
	if not value or entity == 0 then return end
	local ent = Entity(entity).state
	local plate = GetVehicleNumberPlateText(entity)
	SetVehicleDeformation(entity,value)
end)

exports('phonecheck2', function()
    for k, v in ipairs(ESX.PlayerData.inventory) do
        if v.count > 0 then
            if v.name == 'phone' then
               return true
            else
               --ESX.ShowNotification('Nincs nálad telefon')
               --return false
            end
        else
            --ESX.ShowNotification('Nincs nálad telefon')
            --return false
        end
    end
end)

exports('phonecheck', function()
    local count = exports.ox_inventory:Search('count', 'phone')
        if count >= 1 then
            return true
        elseif count <= 0 then
            ESX.ShowNotification('Nincs nálad ~g~telefon')
            return false
        end
end)

local entityEnumerator = {
    __gc = function(enum)
      if enum.destructor and enum.handle then
        enum.destructor(enum.handle)
      end
      enum.destructor = nil
      enum.handle = nil
    end
  }
  
  local function EnumerateEntities(initFunc, moveFunc, disposeFunc)
    return coroutine.wrap(function()
      local iter, id = initFunc()
      if not id or id == 0 then
        disposeFunc(iter)
        return
      end
      
      local enum = {handle = iter, destructor = disposeFunc}
      setmetatable(enum, entityEnumerator)
      
      local next = true
      repeat
        coroutine.yield(id)
        next, id = moveFunc(iter)
      until not next
      
      enum.destructor, enum.handle = nil, nil
      disposeFunc(iter)
    end)
  end
  
function EnumerateObjects()
  return EnumerateEntities(FindFirstObject, FindNextObject, EndFindObject)
end
  
function EnumeratePeds()
  return EnumerateEntities(FindFirstPed, FindNextPed, EndFindPed)
end
  
function EnumerateVehicles()
  return EnumerateEntities(FindFirstVehicle, FindNextVehicle, EndFindVehicle)
end
  
function EnumeratePickups()
  return EnumerateEntities(FindFirstPickup, FindNextPickup, EndFindPickup)
end


function ESX.IsPlayerLoaded()
	return ESX.PlayerLoaded
end

function ESX.GetPlayerData()
	return ESX.PlayerData
end

function ESX.SearchInventory(items, count)
    if type(items) == 'string' then
        items = {items}
    end

    local returnData = {}
    local itemCount = #items

    for i = 1, itemCount do
        local itemName = items[i]
        returnData[itemName] = count and 0

        for _, item in pairs(ESX.PlayerData.inventory) do
            if item.name == itemName then
                if count then
                    returnData[itemName] = returnData[itemName] + item.count
                else
                    returnData[itemName] = item
                end
            end
        end
    end

    if next(returnData) then
        return itemCount == 1 and returnData[items[1]] or returnData
    end
end

function ESX.SetPlayerData(key, val)
    local current = ESX.PlayerData[key]
    ESX.PlayerData[key] = val
    if key ~= 'inventory' and key ~= 'loadout' then
        if type(val) == 'table' or val ~= current then
            TriggerEvent('esx:setPlayerData', key, val, current)
        end
    end
end

function ESX.Progressbar(message,length, Options)
    exports["esx_progressbar"]:Progressbar(message,length, Options)
end


function ESX.ShowNotification(message, type, length)
    if Config.NativeNotify then 
     BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message)
    EndTextCommandThefeedPostTicker(0,1)
    else 
      exports["esx_notify"]:Notify(type, length, message)
    end
end

function ESX.TextUI(message, type)
	exports["esx_textui"]:TextUI(message, type)
end

function ESX.HideUI()
	exports["esx_textui"]:HideUI()
end


function ESX.ShowAdvancedNotification(sender, subject, msg, textureDict, iconType, flash, saveToBrief, hudColorIndex)
	if saveToBrief == nil then saveToBrief = true end
	AddTextEntry('esxAdvancedNotification', msg)
	BeginTextCommandThefeedPost('esxAdvancedNotification')
	if hudColorIndex then ThefeedSetNextPostBackgroundColor(hudColorIndex) end
	EndTextCommandThefeedPostMessagetext(textureDict, textureDict, false, iconType, sender, subject)
	EndTextCommandThefeedPostTicker(flash or false, saveToBrief)
end

function ESX.ShowHelpNotification(msg, thisFrame, beep, duration)
	AddTextEntry('esxHelpNotification', msg)

	if thisFrame then
		DisplayHelpTextThisFrame('esxHelpNotification', false)
	else
		if beep == nil then beep = true end
		BeginTextCommandDisplayHelp('esxHelpNotification')
		EndTextCommandDisplayHelp(0, false, beep, duration or -1)
	end
end

function ESX.ShowFloatingHelpNotification(msg, coords)
	AddTextEntry('esxFloatingHelpNotification', msg)
	SetFloatingHelpTextWorldPosition(1, coords)
	SetFloatingHelpTextStyle(1, 1, 2, -1, 3, 0)
	BeginTextCommandDisplayHelp('esxFloatingHelpNotification')
	EndTextCommandDisplayHelp(2, false, false, -1)
end

ESX.HashString = function(str)
    local format = string.format
    local upper = string.upper
    local gsub = string.gsub
    local hash = joaat(str)
    local input_map = format("~INPUT_%s~", upper(format("%x", hash)))
    input_map = string.gsub(input_map, "FFFFFFFF", "")

    return input_map
end

if GetResourceState("esx_context") ~= "missing" then
    function ESX.OpenContext(...)
        exports["esx_context"]:Open(...)
    end

    function ESX.PreviewContext(...)
        exports["esx_context"]:Preview(...)
    end

    function ESX.CloseContext(...)
        exports["esx_context"]:Close(...)
    end

    function ESX.RefreshContext(...)
       exports["esx_context"]:Refresh(...) 
    end
else 
    function ESX.OpenContext()
        print("[ERROR] Tried to open context menu, but esx_context is missing!")
    end

    function ESX.PreviewContext()
        print("[ERROR] Tried to preview context menu, but esx_context is missing!")
    end

    function ESX.CloseContext()
        print("[ERROR] Tried to close context menu, but esx_context is missing!")
    end

    function ESX.RefreshContext()
        print("[ERROR] Tried to close context menu, but esx_context is missing!")
    end
end

ESX.RegisterInput = function(command_name, label, input_group, key, on_press, on_release)
    RegisterCommand(on_release ~= nil and "+" .. command_name or command_name, on_press)
    Core.Input[command_name] = on_release ~= nil and ESX.HashString("+" .. command_name) or ESX.HashString(command_name)
    if on_release then
        RegisterCommand("-" .. command_name, on_release)
    end
    RegisterKeyMapping(on_release ~= nil and "+" .. command_name or command_name, label, input_group, key)
end

function ESX.UI.Menu.RegisterType(type, open, close)
	ESX.UI.Menu.RegisteredTypes[type] = {
		open   = open,
		close  = close
	}
end

function ESX.UI.Menu.Open(type, namespace, name, data, submit, cancel, change, close)
	local menu = {}

	menu.type      = type
	menu.namespace = namespace
	menu.name      = name
	menu.data      = data
	menu.submit    = submit
	menu.cancel    = cancel
	menu.change    = change

	menu.close = function()

		ESX.UI.Menu.RegisteredTypes[type].close(namespace, name)

		for i=1, #ESX.UI.Menu.Opened, 1 do
			if ESX.UI.Menu.Opened[i] then
				if ESX.UI.Menu.Opened[i].type == type and ESX.UI.Menu.Opened[i].namespace == namespace and ESX.UI.Menu.Opened[i].name == name then
					ESX.UI.Menu.Opened[i] = nil
				end
			end
		end

		if close then
			close()
		end

	end

	menu.update = function(query, newData)

		for i=1, #menu.data.elements, 1 do
			local match = true

			for k,v in pairs(query) do
				if menu.data.elements[i][k] ~= v then
					match = false
				end
			end

			if match then
				for k,v in pairs(newData) do
					menu.data.elements[i][k] = v
				end
			end
		end

	end

	menu.refresh = function()
		ESX.UI.Menu.RegisteredTypes[type].open(namespace, name, menu.data)
	end

	menu.setElement = function(i, key, val)
		menu.data.elements[i][key] = val
	end

	menu.setElements = function(newElements)
		menu.data.elements = newElements
	end

	menu.setTitle = function(val)
		menu.data.title = val
	end

	menu.removeElement = function(query)
		for i=1, #menu.data.elements, 1 do
			for k,v in pairs(query) do
				if menu.data.elements[i] then
					if menu.data.elements[i][k] == v then
						table.remove(menu.data.elements, i)
						break
					end
				end

			end
		end
	end

	ESX.UI.Menu.Opened[#ESX.UI.Menu.Opened + 1] = menu
	ESX.UI.Menu.RegisteredTypes[type].open(namespace, name, data)

	return menu
end

function ESX.UI.Menu.Close(type, namespace, name)
	for i=1, #ESX.UI.Menu.Opened, 1 do
		if ESX.UI.Menu.Opened[i] then
			if ESX.UI.Menu.Opened[i].type == type and ESX.UI.Menu.Opened[i].namespace == namespace and ESX.UI.Menu.Opened[i].name == name then
				ESX.UI.Menu.Opened[i].close()
				ESX.UI.Menu.Opened[i] = nil
			end
		end
	end
end

function ESX.UI.Menu.CloseAll()
	for i=1, #ESX.UI.Menu.Opened, 1 do
		if ESX.UI.Menu.Opened[i] then
			ESX.UI.Menu.Opened[i].close()
			ESX.UI.Menu.Opened[i] = nil
		end
	end
end

function ESX.UI.Menu.GetOpened(type, namespace, name)
	for i=1, #ESX.UI.Menu.Opened, 1 do
		if ESX.UI.Menu.Opened[i] then
			if ESX.UI.Menu.Opened[i].type == type and ESX.UI.Menu.Opened[i].namespace == namespace and ESX.UI.Menu.Opened[i].name == name then
				return ESX.UI.Menu.Opened[i]
			end
		end
	end
end

function ESX.UI.Menu.GetOpenedMenus()
	return ESX.UI.Menu.Opened
end

function ESX.UI.Menu.IsOpen(type, namespace, name)
	return ESX.UI.Menu.GetOpened(type, namespace, name) ~= nil
end

function ESX.UI.ShowInventoryItemNotification(add, item, count)
	SendNUIMessage({
		action = 'inventoryNotification',
		add    = add,
		item   = item,
		count  = count
	})
end

function ESX.Game.GetPedMugshot(ped, transparent)
    if not DoesEntityExist(ped) then return end
    local mugshot = transparent and RegisterPedheadshotTransparent(ped) or RegisterPedheadshot(ped)

    while not IsPedheadshotReady(mugshot) do
        Wait(0)
    end

    return mugshot, GetPedheadshotTxdString(mugshot)
end

ESX.Game.Teleport = function(entity, coords, cb)
	--local vector = type(coords) == "vector4" and coords or type(coords) == "vector3" and vector4(coords, 0.0) or vec(coords.x, coords.y, coords.z, coords.heading or 0.0)

	if DoesEntityExist(entity) then
		RequestCollisionAtCoord(coords.x, coords.y, coords.z)
		while not HasCollisionLoadedAroundEntity(entity) do
			Wait(10)
		end

		SetEntityCoords(entity, coords.x, coords.y, coords.z, false, false, false, false)
		SetEntityHeading(entity, coords.heading or 0.0)
	end

	if cb then
		cb()
	end
end

ESX.Game.SpawnObject = function(object, coords, cb, networked)
    networked = networked == nil and true or networked
    if networked then 
        ESX.TriggerServerCallback('esx:Onesync:SpawnObject', function(NetworkID)
            if cb then
                local obj = NetworkGetEntityFromNetworkId(NetworkID)
                local es = 0
                while not DoesEntityExist(obj) do
                    obj = NetworkGetEntityFromNetworkId(NetworkID)
                    Wait(0)
                    es += 1
                    if es > 250 then
                        break
                    end
                end
                cb(obj)
            end
        end, object, coords, 0.0)
    else 
        local model = type(object) == 'number' and object or joaat(object)
        local vector = type(coords) == "vector3" and coords or vec(coords.x, coords.y, coords.z)
        CreateThread(function()
            ESX.Streaming.RequestModel(model)

            local obj = CreateObject(model, vector.xyz, networked, false, true)
            if cb then
                cb(obj)
            end
        end)
    end
end

function ESX.Game.SpawnLocalObject(object, coords, cb)
	ESX.Game.SpawnObject(object, coords, cb, false)
end

ESX.Game.DeleteVehicle = function(vehicle)
	SetEntityAsMissionEntity(vehicle, false, true)
	DeleteVehicle(vehicle)
end

function ESX.Game.DeleteObject(object)
	SetEntityAsMissionEntity(object, false, true)
	DeleteObject(object)
end

---@param vehicle number|string
---@param coords any?
---@param cb function?
ESX.Game.SpawnVehicle = function(vehicle, coords, heading, cb)
    local model = type(vehicle) == 'number' and vehicle or joaat(vehicle)
    --local vector = type(coords) == "vector3" and coords or vec(coords.x, coords.y, coords.z)

    local playerCoords = GetEntityCoords(ESX.PlayerData.ped)
    if not playerCoords then 
        return
    end

    CreateThread(function()
    GU.Time = GetGameTimer()
	ESX.Streaming.RequestModel(model)

	RequestCollisionAtCoord(coords.x, coords.y, coords.z)

	print('Spawning ' .. tostring(model) .. ' at ' .. tostring(vector4(coords.x, coords.y, coords.z, heading + 0.0)))
	local vehicle = CreateVehicle(model, coords.x, coords.y, coords.z, heading, true, false)
	local id = NetworkGetNetworkIdFromEntity(vehicle)
		SetNetworkIdCanMigrate(id, true)
		SetEntityAsMissionEntity(vehicle, true, false)
		SetVehicleHasBeenOwnedByPlayer(vehicle, true)
		SetVehicleNeedsToBeHotwired(vehicle, false)
		SetVehRadioStation(vehicle, 'OFF')
		SetModelAsNoLongerNeeded(model)

		if DoesEntityExist(vehicle) then
            local xxxx = 0
			while not HasCollisionLoadedAroundEntity(vehicle) do
                print("Request Collision: " ..xxxx)
			    RequestCollisionAtCoord(vector.xyz)
                if xxxx > 40 then
                    break
                end
                xxxx += 1
			    Wait(50)
			end
		end

        --[[local x2 = 0

		repeat
	        NetworkRequestControlOfEntity(vehicle)
		      Wait(50)
                      x2 += 1
                      print("Request Control Of Entity: " ..x2)
		until NetworkHasControlOfEntity(vehicle) or x2 == 40]]
                
		if cb ~= nil then
			cb(vehicle)
            local elapsedTime = (GetGameTimer() - GU.Time)
            print(('[^2INFO^7] Spawn time %s ms'):format(elapsedTime))
		end
    end)
end

ESX.Game.SpawnLocalVehicle = function(modelName, coords, heading, cb)
    local model = (type(modelName) == 'number' and modelName or joaat(modelName))
    CreateThread(function()
    GU.Time = GetGameTimer()
	ESX.Streaming.RequestModel(model)

	RequestCollisionAtCoord(coords.x, coords.y, coords.z)

	local vehicle = CreateVehicle(model, coords.x, coords.y, coords.z, heading + 0.0, false, false)

		SetVehicleHasBeenOwnedByPlayer(vehicle, true)
		SetVehicleNeedsToBeHotwired(vehicle, false)
		SetModelAsNoLongerNeeded(model)
		SetVehRadioStation(vehicle, 'OFF')

		if DoesEntityExist(vehicle) then
            local x = 0
			while not HasCollisionLoadedAroundEntity(vehicle) do
                print("Request Collision: " ..x)
			    RequestCollisionAtCoord(coords.x, coords.y, coords.z)
                    if x > 40 then
                        break
                    end
                    x += 1
			    Wait(50)
			end
		end

		if cb ~= nil then
			cb(vehicle)
                        local elapsedTime = (GetGameTimer() - GU.Time)
                        print(('[^2INFO^7] Spawn time %s ms'):format(elapsedTime))
		end
    end)
end

ESX.Game.SpawnPed = function(modelName, coords, heading, cb)
    local model = (type(modelName) == 'number' and modelName or joaat(modelName))
    CreateThread(function()
	ESX.Streaming.RequestModel(model)

	RequestCollisionAtCoord(coords.x, coords.y, coords.z)

	print('Spawning ped ' .. tostring(model) .. ' at ' .. tostring(vector4(coords.x, coords.y, coords.z, heading)))
	local ped = CreatePed(0, model, coords.x, coords.y, coords.z, heading, true, false)
	local id = NetworkGetNetworkIdFromEntity(ped)
                print('Ped netid: ' ..id)
		SetNetworkIdCanMigrate(id, true)
                SetNetworkIdExistsOnAllMachines(id, true)
		SetModelAsNoLongerNeeded(model)

		if DoesEntityExist(ped) then
                        local x = 0
			while not HasCollisionLoadedAroundEntity(ped) do
			   RequestCollisionAtCoord(coords.x, coords.y, coords.z)
                           if x > 40 then
                              break
                           end
                        x += 1
			Wait(50)
			end
		end

		repeat
		NetworkRequestControlOfEntity(ped)
		Wait(0)
		until NetworkHasControlOfEntity(ped)

		if cb ~= nil then
			cb(ped)
		end
    end)
end

function ESX.Game.IsVehicleEmpty(vehicle)
	local passengers = GetVehicleNumberOfPassengers(vehicle)
	local driverSeatFree = IsVehicleSeatFree(vehicle, -1)

	return passengers == 0 and driverSeatFree
end

function ESX.Game.GetObjects() -- Leave the function for compatibility
	return GetGamePool('CObject')
end

function ESX.Game.GetPeds(onlyOtherPeds)
    local myPed, pool = ESX.PlayerData.ped, GetGamePool('CPed')

    if not onlyOtherPeds then
        return pool
    end

    local peds = {}
    for i = 1, #pool do
        if pool[i] ~= myPed then
            peds[#peds + 1] = pool[i]
        end
    end

    return peds
end

function ESX.Game.GetVehicles() -- Leave the function for compatibility
	return GetGamePool('CVehicle')
end

function ESX.Game.GetPlayers(onlyOtherPlayers, returnKeyValue, returnPeds)
    local players, myPlayer = {}, PlayerId()

    for k, player in ipairs(GetActivePlayers()) do
        local ped = GetPlayerPed(player)

        if DoesEntityExist(ped) and ((onlyOtherPlayers and player ~= myPlayer) or not onlyOtherPlayers) then
            if returnKeyValue then
                players[player] = ped
            else
                players[#players + 1] = returnPeds and ped or player
            end
        end
    end

    return players
end

function ESX.Game.GetClosestObject(coords, modelFilter)
	return ESX.Game.GetClosestEntity(ESX.Game.GetObjects(), false, coords, modelFilter)
end

function ESX.Game.GetClosestPed(coords, modelFilter)
	return ESX.Game.GetClosestEntity(ESX.Game.GetPeds(true), false, coords, modelFilter)
end

function ESX.Game.GetClosestPlayer(coords)
	return ESX.Game.GetClosestEntity(ESX.Game.GetPlayers(true, true), true, coords, nil)
end

function ESX.Game.GetClosestVehicle(coords, modelFilter)
	return ESX.Game.GetClosestEntity(ESX.Game.GetVehicles(), false, coords, modelFilter)
end

local function EnumerateEntitiesWithinDistance(entities, isPlayerEntities, coords, maxDistance)
	local nearbyEntities = {}

	if coords then
		coords = vector3(coords.x, coords.y, coords.z)
	else
		local playerPed = ESX.PlayerData.ped
		coords = GetEntityCoords(playerPed)
	end

	for k,entity in pairs(entities) do
		local distance = #(coords - GetEntityCoords(entity))

		if distance <= maxDistance then
			nearbyEntities[#nearbyEntities + 1] = isPlayerEntities and k or entity
		end
	end

	return nearbyEntities
end

function ESX.Game.GetPlayersInArea(coords, maxDistance)
	return EnumerateEntitiesWithinDistance(ESX.Game.GetPlayers(true, true), true, coords, maxDistance)
end

function ESX.Game.GetVehiclesInArea(coords, maxDistance)
	return EnumerateEntitiesWithinDistance(ESX.Game.GetVehicles(), false, coords, maxDistance)
end

function ESX.Game.IsSpawnPointClear(coords, maxDistance)
	return #ESX.Game.GetVehiclesInArea(coords, maxDistance) == 0
end


function ESX.Game.GetClosestEntity(entities, isPlayerEntities, coords, modelFilter)
	local closestEntity, closestEntityDistance, filteredEntities = -1, -1, nil

	if coords then
		coords = vector3(coords.x, coords.y, coords.z)
	else
		local playerPed = ESX.PlayerData.ped
		coords = GetEntityCoords(playerPed)
	end

	if modelFilter then
		filteredEntities = {}

		for k,entity in pairs(entities) do
			if modelFilter[GetEntityModel(entity)] then
				filteredEntities[#filteredEntities + 1] = entity
			end
		end
	end

	for k,entity in pairs(filteredEntities or entities) do
		local distance = #(coords - GetEntityCoords(entity))

		if closestEntityDistance == -1 or distance < closestEntityDistance then
			closestEntity, closestEntityDistance = isPlayerEntities and k or entity, distance
		end
	end

	return closestEntity, closestEntityDistance
end

function ESX.Game.GetVehicleInDirection()
    local playerPed = ESX.PlayerData.ped
    local playerCoords = GetEntityCoords(playerPed)
    local inDirection = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 5.0, 0.0)
    local rayHandle = StartExpensiveSynchronousShapeTestLosProbe(playerCoords.x, playerCoords.y, playerCoords.z, inDirection, 10, playerPed, 0)
    local numRayHandle, hit, endCoords, surfaceNormal, entityHit = GetShapeTestResult(rayHandle)

    if hit == 1 and GetEntityType(entityHit) == 2 then
        local entityCoords = GetEntityCoords(entityHit)
        return entityHit, entityCoords
    end

    return nil
end

SetVehicleDeformation = function(vehicle, deformationPoints, callback)
    assert(vehicle ~= nil and DoesEntityExist(vehicle), "Parameter \"vehicle\" must be a valid vehicle entity!")
    assert(deformationPoints ~= nil and type(deformationPoints) == "table", "Parameter \"deformationPoints\" must be a table!")
    CreateThread(function()
		local min, max = GetModelDimensions(GetEntityModel(vehicle))
        local damageMult = #(max - min) * 3.5		-- might need some more experimentation

        local printMsg = false
		for i, def in ipairs(deformationPoints) do
			def[1] = vector3(Round(def[1].x,2), Round(def[1].y,2), Round(def[1].z,2))
		end
		local deform = true
		local iteration = 0
		while (deform and iteration < MAX_DEFORM_ITERATIONS) do
			deform = false
			for i, def in ipairs(deformationPoints) do
				if (#(GetVehicleDeformationAtPos(vehicle, def[1])) < Round(def[2]*0.99,2)) then
					SetVehicleDamage(vehicle, def[1] * 2.0, Round(def[2] * damageMult,2), 1000.0, true)
					deform = true
				end
			end
			iteration = iteration + 1
			Citizen.Wait(100)
		end
        if (callback) then
		    callback()
        end
	end)
end

GetVehicleDeformation = function(vehicle)
    assert(vehicle ~= nil and DoesEntityExist(vehicle), "Parameter \"vehicle\" must be a valid vehicle entity!")
	local min, max = GetModelDimensions(GetEntityModel(vehicle))
	local X = Round((max.x - min.x) * 0.5, 2)
	local Y = Round((max.y - min.y) * 0.5, 2)
	local Z = Round((max.z - min.z) * 0.5, 2)
	local halfY = Round(Y * 0.5, 2)
	local positions = {
		vector3(-X, Y,  0.0),
		vector3(-X, Y,  Z),

		vector3(0.0, Y,  0.0),
		vector3(0.0, Y,  Z),

		vector3(X, Y,  0.0),
		vector3(X, Y,  Z),


		vector3(-X, halfY,  0.0),
		vector3(-X, halfY,  Z),

                --új
	        vector3(-X, halfY + (halfY / 2),  0.0),
		vector3(-X, halfY + (halfY / 2),  Z),

		vector3(-X, halfY - (halfY / 2),  0.0),
		vector3(-X, halfY - (halfY / 2),  Z),
                --

		vector3(0.0, halfY,  0.0),
		vector3(0.0, halfY,  Z),

		vector3(X, halfY,  0.0),
		vector3(X, halfY,  Z),
       
                --új
	        vector3(X, halfY + (halfY / 2),  0.0),
		vector3(X, halfY + (halfY / 2),  Z),

		vector3(X, halfY - (halfY / 2),  0.0),
		vector3(X, halfY - (halfY / 2),  Z),
                --

		vector3(-X, 0.0,  0.0),
		vector3(-X, 0.0,  Z),

		vector3(0.0, 0.0,  0.0),
		vector3(0.0, 0.0,  Z),

		vector3(X, 0.0,  0.0),
		vector3(X, 0.0,  Z),


		vector3(-X, -halfY,  0.0),
		vector3(-X, -halfY,  Z),

	        vector3(-X, -(halfY + (halfY / 2)),  0.0),
		vector3(-X, -(halfY + (halfY / 2)),  Z),

		vector3(-X, -(halfY - (halfY / 2)),  0.0),
		vector3(-X, -(halfY - (halfY / 2)),  Z),

		vector3(0.0, -halfY,  0.0),
		vector3(0.0, -halfY,  Z),

		vector3(0.0, -(halfY + (halfY / 2)),  0.0),
		vector3(0.0, -(halfY + (halfY / 2)),  Z),

		vector3(0.0, -(halfY - (halfY / 2)),  0.0),
		vector3(0.0, -(halfY - (halfY / 2)),  Z),

		vector3(X, -halfY,  0.0),
		vector3(X, -halfY,  Z),

		vector3(X, -(halfY + (halfY / 2)),  0.0),
		vector3(X, -(halfY + (halfY / 2)),  Z),

		vector3(X, -(halfY - (halfY / 2)),  0.0),
		vector3(X, -(halfY - (halfY / 2)),  Z),


		vector3(-X, -Y,  0.0),
		vector3(-X, -Y,  Z),

		vector3(0.0, -Y,  0.0),
		vector3(0.0, -Y,  Z),

		vector3(X, -Y,  0.0),
		vector3(X, -Y,  Z),


		vector3(-(X / 2), Y,  0.0),
		vector3(-(X / 2), Y,  Z),

		vector3((X / 2), Y,  0.0),
		vector3((X / 2), Y,  Z),

		vector3(-(X / 2), halfY,  0.0),
		vector3(-(X / 2), halfY,  Z),

		vector3(-(X / 2), halfY + (halfY / 2),  0.0),
		vector3(-(X / 2), halfY + (halfY / 2),  Z),

		vector3(-(X / 2), halfY - (halfY / 2),  0.0),
		vector3(-(X / 2), halfY - (halfY / 2),  Z),
		vector3((X / 2), halfY + (halfY / 2),  0.0),
		vector3((X / 2), halfY + (halfY / 2),  Z),

		vector3((X / 2), halfY - (halfY / 2),  0.0),
		vector3((X / 2), halfY - (halfY / 2),  Z),

		vector3(-(X / 2), 0.0,  0.0),
		vector3(-(X / 2), 0.0,  Z),

		vector3(-(X / 2), -halfY,  0.0),
		vector3(-(X / 2), -halfY,  Z),

		vector3(-(X / 2), -(halfY + (halfY / 2)),  0.0),
		vector3(-(X / 2), -(halfY + (halfY / 2)),  Z),

		vector3(-(X / 2), -(halfY - (halfY / 2)),  0.0),
		vector3(-(X / 2), -(halfY - (halfY / 2)),  Z),

		vector3((X / 2), -halfY,  0.0),
		vector3((X / 2), -halfY,  Z),

		vector3((X / 2), -(halfY + (halfY / 2)),  0.0),
		vector3((X / 2), -(halfY + (halfY / 2)),  Z),

		vector3((X / 2), -(halfY - (halfY / 2)),  0.0),
		vector3((X / 2), -(halfY - (halfY / 2)),  Z),

		vector3(-(X / 2), -Y,  0.0),
		vector3(-(X / 2), -Y,  Z),

		vector3((X / 2), -Y,  0.0),
		vector3((X / 2), -Y,  Z),
		vector3(-X, Y,  -Z),

		vector3(0.0, Y,  -Z),

		vector3(X, Y,  -Z),

		vector3(-X, halfY,  -Z),

		vector3(-X, halfY + (halfY / 2),  -Z),

		vector3(-X, halfY - (halfY / 2),  -Z),

		vector3(0.0, halfY,  -Z),

		vector3(X, halfY + (halfY / 2),  -Z),

		vector3(X, halfY - (halfY / 2),  -Z),

		vector3(-X, 0.0,  -Z),

		vector3(0.0, 0.0,  -Z),

		vector3(X, 0.0,  -Z),

		vector3(-X, -halfY,  -Z),

		vector3(-X, -(halfY + (halfY / 2)),  -Z),

		vector3(-X, -(halfY - (halfY / 2)),  -Z),

		vector3(0.0, -halfY,  -Z),

		vector3(0.0, -(halfY + (halfY / 2)),  -Z),

		vector3(0.0, -(halfY - (halfY / 2)),  -Z),

		vector3(X, -halfY,  -Z),

		vector3(X, -(halfY + (halfY / 2)),  -Z),

		vector3(X, -(halfY - (halfY / 2)),  -Z),

		vector3(-X, -Y,  -Z),

		vector3(0.0, -Y,  -Z),

		vector3(X, -Y,  -Z),

		vector3(-(X / 2), Y,  -Z),

		vector3((X / 2), Y,  -Z),

		vector3(-(X / 2), halfY,  -Z),

		vector3(-(X / 2), halfY + (halfY / 2),  -Z),

		vector3(-(X / 2), halfY - (halfY / 2),  -Z),
		vector3((X / 2), halfY + (halfY / 2),  -Z),

		vector3((X / 2), halfY - (halfY / 2),  -Z),

		vector3(-(X / 2), 0.0,  -Z),

		vector3(-(X / 2), -halfY,  -Z),

		vector3(-(X / 2), -(halfY + (halfY / 2)),  -Z),

		vector3(-(X / 2), -(halfY - (halfY / 2)),  -Z),

		vector3((X / 2), -halfY,  -Z),

		vector3((X / 2), -(halfY + (halfY / 2)),  -Z),

		vector3((X / 2), -(halfY - (halfY / 2)),  -Z),


		vector3(-(X / 2), -Y,  -Z),

		vector3((X / 2), -Y,  -Z),
	}
        local deformationPoints = {}
	for i, pos in ipairs(positions) do
		local dmg = math.floor(#(GetVehicleDeformationAtPos(vehicle, pos)) * 1000.0) / 1000.0
		if (dmg > DEFORMATION_DAMAGE_THRESHOLD) then
			table.insert(deformationPoints, { pos, dmg })
		end
	end
	return deformationPoints
end

IsDeformationWorse = function(newDef, oldDef)
  if newDef == nil and oldDef == nil then return false end
	if (oldDef == nil or #newDef > #oldDef) then
		return true
	elseif (#newDef < #oldDef) then
		return false
	end

	for i, new in ipairs(newDef) do
		local found = false
		for j, old in ipairs(oldDef) do
			if (new[1] == old[1]) then
				found = true

				if (new[2] > old[2]) then
					return true
				end
			end
		end

		if (not found) then
			return true
		end
	end

	return false
end

GetVehicleOffsetsForDeformation = function(vehicle)
	local min, max = GetModelDimensions(GetEntityModel(vehicle))
	local X = Round((max.x - min.x) * 0.5, 2)
	local Y = Round((max.y - min.y) * 0.5, 2)
	local Z = Round((max.z - min.z) * 0.5, 2)
	local halfY = Round(Y * 0.5, 2)

	return {
		vector3(-X, Y,  0.0),
		vector3(-X, Y,  Z),

		vector3(0.0, Y,  0.0),
		vector3(0.0, Y,  Z),

		vector3(X, Y,  0.0),
		vector3(X, Y,  Z),


		vector3(-X, halfY,  0.0),
		vector3(-X, halfY,  Z),

		vector3(0.0, halfY,  0.0),
		vector3(0.0, halfY,  Z),

		vector3(X, halfY,  0.0),
		vector3(X, halfY,  Z),


		vector3(-X, 0.0,  0.0),
		vector3(-X, 0.0,  Z),

		vector3(0.0, 0.0,  0.0),
		vector3(0.0, 0.0,  Z),

		vector3(X, 0.0,  0.0),
		vector3(X, 0.0,  Z),


		vector3(-X, -halfY,  0.0),
		vector3(-X, -halfY,  Z),

		vector3(0.0, -halfY,  0.0),
		vector3(0.0, -halfY,  Z),

		vector3(X, -halfY,  0.0),
		vector3(X, -halfY,  Z),


		vector3(-X, -Y,  0.0),
		vector3(-X, -Y,  Z),

		vector3(0.0, -Y,  0.0),
		vector3(0.0, -Y,  Z),

		vector3(X, -Y,  0.0),
		vector3(X, -Y,  Z),
	}
end

function Round(value, numDecimals)
	return math.floor(value * 10^numDecimals) / 10^numDecimals
end

function toPercent(v)
  return math.floor(v * 100) / 1000
end

ESX.Game.GetVehicleProperties = function(vehicle)
    if not DoesEntityExist(vehicle) then
        return
    end

    local colorPrimary, colorSecondary = GetVehicleColours(vehicle)
    local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)
    local hasCustomPrimaryColor = GetIsVehiclePrimaryColourCustom(vehicle)
    local dashboardColor = GetVehicleDashboardColor(vehicle)
    local interiorColor = GetVehicleInteriorColour(vehicle)
    local customPrimaryColor = nil
    if hasCustomPrimaryColor then
        customPrimaryColor = { GetVehicleCustomPrimaryColour(vehicle) }
    end

    local hasCustomXenonColor, customXenonColorR, customXenonColorG, customXenonColorB = GetVehicleXenonLightsCustomColor(vehicle)
    local customXenonColor = nil
    if hasCustomXenonColor then
        customXenonColor = { customXenonColorR, customXenonColorG, customXenonColorB }
    end

    local hasCustomSecondaryColor = GetIsVehicleSecondaryColourCustom(vehicle)
    local customSecondaryColor = nil
    if hasCustomSecondaryColor then
        customSecondaryColor = { GetVehicleCustomSecondaryColour(vehicle) }
    end

    local extras = {}
    for extraId = 0, 20 do
        if DoesExtraExist(vehicle, extraId) then
            extras[tostring(extraId)] = IsVehicleExtraTurnedOn(vehicle, extraId)
        end
    end

    local driftTyresEnabled = false
    if type(GetDriftTyresEnabled(vehicle) == "boolean") and GetDriftTyresEnabled(vehicle) then
        driftTyresEnabled = true
    end

    local doorsBroken, windowsBroken, tyreBurst = {}, {}, {}
    local numWheels = tostring(GetVehicleNumberOfWheels(vehicle))

    local TyresIndex = {           -- Wheel index list according to the number of vehicle wheels.
        ['2'] = { 0, 4 },          -- Bike and cycle.
        ['3'] = { 0, 1, 4, 5 },    -- Vehicle with 3 wheels (get for wheels because some 3 wheels vehicles have 2 wheels on front and one rear or the reverse).
        ['4'] = { 0, 1, 4, 5 },    -- Vehicle with 4 wheels.
        ['6'] = { 0, 1, 2, 3, 4, 5 } -- Vehicle with 6 wheels.
    }

    if TyresIndex[numWheels] then
        for _, idx in pairs(TyresIndex[numWheels]) do
            tyreBurst[tostring(idx)] = IsVehicleTyreBurst(vehicle, idx, false)
        end
    end

    for windowId = 0, 7 do              -- 13
        RollUpWindow(vehicle, windowId) --fix when you put the car away with the window down
        windowsBroken[tostring(windowId)] = not IsVehicleWindowIntact(vehicle, windowId)
    end

    local numDoors = GetNumberOfVehicleDoors(vehicle)
    if numDoors and numDoors > 0 then
        for doorsId = 0, numDoors do
            doorsBroken[tostring(doorsId)] = IsVehicleDoorDamaged(vehicle, doorsId)
        end
    end

    return {
        model = GetEntityModel(vehicle),
        deformat = json.encode(GetVehicleDeformation(vehicle)),
        wheelData = {
		frontCamber = exports['vstancer']:GetFrontCamber(vehicle)[1],
		rearCamber = exports['vstancer']:GetRearCamber(vehicle)[1],
		frontWidth = exports['vstancer']:GetFrontTrackWidth(vehicle)[1],
		rearWidth = exports['vstancer']:GetRearTrackWidth(vehicle)[1]  
	},
        doorsBroken = doorsBroken,
        windowsBroken = windowsBroken,
        tyreBurst = tyreBurst,
        tyresCanBurst = GetVehicleTyresCanBurst(vehicle),
        plate = ESX.Math.Trim(GetVehicleNumberPlateText(vehicle)),
        plateIndex = GetVehicleNumberPlateTextIndex(vehicle),

        bodyHealth = ESX.Math.Round(GetVehicleBodyHealth(vehicle), 1),
        engineHealth = ESX.Math.Round(GetVehicleEngineHealth(vehicle), 1),
        tankHealth = ESX.Math.Round(GetVehiclePetrolTankHealth(vehicle), 1),

        fuelLevel = ESX.Math.Round(GetVehicleFuelLevel(vehicle), 1),
        dirtLevel = ESX.Math.Round(GetVehicleDirtLevel(vehicle), 1),
        color1 = colorPrimary,
        color2 = colorSecondary,
        customPrimaryColor = customPrimaryColor,
        customSecondaryColor = customSecondaryColor,

        pearlescentColor = pearlescentColor,
        wheelColor = wheelColor,

        dashboardColor = dashboardColor,
        interiorColor = interiorColor,

        wheels = GetVehicleWheelType(vehicle),
        windowTint = GetVehicleWindowTint(vehicle),
        xenonColor = GetVehicleXenonLightsColor(vehicle),
        customXenonColor = customXenonColor,

        neonEnabled = { IsVehicleNeonLightEnabled(vehicle, 0), IsVehicleNeonLightEnabled(vehicle, 1),
            IsVehicleNeonLightEnabled(vehicle, 2), IsVehicleNeonLightEnabled(vehicle, 3) },

        neonColor = table.pack(GetVehicleNeonLightsColour(vehicle)),
        extras = extras,
        driftTyresEnabled = driftTyresEnabled,
        tyreSmokeColor = table.pack(GetVehicleTyreSmokeColor(vehicle)),

        modSpoilers = GetVehicleMod(vehicle, 0),
        modFrontBumper = GetVehicleMod(vehicle, 1),
        modRearBumper = GetVehicleMod(vehicle, 2),
        modSideSkirt = GetVehicleMod(vehicle, 3),
        modExhaust = GetVehicleMod(vehicle, 4),
        modFrame = GetVehicleMod(vehicle, 5),
        modGrille = GetVehicleMod(vehicle, 6),
        modHood = GetVehicleMod(vehicle, 7),
        modFender = GetVehicleMod(vehicle, 8),
        modRightFender = GetVehicleMod(vehicle, 9),
        modRoof = GetVehicleMod(vehicle, 10),
        modRoofLivery = GetVehicleRoofLivery(vehicle),

        modEngine = GetVehicleMod(vehicle, 11),
        modBrakes = GetVehicleMod(vehicle, 12),
        modTransmission = GetVehicleMod(vehicle, 13),
        modHorns = GetVehicleMod(vehicle, 14),
        modSuspension = GetVehicleMod(vehicle, 15),
        modArmor = GetVehicleMod(vehicle, 16),

        modTurbo = IsToggleModOn(vehicle, 18),
        modSmokeEnabled = IsToggleModOn(vehicle, 20),
        modXenon = IsToggleModOn(vehicle, 22),

        modFrontWheels = GetVehicleMod(vehicle, 23),
        modCustomFrontWheels = GetVehicleModVariation(vehicle, 23),
        modBackWheels = GetVehicleMod(vehicle, 24),
        modCustomBackWheels = GetVehicleModVariation(vehicle, 24),

        modPlateHolder = GetVehicleMod(vehicle, 25),
        modVanityPlate = GetVehicleMod(vehicle, 26),
        modTrimA = GetVehicleMod(vehicle, 27),
        modOrnaments = GetVehicleMod(vehicle, 28),
        modDashboard = GetVehicleMod(vehicle, 29),
        modDial = GetVehicleMod(vehicle, 30),
        modDoorSpeaker = GetVehicleMod(vehicle, 31),
        modSeats = GetVehicleMod(vehicle, 32),
        modSteeringWheel = GetVehicleMod(vehicle, 33),
        modShifterLeavers = GetVehicleMod(vehicle, 34),
        modAPlate = GetVehicleMod(vehicle, 35),
        modSpeakers = GetVehicleMod(vehicle, 36),
        modTrunk = GetVehicleMod(vehicle, 37),
        modHydrolic = GetVehicleMod(vehicle, 38),
        modEngineBlock = GetVehicleMod(vehicle, 39),
        modAirFilter = GetVehicleMod(vehicle, 40),
        modStruts = GetVehicleMod(vehicle, 41),
        modArchCover = GetVehicleMod(vehicle, 42),
        modAerials = GetVehicleMod(vehicle, 43),
        modTrimB = GetVehicleMod(vehicle, 44),
        modTank = GetVehicleMod(vehicle, 45),
        modWindows = GetVehicleMod(vehicle, 46),
        modLivery = GetVehicleMod(vehicle, 48) == -1 and GetVehicleLivery(vehicle) or GetVehicleMod(vehicle, 48),
        modLightbar = GetVehicleMod(vehicle, 49)
    }
end

ESX.Game.SetVehicleProperties = function(vehicle, props)
    if not DoesEntityExist(vehicle) then
        return
    end
    local colorPrimary, colorSecondary = GetVehicleColours(vehicle)
    local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)
    SetVehicleModKit(vehicle, 0)

    if props.tyresCanBurst ~= nil then
        SetVehicleTyresCanBurst(vehicle, props.tyresCanBurst)
    end
    if props.customPrimaryColor ~= nil then
        SetVehicleCustomPrimaryColour(vehicle, props.customPrimaryColor[1], props.customPrimaryColor[2],
            props.customPrimaryColor[3])
    end
    if props.customSecondaryColor ~= nil then
        SetVehicleCustomSecondaryColour(vehicle, props.customSecondaryColor[1], props.customSecondaryColor[2],
            props.customSecondaryColor[3])
    end
    if props.color1 ~= nil then
        SetVehicleColours(vehicle, props.color1, colorSecondary)
    end
    if props.color2 ~= nil then
        SetVehicleColours(vehicle, props.color1 or colorPrimary, props.color2)
    end
    if props.pearlescentColor ~= nil then
        SetVehicleExtraColours(vehicle, props.pearlescentColor, wheelColor)
    end

    if props.interiorColor ~= nil then
        SetVehicleInteriorColor(vehicle, props.interiorColor)
    end

    if props.dashboardColor ~= nil then
        SetVehicleDashboardColor(vehicle, props.dashboardColor)
    end

    if props.wheelColor ~= nil then
        SetVehicleExtraColours(vehicle, props.pearlescentColor or pearlescentColor, props.wheelColor)
    end
    if props.wheels ~= nil then
        SetVehicleWheelType(vehicle, props.wheels)
    end
    if props.windowTint ~= nil then
        SetVehicleWindowTint(vehicle, props.windowTint)
    end

    if props.neonEnabled ~= nil then
        SetVehicleNeonLightEnabled(vehicle, 0, props.neonEnabled[1])
        SetVehicleNeonLightEnabled(vehicle, 1, props.neonEnabled[2])
        SetVehicleNeonLightEnabled(vehicle, 2, props.neonEnabled[3])
        SetVehicleNeonLightEnabled(vehicle, 3, props.neonEnabled[4])
    end

    if props.extras ~= nil then
        for extraId, enabled in pairs(props.extras) do
            SetVehicleExtra(vehicle, tonumber(extraId), enabled and 0 or 1)
        end
    end

    if props.driftTyresEnabled then
        SetDriftTyresEnabled(vehicle, true)
    end

    if props.neonColor ~= nil then
        SetVehicleNeonLightsColour(vehicle, props.neonColor[1], props.neonColor[2], props.neonColor[3])
    end
    if props.xenonColor ~= nil then
        SetVehicleXenonLightsColor(vehicle, props.xenonColor)
    end
    if props.customXenonColor ~= nil then
        SetVehicleXenonLightsCustomColor(vehicle, props.customXenonColor[1], props.customXenonColor[2],
            props.customXenonColor[3])
    end
    if props.modSmokeEnabled ~= nil then
        ToggleVehicleMod(vehicle, 20, true)
    end
    if props.tyreSmokeColor ~= nil then
        SetVehicleTyreSmokeColor(vehicle, props.tyreSmokeColor[1], props.tyreSmokeColor[2], props.tyreSmokeColor[3])
    end
    if props.modSpoilers ~= nil then
        SetVehicleMod(vehicle, 0, props.modSpoilers, false)
    end
    if props.modFrontBumper ~= nil then
        SetVehicleMod(vehicle, 1, props.modFrontBumper, false)
    end
    if props.modRearBumper ~= nil then
        SetVehicleMod(vehicle, 2, props.modRearBumper, false)
    end
    if props.modSideSkirt ~= nil then
        SetVehicleMod(vehicle, 3, props.modSideSkirt, false)
    end
    if props.modExhaust ~= nil then
        SetVehicleMod(vehicle, 4, props.modExhaust, false)
    end
    if props.modFrame ~= nil then
        SetVehicleMod(vehicle, 5, props.modFrame, false)
    end
    if props.modGrille ~= nil then
        SetVehicleMod(vehicle, 6, props.modGrille, false)
    end
    if props.modHood ~= nil then
        SetVehicleMod(vehicle, 7, props.modHood, false)
    end
    if props.modFender ~= nil then
        SetVehicleMod(vehicle, 8, props.modFender, false)
    end
    if props.modRightFender ~= nil then
        SetVehicleMod(vehicle, 9, props.modRightFender, false)
    end
    if props.modRoof ~= nil then
        SetVehicleMod(vehicle, 10, props.modRoof, false)
    end

    if props.modRoofLivery ~= nil then
        SetVehicleRoofLivery(vehicle, props.modRoofLivery)
    end

    if props.modEngine ~= nil then
        SetVehicleMod(vehicle, 11, props.modEngine, false)
    end
    if props.modBrakes ~= nil then
        SetVehicleMod(vehicle, 12, props.modBrakes, false)
    end
    if props.modTransmission ~= nil then
        SetVehicleMod(vehicle, 13, props.modTransmission, false)
    end
    if props.modHorns ~= nil then
        SetVehicleMod(vehicle, 14, props.modHorns, false)
    end
    if props.modSuspension ~= nil then
        SetVehicleMod(vehicle, 15, props.modSuspension, false)
    end
    if props.modArmor ~= nil then
        SetVehicleMod(vehicle, 16, props.modArmor, false)
    end
    if props.modTurbo ~= nil then
        ToggleVehicleMod(vehicle, 18, props.modTurbo)
    end
    if props.modXenon ~= nil then
        ToggleVehicleMod(vehicle, 22, props.modXenon)
    end
    if props.modFrontWheels ~= nil then
        SetVehicleMod(vehicle, 23, props.modFrontWheels, props.modCustomFrontWheels)
    end
    if props.modBackWheels ~= nil then
        SetVehicleMod(vehicle, 24, props.modBackWheels, props.modCustomBackWheels)
    end
    if props.modPlateHolder ~= nil then
        SetVehicleMod(vehicle, 25, props.modPlateHolder, false)
    end
    if props.modVanityPlate ~= nil then
        SetVehicleMod(vehicle, 26, props.modVanityPlate, false)
    end
    if props.modTrimA ~= nil then
        SetVehicleMod(vehicle, 27, props.modTrimA, false)
    end
    if props.modOrnaments ~= nil then
        SetVehicleMod(vehicle, 28, props.modOrnaments, false)
    end
    if props.modDashboard ~= nil then
        SetVehicleMod(vehicle, 29, props.modDashboard, false)
    end
    if props.modDial ~= nil then
        SetVehicleMod(vehicle, 30, props.modDial, false)
    end
    if props.modDoorSpeaker ~= nil then
        SetVehicleMod(vehicle, 31, props.modDoorSpeaker, false)
    end
    if props.modSeats ~= nil then
        SetVehicleMod(vehicle, 32, props.modSeats, false)
    end
    if props.modSteeringWheel ~= nil then
        SetVehicleMod(vehicle, 33, props.modSteeringWheel, false)
    end
    if props.modShifterLeavers ~= nil then
        SetVehicleMod(vehicle, 34, props.modShifterLeavers, false)
    end
    if props.modAPlate ~= nil then
        SetVehicleMod(vehicle, 35, props.modAPlate, false)
    end
    if props.modSpeakers ~= nil then
        SetVehicleMod(vehicle, 36, props.modSpeakers, false)
    end
    if props.modTrunk ~= nil then
        SetVehicleMod(vehicle, 37, props.modTrunk, false)
    end
    if props.modHydrolic ~= nil then
        SetVehicleMod(vehicle, 38, props.modHydrolic, false)
    end
    if props.modEngineBlock ~= nil then
        SetVehicleMod(vehicle, 39, props.modEngineBlock, false)
    end
    if props.modAirFilter ~= nil then
        SetVehicleMod(vehicle, 40, props.modAirFilter, false)
    end
    if props.modStruts ~= nil then
        SetVehicleMod(vehicle, 41, props.modStruts, false)
    end
    if props.modArchCover ~= nil then
        SetVehicleMod(vehicle, 42, props.modArchCover, false)
    end
    if props.modAerials ~= nil then
        SetVehicleMod(vehicle, 43, props.modAerials, false)
    end
    if props.modTrimB ~= nil then
        SetVehicleMod(vehicle, 44, props.modTrimB, false)
    end
    if props.modTank ~= nil then
        SetVehicleMod(vehicle, 45, props.modTank, false)
    end
    if props.modWindows ~= nil then
        SetVehicleMod(vehicle, 46, props.modWindows, false)
    end

    if props.modLivery ~= nil then
        SetVehicleMod(vehicle, 48, props.modLivery, false)
        SetVehicleLivery(vehicle, props.modLivery)
    end

    if props.windowsBroken ~= nil then
        for k, v in pairs(props.windowsBroken) do
            if v then
                RemoveVehicleWindow(vehicle, tonumber(k))
            end
        end
    end

    if props.doorsBroken ~= nil then
        for k, v in pairs(props.doorsBroken) do
            if v then
                SetVehicleDoorBroken(vehicle, tonumber(k), true)
            end
        end
    end

        if props.tyreBurst then
            for k, v in pairs(props.tyreBurst) do
                local f = tonumber(k)
                if v then
                    if f == 4 then
                       f = 2
                       BreakOffVehicleWheel(vehicle, f, true, true, true, false)
                    elseif f == 5 then
                       f = 3
                       BreakOffVehicleWheel(vehicle, f, true, true, true, false)
                    end
                    SetVehicleTyreBurst(vehicle, tonumber(k), true, 1000.0)
                    BreakOffVehicleWheel(vehicle, tonumber(k), true, true, true, false)
                end
            end
        end

        if props.plate then
            SetVehicleNumberPlateText(vehicle, props.plate)
        end
        if props.plateIndex then
            SetVehicleNumberPlateTextIndex(vehicle, props.plateIndex)
        end

        if props.tankHealth then
            SetVehiclePetrolTankHealth(vehicle, props.tankHealth + 0.0)
        end

        if Config.LegacyFuel then
           if props.fuelLevel ~= nil then
	       exports['LegacyFuel']:SetFuel(vehicle, props.fuelLevel + 0.0)
               print("Fuel: " ..props.fuelLevel)
           end
        end
        if props.dirtLevel then
            SetVehicleDirtLevel(vehicle, props.dirtLevel + 0.0)
        end

        if props.bodyHealth then
            SetVehicleBodyHealth(vehicle, props.bodyHealth + 0.0)
            print("Body: " ..props.bodyHealth)
        end

        if props.engineHealth then
            SetVehicleEngineHealth(vehicle, props.engineHealth + 0.0)
            print("Engine: " ..props.engineHealth)
        end

        if props.deformat then
           local deformation = json.decode(props.deformat)
           Entity(vehicle).state:set('deformation', deformation, true)
        end
        if props.wheelData then 
            exports['vstancer']:SetFrontCamber(vehicle, props.wheelData["frontCamber"])
			exports['vstancer']:SetRearCamber(vehicle, props.wheelData["rearCamber"])
			exports['vstancer']:SetFrontTrackWidth(vehicle, props.wheelData["frontWidth"])
			exports['vstancer']:SetRearTrackWidth(vehicle, props.wheelData["rearWidth"])
        end

        --if props.tyreH then
            --for k, v in pairs(props.tyreH) do
                --if v then
                    --BreakOffVehicleWheel(vehicle, tonumber(k), true, true, true, false)
                    --print(tonumber(k))
                --end
            --end
        --end
end

function ESX.Game.Utils.DrawText3D(coords, text, size, font)
    local vector = type(coords) == "vector3" and coords or vec(coords.x, coords.y, coords.z)

    local camCoords = GetFinalRenderedCamCoord()
    local distance = #(vector - camCoords)

    if not size then
        size = 1
    end
    if not font then
        font = 0
    end

    local scale = (size / distance) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    scale = scale * fov

    SetTextScale(0.0 * scale, 0.55 * scale)
    SetTextFont(font)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    BeginTextCommandDisplayText('STRING')
    SetTextCentre(true)
    AddTextComponentSubstringPlayerName(text)
    SetDrawOrigin(vector.xyz, 0)
    EndTextCommandDisplayText(0.0, 0.0)
    ClearDrawOrigin()
end

function ESX.ShowInventory()
    local playerPed = ESX.PlayerData.ped
    local elements, currentWeight = {}, 0

    for i=1, #(ESX.PlayerData.accounts) do
        if ESX.PlayerData.accounts[i].money > 0 then
            local formattedMoney = _U('locale_currency', ESX.Math.GroupDigits(ESX.PlayerData.accounts[i].money))
            local canDrop = ESX.PlayerData.accounts[i].name ~= 'bank'

            table.insert(elements, {
                label = ('%s: <span style="color:green;">%s</span>'):format(ESX.PlayerData.accounts[i].label, formattedMoney),
                count = ESX.PlayerData.accounts[i].money,
                type = 'item_account',
                value = ESX.PlayerData.accounts[i].name,
                usable = false,
                rare = false,
                canRemove = canDrop
            })
        end
    end

    for k, v in ipairs(ESX.PlayerData.inventory) do
        if v.count > 0 then
            currentWeight = currentWeight + (v.weight * v.count)

            table.insert(elements, {
                label = ('%s x%s'):format(v.label, v.count),
                count = v.count,
                type = 'item_standard',
                value = v.name,
                usable = v.usable,
                rare = v.rare,
                canRemove = v.canRemove
            })
        end
    end

    for k, v in ipairs(Config.Weapons) do
        local weaponHash = joaat(v.name)

        if HasPedGotWeapon(playerPed, weaponHash, false) then
            local ammo, label = GetAmmoInPedWeapon(playerPed, weaponHash)

            if v.ammo then
                label = ('%s - %s %s'):format(v.label, ammo, v.ammo.label)
            else
                label = v.label
            end

            table.insert(elements, {
                label = label,
                count = 1,
                type = 'item_weapon',
                value = v.name,
                usable = false,
                rare = false,
                ammo = ammo,
                canGiveAmmo = (v.ammo ~= nil),
                canRemove = true
            })
        end
    end

    ESX.UI.Menu.CloseAll()

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'inventory', {
        title = _U('inventory', currentWeight, ESX.PlayerData.maxWeight),
        align = 'bottom-right',
        elements = elements
    }, function(data, menu)
        menu.close()
        local player, distance = ESX.Game.GetClosestPlayer()
        elements = {}

        if data.current.usable then
            table.insert(elements, {
                label = _U('use'),
                action = 'use',
                type = data.current.type,
                value = data.current.value
            })
        end

        if data.current.canRemove then
            if player ~= -1 and distance <= 3.0 then
                table.insert(elements, {
                    label = _U('give'),
                    action = 'give',
                    type = data.current.type,
                    value = data.current.value
                })
            end

            table.insert(elements, {
                label = _U('remove'),
                action = 'remove',
                type = data.current.type,
                value = data.current.value
            })
        end

        if data.current.type == 'item_weapon' and data.current.canGiveAmmo and data.current.ammo > 0 and player ~= -1 and
            distance <= 3.0 then
            table.insert(elements, {
                label = _U('giveammo'),
                action = 'give_ammo',
                type = data.current.type,
                value = data.current.value
            })
        end

        table.insert(elements, {
            label = _U('return'),
            action = 'return'
        })

        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'inventory_item', {
            title = data.current.label,
            align = 'bottom-right',
            elements = elements
        }, function(data1, menu1)
            local item, type = data1.current.value, data1.current.type

            if data1.current.action == 'give' then
                local playersNearby = ESX.Game.GetPlayersInArea(GetEntityCoords(playerPed), 3.0)

                if #playersNearby > 0 then
                    local players = {}
                    elements = {}

                    for k, playerNearby in ipairs(playersNearby) do
                        players[GetPlayerServerId(playerNearby)] = true
                    end

                    ESX.TriggerServerCallback('esx:getPlayerNames', function(returnedPlayers)
                        for playerId, playerName in pairs(returnedPlayers) do
                            table.insert(elements, {
                                label = playerName,
                                playerId = playerId
                            })
                        end

                        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'give_item_to', {
                            title = _U('give_to'),
                            align = 'bottom-right',
                            elements = elements
                        }, function(data2, menu2)
                            local selectedPlayer, selectedPlayerId = GetPlayerFromServerId(data2.current.playerId),
                                data2.current.playerId
                            playersNearby = ESX.Game.GetPlayersInArea(GetEntityCoords(playerPed), 3.0)
                            playersNearby = ESX.Table.Set(playersNearby)

                            if playersNearby[selectedPlayer] then
                                local selectedPlayerPed = GetPlayerPed(selectedPlayer)

                                if IsPedOnFoot(selectedPlayerPed) and not IsPedFalling(selectedPlayerPed) then
                                    if type == 'item_weapon' then
                                        TriggerServerEvent('esx:giveInventoryItem', selectedPlayerId, type, item, nil)
                                        menu2.close()
                                        menu1.close()
                                    else
                                        ESX.UI.Menu.Open('dialog', GetCurrentResourceName(),
                                            'inventory_item_count_give', {
                                                title = _U('amount')
                                            }, function(data3, menu3)
                                                local quantity = tonumber(data3.value)

                                                if quantity and quantity > 0 and data.current.count >= quantity then
                                                    TriggerServerEvent('esx:giveInventoryItem', selectedPlayerId, type,
                                                        item, quantity)
                                                    menu3.close()
                                                    menu2.close()
                                                    menu1.close()
                                                else
                                                    ESX.ShowNotification(_U('amount_invalid'))
                                                end
                                            end, function(data3, menu3)
                                                menu3.close()
                                            end)
                                    end
                                else
                                    ESX.ShowNotification(_U('in_vehicle'))
                                end
                            else
                                ESX.ShowNotification(_U('players_nearby'))
                                menu2.close()
                            end
                        end, function(data2, menu2)
                            menu2.close()
                        end)
                    end, players)
                else
                    ESX.ShowNotification(_U('players_nearby'))
                end
            elseif data1.current.action == 'remove' then
                if IsPedOnFoot(playerPed) and not IsPedFalling(playerPed) then
                    local dict, anim = 'weapons@first_person@aim_rng@generic@projectile@sticky_bomb@', 'plant_floor'
                    ESX.Streaming.RequestAnimDict(dict)

                    if type == 'item_weapon' then
                        menu1.close()
                        TaskPlayAnim(playerPed, dict, anim, 8.0, 1.0, 1000, 16, 0.0, false, false, false)
                        RemoveAnimDict(dict)
                        Wait(1000)
                        TriggerServerEvent('esx:removeInventoryItem', type, item)
                    else
                        ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'inventory_item_count_remove', {
                            title = _U('amount')
                        }, function(data2, menu2)
                            local quantity = tonumber(data2.value)

                            if quantity and quantity > 0 and data.current.count >= quantity then
                                menu2.close()
                                menu1.close()
                                TaskPlayAnim(playerPed, dict, anim, 8.0, 1.0, 1000, 16, 0.0, false, false, false)
                                RemoveAnimDict(dict)
                                Wait(1000)
                                TriggerServerEvent('esx:removeInventoryItem', type, item, quantity)
                            else
                                ESX.ShowNotification(_U('amount_invalid'))
                            end
                        end, function(data2, menu2)
                            menu2.close()
                        end)
                    end
                end
            elseif data1.current.action == 'use' then
                TriggerServerEvent('esx:useItem', item)
            elseif data1.current.action == 'return' then
                ESX.UI.Menu.CloseAll()
                ESX.ShowInventory()
            elseif data1.current.action == 'give_ammo' then
                local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                local closestPed = GetPlayerPed(closestPlayer)
                local pedAmmo = GetAmmoInPedWeapon(playerPed, joaat(item))

                if IsPedOnFoot(closestPed) and not IsPedFalling(closestPed) then
                    if closestPlayer ~= -1 and closestDistance < 3.0 then
                        if pedAmmo > 0 then
                            ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'inventory_item_count_give', {
                                title = _U('amountammo')
                            }, function(data2, menu2)
                                local quantity = tonumber(data2.value)

                                if quantity and quantity > 0 then
                                    if pedAmmo >= quantity then
                                        TriggerServerEvent('esx:giveInventoryItem', GetPlayerServerId(closestPlayer),
                                            'item_ammo', item, quantity)
                                        menu2.close()
                                        menu1.close()
                                    else
                                        ESX.ShowNotification(_U('noammo'))
                                    end
                                else
                                    ESX.ShowNotification(_U('amount_invalid'))
                                end
                            end, function(data2, menu2)
                                menu2.close()
                            end)
                        else
                            ESX.ShowNotification(_U('noammo'))
                        end
                    else
                        ESX.ShowNotification(_U('players_nearby'))
                    end
                else
                    ESX.ShowNotification(_U('in_vehicle'))
                end
            end
        end, function(data1, menu1)
            ESX.UI.Menu.CloseAll()
            ESX.ShowInventory()
        end)
    end, function(data, menu)
        menu.close()
    end)
end

RegisterNetEvent('esx:showNotification')
AddEventHandler('esx:showNotification', function(msg, type, length)
    ESX.ShowNotification(msg, type, length)
end)

RegisterNetEvent('esx:showAdvancedNotification')
AddEventHandler('esx:showAdvancedNotification',
    function(sender, subject, msg, textureDict, iconType, flash, saveToBrief, hudColorIndex)
        ESX.ShowAdvancedNotification(sender, subject, msg, textureDict, iconType, flash, saveToBrief, hudColorIndex)
    end)

RegisterNetEvent('esx:showHelpNotification')
AddEventHandler('esx:showHelpNotification', function(msg, thisFrame, beep, duration)
    ESX.ShowHelpNotification(msg, thisFrame, beep, duration)
end)

---@param model number|string
---@return string
function ESX.GetVehicleType(model)
    model = type(model) == 'string' and joaat(model) or model

	if model == `submersible` or model == `submersible2` then
        return 'submarine'
	end

	local vehicleType = GetVehicleClassFromName(model)
	local types = {
		[8] = "bike",
		[11] = "trailer",
		[13] = "bike",
		[14] = "boat",
		[15] = "heli",
		[16] = "plane",
		[21] = "train",
	}

    return types[vehicleType] or "automobile"
end
