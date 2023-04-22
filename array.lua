---@generic T
---@class Array : { [integer] : T }
local Array = {}

function Array:__concat(other)
    local result = {}
    for _, v in ipairs(self) do
        table.insert(result, v)
    end
    for _, v in ipairs(other) do
        table.insert(result, v)
    end
    return setmetatable(result, Array)
end

function Array:__call(tbl)
    return ipairs(self)
end

---@generic T
---@param vals T[]
---@return Array<T>
function Array.create(vals)
    return setmetatable({table.unpack(vals)}, Array)
end

return Array
