package.path = package.path .. ';../src/?.lua'

local gauge = require'gauge'
gauge.demo('./lo.lua')
gauge.test('./lo.lua')
