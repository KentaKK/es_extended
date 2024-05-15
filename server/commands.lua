ESX.RegisterCommand('s', 'superadmin', function(_, args, showError)
	if args.playerId.getAccount(args.account) then
		args.playerId.setAccountMoney(args.account, args.amount, "Government Grant")
	else
		showError(_U('command_giveaccountmoney_invalid'))
	end
end, true, {help = _U('command_setaccountmoney'), validate = true, arguments = {
	{name = 'playerId', help = _U('commandgeneric_playerid'), type = 'player'},
	{name = 'account', help = _U('command_giveaccountmoney_account'), type = 'string'},
	{name = 'amount', help = _U('command_setaccountmoney_amount'), type = 'number'}
}})

ESX.RegisterCommand('g', 'superadmin', function(xPlayer, args, showError)
    print(args.playerId)
	if args.playerId.getAccount(args.account) then
		args.playerId.addAccountMoney(args.account, args.amount, "Government Grant")
	else
		showError(_U('command_giveaccountmoney_invalid'))
	end
end, true, {help = _U('command_giveaccountmoney'), validate = true, arguments = {
	{name = 'playerId', help = _U('commandgeneric_playerid'), type = 'player'},
	{name = 'account', help = _U('command_giveaccountmoney_account'), type = 'string'},
	{name = 'amount', help = _U('command_giveaccountmoney_amount'), type = 'number'}
}})

ESX.RegisterCommand('tp', 'admin', function(xPlayer, args, showError)
	xPlayer.setCoords({x = args.x, y = args.y, z = args.z})
end, false, {help = _U('command_setcoords'), validate = true, arguments = {
	{name = 'x', help = _U('command_setcoords_x'), type = 'number'},
	{name = 'y', help = _U('command_setcoords_y'), type = 'number'},
	{name = 'z', help = _U('command_setcoords_z'), type = 'number'}
}})

ESX.RegisterCommand('setjob', 'admin', function(xPlayer, args, showError)
	if ESX.DoesJobExist(args.job, args.grade) then
		args.playerId.setJob(args.job, args.grade)
	else
		showError(_U('command_setjob_invalid'))
	end
end, true, {help = _U('command_setjob'), validate = true, arguments = {
	{name = 'playerId', help = _U('commandgeneric_playerid'), type = 'player'},
	{name = 'job', help = _U('command_setjob_job'), type = 'string'},
	{name = 'grade', help = _U('command_setjob_grade'), type = 'number'}
}})

local upgrades = Config.SpawnVehMaxUpgrades and
    {
        plate = "ADMINCAR",
        modEngine = 3,
        modBrakes = 2,
        modTransmission = 2,
        modSuspension = 3,
        modArmor = true,
        windowTint = 1
    } or {}

ESX.RegisterCommand('car', 'admin', function(xPlayer, args, showError)
	if not xPlayer then
		return print('[^1ERROR^7] The xPlayer value is nil')
	end

	local playerPed = GetPlayerPed(xPlayer.source)
	local playerCoords = GetEntityCoords(playerPed)
	local playerHeading = GetEntityHeading(playerPed)
	local playerVehicle = GetVehiclePedIsIn(playerPed, false)

	if not args.car or type(args.car) ~= 'string' then
		args.car = 'adder'
	end

	if playerVehicle then
		DeleteEntity(playerVehicle)
	end

	ESX.OneSync.SpawnVehicle(args.car, playerCoords, playerHeading, upgrades, function(networkId)
		if networkId then
			local vehicle = NetworkGetEntityFromNetworkId(networkId)
			for i = 1, 20 do
				Wait(0)
				SetPedIntoVehicle(playerPed, vehicle, -1)

				if GetVehiclePedIsIn(playerPed, false) == vehicle then
					break
				end
			end
			if GetVehiclePedIsIn(playerPed, false) ~= vehicle then
				print('[^1ERROR^7] The player could not be seated in the vehicle')
			end
		end
	end)
end, false, {help = _U('command_car'), validate = false, arguments = {
	{name = 'car',validate = false, help = _U('command_car_car'), type = 'string'}
}})

ESX.RegisterCommand('car2', 'admin', function(xPlayer, args, showError)
	local GameBuild = tonumber(GetConvar("sv_enforceGameBuild", 1604))
	if not args.car then args.car = GameBuild >= 2699 and "DRAUGUR" or "Prototipo" end
	xPlayer.triggerEvent('esx:spawnVehicle2', args.car)
end, false, {help = _U('command_car'), validate = false, arguments = {
	{name = 'car',validate = false, help = _U('command_car_car'), type = 'string'}
}})

