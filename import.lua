local packages = {}
local currpkg = ""

---@param file string
function from(file)
    packages[file] = {
        contents = {},
        env = setmetatable({}, { __index = _G }),
        exported = {}
    }

    packages[file].contents = assert(pcall(loadfile(file..".lua", "bt", packages[file].env)))
    setmetatable(packages[file].env, nil)
    currpkg = file
end

---@param syms string[] | string
function import(syms)
    if type(syms) == "string" then return from(syms) end

    local export = {}
    for _, sym in ipairs(syms) do
        for name, value in pairs(packages[currpkg].env) do
            if name == sym then export[name] = value end
        end
    end

    packages[currpkg].exported = export
    for k, v in pairs(export) do _G[k] = v end
end

function as(name)
    _G[name] = {}

    for k, v in pairs(packages[currpkg].exported) do
        _G[name][k] = v
        _G[k] = nil
    end
end
