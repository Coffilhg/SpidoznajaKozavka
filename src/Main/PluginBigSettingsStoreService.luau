--[[--
    PluginBigSettingsStoreService (a prototype used in CoffeeMixer & SpidoznajaKozavka)
    Copyright © 2026 Coffilhg (Roblox UserId 517222346)

    This Source Code Form is subject to the terms of the Mozilla Public
    License, v. 2.0. If a copy of the MPL was not distributed with this
    file, You can obtain one at https://mozilla.org/MPL/2.0/.

    GitHub Repository/Branch with latest version, documentation, etc:
    https://github.com/Coffilhg/Useful-Modules/tree/PluginBigSettingsStoreService
    Stars are appreciated!
    
    This is essentially a prototype / unpublished version of PluginBigSettingsStoreService,
    if the link https://github.com/Coffilhg/Useful-Modules/tree/PluginBigSettingsStoreService
    leads nowhere, it means this module is not published yet, if you use it, this module is
    MPL-2.0 Licensed and made by @Coffilhg (Roblox UserId 517222346)
    This header shall be kept here without modifications.
--]]--

--!strict
--!optimize 2

export type ProjectReference = {
	ProjectName: string,
	ProjectVersion: string,
}

export type JSONAcceptableIndex = string | number
export type JSONAcceptableTable = { [JSONAcceptableIndex]: JSONAcceptable }
export type JSONAcceptable = JSONAcceptableTable | number | string | boolean | buffer

type MutableValueTypeHandlers = {
	[string]: (
		copy: JSONAcceptableTable,
		key: JSONAcceptableIndex,
		value: JSONAcceptable
	) -> (),
}



const MutableValueTypeHandlers: MutableValueTypeHandlers = {}

const function CopyBuffer(original: buffer): buffer
	const copy = buffer.create(buffer.len(original))
	buffer.copy(copy, 0, original)
	return copy
end

const function DeepCopy(original: JSONAcceptableTable): JSONAcceptableTable
	const copy: JSONAcceptableTable = {}
	for key: JSONAcceptableIndex, value: JSONAcceptable in original do
		if key == `___Key` then
			continue
		end

		const mutableTypeHandler = MutableValueTypeHandlers[type(value)]
		if not mutableTypeHandler then
			copy[key] = value
			continue
		end
		mutableTypeHandler(copy, key, value)
	end
	return copy
end

MutableValueTypeHandlers[`table`] = function(
	copy: JSONAcceptableTable,
	key: JSONAcceptableIndex,
	value: JSONAcceptable
)
	copy[key] = DeepCopy(value :: JSONAcceptableTable)
end
MutableValueTypeHandlers[`buffer`] = function(
	copy: JSONAcceptableTable,
	key: JSONAcceptableIndex,
	value: JSONAcceptable
)
	copy[key] = CopyBuffer(value :: buffer)
end

const function Reconcile(target: JSONAcceptableTable, template: JSONAcceptableTable)
	for key: JSONAcceptableIndex, value: JSONAcceptable in template do
		const templateValueType = type(value)
		const targetValue = target[key]
		const targetValueType = type(targetValue)

		if targetValueType == `nil` then
			const mutableTypeHandler = MutableValueTypeHandlers[templateValueType]
			if not mutableTypeHandler then
				target[key] = value
				continue
			end
			mutableTypeHandler(
				target :: JSONAcceptableTable | any,
				key :: JSONAcceptableIndex | any,
				value
			)

			continue
		end

		if targetValueType == `table` and templateValueType == `table` then
			Reconcile(targetValue :: JSONAcceptableTable, value :: JSONAcceptableTable)
		end
	end
end



const function DeepCompareBuffer(one: buffer, two: buffer): boolean
	if buffer.len(one) ~= buffer.len(two) then
		return false
	end
	return buffer.tostring(one) == buffer.tostring(two)
end
const function DeepCompare(one: JSONAcceptable, two: JSONAcceptable): boolean
	-- make sure primitives / references are inequal before proceeding
	if one == two then
		return true
	end

	const typeOne = type(one)
	const typeTwo = type(two)

	-- make sure types are equal
	if typeOne ~= typeTwo then
		return false
	end

	if typeOne == `buffer` then
		return DeepCompareBuffer(one :: buffer, two :: buffer)
	end

	if typeOne ~= `table` then
		return false
	end

	const lengthOne = #(one :: JSONAcceptableTable)
	const lengthTwo = #(two :: JSONAcceptableTable)

	if lengthOne ~= lengthTwo then
		return false
	end

	const comparedKeys = {}
	for key, value in one :: JSONAcceptableTable do
		const valueTwo = (two :: JSONAcceptableTable)[key]
		if not DeepCompare(value, valueTwo) then
			return false
		end

		comparedKeys[key] = true
	end

	for key, value in two :: JSONAcceptableTable do
		if comparedKeys[key] then
			continue
		end

		const valueOne = (one :: JSONAcceptableTable)[key]
		if not DeepCompare(value, valueOne) then
			return false
		end
	end

	return true
