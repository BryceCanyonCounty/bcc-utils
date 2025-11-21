PromptsAPI = {}

--=============================================================
--  HIGH LEVEL OOP-STYLE API (KEEPS YOUR OLD BEHAVIOUR)
--=============================================================
function PromptsAPI:SetupPromptGroup(groupId)
    ----------------- Setup PromptGroup class and add attributes to prompt-----------------
    local GroupsClass = {}
    GroupsClass.PromptGroup = CheckVar(groupId, GetRandomIntInRange(0, 0xffffff))
    ----------------- ----------------- ----------------- ----------------- ----------

    ----------------- PromptGroup Specific APIs below -----------------
    function GroupsClass:ShowGroup(text, tabAmount, tabDefaultIndex, p4, prompt)
        -- Defaults so old calls still work:
        -- :ShowGroup("Some text") → 1 tab, index 0
        UiPromptSetActiveGroupThisFrame(
            self.PromptGroup,
            CreateVarString(10, 'LITERAL_STRING', CheckVar(text, 'Prompt Info')),
            CheckVar(tabAmount, 1),         -- tabAmount (how many tabs)
            CheckVar(tabDefaultIndex, 0),   -- starting index
            CheckVar(p4, 0),                -- usually 0–3 (see note)
            CheckVar(prompt, 0)             -- usually 0 if unused
        )
    end


    -- Optional extra group helper (ambient group setup this frame)
    function GroupsClass:SetAmbientGroupThisFrame(entity, p1, p2, p3, controlAction, name, p6)
        -- UiPromptSetAmbientGroupThisFrame
        UiPromptSetAmbientGroupThisFrame(entity, p1, p2, p3, controlAction, CreateVarString(10, 'LITERAL_STRING', name), p6
        )
    end

    -- TODO: Make a distance check and only show the closest registered prompt (Ideally this should DRASTICALLY help reduce resource consumption)
    function GroupsClass:RegisterPrompt(title, button, enabled, visible, pulsing, mode, options)
        ----------------- Setup Prompt class and add attributes to prompt-----------------
        local PromptClass = {}
        PromptClass.Prompt = UiPromptRegisterBegin()
        PromptClass.Mode = mode
        ----------------- ----------------- ----------------- ----------------- ----------

        UiPromptSetControlAction(PromptClass.Prompt, CheckVar(button, 0x4CC0E2FE))
        UiPromptSetText(PromptClass.Prompt, CreateVarString(10, 'LITERAL_STRING', CheckVar(title, 'Title')))
        UiPromptSetEnabled(PromptClass.Prompt, CheckVar(enabled, 1))
        UiPromptSetVisible(PromptClass.Prompt, CheckVar(visible, 1))

        if mode == 'click' then
            UiPromptSetStandardMode(PromptClass.Prompt, 1)
        end

        if mode == 'customhold' then
            UiPromptSetHoldMode(PromptClass.Prompt, CheckVar(options and options.holdtime, 3000))
        end

        if mode == 'hold' then
            -- Possible hashes: SHORT_TIMED_EVENT_MP, SHORT_TIMED_EVENT, MEDIUM_TIMED_EVENT, LONG_TIMED_EVENT, RUSTLING_CALM_TIMING, PLAYER_FOCUS_TIMING, PLAYER_REACTION_TIMING
            UiPromptSetStandardizedHoldMode(PromptClass.Prompt, CheckVar(options and options.timedeventhash, 'MEDIUM_TIMED_EVENT'))
        end

        if mode == 'mash' then
            UiPromptSetMashMode(PromptClass.Prompt, CheckVar(options and options.mashamount, 20))
        end

        if mode == 'timed' then
            UiPromptSetPressedTimedMode(PromptClass.Prompt, CheckVar(options and options.depletiontime, 10000))
        end

        UiPromptSetGroup(PromptClass.Prompt, self.PromptGroup, CheckVar(options and options.tabIndex, 0))

        -- UiPromptSetUrgentPulsingEnabled
        UiPromptSetUrgentPulsingEnabled(PromptClass.Prompt, CheckVar(pulsing, true))
        UiPromptRegisterEnd(PromptClass.Prompt)

        ----------------- Prompt Specific APIs below (YOUR ORIGINAL ONES) -----------------
        function PromptClass:TogglePrompt(toggle)
            UiPromptSetVisible(self.Prompt, toggle)
        end

        function PromptClass:SetGroup(groupId, tabIndex)
            UiPromptSetGroup( self.Prompt, CheckVar(groupId, 0), CheckVar(tabIndex, 0))
        end
        
        function PromptClass:EnabledPrompt(toggle)
            UiPromptSetEnabled(self.Prompt, toggle)
        end

        function PromptClass:DeletePrompt()
            UiPromptDelete(self.Prompt)
        end

        function PromptClass:HasCompleted(hideoncomplete)
            if self.Mode == 'click' then
                return UiPromptHasStandardModeCompleted(self.Prompt, 0)
            end

            if self.Mode == 'hold' or self.Mode == 'customhold' then
                local result = UiPromptHasHoldModeCompleted(self.Prompt)

                if result then
                    Wait(500) --Prevents the spamming of the result (ensures it only gets triggered 1 time)
                end

                return result
            end

            if self.Mode == 'mash' then
                local result = UiPromptHasMashModeCompleted(self.Prompt)
                if result then
                    Wait(500) --Prevents the spamming of the result (ensures it only gets triggered 1 time)
                end

                return result
            end

            if self.Mode == 'timed' then
                local result = UiPromptHasPressedTimedModeCompleted(self.Prompt)

                if result and CheckVar(hideoncomplete, true) then
                    self:TogglePrompt(false)
                    Wait(200)
                end

                return result
            end
        end

        function PromptClass:HasFailed(hideoncomplete)
            if self.Mode == 'click' or self.Mode == 'hold' or self.Mode == 'customhold' then
                return false
            end

            if self.Mode == 'mash' then
                local result = UiPromptHasMashModeFailed(self.Prompt)

                if result then
                    self:TogglePrompt(false)
                end

                return result
            end

            if self.Mode == 'timed' then
                local result = UiPromptHasPressedTimedModeFailed(self.Prompt)

                if result and CheckVar(hideoncomplete, true) then
                    self:TogglePrompt(false)
                    Wait(200)
                end

                return result
            end
        end

        ----------------- EXTRA HIGH-LEVEL HELPERS USING OTHER PROMPT NATIVES -----------------

        -- State
        function PromptClass:IsActive()
            return UiPromptIsActive(self.Prompt)
        end

        function PromptClass:IsEnabled()
            return UiPromptIsEnabled(self.Prompt)
        end

        function PromptClass:IsPressed()
            return UiPromptIsPressed(self.Prompt)
        end

        function PromptClass:IsJustPressed()
            return UiPromptIsJustPressed(self.Prompt)
        end

        function PromptClass:IsJustReleased()
            return UiPromptIsJustReleased(self.Prompt)
        end

        function PromptClass:IsReleased()
            return UiPromptIsReleased(self.Prompt)
        end

        function PromptClass:IsValid()
            return UiPromptIsValid(self.Prompt)
        end

        -- Progress
        function PromptClass:GetProgress()
            return UiPromptGetProgress(self.Prompt)
        end

        function PromptClass:GetMashProgress()
            return UiPromptGetMashModeProgress(self.Prompt)
        end

        -- Visuals / behavior
        function PromptClass:SetUrgentPulsing(toggle)
            UiPromptSetUrgentPulsingEnabled(self.Prompt, toggle)
        end

        function PromptClass:SetPriority(priority)
            UiPromptSetPriority(self.Prompt, priority)
        end

        function PromptClass:SetTransportMode(mode)
            UiPromptSetTransportMode(self.Prompt, mode)
        end

        function PromptClass:SetType(type)
            UiPromptSetType(self.Prompt, type)
        end

        function PromptClass:SetAttribute(attribute, enabled)
            UiPromptSetAttribute(self.Prompt, attribute, enabled)
        end

        function PromptClass:SetBeatMode(toggle)
            UiPromptSetBeatMode(self.Prompt, toggle)
        end

        function PromptClass:SetBeatModeGrayedOut(p1)
            UiPromptSetBeatModeGrayedOut(self.Prompt, p1)
        end

        function PromptClass:SetRotateMode(speed, counterclockwise)
            UiPromptSetRotateMode(self.Prompt, speed, counterclockwise)
        end

        function PromptClass:SetTargetMode(p1, p2, p3)
            UiPromptSetTargetMode(self.Prompt, p1, p2, p3)
        end

        function PromptClass:SetTargetModeProgress(progress)
            UiPromptSetTargetModeProgress(self.Prompt, progress)
        end

        function PromptClass:SetTargetModeTarget(p1, p2)
            UiPromptSetTargetModeTarget(self.Prompt, p1, p2)
        end

        function PromptClass:SetSpinnerPosition(val)
            UiPromptSetSpinnerPosition(self.Prompt, val)
        end

        function PromptClass:SetSpinnerSpeed(val)
            UiPromptSetSpinnerSpeed(self.Prompt, val)
        end

        -- Context (3D / volume)
        function PromptClass:SetContextPoint(x, y, z)
            UiPromptContextSetPoint(self.Prompt, x, y, z)
        end

        function PromptClass:SetContextRadius(radius)
            UiPromptContextSetRadius(self.Prompt, radius)
        end

        function PromptClass:SetContextVolume(volume)
            UiPromptContextSetVolume(self.Prompt, volume)
        end

        -- Modes - extra
        function PromptClass:SetHoldAutoFill(autoFillTimeMs, holdTimeMs)
            UiPromptSetHoldAutoFillMode(self.Prompt, autoFillTimeMs, holdTimeMs)
        end

        function PromptClass:SetHoldAutoFillWithDecay(autoFillTimeMs, holdTimeMs)
            UiPromptSetHoldAutoFillWithDecayMode(self.Prompt, autoFillTimeMs, holdTimeMs)
        end

        function PromptClass:SetHoldIndefinitely()
            UiPromptSetHoldIndefinitelyMode(self.Prompt)
        end

        function PromptClass:SetMashAutoFill(autoFillTimeMs, mashes)
            UiPromptSetMashAutoFillMode(self.Prompt, autoFillTimeMs, mashes)
        end

        function PromptClass:SetMashIndefinitely()
            UiPromptSetMashIndefinitelyMode(self.Prompt)
        end

        function PromptClass:SetMashManual(p1, p2, p3, p4)
            UiPromptSetMashManualMode(self.Prompt, p1, p2, p3, p4)
        end

        function PromptClass:SetMashManualCanFail(p1, p2, p3, p4)
            UiPromptSetMashManualCanFailMode(self.Prompt, p1, p2, p3, p4)
        end

        function PromptClass:SetMashManualDecaySpeed(speed)
            UiPromptSetMashManualModeDecaySpeed(self.Prompt, speed)
        end

        function PromptClass:SetMashManualIncreasePerPress(rate)
            UiPromptSetMashManualModeIncreasePerPress(self.Prompt, rate)
        end

        function PromptClass:SetMashManualPressedGrowthSpeed(speed)
            UiPromptSetMashManualModePressedGrowthSpeed(self.Prompt, speed)
        end

        function PromptClass:SetMashWithResistance(mashes, p2, p3)
            UiPromptSetMashWithResistanceMode(self.Prompt, mashes, p2, p3)
        end

        function PromptClass:SetMashWithResistanceCanFail(mashes, decreaseSpeed, startProgress)
            UiPromptSetMashWithResistanceCanFailMode(self.Prompt, mashes, decreaseSpeed, startProgress)
        end

        -- Tagging / manual resolve
        function PromptClass:SetTag(tag)
            UiPromptSetTag(self.Prompt, tag)
        end

        function PromptClass:SetManualResolved(val)
            UiPromptSetManualResolved(self.Prompt, val)
        end

        -- Restart all modes
        function PromptClass:RestartModes()
            UiPromptRestartModes(self.Prompt)
        end

        return PromptClass
    end

    return GroupsClass
