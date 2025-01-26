CommandAPI = {}

function CommandAPI.Register(command, suggestion, callback, params)
    RegisterCommand(command, callback)
    TriggerEvent("chat:addSuggestion", "/" .. command, suggestion, params)
end