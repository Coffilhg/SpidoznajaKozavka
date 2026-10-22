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
		Position: UDim2?,
		AutoSize: ("Y" | "X" | "XY" | "None")?,
		Children: {Instance | GuiBase2d}?,
		TextSize: number?,
		Text: (string | Vide.Source<string>)?,
		RichText: boolean?,
		XAlign: ("Left" | "Center" | "Right")?,
		YAlign: ("Top" | "Center" | "Bottom")?,
		Color: Color3?,
	}
)
	const autoSize = if type(props.AutoSize) == `string` then props.AutoSize else "Y"
	const xAlign = if type(props.XAlign) == `string` then props.XAlign else "Center"
	const yAlign = if type(props.YAlign) == `string` then props.YAlign else "Top"
	
	const properties = {
		AnchorPoint = props.AnchorPoint or Vector2.new(.5, .5),
		Size = props.Size or UDim2.fromScale(1, 1),
		Position = props.Position or UDim2.fromScale(.5, .5),

		BackgroundTransparency = 1,

		AutomaticSize = Enum.AutomaticSize[autoSize],
		TextWrapped = true,
		TextScaled = autoSize == "None",
		TextSize = props.TextSize or 12,
		Text = props.Text or ``,
		TextXAlignment = Enum.TextXAlignment[xAlign],
		TextYAlignment = Enum.TextYAlignment[yAlign],
		
		RichText = not not props.RichText,
		
		FontFace = FontStyle.Main,
		
		TextColor3 = props.Color or Colors["Text (Primary)"],
	}
	
	if type(props.Children) == `table` then
		for _, child in props.Children do
			table.insert(properties, child)
		end
	end
	
	const textLabel = C("TextLabel")(properties :: any)
	
	--textLabel.Text = `{props.Text or ``}`
	
	return textLabel
end