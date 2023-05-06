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