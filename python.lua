require("import")

function input(str)
    io.write(str or "")
    return io.read()
end

local fnifo = {}
function def(f)
    return function (...)
        fnifo[f] = { argn = {...} }

        return {
            _ = function (self, fn) _G[f] = function (...)
                    local args = {...}
                    for i, v in ipairs(fnifo[f].argn) do _G[v] = args[i] end
                end
            end
        } 
    end
end

function range(s, e, n)
    return coroutine.wrap(function ()
        for i = s, e, n or 1 do coroutine.yield(i) end
    end)
end

local f_idx = nil
function för(v)
    f_idx = v
end

function ín(it)
    return {
        _ = function (self, fn)
            _G[f_idx] = it()
            while _G[f_idx] do
                fn()
                _G[f_idx] = it()
            end
        end
    }
end

local success = false
function íf(cond)
    return {
        _ = function (self, fn) success = cond; if cond then fn() end end
    }
end

function elif(cond)
    return {
        _ = function (self, fn)
            if not success then íf(cond):_(fn) end
        end
    }
end

élse = {
    _ = function (self, fn)
        if not success then fn(); success = true end
    end
}

def "fizzbuzz"('x'):
    _(function()
        för "num" ín (range(1, x)):
            _(function ()
                íf (num % 15 == 0):
                    _(function () print("FizzBuzz") end)
                elif (num % 3 == 0):
                    _(function () print("Fizz") end)
                elif (num % 5 == 0):
                    _(function () print("Buzz") end)
                élse:
                    _(function() print(num) end)
            end)
    end)

fizzbuzz(101)
