-- EXPIRIMENTAL Secure/Compressed RPC API, this is not ready for production use yet.

-- credits: https://github.com/egerdnc/redm-rpc and feather-core

sRPC = {}

local pendingCallbacks = {}     -- Track all queued callbacks
local pendingCallbackCount = 0  -- Track the number of queued callbacks
local registeredProcedures = {} -- Remote methods table

-- Register events based on environment
if IsDuplicityVersion() then
    RegisterServerEvent("BCC:sCall")
    RegisterServerEvent("BCC:sResponse")
else
    RegisterNetEvent("BCC:sCall")
    RegisterNetEvent("BCC:sResponse")
end

----------------------
-- Helper functions --
----------------------

local function compressIt(data)
    if data == nil then
        return nil
    end

    return LibDeflate:CompressDeflate(json.encode(data or ''))
end

local function decompressIt(data)
    if data == nil then
        return nil
    end

    return json.decode(LibDeflate:DecompressDeflate(data) or '')
end

local function prepare(o, action)
    if type(o) == 'table' then
        for k, v in pairs(o) do
            if type(o) == 'table' then
                o[k] = prepare(v, action)
            else
                o[k] = action(v)
            end
        end
        return o
    else
        return action(o)
    end
end

-- Helper function to trigger events with JSON-friendly arguments
local function TriggerRemoteEvent(eventName, targetSource, ...)
    local args = prepare({ ... }, compressIt)

    if IsDuplicityVersion() then
        TriggerClientEvent(eventName, targetSource or -1, table.unpack(args))
    else
        TriggerServerEvent(eventName, table.unpack(args))
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
    PrettyPrint('Calling it')
    TriggerRemoteEvent("BCC:sCall", source, id, name, params)
end

--------------------
-- Event handling --
--------------------

-- Handles incoming procedure calls
AddEventHandler("BCC:sCall", function(id, name, params)
    id = prepare(id, decompressIt)
    name = prepare(name, decompressIt)
    params = prepare(params, decompressIt)

    print("id, name, params")
    print(id, name, params)

    if type(name) ~= "string" then
        return
    end
    if not registeredProcedures[name] then
        return
    end

    local activeProcedure = registeredProcedures[name]

    -- Create response function for this specific call
    local function GetResponseFunction()
        local clientSource = source -- Capture the source as clientSource
        if not id then return function() end end
        return function(...)
            TriggerRemoteEvent("BCC:sResponse", clientSource, id, ...)
        end
    end

    -- Execute the procedure
    local returnValues = { activeProcedure(params, GetResponseFunction(), source) }
    if returnValues ~= nil and #returnValues > 0 and id ~= nil then
        TriggerRemoteEvent("BCC:sResponse", source, id, table.unpack(returnValues))
    end
end)

-- Handles incoming procedure responses
AddEventHandler("BCC:sResponse", function(id, ...)
    id = prepare(id, decompressIt)
    local args = prepare({ ... }, decompressIt)

    if not pendingCallbacks[id] then
        return
    end

    if (id ~= nil) then
        pendingCallbacks[id](table.unpack(args))
        pendingCallbacks[id] = nil
    end
end)

--------------------
--    RPC API     --
--------------------

-- Register a procedure/method to be called remotely
function sRPC:Register(name, callback)
    registeredProcedures[name] = callback
end

-- Notify without callback
function sRPC:Notify(name, params, source)
    params = params or {}
    CallRemoteProcedure(name, params, nil, source)
end

-- Call a procedure with a callback
function sRPC:Call(name, params, callback, source)
    params = params or {}
    CallRemoteProcedure(name, params, callback, source)
end

-- Call a procedure with asynchronous handling
function sRPC:CallAsync(name, params, source)
    params = params or {}

    -- Create a new promise for async handling
    local p = promise.new()
    CallRemoteProcedure(name, params, function(...)
        p:resolve({ ... })
    end, source)

    -- Await the promise resolution
    return table.unpack(Citizen.Await(p))
end