end









const PluginStoresAndSaveTimes: {[PluginStore]: number} = {}
const PluginStoresPerName: {[string]: PluginStore} = {}
local ProjectReference: ProjectReference
local IsProjectReferenceProvided: boolean = false

const SS = game:GetService(`ServerStorage`)
const SES = game:GetService(`ScriptEditorService`)
const HttpService = game:GetService(`HttpService`)
const Debris = game:GetService(`Debris`)

const NamespaceSync = require(`../Packages/NamespaceSync`)
const RichOutputModule = require(`./Components/RichOutput`)
const RichOutput = RichOutputModule({} :: any)

-- GetPluginBigSettingsFolder
const function GetPBSFolder(): Folder
	if not IsProjectReferenceProvided then
		error(`Reference to project must be provided via :Init(\{ProjectName = "Example", ProjectVersion = "1.2.3"}) first`)
	end
	
	const pluginBigSettingsFolder = NamespaceSync:mkdir(
		ProjectReference.ProjectVersion,
		`{ProjectReference.ProjectName}_BigSettings`,
		SS
	)
	
	return pluginBigSettingsFolder
end



const function JSONDecodeGetEditorSource(source: LuaSourceContainer)
	const source = SES:GetEditorSource(source)
	if source == "" then
		return {}
	end
	return HttpService:JSONDecode(source)
end

-- plugin:GetSetting
-- if source is corrupted `{}` is returned
const function GetStoreData(storeName: string, method: string): JSONAcceptableTable
	const pbs = GetPBSFolder()
	
	const storeDataSource = NamespaceSync:GetOrCreateManual(
		"ModuleScript",
		storeName,
		pbs
	)
	
	const success, storeData = pcall(JSONDecodeGetEditorSource, storeDataSource)
	
	if type(storeData) ~= `table` then
		if not success then
			RichOutput:Error(`[PluginBigSettings] \`{method}\` unsuccessfull, error message: {storeData}`)
		end
		return {}
	end
	
	return storeData
end



const function UpdateSourceAsyncJSONEncode(source: LuaSourceContainer, data: JSONAcceptableTable)
	return SES:UpdateSourceAsync(source, function()
		return HttpService:JSONEncode(data)
	end)
end

-- plugin:SetSetting
const function SetStoreData(storeName: string, data: JSONAcceptableTable?, method: string?): boolean
	const pbs = GetPBSFolder()

	const storeDataSource = NamespaceSync:GetOrCreateManual(
		"ModuleScript",
		storeName,
		pbs
	)
	
	if type(data) == `nil` then
		Debris:AddItem(storeDataSource, 0)
		return true
	end
	
	const success, errorMessage = pcall(UpdateSourceAsyncJSONEncode, storeDataSource, data)
	
	if not success then
		RichOutput:Error(`[PluginBigSettings] Save for "{storeName}" failed, error message: {errorMessage}`)
	end
	
	return success
end


const PluginProfile = {}
export type PluginProfile<T=JSONAcceptableTable> = {
	Save: (self: PluginProfile<T>) -> (),
	___Key: PluginStore,
} & T
PluginProfile.__index = PluginProfile

function PluginProfile.Save(self: PluginProfile)
	self.___Key:Save()
end




const PluginStore = {}
export type PluginStore = typeof(PluginStore)
PluginStore.__index = PluginStore


function PluginStore.Destroy(self: PluginStore, isSaveRequired: boolean?)
	if isSaveRequired then
		self:Save()
	end

	PluginStoresAndSaveTimes[self] = nil
	PluginStoresPerName[self.___Key] = nil

	setmetatable(self, nil)
end
function PluginStore.Wipe(self: PluginStore)
	if not IsProjectReferenceProvided then
		error(`Reference to project must be provided via :Init(\{ProjectName = "Example", ProjectVersion = "1.2.3"}) first`)
		return
	end
	PluginStoresAndSaveTimes[self] = os.time()

	SetStoreData(self.___Key, nil)
