-- Copyright (C) idevz (idevz.org)


local setmetatable = setmetatable
local cluster = require "motan.cluster"
local singletons = require "motan.singletons"

local _M = {
    _VERSION = '0.0.1'
}

local mt = {__index = _M}

function _M.new(self, ref_url_obj)
    local cluster_obj = cluster:new(ref_url_obj)
    cluster_obj:init()
    local client = {
        url = ref_url_obj, 
        cluster = cluster_obj, 
        response = {}
    }
    return setmetatable(client, mt)
end

-- @TODO 500 Call ERR
local _do_call
_do_call = function(self, fucname, ...)
    local protocol = singletons.motan_ext:get_protocol(self.url.protocol)
    local req = protocol:make_motan_request(self.url, fucname, ...)
    self.response = self.cluster:call(req)
    if self.response:get_exception() ~= nil then
        return nil, self.response:get_exception()
    end
    return self.response.value
end

setmetatable(_M, {__index = function(self, fucname)
    local method = 
    function (self, ...)
        return _do_call(self, fucname, ...)
    end
    _M[fucname] = method
    return method
end})

return _M
