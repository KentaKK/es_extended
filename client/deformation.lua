local MAX_DEFORM_ITERATIONS = 50
local DEFORMATION_DAMAGE_THRESHOLD = 0.05

exports("GetVehicleDeformation", GetVehicleDeformation)
exports("SetVehicleDeformation", SetVehicleDeformation)

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
