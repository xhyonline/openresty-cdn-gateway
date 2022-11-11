local _M = {}

-- construct_kv_hash_all 快速构造键值
function _M:construct_kv_hgetall(table)
    local resp = {}
    if not table then
        return resp
    end
    if type(table) ~= "table" then
        return resp
    end
    local hash_key
    for i, v in pairs(table) do
        -- 值
        if i % 2 == 0 then
            resp[hash_key] = v
        else
            hash_key = v
        end
    end
    return resp
end

return _M