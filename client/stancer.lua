AddStateBagChangeHandler('stancer', nil, function(bagName, key, value, _unused, replicated)
	Wait(100)
	local entity = GetEntityFromStateBagName(bagName)
	if not value or entity == 0 then return end
	local ent = Entity(entity).state
	local plate = GetVehicleNumberPlateText(entity)
	SetVehicleStancer(entity, value)
end)
