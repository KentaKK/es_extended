ESX = {}
Core = {}
ESX.PlayerData = {}
ESX.PlayerLoaded = false
Core.Input = {}
ESX.UI = {}
ESX.UI.Menu = {}
ESX.UI.Menu.RegisteredTypes = {}
ESX.UI.Menu.Opened = {}
ESX.Game = {}
ESX.Game.Utils = {}
ESX.Scaleform = {}
ESX.Scaleform.Utils = {}
ESX.Streaming = {}
local GU = {}
GU.Time = 0

---@return boolean
exports('phonecheck', function()
    local count = exports.ox_inventory:Search('count', 'phone')
    if count >= 1 then
        return true
    elseif count <= 0 then
        ESX.ShowNotification('Nincs nálad ~g~telefon')
        return false
    end
    return false
end)

---@return boolean
function ESX.IsPlayerLoaded()
	return ESX.PlayerLoaded
end

---@return table
function ESX.GetPlayerData()
	return ESX.PlayerData
end

function ESX.SearchInventory(items, count)
    while not ESX.PlayerLoaded do Wait(50) end
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

---@param key any
---@param val any
function ESX.SetPlayerData(key, val)
    local current = ESX.PlayerData[key]
    ESX.PlayerData[key] = val
    if key ~= 'inventory' and key ~= 'loadout' then
        if type(val) == 'table' or val ~= current then
            TriggerEvent('esx:setPlayerData', key, val, current)
        end
    end
end

---@param message string
---@param length any
---@param Options any
function ESX.Progressbar(message, length, Options)
    exports["esx_progressbar"]:Progressbar(message, length, Options)
end

---@param message string
---@param type any
---@param length any
function ESX.ShowNotification(message, type, length)
    if Config.NativeNotify then
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message)
    EndTextCommandThefeedPostTicker(false, true)
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
	if not saveToBrief then saveToBrief = true end
	AddTextEntry('esxAdvancedNotification', msg)
	BeginTextCommandThefeedPost('esxAdvancedNotification')
	if hudColorIndex then ThefeedSetNextPostBackgroundColor(hudColorIndex) end
	EndTextCommandThefeedPostMessagetext(textureDict, textureDict, false, iconType, sender, subject)
	EndTextCommandThefeedPostTicker(flash or false, saveToBrief)
end

---@param msg string
---@param thisFrame boolean?
---@param beep boolean?
---@param duration? number
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
	SetFloatingHelpTextWorldPosition(1, coords.x, coords.y, coords.z)
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
    input_map = gsub(input_map, "FF8F5D5D", "")

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
    RegisterCommand(on_release ~= nil and "+" .. command_name or command_name, on_press, false)
    Core.Input[command_name] = on_release ~= nil and ESX.HashString("+" .. command_name) or ESX.HashString(command_name)
    if on_release then
        RegisterCommand("-" .. command_name, on_release, false)
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
    networked = not networked and true or networked

    local model = type(object) == 'number' and object or joaat(object)
    CreateThread(function()
        ESX.Streaming.RequestModel(model)

        local obj = CreateObject(model, coords.x, coords.y, coords.z, networked, false, true)
        if cb then
            cb(obj)
        end
    end)
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
---@param coords vector3|vector4|table
---@param heading number
---@param cb function
ESX.Game.SpawnVehicle = function(vehicle, coords, heading, cb)
    local model = type(vehicle) == 'number' and vehicle or joaat(vehicle)
    if not IsModelInCdimage(model) then return end

    local playerCoords = GetEntityCoords(ESX.PlayerData.ped)
    if not playerCoords then
        return
    end

    CreateThread(function()
    GU.Time = GetGameTimer()
	ESX.Streaming.RequestModel(model)

	RequestCollisionAtCoord(coords.x, coords.y, coords.z)

	print('Spawning '..tostring(model)..' at '..tostring(vector4(coords.x, coords.y, coords.z, heading + 0.0)))
	local veh = CreateVehicle(model, coords.x, coords.y, coords.z, heading, true, true)
	local id = NetworkGetNetworkIdFromEntity(veh)
		SetNetworkIdCanMigrate(id, true)
		SetEntityAsMissionEntity(veh, true, true)
		SetVehicleHasBeenOwnedByPlayer(veh, true)
		SetVehicleNeedsToBeHotwired(veh, false)
		SetVehRadioStation(veh, 'OFF')
        SetVehicleOnGroundProperly(veh)
		SetModelAsNoLongerNeeded(model)

		if DoesEntityExist(veh) then
            local xxxx = 0
			while not HasCollisionLoadedAroundEntity(veh) do
                print("Request Collision: " ..xxxx)
			    RequestCollisionAtCoord(coords.x, coords.y, coords.z)
                if xxxx > 40 then
                    break
                end
                xxxx += 1
			    Wait(50)
			end
		end
		if cb then
			cb(veh)
            local elapsedTime = (GetGameTimer() - GU.Time)
            print(('[^2INFO^7] Spawn time %s ms'):format(elapsedTime))
		end
    end)
