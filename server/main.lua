
local function getUtils ()
    local UtilAPI = {}

    UtilAPI.Versioner = VersionerAPI
    UtilAPI.Database = DatabaseAPI
    UtilAPI.file = FilesAPI
    UtilAPI = SetupSharedAPI(UtilAPI)

    UtilAPI.instance = InstanceAPI
    return UtilAPI
end

AddEventHandler('bcc:getUtils', function(cb)
    cb(getUtils())
end)

exports('initiate',function()
    return getUtils()
end)

VersionerAPI.checkFile(GetCurrentResourceName(), 'https://github.com/BryceCanyonCounty/bcc-utils')


-- New Server Exports
exports('versioner', function()
    return VersionerAPI
end)

exports('database', function()
    return DatabaseAPI
end)

exports('file', function()
    return FilesAPI
end)

exports('instance', function()
    return InstanceAPI
end)