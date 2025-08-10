local EpsilonPhases = LibStub("AceAddon-3.0"):NewAddon("EpsilonPhases", "AceConsole-3.0", "AceEvent-3.0")
local PhaseClass = EpsilonLib.Classes.Phase
local privatePhasesLoaded = false
BINDING_HEADER_PHASE_CODEX = "Phase Codex"
BINDING_NAME_PHASE_CODEX_QUICK_ACCESS = "Quick Access"
BINDING_NAME_PHASE_CODEX_OPEN = "Open Codex"

EpsilonPhases.previousTempPhase = nil

local function phaseInfoCallback(phase)
    tinsert(EpsilonPhases.PrivatePhases, phase)
    EpsilonPhases:RefreshPhases()
    privatePhasesLoaded = true
end
local function addPrivatePhase(phaseId, permanent)
	if permanent then
		tinsert(EpsilonPhases.db.global.PrivatePhases, phaseId, '')
	end
	if not EpsilonPhases:IsPhaseInTable(phaseId, EpsilonPhases.PrivatePhases) then
		PhaseClass:Get(phaseId, phaseInfoCallback)
	end
end
EpsilonPhases.addPrivatePhase = addPrivatePhase

StaticPopupDialogs["ADD_PHASE"] = {
	text = "Which Phase do you want to add?",
	button1 = "Add phase",
	button2 = "Cancel",
	OnAccept = function(self, data, data2)
		local id = tonumber(self.editBox:GetText())
		addPrivatePhase(id, true)
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	hasEditBox = true,
}

StaticPopupDialogs["REMOVE_PHASE"] = {
	text = "Remove %s?",
	button1 = "Yes",
	button2 = "Cancel",
	OnAccept = function(self, data)
		EpsilonPhases.removePrivatePhase(data)
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
}


StaticPopupDialogs["CLICK_LINK_CLICKURL"] = {
	text = "Copy & Paste",
	button1 = "Close",
	OnAccept = function()
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
	OnShow =
		function(self, data)
			self.editBox:SetText(data)
			self.editBox:HighlightText()
		end,
	hasEditBox = true
}

local function phaseShareCallback(phase)
	if not EpsilonPhases:IsPhaseInTable(phase:GetPhaseID(), EpsilonPhases.PrivatePhases) then
		tinsert(EpsilonPhases.PrivatePhases, phase)
	end
	EpsilonPhases:Show(phase:GetPhaseID())
end


local function removePrivatePhase(phaseId)
	EpsilonPhases.db.global.PrivatePhases[phaseId] = nil
	for i, phase in pairs(EpsilonPhases.PrivatePhases) do
		if phase:GetPhaseID() == phaseId then
			table.remove(EpsilonPhases.PrivatePhases, i)
			break
		end
	end
	EpsilonPhases.RefreshPhases()
end
EpsilonPhases.removePrivatePhase = removePrivatePhase

local function setPhaseJoinModKeyDownFunction(value)
	if value == 1 then
		EpsilonPhases.IsPhaseJoinModKeyDown = IsControlKeyDown
	elseif value == 2 then
		EpsilonPhases.IsPhaseJoinModKeyDown = IsShiftKeyDown
	elseif value == 3 then
		EpsilonPhases.IsPhaseJoinModKeyDown = IsAltKeyDown
	end
end

local function setIsRankToAutomaticallyAddPhase(value)
	if value == 1 then
		EpsilonPhases.IsRankToAutomaticallyAddPhase = C_Epsilon.IsOwner
	elseif value == 2 then
		EpsilonPhases.IsRankToAutomaticallyAddPhase = C_Epsilon.IsOfficer
	elseif value == 3 then
		EpsilonPhases.IsRankToAutomaticallyAddPhase = C_Epsilon.IsMember
	else
		EpsilonPhases.IsRankToAutomaticallyAddPhase = function() return true end
	end
end

local function setStartTab(value)
	if value == 1 then
		EpsilonPhases.SetStartTab = EpsilonPhases.SetPhaseListToPublic
	elseif value == 2 then
		EpsilonPhases.SetStartTab = EpsilonPhases.SetPhaseListToMalls
	elseif value == 3 then
		EpsilonPhases.SetStartTab = EpsilonPhases.SetPhaseListToPrivate
	end
