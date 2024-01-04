-- gauge.lua
-- Author: Yassin Achengli <achengli@github.com>
-- Description: Port of demo and test functions from GNU Octave
-- License: GPLv3 `See the LICENSE file`

--- Macro from common lisp. Lets you interact with `file_name` without worrying about 
--- the descriptor.
--- 
--- @param file_name string
--- @param fc function # Functional callback
--- @return any
local __with_open_file = function(file_name, fc)
  local r = nil
  local f = io.open(file_name, 'r')
  if not f then error("with_open_file file descriptor") end
  do r = fc(f,r) end
  f:close()
  return r
end

--- Check if the file mentioned by the `file_name` path exist.
--- 
--- @param file_name string
--- @return boolean
local __file_exist = function (file_name)
  local f = io.open(file_name,'r')
  if f then f:close() return true else return false end
end

--- Alias to shorten the `string.format` function.
local f = string.format

--- Get lines from the file descriptor (`fd`) and group them into a table list.
---
--- If count is `nil` then it will read `from` lines. If `from` is `nil` then it 
--- will read the full file starting from the file descriptor pointer until the 
--- end of the file.
--- 
--- @param fd file*
--- @param from? integer # From which line will start reading
--- @param count? integer # How many lines will read.
--- @return table
local __file_lines = function (fd, from,count)
  if (not count and from) then count = from; from = 0 end
  local lines = {}
  local counter = 0
  for i in fd:lines('L') do
    if (not from or (counter > from and counter < from + count)) then
      table.insert(lines,i)
      counter = counter + 1
    end
  end
  return lines
end

--- Generic function that builds *demo* and *test* exported functions. This function
--- recovers the source code sections which begins with *--!*`prefix` like the following
--- example.
--- 
--- ## Usage
--- --!prefix
--- --! print("Source code that will be executed by blocks")
--- __gauge_executor('./mydemofile.lua', 'prefix', false, true)
--- 
--- After finding a block, it will mark in the console which one is executed in ascending
--- order and then depending of the passed parameters will show the output or not, or will 
--- return which one fails and wich succeed (`results` and `silent` parameters).
--- 
--- @param file_name string
--- @param prefix string
--- @param silent? boolean
--- @param results? boolean
--- @return integer, integer | nil
local function __gauge_executor(file_name, prefix, silent, results)

  file_name = file_name .. (file_name:match('%.lua$') and '' or '.lua')
  prefix = prefix or 'demo'

  file_name = __file_exist(file_name) and file_name or (file_name .. '/init.lua')

  local _code_section_to_execute = ''
  local _to_probe_code_segment = ''
  local _total_test_passed = 0
  local _total_test_failed = 0
  local _mealy_state = 0
  local _count = 0

  print(f("\n~ %s of %s file\n---", prefix, file_name))
  __with_open_file(file_name, function(fd,_)
    for _, line in ipairs(__file_lines(fd)) do

      if (not line:match('^--')) then
        _to_probe_code_segment = _to_probe_code_segment .. line
      end

      if _mealy_state == 0 then
        if line:match(f('^--!%s *\n', prefix)) then
          print(f('\n(!) %s %d',prefix, _count))
          _code_section_to_execute = ''
          _mealy_state = 1
          _count = _count + 1
        end
      elseif _mealy_state == 1 then
        if line:match('^--! *') then
          local l = line:gsub('^--! *','')
          _code_section_to_execute = f("%s%s%s", _code_section_to_execute, '\n', l)
        else
          _mealy_state = 2
        end
      elseif _mealy_state == 2 then
        _mealy_state = 0
        local ok, _ = pcall(function()
          local r = load(f("%s%s%s", _to_probe_code_segment, '\n', _code_section_to_execute))
          if r then r()
          else print(f("%s error at pcall", prefix))
          end
        end)
        _total_test_passed = (ok and _total_test_passed + 1 or _total_test_passed)
        _total_test_failed = (ok and _total_test_failed or _total_test_failed + 1)

        if line:match(f('--!%s *\n', prefix)) then
          print(f('(!) %s %d', prefix, _count))
          _code_section_to_execute = ''
          _mealy_state = 1
        end
      end
    end
  end)

  if _mealy_state == 1 then
    local ok,_ = pcall(function()
      local r = load(_to_probe_code_segment .. '\n' .. _code_section_to_execute)
      if r then r()
      else print(f("%s error at pcall", prefix))
      end
    end)
    _total_test_passed = (ok and _total_test_passed + 1 or _total_test_passed)
    _total_test_failed = (ok and _total_test_failed or _total_test_failed + 1)
  end

  if (not silent) then
    print(string.format('\n* passed: %d',_total_test_passed))
    print(string.format('* failed: %d',_total_test_failed))
  end

  if results then
    return _total_test_passed, _total_test_failed
  end
end

--- Eval all the demo doc comments in `file_name` source file. The comments must
--- start with *"--!demo"* and each demo line must start with *"--!"*.
---
--- @param file_name string
--- @param silent? boolean # Default true
--- @return nil
local function demo(file_name, silent)
  if silent == nil then silent = true end
  __gauge_executor(file_name, 'demo', silent, false)
end
--!demo
--! package.path = package.path .. ';../test/?.lua'
--! print'Demonstration of demo function'
--! local gauge = require'gauge'
--! gauge.demo('../test/lo.lua')

--- Eval all the test comments in `file_name` source file. The comments must
--- start with *"--!test"* and each test line must start with *"--!"*
--- After each test was evaluated, will show the passed and failed tests.
---
--- @param file_name string
--- @param silent? boolean # Default nil
--- @return nil|integer,integer
local function test(file_name, silent)
  silent = (silent == nil) and false or true
  return __gauge_executor(file_name, 'test', silent, true)
end
--!test
--! package.path = package.path .. ';../test/?.lua'
--! print("Demonstration of test function")
--! local gauge = require'gauge'
--! gauge.test('../test/lo.lua')

return {
  VERSION = '1.1',
  AUTHOR = 'Yassin Achengli <achengli@github.com>',
  DESCRIPTION = [[
  Gauge is a Lua library that aims to be the pure Lua port 
  of demo and test functions from GNU Octave.
  ]],
  NAME = 'Gauge',
  ID = '568658dc-e27c-47f7-8893-7f00a9791705',
  test = test,
  demo = demo,
  gauge_gen = __gauge_executor,
}
