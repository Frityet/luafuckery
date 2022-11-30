local lanes = require("lanes").configure()

local oldipairs, oldpairs = _G.ipairs, _G.pairs

local yield = coroutine.yield

---@class function
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
        for i, v in oldipairs(tbl) do yield(i, v) end
    end)
end

---@generic TKey, TValue
---@param tbl {TKey:TValue}
---@return fun(): TKey, TValue
function pairs(tbl)
    return coroutine.wrap(function ()
        for k, v in oldpairs(tbl) do yield(k, v) end
    end)
end

function FunctionExtensions:keys()
    return coroutine.wrap(function()
        for vals in self:enumerate() do yield((table.unpack(vals))) end
    end)
end

function FunctionExtensions:enumerate()
    return coroutine.wrap(function ()
        local out = {self()}
        while out[1] do
            yield(out)
            out = {self()}
        end
    end)
end


---@param fmt string?
function FunctionExtensions:print(fmt)
    for vals in self:enumerate() do
        if fmt then 
            print(string.format(fmt, table.unpack(vals)))
        else
            print(table.unpack(vals))
        end
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
---@param fn fun(T): any
---@return async fun(): any[]
local function pipe(self, fn)
    return coroutine.wrap(function ()
        for vals in self:enumerate() do yield(fn(table.unpack(vals))) end
    end)
end

---@generic T
---@param self fun(): T
---@param fn fun(T): any
---@return async fun(): any[]
local function select(self, fn)
    return coroutine.wrap(function ()
        for vals in self:enumerate() do
            local ok = false
            if type(vals) == "table" then ok = fn(tbl.unpack(vals)) end
        end
    end)
end

function FunctionExtensions:sum()
    return coroutine.wrap(function ()
        local sum
        for val in self:enumerate() do
            sum = sum == nil and sum or sum + val
            yield(sum)
        end

        return sum
    end)
end

function FunctionExtensions:collect()
    local ret = {}
    for vals in self:enumerate() do
        if type(vals) == "table" and #vals == 1 then ret[#ret+1] = vals[1] else ret[#ret+1] = vals end
    end
    return ret
end

function FunctionExtensions:apply(arg)
    return function (...) return self(arg, ...) end
end

function FunctionExtensions:ipairs()
    return coroutine.wrap(function ()
        local i = 1
        for val in self:enumerate() do
            if #val == 1 then yield(i, val[1])
            else yield(i, val) end
            i = i + 1
        end
    end)
end

---@generic T
---@param fn T | fun(T): boolean
function FunctionExtensions:find(fn)
    return coroutine.wrap(function ()
        for vals in self:enumerate() do
            local i, v = vals[1], vals[2]

            local found = false
            if type(fn) == "function" then found = fn(v)
            else found = fn == v end
            if found then yield(i) end
        end
    end)
end

debug.setmetatable(function () end, {
    __index = FunctionExtensions,
    __newindex = function (self, idx, val) if idx == "__thread" then debug.getmetatable(self).__index.__thread = val end end,
    __bor = pipe
})
