function SetupSharedAPI(SharedApi)
    SharedApi.Print = PrettyPrint
    SharedApi.DataView = DataView
    SharedApi.Events = EventsAPI
    SharedApi.Keys = Keys
    SharedApi.Math = MathAPI
    SharedApi.Discord = DiscordAPI
    SharedApi.General = GeneralAPI
    SharedApi.RPC = RPC
    -- SharedApi.RPC = sRPC -- This is expiremental, don't use it yet
    SharedApi.Command = CommandAPI
    SharedApi.Helpers = HelpersAPI
    SharedApi.Compression = LibDeflate
    SharedApi.NetEvents = NetEventsAPI
    SharedApi.Crypt = CryptAPI
    SharedApi.UUID = UUID4

    return SharedApi
end