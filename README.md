# Gauge.lua

Gauge is a *Lua* library that aims to be the pure Lua port of demo and test functions from [GNU Octave](https://octave.org).

This library can be used for the evaluation and debugging of your Lua source files by writing code inside comment-blocks. This gives you a new way to test the behavior of your source files without needing external test files that increments the project entropy.

Gauge can enumerate each comment-block giving you more feedback to find where will be located possible problems inside the targeted file.

## Installation

You can install Gauge from [luarocks](https://luarocks.org/modules/roskosmosiv37/gauge)

* *It is recommended to install it locally*

```shell
luarocks install -local gauge
```


## Example

Demo and test functions must be used out from your intepreted file to avoid infinite recursion.

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

To evaluate demonstration comment-blocks inside your source files, you can type the following Lua instructions:

```lua
local demo = require'gauge'.demo
demo('./lo.lua')
```

> (!) demo: 1
>
> 103

For your testing comment-blocks you can do:

```lua
local test = require'gauge'.test
test('./lo.lua')
```

> (!) test: 1
>
> * passed: 1
> * failed: 1

To avoid prompts from intepreted comment-blocks you can use the argument `silent` which is a ***boolean*** type variable.

## Future projections

Gauge has some ways to enhance the behavior to ensure better manageability of the developer and to give a better presentation of the results.

- [ ] Write a more general documentation for new interpreters which are done from the behavior of the main function *See **__gauge_executor** function in [__gauge_executor:src/gauge.lua](https://github.com/achengli/gauge/blob/main/src/gauge.lua#L73)*
- [ ] It may be useful to give the chance to colorize the console output.
- [ ] Have the posibility to decide where Gauge will start to interpret comment-blocks.
- [ ] Parallelize the code flow.
- [ ] Show the interval of lines which are interpreted *(Should be an optional feature activated with `silent` argument)*.

## Contributors

Feel free to give new ideas, modifications and critics; I will apreciate them very much!

### Enjoy!
