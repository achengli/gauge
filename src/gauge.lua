local function demo(file_name, items)

  file_name = file_name .. (file_name:match('%.lua$') and '' or '.lua')
  local f = io.open(file_name, 'r')
  if not f then
    file_name = file_name .. '/init.lua'
  end
  f = f or io.open(file_name, 'r')
  if not f then
    error('demo has problems opening ' .. file_name ..' file')
  end

  local chunk = ''
  local count = 0
  for line in f:lines('L') do
    if line:match('^--!demo *\n') then
      count = count + 1
      line = line:gsub('^--!demo *\n',string.format('print(">> demo %d")\n',count),count)
      chunk = chunk .. line
    else
      line = line:gsub('^--! *','')
      chunk = chunk .. line
    end
  end
  f:close()

  local c = load(chunk,'t')
  if c then
    c()
  else
    print('demo raised an error')
  end
end

--!demo 
--! print('demo done')

local function test(file_name)

  file_name = file_name .. (file_name:match('%.lua$') and '' or '.lua')
  local f = io.open(file_name, 'r')
  if not f then
    file_name = file_name .. '/init.lua'
  end
  f = f or io.open(file_name, 'r')
  if not f then
    error('demo has problems opening ' .. file_name ..' file')
  end

  local chunk = '' local passed = 0 local failed = 0

  for line in f:lines('L') do
    if line:match('^--!test *\n') then
    elseif line:match('^--! *') then
    else
      chunk = ''
    end
  end
end

return {
  demo = demo,
  test = test
}
