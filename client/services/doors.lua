DoorAPI = {}

function DoorAPI:Create(doorHash, p1, p2, p3, threadId, p5, p6)
    local DoorClass = {}

    local hash = type(doorHash) == "number" and doorHash or GetHashKey(doorHash)

    AddDoorToSystemNew(
        hash,
        CheckVar(p1, true),
        CheckVar(p2, true),
        CheckVar(p3, false),
        CheckVar(threadId, GetIdOfThisThread()),
        CheckVar(p5, 0),
        CheckVar(p6, true)
    )

    DoorClass.Hash = hash

    ----------------------------------------------------------------
    -- BASIC
    ----------------------------------------------------------------

    function DoorClass:GetHash()
        return self.Hash
    end

    ----------------------------------------------------------------
    -- STATE
    ----------------------------------------------------------------
    -- Door lock states:
    -- -1 = INVALID
    --  0 = UNLOCKED
    --  1 = LOCKED_UNBREAKABLE
    --  2 = LOCKED_BREAKABLE
    --  3 = HOLD_OPEN_POSITIVE
    --  4 = HOLD_OPEN_NEGATIVE

    function DoorClass:SetState(state)
        DoorSystemSetDoorState(self.Hash, CheckVar(state, 0))
    end

    function DoorClass:GetState()
        return DoorSystemGetDoorState(self.Hash)
    end

    function DoorClass:IsClosed()
        return IsDoorClosed(self.Hash)
    end

    ----------------------------------------------------------------
    -- OPEN RATIO / AUTOMATIC
    ----------------------------------------------------------------

    -- ajar: -1.0 to 1.0, 0.0 = closed
    function DoorClass:SetOpenRatio(ajar, forceUpdate)
        DoorSystemSetOpenRatio(self.Hash, CheckVar(ajar, 0.0), CheckVar(forceUpdate, true))
    end

    function DoorClass:GetOpenRatio()
        return DoorSystemGetOpenRatio(self.Hash)
    end

    function DoorClass:SetAutomaticDistance(distance)
        DoorSystemSetAutomaticDistance(self.Hash, CheckVar(distance, 2.0))
    end

    function DoorClass:SetAutomaticRate(rate)
        DoorSystemSetAutomaticRate(self.Hash, CheckVar(rate, 1.0))
    end

    -- disable = true to disable automatic behavior
    function DoorClass:SetAutomaticState(disable)
        DoorSystemSetAutomaticState(self.Hash, CheckVar(disable, true))
    end

    -- allow changing open ratio even while locked
    function DoorClass:SetAbleToChangeOpenRatioWhileLocked(allow)
        DoorSystemSetAbleToChangeOpenRatioWhileLocked(self.Hash, CheckVar(allow, true))
    end

    ----------------------------------------------------------------
    -- OWNERSHIP / FORCE
    ----------------------------------------------------------------

    function DoorClass:ForceShut(p1)
        DoorSystemForceShut(self.Hash, CheckVar(p1, true))
    end

    function DoorClass:ChangeScriptOwner()
        DoorSystemChangeScriptOwner(self.Hash)
    end

    ----------------------------------------------------------------
    -- REGISTRATION CHECKS
    ----------------------------------------------------------------

    function DoorClass:IsRegisteredWithNetwork()
        return IsDoorRegisteredWithNetwork(self.Hash)
    end

    function DoorClass:IsRegisteredWithOwner()
        return IsDoorRegisteredWithOwner(self.Hash)
    end

    function DoorClass:IsRegisteredWithSystem()
        return IsDoorRegisteredWithSystem(self.Hash)
    end

    ----------------------------------------------------------------
    -- REMOVE
    ----------------------------------------------------------------

    function DoorClass:RemoveFromSystem()
        RemoveDoorFromSystem(self.Hash)
    end

    return DoorClass
end

-- Wrap an existing door hash without registering (same style helper like ObjectAPI helpers if you add them)
function DoorAPI:FromHash(doorHash)
    local DoorClass = {}

    local hash = type(doorHash) == "number" and doorHash or GetHashKey(doorHash)
    DoorClass.Hash = hash

    return DoorClass
end
