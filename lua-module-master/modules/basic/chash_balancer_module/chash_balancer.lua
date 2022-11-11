-- 用于动态反向代理
local _M = { _VERSION = '0.01' }
local ngx = ngx;
local balancer = require "ngx.balancer"
local cjson = require("cjson")
--local resty_chash = require "resty.chash"
--local nodes = {
--    [1] = 50,
--    [2] = 50,
--    [3] = 50,
--    [4] = 50,
--    [5] = 50,
--    [6] = 50
--}
--
--local chash_up = resty_chash:new(nodes)

-- chash_balancer 一致性 hash
function _M.chash_balancer(conf)
    -- TODO 需要根据一致性 hash 做共享存储
    local range = ngx.var.slice_range
    local uri = ngx.var.uri
    local hash = ngx.md5(uri ..range)
    ngx.log(ngx.INFO, "调试 hash:", hash)
    assert(balancer.set_current_peer("127.0.0.1", "8787"))
end
return _M;


