# Gauge.lua

Gauge is a *Lua* library that aim to be the pure Lua port of demo and test functions
from [GNU Octave](https://octave.org).

This library could be used to eval and debug your lua software writing demos in comment
blocks or your tests also.

Every test and demo will be enumerated giving a visual way for research the location
of your blocks.

## Example

Demo and test functions should be used out from your target file which you will probe.

```lua
-- file: lo.lua
function lo(la0)
    if (type(la0) == 'number') then
        return la0 + 1
    end
    error('la0 must be integer')
end

--!test
--! lo(102) -- 103
--! lo('string') -- error

--!demo
--! print(lo(102))
```

To eval the demonstration block code you can type
```lua
local demo = require'gauge'.demo
demo('./lo.lua')
```

And for the test block code
```lua
local test = require'gauge'.test
test('./lo.lua')
```
