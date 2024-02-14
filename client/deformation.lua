local MAX_DEFORM_ITERATIONS = 150
local DEFORMATION_DAMAGE_THRESHOLD = 0.003

exports("GetVehicleDeformation", GetVehicleDeformation)
exports("SetVehicleDeformation", SetVehicleDeformation)

---This might need some more experimentation
---@param vehicle number
---@param deformationPoints table
---@param cb function?
SetVehicleDeformation = function(vehicle, deformationPoints, cb)
    CreateThread(function()
	    local min, max = GetModelDimensions(GetEntityModel(vehicle))
		local fDeformationDamageMult = GetVehicleHandlingFloat(vehicle, "CHandlingData", "fDeformationDamageMult")
		local damageMult = #(max - min)
		if Config.EnableDebug then
			print(string.format("First deform damagemult: %s", damageMult))
		end
		if (fDeformationDamageMult <= 0.55) then
			damageMult = #(max - min) * 12.0
		elseif (fDeformationDamageMult <= 0.65) then
			damageMult = #(max - min) * 10.0
		elseif (fDeformationDamageMult <= 0.9) then
			damageMult = #(max - min) * 2.0
		end
		if Config.EnableDebug then
			print(string.format("Deform damagemult set: %s", damageMult))
		end

		local deform = true
		local iteration = 0
		local d = 0
		while deform and iteration < MAX_DEFORM_ITERATIONS do
			deform = false
			for _, def in ipairs(deformationPoints) do
				if #GetVehicleDeformationAtPos(vehicle, def[1].x, def[1].y, def[1].z) < def[2] then
					SetVehicleDamage(vehicle, def[1].x, def[1].y, def[1].z, def[2] * damageMult, 2000.0, true)
					deform = true
					d += 1
				end
			end
			iteration += 1
			Wait(10)
		end
		if Config.EnableDebug then
			print(string.format("Deforms set: %s", d))
		end
        if cb then
	        cb()
        end
    end)
end

