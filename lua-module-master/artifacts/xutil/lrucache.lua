local lrucache = require "resty.lrucache"
local cache, err = lrucache.new(5000)  -- allow up to 200 items in the cache
if not cache then
    error("failed to create the cache: " .. (err or "unknown"))
end
local _M = {}

-- set 设置缓存
function _M:set(key, value, ttl, flags)
    return cache:set(key, value, ttl, flags)
end

-- get 获取缓存
function _M:get(key)
    return cache:get(key)
end

-- delete 删除
function _M:delete(key)
    return cache:delete(key)
end

return _M