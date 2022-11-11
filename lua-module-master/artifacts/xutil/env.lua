local _M = {}
local ngx = ngx

-- get_hostname 获取主机名
function _M:get_hostname()
    return string.lower(ngx.var.hostname)
end

-- get_group 获取主机组
function _M:get_group()
    local hostname = self:get_hostname()
    if #hostname < 6 then
        return ""
    end
    return string.sub(hostname, 1, 6)
end

-- get_env 获取当前环境
function _M:get_env()
    local env = os.getenv("cdn-env")
    if not env or env == "" then
        return "dev"
    end
    return "pro"
end



