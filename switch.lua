---@generic T
---@param val string | integer | fun(T): boolean
---@return fun(args: { [string | integer | T]: any | fun(): any   }): any
function switch(val)
    ---@generic T
    ---@type fun(args: { [string | integer | T]: any | fun(): any  })
    return function (args)
        for k, v in pairs(args) do
            local success = false
            if type(val) == "function" then
                success = val(k)
            else
                success = k == val
            end

            if success then return type(v) == "function" and v() or v end
        end
    end
end
