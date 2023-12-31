-- gauge.lua
-- Author: Yassin Achengli <achengli@github.com>
-- Description: Port of demo and test functions from GNU Octave
-- License: GPLv3 `See the LICENSE file`

local func = require'functional'

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

--- Check if a file exists in the path passed in `file_name`.
--- 
--- @param file_name string
--- @return boolean
local __file_exist = function (file_name)
  local f = io.open(file_name,'r')
  if f then f:close() return true else return false end
end

-- Alias to shorten the `string.format` function.
local f = string.format

--- Get all the lines from a file descriptor `fd` and return them into a table list.
---
--- If count is `nil` then it will read from lines. If from is `nil` then will read
--- the full file from the file pointer to the end of file.
--- 
--- @param fd file*
--- @param from? integer # From which line will start reading
--- @param count? integer # How many lines will read.
--- @return table
local _file_lines = function (fd, from,count)
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
--- recovers those source code sections which begins with *--!*`prefix` like the following
--- example.
--- 
--- @example
--- --!prefix
--- --! print("Source code that will be executed by blocks")
--- @end example
--- 
--- After finding a block, it will mark in the console which one is executed in ascending
--- order and then depending of the passed parameters will show the output or not, or will 
--- return which one fails and wich succeed (`results` and `silent` parameters).
local function __gauge_executor(file_name, prefix, silent, results)

  file_name = file_name .. (file_name:match('%.lua$') and '' or '.lua')
  prefix = prefix or 'demo'

  file_name = __file_exist(file_name) and file_name or (file_name .. '/init.lua')

  local _code_section_to_execute = ''
  local _total_test_passed = 0
  local _total_test_failed = 0
  local _mealy_state = 0

  local _file_raw_text = __with_open_file (file_name, func.lambda [[(f,r) f:read('a')]])

  __with_open_file(file_name, function(fd,_)
    for count, line in ipairs(_file_lines(fd)) do
      if _mealy_state == 0 then
        if line:match(f('^--!%s *\n', prefix)) then
          print(f('(!) %s %d:',prefix, count))
          _code_section_to_execute = ''
          _mealy_state = 1
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
          local r = load(f("%s%s%s", _file_raw_text, '\n', _code_section_to_execute))
          if r then r()
          else print(f("%s error at pcall", prefix) .. type(r))
          end
        end)
        _total_test_passed = (ok and _total_test_passed + 1 or _total_test_passed)
        _total_test_failed = (ok and _total_test_failed or _total_test_failed + 1)

        if line:match('--!test *\n') then
          print(string.format('(!) test %d:',count))
          _code_section_to_execute = ''
          _mealy_state = 1
        end
      end
    end
  end)

  if _mealy_state == 1 then
    local ok,_ = pcall(function()
      local r = load(_file_raw_text .. '\n' .. _code_section_to_execute)
      if r then r()
      else print("test chunk could not be executed because is a " .. type(r))
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
--- --
--- @param file_name string
--- @param silent? boolean # Default nil
local function demo(file_name, silent)
  __gauge_executor(file_name, 'demo', silent, false)
end

--- Eval all the test comments in `file_name` source file. The comments must
--- start with *"--!test"* and each test line must start with *"--!"*
--- After each test was evaluated, will show the passed and failed tests.
--- -- 
--- @param file_name string
--- @param silent? boolean # Default nil
--- @return integer,integer
local function test(file_name, silent)
  return __gauge_executor(file_name, 'test', silent, true)
end

return {
  VERSION = '1.0.1-2',
  AUTHOR = 'Yassin Achengli <achengli@github.com>',
  DESCRIPTION = [[
  Gauge is a Lua library that aims to be the pure Lua port of demo and test functions from 
  GNU Octave.]],
  NAME = 'Gauge',
  ID = '568658dc-e27c-47f7-8893-7f00a9791705',
  test = test,
  demo = demo,
}