end
-- As per https://devforum.roblox.com/t/pluginsetsetting-plugingetsetting-do-not-function-as-intended/1307736/6
-- Saving should first use get
function PluginStore.Save(self: PluginStore)
	if not IsProjectReferenceProvided then
		error(`Reference to project must be provided via :Init(\{ProjectName = "Example", ProjectVersion = "1.2.3"}) first`)
		return
	end
	
	-- at first you may think this is not necessary, since it isn't a plugin whose
	-- settings are shared across multiple studio instances (windows / tabs)
	-- but what if user edits the data? So this is useful afterall.
	const upToDateData = GetStoreData(self.___Key, `Get Up-to-date data at :Save()`)

	--print(`Up-to-date previous data:`, upToDateData)

	const dataToSave = DeepCopy(self :: JSONAcceptableTable)

	--print(`Data to be saved:`, dataToSave)
	
	const previousSaveTime = PluginStoresAndSaveTimes[self]
	PluginStoresAndSaveTimes[self] = os.time()



	-- are there any changes between upToDateData and dataToSave?
	-- No? -> No need to SetSetting!
	if DeepCompare(upToDateData, dataToSave) then
		--warn(`Save not necessary, data is identic`)
		return
	end

	-- Yes -> save changes
	const success = SetStoreData(self.___Key, dataToSave, `:Save`)
	if not success then
		-- rollback if save was unsuccessfull & avoid writing nil
		PluginStoresAndSaveTimes[self] = previousSaveTime or os.time()
	end
end
function PluginStore.Get<T>(
	self: PluginStore,
	key: string,
	default: (T & JSONAcceptableTable)?
): PluginProfile<T>
	if key == `___Key` then
		error(`"___Key" is reserved`)
	end

	local data = self[key]
	if type(data) ~= `table` then
		data = {}
		self[key] = data
	end

	const pluginProfile = setmetatable(data, PluginProfile) :: PluginProfile<T>
	pluginProfile.___Key = self

	if type(default) == `table` then
		Reconcile(pluginProfile, default)
	end

	return pluginProfile
end



const PluginBigSettingsStoreService = {}

function PluginBigSettingsStoreService.Init(
	self: PluginBigSettingsStoreService,
	projectReference: ProjectReference
): PluginBigSettingsStoreService
	if not (type(projectReference) == `table` and type(projectReference.ProjectName) == `string` and type(projectReference.ProjectVersion) == `string`) then
		error(`projectReference must be a table conatining ProjectName and ProjectVersion as stringsб e.g. \{ProjectName = "Example", ProjectVersion = "1.2.3"}`)
	end

	ProjectReference = projectReference
	IsProjectReferenceProvided = true

	return self
end

-- NOT DESIGNED TO HANDLE A LOT OF DATA (limit yourself to 0.1MB, that's 100000 bytes)
function PluginBigSettingsStoreService.GetStore(
	self: PluginBigSettingsStoreService,
	storeName: string
): PluginStore
	if type(storeName) ~= `string` then
		error(`storeName is expected to be a string`)
	end

	const alreadyInitializedPluginStore = PluginStoresPerName[storeName]
	if alreadyInitializedPluginStore then
		return alreadyInitializedPluginStore
	end
	
	
	
	const storeData = GetStoreData(storeName, `:GetStore("{storeName}")`)

	const pluginStore = setmetatable(storeData :: {}, PluginStore) :: PluginStore
	pluginStore.___Key = storeName

	PluginStoresAndSaveTimes[pluginStore] = os.time()
	PluginStoresPerName[storeName] = pluginStore

	return pluginStore
end

const function SaveAll(lazy: boolean?)
	const now = os.time()

	for pluginStore, lastSaveTime in PluginStoresAndSaveTimes do
		if lazy and now - lastSaveTime < 300 then
			continue
		end
		pluginStore:Save()
	end
end

function PluginBigSettingsStoreService.SaveAll(
	self: PluginBigSettingsStoreService
): PluginBigSettingsStoreService
	SaveAll(false)
	return self
end

local AutoSaveThread: thread?
const function LazyStartAutoSaving()
	if AutoSaveThread then
		return
	end
	AutoSaveThread = task.spawn(function()
		while task.wait(30) do
			SaveAll(true)
		end
	end)
end
LazyStartAutoSaving() -- initial require of the module

-- Recommended usage:
--plugin.Unloading:Once(function()
--	PluginBigSettingsStoreService:Shutdown()
--end)
-- This stops older running iterations of the plugin from auto-saving their old data. That's very useful when iterating in studio as a local plugin, don't know whether it's particularly useful though.
function PluginBigSettingsStoreService.Shutdown(
	self: PluginBigSettingsStoreService
): PluginBigSettingsStoreService
	if AutoSaveThread then
		task.cancel(AutoSaveThread)
	end
	return self
end

-- Starts the auto-save loop again (lazy (i.e. if a loop is already there, this does nothing))
function PluginBigSettingsStoreService.Restart(
	self: PluginBigSettingsStoreService
): PluginBigSettingsStoreService
	LazyStartAutoSaving()
	return self
end

export type PluginBigSettingsStoreService = typeof(PluginBigSettingsStoreService)
table.freeze(PluginBigSettingsStoreService)

return PluginBigSettingsStoreService :: PluginBigSettingsStoreService