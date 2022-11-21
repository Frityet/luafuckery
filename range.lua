local Ranges = {}
debug.setmetatable(0, { __index = Ranges })

function Ranges:to(n, inc)
    inc = inc or 1
    return coroutine.wrap(function()
        repeat
            coroutine.yield(self)
            self = self + inc
        until self > n
    end)
end
