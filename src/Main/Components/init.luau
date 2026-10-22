--!strict
--!optimize 2

const LoopedPattern = require(`@self/LoopedPattern`)
export type Wrap_LoopedPattern = LoopedPattern.LoopedPattern

const Components = {
	Main = require(`@self/Main`),
	LoopedPattern = LoopedPattern,
	ScrollingFrame = require(`@self/ScrollingFrame`),
	Checkbox = require(`@self/Checkbox`),
	TextButton = require(`@self/TextButton`),
	UIListLayout = require(`@self/UIListLayout`),
	UIPadding = require(`@self/UIPadding`),
	Text = require(`@self/Text`),
	Pre = require(`@self/Pre`),
	PreNoWrap = require(`@self/PreNoWrap`),
	Div = require(`@self/Div`),
	RichOutput = require(`@self/RichOutput`),
	Ask = require(`@self/Ask`),
	PlayerProfile = require(`@self/PlayerProfile`),
	VirtualList = require(`@self/VirtualList`),
}

return Components