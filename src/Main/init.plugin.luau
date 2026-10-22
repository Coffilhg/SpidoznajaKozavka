--[[--
    SpidoznajaKozavka V0.0.0
    Copyright © 2026 Coffilhg (Roblox UserId 517222346)

    This is free and unencumbered software released into the public domain.
    https://unlicense.org

    GitHub Repository/Branch with latest version, documentation, etc:
    https://github.com/Coffilhg/SpidoznajaKozavka
    Stars are appreciated!
--]]--

--!strict
--!optimize 2

--- Services
const Selection = game:GetService(`Selection`)
--const TS = game:GetService(`TweenService`)
--const RunS = game:GetService(`RunService`)
const SES = game:GetService(`ScriptEditorService`)
const UIS = game:GetService(`UserInputService`)
const StudioService = game:GetService(`StudioService`)
const SS = game:GetService(`ServerStorage`)
const Players = game:GetService(`Players`)
const TS = game:GetService(`TweenService`)
const WS = game:GetService(`Workspace`)

--- Dependencies
const LemonSignal = require(`./Packages/LemonSignal`)
const NamespaceSync = require(`./Packages/NamespaceSync`)
const Vide = require(`./Packages/Vide`)
const C = Vide.create
const source = Vide.source
const effect = Vide.effect
const derive = Vide.derive
const GreatUIButton = require(`./Packages/GreatUIButton`)
const Components = require(`@self/Components`)
const PluginBigSettingsStoreService = require(`@self/PluginBigSettingsStoreService`)
const Style = require(`@self/Style`)
const RichGradient = require(`./Packages/RichGradient`)
const Reaction = require(`./Packages/Reaction`)
const HumanoidDescriptionUtils = require(`@self/HumanoidDescriptionUtils`)
const Linguistics = require(`@self/Linguistics`)

const autosuggestionSize = 10
const EmptyList = {}
const AvatarSpawnNullPoint = Vector3.zero

const Colors = Style.Colors
const RaindbowGradient = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 60, 60)),
	ColorSequenceKeypoint.new(1/6, Color3.fromRGB(255, 158, 60)),
	ColorSequenceKeypoint.new(2/6, Color3.fromRGB(255, 229, 60)),
	ColorSequenceKeypoint.new(3/6, Color3.fromRGB(67, 255, 60)),
	ColorSequenceKeypoint.new(4/6, Color3.fromRGB(60, 255, 223)),
	ColorSequenceKeypoint.new(5/6, Color3.fromRGB(60, 112, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(160, 60, 255)),
})
const PremiumGradient = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(160, 255, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 150, 255)),
})
const LoadOutfitsBaseText = RichGradient:Apply(`<b>Load outfits</b>`, PremiumGradient, true)
const RedGradient = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 100, 0)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 60, 40)),
})

--- Plugin Preparation
const PluginVersion: string = `0.0.0`
const PluginNamePascalCase: string = `SpidoznajaKozavka` -- Don't ask who suggested or how this name was chosen
const PluginId: string = `{PluginNamePascalCase}@{PluginVersion}`
local IsPluginStarted: boolean = false
const OnPluginStarted: LemonSignal.Signal<> = LemonSignal.new()

PluginBigSettingsStoreService:Init({
	ProjectName = PluginNamePascalCase,
	ProjectVersion = PluginVersion,
})

const Toolbar = plugin:CreateToolbar(`Load Avatars/Outfits by Username/UserId/Display Name ({PluginId})`)
const Button = Toolbar:CreateButton(
	PluginId,
	`Toggle Plugin (V{PluginVersion})`,
	`rbxassetid://106308295232965`, -- 135892409561312
	`SpidoznajaKozavka`
)
Button.ClickableWhenViewportHidden = true

const WidgetInfo = DockWidgetPluginGuiInfo.new(
	Enum.InitialDockState.Left,
	false,
	false,
	560,
	520,
	0,
	0
)

const Widget = plugin:CreateDockWidgetPluginGuiAsync(PluginId, WidgetInfo)
Widget.Name = PluginId
Widget.Title = PluginId
Widget.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

const OnWidgetEnabled = LemonSignal.new()
const OnWidgetDisabled = LemonSignal.new()

-- Driven off the actual property, not just our own toggle button: the
-- widget can also be opened/closed via Studio's own window controls (the
-- dock's own close button, the Window menu, a layout reset, etc.), none
-- of which go through Button.Click. Selection-change pooling (below)
-- needs OnWidgetEnabled to fire reliably no matter how the widget ends up
-- enabled, so this is the single source of truth for both signals.
Widget:GetPropertyChangedSignal(`Enabled`):Connect(function()
	if Widget.Enabled then
		OnWidgetEnabled:Fire()
	else
		OnWidgetDisabled:Fire()
	end
end)

Button.Click:Connect(function()
	const newEnabled = not Widget.Enabled
	Widget.Enabled = newEnabled

	if newEnabled and not IsPluginStarted then
		IsPluginStarted = true
		OnPluginStarted:Fire()
	end
end)




const GreatUIButtons: {GreatUIButton.GreatUIButton} = {}
const Ask = Components.Ask({
	Parent = Widget,
})
const StartPluginButton, StartPluginGUIB = Components.TextButton({
	Text = `Start Plugin @Coffilhg`,
	Size = UDim2.fromScale(.8, .8),
	ZIndex = 99,
})
StartPluginButton.Parent = Widget
StartPluginGUIB:ApplyAppearance("Default")










-- Await for user to start the plugin either manually (if the plugin was already open) or automatically (by opening the plugin if it wasnt open)
StartPluginButton.Activated:Once(function()
	if IsPluginStarted then
		StartPluginButton:Destroy()
		return
	end
	IsPluginStarted = true
	OnPluginStarted:Fire()
end)

-- Do heavy operations only once the plugin is explicitly started
if not IsPluginStarted then
	OnPluginStarted:Wait()
	if StartPluginButton then
		StartPluginButton:Destroy()
	end
end

const PluginSettings = PluginBigSettingsStoreService:GetStore(`Settings`)
const Privacy = PluginSettings:Get("Privacy Preferences", {
	FetchFindnAutocompleteByDisplayName = false,
	FetchOutfits = false,
})
const Avatar_Searching = PluginSettings:Get("Avatar_Searching", {
	ShowMarketplaceOutfits = false,
})
const Avatar_Import = PluginSettings:Get("Avatar_Import", {
	PlaceAtNullPoint = false,
})
local LastSettingsChangeThread: thread? = nil
const function SaveSettings()
	PluginSettings:Save()
end
const function SettingsUpdated()
	if LastSettingsChangeThread then
		task.cancel(LastSettingsChangeThread)
	end
	LastSettingsChangeThread = task.delay(6, SaveSettings)
end
const HTTP = require(`@self/HTTP`)



type Outfit = {name: string, id: number}
type OutfitList = {[number]: Outfit}



