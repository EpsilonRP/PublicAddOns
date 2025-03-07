local EpsilonLib, EpsiLib   = ...;

-- Module Table
EpsiLib.PhaseAddonData      = EpsiLib.PhaseAddonData or {}

local debug                 = false

-- Local Util & Generic Vars
local CopyTable             = CopyTable
local wipe                  = wipe
local tinsert               = tinsert

local getAddonData          = C_Epsilon.GetPhaseAddonData --[[@as fun(key)]]
local setAddonData          = C_Epsilon.SetPhaseAddonData --[[@as fun(key,str)]]

local MSG_MULTI_FIRST       = "\001"
local MSG_MULTI_NEXT        = "\002"
local MSG_MULTI_LAST        = "\003"
local MAX_CHARS_PER_SEGMENT = 3000

-- Max Calls Per Interval (Seconds)
local throttle_max_calls    = 45
local throttle_interval     = 1.5

--#region Internal Systems

-- Create our Listener Frame for listening to incoming PhaseAddonData messages
local listenerFrame         = CreateFrame("Frame")
listenerFrame:RegisterEvent("CHAT_MSG_ADDON")

-- Create our Queue & Pending system
EpsiLib.PhaseAddonData.queue = {}
EpsiLib.PhaseAddonData.pending = {}
local callCount = 0

---Transforms a key into it's iteration variant, handling %s as a placement marker if present, or just appending it as _# if not; If 1st iter or no iter, then just remove marker if present.
---@param key string
---@param iter number
---@return string
local function getIterKey(key, iter)
	if iter and iter > 1 then
		-- Allow us to use %s in keys to explicitly state where the iter goes
		if key:find("%%s") then
			key = key:format(iter)
		else
			-- not iter marker, append
			key = key .. "_" .. iter
		end
	else
		-- not an iter, or first part, remove marker if present
		key = key:gsub("%%s", "")
	end

	return key
end

local function dprint(...)
	if debug then print(...) end
end

local function stashRequest(keyOrTable, callback, strs)
	if type(keyOrTable) == "table" then
		-- prioritize table calls as they are likely internal calls for 2nd data pieces
		tinsert(EpsiLib.PhaseAddonData.pending, 1, keyOrTable)
		return keyOrTable
	end

	local dataTable = { key = keyOrTable, callback = callback, strs = (strs or {}) }
	tinsert(EpsiLib.PhaseAddonData.pending, dataTable)
	return dataTable
end

local function resumePending()
	local pending = CopyTable(EpsiLib.PhaseAddonData.pending)
	wipe(EpsiLib.PhaseAddonData.pending)
	for i = 1, #pending do
		local pendingData = pending[i]

		if not pendingData.cancelled then -- if marked cancelled, ignore it and move on
			EpsiLib.PhaseAddonData.RequestAddonData(pendingData)
		end
	end
end

--#endregion
--#region Public API

---Requests the Data from the Phase via key, then calls the callback with the data as the first variable
---@param keyOrTable string|table The key to request - note that the table option is primarily for internal use, but you can technically pass it as a table with keys for key & callback. Do not use the strs key, it's used internally, unless you just want to read the data later. Also note that table calls are prioritized over standard key calls, as they are assumed to be internal multi-part calls..
---@param callback? fun(phaseDataString:string) The callback to run once the data is retrieved. Final data string is passed in - if multi-part, it's already pre-joined for you.
---@param strTable? table **internal only, do not use** the table of strs so far (to calculate iter as well)
---@return string|boolean ticket The Message Ticket the server will reply using as the prefix, or the false if it was stashed.
---@return table? stashedTable The reference table in the pending queue if the request was stashed
function EpsiLib.PhaseAddonData.RequestAddonData(keyOrTable, callback, strTable)
	if callCount > throttle_max_calls then
		return false, stashRequest(keyOrTable, callback, strTable)
	end

	local key = keyOrTable
	if type(keyOrTable) == "table" then
		callback = keyOrTable.callback
		strTable = keyOrTable.strs
		key = keyOrTable.key

		if keyOrTable.cancelled then return false end -- passed with a cancelled request.. dunno how, but don't do it!
	end

	callCount = callCount + 1
	if callCount == 1 then
		C_Timer.After(throttle_interval, function() -- reset after our throttle interval & resume any pending requests
			callCount = 0
			resumePending()
		end)
	end

	local iter = strTable and #strTable or nil
	if iter == 0 then iter = nil end -- in the case it's stashed with no strs yet, iter should be nil still
	local dataKey = getIterKey(key, (iter and iter+1))

	dprint("Requested: " .. dataKey)
	local ticket = getAddonData(dataKey)
	EpsiLib.PhaseAddonData.queue[ticket] = { callback = callback, key = key, strs = (strTable or {}) }
	return ticket
