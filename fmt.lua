require("func");

local pprint = require("pprint")

local yield = coroutine.yield

---@return fun(): integer, string
function string:enumerate()
    return coroutine.wrap(function ()
        local i = 1
        repeat
            yield(i, self:sub(i, i))
            i = i + 1
        until i > self:len()
    end)
end

---@param self string
---@return string
return function (self)
    local indexes = self:enumerate():find(function (c) return c == '{' or c == '}' end):collect()
    local locals = {}

    local startp
    for i, v in ipairs(indexes) do
        if not startp then
            startp = v
            goto skip
        end

        locals[#locals+1] = self:sub(startp + 1, v - 1)
        startp = nil
        ::skip::
    end

    local vals = {}
    for _, v in ipairs(locals) do
        local j = 1
        while true do
            local ln, lv = debug.getlocal(2, j)
            if not ln then break end
            if ln == v then
                vals[#vals+1] = lv
                break
            end
            j = j + 1
        end
    end

    local str = ""
    local j, k = 0, 1
    for i = 1, #indexes, 2 do
        str = str..self:sub(j+1, indexes[i]-1)

        local v = vals[k]
        str = str..(type(v) == "table" and pprint.pformat(v) or tostring(v))
        j = indexes[i + 1]
        k = k + 1
    end

    return str
end
