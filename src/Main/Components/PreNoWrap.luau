--!strict
--!optimize 2

const Style = require(`../Style`)
const Colors = Style.Colors
const Vide = require(`../../Packages/Vide`)
const C = Vide.create
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
	local text: string = type(props.Text) == `string` and props.Text or ``

	local thePre = C("TextBox")({
		--FontFace = FontStyle.Main,
		Font = Enum.Font.Code,
		PlaceholderColor3=Colors["Text (Darker - Placeholder/Off)"],
		PlaceholderText=props.Placeholder or `Placeholder of PlaceholderText`,
		Text=text,
		TextColor3=props.Color or Colors["Text (Primary)"],
		TextSize=15,
		TextXAlignment=Enum.TextXAlignment.Left,	
		AutomaticSize=Enum.AutomaticSize.Y,
		BackgroundTransparency=1,
		BorderSizePixel=0,
		ClearTextOnFocus=false,
		Size=props.Size or UDim2.fromScale(1, 0),
		RichText = not not props.RichText,
		AnchorPoint = props.AnchorPoint or Vector2.new(.5, .5),
		Position = props.Position or UDim2.fromScale(.5, .5),
		TextWrapped = true,
		UIPadding({6}),
	})

	local function ApplyText(txt: string?)
		if type(txt) == "string" then
			text = txt
		end
		if thePre.Text == text then
			-- prevents infinite looping
			return
		end
		thePre.Text = text
	end

	if not not (props.IsConstant) then
		thePre:GetPropertyChangedSignal(`Text`):Connect(function()
			ApplyText(text)
		end)
	end

	return thePre, ApplyText
end
