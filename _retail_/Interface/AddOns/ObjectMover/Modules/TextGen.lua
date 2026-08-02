local ADDON_NAME = ...
---@class ns
local ns = select(2, ...)

local Constants = ns.Constants
local Colors = Constants.colors
local Utils = ns.Utils
local cmd = Utils.cmd
local cmdChain = Utils.cmdChain
local op_cmd = Utils.op_cmd
local clearMsg = Utils.clearMsg


--- Word Generator

local wordGenCharMap = {
	[48] = "10001083", --0
	[49] = "10001086", --1
	[50] = "10001081", --2
	[51] = "10001082", --3
	[52] = "10001089", --4
	[53] = "10001085", --5
	[54] = "10001079", --6
	[55] = "10001087", --7
	[56] = "10001088", --8
	[57] = "10001084", --9

	[33] = "10001067", -- !
	[47] = "10001068", -- /
	[38] = "10001069", -- &
	[45] = "10001071", -- -
	[43] = "10001075", -- +
	[58] = "10001076", -- :
	[63] = "10001077", -- ?
	[59] = "10001078", -- ;
	[124] = "10001073", -- | -> sword replacement
	[60] = "10001538", -- <
	[62] = "10001537", -- >
}

local startingLetterID = 10001510
local function getCharIndexOffset(char, index)
	local letterID = string.byte(char, index)
	if letterID >= 65 and letterID <= 90 then -- Letter
		letterID = letterID - 65           -- offset to A == 0
		letterID = startingLetterID + letterID
	elseif wordGenCharMap[letterID] then   -- if supported symbol, or number
		letterID = wordGenCharMap[letterID]
	else                                   -- unsupported or space
		letterID = 0
	end
	return letterID
end

local wordGenCharOffsets = {
	[getCharIndexOffset("B")] = { x = 0, y = -0.0275 },
	[getCharIndexOffset("E")] = { x = 0, y = 0.01 },
	[getCharIndexOffset("F")] = { x = 0, y = 0.0175 },
	[getCharIndexOffset("H")] = { x = 0, y = 0.01 },
	[getCharIndexOffset("I")] = { x = 0, y = 0.0175 },
	[getCharIndexOffset("J")] = { x = 0, y = -0.0175 },
	[getCharIndexOffset("K")] = { x = 0, y = 0.035 },
	[getCharIndexOffset("L")] = { x = 0, y = 0.0175 },
	[getCharIndexOffset("N")] = { x = 0, y = -0.035 },
	[getCharIndexOffset("O")] = { x = 0, y = -0.035 },
	[getCharIndexOffset("Q")] = { x = 0, y = 0.0025 },
	[getCharIndexOffset("R")] = { x = 0, y = 0.0175 },
	[getCharIndexOffset("S")] = { x = 0, y = -0.0125 },
	[getCharIndexOffset("T")] = { x = 0, y = 0.01 },
	[getCharIndexOffset("U")] = { x = 0, y = 0.0125 },
	[getCharIndexOffset("V")] = { x = 0, y = -0.02 },
	[getCharIndexOffset("W")] = { x = 0, y = 0.03 },
	[getCharIndexOffset("X")] = { x = 0, y = 0.02 },
	[getCharIndexOffset("Z")] = { x = 0, y = -0.03 },
}

local function getSpawnCharWithOffsetCommand(letterID, offsetX, lineNum)
	local lineHeight = (lineNum or 1) - 1
	if wordGenCharOffsets[letterID] then
		local charData = wordGenCharOffsets[letterID]
		return ("gobject spawn " .. letterID .. " move left " .. offsetX .. " move up " .. (charData.y - (lineHeight or 0)))
		--print("object required y-offset by " .. charData.y)
	else
		return ("gobject spawn " .. letterID .. " move left " .. offsetX .. " move down " .. lineHeight)
	end
end

