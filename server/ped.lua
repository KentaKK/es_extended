---Set Player Ped
---@param identifier string
---@param model string|number
local function SetPlayerPed(identifier, model)
    MySQL.update.await("UPDATE `users` SET `ped` = ? WHERE `identifier` = ?", {model, identifier})
end

---Command
---@param xPlayer table
---@param args string|number
---@param showError any
ESX.RegisterCommand('setped', 'admin', function(xPlayer, args, showError)
    local xTarget = ESX.GetPlayerFromId(args.target)

    if xTarget then
            if args.model == "none" then
                TriggerClientEvent('esx:resetPed', xTarget.source)
                TriggerClientEvent('chat:addMessage', xPlayer.source, {args = {'^1SYSTEM', ('You have reset %s ped to default!'):format(xTarget.name)}})
                SetPlayerPed(xTarget.identifier, "none")
            else
                TriggerClientEvent('esx:setPed', xTarget.source, args.model)
                TriggerClientEvent('chat:addMessage', xPlayer.source, {args = {'^1SYSTEM', ('You have set %s ped to %s!'):format(xTarget.name, args.model)}})
                SetPlayerPed(xTarget.identifier, args.model)
            end
    else
        TriggerClientEvent('chat:addMessage', xPlayer.source, {args = {'^1SYSTEM', 'Invalid PlayerID!'}})
    end
end, true, {help = 'Set a ped to player', validate = true, arguments = {
    {name = 'target', help = 'playerid', type = 'number'},
    {name = 'model', help = 'ped model', type = 'string'}
}})
