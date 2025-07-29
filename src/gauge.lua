-- gauge.lua
-- ---
-- Copyright (C) BY-NC 2023-2025 Yassin Achengli 
-- This source file follows the GPLv3 license terms.

--- Macro inspired from Common Lisp. Easy file access. 
--- @param file_name string
--- @param map_function function # Functional callback
--- @return any
local with_file_lines = function(file_path, map_function)
  local f = io.open(file_path, 'r')
  local ctx = nil

  for line in f:lines('L') do
    ctx = map_function(string.gsub(line, '\n', ''), ctx)
  end

  f:close()
  return ctx
end

--- Clean comment sections in lua code.
---
--- @param line string
--- @return string
local clean_comments = function(line)
  return string.gsub(line, '%-%-.*$', '') or ''
end

local trim = function(str)
  str = string.gsub(str,'^ +', '')
  str = string.gsub(str,' +$', '')
  return str
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
--- @param file_path string
--- @param f_macro function
--- @param f_source function
--- @param header_name string
--- @param ctx? any
--- @return any
local executor = function(file_path, f_macro, f_source, header_name, ctx)

  local blocks = {{}}

  local function has_comment(line)
    return string.match(line, '^%-%-!') and true or false
  end

  with_file_lines(file_path, function (line, last_line)
    -- Retrieve source lines in a table as code blocks.
    if #line > 0 and not (string.match(trim(line),'^[%-]+[^!]') and
      not string.match(trim(line), '^[%-]+!')) then
      if string.match(line, string.format('^%%-%%-!%s', header_name))
        or (string.match(last_line, '^%-%-!') and not string.match(line, '^%-%-!')) then
        table.insert(blocks, {line})
      else
        table.insert(blocks[#blocks], line)
      end
    end
    return (#line > 0) and line or last_line
  end)

  local C = nil
  for _, block in pairs(blocks) do
    if block[1] and string.match(block[1], string.format('^%%-%%-!%s', header_name))
      and f_macro then
      table.remove(block, 1)

      C = f_macro(block, ctx)
      if C then
        ctx = C
      end
    elseif block[1] and not string.match(block[1], '^%-%-!') and f_source then
      for i,l in ipairs(block) do
        local clean = clean_comments(l)
        if #clean ~= 0 then
          block[i] = clean
        end
      end

      C = f_source(block, ctx)
      if C then
        ctx = C
      end
    end
  end

  return ctx
end

local demo = function(file_path)
  local string_chunk = ''
  executor(file_path, function(block)
    print('Demo\n~~~')
    for _, line in ipairs(block) do
      line = string.gsub(line, '%-%-! *', '') or line
      string_chunk = string_chunk .. '\n' .. line
    end
    local trigger = nil
    if tonumber(string.match(_VERSION, '[%d]%.[%d]')) >= 5.2 then
      trigger = load(string_chunk, 'A')
    else
      trigger = loadstring(string_chunk, 'A')
    end

    if trigger then
      trigger()
    end
  end, function(block)
    for _, line in ipairs(block) do
      line = string.gsub(line, '^%-%-! +', '')
      string_chunk = string_chunk .. '\n' .. line
    end

    local trigger = nil

    if tonumber(string.match(_VERSION, '[%d]%.[%d]')) >= 5.2 then
      trigger = load(string_chunk, 'B')
    else
      trigger = loadstring(string_chunk, 'B')
    end

    if trigger then
      trigger()
    end
  end, 'demo')
end

local test = function(file_path)
  local ctx = executor(file_path, function(block, ctx)
      local string_chunk = ''
      if not ctx then
        ctx = {passed = 0, failed = 0}
      end

      for _, line in ipairs(block) do
        line = string.gsub(line, '^%-%-! *', '')
        string_chunk = string_chunk .. '\n' .. line
      end

      local trigger = nil

      if tonumber(string.match(_VERSION, '[%d]%.[%d]')) >= 5.2 then
        trigger = load(string_chunk, 'A')
      else
        trigger = loadstring(string_chunk, 'A')
      end

      if trigger then
        if pcall(trigger) == true then
          ctx.passed = ctx.passed + 1
        else
          ctx.failed = ctx.failed + 1
        end
      end
      print(ctx.passed, ctx.failed)
      return ctx
    end, function(block)
    local string_chunk = ''
    for _, line in ipairs(block) do
      string_chunk = string_chunk .. '\n' .. line
    end

    local trigger = nil

    if tonumber(string.match(_VERSION, '[%d]%.[%d]')) >= 5.2 then
      trigger = load(string_chunk, 'B')
    else
      trigger = loadstring(string_chunk, 'B')
    end

    if trigger then
      trigger()
    end
  end, 'test', {passed=0, failed=0})

  if ctx.passed > 0 and ctx.failed > 0 then
    print('Test\n~~~')
    print(string.format('Test passed/failed: %d/%d', ctx.passed, ctx.failed))
  end
end

return {
  VERSION = '1.1',
  AUTHOR = 'Yassin Achengli <achengli@github.com>',
  DESCRIPTION = [[
  Gauge is a Lua library that aims to be the pure Lua port 
  of demo and test functions from GNU Octave.
  ]],
  NAME = 'Gauge',
  ID = '568658dc-e27c-47f7-8893-7f00a9791705',
  executor = executor,
  with_file_lines = with_file_lines,
  demo = demo,
  test = test,
}
