# Gauge.lua

Gauge is a *Lua* library that aims to be the pure Lua port of demo and test functions
from [GNU Octave](https://octave.org).

This library can be used to eval and debug your Lua software writing demonstrations 
inside comment blocks on your source file. Also brings you the way to test your 
sofware functionality.

Each test and demo block will be enumerated giving a visual way for research the 
location of your blocks inside the file.

## Example

Demo and test functions must be used out from your target file which you will probe.

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

--!test
--! lo('string') -- error

--!demo
--! print(lo(102))
```

To eval the demonstration block code you can type
```lua
local demo = require'gauge'.demo
demo('./lo.lua')
```

> (!) demo: 1
>
> 103

And for the test block code
```lua
local test = require'gauge'.test
test('./lo.lua')
```
> (!) test: 1
>
> * passed: 1
> * failed: 1

## Future projections

Gauge has some ways to enhance the behavior to ensure better manageability of the developer and
to give a better presentation of the results.

- [ ] Set a general doc interpreter for new custom builds from the developer who uses this library.
- [ ] Include some colors for the output.
- [ ] Posibility to select which point on the file will be the beginning.
- [ ] Parallelize the source.

## Contributors

Feel free to give new ideas, modifications and critics, I will apreciate them very much!
