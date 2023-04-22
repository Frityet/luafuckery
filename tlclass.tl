
local function test(): function<T>(args: {T | function(): T})
    return function<T>(args: {T | function(): T})
        for _, v in ipairs(args) do
            if type(v) == "function" then
                v = (v as function(): T)()
            end

            print(tostring(v))
        end
    end
end

test() {
    "hello",
    function(): string
        return "world"
    end,
    "!",
}
