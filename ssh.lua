
local server = setmetatable({
    ---@type file*
    _handle = assert(io.popen("ssh -X frityet@192.168.1.88", "w"))
}, {
    ---@param self { _handle: file* }
    ---@param cmd string
    __index = function (self, cmd)
        return function (args)
            if args ~= nil and type(args) == "table" then
                cmd = cmd..' '..table.concat(args, ' ')
            elseif args ~= nil then
                cmd = cmd..args
            end

            self._handle:write(cmd..'\n')
            self._handle:flush()
        end
    end
})

server["echo"] { "Hello, from lua!", '>', "out_macos.txt" }
server["xcalc"]()
server["screen"] "-x"
server["say"] "Hello, World!"
server._handle:close()
