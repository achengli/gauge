local function demo(file_name)
  file_name = file_name .. (file_name:match('%.lua$') and '' or '.lua')
  local fc = io.open(file_name, 'r')
  if not fc then
    file_name = file_name .. '/init.lua'
  end
  fc = fc or io.open(file_name, 'r')
  if not fc then
    error('demo has problems opening ' .. file_name ..' file')
  end

  local _demos = {}
  local st = 0
  local _demo = ''

  for line in fc:lines('L') do
    if st == 0 then
      if line:match('^--!demo') then
        st = 1
      end
    else
      if line:match('^--!') and not line:match('^--!demo') then
        local pline = line:gsub('^--! *','')
        _demo = _demo .. pline
      else
        table.insert(_demos,_demo)
        _demo = ''
        st = line:match('^--!demo') and 1 or 0
      end
    end
  end
  fc:close()


  for idx,_demo_block in ipairs(_demos) do
    local f = io.open(file_name,'r')
    if not f then
      error('demo failed opening '..file_name..' file')
    end

    local _file_content = f:read('a')
    f:close()
    local strchunk = _file_content .. '\n' .. _demo_block

    print(string.format('demo %d',idx))
    print(strchunk)

    local chunk = load(strchunk, 't')
    if not chunk then
      print(string.format('demo %d raised an error',idx))
      goto cont
    end
    local ok,_ = pcall(chunk)
    if not ok then
      print(string.format('demo %d raised an error',idx))
    end
    ::cont::
  end
end
--!demo
--! x = function(x)
--! print ('-->',x)
--! end
--! x(10)

local function modelo(p)
  return 10 + p
end

--!demo
--! print(modelo(12))


return {
  demo = demo
}
