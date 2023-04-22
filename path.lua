-- Copyright (C) 2023 Amrit Bhogal
--
-- This file is part of luayue.
--
-- luayue is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- luayue is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with luayue.  If not, see <http://www.gnu.org/licenses/>.

local unpack = unpack or table.unpack

local lfs = require("lfs")

local is_windows = package.config:sub(1, 1) == "\\"

---@class Path
---@overload fun(path: string, ...: string): Path
---@operator div(string|Path): Path
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
    if type(path) == "table" then return Path.from(tostring(self), unpack(path.parts)) end
    --[[@cast path string]]

    local parts = {}
    for part in path:gmatch("[^/\\]+") do
        table.insert(parts, part)
    end

    return Path.from(tostring(self), unpack(parts))
end

---Removes `n` parts from the end of the path
---@param n number
---@return Path
function Path:pop(n)
    local parts = {}
    for i = 1, #self.parts - n do
        table.insert(parts, self.parts[i])
    end
    return Path.from(unpack(parts))
end

---@return fun(): Path?
function Path:entries()
    return coroutine.wrap(function ()
        for entry in lfs.dir(tostring(self)) do
            if entry ~= "." and entry ~= ".." then coroutine.yield(self/entry) end
        end
    end)
end

---@return string?, string?
function Path:read_all()
    local f, err = self:create("file", "r")
    if not f then return nil, err end
    --[[ @cast f file* ]]

    local data = f:read("*a")
    f:close()

    return data
end

---@return string?
function Path:extension()
    local name = self.parts[#self.parts]
    local i = name:find("%.")
    if i then return name:sub(i + 1) end
end

---@private
Path.__sub = Path.pop

---@private
---@return string
function Path:__tostring() return table.concat(self.parts, is_windows and "\\" or "/") end

function Path.temporary_directory()
    local path = os.tmpname()
    if is_windows then path = path:sub(1, -5) end
    return Path(path)
end

setmetatable(Path, { __call = function(_, ...) return Path.from(...) end })
Path.current_directory = Path(lfs.currentdir())
return Path
