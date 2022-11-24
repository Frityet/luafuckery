require("func")

---@param fn fun(_ENV: _G)
---@return string
return function (fn)

    local env = { _G = _G }
    getmetatable(env._G).__index = function (self, tagname)
        return function(props)
            return {
                __id = tagname,
                __props = (pairs(props) | function (k, v) if type(k) == "string" then return k, v end end):collect(),
                __values = ipairs(props):collect()
            }
        end
    end

    local tags = fn(env)

    local str = ""
    for k, v in pairs(tags) do
        
    end
    return str
end