end

--=============================================================
--  LOW-LEVEL STATIC HELPERS (ACCESS TO ALL PROMPT NATIVES)
--=============================================================

-- Frame-wide helpers
function PromptsAPI:DisablePromptsThisFrame()
    Citizen.InvokeNative(0xF1622CE88A1946FB) -- UiPromptDisablePromptsThisFrame
end

function PromptsAPI:DisablePromptTypeThisFrame(promptType)
    Citizen.InvokeNative(0xFC094EF26DD153FA, promptType) -- UiPromptDisablePromptTypeThisFrame
end

function PromptsAPI:EnablePromptTypeThisFrame(promptType)
    Citizen.InvokeNative(0x06565032897BA861, promptType) -- UiPromptEnablePromptTypeThisFrame
end

function PromptsAPI:FilterClear()
    Citizen.InvokeNative(0x6A2F820452017EA2) -- UiPromptFilterClear
end

function PromptsAPI:IsControlActionActive(controlAction)
    return Citizen.InvokeNative(0x1BE19185B8AFE299, controlAction) -- UiPromptIsControlActionActive
end

-- Ambient groups
function PromptsAPI:DoesAmbientGroupExist(hash)
    return Citizen.InvokeNative(0xEB550B927B34A1BB, hash) -- UiPromptDoesAmbientGroupExist
