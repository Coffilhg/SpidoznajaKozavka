--!strict
--!optimize 2

const Style = require(`../Style`)
const Colors = Style.Colors
const FontStyle = Style.Font
const Vide = require(`../../Packages/Vide`)
const C = Vide.create
const ScrollingFrame = require(`./ScrollingFrame`)
const UIListLayout = require(`./UIListLayout`)
const UIPadding = require(`./UIPadding`)

return function(
	props: {
		AnchorPoint: Vector2?,
		Size: UDim2?,
		Position: UDim2?,
		Placeholder: string?,
		Text: string?,
		IsConstant: true?,
		Color: Color3?,
		RichText: boolean?,
	}
)
	const text: string = type(props.Text) == `string` and props.Text or ``
	
	const thePre = C "TextBox" {
		FontFace = FontStyle.Main,
		PlaceholderColor3=Colors["Text (Darker - Placeholder/Off)"],
		PlaceholderText=props.Placeholder or `Placeholder of PlaceholderText`,
		Text=text,
		TextColor3=props.Color or Colors["Text (Primary)"],
		TextSize=15,
		TextXAlignment=Enum.TextXAlignment.Left,	
		AutomaticSize=Enum.AutomaticSize.XY,
		BackgroundTransparency=1,
		BorderSizePixel=0,
		ClearTextOnFocus=false,
		Size=UDim2.fromScale(1, 0),
		RichText = not not props.RichText,
	}
	
	const sf = ScrollingFrame({
		Size = props.Size,
		Position = props.Position,
		AnchorPoint = props.AnchorPoint,
		Direction = "XY",
		Children = {
			UIListLayout({
				XAlign = "Left",
				
			}),
			C "UICorner" {
				CornerRadius = UDim.new(0, 12),
			},
			UIPadding({24}),
			thePre,
		}
	})
	
	sf.BackgroundColor3 = Colors.Button
	
	if not not (props.IsConstant) then
		thePre:GetPropertyChangedSignal(`Text`):Connect(function()
			if thePre.Text == text then
				-- prevents infinite looping
				return
			end
			thePre.Text = text
		end)
	end

	return sf
end