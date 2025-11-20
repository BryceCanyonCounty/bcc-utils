VersionerAPI = {}
ActiveCache = {}

local function _setActiveCache(repo, alerts)
    if type(ActiveCache) ~= "table" then
        ActiveCache = {}
    end

    ActiveCache[repo] = {
        alerts = alerts,
        timestamp = os.time()
    }

    SaveResourceFile(
        GetCurrentResourceName(),
        './server/cache/version.json',
        json.encode(ActiveCache)
    )
end

local function _getCachedRelease(repo)
    if type(ActiveCache) ~= "table" then
        ActiveCache = {}
    end

    return ActiveCache[repo]
end

local function _loadActiveCache()
    local data = LoadResourceFile(GetCurrentResourceName(), './server/cache/version.json')

    if data then
        local ok, decoded = pcall(json.decode, data)
        if ok and type(decoded) == "table" then
            ActiveCache = decoded
        else
            print("[Versioner] WARNING: Failed to decode cache file, starting with empty cache.")
            ActiveCache = {}
        end
    else
        print("[Versioner] No cache file found, starting with empty cache.")
        ActiveCache = {}
    end
end

local function _interalCall(resourcename, repo, cached)
    if cached then
        print(("[Versioner] Using CACHED data for resource '%s' repo '%s'"):format(resourcename, repo))

        local cached_release = _getCachedRelease(repo)

        if not cached_release then
            print(("[Versioner] WARNING: cached_release is nil for repo '%s' (resource '%s')"):format(repo, resourcename))
            return
        end

        if not cached_release.alerts then
            print(("[Versioner] WARNING: cached_release.alerts is nil for repo '%s' (resource '%s')"):format(repo, resourcename))
            return
        end

        if cached_release.alerts[1] then
            cached_release.alerts[1] = '^6(CACHED)' .. cached_release.alerts[1]
        end

        for _, value in ipairs(cached_release.alerts) do
            print(value)
        end
    else
        print(("[Versioner] Checking LIVE release for resource '%s' repo '%s'"):format(resourcename, repo))

        local current = {
            version = GetResourceMetadata(resourcename, 'version', 0)
        }
        local alerts = {}

        if not current.version or current.version == "" then
            print(("[Versioner] WARNING: Resource '%s' has no 'version' metadata set."):format(resourcename))
            return
        end

        PerformHttpRequest('https://api.github.com/repos/' .. repo .. '/releases/latest', function(err, text, headers)
            if err ~= 200 then
                print('^1ERROR: Please try again later. Code (', err, ')', '[', repo, ']')
                return
            end

            if not text or text == "" then
                print(("[Versioner] WARNING: Empty response from GitHub for repo '%s'"):format(repo))
                return
            end

            local ok, response = pcall(json.decode, text)
            if not ok or type(response) ~= "table" then
                print(("[Versioner] WARNING: Failed to decode GitHub JSON for repo '%s'"):format(repo))
                return
            end

            local latest = {
                url = response.html_url,
                body = response.body,
                version = response.tag_name
            }

            if not latest.version then
                print(("[Versioner] WARNING: No 'tag_name' in latest release for repo '%s'"):format(repo))
                return
            end

            local uptodate = false
            local overdate = false

            -- NOTE: string comparison; assumes semantic-like versioning and consistent format
            if current.version > latest.version then
                overdate = true
            elseif current.version < latest.version then
                uptodate = false
            else
                uptodate = true
            end

            if uptodate then
                alerts = {
                    '^2✅ Up to Date! ^5[' .. resourcename .. '] ^6(Current Version ' .. current.version .. ')^0'
                }
            elseif overdate then
                alerts = {
                    '^3⚠️ Unsupported! ^5[' .. resourcename .. '] ^6(Version ' .. current.version .. ')^0',
                    '^4Current Version ^2(' .. latest.version .. ') ^3<' .. latest.url .. '>^0'
                }
            else
                alerts = {
                    '^1❌ Outdated! ^5[' .. resourcename .. '] ^6(Version ' .. current.version .. ')^0',
                    '^4NEW VERSION ^2(' .. latest.version .. ') ^3<' .. latest.url .. '>^0',
                    '^4CHANGELOG ^0\r\n' .. (latest.body or "")
                }
            end

            _setActiveCache(repo, alerts)

            for _, value in ipairs(alerts) do
                print(value)
            end
        end, 'GET', '', {
            ['Content-Type'] = 'application/json'
        })
    end
end

