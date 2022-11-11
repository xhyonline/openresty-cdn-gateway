local kv = require("artifacts.kv.redis")
local x_table = require("artifacts.xutil.table")
local ngx = ngx
local cjson = require("cjson")
local _M = {}
local domain_key = "x-mf-cdn-domain:"
local ssl_key = "x-mf-cdn-ssl:"
local nodes_key = "x-mf-cdn-mgroup:"
local strategy_key = "x-mf-cdn-strategy:"

-- get_domain 获取域名基本配置信息
function _M:get_domain(domain)
    local key = string.format("%s%s", domain_key, domain)
    local result = kv:hgetall(key)
    return x_table:construct_kv_hgetall(result)
end

-- get_ssl_by_sni 获取证书配置
function _M:get_ssl_by_sni(sni)
    local key = string.format("%s%s", domain_key, sni)
    local ssl_id = kv:hget(key, "origin_ssl_id")
    local resp = {}
    if not ssl_id then
        return resp
    end
    return self:get_ssl(tonumber(ssl_id))
end

-- domain_exists 判断域名是否存在
function _M:domain_exists(domain)
    local key = string.format("%s%s", domain_key, domain)
    local result = kv:exists(key)
    return result and tonumber(result) == 1
end

-- get_ssl 通过证书 ID 获取基本配置
function _M:get_ssl(id)
    local key = string.format("%s%d", ssl_key, id)
    local result = kv:hgetall(key)
    return x_table:construct_kv_hgetall(result)
end

-- get_nodes_by_group 通过主机组获取到主机列表
function _M:get_nodes_by_group(group)
    local key = string.format("%s%d", nodes_key, group)
    local result = kv:hgetall(key)
    return x_table:construct_kv_hgetall(result)
end

-- get_parent_by_sid 通过策略 ID 和当前主机组获取它的主父和备父组
function _M:get_parent_group_by_sid(sid, group)
    local key = string.format("%s%s", strategy_key, sid)
    local parent = self:get_parent_group_key(group)
    local s_parent = self:get_s_parent_group_key(group)
    local resp = {}
    local result = kv:hmget(key, parent, s_parent)
    if not result then
        return resp
    end
    for i, v in pairs(result) do
        if i == 1 then
            resp[parent] = v
        else
            resp[s_parent] = v
        end
    end
    return resp
end

-- get_parent_key 获取父级 key
function _M:get_parent_group_key(current_group)
    return string.format("%s_parent", current_group)
end

-- get_s_parent_group_key 获取备父 key
function _M:get_s_parent_group_key(current_group)
    return string.format("%s_s_parent", current_group)
end

return _M