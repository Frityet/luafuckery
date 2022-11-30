local Ranges = {}
debug.setmetatable(0, { 
    __index = Ranges,
    __concat = function (self, rhs)
        if type(rhs) ~= "number" then error("Right hand side must be an integer") end

        return tostring(self)..":"..tostring(rhs)
    end
})

function Ranges:to(n, inc)
    inc = inc or 1
    return coroutine.wrap(function()
        repeat
            coroutine.yield(self)
            self = self + inc
        until self > n
    end)
end

---@param str string
---@return fun(): number
return function (str)
    print(str)
    local g = str:gmatch("([^:]+)")
    return tonumber(g()):to(tonumber(g()))
end
