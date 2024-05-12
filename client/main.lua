local pickups = {}

AddStateBagChangeHandler('metadata', 'player:' .. tostring(GetPlayerServerId(PlayerId())), function(_, key, val)
	ESX.SetPlayerData(key, val)
end)

AddStateBagChangeHandler('group', 'player:' .. tostring(GetPlayerServerId(PlayerId())), function(_, key, val)
	ESX.SetPlayerData(key, val)
end)

AddStateBagChangeHandler('VehicleProperties', nil, function(bagName, _, value)
    if not value then return end
    local netId = bagName:gsub('entity:', '')

    local vehicle = NetToVeh(tonumber(netId))

    ESX.Game.SetVehicleProperties(vehicle, value)
end)

CreateThread(function()
	while not Config.Multichar do
		Wait(0)
		if NetworkIsPlayerActive(PlayerId()) then
			exports.spawnmanager:setAutoSpawn(false)
			DoScreenFadeOut(0)
			Wait(500)
			TriggerServerEvent('esx:onPlayerJoined')
			break
		end
	end
end)

local function playAnime(animDict, animName, duration)
	RequestAnimDict(animDict)
	while not HasAnimDictLoaded(animDict) do Wait(0) end
	TaskPlayAnim(PlayerPedId(), animDict, animName, 1.0, -1.0, duration, 49, 1, false, false, false)
	RemoveAnimDict(animDict)
end

RegisterNetEvent('esx:giveAnimation')
AddEventHandler('esx:giveAnimation', function()
    playAnime('mp_common', 'givetake2_a', 2000)
end)

RegisterNetEvent('esx:removeAnimation')
AddEventHandler('esx:removeAnimation', function()
    playAnime('mp_common', 'plant_bomb', 2000)
end)

RegisterNetEvent("esx:requestModel", function(model)
    ESX.Streaming.RequestModel(model)
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer, isNew, skin)
	ESX.PlayerData = xPlayer

	FreezeEntityPosition(ESX.PlayerData.ped, true)

	if Config.Multichar then
		Wait(3000)
	else
		exports.spawnmanager:spawnPlayer({
			x = ESX.PlayerData.coords.x,
			y = ESX.PlayerData.coords.y,
			z = ESX.PlayerData.coords.z + 0.25,
			heading = ESX.PlayerData.coords.heading,
			model = `mp_m_freemode_01`,
			skipFade = false
		}, function()
			TriggerServerEvent('esx:onPlayerSpawn')
			TriggerEvent('esx:onPlayerSpawn')
			TriggerEvent('esx:restoreLoadout')

			if isNew then
				TriggerEvent('skinchanger:loadDefaultModel', skin.sex == 0)
			elseif skin then
				TriggerEvent('skinchanger:loadSkin', skin)
			end
		    Wait(3200)
			TriggerEvent('esx:loadingScreenOff')
			ShutdownLoadingScreen()
			ShutdownLoadingScreenNui()
			FreezeEntityPosition(ESX.PlayerData.ped, false)
		end)
	end

	ESX.PlayerLoaded = true

	while ESX.PlayerData.ped == nil do Wait(20) end

		-- enable PVP
	if Config.EnablePVP then
		SetCanAttackFriendly(ESX.PlayerData.ped, true, false)
		NetworkSetFriendlyFireOption(true)
	end

	-- RemoveHudCommonents
	for i = 1, #(Config.RemoveHudCommonents) do
		if Config.RemoveHudCommonents[i] then
			SetHudComponentPosition(i, 999999.0, 999999.0)
		end
	end

	-- DisableNPCDrops
	if Config.DisableNPCDrops then
		local weaponPickups = { `PICKUP_WEAPON_CARBINERIFLE`, `PICKUP_WEAPON_PISTOL`, `PICKUP_WEAPON_PUMPSHOTGUN` }
		for i = 1, #weaponPickups do
			ToggleUsePickupsForPlayer(PlayerId(), weaponPickups[i], false)
		end
	end

	if Config.DisableHealthRegen then
		SetPlayerHealthRechargeMultiplier(PlayerId(), 0.0)
	end

	if Config.DisableWeaponWheel or Config.DisableAimAssist or Config.DisableVehicleRewards then
		CreateThread(function()
			local playerId = PlayerId()
			while true do
				if Config.DisableWeaponWheel then
					BlockWeaponWheelThisFrame()
					DisableControlAction(0, 37, true)
				end

				if Config.DisableAimAssist then
					if IsPedArmed(ESX.PlayerData.ped, 4) then
						SetPlayerLockonRangeOverride(playerId, 2.0)
					end
				end

				if Config.DisableVehicleRewards then
					DisablePlayerVehicleRewards(playerId)
				end
				Wait(1)
			end
		end)
	end

	SetDefaultVehicleNumberPlateTextPattern(-1, Config.CustomAIPlates)
	StartServerSyncLoops()
	if ESX.PlayerData.group then print("Group:", ESX.PlayerData.group) end
	Wait(10000)
	local metadata = ESX.PlayerData.metadata
	if metadata.health then
		SetEntityHealth(ESX.PlayerData.ped, metadata.health)
		print("Health:", metadata.health)
	end

	if metadata.armor and metadata.armor > 0 then
		SetPedArmour(ESX.PlayerData.ped, metadata.armor)
		print("Armor:", metadata.armor)
	end
