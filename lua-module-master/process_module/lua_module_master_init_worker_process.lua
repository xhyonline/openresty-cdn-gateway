local ngx = ngx
ngx.log(ngx.INFO, "init初始化走到-1")
local id = ngx.worker.id()
local delay = 2
local handler
local cache = ngx.shared.cache
local mod_key = "loading_status"
local cjson = require("cjson")
local http = require("resty.http")
handler = function(premature)
    if premature then
        return
    end
    local res = cache:get(mod_key)
    if not res or res == "false" then
        ngx.log(ngx.INFO, "许弘毅调试定时任务更新了代码")
        local httpc = http.new()
        local address = "http://127.0.0.1:8787/getCode"
        local err
         res, err = httpc:request_uri(address, {
            method = "GET",
            headers = {
                ["Content-Type"] = "application/x-www-form-urlencoded",
            },
        })
        if err then
            ngx.log(ngx.ERR, "获取代码失败")
            return
        end
        local body = res.body
        if not body then
            ngx.log(ngx.ERR, "获取响应体失败")
            return
        end
        ngx.log(ngx.INFO, "响应体内容为:", body)
        --
        res = cjson.decode(body);


        local code_string = string.format([[
                %s
        ]], res["code_string"])
        ngx.log(ngx.INFO, "许弘毅调试,从云端更新了代码", code_string)
        local lua_src = code_string

        local f, err = loadstring(lua_src, "module foo")
        if not f then
            ngx.log(ngx.ERR, "failed to load module: ", err)
            return
        end
        local mod = f()
        if not mod then
            ngx.log(ngx.ERR, "Lua source does not return the module")
            return
        end
        package.loaded.foo = mod
        cache:set(mod_key, "true")
    end
    local ok, err = ngx.timer.at(delay, handler)
    if not ok then
        ngx.log(ngx.ERR, "failed to create the timer: ", err)
        return
    end
end


local ok, err = ngx.timer.at(delay, handler)
if not ok then
    ngx.log(ngx.ERR, "failed to create the timer: ", err)
    return
end
