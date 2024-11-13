function SetupSharedAPI(SharedApi)
    SharedApi.Print = PrettyPrint
    SharedApi.DataView = DataView
    SharedApi.Events = EventsAPI
    SharedApi.Keys = Keys
    SharedApi.Math = MathAPI
    SharedApi.Discord = DiscordAPI
    SharedApi.General = GeneralAPI
    SharedApi.RPC = RPC
	
    return SharedApi
end