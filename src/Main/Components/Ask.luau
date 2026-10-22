--!strict
--!optimize 2

const TS = game:GetService(`TweenService`)
const TimelineTwInf = TweenInfo.new(
	12,
	Enum.EasingStyle.Linear,
	Enum.EasingDirection.InOut,
	0,
	false,
	0
)
const ToggleTwInf = TweenInfo.new(
	0.3,
	Enum.EasingStyle.Quad,
	Enum.EasingDirection.In,
	0,
	false,
	0
)
const TransitionTwInf = TweenInfo.new(0.1)

const LemonSignal = require(`../../Packages/LemonSignal`)
const GreatUIButton = require(`../../Packages/GreatUIButton`)
const Vide = require(`../../Packages/Vide`)
const C = Vide.create
const Style = require(`../Style`)
const Colors = Style.Colors
const FontFace = Style.Font
const RichOutput = require(`./RichOutput`)
const Button = require(`./TextButton`)
const UIPadding = require(`./UIPadding`)

export type AskObject = {
	read FixGreatUIButtonLooks: (self: AskObject) -> (),
	read Reparent: (
		self: AskObject,
		newParent: Instance
	) -> (),
	read OnAnswer: LemonSignal.Signal<boolean, number>,
	read Ask: (
		self: AskObject,
		questionRichText: string,
		denialButtonText: string,
		approvalButtonText: string
	) -> (number),
}
local IsNotCreated: boolean? = true
local AskObject: AskObject

