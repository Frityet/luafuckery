local Object = require("class")

local MyType = class {
    name = "",
    id = 0
}

function MyType:print()
    print(self.name, self.id)
end

local instance = MyType:create {
    name = "bob",
    id = 4
}

instance:print()

local InheritedType = class(MyType) {
    age = 0
}

function InheritedType:create(name, id, age)
    return Object.create(InheritedType, {
        name = name,
        id = id,
        age = age
    })
end

function InheritedType:print()
    print(self.name, self.id, self.age)
end

instance = InheritedType:create("george", 10, 100)

instance:print()
