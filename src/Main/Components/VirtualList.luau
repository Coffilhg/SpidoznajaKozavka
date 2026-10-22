-- What is Virtual Scrolling
-- https://medium.com/@sreekanthsreekanth970/virtual-scrolling-2797d722c6e2
-- Although I'd name it InfiniteScroll

--!strict
--!optimize 2

const Players = game:GetService(`Players`)
--print(Players:GetUserThumbnailAsync(517222346, Enum.ThumbnailType.AvatarThumbnail, Enum.ThumbnailSize.Size48x48))
--const AES = game:GetService(`AvatarEditorService`)

--AES:GetOutfitsAsync(Enum.OutfitSource.Created, Enum.OutfitType.Avatar)

const HumDescCache: {[number]: HumanoidDescription} = {}
const function GetHumDesc(outfitId: number): (boolean, HumanoidDescription)
	const cached = HumDescCache[outfitId]
	if cached then
		return true, cached
	end
	
	const success, humDesc = pcall(Players.GetHumanoidDescriptionFromOutfitIdAsync, Players, outfitId)
	if success and typeof(humDesc) == `Instance` and humDesc:IsA(`HumanoidDescription`) then
		HumDescCache[outfitId] = humDesc
		return true, humDesc
	end
	
	return false, humDesc
end
--const Assets = script.Parent.Parent.Parent.Assets
--const R6Rig = Assets.R6
--const R15Rig = Assets.R15

const Style = require(`../Style`)
const Colors = Style.Colors
const Reaction = require(`../../Packages/Reaction`)
const V, O, Copy = Reaction.V, Reaction.O, Reaction.C
const Vide = require(`../../Packages/Vide`)
const C = Vide.create
const Source = Vide.source
const GreatUIButton = require(`../../Packages/GreatUIButton`)

const Div = require(`./Div`)
const Text = require(`./Text`)

type Item = {
	name: string,
	id: number,
}
type InitialRow = number
type ElementManager = {
	-- implementation-specific (per-element)
	Id: Reaction.V<number>,
	Name: Reaction.V<string>,
	Main: Frame,
}
type Row = {
	-- general virtual scrolling (per-row)
	YOffset: Reaction.V<number>,
	CurrentRow: number,
	Elements: {ElementManager},
}

const ElementXScale = 0.46
const RowSize = 2
const PaddingXScale = 1 - ElementXScale * RowSize
const BufferSize = 1 -- 1 row buffer on each side
const TextYOffset = 24

