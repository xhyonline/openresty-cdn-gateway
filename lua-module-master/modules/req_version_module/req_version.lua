local _M = { _VERSION = '0.01' }
local ngx = ngx;
local cjson = require("cjson")
local http = require("resty.http")

function _M.req_version_handle(conf)
    local httpc = http.new()
    local address = "http://127.0.0.1:8787/getVersion"
    local res, err = httpc:request_uri(address, {
        method = "GET",
        headers = {
            ["Content-Type"] = "application/x-www-form-urlencoded",
        },
    })
    if err then
        ngx.log(ngx.ERR, "获取版本号出错了:", err)
        ngx.exit(ngx.ERROR)
    end
    local body = res.body
    if not body or body == "" then
        ngx.log(ngx.ERR, "获取版本号出错了没有响应体")
        ngx.exit(ngx.ERROR)
    end
    res = cjson.decode(body);
    ngx.var.version = res.version
    httpc:set_keepalive(30000, 10)
    return ;
end

return _M;
