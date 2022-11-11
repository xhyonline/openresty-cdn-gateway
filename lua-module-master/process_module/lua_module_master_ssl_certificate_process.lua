-- 2022/10/31 许弘毅改造 ssl_certificate_by_lua_block 阶段
local ssl = require "ngx.ssl"
local sni, err = ssl.server_name()
local ngx = ngx
local lrucache = require("artifacts.xutil.lrucache")
local cloud = require("lua_service.cloud")
if not sni then
    ngx.log(ngx.ERR, "no SNI fond: ", err)
    ngx.exit(ngx.ERROR)
end ;

local key = string.format("ssl-sni-key-:%s", sni)
local cert_cache = lrucache:get(key)
local cert_pem, cert_key
if not cert_cache then
    -- 从云端下发的配置中获取
    local res = cloud:get_ssl_by_sni(sni)
    if not res.cert or res.key == "" then
        -- 没有证书
        return
    end
    cert_pem, cert_key = res.cert, res.key
    lrucache:set(key, {
        ["pem"] = cert_pem,
        ["key"] = cert_key
    }, 10)  -- 上线后可修改,单位 s
else
    cert_pem, cert_key = cert_cache["pem"], cert_cache["key"]
end
if cert_pem == "" or cert_key == "" then
    return
end

-- 清除之前的公钥和私钥
local ok, err = ssl.clear_certs()
if not ok then
    ngx.log(ngx.ERR, "清除证书公钥和私钥失败", err)
    return ngx.exit(ngx.ERROR)
end
local cert, err = ssl.parse_pem_cert(cert_pem)
if not cert then
    ngx.log(ngx.ERR, "解析证书失败,原因:", err)
    return
end
ok, err = ssl.set_cert(cert)
if not ok then
    ngx.log(ngx.ERR, "设置证书失败,原因:", err)
    return
end
local pkey, err = ssl.parse_pem_priv_key(cert_key)
if not pkey then
    ngx.log(ngx.ERR, "解析私钥失败,原因:", err)
    return
end
ok, err = ssl.set_priv_key(pkey)
if not ok then
    ngx.log(ngx.ERR, "设置私钥失败,原因:", err)
    return
end