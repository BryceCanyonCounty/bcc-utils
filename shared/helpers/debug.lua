DebugAPI = {}
DebugAPI.__index = DebugAPI

local function makePrinter(prefix, color, level)
    return function(self, ...)
        if not self or not self.DevModeActive then
            return
        end

        local n = select("#", ...)
        local message

        if n == 0 then
            message = ""
        elseif n == 1 then
            message = tostring((...))
        else
            local parts = {}
            for i = 1, n do
                parts[i] = tostring(select(i, ...))
            end
            message = table.concat(parts, " ")
        end

        local out = "^" .. tostring(color)
            .. "[" .. tostring(level) .. "] "
            .. "^3" .. message .. "^0"
            .. "^6 [" .. tostring(prefix) .. "]^0"
        print(out)
    end
end

local function resolveDevMode(devModeOverride)
    if devModeOverride ~= nil then return devModeOverride end
    return Config and (Config.DevMode or (Config.devMode and Config.devMode.active)) or false
end

function DebugAPI:Create(prefix, devModeOverride)
    local inst = {
        prefix = prefix or "DEBUG",
        DevModeActive = resolveDevMode(devModeOverride),
    }

    inst.Enable  = function(self) self.DevModeActive = true end
    inst.Disable = function(self) self.DevModeActive = false end

    inst.Info    = makePrinter(inst.prefix, 5, "INFO")
    inst.Error   = makePrinter(inst.prefix, 1, "ERROR")
    inst.Warning = makePrinter(inst.prefix, 3, "WARNING")
    inst.Success = makePrinter(inst.prefix, 2, "SUCCESS")

    return inst
end

function DebugAPI:Get(prefix, devModeOverride)
    return self:Create(prefix, devModeOverride)
end

function DebugAPI:Ensure(dbg, devModeOverride)
    if type(dbg) ~= "table" then return dbg end

    dbg.prefix = dbg.prefix or "DEBUG"
    if dbg.DevModeActive == nil then
        dbg.DevModeActive = resolveDevMode(devModeOverride)
    end

    dbg.Enable  = dbg.Enable  or function(self) self.DevModeActive = true end
    dbg.Disable = dbg.Disable or function(self) self.DevModeActive = false end

    dbg.Info    = dbg.Info    or makePrinter(dbg.prefix, 5, "INFO")
    dbg.Error   = dbg.Error   or makePrinter(dbg.prefix, 1, "ERROR")
    dbg.Warning = dbg.Warning or makePrinter(dbg.prefix, 3, "WARNING")
    dbg.Success = dbg.Success or makePrinter(dbg.prefix, 2, "SUCCESS")

    return dbg
end
