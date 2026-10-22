--!strict
--!optimize 2

const Style = require(`../Style`)
const Colors = Style.Colors
const Vide = require(`../../Packages/Vide`)
const C = Vide.create

const UIPadding = require(`./UIPadding`)
const Padding = UDim.new(0.12, 0)


-- Returns the PluginUIBox and the Wrap to which all of the ForegroundChildren were parented;
-- BackgroundChildren are parented to PluginUIBox;
-- The Wrap has a ZIndex of 9;
return function(
	props: {
		--Parent: DockWidgetPluginGui,
		BackgroundChildren: {Instance | GuiBase2d},
		ForegroundChildren: {Instance | GuiBase2d},
	}
)
	
	const PluginUIBox = C "Frame" {
		--Parent = props.Parent,
		Name="PluginUIBox",
		BackgroundColor3=Colors["Backgroung"],
		BorderSizePixel=0,
		ClipsDescendants=true,
		Size=UDim2.new(1, 0, 1, 0),
		
		table.unpack(props.BackgroundChildren),
	}
	const Wrap = C "Frame" {
		Parent = PluginUIBox,
		Name="Wrap",
		BorderSizePixel=0,
		ClipsDescendants=true,
		BackgroundTransparency = 1,
		Size=UDim2.new(1, 0, 1, 0),
		ZIndex = 9,
		
		UIPadding {UDim.new(Padding.Scale * 1.5, Padding.Offset * 1.5), Padding, UDim.new(Padding.Scale / 2, Padding.Offset / 2), Padding},
		table.unpack(props.ForegroundChildren),
	}
	const UIPageLayout: UIPageLayout = (C :: any) "UIPageLayout" {
		Parent = Wrap,
		Animated = true,
		Circular = true,
		EasingDirection = Enum.EasingDirection.Out,
		EasingStyle = Enum.EasingStyle.Quint,
		GamepadInputEnabled = true,
		ScrollWheelInputEnabled = true,
		TouchInputEnabled = true,
		TweenTime = 0.6,
		Padding = UDim.new(Padding.Scale*2, Padding.Offset*2),
	}
	
	return PluginUIBox, Wrap, UIPageLayout
end