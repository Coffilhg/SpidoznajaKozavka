--!strict
--!optimize 2

const Style = require(`../Style`)
const Colors = Style.Colors
const FontStyle = Style.Font
const Vide = require(`../../Packages/Vide`)
const C = Vide.create

return function(
	props: {
		AnchorPoint: Vector2?,
		Size: UDim2?,
		Position: (UDim2 | Vide.Source<UDim2>)?,
		Radius: number?,
		AutoSize: ("Y" | "X" | "XY" | "None")?,
		Children: {Instance | GuiBase2d},
		Color: Color3?,
		ShadowColor: Color3?,
	}
)
	const autoSize = if type(props.AutoSize) == `string` then props.AutoSize else "Y"

	return C "Frame" {
		AnchorPoint = props.AnchorPoint or Vector2.new(.5, .5),
		Size = props.Size or UDim2.fromScale(1, 1),
		Position = props.Position or UDim2.fromScale(.5, .5),
		
		AutomaticSize = Enum.AutomaticSize[autoSize],
		
		BorderSizePixel = 0,
		BackgroundColor3 = props.Color or Colors["Div"],
		
		C "UICorner" {
			CornerRadius = UDim.new(0, props.Radius or 6),
		},
		(C :: any) "UIShadow" {
			Color = props.ShadowColor or Colors["Button"],
			BlurRadius = UDim.new(0, 2),
			Spread = UDim2.fromOffset(1, 1),
			Transparency = 0,
		},
		table.unpack(props.Children),
	}
end