---@param vehicle number
---@return table
GetVehicleDeformation = function(vehicle)
	local min, max = GetModelDimensions(GetEntityModel(vehicle))
	local X = (max.x - min.x)
	local Y = (max.y - min.y)
	local Z = (max.z - min.z)
	local halfY = Y

	local positions = {
		vector3(-X, Y,  0.0),
		vector3(-X, Y,  Z),
		vector3(0.0, Y,  0.0),
		vector3(0.0, Y,  Z),
		vector3(X, Y,  0.0),
		vector3(X, Y,  Z),
		vector3(-X, halfY,  0.0),
		vector3(-X, halfY,  Z),
	    vector3(-X, halfY + (halfY / 2),  0.0),
		vector3(-X, halfY + (halfY / 2),  Z),
		vector3(-X, halfY - (halfY / 2),  0.0),
		vector3(-X, halfY - (halfY / 2),  Z),
		vector3(0.0, halfY,  0.0),
		vector3(0.0, halfY,  Z),
		vector3(X, halfY,  0.0),
		vector3(X, halfY,  Z),
	    vector3(X, halfY + (halfY / 2),  0.0),
		vector3(X, halfY + (halfY / 2),  Z),
		vector3(X, halfY - (halfY / 2),  0.0),
		vector3(X, halfY - (halfY / 2),  Z),
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

	for i=1, #positions do
		local pos = positions[i]
		local dmg = #GetVehicleDeformationAtPos(vehicle, pos.x, pos.y, pos.z)
		if dmg > DEFORMATION_DAMAGE_THRESHOLD then
			if Config.EnableDebug then
				print(dmg)
			end
			deformationPoints[#deformationPoints + 1] = {pos, dmg}
		end
	end
	if Config.EnableDebug then
		print(string.format("Deforms got: %s", #deformationPoints))
	end
	return deformationPoints
end

if Config.EnableDebug then
	CreateThread(function()
		while true do
		local sleep = 1000
		local ped = PlayerPedId()
		if IsPedInAnyVehicle(ped, true) then
			sleep = 0
			local vehicle = GetVehiclePedIsIn(ped, false)
			local min, max = GetModelDimensions(GetEntityModel(vehicle))
			local X = (max.x - min.x)
			local Y = (max.y - min.y)
			local Z = (max.z - min.z)
			local halfY = Y
			local positions = {
				vector3(-X, Y,  0.0),
				vector3(-X, Y,  Z),
				vector3(0.0, Y,  0.0),
				vector3(0.0, Y,  Z),
				vector3(X, Y,  0.0),
				vector3(X, Y,  Z),
				vector3(-X, halfY,  0.0),
				vector3(-X, halfY,  Z),
				vector3(-X, halfY + (halfY / 2),  0.0),
				vector3(-X, halfY + (halfY / 2),  Z),
				vector3(-X, halfY - (halfY / 2),  0.0),
				vector3(-X, halfY - (halfY / 2),  Z),
				vector3(0.0, halfY,  0.0),
				vector3(0.0, halfY,  Z),
				vector3(X, halfY,  0.0),
				vector3(X, halfY,  Z),
				vector3(X, halfY + (halfY / 2),  0.0),
				vector3(X, halfY + (halfY / 2),  Z),
				vector3(X, halfY - (halfY / 2),  0.0),
				vector3(X, halfY - (halfY / 2),  Z),
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
				vector3(-X, halfY + (halfY / 2), -Z),
				vector3(-X, halfY - (halfY / 2), -Z),
				vector3(0.0, halfY, -Z),
				vector3(X, halfY + (halfY / 2), -Z),
				vector3(X, halfY - (halfY / 2), -Z),
				vector3(-X, 0.0, -Z),
				vector3(0.0, 0.0, -Z),
				vector3(X, 0.0, -Z),
				vector3(-X, -halfY, -Z),
				vector3(-X, -(halfY + (halfY / 2)), -Z),
				vector3(-X, -(halfY - (halfY / 2)), -Z),
				vector3(0.0, -halfY, -Z),
				vector3(0.0, -(halfY + (halfY / 2)), -Z),
				vector3(0.0, -(halfY - (halfY / 2)), -Z),
				vector3(X, -halfY, -Z),
				vector3(X, -(halfY + (halfY / 2)), -Z),
				vector3(X, -(halfY - (halfY / 2)), -Z),
				vector3(-X, -Y, -Z),
				vector3(0.0, -Y, -Z),
				vector3(X, -Y, -Z),
				vector3(-(X / 2), Y, -Z),
				vector3((X / 2), Y, -Z),
				vector3(-(X / 2), halfY,  -Z),
				vector3(-(X / 2), halfY + (halfY / 2), -Z),
				vector3(-(X / 2), halfY - (halfY / 2), -Z),
				vector3((X / 2), halfY + (halfY / 2), -Z),
				vector3((X / 2), halfY - (halfY / 2), -Z),
				vector3(-(X / 2), 0.0, -Z),
				vector3(-(X / 2), -halfY, -Z),
				vector3(-(X / 2), -(halfY + (halfY / 2)), -Z),
				vector3(-(X / 2), -(halfY - (halfY / 2)), -Z),
				vector3((X / 2), -halfY, -Z),
				vector3((X / 2), -(halfY + (halfY / 2)), -Z),
				vector3((X / 2), -(halfY - (halfY / 2)), -Z),
				vector3(-(X / 2), -Y, -Z),
				vector3((X / 2), -Y, -Z),
			}
			for i=1, #positions do
				local c = positions[i]
				DrawMarker(28, c.x, c.y, c.z, c.x, c.y, c.z, c.x, c.y, c.z,
				c.x, c.y, c.z, 14, 230, 14,
				100, false, true, 2, false, false, false, false)
			end
			local c2 = GetEntityCoords(ped)
			DrawMarker(28, c2.x, c2.y, c2.z + 2, 0.0, 0.0, 0.0, 0.0, 0.0, 0.2,
			0.2, 0.2, 0.2, 14, 230, 14,
			100, false, true, 2, false, false, false, false)
		end
		Wait(sleep)
	    end
	end)
end
