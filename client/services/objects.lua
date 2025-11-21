ObjectAPI = {}

function ObjectAPI:Create(modelhash, x, y, z, heading, networked, method)
    local ObjClass = {}

    local hash = GetHashKey(CheckVar(modelhash, "p_package09"))
    while not HasModelLoaded(hash) do
        RequestModel(hash)
        Wait(10)
    end

    local useNoOffset = (method == "no_offset")

    local obj
    if useNoOffset then
        obj = CreateObjectNoOffset(hash, x, y, z, CheckVar(networked, true), false, true, false)
    else
        obj = CreateObject(hash, x, y, z, CheckVar(networked, true), false, true, false, false)
    end

    if not obj or obj == 0 then
        return nil
    end

    ObjClass.Obj = obj

    if heading then
        SetEntityHeading(obj, heading)
    end

    if CheckVar(method, "standard") == "standard" then
        PlaceObjectOnGroundProperly(obj, true)
        FreezeEntityPosition(obj, true)
    end

    ----------------------------------------------------------------
    -- EXISTING BASIC HELPERS
    ----------------------------------------------------------------

    function ObjClass:PickupLight(state)
        Citizen.InvokeNative(0x7DFB49BCDB73089A, self.Obj, CheckVar(state, true))
    end

    function ObjClass:Freeze(state)
        FreezeEntityPosition(self.Obj, CheckVar(state, true))
    end

    function ObjClass:SetHeading(head)
        SetEntityHeading(self.Obj, CheckVar(head, 0.0))
    end

    function ObjClass:PlaceOnGround(state)
        PlaceObjectOnGroundProperly(self.Obj, CheckVar(state, true))
    end

    function ObjClass:SetAsMission(state)
        SetEntityAsMissionEntity(self.Obj, CheckVar(state, true))
    end

    function ObjClass:SetAsNoLongerNeeded()
        SetModelAsNoLongerNeeded(self.Obj)
    end

    function ObjClass:Invincible(state)
        SetEntityInvincible(self.Obj, CheckVar(state, true))
    end

    function ObjClass:SetNotHorseJumpable(state)
        SetNotJumpableByHorse(self.Obj, CheckVar(state, true))
    end

    function ObjClass:Remove()
        DeleteObject(self.Obj)
    end

    function ObjClass:GetObj()
        return self.Obj
    end

    ----------------------------------------------------------------
    -- OBJECT FRAGMENT / DAMAGE / SKELETON
    ----------------------------------------------------------------

    function ObjClass:CreateSkeleton()
        return CreateObjectSkeleton(self.Obj)
    end

    function ObjClass:BreakAllFragmentBones()
        BreakAllObjectFragmentBones(self.Obj)
    end

    function ObjClass:BreakFragmentChild(p1, p2)
        BreakObjectFragmentChild(self.Obj, p1, CheckVar(p2, true))
    end

    function ObjClass:DamageBone(boneIndex)
        DamageBoneOnProp(self.Obj, CheckVar(boneIndex, 0))
    end

    function ObjClass:FixFragment()
        FixObjectFragment(self.Obj)
    end

    function ObjClass:GetFragmentDamageHealth(returnMax)
        return GetObjectFragmentDamageHealth(self.Obj, CheckVar(returnMax, false))
    end

    ----------------------------------------------------------------
    -- LIGHTING
    ----------------------------------------------------------------

    function ObjClass:SetLightIntensity(intensity)
        SetLightIntensityForObject(self.Obj, CheckVar(intensity, 1.0))
    end

    function ObjClass:GetLightIntensity()
        return GetLightIntensityFromObject(self.Obj)
    end

    -- Raw light intensity getter that some scripts use
    function ObjClass:GetLightIntensityRaw()
        return GetObjectLightIntensity(self.Obj)
    end

    function ObjClass:SetLightScatteringDisabled(disable)
        SetLightScatteringDisabledForObject(self.Obj, CheckVar(disable, true))
    end

    function ObjClass:SetLightTranslucency(value)
        SetLightTranslucencyForObject(self.Obj, CheckVar(value, 0.0))
    end

    ----------------------------------------------------------------
    -- BURN / FIRE VISUALS
    ----------------------------------------------------------------

    function ObjClass:SetBurnIntensity(intensity)
        SetObjectBurnIntensity(self.Obj, CheckVar(intensity, 1.0))
    end

    function ObjClass:SetBurnLevel(level, affectAsh)
        SetObjectBurnLevel(self.Obj, CheckVar(level, 0.0), CheckVar(affectAsh, true))
    end

    function ObjClass:SetBurnOpacity(opacity)
        SetObjectBurnOpacity(self.Obj, CheckVar(opacity, 1.0))
    end

    function ObjClass:SetBurnSpeed(speed, p2)
        SetObjectBurnSpeed(self.Obj, CheckVar(speed, 1.0), CheckVar(p2, speed))
    end

    ----------------------------------------------------------------
    -- PHYSICS & MOVEMENT
    ----------------------------------------------------------------

    function ObjClass:ResetVelocity()
        ResetObjectVelocity(self.Obj)
    end

    function ObjClass:ActivatePhysicsOnUnfreeze(toggle)
        SetActivateObjectPhysicsAsSoonAsItIsUnfrozen(self.Obj, CheckVar(toggle, true))
    end

    function ObjClass:SetKickable(kickable)
        SetObjectKickable(self.Obj, CheckVar(kickable, true))
    end

    function ObjClass:SetAllowLowLodBuoyancy(toggle)
        SetObjectAllowLowLodBuoyancy(self.Obj, CheckVar(toggle, true))
    end

    function ObjClass:SetPhysicsParams(weight, p2, p3, p4, p5, gravity, p7, p8, p9, p10, buoyancy)
        SetObjectPhysicsParams(
            self.Obj,
            CheckVar(weight, 1.0),
            CheckVar(p2, 1.0),
            CheckVar(p3, 1.0),
            CheckVar(p4, 1.0),
            CheckVar(p5, 1.0),
            CheckVar(gravity, 9.8),
            CheckVar(p7, 0.0),
            CheckVar(p8, 0.0),
            CheckVar(p9, 0.0),
            CheckVar(p10, 0.0),
            CheckVar(buoyancy, 1.0)
        )
    end

    function ObjClass:SetAutoJumpableByHorse(state)
        SetAutoJumpableByHorse(self.Obj, CheckVar(state, true))
    end

    function ObjClass:SetNotJumpableByHorse(state)
        SetNotJumpableByHorse(self.Obj, CheckVar(state, true))
    end

    function ObjClass:SlideTo(toX, toY, toZ, speedX, speedY, speedZ, collision)
        return SlideObject(
            self.Obj,
            toX, toY, toZ,
            CheckVar(speedX, 1.0),
            CheckVar(speedY, 1.0),
            CheckVar(speedZ, 1.0),
            CheckVar(collision, true)
        )
    end

    ----------------------------------------------------------------
    -- PROMPTS / INTERACTION / TARGETING
    ----------------------------------------------------------------

    function ObjClass:SetPromptName(name)
        SetObjectPromptName(self.Obj, CheckVar(name, ""))
    end

    function ObjClass:SetPromptNameFromGxt(gxtName)
        SetObjectPromptNameFromGxtEntry(self.Obj, CheckVar(gxtName, ""))
    end

    function ObjClass:SetTakesDamageFromBuildings(enabled)
        SetObjectTakesDamageFromCollidingWithBuildings(self.Obj, CheckVar(enabled, true))
    end

    function ObjClass:SetTargettable(targettable)
        SetObjectTargettable(self.Obj, CheckVar(targettable, true))
    end

    function ObjClass:SetTargettable2(targettable)
        SetObjectTargettable_2(self.Obj, CheckVar(targettable, true))
    end

    function ObjClass:SetTargettableFocus(p1, p2)
        SetObjectTargettableFocus(self.Obj, CheckVar(p1, true), CheckVar(p2, true))
    end

    function ObjClass:SetTintIndex(idx)
        SetObjectTintIndex(self.Obj, CheckVar(idx, 0))
    end

    function ObjClass:SetCustomTextures(txdHash, p2, p3)
        SetCustomTexturesOnObject(self.Obj, txdHash, p2, p3)
    end

    ----------------------------------------------------------------
    -- VISIBILITY / CARRY / PICKUP-RELATED (object handle only)
    ----------------------------------------------------------------

    function ObjClass:TrackVisibility()
        TrackObjectVisibility(self.Obj)
    end

    function ObjClass:IsVisible()
        return IsObjectVisible(self.Obj)
    end

    function ObjClass:IsPortablePickup()
        return IsObjectAPortablePickup(self.Obj)
    end

    function ObjClass:MakeCarriable()
        MakeItemCarriable(self.Obj)
    end

    function ObjClass:MarkForDeletionWhenOutOfRange()
        OnlyCleanUpObjectWhenOutOfRange(self.Obj)
    end

    function ObjClass:HidePickup(toggle)
        HidePickupObject(self.Obj, CheckVar(toggle, true))
    end

    function ObjClass:PreventPortablePickupCollection(p1, p2)
        PreventCollectionOfPortablePickup(self.Obj, CheckVar(p1, true), CheckVar(p2, true))
    end

    function ObjClass:SetPickupCollectableOnMount()
        SetPickupCollectableOnMount(self.Obj)
    end

    function ObjClass:SetPickupDoNotAutoPlaceOnGround()
        SetPickupDoNotAutoPlaceOnGround(self.Obj)
    end

    ----------------------------------------------------------------
    -- BREAK SCALE
    ----------------------------------------------------------------

    function ObjClass:SetBreakScale(scale)
        SetObjectBreakScale(self.Obj, CheckVar(scale, 1.0))
    end

    return ObjClass
end
