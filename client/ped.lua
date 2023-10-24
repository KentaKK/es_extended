RegisterNetEvent('esx:setPed', function(model)
    local hash = joaat(model)
    if not IsModelInCdimage(hash) then return end
    RequestModel(hash)
    while not HasModelLoaded(hash) do
        RequestModel(hash)
        Wait(0)
    end
    Wait(5555)
    SetPlayerModel(PlayerId(), hash)
    SetPedDefaultComponentVariation(PlayerPedId())

    SetModelAsNoLongerNeeded(hash)
    TriggerEvent('esx:restoreLoadout')
end)

RegisterNetEvent('esx:resetPed', function()
    ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
        local isMale = skin.sex == 0

        TriggerEvent('skinchanger:loadDefaultModel', isMale, function()
            ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
                TriggerEvent('skinchanger:loadSkin', skin)
            end)
        end)
    end)
end)
