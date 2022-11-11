--[[*************************************************************************
     > File Name: module_conf.lua
     > Author: dongyu
     > Mail: yu.dong@sinobbd.com
**************************************************************************]]

local modules = require "process_module.lua_module_master_modules";

local conf_modules = {
    {
        enable = true,
        module = modules.req_version,
        config_name = "req_version_config",
        module_dir = "/usr/local/openresty/nginx/lua_modules/modules/basic/req_version_module/",   --
    },
    {
        enable = true,
        module = modules.chash_balancer,
        config_name = "chash_balancer_config",
        module_dir = "/usr/local/openresty/nginx/lua_modules/modules/basic/chash_balancer_module/",   --
    },
    {
        enable = true,
        module = modules.core_origin,
        config_name = "core_origin_config",
        module_dir = "/usr/local/openresty/nginx/lua_modules/modules/basic/core_origin_module/",   --
    },
}

return conf_modules;
