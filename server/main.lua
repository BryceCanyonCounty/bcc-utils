
local function getUtils ()
    local UtilAPI = {}

    UtilAPI.Versioner = VersionerAPI
    UtilAPI.Discord = DiscordAPI

    return UtilAPI
end


AddEventHandler('bcc:getUtils', function(cb)
    cb(getUtils())
end)

exports('initiate',function()
    return getUtils()
end)


VersionerAPI.checkRelease(GetCurrentResourceName(), 'https://github.com/BryceCanyonCounty/bcc-utils')

