--[[--
    LoopedPattern (a prototype used in CoffeeMixer & SpidoznajaKozavka)
    Copyright © 2026 Coffilhg (Roblox UserId 517222346)

    This Source Code Form is subject to the terms of the Mozilla Public
    License, v. 2.0. If a copy of the MPL was not distributed with this
    file, You can obtain one at https://mozilla.org/MPL/2.0/.

    GitHub Repository/Branch with latest version, documentation, etc:
    https://github.com/Coffilhg/Useful-Components/tree/LoopedPattern
    Stars are appreciated!
    
    This is essentially a prototype / unpublished version of LoopedPattern,
    if the link https://github.com/Coffilhg/Useful-Components/tree/LoopedPattern
    leads nowhere, it means this component is not published yet, if you use it, this module is
    MPL-2.0 Licensed and made by @Coffilhg (Roblox UserId 517222346)
    This header shall be kept here without modifications.
--]]--

--!strict
--!optimize 2

const RunS = game:GetService(`RunService`)

const Style = require(`../Style`)
const Colors = Style.Colors
const Vide = require(`../../Packages/Vide`)
const C = Vide.create
const source = Vide.source
const derive = Vide.derive

export type LoopedPattern = {
	read PatternRBXAssetId: Vide.Source<string>,
	read PixelsPerTile: Vide.Source<number>,
	read SpeedMultiplier: Vide.Source<number>,
	read MovementAngleDegrees: Vide.Source<number>,
	read Play: (self: LoopedPattern) -> (),
	read Pause: (self: LoopedPattern) -> (),
}



--- Defaults & Explanation
const PatternRBXAssetId = `rbxasset://textures/ui/GuiImagePlaceholder.png`
const TilePixels = 128
----const DoubleTilePixels = 2*TilePixels
--const TileSize = UDim2.fromOffset(TilePixels, TilePixels)
-- technically having TilePixels instead of DoubleTilePixels works,
-- but DoubleTilePixels just guarantees consistent look, even if
-- something ever breaks.
-- now once we added different directions, this is actually a necessity
-- unless we alse modify the starting position
--const BackgroundSize = UDim2.new(1, TilePixels, 1, TilePixels)
--const patternBgColor = Colors["Backgroung"]
--const SpeedMultiplier = (TilePixels / 3.96)


-- rotation as on a Unit Circle
-- e.g. (< https://www.desmos.com/calculator/hxy0ltd2xd >)
-- the pattern moves in the direction
-- towards the (SpeedMultiplierX, SpeedMultiplierY)
-- i.e. Nullpoint (0, 0) -> (SpeedMultiplierX, SpeedMultiplierY)
const MovementAngleDegrees = 67 -- set this in angles
-- rest of the script handles everything math related
--const MovementAngleRadians = math.rad(MovementAngleDegrees)
--const SpeedMultiplierX = math.cos(MovementAngleRadians)
--const SpeedMultiplierY = math.sin(MovementAngleRadians)
--const MovementSpeedX = SpeedMultiplierX * SpeedMultiplier
--const MovementSpeedY = SpeedMultiplierY * SpeedMultiplier
--const StartPos = UDim2.fromOffset(
--	-TilePixels,
--	-TilePixels
--)

return function(
	props: {
		PatternRBXAssetId: string?,
		SpeedMultiplier: number?,
		MovementAngleDegrees: number?,
		PixelsPerTile: number?,
	}
): (ImageLabel, LoopedPattern)
	local connection: RBXScriptConnection?
	local x: number = 0
	local y: number = 0
	
	const assetId = props.PatternRBXAssetId
	const rbxAssetId: Vide.Source<string> = source(type(assetId) == `string` and assetId or PatternRBXAssetId)
	
	const pixels = props.PixelsPerTile
	const pixelsPerTile: Vide.Source<number> = source(type(pixels) == `number` and pixels or TilePixels)
	const tileSize = derive(function()
		return UDim2.fromOffset(pixelsPerTile(), pixelsPerTile())
	end)
	const backgroundSize = derive(function()
		return UDim2.new(1, pixelsPerTile(), 1, pixelsPerTile())
	end)
	
	const speed = props.SpeedMultiplier
	const speedMultiplier = derive(function()
		return type(speed) == `number` and pixelsPerTile() * speed or pixelsPerTile() / 3.96
	end)

	const angle = props.MovementAngleDegrees
	const movementAngleDegrees: Vide.Source<number> = source(type(angle) == `number` and angle or MovementAngleDegrees)
	const movementAngleRadians = derive(function()
		return math.rad(movementAngleDegrees())
	end)
	const speedMultiplierX = derive(function()
		return math.cos(movementAngleRadians())
	end)
	const speedMultiplierY = derive(function()
		return math.sin(movementAngleRadians())
	end)
	const movementSpeedX = derive(function()
		return speedMultiplierX() * speedMultiplier()
	end)
	const movementSpeedY = derive(function()
		return speedMultiplierY() * speedMultiplier()
	end)
	
	
	
	const pattern = C "ImageLabel" {
		Name = `Wrap`,
		Image = rbxAssetId,
		ScaleType = Enum.ScaleType.Tile,
		TileSize = tileSize,
		BackgroundColor3 = Colors["Backgroung"],
		--BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = backgroundSize,
		ImageTransparency = 0.37,
	}
	
	

	const function loop(dt: number)
		x = (x + dt * movementSpeedX()) % pixelsPerTile()
		y = (y - dt * movementSpeedY()) % pixelsPerTile()
		
		-- -pixelsPerTile is the starting pos
		pattern.Position = UDim2.fromOffset(
			-pixelsPerTile() + x,
			-pixelsPerTile() + y
		)
	end
	
	
	
	-- Lazy stop the background loop
	const function pauseBackgroundLoop(self: LoopedPattern)  -- self is unused
		if not (typeof(connection) == `RBXScriptConnection` and connection.Connected) then
			return
		end
		--print("Bg Loop Disconnected")
		connection:Disconnect()
		connection = nil
	end
	
	const loopedPattern = {
		PatternRBXAssetId = rbxAssetId,
		PixelsPerTile = pixelsPerTile,
		SpeedMultiplier = speedMultiplier,
		MovementAngleDegrees = movementAngleDegrees,
		Pause = pauseBackgroundLoop,
	}
	
	-- Lazy init the background loop
	function loopedPattern.Play(self: LoopedPattern) -- self is unused
		if typeof(connection) == `RBXScriptConnection` then
			return
		end
		--print("Bg Loop Connected")
		connection = RunS.PreRender:Connect(loop)
	end
	
	table.freeze(loopedPattern)
	
	;(Vide.cleanup :: any)(pauseBackgroundLoop)

	return pattern, loopedPattern :: LoopedPattern
end