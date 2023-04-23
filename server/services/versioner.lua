VersionerAPI = {}
HasChecked = {}

local function _interalCall(resourcename, repo)
    local current = {
        version = GetResourceMetadata(resourcename, 'version')
    }

    PerformHttpRequest('https://api.github.com/repos/' .. repo .. '/releases/latest', function(err, text, headers)
        if err ~= 200 then
            print('^1ERROR: Please try again later. Code (', err, ')', '[', repo, ']')
            return
        end


        local response = json.decode(text)
        local latest = {
            url = response.html_url,
            body = response.body,
            version = response.tag_name
        }
        local uptodate = false
        local overdate = false

        if current.version > latest.version then
            overdate = true
        elseif current.version < latest.version then
            uptodate = false
        else
            uptodate = true
        end

        if uptodate then
            print('^2✅Up to Date! ^5[' .. resourcename .. '] ^6(Current Version ' .. current.version .. ')^0')
        elseif overdate then
            print('^3⚠️Unsupported! ^5[' .. resourcename .. '] ^6(Version ' .. current.version .. ')^0')
            print('^4Current Version ^2(' .. latest.version .. ') ^3<' .. latest.url .. '>^0')
        else
            print('^1❌Outdated! ^5[' .. resourcename .. '] ^6(Version ' .. current.version .. ')^0')
            print('^4NEW VERSION ^2(' .. latest.version .. ') ^3<' .. latest.url .. '>^0')
            print('^4CHANGELOG ^0\r\n' .. latest.body)
        end

        HasChecked[repo] = {
            active = true,
            timestamp = os.time()
        }
    end, 'GET', json.encode(payload), {
        ['Content-Type'] = 'application/json'
    })
end

function VersionerAPI.checkRelease(resourcename, repo)
    repo = repo:gsub("https://github.com/", "")

    if HasChecked[repo] == nil then
            _interalCall(resourcename, repo)
            HasChecked[repo] = {
                active = true,
                timestamp = os.time()
            }
    else
        local daysfrom = os.difftime(os.time(), HasChecked[repo]) / (24 * 60 * 60) -- seconds in a day
        local wholedays = math.floor(daysfrom)
        if wholedays >= 1 then
            _interalCall(resourcename, repo)
        end
    end
end

function VersionerAPI.checkFile(resourcename, repo)
    local cleanrepo = repo:gsub("https://github.com/", "")

    local current = {
        version = GetResourceMetadata(resourcename, 'version')
    }
    PerformHttpRequest('https://raw.githubusercontent.com/' .. cleanrepo .. '/main/version',
    function(err, response, headers)
        local v = response:match("<%d?%d.%d?%d.?%d?%d?>"):gsub("[<>]", "")
        local latest = {
            url = repo,
            body = response,
            version = v
        }
        local uptodate = false
        local overdate = false

        if current.version > latest.version then
            overdate = true
        elseif current.version < latest.version then
            uptodate = false
        else
            uptodate = true
        end

        if uptodate then
            print('^2✅Up to Date! ^5[' .. resourcename .. '] ^6(Current Version ' .. current.version .. ')^0')
        elseif overdate then
            print('^3⚠️Unsupported! ^5[' .. resourcename .. '] ^6(Version ' .. current.version .. ')^0')
            print('^4Current Version ^2(' .. latest.version .. ') ^3<' .. latest.url .. '>^0')
        else
            print('^1❌Outdated! ^5[' .. resourcename .. '] ^6(Version ' .. current.version .. ')^0')
            print('^4NEW VERSION ^2(' .. latest.version .. ') ^3<' .. latest.url .. '>^0')

            local cl = latest.body:gsub("<" .. current.version .. ">.*", "")
            print('^CHANGELOG ^0\r\n' .. cl)
        end
    end, 'GET', json.encode(payload), {
        ['Content-Type'] = 'application/json'
    })
end
