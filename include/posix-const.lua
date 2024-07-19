local const = {
  -- /usr/include/bits/socket.h
  AF_INET = 2, -- Семейство адресов ipV4
  AF_INET6 = 10, -- Семейство адресов ipV6
  SOMAXCONN = 4096,

  -- /usr/include/bits/socket_type.h
  SOCK_STREAM = 1, -- Тип сокета
  SO_REUSEADDR = 2, -- Позволяет переиспользовать адрес и порт

  -- /usr/include/bits/socket-constants.h
  SOL_SOCKET = 1,

  -- /usr/include/bits/fcntl-linux.h
  F_GETFL = 3,
  F_SETFL = 4,
  O_NONBLOCK = 2048, -- 04000

  -- /usr/include/asm-generic/errno.h
  EAGAIN = 11,
  EINTR = 4,
  EPROTO = 71, -- Protocol error
  EWOULDBLOCK = 103,
}

return const
