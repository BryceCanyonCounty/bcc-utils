-- RayfireAPI.lua

RayfireAPI = {}

-- Create / fetch a Rayfire map object from coords & radius
function RayfireAPI:Create(x, y, z, radius, name)
    local RayfireClass = {}

    local handle = GetRayfireMapObject(
        x, y, z,
        CheckVar(radius, 5.0),
        CheckVar(name, "")
    )

    RayfireClass.Handle = handle

    --------------------------------------------------------
    -- INSTANCE METHODS
    --------------------------------------------------------

    function RayfireClass:GetHandle()
        return self.Handle
    end

    function RayfireClass:Exists()
        return DoesRayfireMapObjectExist(self.Handle)
    end

    function RayfireClass:GetState()
        return GetStateOfRayfireMapObject(self.Handle)
    end

    function RayfireClass:SetState(state)
        SetStateOfRayfireMapObject(self.Handle, CheckVar(state, 0))
    end

    function RayfireClass:GetAnimPhase()
        return GetRayfireMapObjectAnimPhase(self.Handle)
    end

    return RayfireClass
end

-- Wrap an existing handle
function RayfireAPI:FromHandle(handle)
    local RayfireClass = {}
    RayfireClass.Handle = handle

    function RayfireClass:GetHandle()
        return self.Handle
    end

    function RayfireClass:Exists()
        return DoesRayfireMapObjectExist(self.Handle)
    end

    function RayfireClass:GetState()
        return GetStateOfRayfireMapObject(self.Handle)
    end

    function RayfireClass:SetState(state)
        SetStateOfRayfireMapObject(self.Handle, CheckVar(state, 0))
    end

    function RayfireClass:GetAnimPhase()
        return GetRayfireMapObjectAnimPhase(self.Handle)
    end

    return RayfireClass
end

return RayfireAPI