function VersionerAPI.checkRelease(resourcename, repo)
    if not repo or repo == "" then
        print(("[Versioner] WARNING: No github_link metadata for resource '%s'"):format(resourcename))
        return
    end

    repo = repo:gsub("https://github.com/", "")

    local cached_release = _getCachedRelease(repo)
    if cached_release == nil then
        _interalCall(resourcename, repo, false)
    else
        local hours_from = os.difftime(os.time(), cached_release.timestamp or 0) / (60 * 60)
        local whole = math.floor(hours_from)
        _interalCall(resourcename, repo, whole < 2) -- 2 hour cache
    end
end

function VersionerAPI.checkFile(resourcename, repo)
    if not repo or repo == "" then
        print(("[Versioner] WARNING: No github_link metadata for resource '%s' (file check)"):format(resourcename))
        return
    end

    local cleanrepo = repo:gsub("https://github.com/", "")

    local current = {
        version = GetResourceMetadata(resourcename, 'version', 0)
    }

    if not current.version or current.version == "" then
        print(("[Versioner] WARNING: Resource '%s' has no 'version' metadata set (file check)."):format(resourcename))
        return
    end

    PerformHttpRequest('https://raw.githubusercontent.com/' .. cleanrepo .. '/main/version',
        function(err, response, headers)
            if err == 404 then
                print("Version file not found for resource: " .. resourcename)
                return
            end

            if response == nil then
                print("Generic github version error", err)
                return
            end

            local v = response:match("<%d?%d.%d?%d.?%d?%d?>")
            if not v then
                print("Failed to parse version in version file for resource: " .. resourcename)
                return
            end
            v = v:gsub("[<>]", "")

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
                print('^2✅ Up to Date! ^5[' .. resourcename .. '] ^6(Current Version ' .. current.version .. ')^0')
            elseif overdate then
                print('^3⚠️ Unsupported! ^5[' .. resourcename .. '] ^6(Version ' .. current.version .. ')^0')
                print('^4Current Version ^2(' .. latest.version .. ') ^3<' .. latest.url .. '>^0')
            else
                print('^1❌ Outdated! ^5[' .. resourcename .. '] ^6(Version ' .. current.version .. ')^0')
                print('^4NEW VERSION ^2(' .. latest.version .. ') ^3<' .. latest.url .. '>^0')

                local cl = latest.body:gsub("<" .. current.version .. ">.*", "")
                print('^CHANGELOG ^0\r\n' .. cl)
            end
        end, 'GET', '', {
            ['Content-Type'] = 'application/json'
        })
end

-- Load cache on start
_loadActiveCache()

local function CheckForUpdate(resource)
    local ActiveCheck = GetResourceMetadata(resource, 'github_version_check', 0)

    if ActiveCheck == 'true' then
        local resourcename = GetResourceMetadata(resource, 'name', 0)
        local github = GetResourceMetadata(resource, 'github_link', 0)
        local githubtype = GetResourceMetadata(resource, 'github_version_type', 0)

        if not githubtype or githubtype == '' then
            githubtype = "release"
        end

        print(("[Versioner] Checking resource '%s' (internal='%s') github='%s' type='%s'")
            :format(resourcename, resource, tostring(github), tostring(githubtype)))

        if githubtype == "release" then
            VersionerAPI.checkRelease(resourcename, github)
        elseif githubtype == "file" then
            VersionerAPI.checkFile(resourcename, github)
        end
    end
end

local function CheckForUIRelease(resource)
    local CheckUI = GetResourceMetadata(resource, 'github_ui_check', 0)

    if CheckUI == 'true' then
        local resourcename = GetResourceMetadata(resource, 'name', 0)
        local repo = GetResourceMetadata(resource, 'github_link', 0)

        local f = LoadResourceFile(resourcename, './ui/index.html')
        if not f then
            print("^1 INCORRECT DOWNLOAD!  ^0")
            print('^4 Please Download: ^2(' .. resourcename .. '.zip) ^4from ^3<' .. repo .. '/releases/latest>^0')
        end
    end
end

CreateThread(function()
    local ResourceCount = GetNumResources()
    local found = {}

    for i = 0, ResourceCount - 1 do
        local resource = GetResourceByFindIndex(i)
        if resource and resource:match("^bcc%-") then
            table.insert(found, resource)
        end
    end

    table.sort(found)

    for _, resource in ipairs(found) do
        CheckForUpdate(resource)
        CheckForUIRelease(resource)
    end
end)