end)

RegisterCommand("pgroup", function(source, args, rawCommand)
    print(ESX.PlayerData.group)
end, false)

RegisterNetEvent('esx:onPlayerLogout')
AddEventHandler('esx:onPlayerLogout', function()
	ESX.PlayerLoaded = false
end)

RegisterNetEvent('esx:setMaxWeight')
AddEventHandler('esx:setMaxWeight', function(newMaxWeight) ESX.PlayerData.maxWeight = newMaxWeight end)

local function onPlayerSpawn()
	ESX.SetPlayerData('ped', PlayerPedId())
	ESX.SetPlayerData('dead', false)
end

AddEventHandler('playerSpawned', onPlayerSpawn)
AddEventHandler('esx:onPlayerSpawn', onPlayerSpawn)

AddEventHandler('esx:onPlayerDeath', function()
	ESX.SetPlayerData('ped', PlayerPedId())
	ESX.SetPlayerData('dead', true)
end)

AddEventHandler('skinchanger:modelLoaded', function()
	while not ESX.PlayerLoaded do
		Wait(100)
	end
	TriggerEvent('esx:restoreLoadout')
end)

AddEventHandler('esx:restoreLoadout', function()
	ESX.SetPlayerData('ped', PlayerPedId())

	if not Config.OxInventory then
		local ammoTypes = {}
		RemoveAllPedWeapons(ESX.PlayerData.ped, true)

		for _,v in ipairs(ESX.PlayerData.loadout) do
			local weaponName = v.name
			local weaponHash = joaat(weaponName)

			GiveWeaponToPed(ESX.PlayerData.ped, weaponHash, 0, false, false)
			SetPedWeaponTintIndex(ESX.PlayerData.ped, weaponHash, v.tintIndex)

			local ammoType = GetPedAmmoTypeFromWeapon(ESX.PlayerData.ped, weaponHash)

			for _,v2 in ipairs(v.components) do
				local componentHash = ESX.GetWeaponComponent(weaponName, v2).hash
				GiveWeaponComponentToPed(ESX.PlayerData.ped, weaponHash, componentHash)
			end

			if not ammoTypes[ammoType] then
				AddAmmoToPed(ESX.PlayerData.ped, weaponHash, v.ammo)
				ammoTypes[ammoType] = true
			end
		end
	end
end)

RegisterNetEvent('esx:setAccountMoney')
AddEventHandler('esx:setAccountMoney', function(account)
	for i=1, #(ESX.PlayerData.accounts) do
		if ESX.PlayerData.accounts[i].name == account.name then
			ESX.PlayerData.accounts[i] = account
			break
		end
	end

	ESX.SetPlayerData('accounts', ESX.PlayerData.accounts)
end)

