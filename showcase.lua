require("import")

import "func"
import "netrequire"

from "module" import "myfunc" as "mod"

local pprint = require("https://raw.githubusercontent.com/jagt/pprint.lua/master/pprint.lua").pprint

pprint(mod.myfunc(10))

ipairs { "ie", "f32", "f23", "f42", "f22", "f42f2" }:print()

pairs(_G):print()

local function heavy(time)
    print("other thread, sleeping for "..time.." seconds")
    local start = os.time()
    repeat until os.time() >= start + time
    print("end other thread")
end


local thr = heavy:async(5)
print("main thread")
heavy(1)
print("end main thread")
thr:join()

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
