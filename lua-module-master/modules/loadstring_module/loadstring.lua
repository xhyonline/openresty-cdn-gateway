local _M = { _VERSION = '0.01' }
local ngx = ngx;
local foo = require("foo")
-- TODO 此处待处理全局变量无法更新的问题,需要引入一种通知机制,在局部变量中更新该全局
function _M.loadstring_handle(conf)
    foo:run()
end

return _M;