if not Config.OxInventory then
	RegisterNetEvent('esx:addInventoryItem')
	AddEventHandler('esx:addInventoryItem', function(item, count, showNotification)
		for k,v in ipairs(ESX.PlayerData.inventory) do
			if v.name == item then
				ESX.UI.ShowInventoryItemNotification(true, v.label, count - v.count)
				ESX.PlayerData.inventory[k].count = count
				break
			end
		end

		if showNotification then
			ESX.UI.ShowInventoryItemNotification(true, item, count)
		end

		if ESX.UI.Menu.IsOpen('default', 'es_extended', 'inventory') then
			ESX.ShowInventory()
		end
	end)

	RegisterNetEvent('esx:removeInventoryItem')
	AddEventHandler('esx:removeInventoryItem', function(item, count, showNotification)
		for k,v in ipairs(ESX.PlayerData.inventory) do
			if v.name == item then
				ESX.UI.ShowInventoryItemNotification(false, v.label, v.count - count)
				ESX.PlayerData.inventory[k].count = count
				break
			end
		end

		if showNotification then
			ESX.UI.ShowInventoryItemNotification(false, item, count)
		end

		if ESX.UI.Menu.IsOpen('default', 'es_extended', 'inventory') then
			ESX.ShowInventory()
		end
	end)

	RegisterNetEvent('esx:addWeapon')
	AddEventHandler('esx:addWeapon', function(weapon, ammo)
		print("[WARNING] event 'esx:addWeapon' is deprecated. Please use xPlayer.addWeapon Instead!")
	end)

	RegisterNetEvent('esx:addWeaponComponent')
	AddEventHandler('esx:addWeaponComponent', function(weapon, weaponComponent)
		print("[WARNING] event 'esx:addWeaponComponent' is deprecated. Please use xPlayer.addWeaponComponent Instead!")
	end)

	RegisterNetEvent('esx:setWeaponAmmo')
	AddEventHandler('esx:setWeaponAmmo', function(weapon, weaponAmmo)
		print("[^1ERROR^7] event ^5'esx:setWeaponAmmo'^7 Has Been Removed. Please use ^5xPlayer.addWeaponAmmo^7 Instead!")
	end)

	RegisterNetEvent('esx:setWeaponTint')
	AddEventHandler('esx:setWeaponTint', function(weapon, weaponTintIndex)
		SetPedWeaponTintIndex(ESX.PlayerData.ped, joaat(weapon), weaponTintIndex)

	end)

	RegisterNetEvent('esx:removeWeapon')
	AddEventHandler('esx:removeWeapon', function(weapon)
		RemoveWeaponFromPed(ESX.PlayerData.ped, joaat(weapon))
		SetPedAmmo(ESX.PlayerData.ped, joaat(weapon), 0)
	end)

	RegisterNetEvent('esx:removeWeaponComponent')
	AddEventHandler('esx:removeWeaponComponent', function(weapon, weaponComponent)
		local componentHash = ESX.GetWeaponComponent(weapon, weaponComponent).hash
		RemoveWeaponComponentFromPed(ESX.PlayerData.ped, joaat(weapon), componentHash)
	end)
end

RegisterNetEvent('esx:teleport')
AddEventHandler('esx:teleport', function(coords)
	ESX.Game.Teleport(ESX.PlayerData.ped, coords)
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(Job)
	if Config.EnableHud then
		local gradeLabel = Job.grade_label ~= Job.label and Job.grade_label or ''
		if gradeLabel ~= '' then gradeLabel = ' - '..gradeLabel end
		ESX.UI.HUD.UpdateElement('job', {
			job_label = Job.label,
			grade_label = gradeLabel
		})
	end
	ESX.SetPlayerData('job', Job)
end)