-- A page
return function(
	props: {
		AnchorPoint: Vector2?,
		Size: UDim2?,
		Position: UDim2?,
		SelectedItem: Reaction.V<number>,
		SelectedItemMetadata: {
			Name: string,
			IsOutfit: boolean,
		},
		SelectedText: TextLabel,
		ApplySelectionText: (Instance, boolean, boolean?) -> (),
		--Direction: ("Y" | "X" | "XY")?,
		--Children: {Instance | GuiBase2d},
	}
)
	const selectedItem = props.SelectedItem
	const selectedItemMetadata = props.SelectedItemMetadata
	const selectedText = props.SelectedText
	const applySelectionText = props.ApplySelectionText
	local list: {Item} = {} -- data
	const direction = "Y"--if type(props.Direction) == `string` then props.Direction else "Y"

	const sf = C "ScrollingFrame" {
		AnchorPoint = props.AnchorPoint or Vector2.new(.5, .5),
		Size = props.Size or UDim2.fromScale(1, 1),
		Position = props.Position or UDim2.fromScale(.5, .5),

		BackgroundColor3 = Colors["Div"],

		AutomaticCanvasSize = Enum.AutomaticSize.None,
		ScrollingDirection = Enum.ScrollingDirection[direction],

		HorizontalScrollBarInset = Enum.ScrollBarInset[direction ~= "Y" and "Always" or "None"],
		VerticalScrollBarInset = Enum.ScrollBarInset[direction ~= "X" and "Always" or "None"],

		CanvasSize = UDim2.new(),
		BackgroundTransparency = 0,

		ScrollBarThickness = 9,

		C "UICorner" {
			CornerRadius = UDim.new(0, 6),
		},
	}
	
	-- mostly implementation-specific
	const function element(yOffset: Reaction.V<number>, isRight: boolean?)
		const xScale = not isRight and 0 or 1
		
		const id = V(0)
		const name = V("placeholder") :: Reaction.V<string>
		
		--const rig6 = R6Rig:Clone()
		--const rig6Hum = rig6.Humanoid
		--const rig6HRP = rig6.HumanoidRootPart
		--const rig15 = R15Rig:Clone()
		--const rig15Hum = rig15.Humanoid
		--const rig15HRP = rig15.HumanoidRootPart
		
		--rig6HRP.Anchored = true
		--rig15HRP.Anchored = true
		
		--const camera = C "Camera" {}
		--const function lookAtRig(isLookingAtR6: boolean)
		--	const rigHRP = isLookingAtR6 and rig6HRP or rig15HRP
		--	const pos = rigHRP.Position

		--	camera.CFrame = CFrame.lookAt(
		--		pos + Vector3.new(0, 0, -4.5),
		--		pos
		--	)
		--end
		--[[
		--const pos = rig15HRP.Position + (rig6HRP.Position - rig15HRP.Position) / 2
		--const camPos = pos + Vector3.new(0, 0, 8.1)
		--const camCF = CFrame.lookAt(
		--	camPos,
		--	pos
		--)
		--camera.CFrame = camCF
		
		--rig6HRP.CFrame = CFrame.lookAt(rig6HRP.Position, camPos)
		--rig15HRP.CFrame = CFrame.lookAt(rig15HRP.Position, camPos)
		--]]
		
		--const worldModel = C "WorldModel" {
		--	rig6,
		--	rig15
		--}
		
		--const viewport = (C :: any) "ViewportFrame" {
		--	Size = UDim2.fromScale(1, 1),
		--	Position = UDim2.fromScale(.5, .5),
		--	AnchorPoint = Vector2.new(.5, .5),
		--	BackgroundTransparency = 1,
		--	BorderSizePixel = 0,
		--	CurrentCamera = camera,
		--	worldModel,
		--	Archivable = true,
		--}
		
		
		
		
		
		const textLabel = Text {
			AutoSize = "None",
			XAlign = "Center",
			YAlign = "Center",
			RichText = true,
			Text = `<i>{name()}</i>`,
			Size = UDim2.new(1, 0, 0, TextYOffset),
			AnchorPoint = Vector2.new(.5, 0),
			Position = UDim2.fromScale(.5, 1),
		}
		
		const ImageScale = (C :: any) "UIScale" {
			Scale = 1,
		}
		
		const Image = C "ImageLabel" {
			Size = UDim2.fromScale(.75, .75),
			AnchorPoint = Vector2.one / 2,
			Position = UDim2.fromScale(.5, .5),
			BorderSizePixel = 0,
			BackgroundTransparency = 1,
			ImageScale,
		}
		
		const HitBox = C "TextButton" {
			BackgroundTransparency = 1,
			Text = "",
			BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 1) + UDim2.fromOffset(0, TextYOffset),
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.fromScale(0.5, 0),
			ZIndex = 9,
		}
		
		const main = Div({
			AnchorPoint = Vector2.new(xScale, 0),
			Size = UDim2.fromScale(ElementXScale, 1),
			Position = UDim2.new(xScale, 0, 0, yOffset()),
			AutoSize = "None",
			Children = {
				C "UIAspectRatioConstraint" {
					AspectRatio = 1,
				},
				textLabel,
				--viewport,
				Image,
				HitBox,
			},
		})
		main.ClipsDescendants = false
		
		const ggg = GreatUIButton(main, HitBox, {
			TweenInfo = TweenInfo.new(0.18),
			ImageLabel = {
				UIScale = {
					Scale = 1,
				},
			},
		} :: any)
			:SetAppearance("Hover", {
				TweenInfo = TweenInfo.new(0.18),
				ImageLabel = {
					UIScale = {
						Scale = 100/75,
					},
				},
			} :: any, true)
			:ApplyAppearance("Default")
		
		
		ggg.OnClick:Connect(function()
			selectedItemMetadata.Name = name()
			selectedItemMetadata.IsOutfit = true
			selectedItem(id())
			--applySelectionText(main, true)
		end)
		
		local isSelected = false
		
		local unseeSelection: () -> ()
		unseeSelection = O(selectedItem, function(selectedId: number, isDestroyed)
			isSelected = selectedId == id()
			if isSelected then
				applySelectionText(main, true)
			end
			if isDestroyed then
				unseeSelection()
			end
		end)
		
		
		-- Vide' C doesnt support Reaction, so Imma do it using an observer
		local unsee: () -> ()
		unsee = O(yOffset, function(value, isDestroyed)
			main.Position = UDim2.new(xScale, 0, 0, (value or 0) :: number)
			if isDestroyed then
				unsee()
			end
		end)
		--const text = Copy(function()
		--	return `{id()} <i>"{name()}"</i>`
		--end)
		
		
		
		--local updateThread: thread
		--local currentlyDisplayedId: number = -1
		--const function ApplyId(humDescId: number)
		--	if currentlyDisplayedId == humDescId then
		--		return
		--	end
			
		--	local getDetailsSuccess, getDetailsResult = pcall(AES.GetOutfitDetailsAsync, AES, humDescId)
		--	while not getDetailsSuccess do
		--		getDetailsSuccess, getDetailsResult = pcall(AES.GetOutfitDetailsAsync, AES, humDescId)
		--	end
			
		--	local success, humDesc = GetHumDesc(humDescId)
		--	while not success do
		--		task.wait(3)
		--		success, humDesc = GetHumDesc(humDescId)
		--	end
			
		--	const isR6 = getDetailsResult[`PlayerAvatarType`] ~= `R15`
		--	lookAtRig(isR6)
		--	const hum = if isR6 then rig6Hum else rig15Hum
			
			
			
		--	local applySuccess, applyResult = pcall(hum.ApplyDescriptionAsync, hum, humDesc, Enum.AssetTypeVerification.Default)
		--	while not applySuccess do
		--		applySuccess, applyResult = pcall(hum.ApplyDescriptionAsync, hum, humDesc, Enum.AssetTypeVerification.Default)
		--	end
			
		--	currentlyDisplayedId = humDescId
		--end
		
		local unseeIdChange: () -> ()
		unseeIdChange = O(id, function(humDescId: number, isDestroyed)
			--if updateThread then
			--	task.cancel(updateThread)
			--end
			--if currentlyDisplayedId == humDescId then
			--	return
			--end
			--updateThread = task.spawn(ApplyId, humDescId)
			if isSelected then
				selectedText.Visible = humDescId == selectedItem()
			end
			
			Image.Image = `rbxthumb://type=Outfit&id={humDescId}&w=420&h=420`
			
			if isDestroyed then
				unseeIdChange()
			end
		end)
		
		local unseeNameChange: () -> ()
		unseeNameChange = O(name, function(v: string, isDestroyed)
			textLabel.Text = `<i>{v}</i>`
			if isDestroyed then
				unseeNameChange()
			end
		end)
		
		--local unseeText: () -> ()
		--unseeText = O(text, function(value, isDestroyed)
		--	textLabel.Text = value :: string
		--	if isDestroyed then
		--		unseeText()
		--	end
		--end)
		main.Destroying:Once(function()
			unsee()
			unseeIdChange()
			Reaction.rmV(yOffset)
			Reaction.rmV(id)
			Reaction.rmV(name)
			--unseeText()
		end)
		
		main.Parent = sf
		
		const manager: ElementManager = {
			Id = id,
			Name = name,
			Main = main,
		}
		
		return main, manager
	end
	
	
	
	const rows: {[Row]: true} = {}
	local totalRows = 0
	local poolSize = 5
	local lastY = -999
	local lastAbsoluteSize = Vector2.zero
	local isUpdating = false
	local isPendingUpdate = false
	
	-- Update the data displayed by one pooled row.
	const function BindRow(row: Row, targetRow: number)
		const firstItemIndex = targetRow * RowSize

		for column, manager in row.Elements do
			const data = list[firstItemIndex + column]

			manager.Main.Visible = data ~= nil

			if data then
				manager.Id(data.id)
				manager.Name(data.name)
			end
		end
	end

	-- Create a new pooled row.
	const function CreateRow(): Row
		const yOffset = V(0)
		const _, left = element(yOffset, false)
		const _, right = element(yOffset, true)

		return {
			YOffset = yOffset,
			CurrentRow = -math.huge,
			Elements = {left, right},
		}
	end
	for i = 1, poolSize do
		rows[CreateRow()] = true
	end
	
	const function GetRequiredAndAvailableRows(y: number)
		const rangeStart = y - BufferSize
		const rangeEnd = rangeStart + poolSize - 1
		--print(rangeStart, rangeEnd)
		const availableRows: {Row} = {}
		const requiredRows: {[number]: boolean} = {}
		
		for i = rangeStart, rangeEnd do
			requiredRows[i] = true
		end
		for row in rows do
			const currentRow = row.CurrentRow
			if requiredRows[currentRow] then
				requiredRows[currentRow] = nil
				continue
			end
			table.insert(availableRows, row)
		end
		
		return requiredRows, availableRows
	end
	
	const function RepositionAllRows(rowYOffset: number)
		for row in rows do
			row.YOffset(row.CurrentRow * rowYOffset)
		end
	end
	const function CompleteUpdate(y: number, rowYOffset: number, isRepositioningRequired: boolean)
		const requiredRows, availableRows = GetRequiredAndAvailableRows(y)

		local i = 1
		const available = #availableRows
		for yy in requiredRows do
			if i > available then
				warn(`#requiredRows is bigger than #availableRows`)
				break
			end
			const row: Row = availableRows[i]
			row.CurrentRow = yy
			if not isRepositioningRequired then
				row.YOffset(yy * rowYOffset)
			end

			BindRow(row, yy)

			i += 1
		end
		
		if isRepositioningRequired then
			RepositionAllRows(rowYOffset)
		end

		isUpdating = false
	end

	const function Update()
		if isUpdating then
			isPendingUpdate = true
			return
		end
		isUpdating = true
		
		const absoluteSize = sf.AbsoluteSize
		if absoluteSize.X < 10 then
			isUpdating = false
			return
		end
		
		const elementYOffset = absoluteSize.X * ElementXScale + TextYOffset
		const paddingYOffset = absoluteSize.X * PaddingXScale
		const rowYOffset = elementYOffset + paddingYOffset
		
		--								(element height + padding) * (full rows - 1) + element height -- perfect airtight fit with no unecessary padding at the bottom
		-- edge case: with #list % RowSize == 0, it must actually be math.floor(#list / RowSize) - paddingYOffset or (math.floor(#list / RowSize) - 1) + elementYOffset
		sf.CanvasSize = UDim2.fromOffset(0, rowYOffset * totalRows + elementYOffset)
		sf.Visible = totalRows > 0
		
		if rowYOffset < 10 then
			isUpdating = false
			return
		end
		
		const y = math.floor(sf.CanvasPosition.Y / rowYOffset) -- row offset
		--const currentPoolSize = math.ceil(absoluteSize.Y / rowYOffset) + BufferSize * 2
		
		--if currentPoolSize ~= poolSize then
		--	isPendingUpdate = false
			
		--	if currentPoolSize > poolSize then
		--		for _ = poolSize + 1, currentPoolSize do
		--			rows[CreateRow()] = true
		--		end
		--		poolSize = currentPoolSize
		--		CompleteUpdate(y, rowYOffset)
		--	else
		--		poolSize = currentPoolSize
				
		--		const requiredRows, availableRows = GetRequiredAndAvailableRows(y)
				
		--		local i = 1
		--		const available = #availableRows
		--		for yy in requiredRows do
		--			if i > available then
		--				warn(`#requiredRows is bigger than #availableRows`)
		--				break
		--			end
		--			const row: Row = availableRows[i]
		--			row.CurrentRow = yy
		--			row.YOffset(yy * rowYOffset)

		--			BindRow(row, yy)

		--			i += 1
		--		end
				
		--		for a = i, available do
		--			const row: Row = availableRows[a]
		--			rows[row] = nil
					
		--			if row then
		--				for _, m in row.Elements do
		--					m.Main:Destroy()
		--				end
		--			end
		--		end
				
		--		isUpdating = false
		--	end
			
		--	if isPendingUpdate then
		--		isPendingUpdate = false
		--		Update()
		--	end
			
		--	return
		--end
		
		const isRepositioningRequired = lastAbsoluteSize ~= absoluteSize
		if lastY == y then
			if isRepositioningRequired then
				RepositionAllRows(rowYOffset)
			end
			isUpdating = false
			return
		end
		lastY = y
		
		CompleteUpdate(y, rowYOffset, isRepositioningRequired)
	end
	
	
	
	const function SetList(newList: {Item})
		list = newList
		
		const listLen = #list
		const floorRows = math.floor(listLen / RowSize)
		totalRows = listLen % RowSize == 0 and floorRows - 1 or floorRows
		
		for row in rows do
			BindRow(row, row.CurrentRow)
		end
		lastY = -999
		Update()
	end
	
	sf:GetPropertyChangedSignal("CanvasPosition"):Connect(Update)
	sf:GetPropertyChangedSignal("AbsoluteSize"):Connect(Update)
	Update()

	return sf, SetList
end