Vide.mount(function()
	local uiPageLayout: UIPageLayout
	const selectedItem = Reaction.V(0)
	const selectedItemMetadata = {
		Name = ``,
		IsOutfit = false,
	}

	const w, l = Components.LoopedPattern({
		-- 134355859369136
		-- 136182029381014 -- same as above, less saturated
		PatternRBXAssetId = `rbxassetid://136182029381014`, -- 96457678881606
		--SpeedMultiplier = 1.75,
	})

	l:Play()
	OnWidgetEnabled:Connect(function()
		l:Play()
	end)
	OnWidgetDisabled:Connect(function()
		l:Pause()
	end)
	
	const function dividerNewlines() -- top and bottom of `---` in md
		return Components.Text {
			Text = `\n\n`,
			Size = UDim2.new(1, 0, 0, 0),
			TextSize = 18,
		}
	end
	const function divider() -- display `---` in md
		return Components.Div {
			Size = UDim2.new(0.9, 0, 0, 0),
			Children = {},
			ShadowColor = Colors["Text (Primary)"],
		}
	end
	const function singleHashtag(text: string) -- # {text}
		return Components.Text {
			Text = RichGradient:Apply(text, Colors["Text (Primary)"], Colors["Backgroung"]),
			Size = UDim2.new(1, 0, 0, 12),
			TextSize = 18,
			XAlign = "Left",
			RichText = true,
		}
	end
	const function paragraph(text: string) -- just {text}
		return Components.Text {
			Text = text,
			Size = UDim2.new(1, 0, 0, 12),
			TextSize = 15,
			XAlign = "Left",
			RichText = true,
		}
	end
	
	

	const richOutput, richOutputPre, richOutputSF = Components.RichOutput {}
	
	local LastRequestedKeyword: string = ""
	local LastSearchedKeyword: string = ""
	const ActiveUID = source(517222346)
	const StartActiveNameSuccess, StartActiveName = pcall(Players.GetNameFromUserIdAsync, Players, 517222346)
	const ActiveName = source(if StartActiveNameSuccess then StartActiveName else `Coffilhg`)
	const ActiveIsVerified = source(false)
	const ActiveDisplayName = source(ActiveName())
	
	selectedItemMetadata.Name = ActiveName()
	selectedItemMetadata.IsOutfit = false
	selectedItem(ActiveUID())
	
	
	
	const SlopItBtn, SlopIt = Components.TextButton({
		Text = `Search`,
		Size = UDim2.new(0.2, 0, 1, 0),
		Position = UDim2.fromScale(1, 0.5),
		AnchorPoint = Vector2.new(1, 0.5),
		RichText = true,
	})
	SlopIt:SetAppearance(`Disabled`, {
		TweenInfo = TweenInfo.new(0.5),
		BackgroundColor3 = Colors["Yellow"],
		TextColor3 = Colors["Text (Inverted)"],
	}, true)
	table.insert(GreatUIButtons, SlopIt)
	const AutocompleteOptions: { Frame | UIListLayout | Instance } = {
		Components.UIListLayout {Padding = UDim.new(0, 3)},
	}
	const AutocompleteOptionsValues: {[number]: {
		displayName: Vide.Source<string>,
		hasVerifiedBadge: Vide.Source<boolean>,
		id: Vide.Source<number>,
		name: Vide.Source<string>,
		previousUsernames: ({string}?) -> (),
	}} = {}
	
	
	
	
	
	
	
	
	
	
	
	
	const MainProfileHitBox = C "TextButton" {
		BackgroundTransparency = 1,
		Text = "",
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		ZIndex = 9,
	}
	const MainProfile, SetMainProfilePreviousUsernames = Components.PlayerProfile({
		Size = UDim2.new(1, 0, 0, 64),
		UserId = ActiveUID,
		ThumbnailType = "Avatar",
		ThumbnailSize = "180",
		DisplayUsername = ActiveName,
		Username = ActiveName,
		HasVerifiedBadge = ActiveIsVerified,
	})
	MainProfileHitBox.Parent = MainProfile
	
	
	
	const playerAvatarType = source(`Loading`)
	const isAnOutfit = source(false)
	
	local loadSelectedId = 0
	const function loadSelected(isR6: boolean?)
		loadSelectedId += 1
		const thisLoadSelectedId = loadSelectedId
		const isOutfit = isAnOutfit()
		const thisSelectedItem = selectedItem()
		const thisName = isOutfit and `{ActiveName()} | {selectedItemMetadata.Name}` or `{ActiveName()}`

		const getHumDescApi = isOutfit and HumanoidDescriptionUtils.GetOutfit or HumanoidDescriptionUtils.GetHumDesc

		local successGetHumDesc, resultGetHumDesc = getHumDescApi(thisSelectedItem)
		while not successGetHumDesc do
			successGetHumDesc, resultGetHumDesc = getHumDescApi(thisSelectedItem)
		end

		const calledAPI = Players.CreateHumanoidModelFromDescriptionAsync
		const rigType = Enum.HumanoidRigType[isR6 and "R6" or "R15"]
		const assetTypeVerification = Enum.AssetTypeVerification.ClientOnly

		local successCreateHumanoidModelFromDescriptionAsync, resultCreateHumanoidModelFromDescriptionAsync = pcall(calledAPI, Players, resultGetHumDesc, rigType, assetTypeVerification)
		while not successCreateHumanoidModelFromDescriptionAsync do
			successCreateHumanoidModelFromDescriptionAsync, resultCreateHumanoidModelFromDescriptionAsync = pcall(calledAPI, Players, resultGetHumDesc, rigType, assetTypeVerification)
		end
		
		const humanoidOfResultCreateHumanoidModelFromDescriptionAsync = resultCreateHumanoidModelFromDescriptionAsync:FindFirstChildOfClass(`Humanoid`)
		if humanoidOfResultCreateHumanoidModelFromDescriptionAsync then
			(humanoidOfResultCreateHumanoidModelFromDescriptionAsync :: Humanoid).DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		else
			richOutput:Warn(`<i>Humanoid</i> of the imported avatar not found, couldn't hide it's display name by setting <i>DisplayDistanceType</i> to <i>None</i>`)
		end
		const hrpOfResultCreateHumanoidModelFromDescriptionAsync = resultCreateHumanoidModelFromDescriptionAsync:FindFirstChild(`HumanoidRootPart`)
		if hrpOfResultCreateHumanoidModelFromDescriptionAsync then
			local pos = AvatarSpawnNullPoint
			if not Avatar_Import.PlaceAtNullPoint then
				const camera = WS.CurrentCamera
				if camera then
					pos = camera.CFrame.Position + camera.CFrame.LookVector * 9
				else
					richOutput:Warn(`<i>Camera</i> not found, falling back to \`Vector3.new({AvatarSpawnNullPoint})\` for avatar import`)
				end
			end
			
			(hrpOfResultCreateHumanoidModelFromDescriptionAsync :: Part).Position = pos
		end
		-- for some reason CreateHumanoidModelFromDescriptionAsync with R6 makes all BaseParts.Locked = true; Not the case with R15, so we have to fix that!
		if isR6 then
			for _, ch in resultCreateHumanoidModelFromDescriptionAsync:GetChildren() do
				if ch:IsA(`BasePart`) then
					ch.Locked = false
				end
			end
		end
		resultCreateHumanoidModelFromDescriptionAsync.Name = thisName
		resultCreateHumanoidModelFromDescriptionAsync.Parent = WS

		if thisLoadSelectedId ~= loadSelectedId then
			return
		end
		Selection:Set({resultCreateHumanoidModelFromDescriptionAsync})
	end
	
	
	
	const selectedText = Components.Text {
		RichText = true,
		Size = UDim2.fromScale(.9, .2),
		AnchorPoint = Vector2.new(.5, 1),
		Position = UDim2.fromScale(.5, 1),
		AutoSize = "None",
		Text = Vide.derive(function()
			return `<b>{isAnOutfit() and `Outfit` or `Current Avatar`} Selected ✅ ({playerAvatarType()})</b>`
		end),
		Children = {
			(C :: any) "UIStroke" {
				Color = Color3.fromRGB(21, 21, 21),
				StrokeSizingMode = Enum.StrokeSizingMode.FixedSize,
				Thickness = 3,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
			},
			Components.UIPadding({UDim.new(.1, 0), 0, 0, 0}),
		},
	}
	
	const hideSelectedText = TS:Create(
		selectedText,
		TweenInfo.new(.24, Enum.EasingStyle.Back, Enum.EasingDirection.In, 0, false, 0),
		{
			Size = UDim2.fromScale(0, 0),
		}
	)
	const showSelectedOutfitText = TS:Create(
		selectedText,
		TweenInfo.new(.39, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0),
		{
			AnchorPoint = Vector2.new(.5, 1),
			Position = UDim2.fromScale(.5, 1),
			Size = UDim2.fromScale(.9, .21),
		}
	)
	const showSelectedAppearanceText = TS:Create(
		selectedText,
		TweenInfo.new(.39, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0),
		{
			AnchorPoint = Vector2.new(.5, 0),
			Position = UDim2.fromScale(.5, 1.11),
			Size = UDim2.fromScale(.9, .36),
		}
	)
	
	const newlinesAfterMainProfile = Components.Text {
		Text = `\n`,
		Size = UDim2.new(1, 0, 0, 0),
		TextSize = 18,
	}
	
	local currentAnimId = 0
	local lastIsAutomaticApplySelectionText: boolean = false
	local lastSelectedItemDuringApplySelectionText = -1
	-- isAutomatic shall be true when this function was not called as aresult of user input
	const function applySelectionText(newParent, isForOutfit, isAutomatic: boolean?)
		--newlinesAfterMainProfile.Visible = not isForOutfit
		-- clicking (as in user input) again loads the intended rig type of selectedItem
		-- edge case - wrong when the parent is element of the VirtualList
		-- fix - track lastSelectedItem
		if newParent == selectedText.Parent and lastSelectedItemDuringApplySelectionText == selectedItem() and not (isAutomatic or lastIsAutomaticApplySelectionText) then
			const avatarType = playerAvatarType()
			const isR6 = avatarType == `R6`
			-- contradiction to this check = invalid type (still Loading) | don't trigger load
			if isR6 or (avatarType == `R15` and not isR6) then
				loadSelected(isR6)
				return
			end
		end
		lastIsAutomaticApplySelectionText = not not isAutomatic
		lastSelectedItemDuringApplySelectionText = selectedItem()
		--print("Reparenting to", newParent, isForOutfit)
		currentAnimId += 1
		const thisAnimationId = currentAnimId
		-- Hide text
		--selectedText:TweenSize(UDim2.new(0, 0, 0, 0), "In", "Back", 0.25, true)
		hideSelectedText:Play()
		task.delay(0.3, function()
			selectedText.Visible = true
			if thisAnimationId == currentAnimId then
				--selectedText.Text = isForOutfit and "<b>Outfit Selected ✅</b>" or "<b>Appearance Selected ✅</b>"
				selectedText.Parent = newParent
				if isForOutfit then
					showSelectedOutfitText:Play()
				else
					showSelectedAppearanceText:Play()
				end
				--selectedText:TweenSize(UDim2.fromScale(isForOutfit and .4 or .9, .2), "Out", "Back", 0.4, true)
			end
			--print(NewMorphId, NewOutfitId, NewGameOutfitCmdName)
		end)
		
		playerAvatarType(`Loading`)
		isAnOutfit(isForOutfit)
		const isR6 = if isForOutfit then HumanoidDescriptionUtils.IsOutfitR6(selectedItem()) else HumanoidDescriptionUtils.IsHumDescR6(selectedItem())
		--print(isR6)
		if thisAnimationId ~= currentAnimId then
			return
		end
		if isR6 then
			playerAvatarType(`R6`)
			--print(`R6`)
			return
		end
		playerAvatarType(`R15`)
		--print(`R15`)
	end

	const function resetSelectionText(isAutomatic: boolean?)
		applySelectionText(MainProfile, false, isAutomatic)
	end
	resetSelectionText() -- treat plugin load as user input
	
	
	
	
	
	
	const MainProfileHitBoxGUIBtn = GreatUIButton(MainProfile, MainProfileHitBox, {
		TweenInfo = TweenInfo.new(.21),
		BackgroundColor3 = Colors[`Div`],
	})
		:SetAppearance("Hover", {
			TweenInfo = TweenInfo.new(.21),
			BackgroundColor3 = Colors[`Hover`],
		}, true)
		:ApplyAppearance("Default")
		.OnClick:Connect(function()
			selectedItemMetadata.Name = ActiveName()
			selectedItemMetadata.IsOutfit = false
			selectedItem(ActiveUID())
			resetSelectionText() -- obvious user input
		end)
	
	const LoadOutfits, LoadOutfitsGreat = Components.TextButton {
		Size = UDim2.new(1, 0, 0, 32),
		Text = LoadOutfitsBaseText,
		RichText = true,
	}

	const vl, setVl = Components.VirtualList {
		Size = UDim2.new(1, 0, 0, 300),
		SelectedItem = selectedItem,
		SelectedItemMetadata = selectedItemMetadata,
		SelectedText = selectedText,
		ApplySelectionText = applySelectionText,
	}
	
	const ResetOutfitsCache, ResetOutfitsCacheGreat = Components.TextButton {
		Size = UDim2.new(1, 0, 0, 32),
		Text = RichGradient:Apply(`Reset Outfits Cache`, RedGradient, true),
		RichText = true,
	}

	-- test
	--[[
	task.delay(1, function()
		setVl({
			{
				id = 11,
				name = "foo",
			},
			{
				id = 12,
				name = "bar",
			},
			{
				id = 21,
				name = "bird",
			},
			{
				id = 22,
				name = "car",
			},
			{
				id = 31,
				name = "hello",
			},
			{
				id = 32,
				name = "world",
			},
			{
				id = 41,
				name = "heart",
			},
			{
				id = 42,
				name = "apple",
			},
			{
				id = 51,
				name = "ban",
			},
			{
				id = 52,
				name = "idk",
			},
			{
				id = 61,
				name = "ban",
			},
			{
				id = 62,
				name = "idk",
			},
			{
				id = 71,
				name = "ban",
			},
			{
				id = 72,
				name = "idk",
			},
			{
				id = 81,
				name = "ban",
			},
			{
				id = 82,
				name = "idk",
			},
			{
				id = 91,
				name = "ban",
			},
			{
				id = 92,
				name = "idk",
			},
			{
				id = 101,
				name = "ban",
			},
		})
	end)
	--]]
	
	local AutocompleteOptionsSF: ScrollingFrame
	
	for i = 1, autosuggestionSize do
		const uid = source(517222346)
		const dispName = source("SubToCoffing")
		const trueName = source("Coffilhg")
		const isVerity = source(false)
		local thisPreviousUsernames = {}
		const profile, profileSetPreviousUsernames = Components.PlayerProfile {
			Size = UDim2.new(1, 0, 0, 64),
			UserId = uid,
			ThumbnailType = "AvatarBust",
			ThumbnailSize = "100",
			DisplayUsername = dispName,
			Username = trueName,
			HasVerifiedBadge = isVerity,
		}
		profile.Visible = false
		table.insert(AutocompleteOptions, profile)
		table.insert(AutocompleteOptionsValues, {
			displayName = dispName,
			hasVerifiedBadge = isVerity,
			id = uid,
			name = trueName,
			previousUsernames = function(previousUsernames: {string}?)
				profileSetPreviousUsernames(previousUsernames)
				thisPreviousUsernames = previousUsernames
			end,
		})
		
		const HitBox = C "TextButton" {
			BackgroundTransparency = 1,
			Text = "",
			BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 1),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			ZIndex = 9,
		}
		HitBox.Parent = profile
		
		const gp = GreatUIButton(profile, HitBox, {
			TweenInfo = TweenInfo.new(.3),
			BackgroundColor3 = Colors["Div"],
		}):SetAppearance("Hover", {
			TweenInfo = TweenInfo.new(.3),
			BackgroundColor3 = Colors["Hover"],
		}, true)
		
		gp.OnClick:Connect(function()
			ActiveUID(uid())
			ActiveName(trueName())
			LoadOutfits.Text = LoadOutfitsBaseText
			setVl(EmptyList)
			selectedItem(ActiveUID())
			resetSelectionText(true) -- semi-automated input, mark as automatic to prevent loading unless user really wants to
			-- this stuff is known (yay!)
			ActiveDisplayName(dispName())
			ActiveIsVerified(isVerity())
			SetMainProfilePreviousUsernames(thisPreviousUsernames)
			AutocompleteOptionsSF.Visible = false
		end)
		
	end
	const AutocompleteOptionsInfo = Components.Text {
		Text = `Nothing else to show!`,
		RichText = true,
	}
	AutocompleteOptionsInfo.Visible = false
	table.insert(AutocompleteOptions, AutocompleteOptionsInfo)
	table.insert(AutocompleteOptions, dividerNewlines())
	table.insert(AutocompleteOptions, divider())
	--table.insert(AutocompleteOptions, dividerNewlines())
	table.insert(AutocompleteOptions, Components.Text {
		Text = `Nothing else to show!`
	})
	AutocompleteOptionsSF = Components.ScrollingFrame {
		--AnchorPoint = Vector2.new(0, 1),
		Size = UDim2.new(1, 12, 0, 72),
		--Position = UDim2.fromScale(0, 1),
		Direction = "Y",
		Children = AutocompleteOptions,
	}
	AutocompleteOptionsSF.Visible = false
	const function ToggleAutocomplete()
		AutocompleteOptionsSF.Visible = not AutocompleteOptionsSF.Visible
	end
	const ToggleAutocompleteSF, ToggleAutocompleteSFGreat = Components.TextButton {
		Size = UDim2.new(1, 0, 0, 32),
		Text = `Toggle (<i>Show/Hide</i>) Autocomplete Options`,
		RichText = true,
	}
	ToggleAutocompleteSFGreat.OnClick:Connect(ToggleAutocomplete)
	const UsernameInput, UsernameInputApply = Components.PreNoWrap {
		Size = UDim2.new(0.8, 0, 0, 64),
		AnchorPoint = Vector2.zero,
		Position = UDim2.fromScale(0, 0),
		Placeholder = "Username, UserId or Display Name",
	}
	
	
	
	-- remember to table.unpack at the end of the list for everything to unpack correctly!
	const function CreateCheckboxAtCategoryForField<T>(
		category: PluginBigSettingsStoreService.PluginProfile<T>,
		field: keyof<T>
	): {Instance}
		const check, checkHitbox, checkConfing = Components.Checkbox({})
		checkConfing.DataState(category[field])
		checkConfing.OnToggled:Connect(function()
			category[field] = checkConfing.DataState()
			SettingsUpdated()
		end)
		return {checkHitbox, check}
	end
	
	const function MakeCheckboxDiv(description: string, createCheckboxResult: {Instance})
		return Components.Div {
			Size = UDim2.new(1, 0, 0, 32),
			AutoSize = "Y",
			Children = {
				Components.UIPadding({6}),
				Components.Text {
					AutoSize = "Y",
					Text = description,
					Size = UDim2.new(0.8, 0, 0, 0),
					Position = UDim2.fromScale(0, 0),
					AnchorPoint = Vector2.new(0, 0),
					YAlign = "Top",
					XAlign = "Left",
					RichText = true,
				},
				table.unpack(createCheckboxResult)
			},
		}
	end
	
	const outfitsCheck, outfitsCheckHitBox, outfitsCheckConfig = Components.Checkbox({})
	outfitsCheckConfig.DataState(Privacy.FetchOutfits)
	outfitsCheckConfig.OnToggled:Connect(function()
		Privacy.FetchOutfits = outfitsCheckConfig.DataState()
		SettingsUpdated()
	end)
	----print("---")
	--const _, _, autocompleteNameCheckConfig = Components.Checkbox({})
	--autocompleteNameCheckConfig.DataState(Privacy.FetchFindnAutocompleteByDisplayName)
	--autocompleteNameCheckConfig.OnToggled:Connect(function()
	--	Privacy.FetchFindnAutocompleteByDisplayName = autocompleteNameCheckConfig.DataState()
	--	SettingsUpdated()
	--end)
	----print(Privacy)
	----print(outfitsCheckConfig.DataState(), autocompleteNameCheckConfig.DataState())
	--const _, _, showMarketplaceOutfitsCheckConfig = Components.Checkbox({})
	--showMarketplaceOutfitsCheckConfig.DataState(Avatar_Searching.ShowMarketplaceOutfits)
	--showMarketplaceOutfitsCheckConfig.OnToggled:Connect(function()
	--	Avatar_Searching.ShowMarketplaceOutfits = showMarketplaceOutfitsCheckConfig.DataState()
	--	SettingsUpdated()
	--end)
	--const _, _, showMarketplaceOutfitsCheckConfig = Components.Checkbox({})
	--showMarketplaceOutfitsCheckConfig.DataState(Avatar_Import.PlaceAtNullPoint)
	--showMarketplaceOutfitsCheckConfig.OnToggled:Connect(function()
	--	Avatar_Import.PlaceAtNullPoint = showMarketplaceOutfitsCheckConfig.DataState()
	--	SettingsUpdated()
	--end)
	
	
	
	const function UnlockSearch()
		SlopIt.IsVisuallyResponsive = true
		SlopIt:ApplyAppearance()
		SlopItBtn.Text = `Search`
	end
	local UnlockSearchThread: thread = task.delay(0, UnlockSearch)
	const function InitUnlockSearchThread(t: number?)
		task.cancel(UnlockSearchThread)
		UnlockSearchThread = task.delay(t or 2.7, UnlockSearch)
	end
	const function TryAutocomplete(trimmedInput: string)
		if trimmedInput == LastRequestedKeyword then
			return
		end
		const success, response: HTTP.UsersByNameResponse = HTTP:Fetch(
			HTTP.Links.UsersByName.Format(trimmedInput, autosuggestionSize),
			true,
			true
		)
		AutocompleteOptionsSF.CanvasPosition = Vector2.zero
		if not success then
			AutocompleteOptionsSF.Visible = false
			AutocompleteOptionsInfo.Visible = true
			for _, autocompleteOption in AutocompleteOptions do
				if autocompleteOption:IsA(`Frame`) then
					autocompleteOption.Visible = false
				end
			end
			const info = `Couldn't autocomplete/search for "<i>{trimmedInput}</i>", reason: {response == nil and `unknown` or response};\nRetry by clicking "Search" again!`
			AutocompleteOptionsInfo.Text = `<b>{RichGradient:Apply(info, Color3.fromRGB(245, 118, 48), Color3.fromRGB(245, 160, 48))}</b>`
			richOutput:Warn(info)
			return
		end
		
		AutocompleteOptionsInfo.Visible = false
		LastRequestedKeyword = trimmedInput
		const data = response.data
		for i, autocompleteOptionValues in AutocompleteOptionsValues do
			const details = data[i]
			const autocompleteOption = AutocompleteOptions[i+1]
			if autocompleteOption and autocompleteOption:IsA(`Frame`) then
				autocompleteOption.Visible = not not details
			end
			if not details then
				continue
			end
			autocompleteOptionValues.displayName(details.displayName)
			autocompleteOptionValues.hasVerifiedBadge(details.hasVerifiedBadge)
			autocompleteOptionValues.id(details.id)
			autocompleteOptionValues.name(details.name)
			autocompleteOptionValues.previousUsernames(details.previousUsernames)
		end
		AutocompleteOptionsSF.Visible = true
		--print(response)
	end
	const function ApplyUsernameInput(bypass: true?)
		SlopIt.IsVisuallyResponsive = false
		SlopIt:ApplyAppearance()
		SlopItBtn.Text = `Searching...`
		
		const rawInput = UsernameInput.Text
		const trimmedInput = string.match(rawInput, `^%s*(.-)%s*$`) :: string -- this match pattern can never fail as long as the input is a string
		
		if trimmedInput == "" then
			SlopItBtn.Text = `Empty search!`
			InitUnlockSearchThread()
			return
		end
		
		if not bypass and (
			string.lower(trimmedInput) == string.lower(ActiveName()) or
				string.lower(trimmedInput) == `{ActiveUID()}` or
				string.lower(trimmedInput) == string.lower(ActiveDisplayName())
			) then
			SlopItBtn.Text = `Already Displaying`
			InitUnlockSearchThread()
			return
		end
		
		
		
		-- basic number input, e.g. 123, 123.4, -432.1, -321
		if trimmedInput:match(`^[%+%-]?%d+%.?%d*$`) then
			const inputNumber = tonumber(trimmedInput) :: number -- it matches the above pattern, therefore a number
			const uid = math.abs(math.round(inputNumber))
			const success, fromUIDName = pcall(Players.GetNameFromUserIdAsync, Players, uid)
			if not success then
				InitUnlockSearchThread(1.35)
				SlopItBtn.Text = `<b><font color="#f57630">NOT Found!</font></b> By UID \`{uid}\``
				return
			end
			InitUnlockSearchThread()
			SlopItBtn.Text = `Found! By UID \`{uid}\``
			ActiveUID(uid)
			ActiveName(fromUIDName)
			LoadOutfits.Text = LoadOutfitsBaseText
			setVl(EmptyList)
			selectedItem(ActiveUID())
			resetSelectionText(true) -- semi-automated input, mark as automatic to prevent loading unless user really wants to
			-- those are unknown unless quieried additionally, so reset
			ActiveDisplayName(fromUIDName)
			ActiveIsVerified(false)
			SetMainProfilePreviousUsernames(nil)
			return
		end
		
		if Privacy.FetchFindnAutocompleteByDisplayName == true then
			task.spawn(TryAutocomplete, trimmedInput)
		end
		
		const success, fromNameUID = pcall(Players.GetUserIdFromNameAsync, Players, trimmedInput)
		if not success then
			InitUnlockSearchThread(1.35)
			SlopItBtn.Text = `<b><font color="#f57630">NOT Found!</font></b> By Username "{trimmedInput}"`
			return
		end
		InitUnlockSearchThread()
		SlopItBtn.Text = `Found! By Username "{trimmedInput}"`
		ActiveUID(fromNameUID)
		ActiveName(trimmedInput)
		LoadOutfits.Text = LoadOutfitsBaseText
		setVl(EmptyList)
		selectedItem(ActiveUID())
		resetSelectionText(true) -- semi-automated input, mark as automatic to prevent loading unless user really wants to
		-- those are unknown unless quieried additionally, so reset
		ActiveDisplayName(trimmedInput)
		ActiveIsVerified(false)
		SetMainProfilePreviousUsernames(nil)
	end
	SlopIt.OnPressStart:Connect(function()
		if not SlopIt.IsVisuallyResponsive then
			return
		end
		ApplyUsernameInput(true)
	end)
	local LastUsernameInputChangedThread: thread? = nil
	const function UsernameInputChanged()
		if LastUsernameInputChangedThread then
			task.cancel(LastUsernameInputChangedThread)
		end
		LastUsernameInputChangedThread = task.delay(0.81, ApplyUsernameInput, nil)
	end
	UsernameInput:GetPropertyChangedSignal(`Text`):Connect(UsernameInputChanged)
	
	const LoadAsR6, L6G = Components.TextButton {
		Size = UDim2.new(.45, 0, 1, 0),
		Position = UDim2.fromScale(0.225, .5),
		Text = `Load as R6`,
	}
	const LoadAsR15, L15G = Components.TextButton {
		Size = UDim2.new(.45, 0, 1, 0),
		Position = UDim2.fromScale(1-.225, .5),
		Text = `Load as R15`,
	}
	L6G.OnClick:Connect(function()
		loadSelected(true)
	end)
	L15G.OnClick:Connect(function()
		loadSelected(false)
	end)
	const LoadAsDiv = Components.Div {
		Size = UDim2.new(1, 0, 0, 32),
		Children = {LoadAsR6, LoadAsR15},
	}
	
	const LoadedOutfitsCache: {[number]: {LoadedData: OutfitList, PaginationToken: string?}} = {}
	local LoadingOutfitsId: number = 0
	local LastLoadingOutfitsFor: number?
	LoadOutfitsGreat.OnClick:Connect(function()
		const requestedUID = ActiveUID()
		if not Privacy.FetchOutfits then
			const questionId = Ask:Ask(
				`Please allow making http requests to <font color="#{Colors["Text (Darker - Placeholder/Off)"]:ToHex()}">\`{HTTP.Links.Outfits.Read}\`</font>\nOtherwise you can only get the current avatar of {ActiveDisplayName()}`,
				`Deny`,
				`Allow`
			)
			local approved, answerId = Ask.OnAnswer:Wait()
			
			while answerId ~= questionId and not Privacy.FetchOutfits do
				if answerId > questionId then
					-- the question was already answered and we missed it (idk how, but it's good to handle this)
					break
				end
				approved, answerId = Ask.OnAnswer:Wait() -- keep awaiting until it's our question' answer status
			end
			
			if not (Privacy.FetchOutfits or approved) then
				return
			end
			outfitsCheckConfig.DataState(true)
		end
		
		if LastLoadingOutfitsFor == requestedUID then
			return
		end
		
		LastLoadingOutfitsFor = requestedUID
		LoadingOutfitsId += 1
		const thisLoadingOutfitsId = LoadingOutfitsId
		
		LoadOutfits.Text = RichGradient:Apply(`<b>Loading outfits</b>`, PremiumGradient, true)
		
		const formLink = HTTP.Links.Outfits.Format
		local loadedData = {}
		local paginationToken: string?
		const pageSize = 100
		--local pagesLoaded = 0
		--local lastResponseData: HTTP.OutfitsByUserIdResponseData
		--local currentResponseData: HTTP.OutfitsByUserIdResponseData
		
		const function cacheLoaded()
			const cache = LoadedOutfitsCache[requestedUID]
			if cache then
				-- loadedData is mutated already
				cache.PaginationToken = paginationToken
				return
			end
			-- placeholder
			LoadedOutfitsCache[requestedUID] = {
				LoadedData = loadedData,
				PaginationToken = paginationToken,
			}
		end
		
		const function addData(responseData: HTTP.OutfitsByUserIdResponseData)
			for _, outfit in responseData do
				table.insert(loadedData, {
					name = outfit.name,
					id = outfit.id,
				})
			end
		end
		
		const cache = LoadedOutfitsCache[requestedUID]
		if cache then
			loadedData = cache.LoadedData
			paginationToken = cache.PaginationToken
		end
		const loadedFromCacheAmount = #loadedData
		
		local success, response: HTTP.OutfitsByUserIdResponse
		local attempts: number = 1
		const isEditable = if Avatar_Searching.ShowMarketplaceOutfits == true then nil else true
		
		if type(paginationToken) ~= `string` or #loadedData < 1 then
			const firstLink = formLink(requestedUID, pageSize, nil, "Avatar", isEditable)
			success, response = HTTP:Fetch(firstLink, true, true)
			-- test abortion mid-first-loop whether the return actually exits the entire function; (yes it does)
			--success = false
			--response = nil
			--print(success, response)
			while not success do
				if LoadingOutfitsId ~= thisLoadingOutfitsId or requestedUID ~= ActiveUID() then
					--cacheLoaded()
					-- nothing was actually loaded
					LastLoadingOutfitsFor = nil
					return
				end
				attempts += 1
				LoadOutfits.Text = RichGradient:Apply(`<b>Loading outfits | attempt #{attempts}</b>`, PremiumGradient, true)
				task.wait(3)
				success, response = HTTP:Fetch(firstLink, true, true)
				-- test abortion mid-first-loop whether the return actually exits the entire function; (yes it does)
				--success = false
				--response = nil
				--print(success, response)
			end
			
			-- since test abortion mid-first-loop does exit the whole function
			-- no need to cacheLoaded here in a way how it's done below on abort

			--currentResponseData = response.data
			paginationToken = response.paginationToken
			addData(response.data)
			--table.insert(loadedData, response.data)
		end
		
		if LoadingOutfitsId ~= thisLoadingOutfitsId or requestedUID ~= ActiveUID() then
			cacheLoaded()
			LastLoadingOutfitsFor = nil
			return
		end
		
		local outfitsAmount = #loadedData
		
		while paginationToken ~= "" do
			if LoadingOutfitsId ~= thisLoadingOutfitsId or requestedUID ~= ActiveUID() then
				cacheLoaded()
				break
			end
			success = false
			attempts = 0
			while not success do
				if LoadingOutfitsId ~= thisLoadingOutfitsId or requestedUID ~= ActiveUID() then
					cacheLoaded()
					break
				end
				attempts += 1
				LoadOutfits.Text = RichGradient:Apply(`<b>Loading outfits | {outfitsAmount} loaded | attempt #{attempts}</b>`, PremiumGradient, true)
				if attempts > 1 then
					task.wait(3)
				end
				success, response = HTTP:Fetch(formLink(requestedUID, pageSize, paginationToken, "Avatar", isEditable), true, true)
				--print(success, response)
			end
			
			-- prevent response.data being nil mid-abort
			if (not success) and (LoadingOutfitsId ~= thisLoadingOutfitsId or requestedUID ~= ActiveUID()) then
				cacheLoaded()
				break
			end
			
			--lastResponseData = currentResponseData
			--currentResponseData = response.data
			paginationToken = response.paginationToken
			addData(response.data)
			outfitsAmount = #loadedData
			--table.insert(loadedData, response.data)
		end
		LastLoadingOutfitsFor = nil
		if LoadingOutfitsId ~= thisLoadingOutfitsId or requestedUID ~= ActiveUID() then
			cacheLoaded()
			return
		end
		
		--print(loadedData)
		-- shall I cacheLoaded here too? I guess
		cacheLoaded()
		
		LoadOutfits.Text = RichGradient:Apply(`<b>Loaded {outfitsAmount} outfit{Linguistics:WordPerAmount(outfitsAmount)}{(loadedFromCacheAmount > 0 or cache) and ` | {loadedFromCacheAmount} from Cache` or ``}{outfitsAmount < 1 and `\nIs their <i>Inventory visibility</i> set to <i>Everyone</i>?` or ``}</b>`, PremiumGradient, true)
		
		setVl(loadedData)
		
	end)
	
	ResetOutfitsCacheGreat.OnClick:Connect(function()
		table.clear(LoadedOutfitsCache)
	end)
	
	
	
	
	
	
	
	
	const MainSF = Components.ScrollingFrame {
		Direction = "Y",
		Children = {
			Components.UIListLayout {
				XAlign = "Left",
			},
			Components.UIPadding {},
			Components.Div {
				Size = UDim2.new(1, 0, 0, 64),
				AutoSize = "Y",
				Children = {
					SlopItBtn,
					UsernameInput,
				},
			},
			ToggleAutocompleteSF,
			AutocompleteOptionsSF,
			--Components.Text {
			--	Text = `Start by typing the Username or the UserId\n<i>(Display name too, if the such option is enabled in settings)</i>\nClick Search if it feels like the script hasn't caught on!`,
			--	Size = UDim2.new(1, 0, 0, 12),
			--	TextSize = 15,
			--	XAlign = "Left",
			--	RichText = true,
			--},
			Components.Text {
				RichText = true,
				Text = `<b>Tips</b>:\n\n<b>|</b> Scroll over the background to discover more tabs or use the above navigation\n\n<b>|</b> Click again after selecting to load as the inteded RigType of the avatar/outfit (doesn't work if RigType is still loading)`,
				Color = Colors["Text (Darker - Placeholder/Off)"],
				Size = UDim2.new(1, 0, 0, 12),
				XAlign = "Left",
			},
			LoadAsDiv,
			MainProfile,
			newlinesAfterMainProfile,
			LoadOutfits,
			vl,
			ResetOutfitsCache,
		},
	}
	
	const SettingsSF = Components.ScrollingFrame {
		Direction = "Y",
		Children = {
			Components.UIListLayout {},
			Components.UIPadding {},
			singleHashtag(`<b>Privacy Settings</b>`),
			MakeCheckboxDiv(
				`<b>Allow making http requests to <i>\`{RichGradient:Apply(HTTP.Links.Outfits.Read, RaindbowGradient, true)}\`</i>?</b>\nThis is necessary for the ability to load all outfits.\nWithout this option enabled only the current avatar can be loaded`,
				{
					outfitsCheckHitBox,
					outfitsCheck
				}
			),
			MakeCheckboxDiv(
				`<b>Allow making http requests to <i>\`{RichGradient:Apply(HTTP.Links.UsersByName.Read, RaindbowGradient, true)}\`</i>?</b>\nThis is necessary for the ability to\n<b>- search for Players by Display Name</b>\n- show autocomplete for usernames`,
				CreateCheckboxAtCategoryForField(
					Privacy,
					"FetchFindnAutocompleteByDisplayName"
				)
			),
			singleHashtag(`<b>Avatar Search</b>`),
			MakeCheckboxDiv(
				`<b>Should the <i>{LoadOutfitsBaseText}</i> button also load purchased Marketplace outfits (usually bundles by Roblox)?</b>\nTechnically this means to show all outfits instead of only those with isEditable = true`,
				CreateCheckboxAtCategoryForField(
					Avatar_Searching,
					"ShowMarketplaceOutfits"
				)
			),
			singleHashtag(`<b>Avatar Import</b>`),
			MakeCheckboxDiv(
				`<b>Should the Imported avatar always spawn at \`Vector3.new({AvatarSpawnNullPoint})\`?</b>\nIf this setting is disabled, the Imported avatars spawn in front of the camera <i>(Workspace.CurrentCamera)</i>`,
				CreateCheckboxAtCategoryForField(
					Avatar_Import,
					"PlaceAtNullPoint"
				)
			),
		},
	}

	const LegalSF = Components.ScrollingFrame {
		Direction = "Y",
		Children = {
			Components.UIListLayout {},
			Components.UIPadding {},
			Components.Text {
				Text = `<b>License & Notice</b>`,
				Size = UDim2.new(1, 0, 0, 12),
				TextSize = 24,
				RichText = true,
			},
			Components.Text {
				Text = `⚠️ This tab is not guaranteed to be up-to-date`,
				Size = UDim2.new(1, 0, 0, 12),
				TextSize = 12,
				XAlign = "Left",
				Color = Colors["Text (Darker - Placeholder/Off)"],
			},
			paragraph(`GitHub Repository with latest version, documentation, license, notice etc:`),
			Components.Pre {
				Size = UDim2.new(1, 0, 0, 72),
				Text = `https://github.com/Coffilhg/SpidoznajaKozavka`,
				IsConstant = true,
			},
			paragraph(RichGradient:Apply(`<i><b>Stars are appreciated!</b></i>`, RaindbowGradient)),
			dividerNewlines(), divider(), dividerNewlines(),
			singleHashtag(`<b>License ~ Unlicense</b>`),
			paragraph(`This is free and unencumbered software released into the public domain. For more information, please refer to:`),
			Components.Pre {
				Size = UDim2.new(1, 0, 0, 72),
				Text = `https://unlicense.org`,
				IsConstant = true,
			},
			dividerNewlines(), divider(), dividerNewlines(),
			singleHashtag(`<b>Notice</b>`),
			paragraph(`SpidoznajaKozavka`),
			paragraph(`Copyright © 2026 @Coffilhg (Roblox UserId 517222346)`),
			paragraph(`This software depends on software developed by (and vendors or redistributes it)`),
			Components.Text {
				Text = `ofc it redistributes, because it's a plugin duh;`,
				Size = UDim2.new(1, 0, 0, 12),
				TextSize = 12,
				XAlign = "Left",
				Color = Colors["Text (Darker - Placeholder/Off)"],
			},
			paragraph(`~ Coffilhg`),
			Components.Pre {
				Size = UDim2.new(1, 0, 0, 72 + 18 * 1),
				Text = `\t| <b>NamespaceSync</b> (MPL-2.0): https://github.com/Coffilhg/Useful-Modules/tree/NamespaceSync\n\t| <b>GreatUIButton</b> (MPL-2.0): https://github.com/Coffilhg/Useful-Modules/tree/GreatUIButton\n\t| <b>RichGradient</b> (MPL-2.0): https://github.com/Coffilhg/Useful-Modules/tree/RichGradient\n\t| <b>Reaction</b> (MPL-2.0): https://github.com/Coffilhg/Useful-Modules/tree/Reaction`,
				IsConstant = true,
				RichText = true,
			},
			paragraph(`~ Data-Oriented-House`),
			Components.Pre {
				Size = UDim2.new(1, 0, 0, 72),
				Text = `\t| <b>LemonSignal</b> (MIT License): https://github.com/Data-Oriented-House/LemonSignal`,
				IsConstant = true,
				RichText = true,
			},
			paragraph(`~ centau`),
			Components.Pre {
				Size = UDim2.new(1, 0, 0, 72),
				Text = `\t| <b>Vide</b> (MIT License): https://github.com/centau/vide`,
				IsConstant = true,
				RichText = true,
			},
			paragraph(`~ Any associated nested transitive dependencies of the above modules (AUTOMATICALLY VENDORED OR REDISTRIBUTED)`),
			dividerNewlines(), divider(), dividerNewlines(),
			singleHashtag(`<b>License Exceptions</b>`),
			paragraph(`Some of the modules in this plugin are prototypes and/or do not belong to this Plugin at it's core. If a script header mentions being made by @coffilhg, it is allowed to have a license different from the main license (see above)`),
			paragraph(`I, the developer of this plugin, @Coffilhg, am planning to polish some of them and publish as separate projects/modules, after which, I'd likely re-integrate them as dependencies (already the case with RichGradient)`),
			paragraph(`\nSome of the scripts were left without a header, they shall be treated as UNLICENSE licensed without a NOTICE; I mean they are just config files and simple stuff in general. Those can be used anywhere however you want without any attribution whatsoever.`),
			dividerNewlines(), divider(), dividerNewlines(),
			singleHashtag(`<b>AI usage</b>`),
			paragraph(`No AI was used to make the Plugin and now only God knows how it works`),
		},
	}

	const m, wrap, pageLayout = Components.Main({
		BackgroundChildren = {
			w,
		},
		ForegroundChildren = {
			--s,
			MainSF,
			SettingsSF,
			richOutputSF,
			LegalSF,
		},
	})
	uiPageLayout = pageLayout
	
	
	
	local isLastSyncByNav = true
	const navSF = Components.ScrollingFrame {
		Size = UDim2.fromScale(.8, 1),
		Direction = "X",
		Children = {
			Components.UIListLayout {
				Direction = "Horizontal",
				XAlign = "Left",
				YAlign = "Center",
				Padding = UDim.new(0, 6),
			},
			Components.UIPadding {0, 1200},
		}
	}
	navSF.ClipsDescendants = false
	navSF.BackgroundTransparency = 1
	const navButtonBinds = {}
	const function navButton(SectionName: string, bindToPage: Instance | (...any) -> ())
		const b = C "TextButton" {
			Size = UDim2.fromScale(0, 1),
			--Position = UDim2.fromScale(.5, .5),
			--AnchorPoint = Vector2.new(.5, .5),
			AutomaticSize = Enum.AutomaticSize.X,
			TextSize = 16,
			--TextWrapped = true,
			--TextScaled = true,
			Text = `<b>{SectionName}</b>`,
			RichText = true,
			Components.UIPadding({3, 6}),
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = Colors["Text (Primary)"],
			(C :: any) "UIScale" {
				Scale = 1,
			},
		}
		
		b.Parent = navSF
		
		const gb = GreatUIButton(b, b, {
			TweenInfo = TweenInfo.new(0.3),
			UIScale = {
				TweenInfo = TweenInfo.new(0.3),
				Scale = 1,
			},
		}):SetAppearance("Hover", {
			TweenInfo = TweenInfo.new(0.3),
			UIScale = {
				TweenInfo = TweenInfo.new(0.3),
				Scale = 1.08,
			},
		}):SetAppearance("Press", {
			TweenInfo = TweenInfo.new(0.3),
			UIScale = {
				TweenInfo = TweenInfo.new(0.3),
				Scale = 0.9,
			},
		}, true):ApplyAppearance("Default")
		
		if type(bindToPage) == `function` then
			gb.OnPressStart:Connect(bindToPage)
			
			const cube = C "UIAspectRatioConstraint" {
				AspectRatio = 1,
			}
			cube.Parent = b
			b.Size = UDim2.fromScale(1, 1)
		else
			gb.OnPressStart:Connect(function()
				pageLayout:JumpTo(bindToPage)
			end)

			navButtonBinds[bindToPage] = b
		end
		
		return b
	end
	
	const function syncSections(page: Instance)
		const b = navButtonBinds[page]
		if not b then
			return
		end
		const xPosition = b.AbsolutePosition.X - navSF.AbsolutePosition.X + navSF.CanvasPosition.X
		--print(xPosition)
		navSF.CanvasPosition = Vector2.new(xPosition, 0)
	end
	
	pageLayout.PageEnter:Connect(syncSections)
	
	navButton(RichGradient:Apply(`Outfit Loader`, PremiumGradient, true), MainSF)
	navButton(RichGradient:Apply(`Settings`, ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(190, 255, 60)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 255, 125)),
	}), true), SettingsSF)
	navButton(`Output`, richOutputSF)
	navButton(RichGradient:Apply(`License & Legal`, Colors["Text (Primary)"], Colors.Backgroung), LegalSF)
	
	syncSections(MainSF)
	
	
	
	-- https://create.roblox.com/docs/ui/rich-text#escape-forms for lt and gt
	const navBack = navButton(`&lt;`, function()
		pageLayout:Previous()
	end)
	navBack.Position = UDim2.fromScale(0, .5)
	navBack.AnchorPoint = Vector2.new(0, .5)
	navBack.ZIndex = 10
	navBack.TextScaled = true
	navBack.BackgroundColor3 = Colors["Div"]
	navBack.BackgroundTransparency = 0
	navBack.TextXAlignment = Enum.TextXAlignment.Center
	navBack.AutomaticSize = Enum.AutomaticSize.None
	navBack.Size = UDim2.fromScale(.1, 1)
	;(C "UICorner" {
		CornerRadius = UDim.new(0, 4)
	}).Parent = navBack

	const navFront = navButton(`&gt;`, function()
		pageLayout:Next()
	end)
	navFront.Position = UDim2.fromScale(1, .5)
	navFront.AnchorPoint = Vector2.new(1, .5)
	navFront.ZIndex = 10
	navFront.TextScaled = true
	navFront.BackgroundColor3 = Colors["Div"]
	navFront.BackgroundTransparency = 0
	navFront.TextXAlignment = Enum.TextXAlignment.Center
	navFront.AutomaticSize = Enum.AutomaticSize.None
	navFront.Size = UDim2.fromScale(.1, 1)
	;(C "UICorner" {
		CornerRadius = UDim.new(0, 4)
	}).Parent = navFront
	
	const nav = Components.Div {
		AnchorPoint = Vector2.new(.5, .5),
		Size = UDim2.fromScale(0.76, 0.09),
		Position = UDim2.new(.5, 0, 0.09, 0),
		Radius = 4,
		AutoSize = "None",
		Children = {
			navSF,
			navBack,
			navFront
		},
	}
	nav.ClipsDescendants = true
	nav.ZIndex = 7
	nav.Parent = Widget

	return m
end, Widget)

Ask:FixGreatUIButtonLooks()
for _, greatUIButton in GreatUIButtons do
	--print(greatUIButton)
	greatUIButton:ApplyAppearance("Default")
end

plugin.Unloading:Once(function()
	PluginBigSettingsStoreService:Shutdown()
end)