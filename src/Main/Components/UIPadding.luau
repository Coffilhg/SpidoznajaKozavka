--!strict
--!optimize 2

const Vide = require(`../../Packages/Vide`)
const C = Vide.create

--- Default Padding ---
local Padding = UDim.new(0, 12)

local function toUDim(v: UDim | number)
	if typeof(v) == "UDim" then
		return v
	end

	if type(v) ~= "number" then
		return Padding
	end
	
	if math.isnan(v) or not math.isfinite(v) then
		return Padding
	end

	return UDim.new(0, v)
end

local cbs = {
	["0"] = function()
		return Padding, Padding, Padding, Padding
	end,
	["1"] = function(padding)
		local p = toUDim(padding[1])
		return p, p, p, p
	end,
	["2"] = function(padding)
		local xp = toUDim(padding[2])
		local yp = toUDim(padding[1])
		return yp, xp, yp, xp
	end,
	["3"] = function(padding)
		local xp = toUDim(padding[2])
		return toUDim(padding[1]), xp, toUDim(padding[3]), xp
	end,
	["4"] = function(padding)
		return toUDim(padding[1]), toUDim(padding[2]), toUDim(padding[3]), toUDim(padding[4])
	end,
}

local function normalizePadding(p : ({[number]: number | UDim} | {}))
	p = p or {}

	local t, r, b, l = cbs[`{math.min(#p, 4)}`](p)

	return {
		PaddingTop = t,
		PaddingRight = r,
		PaddingBottom = b,
		PaddingLeft = l,
	}
end

-- Write your paddingin a css like way
return function(
	PaddingOptions: ({[number]: number | UDim} | {})
): UIPadding
	return (C :: any)("UIPadding")(normalizePadding(PaddingOptions))  :: UIPadding
end