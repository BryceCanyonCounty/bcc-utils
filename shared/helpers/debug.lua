DebugAPI = {}
DebugAPI.__index = DebugAPI

local function joinArgs(...)
    local n = select("#", ...)
    if n == 0 then return "" end
    if n == 1 then return tostring((...)) end
    local parts = {}
    for i = 1, n do parts[#parts+1] = tostring(select(i, ...)) end
    return table.concat(parts, " ")
end

local function makePrinter(prefix, color, level)
    return function(self, ...)
        if not self.DevModeActive then return end
        print(("^%d[%s] ^3%s^0"):format(color, level, joinArgs(...)))
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
    inst.Info    = makePrinter(inst.prefix, 5, inst.prefix .. " INFO")
    inst.Error   = makePrinter(inst.prefix, 1, inst.prefix .. " ERROR")
    inst.Warning = makePrinter(inst.prefix, 3, inst.prefix .. " WARNING")
    inst.Success = makePrinter(inst.prefix, 2, inst.prefix .. " SUCCESS")

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
    dbg.Info    = dbg.Info    or makePrinter(dbg.prefix, 5, dbg.prefix .. " INFO")
    dbg.Error   = dbg.Error   or makePrinter(dbg.prefix, 1, dbg.prefix .. " ERROR")
    dbg.Warning = dbg.Warning or makePrinter(dbg.prefix, 3, dbg.prefix .. " WARNING")
    dbg.Success = dbg.Success or makePrinter(dbg.prefix, 2, dbg.prefix .. " SUCCESS")
    return dbg
end
