local function getUtils ()
    local UtilAPI = {}

    UtilAPI.YtAudioPlayer = YtAudioPlayer
    UtilAPI.Misc = MiscAPI
    UtilAPI.Blip = BlipAPI
    UtilAPI.Blips = BlipAPI
    UtilAPI.Horse = HorseAPI
    UtilAPI.Map = MapAPI
    UtilAPI.Object = ObjectAPI
    UtilAPI.Objects = ObjectAPI
    UtilAPI.Ped = PedAPI
    UtilAPI.Prompt = PromptsAPI
    UtilAPI.Prompts = PromptsAPI
    UtilAPI.Render = RenderAPI
    UtilAPI.Keys = KeyPressAPI
    UtilAPI.Clip = ClipAPI
    UtilAPI.UI = UIAPI
    UtilAPI.Destruct = DestructionAPI
    UtilAPI.Button = ButtonAPI
	
    UtilAPI = SetupSharedAPI(UtilAPI)

    return UtilAPI
end

AddEventHandler('bcc:getUtils', function(cb)
    cb(getUtils())
end)

-- TODO: Create a system wher you can give it an array of exports and it will return them, if non, return all
exports('initiate',function()
    return getUtils()
end)