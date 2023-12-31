-- test of gauge.lua
-- Author: Yassin Achengli <achengli@github.com>

package.path = package.path .. ';../src/?.lua'

local gauge = require'gauge'
gauge.demo('./lo.lua')
gauge.test('./lo.lua')
gauge.demo('../src/gauge.lua')
