local get_locals = require("locals")


---@param str string
---@return string
return function (str)
    local locals = get_locals()

    -- Combine the locals with the global env
    local env = {}
    for k, v in pairs(_G) do env[k] = v end
    -- Locals after, so they can override globals.
    for k, v in pairs(locals) do env[k] = v end

    -- In between ${} is a lua expression, and the result is inserted into the string.
    -- so like ${hi} is a variable, and ${hi + 1} is a variable plus 1.
    -- So return a string with all the variables in it.

    ---@param str string
    ---@return string
    local function replace(str)
        return (str:gsub("%${.-}", function(match)
            local expr = match:sub(3, -2)
            local ok, res = pcall(assert(load("return "..expr, "fmt", "t", env)))
            if ok then return tostring(res)
            else return match end
        end))
    end

    ---@param str string
    ---@return string
    local function replace_all(str)
        local new = replace(str)
        if new == str then return new
        else return replace_all(new) end
    end

    return replace_all(str)
end
