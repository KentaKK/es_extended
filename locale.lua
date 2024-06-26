Locales = {}

function _(str, ...)  -- Translate string

	if Locales[Config.Locale] ~= nil then

		if Locales[Config.Locale][str] ~= nil then
			return string.format(Locales[Config.Locale][str], ...)
		else
			return 'Translation [' .. Config.Locale .. '][' .. str .. '] does not exist'
		end

	else
		return 'Locale [' .. Config.Locale .. '] does not exist'
	end

end

function _U(str, ...) -- Translate string first char uppercase
	return tostring(_(str, ...):gsub("^%l", string.upper))
end

function Translate(str, ...)  -- Translate string
	if Locales[Config.Locale] then
		if Locales[Config.Locale][str] then
			return string.format(Locales[Config.Locale][str], ...)
		elseif Config.Locale ~= 'en' and Locales['en'] and Locales['en'][str] then
			return string.format(Locales['en'][str], ...)
		else
			return 'Translation [' .. Config.Locale .. '][' .. str .. '] does not exist'
		end
	elseif Config.Locale ~= 'en' and Locales['en'] and Locales['en'][str] then
			return string.format(Locales['en'][str], ...)
	else
		return 'Locale [' .. Config.Locale .. '] does not exist'
	end
end

function TranslateCap(str, ...) -- Translate string first char uppercase
	return _(str, ...):gsub("^%l", string.upper)
end

_ = Translate
_U = TranslateCap
