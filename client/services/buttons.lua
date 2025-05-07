ButtonAPI = {}

-- virtual key codes: https://learn.microsoft.com/en-us/windows/win32/inputdev/virtual-key-codes
local MinVirtualKeyCode <const> = 0x00
local MaxVirtualKeyCode <const> = 0xFF

---Check if button just pressed
---@param control integer (doesn't matter for virtual key code) EXAMPLE VALUE: 0
---@param button string | integer Hash or virtual key code or string to be hashed EXAMPLE VALUE: `INPUT_JUMP` or 0x70 for [F1] button
---@param checkDisabled boolean Check even if the button is disabled (doesn't matter for virtual key code)
---@return boolean
function ButtonAPI:IsKeyPressed(control, button, checkDisabled)
    if type(button) == "number" and MinVirtualKeyCode < button and button < MaxVirtualKeyCode then
        ---@diagnostic disable-next-line: undefined-global
        return IsRawKeyPressed(button)
    elseif checkDisabled then
        return IsDisabledControlJustPressed(control, button)
    else
        return IsControlJustPressed(control, button)
    end
end

---Check if button pressed right now
---@param control integer (doesn't matter for virtual key code) EXAMPLE VALUE: 0
---@param button string | integer Hash or virtual key code or string to be hashed EXAMPLE VALUE: `INPUT_JUMP` or 0x70 for [F1] button
---@param checkDisabled boolean Check even if the button is disabled (doesn't matter for virtual key code)
---@return boolean
function ButtonAPI:IsKeyDown(control, button, checkDisabled)
    if type(button) == "number" and MinVirtualKeyCode < button and button < MaxVirtualKeyCode then
        ---@diagnostic disable-next-line: undefined-global
        return IsRawKeyDown(button) -- IsRawKeyUp
    elseif checkDisabled then
        return IsDisabledControlPressed(control, button)
    else
        return IsControlPressed(control, button)
    end
end

---Check if button just released
---@param control integer (doesn't matter for virtual key code) EXAMPLE VALUE: 0
---@param button string | integer Hash or virtual key code or string to be hashed EXAMPLE VALUE: `INPUT_JUMP` or 0x70 for [F1] button
---@param checkDisabled boolean Check even if the button is disabled (doesn't matter for virtual key code)
---@return boolean
function ButtonAPI:IsKeyReleased(control, button, checkDisabled)
    if type(button) == "number" and MinVirtualKeyCode < button and button < MaxVirtualKeyCode then
        ---@diagnostic disable-next-line: undefined-global
        return IsRawKeyReleased(button)
    elseif checkDisabled then
        return IsDisabledControlJustReleased(control, button)
    else
        return IsControlJustReleased(control, button)
    end
end

---Creates a button handler class.
---@param control integer EXAMPLE VALUE: 0
---@param button string | integer Hash or virtual key code or string to be hashed EXAMPLE VALUE: `INPUT_JUMP` or 0x70 for [F1] button
---@param checkDisabled boolean Check even if the button is disabled
---@param doublePressThreshold integer Treshhold for double and more press detection EXAMPLE VALUE: 300
---@param holdPressThreshold integer Treshhold for long press detection EXAMPLE VALUE: 1000
---@param Callbacks { OnRepeatedJustPressed?: function, OnRepeatedJustReleased?: function, OnHold?: function, OnLongPressDetection?: function, OnTotalRepeatedShortPresses?: function, CallbackOnTotalRepeatedPress?: function } # LEGACY support CallbackOnTotalRepeatedPress
---@param autoUpdate? boolean automaticaly star update cycle
---@param gamepadInput? boolean if true, handles only gamepad input; if false or omitted, handles all inputs by default including keyboard and mouse.
---@return ButtonClass
function ButtonAPI:Create(control, button, checkDisabled, doublePressThreshold, holdPressThreshold, Callbacks, autoUpdate, gamepadInput)
    ---@class ButtonClass
    local ButtonClass = {}

    local devMode = false -- only for devs

    local function Debug(...)
        if devMode then print(...) end
    end

    ButtonClass.gamepadInput = gamepadInput or false
    ButtonClass.control = control
    ButtonClass.button = button
    ButtonClass.checkDisabled = checkDisabled
    ButtonClass.repeatedPressThreshold = doublePressThreshold
    ButtonClass.holdPressThreshold = holdPressThreshold
    ButtonClass.CallbackOnRepeatedJustPressed =       Callbacks.OnRepeatedJustPressed or function(timesPressed) Debug(string.format("Repeated press number %d", timesPressed)) end
    ButtonClass.CallbackOnRepeatedJustReleased =      Callbacks.OnRepeatedJustReleased or function(timesPressed) Debug(string.format("Repeated released number %d", timesPressed)) end
    ButtonClass.CallbackOnHold =                      Callbacks.OnHold or function(timesPressed) --[[Debug(string.format("Hold button"))]] end -- Commented due to spam in the debug console
    ButtonClass.CallbackOnLongPressDetection =        Callbacks.OnLongPressDetection or function(timesPressed) Debug(string.format("Long press after %d press count", timesPressed)) end
    ButtonClass.CallbackOnTotalRepeatedShortPresses = Callbacks.OnTotalRepeatedShortPresses or Callbacks.CallbackOnTotalRepeatedPress or function(timesPressed) Debug(string.format("Total number of short presses %d", timesPressed)) end
    local lastPressTime = 0
    local pressCount = 0

    ---This method needs to be called every tick to track button presses.
    function ButtonClass:Update()
        if self.gamepadInput ~= not IsUsingKeyboardAndMouse(self.control) then
            lastPressTime = 0 -- reset clicking timer
            pressCount = 0 -- reset clicking counter
            return -- Skip handling if the expected input method (gamepad or keyboard/mouse) doesn't match the current one
        end
        local current = GetGameTimer()

        if ButtonAPI:IsKeyPressed(self.control, self.button, self.checkDisabled) then
            if ((current - lastPressTime) < self.repeatedPressThreshold) then
                pressCount = pressCount + 1 -- Repeated pressing
            else
                pressCount = 1 -- Start from the first
            end
            self.CallbackOnRepeatedJustPressed(pressCount) -- Do something
            lastPressTime = current
        elseif ButtonAPI:IsKeyReleased(self.control, self.button, self.checkDisabled) then
            self.CallbackOnRepeatedJustReleased(pressCount) -- Do something
        elseif pressCount ~= 0 then
            if ButtonAPI:IsKeyDown(self.control, self.button, self.checkDisabled) then
                if ((current - lastPressTime) > self.holdPressThreshold) then
                    self.CallbackOnLongPressDetection(pressCount) -- Do something
                    pressCount = 0 -- needed for omit CallbackOnTotalRepeatedPress (fire only ONE callback among these: CallbackOnLongPressDetection, CallbackOnTotalRepeatedPress)
                end
                self.CallbackOnHold(pressCount) -- Do something
            else -- IsKeyUp
                if ((current - lastPressTime) > self.repeatedPressThreshold) then
                    if pressCount > 0 then
                        self.CallbackOnTotalRepeatedShortPresses(pressCount) -- Do something
                    end
                    pressCount = 0 -- reset clicking counter
                end
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
                    ButtonClass:Update()
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

BccUtils = exports["bcc-utils"].initiate()
ButtonAPI = BccUtils.Button

-- Look for more button hashes here: https://redlookup.com/controls/?p=1&s=&pp=200&at
-- Or use virtual key insted from here: https://learn.microsoft.com/en-us/windows/win32/inputdev/virtual-key-codes
local button = `INPUT_GAME_MENU_TAB_LEFT_SECONDARY` -- [Z]
local repeatPressThreshold = 300 -- usualy between 200 and 500 ms
local longPressThreshold = 300 -- must be greater than repeatPressThreshold, usualy between 300 and 1000 ms
local autoUpdate = true -- enables automatic updates each frame; set to false to require manual button:Update() calls.
local gamepadInput = false -- true - handles only gamepad input, false - all inputs

local AnimationButton = ButtonAPI:Create(0, button, true, repeatPressThreshold, longPressThreshold, {
    OnRepeatedJustPressed = function(count)
        if count == 1 then -- Execute actions when the button is pressed for the first time
        elseif count == 2 then -- Execute actions when the button is pressed for the second time within the allowed time frame
        elseif count == 3 then -- Execute actions when the button is pressed for the third time within the allowed time frame
        end
    end,
    OnRepeatedJustReleased = function(count)
        if count == 0 then -- Execute actions when the button is released after a long press
            --[=[ Hide animation window
            ExecuteCommand("stopAnim")
            --]=]
        elseif count == 1 then -- Execute actions when the button is released after a single short press
        elseif count == 2 then -- Execute actions when the button is released after a double short press
        elseif count == 3 then -- Execute actions when the button is released after a triple short press
        end
    end,
    OnHold = function(count) -- Called every tick while the button is held down
        if count == 0 then -- -- Triggered after a allowed timeout between clicks ends, indicating that the press sequence has been reset
        elseif count == 1 then -- Triggered after the button is pressed for the first time within the allowed time frame
        elseif count == 2 then -- Triggered after the button is pressed for the second time within the allowed time frame
        elseif count == 3 then -- Triggered after the button is pressed for the third time within the allowed time frame
        end
    end,
    OnLongPressDetection = function(count)
        if count == 1 then -- Execute actions after holding the button down for a long press
            --[=[ Start animation window
            ExecuteCommand("startAnim")
            --]=]
        elseif count == 2 then -- Execute actions after double-clicking the button and then holding it down
        elseif count == 3 then -- Execute actions after triple-clicking the button and then holding it down
        end
    end,
    OnTotalRepeatedShortPresses  = function(count) -- Excludes cases where the last press was a long press
        if count == 1 then -- Execute actions after a single-click of the button, released quickly, and after the short press timeout has passed
        elseif count == 2 then -- Execute actions after a double-click of the button, released quickly, and after the short press timeout has passed
            --[=[ Force to stop all tasks including animation task and disarm the player
            local ped = PlayerPedId()
            if not IsPlayerFreeAiming(ped) then
                ClearPedTasks(ped)
                ClearPedSecondaryTask(ped)
                SetCurrentPedWeapon(ped, GetHashKey("WEAPON_UNARMED"), false, 0, false, false)
                SetCurrentPedWeapon(ped, GetHashKey("WEAPON_UNARMED"), false, 1, false, false)
            end
            --]=]
        elseif count == 3 then -- Execute actions after a tripple-click of the button, released quickly, and after the short press timeout has passed
        end
    end
}, autoUpdate, gamepadInput)

----------------------------------------------------------
-- In case you want to mannualy control the update process
----------------------------------------------------------
AnimationButton:StopAutoUpdate() -- Stop auto update process
CreateThread(function()
    while true do
        Wait(0)
        AnimationButton:Update()
    end
end)
----------------------------------------------------------

--]]