return function(
	props: {
		Parent: Instance?,
	}
)
	const RichOutputObject = RichOutput({} :: any)
	
	if not IsNotCreated then
		-- just in case IsNotCreated = true was set, but the object was not yet assigned
		if not AskObject then
			RichOutputObject:Warn(`Components.Ask: Race condition reached`)
			repeat task.wait() until AskObject
		end
		return AskObject
	end
	if not props.Parent then
		-- wait until main script inits this
		RichOutputObject:Warn(`Awaiting AskObject`)
		if not AskObject then
			repeat task.wait() until AskObject
		end
		return AskObject
	end
	IsNotCreated = true
	
	const PromptBackground = C "Frame" {
		Parent = props.Parent,
		AnchorPoint=Vector2.new(0.5, 1),
		BackgroundColor3=Colors["Div"],
		BorderSizePixel=0,
		Position=UDim2.new(0.5, 0, 0, -12),
		Size=UDim2.new(1, -24, 0, 0),
		ZIndex=9,
		AutomaticSize = Enum.AutomaticSize.Y,
	}
	C "UICorner" {
		Parent = PromptBackground,
		CornerRadius = UDim.new(0, 6),
	}
	;(C :: any) "UIShadow" {
		Parent = PromptBackground,
		Color = Colors.Outline,
		Spread = UDim2.fromOffset(4, 4),
		BlurRadius = UDim.new(0, 3),
	}
	C "UIListLayout" {
		Parent = PromptBackground,
		FillDirection = Enum.FillDirection.Vertical,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 0),
	}
	
	const PromptMain = C "Frame" {
		Parent = PromptBackground,
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundColor3 = PromptBackground.BackgroundColor3,
		BorderSizePixel = 0,
		Position = UDim2.new(0.5, 0, 0, 0),
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		ZIndex = 3,
		UIPadding {4},
	}
	C "UICorner" {
		Parent = PromptMain,
		CornerRadius = UDim.new(0, 6),
	}
	
	const PromptTimelineWrapFullSize = UDim2.new(1, 0, 0, 3)
	const PromptTimelineWrap = C "Frame" {
		Parent = PromptBackground,
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.fromScale(0, 1),
		Size = PromptTimelineWrapFullSize,
		LayoutOrder = 3,
		ZIndex = 1,
		BackgroundTransparency = 1,
	}
	const Timeline = C "Frame" {
		Parent = PromptTimelineWrap,
		BackgroundColor3 = Colors["Hover"],
		Size = UDim2.new(1, 0, 2, 18),
		Position = UDim2.fromScale(0, 1),
		AnchorPoint = Vector2.new(0, 1),
	}
	C "UICorner" {
		Parent = Timeline,
		CornerRadius = UDim.new(0, 6),
	}
	
	C "UIListLayout" {
		Parent = PromptMain,
		FillDirection = Enum.FillDirection.Vertical,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 8),
	}
	const Question = C "TextLabel" {
		Parent = PromptMain,
		Text = "A request to https://example.json is required to continue, allow?",
		TextScaled = false,
		TextWrapped = true,
		TextColor3 = Colors["Text (Primary)"],
		Size = UDim2.fromScale(1, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		FontFace = FontFace.Main,
		TextSize = 18,
		RichText = true,
	}
	const Buttons = C "Frame" {
		Parent = PromptMain,
		Size = UDim2.new(1, 0, 0, 24),
		BorderSizePixel = 0,
		BackgroundTransparency = 1,
		LayoutOrder = 3,
	}
	--C "UIPadding" {
	--	Parent = Buttons,
	--	PaddingBottom = UDim.new(0, 4),
	--	PaddingTop = UDim.new(0, 4),
	--	PaddingLeft = UDim.new(0, 4),
	--	PaddingRight = UDim.new(0, 4),
	--}
	
	
	const Deny = C "TextButton" {
		Size = UDim2.new(0.5, -8, 1, 0),
		Position = UDim2.fromScale(0, 0.5),
		AnchorPoint = Vector2.new(0, 0.5),
		TextScaled = true,
		TextWrap = true,
		TextWrapped = true,
		Parent = Buttons,
		Text = "Deny",
		C "UICorner" {
			CornerRadius = UDim.new(0, 8),
		},
	}
	
	const DenyGUIB = GreatUIButton(Deny, Deny, {
		TweenInfo = TransitionTwInf,
		TextColor3 = Colors["Text (Buttons)"],
		BackgroundColor3 = Colors["Button"],
		UICorner = {
			TweenInfo = TransitionTwInf,
			CornerRadius=UDim.new(0, 8),
		},
	}):SetAppearance("Hover", {
		TweenInfo = TransitionTwInf,
		TextColor3 = Colors["Text (Hover)"],
		BackgroundColor3 = Colors["Red"],
		UICorner = {
			TweenInfo = TransitionTwInf,
			CornerRadius=UDim.new(0, 12),
		},
	}, true)
	
	const Allow = C "TextButton" {
		Size = UDim2.new(0.5, -8, 1, 0),
		Position = UDim2.fromScale(1, 0.5),
		AnchorPoint = Vector2.new(1, 0.5),
		TextScaled = true,
		TextWrap = true,
		TextWrapped = true,
		Parent = Buttons,
		Text = "Allow",
		C "UICorner" {
			CornerRadius = UDim.new(0, 8),
		},
	}
	
	const AllowGUIB = GreatUIButton(Allow, Allow, {
		TweenInfo = TransitionTwInf,
		TextColor3 = Colors["Text (Buttons)"],
		BackgroundColor3 = Colors["Button"],
		UICorner = {
			TweenInfo = TransitionTwInf,
			CornerRadius=UDim.new(0, 8),
		},
	}):SetAppearance("Hover", {
		TweenInfo = TransitionTwInf,
		TextColor3 = Colors["Text (Hover)"],
		BackgroundColor3 = Colors["Hover"],
		UICorner = {
			TweenInfo = TransitionTwInf,
			CornerRadius=UDim.new(0, 12),
		},
	}, true)
	
	
	local timeoutThread: thread?
	local timeoutId = 0
	local IsOpen: boolean = false
	const TimelineTween = TS:Create(
		PromptTimelineWrap,
		TimelineTwInf,
		{
			Size = UDim2.new(
				0,
				0,
				PromptTimelineWrapFullSize.Y.Scale,
				PromptTimelineWrapFullSize.Y.Offset
			),
		}
	)
	const OpenTween = TS:Create(
		PromptBackground,
		ToggleTwInf,
		{
			AnchorPoint=Vector2.new(0.5, 0),
			Position=UDim2.new(0.5, 0, 0, 12),
		}
	)
	const CloseTween = TS:Create(
		PromptBackground,
		ToggleTwInf,
		{
			AnchorPoint=Vector2.new(0.5, 1),
			Position=UDim2.new(0.5, 0, 0, -12),
		}
	)
	const OnAnswer: LemonSignal.Signal<boolean, number> = LemonSignal.new()
	
	-- Purely visual functions
	const function Open()
		if CloseTween.PlaybackState == Enum.PlaybackState.Playing then
			CloseTween:Cancel()
		end
		OpenTween:Play()
	end
	const function Close()
		if OpenTween.PlaybackState == Enum.PlaybackState.Playing then
			OpenTween:Cancel()
		end
		CloseTween:Play()
	end
	
	
	-- Logic functions
	const function Timeout(threadTimeoutId: number)
		if threadTimeoutId ~= timeoutId then
			return
		end
		
		timeoutThread = nil
		
		OnAnswer:Fire(false, threadTimeoutId)
		IsOpen = false
		Close()
	end
	const function StartTimeout()
		if TimelineTween.PlaybackState == Enum.PlaybackState.Playing then
			TimelineTween:Cancel()
		end

		PromptTimelineWrap.Size = PromptTimelineWrapFullSize
		TimelineTween:Play()

		timeoutThread = task.delay(TimelineTween.TweenInfo.Time, Timeout, timeoutId)
	end
	
	Deny.Activated:Connect(function()
		if timeoutThread then
			task.cancel(timeoutThread)
		end
		OnAnswer:Fire(false, timeoutId)
		IsOpen = false
		Close()
	end)
	Allow.Activated:Connect(function()
		if timeoutThread then
			task.cancel(timeoutThread)
		end
		OnAnswer:Fire(true, timeoutId)
		IsOpen = false
		Close()
	end)
	
	AskObject = {
		FixGreatUIButtonLooks = function(self: AskObject)
			DenyGUIB:ApplyAppearance("Hover")
			DenyGUIB:ApplyAppearance("Default")
			AllowGUIB:ApplyAppearance("Hover")
			AllowGUIB:ApplyAppearance("Default")
		end,
		Reparent = function(
			self: AskObject,
			newParent: Instance
		)
			PromptBackground.Parent = newParent
		end,
		OnAnswer = OnAnswer,
		Ask = function(
			self: AskObject,
			questionRichText: string,
			denialButtonText: string,
			approvalButtonText: string
		): number
			const previousTimeoutId = timeoutId
			timeoutId += 1
			
			Question.Text = questionRichText
			Deny.Text = denialButtonText
			Allow.Text = approvalButtonText

			if IsOpen then
				if timeoutThread then
					task.cancel(timeoutThread)
				end
				OnAnswer:Fire(false, previousTimeoutId) -- deny previous question
				StartTimeout()
				return timeoutId
			end

			Open()
			IsOpen = true
			StartTimeout()
			return timeoutId
		end,
	}
	
	table.freeze(AskObject)
	
	return AskObject :: AskObject
end