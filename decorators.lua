---@generic T
---@param orig T
---@param opts fun(func: T, context: debuginfo): T
---@return T
local function decorate(orig, opts)
    return opts(orig, debug.getinfo(orig))
end

---@param a number
---@param b number
---@return number
local function add(a, b)
    return a + b
end

local add = decorate(add, function(func, context)
    print("decorating "..context.name)
    return function(...)
        print("calling "..context.name)
        return func(...)
    end
end)


print(add(1, 2))
for k, v in pairs(debug.getinfo(add)) do
    print(string.format("[\"%s\"] = %s", k, tostring(v)))
end
