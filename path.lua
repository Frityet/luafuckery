
local lfs = require("lfs")

local is_windows = package.config:sub(1, 1) == "\\"

---@class Path
---@operator div(string|Path): Path
---@operator call(string): Path
---@operator sub(number): Path
local Path = {
    ---@type string[]
    parts = {},

    ---@type Path
    current_directory = {}
}
Path.__index = Path

---@param path string
---@param ... string
---@return Path
function Path.from(path, ...)
    local parts = {}
    if path:sub(1, 1) == "/" or path:sub(1, 1) == "\\" then parts = { "/" } end

    for part in path:gmatch("[^/\\]+") do
        table.insert(parts, part)
    end
    for _, part in ipairs({...}) do
        table.insert(parts, part)
    end
    return setmetatable({ parts = parts }, Path)
end

---@return boolean
function Path:exists()
    local mode = self:type()
    return mode == "directory" or mode == "file"
end


---@return LuaFileSystem.AttributeMode
function Path:type() return (lfs.attributes(tostring(self), "mode")) end

---@private
---@return boolean, string?
function Path:mkdir_p()
    local path = ""
    for _, part in ipairs(self.parts) do
        path = path..part.."/"

        local mode = lfs.attributes(path, "mode")
        if mode == nil then
            local ok, err = lfs.mkdir(path)
            if not ok then return false, err end
        elseif mode ~= "directory" then
            return false, "Path \""..path.."\" is not a directory"
        end
    end
    return true
end

---@overload fun(self: Path, type: "file", mode: openmode?): file*, string?
---@param type "directory"
---@return boolean | file*, string?
function Path:create(type, mode)
    if self:exists() then return false, "Path already exists" end

    if type == "directory" then return self:mkdir_p()
    elseif type == "file" then
        mode = mode or "w"
        local ok, err = (self - 1):mkdir_p()
        if not ok then return false, err end

        local file, err = io.open(tostring(self), mode)
        if not file then return false, err end

        return file
    else return false, "Invalid type \""..type.."\"" end
end

---@private
---@param path string | Path
---@return Path
function Path:__div(path)
    if type(path) == "table" then return Path.from(tostring(self), table.unpack(path.parts)) end
    --[[@cast path string]]

    local parts = {}
    for part in path:gmatch("[^/\\]+") do
        table.insert(parts, part)
    end

    return Path.from(tostring(self), table.unpack(parts))
end

---Removes `n` parts from the end of the path
---@param n number
---@return Path
function Path:pop(n)
    local parts = {}
    for i = 1, #self.parts - n do
        table.insert(parts, self.parts[i])
    end
    return Path.from(table.unpack(parts))
end

---@private
Path.__sub = Path.pop

---@private
---@return string
function Path:__tostring() return table.concat(self.parts, is_windows and "\\" or "/") end

setmetatable(Path, { __call = function(_, ...) return Path.from(...) end })
Path.current_directory = Path(lfs.currentdir())
return Path