end

---@param modelName number|string
---@param coords vector3|vector4|table
---@param heading number
---@param cb function
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

		if cb then
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

		if cb then
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

		for _,entity in pairs(entities) do
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

---@return number
---@return vector3|nil
function ESX.Game.GetVehicleInDirection()
    local playerPed = ESX.PlayerData.ped
    local playerCoords = GetEntityCoords(playerPed)
    local inDirection = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 5.0, 0.0)
    local rayHandle = StartExpensiveSynchronousShapeTestLosProbe(playerCoords.x, playerCoords.y, playerCoords.z, inDirection.x, inDirection.y, inDirection.z, 2, playerPed, 4)
    local _, hit, _, _, entityHit = GetShapeTestResult(rayHandle)

    if hit == 1 and GetEntityType(entityHit) == 2 then
        local entityCoords = GetEntityCoords(entityHit)
        return entityHit, entityCoords
    end

    return 0
end


---@param vehicle number
---@return table|nil
ESX.Game.GetVehicleProperties = function(vehicle)
    if not DoesEntityExist(vehicle) then
        return
    end

    local colorPrimary, colorSecondary = GetVehicleColours(vehicle)
    local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)
    local hasCustomPrimaryColor = GetIsVehiclePrimaryColourCustom(vehicle)
    local dashboardColor = GetVehicleDashboardColor(vehicle)
    local interiorColor = GetVehicleInteriorColour(vehicle)
    local paintType1 = GetVehicleModColor_1(vehicle)
    local paintType2 = GetVehicleModColor_2(vehicle)
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
    for i = 0, 20 do
        if DoesExtraExist(vehicle, i) then
            extras[i] = IsVehicleExtraTurnedOn(vehicle, i)
        end
    end

    local driftTyresEnabled = false
    if type(GetDriftTyresEnabled(vehicle) == "boolean") and GetDriftTyresEnabled(vehicle) then
        driftTyresEnabled = true
    end

    local doorsBroken, windowsBroken, tyreBurst = {}, {}, {}

    for i = 0, 7 do
        if IsVehicleTyreBurst(vehicle, i, false) then
            tyreBurst[i] = IsVehicleTyreBurst(vehicle, i, true) and 2 or 1
        end
    end

    local w = 0

    for i = 0, 7 do
        RollUpWindow(vehicle, i)
        if not IsVehicleWindowIntact(vehicle, i) then
            w += 1
            windowsBroken[w] = i
        end
    end

    local d = 0

    for i = 0, 5 do
        if IsVehicleDoorDamaged(vehicle, i) then
            d += 1
            doorsBroken[d] = i
        end
    end

    local wheelData = {}

    if GetResourceState("vstancer") == "started" then
        wheelData = {
		    frontCamber = exports['vstancer']:GetFrontCamber(vehicle)[1],
		    rearCamber = exports['vstancer']:GetRearCamber(vehicle)[1],
		    frontWidth = exports['vstancer']:GetFrontTrackWidth(vehicle)[1],
		    rearWidth = exports['vstancer']:GetRearTrackWidth(vehicle)[1]
        }
    end

    return {
        model = GetEntityModel(vehicle),
        deformat = json.encode(GetVehicleDeformation(vehicle)),
        wheelData = wheelData,
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
        paintType1 = paintType1,
        paintType2 = paintType2,
        customPrimaryColor = customPrimaryColor,
        customSecondaryColor = customSecondaryColor,

        pearlescentColor = pearlescentColor,
        wheelColor = wheelColor,
        wheelSize = GetVehicleWheelSize(vehicle),
        wheelWidth = GetVehicleWheelWidth(vehicle),
        bulletProofTyres = GetVehicleTyresCanBurst(vehicle),

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

---@param vehicle number
---@param props table
ESX.Game.SetVehicleProperties = function(vehicle, props)
    if not DoesEntityExist(vehicle) then
        return
    end
    local colorPrimary, colorSecondary = GetVehicleColours(vehicle)
    local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)
    SetVehicleModKit(vehicle, 0)

    if props.tyresCanBurst then
        SetVehicleTyresCanBurst(vehicle, props.tyresCanBurst)
    end
    if props.customPrimaryColor then
        SetVehicleCustomPrimaryColour(vehicle, props.customPrimaryColor[1], props.customPrimaryColor[2],
            props.customPrimaryColor[3])
    end
    if props.customSecondaryColor then
        SetVehicleCustomSecondaryColour(vehicle, props.customSecondaryColor[1], props.customSecondaryColor[2],
            props.customSecondaryColor[3])
    end

    if props.color1 then
        if type(props.color1) == 'number' then
            ClearVehicleCustomPrimaryColour(vehicle)
            SetVehicleColours(vehicle, props.color1 --[[@as number]], colorSecondary --[[@as number]])
        else
            if props.paintType1 then SetVehicleModColor_1(vehicle, props.paintType1, colorPrimary, pearlescentColor) end

            SetVehicleCustomPrimaryColour(vehicle, props.color1[1], props.color1[2], props.color1[3])
        end
    end

    if props.color2 then
        if type(props.color2) == 'number' then
            ClearVehicleCustomSecondaryColour(vehicle)
            SetVehicleColours(vehicle, props.color1 or colorPrimary --[[@as number]], props.color2 --[[@as number]])
        else
            if props.paintType2 then SetVehicleModColor_2(vehicle, props.paintType2, colorSecondary) end

            SetVehicleCustomSecondaryColour(vehicle, props.color2[1], props.color2[2], props.color2[3])
        end
    end

    if props.pearlescentColor then
        SetVehicleExtraColours(vehicle, props.pearlescentColor, wheelColor)
    end

    if props.interiorColor then
        SetVehicleInteriorColor(vehicle, props.interiorColor)
    end

    if props.dashboardColor then
        SetVehicleDashboardColor(vehicle, props.dashboardColor)
    end

    if props.wheelColor then
        SetVehicleExtraColours(vehicle, props.pearlescentColor or pearlescentColor, props.wheelColor)
    end

    if props.wheels then
        SetVehicleWheelType(vehicle, props.wheels)
    end

    if props.wheelSize then
        SetVehicleWheelSize(vehicle, props.wheelSize)
    end

    if props.wheelWidth then
        SetVehicleWheelWidth(vehicle, props.wheelWidth)
    end

    if props.windowTint then
        SetVehicleWindowTint(vehicle, props.windowTint)
    end

    if props.neonEnabled then
        SetVehicleNeonLightEnabled(vehicle, 0, props.neonEnabled[1])
        SetVehicleNeonLightEnabled(vehicle, 1, props.neonEnabled[2])
        SetVehicleNeonLightEnabled(vehicle, 2, props.neonEnabled[3])
        SetVehicleNeonLightEnabled(vehicle, 3, props.neonEnabled[4])
    end

    if props.extras then
        for extraId, enabled in pairs(props.extras) do
            SetVehicleExtra(vehicle, tonumber(extraId) --[[@as number]], enabled == 1)
        end
    end

    if props.driftTyresEnabled then
        SetDriftTyresEnabled(vehicle, true)
    end

    if props.neonColor then
        SetVehicleNeonLightsColour(vehicle, props.neonColor[1], props.neonColor[2], props.neonColor[3])
    end
    if props.xenonColor then
        SetVehicleXenonLightsColor(vehicle, props.xenonColor)
    end
    if props.customXenonColor then
        SetVehicleXenonLightsCustomColor(vehicle, props.customXenonColor[1], props.customXenonColor[2],
            props.customXenonColor[3])
    end
    if props.modSmokeEnabled then
        ToggleVehicleMod(vehicle, 20, true)
    end
    if props.tyreSmokeColor then
        SetVehicleTyreSmokeColor(vehicle, props.tyreSmokeColor[1], props.tyreSmokeColor[2], props.tyreSmokeColor[3])
    end
    if props.modSpoilers then
        SetVehicleMod(vehicle, 0, props.modSpoilers, false)
    end
    if props.modFrontBumper then
        SetVehicleMod(vehicle, 1, props.modFrontBumper, false)
    end
    if props.modRearBumper then
        SetVehicleMod(vehicle, 2, props.modRearBumper, false)
    end
    if props.modSideSkirt then
        SetVehicleMod(vehicle, 3, props.modSideSkirt, false)
    end
    if props.modExhaust then
        SetVehicleMod(vehicle, 4, props.modExhaust, false)
    end
    if props.modFrame then
        SetVehicleMod(vehicle, 5, props.modFrame, false)
    end
    if props.modGrille then
        SetVehicleMod(vehicle, 6, props.modGrille, false)
    end
    if props.modHood then
        SetVehicleMod(vehicle, 7, props.modHood, false)
    end
    if props.modFender then
        SetVehicleMod(vehicle, 8, props.modFender, false)
    end
    if props.modRightFender then
        SetVehicleMod(vehicle, 9, props.modRightFender, false)
    end
    if props.modRoof then
        SetVehicleMod(vehicle, 10, props.modRoof, false)
    end

    if props.modRoofLivery then
        SetVehicleRoofLivery(vehicle, props.modRoofLivery)
    end

    if props.modEngine then
        SetVehicleMod(vehicle, 11, props.modEngine, false)
    end
    if props.modBrakes then
        SetVehicleMod(vehicle, 12, props.modBrakes, false)
    end
    if props.modTransmission then
        SetVehicleMod(vehicle, 13, props.modTransmission, false)
    end
    if props.modHorns then
        SetVehicleMod(vehicle, 14, props.modHorns, false)
    end
    if props.modSuspension then
        SetVehicleMod(vehicle, 15, props.modSuspension, false)
    end
    if props.modArmor then
        SetVehicleMod(vehicle, 16, props.modArmor, false)
    end
    if props.modTurbo then
        ToggleVehicleMod(vehicle, 18, props.modTurbo)
    end
    if props.modXenon then
        ToggleVehicleMod(vehicle, 22, props.modXenon)
    end
    if props.modFrontWheels then
        SetVehicleMod(vehicle, 23, props.modFrontWheels, props.modCustomFrontWheels)
    end
    if props.modBackWheels then
        SetVehicleMod(vehicle, 24, props.modBackWheels, props.modCustomBackWheels)
    end
    if props.modPlateHolder then
        SetVehicleMod(vehicle, 25, props.modPlateHolder, false)
    end
    if props.modVanityPlate then
        SetVehicleMod(vehicle, 26, props.modVanityPlate, false)
    end
    if props.modTrimA then
        SetVehicleMod(vehicle, 27, props.modTrimA, false)
    end
    if props.modOrnaments then
        SetVehicleMod(vehicle, 28, props.modOrnaments, false)
    end
    if props.modDashboard then
        SetVehicleMod(vehicle, 29, props.modDashboard, false)
    end
    if props.modDial then
        SetVehicleMod(vehicle, 30, props.modDial, false)
    end
    if props.modDoorSpeaker then
        SetVehicleMod(vehicle, 31, props.modDoorSpeaker, false)
    end
    if props.modSeats then
        SetVehicleMod(vehicle, 32, props.modSeats, false)
    end
    if props.modSteeringWheel then
        SetVehicleMod(vehicle, 33, props.modSteeringWheel, false)
    end
    if props.modShifterLeavers then
        SetVehicleMod(vehicle, 34, props.modShifterLeavers, false)
    end
    if props.modAPlate then
        SetVehicleMod(vehicle, 35, props.modAPlate, false)
    end
    if props.modSpeakers then
        SetVehicleMod(vehicle, 36, props.modSpeakers, false)
    end
    if props.modTrunk then
        SetVehicleMod(vehicle, 37, props.modTrunk, false)
    end
    if props.modHydrolic then
        SetVehicleMod(vehicle, 38, props.modHydrolic, false)
    end
    if props.modEngineBlock then
        SetVehicleMod(vehicle, 39, props.modEngineBlock, false)
    end
    if props.modAirFilter then
        SetVehicleMod(vehicle, 40, props.modAirFilter, false)
    end
    if props.modStruts then
        SetVehicleMod(vehicle, 41, props.modStruts, false)
    end
    if props.modArchCover then
        SetVehicleMod(vehicle, 42, props.modArchCover, false)
    end
    if props.modAerials then
        SetVehicleMod(vehicle, 43, props.modAerials, false)
    end
    if props.modTrimB then
        SetVehicleMod(vehicle, 44, props.modTrimB, false)
    end
    if props.modTank then
        SetVehicleMod(vehicle, 45, props.modTank, false)
    end
    if props.modWindows then
        SetVehicleMod(vehicle, 46, props.modWindows, false)
    end

    if props.modLivery then
        SetVehicleMod(vehicle, 48, props.modLivery, false)
        SetVehicleLivery(vehicle, props.modLivery)
    end

    if props.windowsBroken then
        for i=1, #props.windowsBroken do
            RemoveVehicleWindow(vehicle, props.windowsBroken[i])
        end
    end

    if props.doorsBroken then
        for i=1, #props.doorsBroken do
            SetVehicleDoorBroken(vehicle, props.doorsBroken[i], true)
        end
    end

    if props.bulletProofTyres then
        SetVehicleTyresCanBurst(vehicle, props.bulletProofTyres)
    end

    if props.tyreBurst then
        for tyre, state in pairs(props.tyreBurst) do
            SetVehicleTyreBurst(vehicle, tonumber(tyre) --[[@as number]], state == 2, 1000.0)
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

    print("----------")
    if Config.LegacyFuel then
        if props.fuelLevel then
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

    print("----------")
    if props.deformat then
        local deformation = json.decode(props.deformat)
        Entity(vehicle).state:set('deformation', deformation, true)
    end

    if props.wheelData then
        if GetResourceState("vstancer") == "started" then
            exports['vstancer']:SetFrontCamber(vehicle, props.wheelData["frontCamber"])
            exports['vstancer']:SetRearCamber(vehicle, props.wheelData["rearCamber"])
            exports['vstancer']:SetFrontTrackWidth(vehicle, props.wheelData["frontWidth"])
            exports['vstancer']:SetRearTrackWidth(vehicle, props.wheelData["rearWidth"])
        end
    end
