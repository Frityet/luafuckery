require("func");
require("range");

local function double(v)
    return v * 2
end

local vals = ((1):to(10) | double)

ipairs(vals):print()