ESX.RegisterCommand({'cardel', 'dv'}, 'admin', function(xPlayer, args, showError)
	local PedVehicle = GetVehiclePedIsIn(GetPlayerPed(xPlayer.source), false)
	if DoesEntityExist(PedVehicle) then
		DeleteEntity(PedVehicle)
	end
	local Vehicles = ESX.OneSync.GetVehiclesInArea(GetEntityCoords(GetPlayerPed(xPlayer.source)), tonumber(args.radius) or 5.0)
	for i=1, #Vehicles do
		local Vehicle = NetworkGetEntityFromNetworkId(Vehicles[i])
		if DoesEntityExist(Vehicle) then
			DeleteEntity(Vehicle)
		end
	end
end, false, {help = _U('command_cardel'), validate = false, arguments = {
	{name = 'radius',validate = false, help = _U('command_cardel_radius'), type = 'number'}
}})

ESX.RegisterCommand({'dvv'}, 'admin', function(xPlayer, args, showError)
	if not args.radius then args.radius = 4 end
	xPlayer.triggerEvent('esx:deleteVehicle2', args.radius)
end, false, {help = _U('command_cardel'), validate = false, arguments = {
	{name = 'radius', help = _U('command_cardel_radius'), type = 'any'}
}})

if not Config.OxInventory then
	ESX.RegisterCommand('giveitem', 'admin', function(_, args, _)
		args.playerId.addInventoryItem(args.item, args.count)
	end, true, {help = _U('command_giveitem'), validate = true, arguments = {
		{name = 'playerId', help = _U('commandgeneric_playerid'), type = 'player'},
		{name = 'item', help = _U('command_giveitem_item'), type = 'item'},
		{name = 'count', help = _U('command_giveitem_count'), type = 'number'}
	}})

	ESX.RegisterCommand('p', 'admin', function(_, args, showError)
		if args.playerId.hasWeapon(args.weapon) then
			showError(_U('command_giveweapon_hasalready'))
		else
			args.playerId.addWeapon(args.weapon, args.ammo)
		end
	end, true, {help = _U('command_giveweapon'), validate = true, arguments = {
		{name = 'playerId', help = _U('commandgeneric_playerid'), type = 'player'},
		{name = 'weapon', help = _U('command_giveweapon_weapon'), type = 'weapon'},
		{name = 'ammo', help = _U('command_giveweapon_ammo'), type = 'number'}
	}})

	ESX.RegisterCommand('giveweaponcomponent', 'admin', function(xPlayer, args, showError)
		if args.playerId.hasWeapon(args.weaponName) then
			local component = ESX.GetWeaponComponent(args.weaponName, args.componentName)

			if component then
				if args.playerId.hasWeaponComponent(args.weaponName, args.componentName) then
					showError(_U('command_giveweaponcomponent_hasalready'))
				else
					args.playerId.addWeaponComponent(args.weaponName, args.componentName)
				end
			else
				showError(_U('command_giveweaponcomponent_invalid'))
			end
		else
			showError(_U('command_giveweaponcomponent_missingweapon'))
		end
	end, true, {help = _U('command_giveweaponcomponent'), validate = true, arguments = {
		{name = 'playerId', help = _U('commandgeneric_playerid'), type = 'player'},
		{name = 'weaponName', help = _U('command_giveweapon_weapon'), type = 'weapon'},
		{name = 'componentName', help = _U('command_giveweaponcomponent_component'), type = 'string'}
	}})
end

ESX.RegisterCommand({'clear', 'cls'}, 'user', function(xPlayer, _, _)
	xPlayer.triggerEvent('chat:clear')
end, false, {help = _U('command_clear')})

ESX.RegisterCommand({'clearall', 'clsall'}, 'admin', function(_, _, _)
	TriggerClientEvent('chat:clear', -1)
end, false, {help = _U('command_clearall')})

ESX.RegisterCommand("refreshjobs", 'admin', function(_, _, _)
	ESX.RefreshJobs()
end, true, {help = _U('command_clearall')})

if not Config.OxInventory then
	ESX.RegisterCommand('clearinventory', 'admin', function(_, args, _)
		for _,v in ipairs(args.playerId.inventory) do
			if v.count > 0 then
				args.playerId.setInventoryItem(v.name, 0)
			end
		end
		TriggerEvent('esx:playerInventoryCleared',args.playerId)
	end, true, {help = _U('command_clearinventory'), validate = true, arguments = {
		{name = 'playerId', help = _U('commandgeneric_playerid'), type = 'player'}
	}})

	ESX.RegisterCommand('clearloadout', 'admin', function(_, args, _)
		for i=#args.playerId.loadout, 1, -1 do
			args.playerId.removeWeapon(args.playerId.loadout[i].name)
		end
		TriggerEvent('esx:playerLoadoutCleared',args.playerId)
	end, true, {help = _U('command_clearloadout'), validate = true, arguments = {
		{name = 'playerId', help = _U('commandgeneric_playerid'), type = 'player'}
	}})