end

local function setQuickAccessHotkey(hotkey)
	if hotkey ~= nil then
		SetBinding(hotkey, "PHASE_CODEX_QUICK_ACCESS")
	end
end

local function setOpenAccessHotkey(hotkey)
	if hotkey ~= nil then
		SetBinding(hotkey, "PHASE_CODEX_OPEN")
	end
end

local function setHomePhaseEntry(entry)
	EpsilonPhases.HomePhaseEntry = entry
end

local function setSettingsFunctions(options, homePhaseEntry)
	setPhaseJoinModKeyDownFunction(options.PhaseJoinModKey)
	setIsRankToAutomaticallyAddPhase(options.PhaseJoinMinimumRank)
	setStartTab(options.StartTab)
	setQuickAccessHotkey(options.quickAccesHotkey)
	setOpenAccessHotkey(options.openHotkey)
	setHomePhaseEntry(homePhaseEntry)
end

function EpsilonPhases:Show(phaseID, tab)
	if EpsilonPhasesMainFrame:IsVisible() then
		EpsilonPhasesMainFrame:Hide()
		EpsilonPhasesPhaseListFrame:Hide()
	else
		EpsilonPhasesMainFrame:Show()
		EpsilonPhasesPhaseListFrame:Show()

		if tab == 1 then
			EpsilonPhases:SetPhaseListToPublic()
		elseif tab == 2 then
			EpsilonPhases:SetPhaseListToMalls()
		elseif tab == 3 then
			EpsilonPhases:SetPhaseListToPrivate()
		else
			EpsilonPhases.SetStartTab()
		end
		if phaseID ~= nil then
			EpsilonPhases.SetCurrentActivePhaseByPhaseID(phaseID)
		end
	end
end

local sendAddonCmd
if EpsilonLib and EpsilonLib.AddonCommands then
	sendAddonCmd = EpsilonLib.AddonCommands.Register("PhaseCodex")
else
	-- command, callbackFn, forceShowMessages
	function sendAddonCmd(command, callbackFn, forceShowMessages)
		if EpsilonLib and EpsilonLib.AddonCommands then
			-- Reassign it.
			sendAddonCmd = EpsilonLib.AddonCommands.Register("PhaseCodex")
			sendAddonCmd(command, callbackFn, forceShowMessages)
			return
		end

		-- Fallback ...
		print("Warning: PhaseCodex had to fallback to standard chat commands. Is your EpsilonLib okay??")
		SendChatMessage("." .. command, "GUILD")
	end
end
EpsilonPhases.SendAddonCommand = sendAddonCmd

local function CreateMinimapIcon()
	LibStub("EpsiLauncher-1.0").API.new("Phase Codex", function()
		EpsilonPhases:Show()
	end, EpsilonPhases.ASSETS_PATH .. "/EpsilonTrayIconCodex", { "Click to open the Phase Codex." })
end

local function phaseOverviewCallback(phases, store)
	if #phases > 0 then
		EpsilonPhases:SetupPhaseList(phases)
	else
		local emptyOverviewList = {
			[1] = store[169]
		}
		EpsilonPhases:SetupPhaseList(emptyOverviewList)
	end
end

local function GetPublicPhases()
	EpsilonLib.Classes.Phase:Get(169)
	EpsilonLib.Classes.Phase:RequestOverview(phaseOverviewCallback)
end
EpsilonPhases.GetPublicPhases = GetPublicPhases

local function JoinPhase(phase)
	local phaseID = tonumber(phase:GetPhaseID())
	local mallEntryOverride = EPSILON_BH_MALLS_CACHE[phaseID]
	if EpsilonPhases.IsPhaseJoinModKeyDown() then
		sendAddonCmd("phase enter " .. phaseID .. " here")
	elseif (phase.data.entry ~= nil and phase.data.entry ~= "") or mallEntryOverride then
		local entry = phase.data.entry or mallEntryOverride or ""
		sendAddonCmd("phase enter " .. phaseID .. " " .. entry)
	else
		sendAddonCmd("phase enter " .. phaseID)
	end
