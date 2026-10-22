--!strict
--!optimize 2

const Utils = {}

const Players = game:GetService(`Players`)
const AES = game:GetService(`AvatarEditorService`)


type userId = number
type outfitId = number
type isSuccessBoolean = boolean





const HumDescCache: {[userId]: HumanoidDescription} = {}
-- Second return argument is a HumanoidDescription only if isSuccessBoolean == true
const function GetHumDesc(userId: userId): (isSuccessBoolean, HumanoidDescription)
	const cached = HumDescCache[userId]
	if cached then
		return true, cached
	end

	const success, humDesc = pcall(Players.GetHumanoidDescriptionFromUserIdAsync, Players, userId :: any) -- Roblox expects a new type "User", but still supports numbers and this is a plugin so we'll never get a proper "User" type value
	if success and typeof(humDesc) == `Instance` and humDesc:IsA(`HumanoidDescription`) then
		HumDescCache[userId] = humDesc
		return true, humDesc
	end

	return false, humDesc
end
Utils.GetHumDesc = GetHumDesc

const OutfitsCache: {[outfitId]: HumanoidDescription} = {}
-- Second return argument is a HumanoidDescription only if isSuccessBoolean == true
const function GetOutfit(outfitId: outfitId): (isSuccessBoolean, HumanoidDescription)
	const cached = OutfitsCache[outfitId]
	if cached then
		return true, cached
	end

	const success, humDesc = pcall(Players.GetHumanoidDescriptionFromOutfitIdAsync, Players, outfitId)
	if success and typeof(humDesc) == `Instance` and humDesc:IsA(`HumanoidDescription`) then
		OutfitsCache[outfitId] = humDesc
		return true, humDesc
	end

	return false, humDesc
end
Utils.GetOutfit = GetOutfit

-- Yields for however long required
const function GetHumDescDetails(userId: userId)
	local getDetailsSuccess, getDetailsResult = pcall(Players.GetCharacterAppearanceInfoAsync, Players, userId :: any) -- "User"
	--print(getDetailsSuccess, getDetailsResult)
	while not getDetailsSuccess do
		--print(getDetailsSuccess, getDetailsResult)
		getDetailsSuccess, getDetailsResult = pcall(Players.GetCharacterAppearanceInfoAsync, Players, userId :: any) -- "User"
	end
	
	return getDetailsResult
end
Utils.GetHumDescDetails = GetHumDescDetails

-- Yields for however long required
const function IsHumDescR6(userId: userId): boolean
	const getDetailsResult = GetHumDescDetails(userId)

	const isR6 = getDetailsResult[`playerAvatarType`] ~= `R15`

	return isR6 --getDetailsResult
end
Utils.IsHumDescR6 = IsHumDescR6

-- Yields for however long required
const function IsOutfitR6(outfitId: outfitId): boolean
	local getDetailsSuccess, getDetailsResult = pcall(AES.GetOutfitDetailsAsync, AES, outfitId)
	--print(getDetailsSuccess, getDetailsResult)
	while not getDetailsSuccess do
		--print(getDetailsSuccess, getDetailsResult)
		getDetailsSuccess, getDetailsResult = pcall(AES.GetOutfitDetailsAsync, AES, outfitId)
	end
	
	const isR6 = getDetailsResult[`PlayerAvatarType`] ~= `R15`
	
	return isR6 --getDetailsResult
end
Utils.IsOutfitR6 = IsOutfitR6



table.freeze(Utils)
export type Utils = typeof(Utils)
return Utils