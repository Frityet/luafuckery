---@class Object
local Object = {
    operators = {}
}

do
    setmetatable(Object.operators, {
        __newindex = function (self, key, value)
            rawset(self, "__"..key, value)
        end,
        __index = function (self, key)
            return rawget(self, "__"..key)
        end
    })
end

---@generic T
---@param data T?
---@return T
function Object:create(data)
    local mt =  { __index = self }

    pairs(self.operators):appendto(mt)

    return setmetatable(data or {}, mt)
end

---@generic T
---@param data T?
---@return T | fun(T?): T
function class(data)
    local old_mt = getmetatable(data)
    if old_mt then
        return function (data)
            return setmetatable(data or {}, { __index = old_mt.__index })
        end
    end

    data = setmetatable(data or {}, { __index = Object })
    return setmetatable({}, { __index = data })
end

return Object
