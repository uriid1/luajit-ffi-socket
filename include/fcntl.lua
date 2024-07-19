local ffi = require('ffi')
local bit = require('bit')
local const = require('posix-const')

ffi.cdef[[
int fcntl(int fd, int cmd, int arg);
]]

local function setnonblocking(fd)
  local flags = ffi.C.fcntl(fd, const.F_GETFL, 0)
  if flags == -1 then
    return -1
  end

  flags = bit.bor(flags, const.O_NONBLOCK)

  local res = ffi.C.fcntl(fd, const.F_SETFL, flags)
  if res == -1 then
    return -1
  end

  return true
end

return {
  setnonblocking = setnonblocking
}