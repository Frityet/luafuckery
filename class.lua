---@class Object
local Object = {}

---@generic T
---@param data T?
---@return T
function Object:create(data) return setmetatable(data or {}, { __index = self }) end

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
