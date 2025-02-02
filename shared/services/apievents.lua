local netEventIDs = {}

local function compressIt(data)
    return LibDeflate:CompressDeflate(json.encode(data))
end

local function decompressIt(data)
    return json.decode(LibDeflate:DecompressDeflate(data) or '')
end

local function storeEventID(eventName)
    local attempts = 0
    local max = 20
    local id = UUID4()

    while netEventIDs[eventName] == id and attempts < max do
        id = UUID4()
        attempts = attempts + 1
    end
    
    netEventIDs[eventName] = id

    return id
end

local function getEventID(eventName)
    return netEventIDs[eventName]
end

NetEventsAPI = {}

function NetEventsAPI:TriggerNetEvent(eventName, targetSource, ...)
    local obfID = getEventID(eventName)

    local args = {...}
    for i, arg in ipairs(args) do
        args[i] = compressIt(arg)
    end

    if IsDuplicityVersion() then
        TriggerClientEvent(obfID, targetSource or -1, table.unpack(args))
    else
        TriggerServerEvent(obfID, table.unpack(args))
    end
end

function NetEventsAPI:RegisterNetEvent(eventName, callback)
    local obfID = storeEventID(eventName)

    if IsDuplicityVersion() then
        RegisterServerEvent(obfID)
        AddEventHandler(obfID, function(...)
            local args = {...}
            for i, arg in ipairs(args) do
                args[i] = decompressIt(arg)
            end
            callback(table.unpack(args))
        end)
    else
        RegisterNetEvent(obfID)
        AddEventHandler(obfID, function(...)
            local args = {...}
            for i, arg in ipairs(args) do
                args[i] = decompressIt(arg)
            end
            callback(table.unpack(args))
        end)
    end
end