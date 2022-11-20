-- require("netrequire")
-- local pprint = require("https://raw.githubusercontent.com/jagt/pprint.lua/master/pprint.lua")

-- pprint.pprint {
--     test = "y s"
-- }

require("switch")

local input = io.read()
local t = switch(input) {
    ["amrit"] = function ()
        print("Woah!")
        return "lua is based"
    end,
    ["frityet"] = "based"
}

print(t)

local function comp(k)
    if k == "amrit" or k == "frityet" then return true
    else return false end
end

t = switch(comp) {
    [input] = function ()
        return "this is great!"
    end
}

print(t)
