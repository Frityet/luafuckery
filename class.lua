local f = require("fmt")

---@generic T
---@param ... T
---@return T | fun(...: T): T
function class(...)
    local args = {...}
    local obj = setmetatable({}, { __index = args[#args] })

    if #args > 1 then
        for i, v in ipairs(args) do
            local mt = getmetatable(v)
            if not mt then error(f"Table {i} cannot be inherited from") end


        end
    end


end

local Object = class {

}

Object = class(Object, Object, Object) {

}
