ButtonAPI = {}

---Creates a button handler class.
---@param control integer EXAMPLE VALUE: 0
---@param button string | integer Hash or string to be hashed EXAMPLE VALUE: `INPUT_JUMP`
---@param checkDisabled boolean Check even if the button is disabled
---@param doublePressThreshold integer Treshhold for double and more press detection EXAMPLE VALUE: 300
---@param holdPressThreshold integer Treshhold for long press detection EXAMPLE VALUE: 1000
---@param Callbacks { OnRepeatedJustPressed?: function, OnRepeatedJustReleased?: function, OnHold?: function, OnLongPressDetection?: function, OnTotalRepeatedPress?: function }
---@param autoUpdate? boolean automaticaly star update cycle
---@param alternative? boolean whitch mode use for auto update
---@return ButtonClass
function ButtonAPI:Create(control, button, checkDisabled, doublePressThreshold, holdPressThreshold, Callbacks, autoUpdate, alternative)
    ---@class ButtonClass
    local ButtonClass = {}

    local devMode = false -- only for devs

    local function Debug(...)
        if devMode then print(...) end
    end

    ButtonClass.control = control
    ButtonClass.button = button
    ButtonClass.checkDisabled = checkDisabled
    ButtonClass.repeatedPressThreshold = doublePressThreshold
    ButtonClass.holdPressThreshold = holdPressThreshold
    ButtonClass.CallbackOnRepeatedJustPressed =  Callbacks.OnRepeatedJustPressed or function(timesPressed) Debug(string.format("Repeated press number %d", timesPressed)) end
    ButtonClass.CallbackOnRepeatedJustReleased = Callbacks.OnRepeatedJustReleased or function(timesPressed) Debug(string.format("Repeated released number %d", timesPressed)) end
    ButtonClass.CallbackOnHold =                 Callbacks.OnHold or function(timesPressed) --[[Debug(string.format("Hold button"))]] end -- Commented due to spam in the debug console
    ButtonClass.CallbackOnLongPressDetection =   Callbacks.OnLongPressDetection or function(timesPressed) Debug(string.format("Long press after %d press count", timesPressed)) end
    ButtonClass.CallbackOnTotalRepeatedPress =   Callbacks.OnTotalRepeatedPress or function(timesPressed) Debug(string.format("Total number pressed %d", timesPressed)) end
    local lastPressTime = 0
    local lastReleaseTime = 0 -- Alternative
    local pressCount = 0

    ---This method needs to be called every tick to track button presses.
    ---@param alternative? boolean Enables alternative processing algorithm (optional)
    function ButtonClass:Update(alternative)
        local current = GetGameTimer()

        local IsJustPressed =  self.checkDisabled and IsDisabledControlJustPressed  or IsControlJustPressed
        local IsPressed =      self.checkDisabled and IsDisabledControlPressed      or IsControlPressed
        local IsJustReleased = self.checkDisabled and IsDisabledControlJustReleased or IsControlJustReleased

        if IsJustPressed(self.control, self.button) then
            if ((current - lastPressTime) < self.repeatedPressThreshold) then
                pressCount = pressCount + 1 -- Repeated pressing
            else
                pressCount = 1 -- Start from the first
            end
            self.CallbackOnRepeatedJustPressed(pressCount) -- Do something
            lastPressTime = current
        elseif IsPressed(self.control, self.button) then
            if ((current - lastPressTime) > self.holdPressThreshold) then
                self.CallbackOnLongPressDetection(pressCount) -- Do something
                pressCount = 0 -- needed for omit CallbackOnTotalRepeatedPress (fire only ONE callback among these: CallbackOnLongPressDetection, CallbackOnTotalRepeatedPress)
            end
            self.CallbackOnHold(pressCount) -- Do something
        elseif IsJustReleased(self.control, self.button) then
            if alternative then -- Alternative
                if ((current - lastReleaseTime) < self.repeatedPressThreshold) then
                    self.CallbackOnRepeatedJustReleased(pressCount) -- Do something
                end
                lastReleaseTime = current
            else -- Regular
                if ((current - lastPressTime) < (self.repeatedPressThreshold // 2)) then
                    self.CallbackOnRepeatedJustReleased(pressCount) -- Do something
                end
            end
        else
            if ((current - lastPressTime) > self.repeatedPressThreshold) then
                if pressCount > 0 then
                    self.CallbackOnTotalRepeatedPress(pressCount) -- Do something
                end
                pressCount = 0 -- reset clicking counter
            end
        end
    end

    ---Sets the mode to check only enabled or enabled and disabled buttons
    ---@param checkDisabled boolean true - check even if the button is disabled, false - only check if button is enabled
    function ButtonClass:SetCheckDisabled(checkDisabled)
        self.checkDisabled = checkDisabled
    end

    ---Returns the mode of checking only enabled or enabled and disabled buttons
    ---@return boolean # Returns whether the mode is set to check for disabled buttons
    function ButtonClass:GetCheckDisabled()
        return self.checkDisabled
    end

    ---Stop auto update process
    ---@return boolean result returns true if stopped false otherwise
    function ButtonClass:StopAutoUpdate()
        if autoUpdate then
            autoUpdate = false
            return true
        else
            return false
        end
    end

    ---Needs for start auto update thread
    function ButtonClass:StartAutoUpdate()
        if not autoUpdate then
            autoUpdate = true
            CreateThread(function()
                while autoUpdate do
                    Wait(0)
                    ButtonClass:Update(alternative)
                end
            end)
        end
    end

    if autoUpdate then
        autoUpdate = false
        ButtonClass:StartAutoUpdate()
    end

    return ButtonClass
end


--[[ CODE EXAMPLE:

local longPressThreshold = 1000
local repeatPressThreshold = 300
local button = `INPUT_DUCK` -- same as 0xDB096B85
local CtrlButton = ButtonAPI:Create(0, button, true, repeatPressThreshold, longPressThreshold, {
    OnRepeatedJustPressed = function(count) end,
    OnRepeatedJustReleased = function(count) end,
    OnHold = function() end, -- calls every tick when button is pressed
    OnLongPressDetection = function(count)
        if count == 1 then
            -- Do stuff after holding the button down long enough
        elseif count == 2 then
            -- Do stuff after double-clicking the button and then holding it down
        elseif count == 3 then
            -- Do stuff after triple-clicking the button and then holding it down
        end
    end,
    OnTotalRepeatedPress = function(count)
        if count == 2 then
            -- Do stuff after double-clicking the button and release (all timeouts passed)
        end
    end
})

CreateThread(function()
    while true do
        Wait(0)
        CtrlButton:Update()
    end
end)

]]