StaticPopupDialogs["OM_TOOL_TEXTGEN"] = {
	text = "Text Generator",
	subText = ("Enter Text, then hit '%s' to Spawn.\n\rMay spawn multiple lines.\n\rSupported Symbols: ! / & - + ; : ? | < >\n\r")
		:format(START),
	button1 = START,
	button2 = CANCEL,
	OnAccept = function(self)
		local editBox = self.insertedFrame.EditBox
		local letterWidth = 0.75
		local full_text = string.upper(editBox:GetText())
		full_text = full_text:gsub("%|%|", "|")

		if #full_text == 0 then return end                                                                      -- Empty String, cancel early
		if #full_text == 1 then return cmd(getSpawnCharWithOffsetCommand(getCharIndexOffset(full_text, 1), 0, 1)) end -- Only 1 character, spawn it solo, move on

		local strTable = { strsplit("\n", full_text) }
		local spawnTable = {}

		for line, text in ipairs(strTable) do
			for i = 1, #text do
				if line == 1 and i == 1 then
					-- First Line & First Character; This is going to be reserved as our first spawn to get the group leader, then initiate the chain from there.
				else
					local letterID = getCharIndexOffset(text, i)
					if letterID ~= 0 then
						table.insert(spawnTable, getSpawnCharWithOffsetCommand(letterID, letterWidth * (i - 1), line));
						table.insert(spawnTable, "gobject group add %s")
					end
				end
			end
		end

		local firstChar = getCharIndexOffset(strTable[1], 1)
		local firstSpawnCommand = getSpawnCharWithOffsetCommand(firstChar, 0, 1)

		local function spawnRemainingGobs(groupLeaderID)
			-- Sub in our Group Leader ID
			for i = 2, #spawnTable, 2 do
				spawnTable[i] = spawnTable[i]:format(groupLeaderID)
			end

			cmdChain(spawnTable, function(success, msg) if success then cmd(("gob group sel %s"):format(groupLeaderID)) end end)
		end

		local function onFirstSpawnCallback(success, messages)
			if not success then error("Failed to Spawn Text Gen?") end
			local groupLeaderID
			for k, v in ipairs(messages) do
				local v = clearMsg(v)
				-- %(GUID: |Hgameobject_GUID:%d+|h(%d+)|h%)
				local idMatch = v:match("%(GUID: |Hgameobject_GUID:%d+|h(%d+)|h%)")
				if idMatch then
					groupLeaderID = idMatch
					break
				end
			end
			if not groupLeaderID then error("Failed to Spawn or Capture Group Leader Gobject") end
			spawnRemainingGobs(groupLeaderID)
		end
		op_cmd(firstSpawnCommand, nil, nil, onFirstSpawnCallback)
	end,
	OnShow = function(self)
		local editBox = self.insertedFrame.EditBox
		editBox:SetText("")
	end,
	OnHide = function(self)
		local editBox = self.insertedFrame.EditBox
		editBox:SetText("")
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	editBoxWidth = 330,
}

local multiLineInputBox = CreateFrame("ScrollFrame", nil, nil, "InputScrollFrameTemplate")
multiLineInputBox:SetPoint("CENTER")
multiLineInputBox:SetSize(330, 180)
multiLineInputBox.EditBox:SetWidth(multiLineInputBox:GetWidth() - 18)
multiLineInputBox.maxLetters = 255
multiLineInputBox.EditBox:SetFont("Interface\\Addons\\" .. ADDON_NAME .. "\\media\\COLONNA.TTF", 16)
multiLineInputBox.EditBox:SetScript("OnTextChanged", function(self)
	self:SetText(strupper(self:GetText()))
end)
multiLineInputBox:Hide()

local function showWordGenMenu()
	if StaticPopup_Visible("OM_TOOL_TEXTGEN") then return end
	StaticPopup_Show("OM_TOOL_TEXTGEN", nil, nil, customData, multiLineInputBox);
end

local textGen = {
	text = "Text Generator",
	tooltipText = "Easily spawn full lines of text using the Epsilon Alphabet objects.",
	func = showWordGenMenu,
	disabled = function()
		return not EpsilonLib.GameObject.CanSpawn()
	end,
}
ns.AddTool({ textGen })
