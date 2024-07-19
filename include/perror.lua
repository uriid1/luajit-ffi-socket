local serr = require('include.serr')

local function perror(message)
  if message then
    io.stderr:write(
      ('Error: %s Errno: %s\n'):format(
        message,
        serr()
      )
    )
    return
  end

  io.stderr:write(('Errno: %s\n'):format(serr()))
end

return perror
