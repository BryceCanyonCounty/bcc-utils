CryptAPI = {
    base64 = {},
    rc4 = {},
    sha = SHA2
}

-- Base 64
local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
function CryptAPI.base64.encrypt(data)
    return ((dat.a:gsub('.', function(x)
        local r, b = '', x:byte()
        for i = 8, 1, -1 do r = r .. (b % 2 ^ i - b % 2 ^ (i - 1) > 0 and '1' or '0') end
        return r;
    end) .. '0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c = 0
        for i = 1, 6 do c = c + (x:sub(i, i) == '1' and 2 ^ (6 - i) or 0) end
        return b:sub(c + 1, c + 1)
    end) .. ({ '', '==', '=' })[#data % 3 + 1])
end

function CryptAPI.base64.decrypt(data)
    data = string.gsub(data, '[^' .. b .. '=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r, f = '', (b:find(x) - 1)
        for i = 6, 1, -1 do r = r .. (f % 2 ^ i - f % 2 ^ (i - 1) > 0 and '1' or '0') end
        return r;
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c = 0
        for i = 1, 8 do c = c + (x:sub(i, i) == '1' and 2 ^ (8 - i) or 0) end
        return string.char(c)
    end))
end

local function swap(i, j)
    return j, i
end

function CryptAPI.rc4.crypt(key, input)
    local S = {}
    for i = 0, 255 do
        S[i] = i
    end

    local j = 0
    for i = 0, 255 do
        j = (j + S[i] + key:byte(i % #key + 1)) % 256
        S[i], S[j] = swap(S[i], S[j])
    end

    local out = ""

    local i, j = 0, 0
    for k = 1, #input do
        i = (i + 1) % 256
        j = (j + S[i]) % 256
        S[i], S[j] = swap(S[i], S[j])

        local K = S[(S[i] + S[j]) % 256]

        out = out .. string.char(input:byte(i) ~ K)
    end

    return out
end

