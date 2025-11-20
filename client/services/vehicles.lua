VehicleAPI = {}

function VehicleAPI:Create(modelHash, x, y, z, heading, isNetwork, bScriptHostVeh, bDontAutoCreateDraftAnimals, p8)
    local VehicleClass = {}
    local hash = type(modelHash) == "string" and GetHashKey(modelHash) or modelHash

    -- Load the model
    while not HasVehicleAssetLoaded(hash) do
        RequestVehicleAsset(hash)
        Wait(10)
    end

    -- Create the vehicle
    local vehicle = CreateVehicle(hash, x, y, z, heading, isNetwork, bScriptHostVeh, bDontAutoCreateDraftAnimals, p8)
    VehicleClass.Vehicle = vehicle

    -- Methods for the VehicleClass
    function VehicleClass:SetEngineOn(state, instantly)
        SetVehicleEngineOn(self.Vehicle, state, instantly or false)
    end

    function VehicleClass:SetForwardSpeed(speed)
        SetVehicleForwardSpeed(self.Vehicle, speed)
    end

    function VehicleClass:Freeze(state)
        FreezeEntityPosition(self.Vehicle, state or true)
    end

    function VehicleClass:SetHeading(head)
        SetEntityHeading(self.Vehicle, head or 0.0)
    end

    function VehicleClass:SetAsMissionEntity(state, p2)
        SetEntityAsMissionEntity(self.Vehicle, state or true, p2 or true)
    end

    function VehicleClass:SetAsNoLongerNeeded()
        SetVehicleAsNoLongerNeeded(self.Vehicle)
    end

    function VehicleClass:Remove()
        DeleteVehicle(self.Vehicle)
    end

    function VehicleClass:GetVehicle()
        return self.Vehicle
    end

    function VehicleClass:SetDoorsLocked(lockStatus)
        SetVehicleDoorsLocked(self.Vehicle, lockStatus)
    end

    function VehicleClass:SetInvincible(state)
        SetEntityInvincible(self.Vehicle, state or true)
    end

    function VehicleClass:AreAnySeatsFree()
        return AreAnyVehicleSeatsFree(self.Vehicle)
    end

    function VehicleClass:AttachDraftHarnessPed(mount, draft, harnessId)
        return AttachDraftVehicleHarnessPed(self.Vehicle, draft, harnessId)
    end

    function VehicleClass:BreakOffWheel(wheelIndex, destroyingForce)
        BreakOffDraftWheel(self.Vehicle, wheelIndex, destroyingForce)
    end

    function VehicleClass:BringToHalt(distance, duration, unknown)
        BringVehicleToHalt(self.Vehicle, distance, duration, unknown)
    end

    function VehicleClass:CanAnchorBoat()
        return CanAnchorBoatHere(self.Vehicle)
    end

    function VehicleClass:CanShuffleSeat(seatIndex)
        return CanShuffleSeat(self.Vehicle, seatIndex)
    end

    function VehicleClass:CopyDamages(sourceVehicle)
        CopyVehicleDamages(sourceVehicle, self.Vehicle)
    end

    function VehicleClass:Explode(isAudible, isInvisible)
        ExplodeVehicle(self.Vehicle, isAudible, isInvisible)
    end

    function VehicleClass:GetDriver()
        return GetDriverOfVehicle(self.Vehicle)
    end

    function VehicleClass:GetLastPedInSeat(seatIndex)
        return GetLastPedInVehicleSeat(self.Vehicle, seatIndex)
    end

    function VehicleClass:GetPedInSeat(seatIndex)
        return GetPedInVehicleSeat(self.Vehicle, seatIndex)
    end

    function VehicleClass:GetBodyHealth()
        return GetVehicleBodyHealth(self.Vehicle)
    end

    function VehicleClass:GetEngineHealth()
        return GetVehicleEngineHealth(self.Vehicle)
    end

    function VehicleClass:GetPetrolTankHealth()
        return GetVehiclePetrolTankHealth(self.Vehicle)
    end

    function VehicleClass:GetNumberOfPassengers()
        return GetVehicleNumberOfPassengers(self.Vehicle)
    end

    function VehicleClass:IsSeatFree(seatIndex)
        return IsVehicleSeatFree(self.Vehicle, seatIndex)
    end

    function VehicleClass:IsStopped()
        return IsVehicleStopped(self.Vehicle)
    end

    function VehicleClass:IsOnAllWheels()
        return IsVehicleOnAllWheels(self.Vehicle)
    end

    function VehicleClass:IsWindowIntact(windowIndex)
        return IsVehicleWindowIntact(self.Vehicle, windowIndex)
    end

    function VehicleClass:IsWrecked()
        return IsVehicleWrecked(self.Vehicle)
    end

    function VehicleClass:ModifyTopSpeed(value)
        ModifyVehicleTopSpeed(self.Vehicle, value)
    end

    function VehicleClass:SetVehicleStrong(toggle)
        SetVehicleStrong(self.Vehicle, toggle)
    end

    function VehicleClass:SetVehicleTyresCanBurst(toggle)
        SetVehicleTyresCanBurst(self.Vehicle, toggle)
    end

    function VehicleClass:SetVehicleWheelsCanBreak(toggle)
        SetVehicleWheelsCanBreak(self.Vehicle, toggle)
    end

    return VehicleClass
end