end

EpsiLib.PhaseAddonData.GetPhaseAddonData = EpsiLib.PhaseAddonData.RequestAddonData
EpsiLib.PhaseAddonData.Get = EpsiLib.PhaseAddonData.RequestAddonData
EpsiLib.PhaseAddonData.Request = EpsiLib.PhaseAddonData.RequestAddonData


---Set PhaseAddonData but with automatic handling of over-sized data
---@param key string The key to use. You may use %s in the key to indicate where the iter goes, otherwise it will be appended to the end as _X where X = the iter count, if the str requires split
---@param str string
function EpsiLib.PhaseAddonData.SetAddonData(key, str)
	local strLength = #str
	if strLength > MAX_CHARS_PER_SEGMENT then
		local numEntriesRequired = math.ceil(strLength / MAX_CHARS_PER_SEGMENT)
		for i = 1, numEntriesRequired do
			local strSub = string.sub(str, (MAX_CHARS_PER_SEGMENT * (i - 1)) + 1, (MAX_CHARS_PER_SEGMENT * i))
			if i == 1 then
				strSub = MSG_MULTI_FIRST .. strSub

				-- remove iter marker for first key if present; no iter for first!
				local dataKey = getIterKey(key)
				setAddonData(dataKey, strSub)
				dprint("Set1: " .. dataKey)
			else
				local controlChar = MSG_MULTI_NEXT
				if i == numEntriesRequired then controlChar = MSG_MULTI_LAST end
				strSub = controlChar .. strSub

				-- Allow us to use %s in keys to explicitly state where the iter goes
				local dataKey = getIterKey(key, i)
				setAddonData(dataKey, strSub)
				dprint("Set2: " .. dataKey)
			end
		end
	else
		-- remove the iter marker if present & save
		local dataKey = getIterKey(key)
		setAddonData(dataKey, str)
		dprint("Set3: " .. dataKey)
	end
end

EpsiLib.PhaseAddonData.SetPhaseAddonData = EpsiLib.PhaseAddonData.SetAddonData
EpsiLib.PhaseAddonData.Set = EpsiLib.PhaseAddonData.SetAddonData

--#endregion
--#region Handler for Server Replies

listenerFrame:SetScript("OnEvent", function(self, event, prefix, text, channel, sender, ...)
	if event == "CHAT_MSG_ADDON" and EpsiLib.PhaseAddonData.queue[prefix] then
		local dataTable = EpsiLib.PhaseAddonData.queue[prefix]

		local iter = #dataTable.strs
		dprint("Received: " .. getIterKey(dataTable.key, iter + 1))

		if string.match(text, "^[\001-\002]") then -- if first character is a multi-part identifier - \001 = first, \002 = middle, then we can add it to the strings table, and return with a call to get the next segment
			-- remove the control character
			text = text:gsub("^[\001-\002]", "")

			-- insert into the strings table
			table.insert(dataTable.strs, text)

			-- request the next iteration
			local ticket, stashed = EpsiLib.PhaseAddonData.RequestAddonData(dataTable)

			-- Remove the previous queue, already handled
			EpsiLib.PhaseAddonData.queue[prefix] = nil

			-- And exit this call
			return ticket
		elseif string.match(text, "^[\003]") then -- if first character is a last identifier - \003 = last, then we can add it to our table, then concat into a final string to use and continue
			-- remove the control character
			text = text:gsub("^[\003]", "")

			-- insert into the strings table
			table.insert(dataTable.strs, text)

			-- Create our final string from all the strs
			text = table.concat(dataTable.strs, "")
		end

		-- If we handled the last multi-part, or got here without being multipart,
		-- continue to passing the text result to the callback
		-- and remove from the queue

		EpsiLib.PhaseAddonData.queue[prefix].callback(text)
		EpsiLib.PhaseAddonData.queue[prefix] = nil
	end
end)

--#endregion
