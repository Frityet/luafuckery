--- Gets all local variables across all levels of the stack.
---@return { [string] : any }
return function ()
    local _VARS_ = {}
    local _LEVEL_ = 1

    while true do
        local _EMPTY_ = true
        local _INDEX_ = 1

        while true do
            if debug.getinfo(_LEVEL_) == nil then break end

            local name, value = debug.getlocal(_LEVEL_, _INDEX_)

            if name ~= nil then
                _EMPTY_ = false

                if name:sub(1, 1) ~= "(" and name ~= "_VARS_" and name ~= "_LEVEL_" and name ~= "_EMPTY_" and name ~= "_INDEX_" then
                    _VARS_[name] = value
                end

            else break end

            _INDEX_ = _INDEX_ + 1
        end

        if _EMPTY_ then break end

        _LEVEL_ = _LEVEL_ + 1
    end

    return _VARS_
end
