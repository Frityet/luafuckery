local https = require("ssl.https")

---@param url string
package.searchers[#package.searchers+1] = function (url)
    if url:find("https") ~= 1 then return nil end

    print("Getting package from \""..url.."\"...")
    local contents, errc = https.request(url)
    if errc ~= 200 then error("Could not execute HTTPS request! Reason: "..errc) end

    local ok, res = pcall(load(contents, nil, "bt"))
    if not ok then error("Could not load chunk") end

    print("Done")
    return res
end
