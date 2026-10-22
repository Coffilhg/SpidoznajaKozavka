--!strict
--!optimize 2

const Style = require(`../Style`)
const Colors = Style.Colors
const FontStyle = Style.Font
const Vide = require(`../../Packages/Vide`)
const C = Vide.create
const source = Vide.source
const effect = Vide.effect
const root = Vide.root

const ScrollingFrame = require(`./ScrollingFrame`)
const UIListLayout = require(`./UIListLayout`)
const UIPadding = require(`./UIPadding`)

export type RichOutputObject = {
	read Print: (
		self: RichOutputObject,
		...any
	) -> (),
	read Warn: (
		self: RichOutputObject,
		...any
	) -> (),
	read Error: (
		self: RichOutputObject,
		...any
	) -> (),
	read HighlightedPrint: (
		self: RichOutputObject,
		...any
	) -> (),
	read Clear: (
		self: RichOutputObject
	) -> (),
}

-- https://create.roblox.com/docs/en-us/ui/rich-text
-- important color: df6af7
-- usual print: bcbec8

const DefaultMessage = `Plugin Debug Log will show up here`
const MaxLogLength = 200_000

-- RichOutput is a singleton: PluginBigSettingsStoreService needs a place
-- to log errors from as early as module-load time (well before Main's
-- Vide.mount ever runs), and does so via `RichOutputModule({} :: any)`
-- kept to a single variable - so the RichOutputObject (the thing with
-- :Error/:Print/etc) MUST be the first return value, exactly like the
-- old single-return RichOutput. Main wants the TextBox and
-- ScrollingFrame too, to embed in the UI, so those follow after.
--
-- Whichever of the two callers runs first is the one that actually
-- builds it - via its own Vide.root(), so it never depends on being
-- called from within an already-existing reactive scope - and every
-- later call (in either direction) just receives the same already-built
-- RichOutputObject / TextBox / ScrollingFrame back.
local isBuilt = false
local builtRichOutput: RichOutputObject
local builtPre: TextBox
local builtScrollingFrame: ScrollingFrame

return function(
	props: {}
): (RichOutputObject, TextBox, ScrollingFrame)
	if isBuilt then
		return builtRichOutput, builtPre, builtScrollingFrame
	end
	isBuilt = true

	const _destroy, richOutput, thePre, sf = root(function()
		const messages: {string} = {DefaultMessage}
		const logText = source(DefaultMessage)

		const function UpdateText()
			local log = table.concat(messages, "\n\n")
			while #log > MaxLogLength and #messages > 1 do
				table.remove(messages, 1)
				log = table.concat(messages, "\n\n")
			end
			logText(log)
		end

		-- format: a string to format via string.format including %s once
		const function Log(format: string, ...)
			const toConcat: {string} = {}
			for _, v in {...} do
				table.insert(toConcat, `{v}`)
			end

			const formatted = string.format(
				format,
				table.concat(toConcat, ", ")
			)

			table.insert(messages, table.concat({
				formatted,
				string.format("%.3f", os.clock()),
			}, "\t-\t"))
			UpdateText()
		end
		const function Clear()
			table.clear(messages)
			table.insert(messages, DefaultMessage)
			UpdateText()
		end

		const thePre = C "TextBox" {
			FontFace = FontStyle.Main,
			PlaceholderColor3 = Colors["Text (Darker - Placeholder/Off)"],
			PlaceholderText = `Plugin Debug Log will show up here`,
			Text = DefaultMessage,
			RichText = true,
			TextColor3 = Colors["Text (Primary)"],
			TextSize = 15,
			TextXAlignment = Enum.TextXAlignment.Left,
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ClearTextOnFocus = false,
			Size = UDim2.fromScale(1, 0),
		}

		-- Keeps the log read-only: any edit the user makes is immediately
		-- reverted back to the current log text - same guard Pre's
		-- IsConstant uses, just tracking a value that changes over time
		-- instead of a single fixed one.
		const function SyncText()
			if thePre.Text == logText() then
				return
			end
			thePre.Text = logText()
		end
		effect(SyncText)
		thePre:GetPropertyChangedSignal(`Text`):Connect(SyncText)

		const sf = ScrollingFrame({
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

		const richOutput: RichOutputObject = {
			Print = function(self: RichOutputObject, ...)
				Log(`%s`, ...)
			end,
			Warn = function(self: RichOutputObject, ...)
				Log(`<b><font color="#f57630">%s</font></b>`, ...)
			end,
			Error = function(self: RichOutputObject, ...)
				Log(`<b><font color="#e75750">%s</font></b>`, ...)
			end,
			HighlightedPrint = function(self: RichOutputObject, ...)
				Log(`<b><font color="#df6af7">%s</font></b>`, ...)
			end,
			Clear = function(self: RichOutputObject)
				Clear()
			end,
		}
		table.freeze(richOutput)

		return richOutput, thePre, sf
	end)

	builtRichOutput, builtPre, builtScrollingFrame = richOutput, thePre, sf

	return richOutput, thePre, sf
end