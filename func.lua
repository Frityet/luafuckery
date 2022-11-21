local lanes = require("lanes").configure()

local oldipairs, oldpairs = _G.ipairs, _G.pairs

local FunctionExtensions = {}

function FunctionExtensions:async(...)
    self.__thread = lanes.gen("*", self)
    local thr = self.__thread(...)
    return thr
end

---@generic T
---@param tbl T[]
---@return fun(): integer, T
function ipairs(tbl)
    return coroutine.wrap(function ()
        for i, v in oldipairs(tbl) do coroutine.yield(i, v) end
    end)
end

---@generic TKey, TValue
---@param tbl {TKey:TValue}
---@return fun(): TKey, TValue
function pairs(tbl)
    return coroutine.wrap(function ()
        for k, v in oldpairs(tbl) do coroutine.yield(k, v) end
    end)
end

function FunctionExtensions:print()
    local out = {self()}
    while out[1] do
        print(table.unpack(out))
        out = {self()}
    end
end


debug.setmetatable(function () end, {
    __index = FunctionExtensions,
    __newindex = function (self, idx, val) if idx == "__thread" then debug.getmetatable(self).__index.__thread = val end end
})