 -- https://github.com/luau-lang/luau/blob/master/fuzz/basic.lua
local function test(t)
	for k,v in pairs(t) do
		print(k,v)
	end
end

test({a = 1})

--[[
more comment
]]
