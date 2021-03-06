--[[
License:
http://opensource.org/licenses/MIT

Copyright (c) 2013 Andida Syahendar

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), 
to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, 
sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

]]--
-- To know more about lua-websockets, see https://github.com/lipp/lua-websockets
-- To know more about middleclass, see https://github.com/kikito/middleclass

require 'middleclass'

local WSock = class('WSock')

function WSock:initialize (port, timeout)
  self.port = port
  self.timeout = timeout
  self.protocols = {}
  return self
end

function WSock:httpHandler (handler)
  self.httpHandlerFunction = handler
  return self
end

function WSock:ssl (cert, privKey)
  self.sslCert = cert
  self.sslPrivKey = privKey
  return self
end

function WSock:user (uid, guid)
  self.uid = uid
  self.guid = guid
  return self
end

function WSock:newProtocolHandler (protocol, handler)

  if(type(protocol) == 'string' and type(handler) == 'function') then

    self.protocols[protocol] = handler

  elseif(type(protocol) == 'table' and type(handler) == 'nil') then

    self.protocols = protocol

  else

    error('Invalid argument(s).')

  end

  return self
end

function WSock:start ()
  print('Websocket server listening on port ' .. self.port)

  self.socket = require 'websockets'

  if(type(self.httpHandlerFunction) ~= 'function') then
    self.httpHandlerFunction = nil
  end

  if(type(self.uid) ~= 'number') then
    self.uid = nil
  end

  if(type(self.guid) ~= 'number') then
    self.guid = nil
  end

  if(type(self.sslCert) ~= 'string') then
    self.sslCert = nil
  end

  if(type(self.sslPrivKey) ~= 'string') then
    self.sslPrivKey = nil
  end

  local context = self.socket.context({
    on_http = self.httpHandlerFunction,
    uid = self.uid,
    guid = self.guid,
    ssl_cert_path = self.sslCert,
    ssl_private_key_path = self.sslPrivKey,
    port = self.port,
    protocols = self.protocols
  })

  while true do
    context:service(self.timeout)
  end
end

return WSock