end
EpsilonPhases.JoinPhase = JoinPhase


local function GetPrivatePhases()
	for k, _ in pairs(EpsilonPhases.db.global.PrivatePhases) do
		PhaseClass:Get(k, phaseInfoCallback)
	end
end

local function SlashCommandProcessor(input)
	local helpMessage = {
		[1] = "|cff33f3ff[C|r|cff48ddffo|r|cff72c7ffd|r|cff96adffe|r|cffc489fax]|r Epsilon Phase Codex commands:",
		[2] = "|cff33f3ff[C|r|cff48ddffo|r|cff72c7ffd|r|cff96adffe|r|cffc489fax]|r |cff00ff00/codex open|r - opens the codex",
		[3] = "|cff33f3ff[C|r|cff48ddffo|r|cff72c7ffd|r|cff96adffe|r|cffc489fax]|r |cff00ff00/codex public|r- opens the codex on public tab",
		[4] = "|cff33f3ff[C|r|cff48ddffo|r|cff72c7ffd|r|cff96adffe|r|cffc489fax]|r |cff00ff00/codex malls|r - opens the codex on malls tab",
		[5] = "|cff33f3ff[C|r|cff48ddffo|r|cff72c7ffd|r|cff96adffe|r|cffc489fax]|r |cff00ff00/codex personal|r - opens the codex on personal tab",
	}

	if string.match(input, 'open') then
		EpsilonPhases:Show()
	elseif string.find(input, 'addphase') then
		local phaseID = string.match(input, 'addphase (%d+)')
		EpsilonPhases:addPrivatePhase(phaseID)
	elseif string.find(input, 'fave') then
		EpsilonPhases.Favourites[tonumber(C_Epsilon.GetPhaseId())] = true
	elseif string.find(input, 'malls') then
		EpsilonPhases.UpdatePhaseMallsHorizCache()
		EpsilonPhases:Show(nil, 2)
	elseif string.find(input, 'public') then
		EpsilonPhases:Show(nil, 1)
	elseif string.find(input, 'personal') then
		EpsilonPhases:Show(nil, 3)
	else
		for _, line in ipairs(helpMessage) do
			print(line)
		end
	end
end

EpsilonPhases:RegisterChatCommand("codex", SlashCommandProcessor)
EpsilonPhases:RegisterChatCommand("epsiloncodex", SlashCommandProcessor)
EpsilonPhases:RegisterChatCommand("phasecodex", SlashCommandProcessor)
EpsilonPhases:RegisterChatCommand("pc", SlashCommandProcessor)


