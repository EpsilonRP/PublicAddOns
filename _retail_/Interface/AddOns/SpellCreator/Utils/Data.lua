---@class ns
local ns = select(2, ...)

local tInsert = tinsert

---------------------------------------------------------
--- General
---------------------------------------------------------

local function isNotDefined(s)
	return s == nil or s == '';
end

local function getRandomArg(...)
	return (select(random(select("#", ...)), ...));
end

---@class WeightedArgItem
---@field [1] integer weight
---@field [2] string|table|any return item

---@class WeightedArgPool
---@type WeightedArgItem[]

---Get a random arg based on weighting
---@param pool WeightedArgPool
---@return WeightedArgItem<2>?
local function getRandomWeightedArg(pool)
	local poolsize = 0
	for i = 1, #pool do
		local v = pool[i]
		poolsize = poolsize + v[1]
	end
	local selection = math.random(1, poolsize)
	for i = 1, #pool do
		local v = pool[i]
		selection = selection - v[1]
		if (selection <= 0) then
			return v[2]
		end
	end
end

--[[ Example Pool
 pool = {
	{20, "foo"},
	{20, "bar"},
	{60, "baz"}
 }
--]]
---------------------------------------------------------
--- String Helpers
---------------------------------------------------------

local function toBoolean(str) return strlower(str) == "true" end

local function firstToUpper(str)
	return (str:gsub("^%l", string.upper))
end

local function wordToProperCase(word)
	return firstToUpper(string.lower(word))
end

---@param input string
---@return string
local function sanitizeNewlinesToCSV(input)
	local output = strtrim(input) -- removes leading/trailing new lines (& spaces) since we don't want blanks
	output = output:gsub("\n", ",")
	return output
end

local function caseInsensitiveCompare(a, b)
	if type(a) == "number" and type(b) == "number" then
		return a < b
	else
		return string.lower(a) < string.lower(b)
	end
end

local replaceEmptyVars = function(str)
	while str:find(",%s*,") do
		str = str:gsub(",%s*,", ",nil,", 1)
	end

	return str
end

