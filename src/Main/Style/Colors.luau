--!strict
--!optimize 2

const Colors = {
	[`Backgroung`] = Color3.fromRGB(200, 150, 255),--Color3.fromRGB(255, 255, 106), --Color3.fromRGB(255, 255, 106),
	
	[`Div`] = Color3.fromRGB(26, 26, 30),
	[`Button`] = Color3.fromRGB(32, 32, 36),
	[`Hover`] = Color3.fromRGB(64, 208, 88), --Color3.fromRGB(46, 46, 51),
	[`Outline`] = Color3.fromRGB(218, 218, 210),
	[`Red`] = Color3.fromRGB(208, 64, 64),
	[`Yellow`] = Color3.fromRGB(208, 208, 64),
	
	[`Text (Primary)`] = Color3.fromRGB(218, 218, 220),
	[`Text (Darker - Placeholder/Off)`] = Color3.fromRGB(143, 143, 144),
	[`Text (Buttons)`] = Color3.fromRGB(170, 170, 175),
	[`Text (Hover)`] = Color3.fromRGB(247, 247, 247),
	[`Text (Inverted)`] = Color3.fromRGB(37, 37, 35),
}

table.freeze(Colors)

return Colors