function EpsilonPhases:OnInitialize()
	self:RegisterChatCommand("phases", "Show")
	self.db = LibStub("AceDB-3.0"):New("EpsilonPhasesDB", {
		global = {
			PrivatePhases = {},
			Favourites = {},
			Options = {
				PhaseJoinModKey = 1,
				PhaseJoinMinimumRank = 2,
				StartTab = 1,
				ReplaceOverview = true,
			},
		},
		char = {
			HomePhase = nil,
			HomePhaseEntry = 'here',
		}
	})

	local addonOptions = {
		type = "group",
		args = {
			hotkeys = {
				type = "group",
				name = "Hotkeys",
				args = {
					quickAccesHotkey = {
						name = "Quick access",
						desc = "Hotkey to open the phase list while pressed",
						type = "keybinding",
						get = function()
							return self.db.global.Options.quickAccesHotkey
						end,
						set = function(_, value)
							self.db.global.Options.quickAccesHotkey = value
							setQuickAccessHotkey(value)
						end
					},
					openHotkey = {
						name = "Open",
						desc = "Hotkey to open the phase list",
						type = "keybinding",
						get = function()
							return self.db.global.Options.openHotkey
						end,
						set = function(_, value)
							self.db.global.Options.openHotkey = value
							setOpenAccessHotkey(value)
						end
					},
				},
			},
			general = {
				type = "group",
				name = "General",
				args = {
					startTab = {
						name = "Start tab",
						desc = "The tab that is selected by default when you open the Phase Codex",
						type = "select",
						values = { "Public", "Mall", "Personal" },
						order = 1,
						get = function()
							return self.db.global.Options.StartTab
						end,
						set = function(_, value)
							self.db.global.Options.StartTab = value
							setStartTab(value)
						end
					},
					replaceOverview = {
						name = "Open Codex with Phase Overview",
						desc = "Opens the Phase Codex when you use '.phase overview', instead of printing the overview in chat.",
						type = "toggle",
						width = "full",
						order = 2,
						get = function()
							return self.db.global.Options.ReplaceOverview
						end,
						set = function(_, value)
							self.db.global.Options.ReplaceOverview = value
						end
					},
				}
			},
			phaseJoin = {
				type = "group",
				name = "Phase Join",
				args = {
					modKey = {
						name = "Phase Join modifier key",
						desc =
						"When holding this key while clicking the join button you will enter the phase where you are",
						type = "select",
						values = { "CTRL", "SHIFT", "ALT" },
						get = function()
							return self.db.global.Options.PhaseJoinModKey
						end,
						set = function(_, value)
							self.db.global.Options.PhaseJoinModKey = value
							setPhaseJoinModKeyDownFunction(value)
						end
					},
					homePhaseEntry = {
						name = "Home Phase Entrypoint",
						desc = "The entrypoint to join your home phase",
						type = "input",
						get = function()
							return self.db.char.HomePhaseEntry
						end,
						set = function(_, value)
							self.db.char.HomePhaseEntry = value
							setHomePhaseEntry(value)
						end
					},
					joinRank = {
						name = "Minimum auto-add rank",
						desc =
						"The minimum rank you need to have for a phase you join to be automatically added to your list of personal phases",
						type = "select",
						values = { "Owner", "Officer", "Member", "Every Phase" },
						get = function()
							return self.db.global.Options.PhaseJoinMinimumRank
						end,
						set = function(_, value)
							self.db.global.Options.PhaseJoinMinimumRank = value
							setIsRankToAutomaticallyAddPhase(value)
						end
					},
				}
			}
		},
	}
	LibStub("AceConfig-3.0"):RegisterOptionsTable("EpsilonPhases", addonOptions)
	self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("EpsilonPhases", "Phase Codex")
	EpsilonPhases.PrivatePhases = {}
	EpsilonPhases.Malls = {}
	EpsilonPhases.Favourites = self.db.global.Favourites
	EpsilonPhases.HomePhase = self.db.char.HomePhase
	EpsilonPhases.PublicPhases = {}
	CreateMinimapIcon()
end

function EpsilonPhases:IsPhaseInTable(phaseID, phaseTable)
	for _, phase in pairs(phaseTable) do
		if phase:GetPhaseID() == phaseID then
			return true
		end
	end
	return false
end

local function OnEvent(_, event, prefix, text, _, sender)
    if event == "CHAT_MSG_ADDON" then
        if prefix == "EPSILON_UNLIST" then
            local phaseID = string.match(text, ("(%d+)"))
            EpsilonPhases.RemovePhaseFromList(phaseID, EpsilonPhases.PublicPhases)
        elseif prefix == EpsilonPhases.SEND_ADDON_MESSAGE_PREFIX then
            local sender = string.match(sender, "^(.-)-")
            local id, name = string.match(text, "^(%d+),(.+)$")
            local dialog = StaticPopup_Show("GET_PHASE", sender, name)
            dialog.data = tonumber(id)
        end
    end
end

