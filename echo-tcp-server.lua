--- Простой синхронный tcp echo сервер
--
local ffi = require('ffi')
local _ = require('include.ffi-socket')
local const = require('include.posix-const')
local escape_controls = require('include.escape-controls')
local perror = require('include.perror')

local BUFSIZE = 1024
local HOST = '0.0.0.0'
local PORT = 9000

local sizeof = ffi.sizeof
local cast = ffi.cast
local C = ffi.C

local sd = C.socket(const.AF_INET, const.SOCK_STREAM, 0)
if sd == -1 then
  perror('Create socket')
  os.exit(1)
end

local optval = ffi.new('int[1]', 1)
local res = C.setsockopt(sd, const.SOL_SOCKET, const.SO_REUSEADDR,
  optval, sizeof(optval)
)
if res == -1 then
  perror('setsockopt')
  os.exit(1)
end

local addr = ffi.new('struct sockaddr_in')
addr.sin_family = const.AF_INET
addr.sin_port = C.htons(PORT)
addr.sin_addr.s_addr = C.inet_addr(HOST)

local res = C.bind(sd, cast('struct sockaddr *', addr), sizeof(addr))
if res == -1 then
  perror('bind')
  os.exit(1)
end

local res = C.listen(sd, const.SOMAXCONN)
if res == -1 then
  perror('listen')
  os.exit(1)
end

print(('TCP server listen %s:%d'):format(HOST, PORT))

local buf = ffi.new('char[?]', BUFSIZE)
local remote = ffi.new('struct sockaddr_in')

while true do
  local address_len = ffi.new('socklen_t[1]', sizeof(remote))
  local conn_fd = ffi.C.accept(sd, ffi.cast('struct sockaddr *', remote), address_len)
  if conn_fd == -1 then
    perror()
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
  if C.setsockopt(conn_fd, 1, 20, ffi.cast('const void *', timeout), sizeof(timeout)) < 0 then
    perror('setsockopt')
    C.close(conn_fd)
    goto continue
  end

  -- Чтение данных с клиента
  local total_read = 0
  local data = ''
  while true do
    local nread = C.recv(conn_fd, buf + total_read, BUFSIZE, 0)

    if nread == -1 then
      perror('recv. Close connection')
      C.close(conn_fd)

      goto continue
    elseif nread == 0 then
      print('Клиент закрыл соединение')
      C.close(conn_fd)

      goto continue
    end

    total_read = total_read + nread
    data = data .. ffi.string(buf, nread)

    -- Предполагаем, что данные были прочитаны
    -- и не отправлены по частям
    -- т.к не отправляем какую либо последовательность символов для завершения
    if nread < BUFSIZE then
      break
    end
  end

  print('\nДанные от клиента:')
  print(escape_controls(data))

  -- Отправка прочитанных данных клиенту
  local total_send = 0
  while total_send < total_read do
    local send_data = data:sub(total_send + 1, total_send + 1 + BUFSIZE - 1)
    local nsend = C.send(conn_fd, send_data, #send_data, 0)

    if nsend == -1 then
      perror('send. Close connection')
      C.close(conn_fd)
      goto continue
    end

    total_send = total_send + tonumber(nsend)
  end

  C.close(conn_fd)

  ::continue::
end

C.close(sd)
