PickupAPI = {}

-- Basic pickup
function PickupAPI:Create(pickupHash, x, y, z, flags, p5, p6, modelHash, p8, p9, p10)
    local PickupClass = {}

    local hash = type(pickupHash) == "number" and pickupHash or GetHashKey(pickupHash)
    local model = modelHash and (type(modelHash) == "number" and modelHash or GetHashKey(modelHash)) or 0

    local handle = CreatePickup(
        hash,
        x, y, z,
        CheckVar(flags, 0),
        CheckVar(p5, 0),
        CheckVar(p6, true),
        model,
        CheckVar(p8, 0),
        CheckVar(p9, 0.0),
        p10
    )

    PickupClass.Handle = handle

    --------------------------------------------------------
    -- INSTANCE METHODS
    --------------------------------------------------------

    function PickupClass:GetHandle()
        return self.Handle
    end

    function PickupClass:Exists()
        return DoesPickupExist(self.Handle)
    end

    function PickupClass:Remove()
        if self:Exists() then
            RemovePickup(self.Handle)
        end
    end

    function PickupClass:GetCoords()
        return GetPickupCoords(self.Handle)
    end

    function PickupClass:GetObject()
        return GetPickupObject(self.Handle)
    end

    function PickupClass:IsCollected()
        return HasPickupBeenCollected(self.Handle)
    end

    -- Hide pickup's object (takes pickupObject, so we resolve it)
    function PickupClass:HideObject(toggle)
        local pickupObject = self:GetObject()
        if pickupObject and pickupObject ~= 0 then
            HidePickupObject(pickupObject, CheckVar(toggle, true))
        end
    end

    -- Prevent portable collection (requires pickupObject, not pickup handle)
    function PickupClass:PreventPortableCollection(p1, p2)
        local pickupObject = self:GetObject()
        if pickupObject and pickupObject ~= 0 then
            PreventCollectionOfPortablePickup(
                pickupObject,
                CheckVar(p1, true),
                CheckVar(p2, true)
            )
        end
    end

    -- Mark collectable on mount (pickupObject)
    function PickupClass:SetCollectableOnMount()
        local pickupObject = self:GetObject()
        if pickupObject and pickupObject ~= 0 then
            SetPickupCollectableOnMount(pickupObject)
        end
    end

    -- Do not auto place on ground (pickupObject)
    function PickupClass:SetDoNotAutoPlaceOnGround()
        local pickupObject = self:GetObject()
        if pickupObject and pickupObject ~= 0 then
            SetPickupDoNotAutoPlaceOnGround(pickupObject)
        end
    end

    -- Hidden when uncollectable (generic p0, p1)
    function PickupClass:SetHiddenWhenUncollectable(p0, p1)
        SetPickupHiddenWhenUncollectable(
            CheckVar(p0, self.Handle),
            CheckVar(p1, true)
        )
    end

    function PickupClass:SetNotLootable(p0, p1)
        SetPickupNotLootable(
            CheckVar(p0, self.Handle),
            CheckVar(p1, true)
        )
    end

    function PickupClass:SetParticleFxHighlight(p0, p1)
        SetPickupParticleFxHighlight(
            CheckVar(p0, self.Handle),
            CheckVar(p1, true)
        )
    end

    function PickupClass:SetParticleFxSpawn(p0, p1)
        SetPickupParticleFxSpawn(
            CheckVar(p0, self.Handle),
            CheckVar(p1, true)
        )
    end

    function PickupClass:SetRegenerationTime(duration)
        SetPickupRegenerationTime(self.Handle, CheckVar(duration, 60000))
    end

    function PickupClass:SetUncollectable(p0, p1)
        SetPickupUncollectable(
            CheckVar(p0, self.Handle),
            CheckVar(p1, true)
        )
    end

    return PickupClass
end