EpsilonPhases:RegisterEvent("PLAYER_ENTERING_WORLD", function(_, isLogin, isReload)
	if EpsilonPhases.HomePhase ~= nil and isLogin and not isReload then
		EpsilonPhases:RegisterEvent("FIRST_FRAME_RENDERED", function()
			EpsilonPhases:GetMallsFromMPDirectory()
			if EpsilonPhases.HomePhase ~= nil and isLogin and not isReload then
				C_Timer.After(1,
					function()
						sendAddonCmd("phase enter " ..
							EpsilonPhases.HomePhase .. ' ' .. EpsilonPhases.HomePhaseEntry)
					end)
			end
			EpsilonPhases:UnregisterEvent("FIRST_FRAME_RENDERED")
		end)
	end

	--only on zone switch
	if not isLogin and not isReload then
		local phaseId = tonumber(C_Epsilon:GetPhaseId())
		EpsilonPhases:SetSettingsButtonEnable()

		if EpsilonPhases.previousTempPhase ~= nil then
			EpsilonPhases.RemovePhaseFromList(EpsilonPhases.previousTempPhase, EpsilonPhases.PrivatePhases)
		end

        if privatePhasesLoaded then
            if EpsilonPhases.IsRankToAutomaticallyAddPhase() then
                addPrivatePhase(phaseId, true)
            elseif EpsilonPhases.Utils.isPhaseTemp(phaseId) then
                addPrivatePhase(phaseId, false)
                EpsilonPhases.previousTempPhase = phaseId
            end
        end
    end
end)

local SetHyperlink = ItemRefTooltip.SetHyperlink
function ItemRefTooltip:SetHyperlink(link)
	if strsub(link, 1, 6) == "phase:" then
		local id = tonumber(link:match(":(%d+)$"))
		PhaseClass:Get(id, phaseShareCallback)
	else
		SetHyperlink(self, link)
	end
end

hooksecurefunc("SetItemRef", function(link, text)
	if strsub(link, 1, 6) == "phase:" and EpsilonPhases.IsPhaseJoinModKeyDown() then
		local id = tonumber(link:match(":(%d+)$"))
		sendAddonCmd("phase enter " .. id)
	end
end)


function EpsilonPhases:OnEnable()
	setSettingsFunctions(self.db.global.Options, self.db.char.HomePhaseEntry)
	EpsilonPhasesMainFrame:SetScript("OnEvent", OnEvent)
	EpsilonPhasesMainFrame:RegisterEvent("SCENARIO_UPDATE")
	EpsilonPhasesMainFrame:RegisterEvent("CHAT_MSG_ADDON")
	C_ChatInfo.RegisterAddonMessagePrefix(EpsilonPhases.SEND_ADDON_MESSAGE_PREFIX)

    EpsilonPhases.SetPhaseListToPublic()
    GetPrivatePhases()
    self:GetMallsFromMPDirectory()
    EpsilonPhases:RegisterEvent("SCENARIO_UPDATE", function() 
        local phaseId = tonumber(C_Epsilon:GetPhaseId())
        EpsilonPhases:SetSettingsButtonEnable()
        if phaseId == 169 then
            -- We are back in Main Phase, refresh the malls cache
            EpsilonPhases:GetMallsFromMPDirectory()
        end
        EpsilonPhasesPhaseListFrame.MallAdminButton:ShowIfMember()

        if EpsilonPhases.previousTempPhase ~= nil then
            EpsilonPhases.RemovePhaseFromList(EpsilonPhases.previousTempPhase, EpsilonPhases.PrivatePhases)
        end

        if privatePhasesLoaded then
            if EpsilonPhases.IsRankToAutomaticallyAddPhase() then
                addPrivatePhase(phaseId, true)
            elseif EpsilonPhases.Utils.isPhaseTemp(phaseId) then
                addPrivatePhase(phaseId, false)
                EpsilonPhases.previousTempPhase = phaseId
            end
        end
    end)
    EpsilonPhases.Utils.ChatLinks_Init()
end

_G.EpsilonPhases = EpsilonPhases


-- Phase Overview Override

local Original_SendChatMessage = SendChatMessage
function SendChatMessage(msg, chatType, language, channel)
	if EpsilonPhases.db.global.Options.ReplaceOverview and type(msg) == "string" and not msg:lower():find("addon") then
		local trimmed = strtrim(msg:lower())
		local ph, ov = trimmed:match("^%.(ph%w*)%s+(ov%w*)$")
		if ph and ov then
			EpsilonPhases:Show()
			return
		end
	end

	-- Call the original function if not intercepted
	Original_SendChatMessage(msg, chatType, language, channel)
end
