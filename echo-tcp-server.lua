--- Простой синхронный tcp echo сервер
--
local ffi = require('ffi')
local _ = require('include.ffi-socket')
local const = require('include.posix-const')
local escape_controls = require('include.escape-controls')
local err = require('include.err')

local BUFSIZE = 1024
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

local buf = ffi.new('char[?]', BUFSIZE)
local remote = ffi.new('struct sockaddr_in')

while true do
  local address_len = ffi.new('socklen_t[1]', ffi.sizeof(remote))
  local conn_fd = ffi.C.accept(server_fd, ffi.cast('struct sockaddr *', remote), address_len)
  if conn_fd == -1 then
    err(nil, errno())
    goto continue
  end

  print(
    ('Accept %s:%d'):format(
      ffi.string(C.inet_ntoa(remote.sin_addr)),
      remote.sin_port
    )
  )


  -- Установка таймаута соединению на 5 секунд
  local timeout = ffi.new('struct timeval')
  timeout.tv_sec = 5
  timeout.tv_usec = 0
  if C.setsockopt(conn_fd, 1, 20, ffi.cast('const void *', timeout), ffi.sizeof(timeout)) < 0 then
    err('setsockopt', errno())
    C.close(conn_fd)
    goto continue
  end

  -- Чтение данных с клиента
  local total_read = 0
  local data = ''
  while true do
    local nread = C.read(conn_fd, buf + total_read, BUFSIZE)

    if nread == -1 then
      err('recv. Close connection', errno())
      C.close(conn_fd)

      goto continue
    elseif nread == 0 then
      print('Клиент закрыл соединение')
      C.close(conn_fd)

      goto continue
    end

    total_read = total_read + nread
    print('total_read', total_read)
    print('nread', nread)
    data = data .. ffi.string(buf, nread)

    -- Предполагаем, что данные были прочитаны
    -- и не отправлены по частям
    -- т.к не отправляем какую либо последовательность символов для завершения
    if nread < BUFSIZE then
      break
    end
  end

  print('Данные от клиента:')
  print(escape_controls(data))

  -- Отправка прочитанных данных клиенту
  local total_send = 0
  while total_send < total_read do
    local send_data = data:sub(total_send + 1, total_send + 1 + BUFSIZE - 1)
    local nsend = C.send(conn_fd, send_data, #send_data, 0)

    if nsend == -1 then
      err('send. Close connection', errno())
      C.close(conn_fd)
      goto continue
    end

    total_send = total_send + tonumber(nsend)
  end

  C.close(conn_fd)

  ::continue::
end

C.close(server_fd)
