DebugAPI = {}
DebugAPI.__index = DebugAPI

-- enable/disable per instance
function DebugAPI:Enable()
    self.enabled = true
end

function DebugAPI:Disable()
    self.enabled = false
end

-- internal helper: create printer methods
local function makePrinter(level, color)
    return function(self, message)
        if not self.enabled then return end
        print(("^%d[%s:%s]^7 %s"):format(color, self.prefix, level, message))
    end
end

DebugAPI.Info    = makePrinter("INFO",    5)
DebugAPI.Error   = makePrinter("ERROR",   1)
DebugAPI.Warning = makePrinter("WARN",    3)
DebugAPI.Success = makePrinter("SUCCESS", 2)

-- MAIN creation factory
function DebugAPI:Create(prefix)
    local inst = {
        prefix = prefix or "DEBUG",
        enabled = false
    }

    -- bind methods so DOT syntax works
    local function bind(fn)
        return function(_, ...)
            return fn(inst, ...)
        end
    end

    return {
        Enable  = bind(self.Enable),
        Disable = bind(self.Disable),

        Info    = bind(self.Info),
        Error   = bind(self.Error),
        Warning = bind(self.Warning),
        Success = bind(self.Success),
    }
end

return DebugAPI
