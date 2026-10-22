--!strict
--!optimize 2

const Style = require(`../Style`)
const Colors = Style.Colors
const Vide = require(`../../Packages/Vide`)
const C = Vide.create

-- A page
return function(
	props: {
		AnchorPoint: Vector2?,
		Size: UDim2?,
		Position: UDim2?,
		Direction: ("Y" | "X" | "XY")?,
		Children: {Instance | GuiBase2d},
	}
)
	const direction = if type(props.Direction) == `string` then props.Direction else "Y"
	
	const sf = C "ScrollingFrame" {
		AnchorPoint = props.AnchorPoint or Vector2.new(.5, .5),
		Size = props.Size or UDim2.fromScale(1, 1),
		Position = props.Position or UDim2.fromScale(.5, .5),
		
		BackgroundColor3 = Colors["Div"],
		
		AutomaticCanvasSize = Enum.AutomaticSize[direction],
		ScrollingDirection = Enum.ScrollingDirection[direction],
		
		HorizontalScrollBarInset = Enum.ScrollBarInset[direction ~= "Y" and "Always" or "None"],
		VerticalScrollBarInset = Enum.ScrollBarInset[direction ~= "X" and "Always" or "None"],
		
		CanvasSize = UDim2.new(),
		BackgroundTransparency = 0,
		
		ScrollBarThickness = 9,
		
		
		
		C "UICorner" {
			CornerRadius = UDim.new(0, 6),
		},
		
		table.unpack(props.Children),
	}
	
	return sf
end