end


ESX.RegisterCommand('setgroup', 'admin', function(xPlayer, args, _)
	if not args.playerId then args.playerId = xPlayer.source end
	--[[if args.group == "superadmin" then args.group = "admin" print("[^3WARNING^7] Superadmin detected, setting group to admin") end]]
	args.playerId.setGroup(args.group)
end, true, {help = _U('command_setgroup'), validate = true, arguments = {
	{name = 'playerId', help = _U('commandgeneric_playerid'), type = 'player'},
	{name = 'group', help = _U('command_setgroup_group'), type = 'string'},
}})

ESX.RegisterCommand('save', 'admin', function(_, args, _)
	Core.SavePlayer(args.playerId)
	print("[^2Info^0] Saved Player!")
end, true, {help = _U('command_save'), validate = true, arguments = {
	{name = 'playerId', help = _U('commandgeneric_playerid'), type = 'player'}
}})

ESX.RegisterCommand('saveall', 'admin', function(_, _, _)
	Core.SavePlayers()
end, true, {help = _U('command_saveall')})

ESX.RegisterCommand('group', {"user", "admin"}, function(xPlayer, _, _)
	print(xPlayer.getName()..", You are currently: ^5".. xPlayer.getGroup() .. "^0")
end, true)

ESX.RegisterCommand('job', {"user", "admin"}, function(xPlayer, _, _)
	print(xPlayer.getName()..", You are currently: ^5".. xPlayer.getJob().name.. "^0 - ^5".. xPlayer.getJob().grade_label .. "^0")
end, true)

ESX.RegisterCommand('info', {"user", "admin"}, function(xPlayer, _, _)
	local job = xPlayer.getJob().name
	local jobgrade = xPlayer.getJob().grade_name
	print("^2ID : ^5"..xPlayer.source.." ^0| ^2Name:^5"..xPlayer.getName().." ^0 | ^2Group:^5"..xPlayer.getGroup().."^0 | ^2Job:^5".. job.."^0")
end, true)

ESX.RegisterCommand('coords', 'admin', function(xPlayer, _, _)
    local ped = GetPlayerPed(xPlayer.source)
	local coords = GetEntityCoords(ped, false)
	local heading = GetEntityHeading(ped)
	print("Coords - Vector3: ^5".. vector3(coords.x,coords.y,coords.z).. "^0")
	print("Coords - Vector4: ^5".. vector4(coords.x, coords.y, coords.z, heading) .. "^0")
end, true)

ESX.RegisterCommand('tpm', "admin", function(xPlayer, _, _)
	xPlayer.triggerEvent("esx:tpm")
end, true)

ESX.RegisterCommand('kill', "admin", function(_, args, _)
	args.playerId.triggerEvent("esx:killPlayer")
end, true, {help = _U('command_kill'), validate = true, arguments = {
	{name = 'playerId', help = _U('commandgeneric_playerid'), type = 'player'}
}})

ESX.RegisterCommand('freeze', "admin", function(_, args, _)
	args.playerId.triggerEvent('esx:freezePlayer', "freeze")
end, true, {help = _U('command_freeze'), validate = true, arguments = {
	{name = 'playerId', help = _U('commandgeneric_playerid'), type = 'player'}
}})

ESX.RegisterCommand('unfreeze', "admin", function(_, args, _)
	args.playerId.triggerEvent('esx:freezePlayer', "unfreeze")
end, true, {help = _U('command_unfreeze'), validate = true, arguments = {
	{name = 'playerId', help = _U('commandgeneric_playerid'), type = 'player'}
}})

ESX.RegisterCommand('players', "admin", function(_, _, _)
	local xPlayers = ESX.GetExtendedPlayers() -- Returns all xPlayers
	print("^5"..#xPlayers.." ^2online player(s)^0")
	for i=1, #(xPlayers) do
		local xPlayer = xPlayers[i]
		print("^1[ ^2ID : ^5"..xPlayer.source.." ^0| ^2Name : ^5"..xPlayer.getName().." ^0 | ^2Group : ^5"..xPlayer.getGroup().." ^0 | ^2Identifier : ^5".. xPlayer.identifier .."^1]^0\n")
	end
end, true)
