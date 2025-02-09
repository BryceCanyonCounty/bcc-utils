local netEventIDs = {}

local function compressIt(data)
    return LibDeflate:CompressDeflate(json.encode(data))
end

local function decompressIt(data)
    return json.decode(LibDeflate:DecompressDeflate(data) or '')
end

NetEventsAPI = {}

function NetEventsAPI:TriggerNetEvent(eventName, targetSource, ...)
    local args = {...}
    for i, arg in ipairs(args) do
        args[i] = compressIt(arg)
    end

    if IsDuplicityVersion() then
        TriggerClientEvent(eventName, targetSource or -1, table.unpack(args))
    else
        TriggerServerEvent(eventName, table.unpack(args))
    end
end

function NetEventsAPI:RegisterNetEvent(eventName, callback)
    if IsDuplicityVersion() then
        RegisterServerEvent(eventName)
        AddEventHandler(eventName, function(...)
            local args = {...}
            for i, arg in ipairs(args) do
                args[i] = decompressIt(arg)
            end
            callback(table.unpack(args))
        end)
    else
        RegisterNetEvent(eventName)
        AddEventHandler(eventName, function(...)
            local args = {...}
            for i, arg in ipairs(args) do
                args[i] = decompressIt(arg)
            end
            callback(table.unpack(args))
        end)
    end
end