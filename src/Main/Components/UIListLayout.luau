--!strict
--!optimize 2

const Vide = require(`../../Packages/Vide`)
const C = Vide.create

return function(
	props: {
		Direction: ("Vertical" | "Horizontal")?,
		XAlign: ("Left" | "Center" | "Right")?,
		YAlign: ("Top" | "Center" | "Bottom")?,
		SortOrder: ("Name" | "LayoutOrder")?,
		Padding: UDim?,
	}
)
	const direction = if type(props.Direction) == `string` then props.Direction else "Vertical"
	const xAlign = if type(props.XAlign) == `string` then props.XAlign else "Center"
	const yAlign = if type(props.YAlign) == `string` then props.YAlign else "Top"
	const sortOrder = if type(props.SortOrder) == `string` then props.SortOrder else "LayoutOrder"
	
	return C "UIListLayout" {
		FillDirection = Enum.FillDirection[direction],
		HorizontalAlignment = Enum.HorizontalAlignment[xAlign],
		VerticalAlignment = Enum.VerticalAlignment[yAlign],
		SortOrder = Enum.SortOrder[sortOrder],
		Padding = props.Padding or UDim.new(0, 12),
	}
end