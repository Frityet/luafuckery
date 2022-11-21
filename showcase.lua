require("import")

import "func"
import "netrequire"
import "switch"
import "range"

from "module" import { "myfunc" } as "mod"
from "class" import { "Object", "class" }

local MyType = class {
    name = "",
    id = 0
}

function MyType:print()
    print(self.name, self.id)
end

local instance = MyType:create {
    name = "bob",
    id = 4
}

instance:print()

local InheritedType = class(MyType) {
    age = 0
}

function InheritedType:create(name, id, age)
    return Object.create(InheritedType, {
        name = name,
        id = id,
        age = age
    })
end

function InheritedType:print()
    print(self.name, self.id, self.age)
end

instance = InheritedType:create("george", 10, 100)

instance:print()

local Integer = class {
    value = 0
}

function Integer:create(val)
    return Object.create(self, {
        value = val
    })
end

function Integer.operators:add(other)
    return Integer:create(self.value + other) 
end

function Integer.operators:tostring() return tostring(self.value) end

local obj = Integer:create(10)

print(obj + 11)

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
 
local sum = 0
for i in (1):to(10) do sum = sum + i end

io.write("Sum: ")
sum:to(sum):print();

(1):to(10):print()