end

function ESX.Game.Utils.DrawText3D(coords, text, size, font)
    local camCoords = GetFinalRenderedCamCoord()
    local distance = #(vector3(coords.x, coords.y, coords.z) - camCoords)

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
    SetTextColour(255, 255, 255, 215)
    BeginTextCommandDisplayText('STRING')
    SetTextCentre(true)
    AddTextComponentSubstringPlayerName(text)
    SetDrawOrigin(coords.x, coords.y, coords.z, 0)
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

    for _,v in ipairs(ESX.PlayerData.inventory) do
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

    for _,v in ipairs(Config.Weapons) do
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

---@param account string Account name (money/bank/black_money)
---@return table|nil
function ESX.GetAccount(account)
    for i = 1, #ESX.PlayerData.accounts, 1 do
        if ESX.PlayerData.accounts[i].name == account then
            return ESX.PlayerData.accounts[i]
        end
    end
    return nil
end

AddEventHandler("onResourceStop", function(resourceName)
    for i = 1, #ESX.UI.Menu.Opened, 1 do
        if ESX.UI.Menu.Opened[i] then
            if ESX.UI.Menu.Opened[i].resourceName == resourceName or ESX.UI.Menu.Opened[i].namespace == resourceName then
                ESX.UI.Menu.Opened[i].close()
                ESX.UI.Menu.Opened[i] = nil
            end
        end
    end
end)

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
