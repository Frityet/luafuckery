require("import")

from "module" import "myfunc" as "funct"

print(funct.myfunc(10))

require("netrequire")

local pprint = require("https://raw.githubusercontent.com/jagt/pprint.lua/master/pprint.lua").pprint
pprint {
    hello = "world!"
}
