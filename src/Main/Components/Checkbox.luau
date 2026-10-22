--!strict
--!optimize 2

const TS = game:GetService(`TweenService`)

const Style = require(`../Style`)
const Colors = Style.Colors
const Vide = require(`../../Packages/Vide`)
const C = Vide.create
const source = Vide.source
const effect = Vide.effect
const GreatUIButton = require(`../../Packages/GreatUIButton`)
const LemonSignal = require(`../../Packages/LemonSignal`)

const TransitionTwInf = TweenInfo.new(0.1)



return function(
	props: {

	}
)

	const state = source(true)
	const onToggled: LemonSignal.Signal<> = LemonSignal.new()
	
	const HitBox = C "TextButton" {
		BackgroundTransparency = 1,
		Text = "",
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		ZIndex = 9,
	}

	const checkbox = C "ImageLabel" {
		Size = UDim2.fromScale(0.171, 0.81),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.9, 0.5),
		Image = `rbxassetid://119003901253073`,
		ImageRectSize = Vector2.new(64, 64),
		ImageRectOffset = Vector2.new(0, 0),
		ImageColor3 = Colors["Text (Buttons)"],

		BackgroundTransparency = 1,

		C "UIAspectRatioConstraint" {
			AspectRatio = 1,
		},
		C "UICorner" {
			CornerRadius = UDim.new(0, 3),
		},
		(C :: any) "UISizeConstraint" {
			MaxSize = Vector2.new(64, 64),
		},
		(C :: any) "UIScale" {
			Scale = 1
		},
	}

	const greatCheckbox = GreatUIButton(checkbox, HitBox, {
		TweenInfo = TransitionTwInf,
		ImageColor3 = Colors["Text (Buttons)"],
		UICorner = {
			TweenInfo = TransitionTwInf,
			CornerRadius=UDim.new(0, 3),
		},
	})
		:SetAppearance(
			"Hover",
			{
				TweenInfo = TransitionTwInf,
				ImageColor3 = Colors["Text (Hover)"],
				UICorner = {
					TweenInfo = TransitionTwInf,
					CornerRadius=UDim.new(0, 6),
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


	const ShowCross = TS:Create(
		checkbox,
		TransitionTwInf,
		{
			ImageRectOffset = Vector2.new(0, 0),
		}
	)
	const ShowCheck = TS:Create(
		checkbox,
		TransitionTwInf,
		{
			ImageRectOffset = Vector2.new(128, 0),
		}
	)
	--const ShowMixed = TS:Create(
	--	checkbox,
	--	TransitionTwInf,
	--	{
	--		ImageRectOffset = Vector2.new(64, 0),
	--	}
	--)
	
	const function SetDisplay(displayed: boolean)
		if displayed then
			ShowCheck:Play()
			return
		end
		ShowCross:Play()
		--if displayed < 1 then
		--	ShowCheck:Play()
		--elseif displayed == 1 then
		--	ShowCross:Play()
		--else
		--	ShowMixed:Play()
		--end
	end

	greatCheckbox.OnPressStart:Connect(function()
		state(not state())
	end)
	effect(function()
		--print("Setting diplay to", state())
		SetDisplay(state())
		onToggled:Fire()
	end)

	return checkbox, HitBox, {
		GreatUIButton = greatCheckbox,
		DataState = state,
		OnToggled = onToggled,
	}
end