end

function PromptsAPI:GetGroupActivePage(hash)
    return Citizen.InvokeNative(0xC1FCC36C3F7286C8, hash) -- UiPromptGetGroupActivePage
end

function PromptsAPI:GetGroupIdForScenarioPoint(scenPoint, p1)
    return Citizen.InvokeNative(0xCB73D7521E7103F0, scenPoint, p1) -- UiPromptGetGroupIdForScenarioPoint
end

function PromptsAPI:GetGroupIdForTargetEntity(entity)
    return Citizen.InvokeNative(0xB796970BD125FCE8, entity) -- UiPromptGetGroupIdForTargetEntity
end

function PromptsAPI:SetActiveGroupThisFrame(hash, text, tabAmount, tabDefaultIndex, p4, prompt)
    Citizen.InvokeNative(
        0xC65A45D4453C2627,
        hash,
        CreateVarString(10, 'LITERAL_STRING', text or ''),
        tabAmount or 0,
        tabDefaultIndex or 0,
        p4 or 0,
        prompt or 0
    ) -- UiPromptSetActiveGroupThisFrame
end

function PromptsAPI:AddGroupLink(p0, prompt, p2)
    Citizen.InvokeNative(0x684C96CC4142932A, p0, prompt, p2) -- UiPromptAddGroupLink
end

function PromptsAPI:AddGroupReturnLink(p0, prompt)
    Citizen.InvokeNative(0x837972ED28159536, p0, prompt) -- UiPromptAddGroupReturnLink
end

function PromptsAPI:RemoveGroup(prompt, p1)
    Citizen.InvokeNative(0x4E52C800A28F7BE8, prompt, p1) -- UiPromptRemoveGroup
end

-- Prompt priority preference
function PromptsAPI:SetPromptPriorityPreference(ped)
    Citizen.InvokeNative(0x530A428705BE5DEF, ped) -- UiPromptSetPromptPriorityPreference
end

function PromptsAPI:ClearPromptPriorityPreference()
    Citizen.InvokeNative(0x51259AE5C72D4A1B) -- UiPromptClearPromptPriorityPreference
end

-- Horizontal orientation
function PromptsAPI:SetRegisterHorizontalOrientation()
    return Citizen.InvokeNative(0xD9459157EB22C895) -- UiPromptSetRegisterHorizontalOrientation
end

function PromptsAPI:ClearHorizontalOrientation(id)
    Citizen.InvokeNative(0x6095358C4142932A, id) -- UiPromptClearHorizontalOrientation
end

return PromptsAPI
