local lanes = require("lanes").configure()

local FunctionExtensions = {}

function FunctionExtensions:async(...)
    self.__thread = lanes.gen("*", self)
    local thr = self.__thread(...)
    return thr
end

---@generic T
---@param tbl T[]
---@return fun(): integer, T
local function ipairs(tbl)
    return coroutine.wrap(function ()
        local p = _G.ipairs
        for i, v in p(tbl) do coroutine.yield(i, v) end
        return nil
    end)
end

---@generic TKey, TValue
---@param tbl {TKey:TValue}
---@return fun(): TKey, TValue
local function pairs(tbl)
    return coroutine.wrap(function ()
        local p = _G.pairs
        for k, v in p(tbl) do coroutine.yield(k, v) end
        return nil
    end)
end

function FunctionExtensions:print()
    for k, v in self do print(k, v) end
end


debug.setmetatable(function () end, {
    __index = FunctionExtensions,
    __newindex = function (self, idx, val) if idx == "__thread" then debug.getmetatable(self).__index.__thread = val end end
})