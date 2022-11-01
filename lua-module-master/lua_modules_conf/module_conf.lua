--[[*************************************************************************
     > File Name: module_conf.lua
     > Author: dongyu
     > Mail: yu.dong@sinobbd.com
**************************************************************************]]

local modules = require "process_module.lua_module_master_modules";

local conf_modules = {
    {
        enable = true,
        module = modules.hello_body, -- 该配置来自: /process_module/lua_module_master_modules.lua 中的 module hello_body
        config_name = "hello_body_config",
        module_dir = "/usr/local/openresty/nginx/lua_modules/modules/hello_body_module/",   --
    },
    {
        enable = true,
        module = modules.req_version,
        config_name = "req_version_config",
        module_dir = "/usr/local/openresty/nginx/lua_modules/modules/req_version_module/",   --
    },
    {
        enable = true,
        module = modules.loadstring,
        config_name = "loadstring_config",
        module_dir = "/usr/local/openresty/nginx/lua_modules/modules/loadstring_module/",   --
    },
}

return conf_modules;