RegisterNetEvent('esx:spawnVehicle')
AddEventHandler('esx:spawnVehicle', function(vehicle)
	ESX.TriggerServerCallback("esx:isUserAdmin", function(admin)
		if admin then
			local model = (type(vehicle) == 'number' and vehicle or joaat(vehicle))

			if IsModelInCdimage(model) then
				local playerCoords, playerHeading = GetEntityCoords(ESX.PlayerData.ped), GetEntityHeading(ESX.PlayerData.ped)

				ESX.Game.SpawnVehicle(model, playerCoords, playerHeading, function(vehicle)
					TaskWarpPedIntoVehicle(ESX.PlayerData.ped, vehicle, -1)
					SetVehicleDirtLevel(vehicle, 0)
					SetVehicleFuelLevel(vehicle, 100.0)
			    -- SetVehicleCustomSecondaryColour(vehicle, 55, 140, 191) -- ESX Blue
					SetEntityAsMissionEntity(vehicle, true, true) -- Persistant Vehicle

					-- Max out vehicle upgrades
					if Config.MaxAdminVehicles then
						SetVehicleExplodesOnHighExplosionDamage(vehicle, true)
						SetVehicleModKit(vehicle, 0)
						SetVehicleMod(vehicle, 11, 3, false) -- modEngine
						SetVehicleMod(vehicle, 12, 2, false) -- modBrakes
						SetVehicleMod(vehicle, 13, 2, false) -- modTransmission
						SetVehicleMod(vehicle, 15, 3, false) -- modSuspension
						SetVehicleMod(vehicle, 16, 4, false) -- modArmor
						ToggleVehicleMod(vehicle, 18, true) -- modTurbo
						SetVehicleTurboPressure(vehicle, 100.0)
						SetVehicleNumberPlateText(vehicle, "XXX XXX")
						SetVehicleNumberPlateTextIndex(vehicle, 1)
						SetVehicleNitroEnabled(vehicle, true)

						for i=0, 3 do
							SetVehicleNeonLightEnabled(vehicle, i, true)
						end
						SetVehicleNeonLightsColour(vehicle, 55, 140, 191)  -- ESX Blue
					end
				end)
			else
				ESX.ShowNotification('Invalid vehicle model.')
			end
		end
	end)
end)

RegisterNetEvent('esx:spawnVehicle2')
AddEventHandler('esx:spawnVehicle2', function(vehicle)
	ESX.TriggerServerCallback("esx:isUserAdmin", function(admin)
		if admin then
			local model = (type(vehicle) == 'number' and vehicle or joaat(vehicle))

			if IsModelInCdimage(model) then
				local playerCoords, playerHeading = GetEntityCoords(ESX.PlayerData.ped), GetEntityHeading(ESX.PlayerData.ped)

				ESX.Game.SpawnVehicle(model, playerCoords, playerHeading, function(vehicle)
					TaskWarpPedIntoVehicle(ESX.PlayerData.ped, vehicle, -1)
					SetVehicleDirtLevel(vehicle, 0)
					SetVehicleFuelLevel(vehicle, 100.0)
			    -- SetVehicleCustomSecondaryColour(vehicle, 55, 140, 191) -- ESX Blue
					SetEntityAsMissionEntity(vehicle, true, true) -- Persistant Vehicle

					-- Max out vehicle upgrades
				end)
			else
				ESX.ShowNotification('Invalid vehicle model.')
			end
		end
	end)
end)

if not Config.OxInventory then
	RegisterNetEvent('esx:createPickup')
	AddEventHandler('esx:createPickup', function(pickupId, label, coords, type, name, components, tintIndex)
		local function setObjectProperties(object)
			SetEntityAsMissionEntity(object, true, false)
			PlaceObjectOnGroundProperly(object)
			FreezeEntityPosition(object, true)
			SetEntityCollision(object, false, true)

			pickups[pickupId] = {
				obj = object,
				label = label,
				inRange = false,
				coords = vector3(coords.x, coords.y, coords.z)
			}
		end

		if type == 'item_weapon' then
			local weaponHash = joaat(name)
			ESX.Streaming.RequestWeaponAsset(weaponHash)
			local pickupObject = CreateWeaponObject(weaponHash, 50, coords.x, coords.y, coords.z, true, 1.0, 0)
			SetWeaponObjectTintIndex(pickupObject, tintIndex)

			for _,v in ipairs(components) do
				local component = ESX.GetWeaponComponent(name, v)
				GiveWeaponComponentToWeaponObject(pickupObject, component.hash)
			end

			setObjectProperties(pickupObject)
		else
			ESX.Game.SpawnLocalObject('prop_money_bag_01', coords, setObjectProperties)
		end
	end)

	RegisterNetEvent('esx:createMissingPickups')
	AddEventHandler('esx:createMissingPickups', function(missingPickups)
		for pickupId, pickup in pairs(missingPickups) do
			TriggerEvent('esx:createPickup', pickupId, pickup.label, pickup.coords - vector3(0,0, 1.0), pickup.type, pickup.name, pickup.components, pickup.tintIndex)
		end
	end)
