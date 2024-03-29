require("import")

import "func"
import "netrequire"
import "switch"
import "range"
import "fmt"
import "cmod"
import "lambda"

from "module" import { "myfunc" } as "mod"
from "class" import { "Object", "class" }

local add = cmod [[
    int add(lua_State *lua)
    {
        int a = luaL_checkinteger(lua, 1);
        int b = luaL_checkinteger(lua, 2);
        lua_pushinteger(lua, a + b);
        return 1;
    }
]] { export = { "add" }, }

print(add(1, 2))

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

local function comp(k) return k == "frityet" or k == "amrit" end

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

local tbl = {
    "Hello, "
}
function tbl:run(msg)
    print("start")
    local start = os.time()
    repeat until os.time() >= start + 1
    print(self[1], msg)
    local start = os.time()
    repeat until os.time() >= start + 1
    print("end")
end

tbl.run:apply(tbl):async("World!")

local function double(v) return v * 2 end
local function addpair(k, v) return k + v end

local vals = (((1):to(100, 2) | double):ipairs() | addpair):collect()
ipairs(vals):print()

local str = "my string"
local num = 43534
local tbl = {};
(lambda'arg -> print(f"my string: ${str..num}, ${tbl}, ${arg}")')(43)

