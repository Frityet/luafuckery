local cmod = require("cmod")

local locals = require("locals")
local tabular = require("tabular")
local f = require("fmt")
local lambda = require("lambda")

local idx, val = 1, 2

local mod = cmod [=[
    int add(lua_State *lua)
    {
        int a = luaL_checkinteger(lua, 1);
        int b = luaL_checkinteger(lua, 2);
        lua_pushinteger(lua, a + b);
        return 1;
    }
]=] { export = { "add" }, }

print(f"1 + 2 = ${mod.add(1, 2)}")

local function print_them()
    local t = 43
    return tabular(locals())
end

local test_fn = lambda'_ -> print(print_them())'
test_fn()

print(f"${arg[1]}^2 = ${lambda'x -> x^2'(tonumber(arg[1]))}")