end


RegisterNetEvent('esx:registerSuggestions')
AddEventHandler('esx:registerSuggestions', function(registeredCommands)
	for name,command in pairs(registeredCommands) do
		if command.suggestion then
			TriggerEvent('chat:addSuggestion', ('/%s'):format(name), command.suggestion.help, command.suggestion.arguments)
		end
	end
end)

if not Config.OxInventory then
	RegisterNetEvent('esx:removePickup')
	AddEventHandler('esx:removePickup', function(pickupId)
		if pickups[pickupId] and pickups[pickupId].obj then
			ESX.Game.DeleteObject(pickups[pickupId].obj)
			pickups[pickupId] = nil
		end
	end)
end

RegisterNetEvent('esx:deleteVehicle')
AddEventHandler('esx:deleteVehicle', function(radius)
	if radius and tonumber(radius) then
		radius = tonumber(radius) + 0.01
		local vehicles = ESX.Game.GetVehiclesInArea(GetEntityCoords(ESX.PlayerData.ped), radius)

		for _,entity in ipairs(vehicles) do
			local attempt = 0

			while not NetworkHasControlOfEntity(entity) and attempt < 100 and DoesEntityExist(entity) do
				Wait(100)
				NetworkRequestControlOfEntity(entity)
				attempt += 1
			end

			if DoesEntityExist(entity) and NetworkHasControlOfEntity(entity) then
				ESX.Game.DeleteVehicle(entity)
			end
		end
	else
		local vehicle, attempt = ESX.Game.GetVehicleInDirection(), 0

		if IsPedInAnyVehicle(ESX.PlayerData.ped, true) then
			vehicle = GetVehiclePedIsIn(ESX.PlayerData.ped, false)
		end

		while not NetworkHasControlOfEntity(vehicle) and attempt < 100 and DoesEntityExist(vehicle) do
			Wait(100)
			NetworkRequestControlOfEntity(vehicle)
			attempt += 1
		end

		if DoesEntityExist(vehicle) and NetworkHasControlOfEntity(vehicle) then
			ESX.Game.DeleteVehicle(vehicle)
		end
	end
end)

RegisterNetEvent('esx:deleteVehicle2')
AddEventHandler('esx:deleteVehicle2', function()
    for _, prop in pairs(GetGamePool("CObject")) do
        if DoesEntityExist(prop) and NetworkGetEntityOwner(prop) == GetPlayerServerId(PlayerId()) and GetEntityScript(prop) then
            SetEntityAsMissionEntity(prop, false, false)
            DeleteEntity(prop)
        end
    end
end)

function StartServerSyncLoops()
	if not Config.OxInventory then
			-- keep track of ammo

			CreateThread(function()
					local currentWeapon = {Ammo = 0}
					while ESX.PlayerLoaded do
						local sleep = 1500
						if GetSelectedPedWeapon(ESX.PlayerData.ped) ~= -1569615261 then
							sleep = 1000
							local _,weaponHash = GetCurrentPedWeapon(ESX.PlayerData.ped, true)
							local weapon = ESX.GetWeaponFromHash(weaponHash)
							if weapon then
								local ammoCount = GetAmmoInPedWeapon(ESX.PlayerData.ped, weaponHash)
								if weapon.name ~= currentWeapon.name then
									currentWeapon.Ammo = ammoCount
									currentWeapon.name = weapon.name
								else
									if ammoCount ~= currentWeapon.Ammo then
										currentWeapon.Ammo = ammoCount
										TriggerServerEvent('esx:updateWeaponAmmo', weapon.name, ammoCount)
									end
								end
							end
						end
					Wait(sleep)
					end
			end)
	end
end

-- disable wanted level
if not Config.EnableWantedLevel then
	ClearPlayerWantedLevel(PlayerId())
	SetMaxWantedLevel(0)
