--!strict
--!optimize 2

const Style = require(`../Style`)
const Colors = Style.Colors
const FontStyle = Style.Font
const Vide = require(`../../Packages/Vide`)
const C = Vide.create
const GreatUIButton = require(`../../Packages/GreatUIButton`)
const UIPadding = require(`./UIPadding`)

const TransitionTwInf = TweenInfo.new(0.1)



return function(
	props: {
		AnchorPoint: Vector2?,
		Position: UDim2?,
		Size: UDim2?,
		Text: string | Vide.Source<string>,
		ZIndex: number?,
		RichText: boolean?,
	}
)

	const textButton = C "TextButton" {
		AnchorPoint = props.AnchorPoint or Vector2.new(.5, .5),
		Position = props.Position or UDim2.fromScale(.5, .5),
		Size = props.Size or UDim2.fromScale(1, 1),
		Text = props.Text,
		TextScaled = true,
		TextWrapped = true,
		ZIndex = props.ZIndex or 1,
		RichText = not not props.RichText,
		
		FontFace = FontStyle.Main,
		
		TextColor3 = Colors["Text (Buttons)"],
		BackgroundColor3=Colors["Button"],
		
		UIPadding({3}),
		C "UICorner" {
			Name="UICorner",
			CornerRadius=UDim.new(0, 6),
		},
		(C :: any) "UIScale" {
			Scale = 1
		}
	}
	
	const greatUIButton = GreatUIButton(textButton, textButton, {
		TweenInfo = TransitionTwInf,
		TextColor3 = Colors["Text (Buttons)"],
		BackgroundColor3=Colors["Button"],
		UICorner = {
			TweenInfo = TransitionTwInf,
			CornerRadius=UDim.new(0, 6),
		},
	})
	:SetAppearance(
		"Hover",
		{
			TweenInfo = TransitionTwInf,
			TextColor3 = Colors["Text (Hover)"],
			BackgroundColor3 = Colors["Hover"],
			UICorner = {
				TweenInfo = TransitionTwInf,
				CornerRadius=UDim.new(0, 12),
			},
		}
	)
	:SetAppearance(
		"Press",
		{
			TweenInfo = TransitionTwInf,
			UIScale = {
				TweenInfo = TransitionTwInf,
				Scale = 0.9,
			},
		}
	)
	:SetAppearance(
		"!Press",
		{
			TweenInfo = TransitionTwInf,
			UIScale = {
				TweenInfo = TransitionTwInf,
				Scale = 1,
			},
		},
		true
	)
	
	return textButton, greatUIButton
end