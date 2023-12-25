-- gauge.lua
-- Author: Yassin Achengli <achengli@github.com>
-- Description: Port of demo and test functions from GNU Octave
-- License: GPLv3 `See the LICENSE file`

--- Eval all the demo doc comments in `file_name` source file. The comments must
--- start with `--!demo` and each demo line must start with `--!`.
--- --
--- @param file_name string
local function demo(file_name)
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
  local st = 0 local count = 0
  local content = f:read("a")
  f:seek('set',0)

  for line in f:lines('L') do
    if st == 0 then
      if line:match('^--!demo *\n') then
        count = count + 1
        print(string.format('(!) demo %d:',count))
        chunk = ''
        st = 1
      end
    elseif st == 1 then
      if line:match('^--! *') then
        local l = line:gsub('^--! *','')
        chunk = chunk .. '\n' .. l
      else
        st = 2
      end
    elseif st == 2 then
      st = 0
      pcall(function()
        local r = load(content .. '\n' .. chunk)
        if r then
          r()
        else
          print(string.format("demo %d could not be executed because is a ",count) .. type(r))
        end
      end)

      if (line:match('^--!demo *\n')) then
        count = count + 1
        print(string.format('(!) demo %d:',count))
        chunk = ''
        st = 1
      end

    end
  end

  if st == 1 then
    pcall(function()
      local r = load(content .. '\n' .. chunk)
      if r then
        r()
      else
        print("test chunk could not be executed because is a " .. type(r))
      end
    end)
  end
end

--- Eval all the test comments in `file_name` source file. The comments must
--- start with `--!test` and each test line must start with `--!`.
--- After each test was evaluated, will show the passed and failed tests.
--- --
--- @param file_name string
--- @param silent? boolean # Default nil
--- @return integer,integer
local function test(file_name, silent)
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
  local st = 0 local count = 0
  local content = f:read("a")
  f:seek('set',0)

  for line in f:lines('L') do
    if st == 0 then
      if line:match('^--!test *\n') then
        count = count + 1
        print(string.format('(!) test %d:',count))
        chunk = '' st = 1
      end
    elseif st == 1 then
      if line:match('^--! *') then
        local l = line:gsub('^--! *','')
        chunk = chunk .. '\n' .. l
      else
        st = 2
      end
    elseif st == 2 then
      st = 0
      local ok, _ = pcall(function()
        local r = load(content .. '\n' .. chunk)
        if r then
          r()
        else
          print("test chunk could not be executed because is a " .. type(r))
        end
      end)
      passed = (ok and passed + 1 or passed)
      failed = (ok and failed or (failed + 1))

      if line:match('--!test *\n') then
        count = count + 1
        print(string.format('(!) test %d:',count))
        chunk = ''
        st = 1
      end
    end
  end

  if st == 1 then
    local ok, _ = pcall(function()
      local r = load(content .. '\n' .. chunk)
      if r then
        r()
      else
        print("test chunk could not be executed because is a " .. type(r))
      end
    end)
    passed = (ok and passed + 1 or passed)
    failed = (ok and failed or (failed + 1))
  end
  if not silent then
    print(string.format('\n* passed: %d',passed))
    print(string.format('* failed: %d',failed))
  end
  return passed, failed
end

return {
  demo = demo,
  test = test
}