-- Ambient pickup creator
function PickupAPI:CreateAmbient(pickupHash, x, y, z, flags, amount, customModel, createAsScriptObject, scriptHostObject, customAmmoType, p10)
    local PickupClass = {}

    local hash = type(pickupHash) == "number" and pickupHash or GetHashKey(pickupHash)
    local model = customModel and (type(customModel) == "number" and customModel or GetHashKey(customModel)) or 0

    local handle = CreateAmbientPickup(
        hash,
        x, y, z,
        CheckVar(flags, 0),
        CheckVar(amount, 1),
        model,
        CheckVar(createAsScriptObject, true),
        CheckVar(scriptHostObject, false),
        CheckVar(customAmmoType, 0),
        CheckVar(p10, 0.0)
    )

    PickupClass.Handle = handle

    -- reuse basic methods – simplest is just attach the same funcs as Create
    -- but to keep syntax same, we can just call main constructor:
    -- however you can use PickupAPI:Wrap(handle) pattern if you like

    function PickupClass:GetHandle()
        return self.Handle
    end

    function PickupClass:Exists()
        return DoesPickupExist(self.Handle)
    end

    function PickupClass:Remove()
        if self:Exists() then
            RemovePickup(self.Handle)
        end
    end

    function PickupClass:GetCoords()
        return GetPickupCoords(self.Handle)
    end

    function PickupClass:GetObject()
        return GetPickupObject(self.Handle)
    end

    return PickupClass
end

-- Rotated pickup creator
function PickupAPI:CreateRotate(pickupHash, posX, posY, posZ, rotX, rotY, rotZ, flags, p8, p9, p10, modelHash, p12, p13, p14)
    local PickupClass = {}

    local hash = type(pickupHash) == "number" and pickupHash or GetHashKey(pickupHash)
    local model = modelHash and (type(modelHash) == "number" and modelHash or GetHashKey(modelHash)) or 0

    local handle = CreatePickupRotate(
        hash,
        posX, posY, posZ,
        CheckVar(rotX, 0.0),
        CheckVar(rotY, 0.0),
        CheckVar(rotZ, 0.0),
        CheckVar(flags, 0),
        CheckVar(p8, 0),
        CheckVar(p9, 0),
        CheckVar(p10, true),
        model,
        CheckVar(p12, 0),
        CheckVar(p13, 0.0),
        p14
    )

    PickupClass.Handle = handle

    function PickupClass:GetHandle()
        return self.Handle
    end

    function PickupClass:Exists()
        return DoesPickupExist(self.Handle)
    end

    function PickupClass:Remove()
        if self:Exists() then
            RemovePickup(self.Handle)
        end
    end

    function PickupClass:GetCoords()
        return GetPickupCoords(self.Handle)
    end

    return PickupClass
end

-- Portable pickup creator (returns both pickup & object-style methods)
function PickupAPI:CreatePortable(pickupHash, x, y, z, placeOnGround, modelHash)
    local PickupClass = {}

    local hash = type(pickupHash) == "number" and pickupHash or GetHashKey(pickupHash)
    local model = modelHash and (type(modelHash) == "number" and modelHash or GetHashKey(modelHash)) or 0

    local pickupObject = CreatePortablePickup(
        hash,
        x, y, z,
        CheckVar(placeOnGround, true),
        model
    )

    PickupClass.Object = pickupObject

    function PickupClass:GetObject()
        return self.Object
    end

    function PickupClass:AttachToPed(ped)
        AttachPortablePickupToPed(self.Object, ped)
    end

    function PickupClass:DetachFromPed()
        DetachPortablePickupFromPed(self.Object)
    end

    function PickupClass:Hide(toggle)
        HidePickupObject(self.Object, CheckVar(toggle, true))
    end

    function PickupClass:PreventCollection(p1, p2)
        PreventCollectionOfPortablePickup(
            self.Object,
            CheckVar(p1, true),
            CheckVar(p2, true)
        )
    end

    function PickupClass:Remove()
        -- Portable pickup is an object; DeleteObject is also valid,
        -- but if you have a pickup handle too, you can use RemovePickup
        DeleteObject(self.Object)
    end

    return PickupClass
