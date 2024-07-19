--- Минимальный пример TCP сервера
--
local ffi = require('ffi')
local _ = require('include.ffi-socket')
local const = require('include.posix-const')
local err = require('include.err')

local HOST = '0.0.0.0'
local PORT = 9000

local sizeof = ffi.sizeof
local errno = ffi.errno
local cast = ffi.cast
local C = ffi.C

local server_fd = C.socket(const.AF_INET, const.SOCK_STREAM, 0)
if server_fd == -1 then
  err('Create socket', errno())
  os.exit(1)
end

local optval = ffi.new('int[1]', 1)
local res = C.setsockopt(server_fd, const.SOL_SOCKET, const.SO_REUSEADDR,
  optval, sizeof(optval)
)
if res == -1 then
  err('setsockopt', errno())
  os.exit(1)
end

local addr = ffi.new('struct sockaddr_in')
addr.sin_family = const.AF_INET
addr.sin_port = C.htons(PORT)
addr.sin_addr.s_addr = C.inet_addr(HOST)

local res = C.bind(server_fd, cast('struct sockaddr *', addr), sizeof(addr))
if res == -1 then
  err('bind', errno())
  os.exit(1)
end

local res = C.listen(server_fd, const.SOMAXCONN)
if res == -1 then
  err('listen', errno())
  os.exit(1)
end

print(('TCP server listen %s:%d'):format(HOST, PORT))

while true do
  local conn_fd = C.accept(server_fd, nil, nil)
  if conn_fd == -1 then
    err(nil, errno())
    break
  end

  local message = 'Hello client!'
  local bytes = C.send(conn_fd, message, #message, 0)
  if bytes == -1 then
    err(nil, errno())
    break
  end

  C.close(conn_fd)
end

C.close(server_fd)
