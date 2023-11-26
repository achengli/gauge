package = 'gauge'
version = '1.0-1'
source = {
  url = 'git+https://github.com/achengli/gauge.git'
}
description = {
  detailed = [[
  ]],
  homepage = 'https://github.com/achengli/gauge',
  license = 'GPLv3',
}
build = {
  type = 'builtin',
  modules = {
    gauge = 'src/gauge.lua',
  }
}