end

------------------------------------------------------------
-- STATIC / HELPER FUNCTIONS (API LEVEL)
------------------------------------------------------------

function PickupAPI:ConvertOldTypeToNew(pickupHash)
    local hash = type(pickupHash) == "number" and pickupHash or GetHashKey(pickupHash)
    return ConvertOldPickupTypeToNew(hash)
end

function PickupAPI:IsPickupTypeValid(pickupHash)
    local hash = type(pickupHash) == "number" and pickupHash or GetHashKey(pickupHash)
    return IsPickupTypeValid(hash)
end

function PickupAPI:DoesPickupOfTypeExistInArea(pickupHash, x, y, z, radius)
    local hash = type(pickupHash) == "number" and pickupHash or GetHashKey(pickupHash)
    return DoesPickupOfTypeExistInArea(hash, x, y, z, radius)
end

function PickupAPI:DoesPickupExist(pickup)
    return DoesPickupExist(pickup)
end

function PickupAPI:DoesPickupObjectExist(pickupObject)
    return DoesPickupObjectExist(pickupObject)
end

function PickupAPI:RemoveAllOfType(pickupHash)
    local hash = type(pickupHash) == "number" and pickupHash or GetHashKey(pickupHash)
    RemoveAllPickupsOfType(hash)
end

function PickupAPI:Remove(pickup)
    RemovePickup(pickup)
end

function PickupAPI:GetAmmoTypeFromPickupType(pickupHash)
    local hash = type(pickupHash) == "number" and pickupHash or GetHashKey(pickupHash)
    return GetAmmoTypeFromPickupType(hash)
end

function PickupAPI:GetWeaponTypeFromPickupType(pickupHash)
    local hash = type(pickupHash) == "number" and pickupHash or GetHashKey(pickupHash)
    return GetWeaponTypeFromPickupType(hash)
end

function PickupAPI:SetAmbientPickupLifetime(ms)
    SetAmbientPickupLifetime(CheckVar(ms, 60000))
end

function PickupAPI:SetGenerationRangeMultiplier(multiplier)
    SetPickupGenerationRangeMultiplier(CheckVar(multiplier, 1.0))
end

function PickupAPI:SetLocalPlayerCanCollectPortablePickups(toggle)
    SetLocalPlayerCanCollectPortablePickups(CheckVar(toggle, true))
end

function PickupAPI:SetLocalPlayerPermittedToCollectPickupsWithModel(modelHash, toggle)
    local hash = type(modelHash) == "number" and modelHash or GetHashKey(modelHash)
    SetLocalPlayerPermittedToCollectPickupsWithModel(hash, CheckVar(toggle, true))
end

function PickupAPI:SetMaxNumPortablePickupsCarriedByPlayer(modelHash, count)
    local hash = type(modelHash) == "number" and modelHash or GetHashKey(modelHash)
    SetMaxNumPortablePickupsCarriedByPlayer(hash, CheckVar(count, 1))
end

function PickupAPI:SetNetworkPickupUsableForPlayer(player, pickupHash, isUsable)
    local hash = type(pickupHash) == "number" and pickupHash or GetHashKey(pickupHash)
    SetNetworkPickupUsableForPlayer(player, hash, CheckVar(isUsable, true))
end

function PickupAPI:SuppressRewardType(rewardType, suppress)
    SuppressPickupRewardType(rewardType, CheckVar(suppress, true))
end

function PickupAPI:BlockPickupFromPlayerCollection(p0, p1)
    BlockPickupFromPlayerCollection(p0, p1)
end

function PickupAPI:ForcePickupRegenerate(p0)
    ForcePickupRegenerate(p0)
end

return PickupAPI