local null = {}
---@param text string string to parse into csv arguments, returned as an array of args.
---@param limit? number
---@return string[]|table, number?
local function getCSVArgsFromString(text, limit)
	local _csvTable = {}
	if not text then return _csvTable end
	text = text:gsub(', "', ',"') -- replace , " with ,"
	text = text:gsub('" ,', '",') -- replace " , with ",
	text = replaceEmptyVars(text) -- replacing any empty vars with nil
	if not text then return _csvTable end

	local spat, epat, buf, quoted = [=[^(["])]=], [=[(["])$]=]
	for str in text:gmatch("[^,]+") do
		local squoted = str:match(spat)
		local equoted = str:match(epat)
		local escaped = str:match([=[(\*)["]$]=])
		if squoted and not quoted and not equoted then
			buf, quoted = str, squoted
		elseif buf and equoted == quoted and #escaped % 2 == 0 then
			str, buf, quoted = buf .. ',' .. str, nil, nil
		elseif buf then
			buf = buf .. ',' .. str
		end
		if not buf then
			local arg = (str:gsub(spat, ""):gsub(epat, ""))
			if strtrim(arg) == "nil" then arg = null end
			tinsert(_csvTable, arg)
		end
	end
	if buf then ns.Logging.eprint("Error Parsing CSV: Missing matching end quote for " .. buf .. "\rCheck your ArcSpell!") end

	-- convert nulls back to nils
	local trueLength = #_csvTable
	for k, v in ipairs(_csvTable) do
		if v == null then
			_csvTable[k] = nil
		end

		if limit and k > limit then
			_csvTable[limit] = strjoin(",", _csvTable[limit], _csvTable[k]) -- rejoin anything over the limit with , delimiter
			_csvTable[k] = nil                                     -- clear that
		end

		if _csvTable[k] then _csvTable[k] = strtrim(_csvTable[k]) end -- trim it
	end

	local returnLength
	if limit and limit < trueLength then
		returnLength = limit
	else
		returnLength = trueLength
	end

	return _csvTable, returnLength
end

local function getArguments(input, limit)
	local _args = {}
	local currentArg = ""
	local inQuotes = false
	local escapeNext = false
	local numArgs = 0

	-- Special case handler for limit of 1
	if limit == 1 then
		if #input == 0 or strtrim(input) == "nil" or strtrim(input) == "" then
			_args[1] = nil
		else
			input = strtrim(input)
			if input:sub(1, 1) == '"' and input:sub(-1) == '"' then
				input = input:sub(2, -2)
			end
			_args[1] = strtrim(input)
		end
		return _args, 1
	end

	if not input then return _args end
	input = input:gsub(', *"', ',"') -- replace , " with ,"
	input = input:gsub('" *,', '",') -- replace " , with ",
	input = replaceEmptyVars(input) -- replacing any empty vars with nil
	if not input then return _args end

	-- Iterate over the input string character by character
	for i = 1, #input do
		local char = input:sub(i, i)
		local nextChar = input:sub(i + 1, i + 1) -- Look ahead at the next character

		if escapeNext then
			-- If the previous character was a backslash, append the current character and reset escape flag
			currentArg = currentArg .. char
			escapeNext = false
		elseif char == "\\" and nextChar == '"' then
			-- If we encounter a backslash, set escapeNext flag to true (escape the next character)
			escapeNext = true
		elseif char == '"' and not inQuotes and #currentArg == 0 then
			-- Start of a quoted section: don't save the quote, just toggle inQuotes
			inQuotes = true
		elseif char == '"' and inQuotes and (nextChar == "," or nextChar == nil or nextChar == "") then
			-- End of a quoted section: don't save the quote, just toggle inQuotes
			inQuotes = false
		elseif char == "," and not inQuotes then
			-- If we reach a comma and we are not inside a quoted string, it's an argument delimiter
			numArgs = numArgs + 1 -- Increment argument count
			if #currentArg == 0 or strtrim(currentArg) == "nil" or strtrim(currentArg) == "" then
				_args[numArgs] = nil -- Blank arguments, or "nil", are inserted as nil
			else
				_args[numArgs] = strtrim(currentArg)
			end
			currentArg = "" -- Reset current argument

			-- If the limit is reached, collect the rest as a single string
			if limit and numArgs == limit - 1 then
				currentArg = input:sub(i + 1)
				break
			end
		else
			-- Collect the current character
			currentArg = currentArg .. char
		end
	end

	-- Insert the last argument after finishing the loop
	numArgs = numArgs + 1

	if limit and numArgs == limit then
		-- Apply the same logic for trimming quotes and setting nil values for the last argument
		if #currentArg == 0 or strtrim(currentArg) == "nil" or strtrim(currentArg) == "" then
			_args[numArgs] = nil
		else
			-- If the last argument is quoted, remove the surrounding quotes
			-- trim first
			currentArg = strtrim(currentArg)
			if currentArg:sub(1, 1) == '"' and currentArg:sub(-1) == '"' then
				currentArg = currentArg:sub(2, -2)
			end
			_args[numArgs] = strtrim(currentArg)
		end
	else
		-- Handle the normal case where the last argument is at the end of the loop
		if #currentArg == 0 then
			_args[numArgs] = nil
		else
			_args[numArgs] = strtrim(currentArg)
		end
	end

	return _args, numArgs
end


local parseStringToArgs = getArguments

---A wrapper for parseStringToArgs that handles failure fallback, along with arg limits
---@param string any
---@param limit? any
---@return table|string[]?
---@return number?
local parseArgsWrapper = function(string, limit)
	local success, argTable, numArgs = pcall(parseStringToArgs, string, limit)
	if not success then
		ns.Logging.eprint("Error Parsing String to Args (Are you missing a \" ?)")
		ns.Logging.dprint(argTable)
		return
	end
	return argTable, numArgs
end

---@param string string CSV Delimited String of Args
---@param limit? number Max number of args to grab
---@return ... All the args, capped at the limit or the max number found if no limit given, including nils
local function getArgs(string, limit)
	local argsTable, numArgs = parseArgsWrapper(string, limit)
	if not argsTable then error("Error Parsing String to Args (Are you missing a \" ?)") end
	return unpack(argsTable, 1, numArgs)
end


---comment
---@param seconds number length in seconds
---@return string timeString the time in either '1m 10s' or '10s' format
local function secondsToMinuteSecondString(seconds)
	local timeString
	if seconds > 60 then
		-- minute handler..
		local _min = math.floor(seconds / 60)
		local _sec = math.ceil(seconds % 60)
		timeString = _min .. "m " .. _sec .. "s"
	else
		timeString = math.ceil(seconds) .. "s"
	end
	return timeString
end

---------------------------------------------------------
--- Link Helpers
---------------------------------------------------------

local function getSpellInfoFromHyperlink(link)
	local strippedSpellLink, spellID = link:match("|Hspell:((%d+).-)|h");
	if spellID then
		return tonumber(spellID), strippedSpellLink;
	end
end

local function getItemInfoFromHyperlink(link)
	local strippedItemLink, itemID = link:match("|Hitem:((%d+).-)|h");
	if itemID then
		return tonumber(itemID), strippedItemLink;
	end
end

local ITEM_LINK_FORMATS = {
	--item = { format = "|cff......|Hitem:((%d+).-)|h|r", replacement = "%2", handler = getItemInfoFromHyperlink },
	--spell = { format = "|cff......|Hspell:((%d+).-)|h|r", replacement = "%2", handler = getSpellInfoFromHyperlink },
	other = { format = "|cff......|H%w+:((%d+).-)|h|r", replacement = "%2", handler = getSpellInfoFromHyperlink },
}
local ITEM_LINK_FORMATS_TUPLE = {}
for k, v in pairs(ITEM_LINK_FORMATS) do
	local tuple = CopyTable(v)
	tuple.type = k
	tinsert(ITEM_LINK_FORMATS_TUPLE, tuple)
end

local function convertLinksToIDs(text)
	for i = 1, #ITEM_LINK_FORMATS_TUPLE do
		text = text:gsub(ITEM_LINK_FORMATS_TUPLE[i].format, ITEM_LINK_FORMATS_TUPLE[i].replacement)
	end
	return text
end

local function convertSpellIDsToLinks(text)
	local finalText = gsub(text, "%d+", function(id)
		id = tonumber(id)
		local link = GetSpellLink(id)
		return link and link or id
	end)
	return finalText
end

local function convertItemIDsToLinks(text)
	local finalText = gsub(text, "%d+", function(id)
		id = tonumber(id)
		local _id, link = GetItemInfo(id)
		return link and link or id
	end)
	return finalText
end

---------------------------------------------------------
--- Table Helpers
---------------------------------------------------------

---@param delim string
---@param str string
---@param pieces? number
---@return table
local function strsplitTrimTable(delim, str, pieces)
	local strings = { strsplit(delim, str, pieces) }
	local finStrings = {}
	for k, v in ipairs(strings) do
		tinsert(finStrings, strtrim(v))
	end
	return finStrings
end

---@param delim string
---@param str string
---@param pieces? number
---@return ... strings
local function strsplitTrim(delim, str, pieces)
	return unpack(strsplitTrimTable(delim, str, pieces))
end

---@generic T
---@param t T
---@return T
local function orderedPairs(t, f) -- get keys & sort them - default sort is alphabetically, case insensitive using our custom comparartor
	if not f then f = caseInsensitiveCompare end
	local keys = {}
	for k in pairs(t) do keys[#keys + 1] = k end
	table.sort(keys, f)
	local i = 0          -- iterator variable
	local iter = function() -- iterator function
		i = i + 1
		if keys[i] == nil then
			return nil
		else
			return keys[i], t[keys[i]]
		end
	end
	return iter
end

---@generic K, V
---@param tbl table<K, V>
---@return K[]
local function keys(tbl)
	local keysArray = {};
	for key in pairs(tbl) do
		tInsert(keysArray, key);
	end
	return keysArray;
end

---@generic K, V
---@param tbl table<K, V>
---@return V[]
local function values(tbl)
	local valuesArray = {};
	for key, value in pairs(tbl) do
		tInsert(valuesArray, value);
	end
	return valuesArray;
end

---@generic K, V
---@param tbl table<K, V>
---@return { key: K, value: V }[]
local function entries(tbl)
	local pairsArray = {};
	for key, value in pairs(tbl) do
		tInsert(pairsArray, { key = key, value = value, });
	end
	return pairsArray;
end

---@generic K, V
---@param tbl table<K, V>
---@param predicate fun(value: V): boolean
---@return table<K, V>
local function filter(tbl, predicate)
	local out = {}

	for k, v in pairs(tbl) do
		if predicate(v) then
			out[k] = v
		end
	end

	return out
end

---@generic V
---@param array V[]
---@param value V
---@return integer
local function indexOf(array, value)
	for i, v in ipairs(array) do
		if v == value then
			return i
		end
	end
	return -1
end

local function do_tables_match_concat(a, b)
	return table.concat(a) == table.concat(b)
end

local function areTablesFunctionallyEquivalent(tableA, tableB)
	local longerTable = tableA;
	if #tableB > #tableA then longerTable = tableB end
	-- determine which table is larger to get the end
	-- of our iterator
	local mismatch = false;
	for i = 1, #longerTable do
		if not (tableB[i] == tableA[i]) then
			mismatch = true;
			break
		end
	end
	if not (mismatch) then return true end
	return false
end
---------------------------------------------------------
--- Number Helpers
---------------------------------------------------------

---Get the distance between two numbers, or between two x,y points.
---@param x1 number
---@param y1 number
---@param x2? number
---@param y2? number
---@return number
local function getDistanceBetweenPoints(x1, y1, x2, y2)
	if x2 and y2 then
		local dx = x1 - x2
		local dy = y1 - y2
		return math.sqrt(dx * dx + dy * dy) -- x * x is faster than x^2
	else
		local d = math.abs(x1 - y1)
		return d
	end
end

---@param num number the number to round
---@param n integer number of decimal places
---@return number number the rounded number
local function roundToNthDecimal(num, n)
	local mult = 10 ^ (n or 0)
	return math.floor(num * mult + 0.5) / mult
end

local function getDiffInTimeTable(t1, t2)
	local timeDiff = time(t2) - time(t1)
	local isPast = (timeDiff < 0)
	timeDiff = math.abs(timeDiff)

	local days = floor(timeDiff / 86400); if isPast then days = 0 - days end
	local hours = floor(mod(timeDiff, 86400) / 3600); if isPast then hours = 0 - hours end
	local minutes = floor(mod(timeDiff, 3600) / 60); if isPast then minutes = 0 - minutes end

	if isPast then timeDiff = 0 - timeDiff end -- convert back to negative

	return timeDiff, { days = days, hours = hours, minutes = minutes }
end

local function getDiffInTimeHM(h1, m1, h2, m2)
	local t1, t2 = date("*t"), date("*t")
	t1.hour = h1
	t1.min = m1
	t1.sec = 0
	t2.hour = h2
	t2.min = m2
	t2.sec = 0

	return getDiffInTimeTable(t1, t2)
end

---Checks if a given time is within X minutes, >, or < current Game Time.
---@param time string|osdateparam The time to test against game time
---@param mod? number|string The number of minutes on either side to test, or ">" or "<" to check respectively. If not given, checks if time is exactly
---@return boolean
local function getNormalizedGameTimeDiff(time, mod)
	if not time then return false end
	local testH, testM = 0, 0

	-- convert time
	if type(time) == "string" then
		testH, testM = strsplit(":", time, 2)
	elseif type(time) == "table" then
		testH = time.hour and time.hour or 0 --[[@as integer]]
		testM = time.min and time.min or 0 --[[@as integer]]
	end

	-- convert mod if able
	if not mod then mod = 0 end
	if tonumber(mod) then mod = tonumber(mod) --[[@as number]] end

	local minInDay = 1440
	local curH, curM = GetGameTime()
	local curT = curM + (curH * 60) -- time in minutes after midnight
	testH = tonumber(testH) --[[@as integer]]
	testM = tonumber(testM) --[[@as integer]]
	if not testH or not testM then return false end
	local testT = testM + (testH * 60)

	if type(mod) == "number" then
		local timeMin = (testT - mod % minInDay)
		local timeMax = (testT + mod % minInDay)
		if curT > timeMin and curT < timeMax then -- time is greater than min, less than max
			return true
		else
			return false
		end
	elseif type(mod) == "string" then
		if mod == ">" then -- check time greater
			return curT >= testT
		elseif mod == "<" then -- check time less
			return curT <= testT
		end
	end
	return false -- you made it to the end, that's a fail!
end

---@param date {year: integer, month: integer, day: integer, hour: integer?, min: integer?, sec: integer?}
local function isTodayAfterOrEqualDate(date)
	local rightNow = time()
	local whatDate = time(date)
	if rightNow > whatDate then return true else return false end
end

local function adjustNumbersInRange(inputStr, lowerBound, upperBound, adjustment)
	local adjustedStr = inputStr
	local hadUpdate = false
	for numStr in string.gmatch(inputStr, "%d+") do
		local num = tonumber(numStr)
		if num >= lowerBound and num <= upperBound then
			local newNum = num + adjustment
			hadUpdate = true
			adjustedStr = adjustedStr:gsub(num, tostring(newNum))
		end
	end

	return adjustedStr, hadUpdate
end

---@class Utils_Data
ns.Utils.Data = {
	isNotDefined = isNotDefined,
	toBoolean = toBoolean,
	orderedPairs = orderedPairs,
	caseInsensitiveCompare = caseInsensitiveCompare,
	firstToUpper = firstToUpper,
	wordToProperCase = wordToProperCase,
	sanitizeNewlinesToCSV = sanitizeNewlinesToCSV,
	--getCSVArgsFromString = getCSVArgsFromString,
	parseStringToArgs = parseStringToArgs,
	parseArgsWrapper = parseArgsWrapper,
	getArgs = getArgs,
	secondsToMinuteSecondString = secondsToMinuteSecondString,
	adjustNumbersInRange = adjustNumbersInRange,

	strsplitTrimTable = strsplitTrimTable,
	strsplitTrim = strsplitTrim,
	do_tables_match_concat = do_tables_match_concat,
	areTablesFunctionallyEquivalent = areTablesFunctionallyEquivalent,

	getSpellInfoFromHyperlink = getSpellInfoFromHyperlink,
	getItemInfoFromHyperlink = getItemInfoFromHyperlink,
	convertLinksToIDs = convertLinksToIDs,
	convertItemIDsToLinks = convertItemIDsToLinks,
	convertSpellIDsToLinks = convertSpellIDsToLinks,

	keys = keys,
	values = values,
	entries = entries,
	filter = filter,
	indexOf = indexOf,

	getDistanceBetweenPoints = getDistanceBetweenPoints,
	roundToNthDecimal = roundToNthDecimal,
	isTodayAfterOrEqualDate = isTodayAfterOrEqualDate,
	getDiffInTimeHM = getDiffInTimeHM,
	getDiffInTimeTable = getDiffInTimeTable,
	getNormalizedGameTimeDiff = getNormalizedGameTimeDiff,

	getRandomArg = getRandomArg,
	getRandomWeightedArg = getRandomWeightedArg,
}
