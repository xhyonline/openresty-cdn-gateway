--[[*************************************************************************
     > File Name: module_conf.lua
     > Author: fishgege
     > Mail: yu.dong@sinobbd.com
**************************************************************************]]

--[[
local example  = {
    filename = "example_module.example";  --执行文件位置,example_module为模块文件夹，example为入口文件名
    init          = nil,                  --表示master init阶段处理的handle   init_by_lua_file
    init_worker   = nil;                  --表示worker init阶段处理的handle   init_worker_by_lua_file
    rewrite       = nil,                  --表示rewrite阶段处理的handle       rewrite_by_lua_file
    access        = "access_check",       --表示access阶段处理的handle        access_by_lua_file
    content       = nil,                  --表示content阶段处理的handle       content_by_lua_file
    header_filter = nil,                  --表示header_filter阶段处理的handle header_filter_by_lua_file
    body_filter   = nil,                  --表示body_filter阶段处理的handle   body_filter_by_lua_file
    log           = nil,                  --表示log阶段处理的handle           log_by_lua_file
    balancer      = nil,                  --表示balancer阶段处理的handle      balancer_by_lua_file
}

local modules = {
    ["module"] = example,    --[]中module为模块索引， example为模块名称
    ...
    ...
}
]]


local core_origin_module = {
    filename      = "modules.basic.core_origin_module.core_origin",
    init          = nil,
    init_worker   = nil,
    rewrite       = nil,
    access        = "core_origin",
    content       = nil,
    header_filter = nil,
    body_filter   = nil,
    log           = nil,
    balancer      = nil,
}


-- 处理请求版本号
local req_version_module = {
    filename      = "modules.basic.req_version_module.req_version",
    init          = nil,
    init_worker   = nil,
    rewrite       = nil,
    access        = "req_version_handle",
    content       = nil,
    header_filter = nil,
    body_filter   = nil,
    log           = nil,
    balancer      = nil,
}

local chash_balancer_module = {
    filename      = "modules.basic.chash_balancer_module.chash_balancer",
    init          = nil,
    init_worker   = nil,
    rewrite       = nil,
    access        = nil,
    content       = nil,
    header_filter = nil,
    body_filter   = nil,
    log           = nil,
    balancer      = "chash_balancer",
}






local modules = {
    ["core_origin"]    = core_origin_module,
    ["req_version"]    = req_version_module,
    ["chash_balancer"] = chash_balancer_module,
}


return modules;
