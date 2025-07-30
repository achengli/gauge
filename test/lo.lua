-- demonstration file

local function lo(la0)
  if type(la0) == 'number' then
    return la0+1
  else
    error('usage: lo(la0:integer)')
  end
end

--!test
--! print(lo(102)) -- 103

--!test
--! print(lo(23)) -- error

--!demo
--! function diff(f,x0)
--! return (f(x0+0.0001) - f(x0))/0.0001
--! end
--! print(diff(function(x) return (x^2- 3.2*x) end, 0.5))

--!demo
--! print("hello")
