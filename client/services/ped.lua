PedAPI = {}

function PedAPI.SetStatic(ped)
    SetEntityAsMissionEntity(ped, true, true)
    SetEntityInvincible(ped, true)
    FreezeEntityPosition(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
end

function PedAPI.ScenarioInPlace(ped, hash, time)
    FreezeEntityPosition(ped, true)
    TaskStartScenarioInPlace(ped, joaat(hash), time, true, false, false, false)
    Wait(time)
    ClearPedTasksImmediately(ped)
    FreezeEntityPosition(ped, false)
end

function PedAPI.CreatePed(model, x, y, z, h, networked, scripthostped, staticped)
    joaat(model)
    RequestModel(model)
    if not HasModelLoaded(model) then
        RequestModel(model)
    end
    while not HasModelLoaded(model) do
      Wait(100)
    end
    local ped = CreatePed(model, x, y, z, h, networked, scripthostped)
    Citizen.InvokeNative(0x283978A15512B2FE, ped, true)
    if staticped then
        PedAPI.SetStatic(ped)
    end
    return ped
end

function PedAPI.FreezePed(ped)
    FreezeEntityPosition(ped, true)
end

function PedAPI.UnfreezePed(ped)
    FreezeEntityPosition(ped, false)
end

function PedAPI.SetPedHealth(ped, healthamount)
    SetEntityHealth(ped, healthamount, 0)
end
