--!strict
--!optimize 2

const HttpService = game:GetService(`HttpService`)

const Ask = require(`./Components/Ask`)
const AskObject = Ask({})
const OnAnswer = AskObject.OnAnswer



const IsDebugEnabled: boolean = false



const function GetAsync(url: any)
	return HttpService:GetAsync(url)
end
const function JSONDecode(json: any)
	return HttpService:JSONDecode(json)
end


export type UsersByNameResponse = {
	data: {
		[number]: {
			displayName: string,
			hasVerifiedBadge: boolean,
			id: number,
			name: string,
			previousUsernames: {string},
		},
	},
	nextPageCursor: string,
}
export type outfitType = "Avatar" | "DynamicHead" | string
export type OutfitsByUserIdResponseData = {
	[number]: {
		id: number,
		isEditable: boolean,
		name: string,
		outfitType: outfitType,
	},
}
export type OutfitsByUserIdResponse = {
	data: OutfitsByUserIdResponseData,
	paginationToken: string,
}


const HTTP = {
	Links = table.freeze({
		Outfits = {
			-- self explanatory
			Format = function(UID: number, ItemsPerPage: number, PaginationToken: string?, OutfitType: outfitType?, IsEditable: boolean?)
				-- page={Page} doesn't work either way. By default it is 1, if no pagination token is provided it is 1 regardless of sent value.
				-- with a pagination token, roblox returns only the next page that is bound to this pagination token.
				return `https://avatar.roproxy.com/v2/avatar/users/{UID}/outfits?itemsPerPage={ItemsPerPage}{
				type(PaginationToken) == `string` and `&paginationToken={PaginationToken}` or ``
				}{
				type(OutfitType) == `string` and `&outfitType={OutfitType}` or ``
				}{
				type(IsEditable) == `boolean` and `&isEditable={IsEditable}` or ``
				}`
			end,
			Read = `https://avatar.roproxy.com/v2/avatar/users/\{UID}/outfits?itemsPerPage=\{ItemsPerPage} and optional &paginationToken=\{PaginationToken} &outfitType=\{OutfitType} &isEditable=\{IsEditable}`,
		},
		UsersByName = {
			-- keyword string and limit 10 | 25 | 50 | 100 expected
			Format = function(keyword: string, limit: number)
				return `https://users.roproxy.com/v1/users/search?keyword={keyword}&limit={limit}`
			end,
			Read = `https://users.roproxy.com/v1/users/search?keyword=\{keyword}&limit=\{limit}`,
		},
	}),
}

function HTTP.Fetch(
	self: HTTP,
	url: string,
	isJSONDecodeRequired: boolean?,
	isAllowed: boolean?,
	reason: string?,
	yes: string?,
	no: string?
): (boolean, string | any)
	if isAllowed ~= true then
		const questionId = AskObject:Ask(
			`Please approve HttpService:GetAsync to "{url}"{reason and `;\n{reason}` or ``}`,
			no or `Deny`,
			yes or `Allow`
		)
		local approved, answerId = OnAnswer:Wait()

		while answerId ~= questionId do
			if answerId > questionId then
				-- the question was already answered and we missed it (idk how, but it's good to handle this)
				return false, `Question was answered too fast or automatically, answer status missing`
			end
			approved, answerId = OnAnswer:Wait() -- keep awaiting until it's our question' answer status
		end

		if not approved then
			return false, `HttpService:GetAsync request to "{url}" was denied, can not proceed`
		end
	end
	
	
	
	const success, result = pcall(GetAsync, url)
	if not (success and isJSONDecodeRequired) then
		if not not IsDebugEnabled then
			print(`{`[HTTP] \{{url}}`}\n\t{success}`, result)
		end
		return success, result
	end
	
	
	
	const ok, decoded = pcall(JSONDecode, result)
	
	
	
	if not not IsDebugEnabled then
		print(`{`[HTTP] \{{url}}`}\n\t{ok}`, decoded)
	end
	if not ok then
		return ok, result
	end
	return ok, decoded
end

table.freeze(HTTP)
type HTTP = typeof(HTTP)
return HTTP