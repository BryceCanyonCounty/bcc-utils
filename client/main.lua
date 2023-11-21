local function getUtils ()
    local UtilAPI = {}

    UtilAPI.YtAudioPlayer = YtAudioPlayer
    UtilAPI.Misc = MiscAPI
    UtilAPI.Blip = BlipAPI
    UtilAPI.Horse = HorseAPI
    UtilAPI.Map = MapAPI
    UtilAPI.Notify = NotifyAPI
    UtilAPI.Object = ObjectAPI
    UtilAPI.Ped = PedAPI
    UtilAPI.Prompt = PromptsAPI
    UtilAPI.Render = RenderAPI
    UtilAPI.Wagon = WagonsAPI
    UtilAPI.Keys = KeyPressAPI
    UtilAPI.Clip = ClipAPI
    
    UtilAPI = SetupSharedAPI(UtilAPI)

    return UtilAPI
end

AddEventHandler('bcc:getUtils', function(cb)
    cb(getUtils())
end)

exports('initiate',function()
    return getUtils()
end)