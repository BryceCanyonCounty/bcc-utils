-- credits: https://github.com/egerdnc/redm-rpc and feather-core

RPC = {}

local pendingCallbacks = {}  -- Track all queued callbacks
local pendingCallbackCount = 0  -- Track the number of queued callbacks
local registeredProcedures = {}  -- Remote methods table

-- Register events based on environment
if IsDuplicityVersion() then
    RegisterServerEvent("BCC:Call")
    RegisterServerEvent("BCC:Response")
else
    RegisterNetEvent("BCC:Call")
    RegisterNetEvent("BCC:Response")
end

----------------------
-- Helper functions --
----------------------

-- Helper function to trigger events with JSON-friendly arguments
local function TriggerRemoteEvent(eventName, targetSource, ...)
    local args = {...}
    
    -- Convert tables to JSON for better readability in debugging
    for i, arg in ipairs(args) do
        if type(arg) == "table" then
            args[i] = json.encode(arg)
        else
            args[i] = tostring(arg)
        end
    end

    if IsDuplicityVersion() then
        TriggerClientEvent(eventName, targetSource or -1, ...)
    else
        TriggerServerEvent(eventName, ...)
    end
end

---------------------
--  Main functions --
---------------------

-- Core function to handle remote procedure calls
local function CallRemoteProcedure(name, params, callback, source)
    local id = nil
    if callback then
        id = pendingCallbackCount + 1
        pendingCallbackCount = id
        pendingCallbacks[id] = callback
    end

    TriggerRemoteEvent("BCC:Call", source, id, name, params)
end

--------------------
-- Event handling --
--------------------

-- Handles incoming procedure calls
AddEventHandler("BCC:Call", function(id, name, params)
    if type(name) ~= "string" then
        return
    end
    if not registeredProcedures[name] then
        return
    end

    local activeProcedure = registeredProcedures[name]

    -- Create response function for this specific call
    local function GetResponseFunction()
        local clientSource = source  -- Capture the source as clientSource
        if not id then return function() end end
        return function(...)
            TriggerRemoteEvent("BCC:Response", clientSource, id, ...)
        end
    end

    -- Execute the procedure
    local returnValues = { activeProcedure(params, GetResponseFunction(), source) }
    if #returnValues > 0 and id then
        TriggerRemoteEvent("BCC:Response", source, id, table.unpack(returnValues))
    end
end)

-- Handles incoming procedure responses
AddEventHandler("BCC:Response", function(id, ...)
    local args = {...}

    -- Convert arguments to JSON if they're tables
    for i, arg in ipairs(args) do
        if type(arg) == "table" then
            args[i] = json.encode(arg)
        else
            args[i] = tostring(arg)
        end
    end

    if not pendingCallbacks[id] then
        return
    end

    pendingCallbacks[id](...)
    pendingCallbacks[id] = nil
end)

--------------------
--    RPC API     --
--------------------

-- Register a procedure/method to be called remotely
function RPC:Register(name, callback)
    registeredProcedures[name] = callback
end

-- Notify without callback
function RPC:Notify(name, params, source)
    params = params or {}
    CallRemoteProcedure(name, params, nil, source)
end

-- Call a procedure with a callback
function RPC:Call(name, params, callback, source)
    params = params or {}
    CallRemoteProcedure(name, params, callback, source)
end

-- Call a procedure with asynchronous handling
function RPC:CallAsync(name, params, source)
    params = params or {}

    -- Create a new promise for async handling
    local p = promise.new()

    CallRemoteProcedure(name, params, function(...)
        p:resolve({ ... })
    end, source)

    -- Await the promise resolution
    return table.unpack(Citizen.Await(p))
end