end

RegisterNetEvent("esx:tpm")
AddEventHandler("esx:tpm", function()
local PlayerPedId = PlayerPedId
local GetEntityCoords = GetEntityCoords
local GetGroundZFor_3dCoord = GetGroundZFor_3dCoord

	ESX.TriggerServerCallback("esx:isUserAdmin", function(admin)
		if admin then
			local blipMarker = GetFirstBlipInfoId(8)
			if not DoesBlipExist(blipMarker) then
					ESX.ShowNotification('No Waypoint Set.')
					return 'marker'
			end

			local ped, coords = PlayerPedId(), GetBlipInfoIdCoord(blipMarker)
			local vehicle = GetVehiclePedIsIn(ped, false)
			local oldCoords = GetEntityCoords(ped)

			local x, y, groundZ, Z_START = coords['x'], coords['y'], 850.0, 950.0
			local found = false
			if vehicle > 0 then
					FreezeEntityPosition(vehicle, true)
			else
					FreezeEntityPosition(ped, true)
			end

			for i = Z_START, 0, -25.0 do
					local z = i
					if (i % 2) ~= 0 then
							z = Z_START - i
					end

					NewLoadSceneStart(x, y, z, x, y, z, 50.0, 0)
					local curTime = GetGameTimer()
					while IsNetworkLoadingScene() do
							if GetGameTimer() - curTime > 1000 then
									break
							end
							Wait(0)
					end
					NewLoadSceneStop()
					SetPedCoordsKeepVehicle(ped, x, y, z)

					while not HasCollisionLoadedAroundEntity(ped) do
							RequestCollisionAtCoord(x, y, z)
							if GetGameTimer() - curTime > 1000 then
									break
							end
							Wait(0)
					end

					found, groundZ = GetGroundZFor_3dCoord(x, y, z, false)
					if found then
							Wait(0)
							SetPedCoordsKeepVehicle(ped, x, y, groundZ)
							break
					end
					Wait(0)
			end

			if vehicle > 0 then
					FreezeEntityPosition(vehicle, false)
			else
					FreezeEntityPosition(ped, false)
			end

			if not found then
					SetPedCoordsKeepVehicle(ped, oldCoords['x'], oldCoords['y'], oldCoords['z'] - 1.0)
					ESX.ShowNotification('Successfully Teleported')
			end

			SetPedCoordsKeepVehicle(ped, x, y, groundZ)
			ESX.ShowNotification('Successfully Teleported')
		end
	end)
end)

RegisterNetEvent("esx:killPlayer")
AddEventHandler("esx:killPlayer", function()
  SetEntityHealth(ESX.PlayerData.ped, 0)
end)

RegisterNetEvent("esx:freezePlayer")
AddEventHandler("esx:freezePlayer", function(input)
    local player = PlayerId()
    if input == 'freeze' then
        SetEntityCollision(ESX.PlayerData.ped, false)
        FreezeEntityPosition(ESX.PlayerData.ped, true)
        SetPlayerInvincible(player, true)
    elseif input == 'unfreeze' then
        SetEntityCollision(ESX.PlayerData.ped, true)
	    FreezeEntityPosition(ESX.PlayerData.ped, false)
        SetPlayerInvincible(player, false)
    end
end)

ESX.RegisterClientCallback("esx:GetVehicleType", function(cb, model)
	cb(ESX.GetVehicleType(model))
end)

local DoNotUse = {
	'essentialmode',
	'es_admin2',
	'basic-gamemode',
	'mapmanager',
	'fivem-map-skater',
	'fivem-map-hipster',
	'qb-core',
	'default_spawnpoint',
}

for i=1, #DoNotUse do
	if GetResourceState(DoNotUse[i]) == 'started' or GetResourceState(DoNotUse[i]) == 'starting' then
		print("[^1ERROR^7] YOU ARE USING A RESOURCE THAT WILL BREAK ^1ESX^7, PLEASE REMOVE ^5"..DoNotUse[i].."^7")
		StopResource(DoNotUse[i])
		print("STOPPED RESOURCE: ^5"..DoNotUse[i].."^7")
	end
end
