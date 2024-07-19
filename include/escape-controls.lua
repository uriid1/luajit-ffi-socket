local special = {
  [7]  = 'a',
  [8]  = 'b',
  [9]  = 't',
  [10] = 'n',
  [11] = 'v',
  [12] = 'f',
  [13] = 'r',
}

local controls = {}
for i = 0, 31 do
  local c = special[i]
  if not c then
    if i < 10 then
      c = "00" .. tostring(i)
    else
      c = "0" .. tostring(i)
    end
  end

  controls[i] = tostring('\\' .. c)
end

controls[92] = tostring('\\\\')
controls[34] = tostring('\\"')
controls[39] = tostring("\\'")

for i = 128, 255 do
  local c
  if i < 100 then
    c = "0" .. tostring(i)
  else
    c = tostring(i)
  end

  controls[i] = tostring('\\' .. c)
end

local function stringEscape(char)
  return controls[string.byte(char, 1)]
end

local function escape_controls(str)
  local res, _ = string.gsub(str, '[%c\\\128-\255]', stringEscape)
  return res
end

return escape_controls
