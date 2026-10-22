--!strict
--!optimize 2

-- This script is an improved version of an example on devforum at:
-- https://devforum.roblox.com/t/your-name-color-in-chat-%E2%80%94-history-and-how-it-works/2702247
-- more precisely here:
-- https://devforum.roblox.com/t/how-to-get-a-users-default-chat-colour-simple-module/957515/1
-- Improved & Added Gradients by @Coffilhg (Roblox UserId 517222346)
-- Use this however you want; The gradient variants don't all exactly match the usual chat colors!

-- This module has first ever become public with SpidoznajaKozavka's V0.0.0 release. The gradients were invented in the middle (Summer) of 2025, I think they're pretty cool.
-- This is free and unencumbered software released into the public domain. Under the
-- Unlicense license: https://unlicense.org

type NAME_COLORS = {Color3}
type NAME_GRADIENTS = {ColorSequence}

local NAME_COLORS: NAME_COLORS =
	{
		Color3.new(0.992157, 0.160784, 0.262745), -- BrickColor.new("Bright red").Color,
		Color3.new(1/255, 162/255, 255/255), -- BrickColor.new("Bright blue").Color,
		Color3.new(2/255, 184/255, 87/255), -- BrickColor.new("Earth green").Color,
		BrickColor.new("Bright violet").Color,
		BrickColor.new("Bright orange").Color,
		BrickColor.new("Bright yellow").Color,
		BrickColor.new("Light reddish violet").Color,
		BrickColor.new("Brick yellow").Color,
	}
local NAME_GRADIENTS: NAME_GRADIENTS =
	{
		ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 100, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 60, 40)),
		}), -- 1: [Red] Good match
		ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 112, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 255, 223)),
		}), -- 2: [Bright blue] Somewhat matching
		ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(190, 255, 60)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 255, 125)),
		}), -- 3: [Earth green] Good match
		--ColorSequence.new({
		--	ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 255, 223)),
		--	ColorSequenceKeypoint.new(0.435, Color3.fromRGB(60, 180, 255)),
		--	ColorSequenceKeypoint.new(1, Color3.fromRGB(160, 60, 255)),
		--}), -- 3: [Earth green] Not at all matching
		ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 60, 255)),
			ColorSequenceKeypoint.new(0.334, Color3.fromRGB(160, 60, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 112, 255)),
		}), -- 4: [Bright violet] Somewhat matching
		ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 60, 60)),
			ColorSequenceKeypoint.new(0.428, Color3.fromRGB(255, 158, 60)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(67, 255, 60)),
		}), -- 5: [Bright orange] Somewhat matching
		ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(190, 255, 60)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 229, 60)),
		}), -- 6: [Bright yellow] Somewhat matching
		ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(160, 255, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 150, 255)),
		}), -- 7: [Light reddish violet] Not at all matching; But this looks Premium!
		-- the last one for 8: ["Crick Yellow"] can be either
		--ColorSequence.new({
		--	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 60, 60)),
		--	ColorSequenceKeypoint.new(0.428, Color3.fromRGB(255, 158, 60)),
		--	ColorSequenceKeypoint.new(1, Color3.fromRGB(67, 255, 60)),
		--}), -- same as 5
		-- or this one
		ColorSequence.new({
			ColorSequenceKeypoint.new(0, BrickColor.new("Brick yellow").Color),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(253, 255, 133))
		}),
	}

local function GetNameValue(pName: string): number
	local value = 0
	for index = 1, #pName do
		local cValue = string.byte(string.sub(pName, index, index))
		local reverseIndex = #pName - index + 1
		if #pName%2 == 1 then
			reverseIndex = reverseIndex - 1
		end
		if reverseIndex%4 >= 2 then
			cValue = -cValue
		end
		value = value + cValue
	end
	return value
end

local color_offset: number = 0

local module = {}

function module.ComputeNameNumber(pName : string) : number
	return ((GetNameValue(pName) + color_offset) % #NAME_COLORS) + 1
end

function module.ComputeNameColor(pName : string) : Color3
	return NAME_COLORS[((GetNameValue(pName) + color_offset) % #NAME_COLORS) + 1]
end

function module.ComputeNameGradient(pName : string) : ColorSequence
	return NAME_GRADIENTS[((GetNameValue(pName) + color_offset) % #NAME_GRADIENTS) + 1]
end

table.freeze(module)
return module