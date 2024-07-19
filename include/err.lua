local ffi = require('ffi')

ffi.cdef[[
char *strerror(int errnum);
]]

local function err(message, errno)
  local err_msg = ffi.C.strerror(errno)
  if message then
    print(
      ("Messgage: %s | Errno: %s"):format(
        message,
        ffi.string(err_msg)
      )
    )
  else
    print(
      ("Errno: %s"):format(ffi.string(err_msg))
    )
  end
end

return err