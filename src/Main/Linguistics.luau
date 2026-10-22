--!strict
--!optimize 2

const Linguistics = {}

-- Suffix - a morpheme or ending added to the end of a word
-- Usually referred to as a "Postfix" in programming tho;
-- Example usage:
-- English (Default) `:WordPerAmount(123)`
-- Ukrainian `:WordPerAmount(123, ``, `и`, `ів`)`
-- Russian `:WordPerAmount(123, ``, `а`, `ов`)`
function Linguistics.WordPerAmount(
	self: Linguistics,
	number: number,
	singleSuffix: string?,
	multipleSuffix: string?,
	moreSuffix: string?,
	includeNumber: boolean?
): string
	if type(number) ~= `number` then
		return ``
	end

	-- English fallback suffixes (postfixes)
	if type(singleSuffix) ~= `string` then
		singleSuffix = ``
	end
	if type(multipleSuffix) ~= `string` then
		multipleSuffix = `s`
	end
	if type(moreSuffix) ~= `string` then
		moreSuffix = `s`
	end
	
	const n = not includeNumber and `` or `{number}`

	const numberModuleHundred = number % 100
	if numberModuleHundred > 4 and numberModuleHundred < 21 then
		return `{n}{moreSuffix}`
	end

	const numberModuleTen = number % 10
	if numberModuleTen > 4 or numberModuleTen == 0 then
		return `{n}{moreSuffix}`
	end

	if numberModuleTen > 1 then
		return `{n}{multipleSuffix}`
	end

	return `{n}{singleSuffix}`
end

table.freeze(Linguistics)
export type Linguistics = typeof(Linguistics)
return Linguistics