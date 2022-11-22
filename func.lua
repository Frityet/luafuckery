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

function FunctionExtensions:enumerate()
    return coroutine.wrap(function ()
        local out = {self()}
        while out[1] do
            coroutine.yield(out)
            out = {self()}
        end
    end)
end


function FunctionExtensions:print()
    for vals in self:enumerate() do
        print(table.unpack(vals))
    end
end

function FunctionExtensions:appendto(tbl)
    for vals in self:enumerate() do
        local k, v = vals[1], vals[2]
        tbl[k] = v
    end

    return tbl
end

---@generic T
---@param self fun(): T
---@param fn fun(T)
---@return any[]
local function pipe(self, fn)
    local ret = {}
    for vals in self:enumerate() do
        ret[#ret+1] = fn(table.unpack(vals))
    end
    return ret
end

debug.setmetatable(function () end, {
    __index = FunctionExtensions,
    __newindex = function (self, idx, val) if idx == "__thread" then debug.getmetatable(self).__index.__thread = val end end,
    __bor = pipe
})