local ffi = require('ffi')

ffi.cdef[[
char *strerror(int errnum);
]]

local function err()
  return ffi.string(ffi.C.strerror(ffi.errno()))
end

return err
