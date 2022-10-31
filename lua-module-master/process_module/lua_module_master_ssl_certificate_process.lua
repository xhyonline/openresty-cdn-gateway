-- 2022/10/31 许弘毅改造 ssl_certificate_by_lua_block 阶段
local ssl = require "ngx.ssl"
local httpc = require("resty.http").new()
local cjson = require "cjson"
local b64 = require("ngx.base64")
local ocsp = require "ngx.ocsp"
local sni, err = ssl.server_name()
local cache = ngx.shared.cache
if not sni then
    ngx.log(ngx.ERR, "no SNI fond: ", err)
    ngx.exit(ngx.ERROR)
end ;
local address = "http://127.0.0.1:8787/getDomain?domain=" .. sni
local res, err = httpc:request_uri(address, {
    method = "GET",
    headers = {
        ["Content-Type"] = "application/x-www-form-urlencoded",
    },
})
if err then
    ngx.log(ngx.ERR, "出错了:", err)
end
local body = res.body
res = cjson.decode(body);
if res.key and res.key ~= "" then
    -- 清除之前的公钥和私钥
    local ok, err = ssl.clear_certs()
    if not ok then
        ngx.log(ngx.ERR, "清除证书公钥和私钥失败", err)
        return ngx.exit(ngx.ERROR)
    end
    local cert, err = ssl.parse_pem_cert(res.pem)
    if not cert then
        ngx.log(ngx.ERR, "解析证书失败,原因:", err)
        return
    end
    ok, err = ssl.set_cert(cert)
    if not ok then
        ngx.log(ngx.ERR, "设置证书失败,原因:", err)
        return
    end
    local pkey, err = ssl.parse_pem_priv_key(res.key)
    if not pkey then
        ngx.log(ngx.ERR, "解析私钥失败,原因:", err)
        return
    end
    ok, err = ssl.set_priv_key(pkey)
    if not ok then
        ngx.log(ngx.ERR, "设置私钥失败,原因:", err)
        return
    end
    local finalRes = cache:get(sni)
    local ocsp_resp = ""
    if not finalRes then
        local der_cert, err = ssl.cert_pem_to_der(res.pem)
        if err then
            ngx.log(ngx.ERR, "转换 der 失败", err)
            return
        end
        local ocsp_url, err = ocsp.get_ocsp_responder_from_der_chain(der_cert)
        if err then
            ngx.log(ngx.ERR, "获取 ocsp_url 失败", err)
            return
        end
        local ocsp_req, err = ocsp.create_ocsp_request(der_cert)                -- 生成 OCSP 请求体
        if err then
            ngx.log(ngx.ERR, "生成 OCSP 请求体", err)
            return
        end
        res, err = httpc:request_uri(ocsp_url, {                          -- 发送 HTTP 请求
            method = "POST", -- 必须 POST 数据
            body = ocsp_req, -- 使用刚生成的请求体
            headers = {                                                     -- 标注内容类型是 OCSP
                ["Content-Type"] = "appplication/ocsp-request",
            }
        })
        if err then
            ngx.log(ngx.ERR, "请求 OCSP 失败", err)
            return
        end
        ocsp_resp = res.body                                              -- 获取响应体
        if ocsp_resp and #ocsp_resp > 0 then
            -- 响应体必须是有效的
            ok, err = ocsp.validate_ocsp_response(ocsp_resp, der_cert)    -- 验证 OCSP 的返回结果
            if not ok then
                ngx.log(ngx.ERR, "failed to validate: ", err)
                ngx.exit(ngx.ERROR)
            end
        end
        cache:set(sni, b64.encode_base64url(ocsp_resp))
    else
        ocsp_resp, err = b64.decode_base64url(finalRes)
        if not ocsp_resp then
            ngx.log(ngx.ERR, err)
            return
        end
        ngx.log(ngx.ERR,"许弘毅调试,复用ocsp")
    end
    ok, err = ocsp.set_ocsp_status_resp(ocsp_resp)
    if not ok then
        ngx.log(ngx.ERR, "failed to set: ", err)
        ngx.exit(ngx.ERROR)
    end
end ;