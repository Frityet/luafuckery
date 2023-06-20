

---Compiles a C module from source.
---@generic T
---@param source string
---@return fun(opts: { link_directories: string[]?, include_directory: string[]?, libraries: string[]?, export: string[] }): T
return function(source)
    source = [[
        #include <lua.h>
        #include <lauxlib.h>
        #include <lualib.h>
    ]]..source

    local cc = os.getenv("CC") or "clang"
    local liblua = {
        include = "/usr/local/include",
        lib = "/usr/local/lib",
        link = "lua"
    }

    if jit then
        liblua = {
            include = "/usr/local/include/luajit-2.1",
            lib = "/usr/local/lib",
            link = "luajit-2.1"
        }
    end

    local srcnam = os.tmpname()..".c"
    local src = assert(io.open(srcnam, "w"))
    src:write(source)
    local out = os.tmpname()..".so"
    return function(opts)
        local link_directories = opts.link_directories or {}
        local include_directory = opts.include_directory or {}
        local libraries = opts.libraries or {}

        local link_directories_str = ""
        for _, v in ipairs(link_directories) do
            link_directories_str = link_directories_str.." -L"..v
        end

        local include_directory_str = ""
        for _, v in ipairs(include_directory) do
            include_directory_str = include_directory_str.." -I"..v
        end

        local libraries_str = ""
        for _, v in ipairs(libraries) do
            libraries_str = libraries_str.." -l"..v
        end

        -- local export_str = ""
        -- for _, v in ipairs(export) do
        --     export_str = export_str.." -Wl,-export-dynamic -Wl,-export:"..v
        -- end

        -- adding in the luaL_Reg struct and the luaopen_* function based off the `export` table
        src:write("static const struct luaL_Reg $LIB$[] = {")
        for _, v in ipairs(opts.export) do
            src:write("{ \""..v.."\", "..v.." },")
        end
        src:write("{ NULL, NULL } };")
        src:write("int $LIB_OPEN$(lua_State *L) {")
        src:write("luaL_newlib(L, $LIB$);")
        src:write("return 1; }")
        src:close()

        local ok, err =
        os.execute(cc.." -shared -undefined dynamic_lookup -fPIC -o "..out.." "..srcnam
        .." -I"..liblua.include..include_directory_str
        .." -L"..liblua.lib.." -l"..liblua.link..link_directories_str..libraries_str)
        if not ok then error(err) end

        local mod = package.loadlib(out, "$LIB_OPEN$")()
        if not mod then error("Could not load module") end

        os.remove(out)
        os.remove(srcnam)

        return mod
    end
end
