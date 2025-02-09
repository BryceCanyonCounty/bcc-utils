-- https://en.wikipedia.org/wiki/Universally_unique_identifier
-- Thanks to Black Pegasus#0001

function UUID4()
    math.randomseed(tonumber(tostring(os.time()):reverse():sub(1, 9))) -- determines where to start the sequence of random numbers given by math.random (this is set for this whole context)
    local random = math.random
    local baseUUID ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(baseUUID, '[xy]', function (c)
        local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
        return string.format('%x', v)
    end)
end