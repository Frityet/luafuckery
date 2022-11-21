local Object = require("class")
require("func")

local MyType = class {
    value = 0
}

function MyType:create(val)
    return Object.create(self, {
        value = val
    })
end

function MyType.operators:add(other)
    return MyType:create(self.value + other) 
end

function MyType.operators:tostring() return tostring(self.value) end

local obj = MyType:create(10)

print(obj + 11)
