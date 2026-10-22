--!strict
--!optimize 2

const TextService = game:GetService(`TextService`)

const ANameColorP = require(`../AdvancedNameColorPredictor`)
const Style = require(`../Style`)
const Colors = Style.Colors
const FontStyle = Style.Font
const RichGradient = require(`../../Packages/RichGradient`)
const Vide = require(`../../Packages/Vide`)
const C = Vide.create
const Div = require(`./Div`)
const Text = require(`./Text`)
const UIPadding = require(`./UIPadding`)
const ScrollingFrame = require(`./ScrollingFrame`)

const VerifiedBadge = ` {utf8.char(0xE000)}`

export type ThumbnailType = "AvatarHeadShot" | "Avatar" | "AvatarBust"
export type ThumbnailSize = "48" | "60" | "100" | "150" | "180" | "352" | "420" | number

return function(
	props: {
		AnchorPoint: Vector2?,
		Size: UDim2?,
		Position: UDim2?,
		Radius: number?,
		UserId: Vide.Source<number>,
		ThumbnailType: ThumbnailType,
		ThumbnailSize: ThumbnailSize,
		DisplayUsername: Vide.Source<string>,
		Username: Vide.Source<string>,
		PreviousUsernames: {string}?,
		HasVerifiedBadge: Vide.Source<boolean>,
	}
)
	const Image = C "ImageLabel" {
		BorderSizePixel = 0,
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(1, 1),
		AnchorPoint = Vector2.new(1, 1),
		Size = UDim2.fromScale(0.3, 1),
		C "UIAspectRatioConstraint" {
			AspectRatio = 1,
		},
		C "UICorner" {
			CornerRadius = UDim.new(0, props.Radius or 6),
		},
	}
	const uid, thumbnailType, thumbnailSize = props.UserId, props.ThumbnailType, props.ThumbnailSize
	Vide.effect(function()
		Image.Image = `rbxthumb://type={thumbnailType}&id={uid()}&w={thumbnailSize}&h={thumbnailSize}`
	end)
	
	const DisplayUsername = Text {
		AnchorPoint = Vector2.zero,
		Size = UDim2.fromScale(.7, 0.6),
		Position = UDim2.fromScale(0, 0),
		AutoSize = "None",
		Children = {
			UIPadding {3},
		},
		Text = Vide.derive(function()
			return `<b>{props.DisplayUsername()}{props.HasVerifiedBadge() and VerifiedBadge or ``}</b>`
		end),
		RichText = true,
		XAlign = "Left",
	}
	
	const TrueUsername = Text {
		AnchorPoint = Vector2.new(0, 1),
		Size = UDim2.fromScale(.7, 0.3),
		Position = UDim2.fromScale(0, 0.95),
		AutoSize = "None",
		Children = {
			UIPadding {3, 3, 3, 6},
		},
		Text = Vide.derive(function()
			const username = props.Username()
			return `<b>@{RichGradient:Apply(username, ANameColorP.ComputeNameGradient(username), true)}</b>`
		end),
		RichText = true,
		XAlign = "Left",
	}
	TrueUsername.TextTransparency = 0.3
	
	const PreviousUsernames = Text {
		AnchorPoint = Vector2.new(0, 0),
		Size = UDim2.fromScale(1, 0),
		Position = UDim2.fromScale(0, 0),
		AutoSize = "Y",
		XAlign = "Left",
		YAlign = "Top",
	}
	PreviousUsernames.Font = Enum.Font.Code
	const PreviousUsernamesSF = ScrollingFrame {
		AnchorPoint = Vector2.new(0, 1),
		Size = UDim2.fromScale(.7, 0.4),
		Position = UDim2.fromScale(0, 1),
		Direction = "Y",
		Children = {PreviousUsernames, UIPadding {0, 0, 0, 6},}
	}
	PreviousUsernamesSF.BackgroundTransparency = 1
	
	const div = Div {
		AnchorPoint = props.AnchorPoint,
		Size = props.Size,
		Position = props.Position,
		Radius = props.Radius,
		AutoSize = "None",
		Children = {
			Image,
			DisplayUsername,
			TrueUsername,
			PreviousUsernamesSF
		},
	}
	
	const function SetPreviousUsernames(previousUsernames: {string}?)
		if type(previousUsernames) ~= `table` or #previousUsernames < 1 then
			DisplayUsername.Size = UDim2.fromScale(.7, .6)
			TrueUsername.Size = UDim2.fromScale(.7, .3)
			TrueUsername.Position = UDim2.fromScale(0, 0.95)
			
			PreviousUsernamesSF.Visible = false
			PreviousUsernames.Text = ``
			return
		end
		DisplayUsername.Size = UDim2.fromScale(.7, .4)
		TrueUsername.Size = UDim2.fromScale(.7, .25)
		TrueUsername.Position = UDim2.fromScale(0, 0.6)
		
		const text = table.concat({
			"Previous usernames: @",
			table.concat(previousUsernames, `, @`)
		})
		const ActualTextBounds = TextService:GetTextSize(
			text,
			PreviousUsernames.TextSize,
			PreviousUsernames.Font,
			Vector2.new(PreviousUsernamesSF.AbsoluteSize.X, 10e100)
		)
		PreviousUsernames.Size = UDim2.new(1, 0, 0, ActualTextBounds.Y)
		PreviousUsernames.Text = text
		--print(props.Username(), #previousUsernames)
		PreviousUsernamesSF.Visible = true
	end
	SetPreviousUsernames(props.PreviousUsernames)
	
	return div, SetPreviousUsernames
	
end