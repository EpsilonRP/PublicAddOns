-------------------------------------------------------------------------------
-- Initialize Variables
-------------------------------------------------------------------------------
---@class ns
local ns = select(2, ...)

local ADDON_NAME = ...
local tooltip = ns.Utils.Tooltip
local icon = ns.Launcher.CONSTANTS.assetsPath .. "EpsilonTrayIconEditor"
local getSavedVars = function() return ns.Launcher.addon.db.profile end
local green = CreateColor(0.1, 1, 0.1, 1) -- Green color for messages

-------------------------------------------------------------------------------
-- Target Graphics API
-------------------------------------------------------------------------------

local editor_target_gxApi = "D3D11"
local editor_backup_gxApi = "D3D11_LEGACY"

local target_gxApi_name = _G["GXAPI_" .. editor_target_gxApi]
local backup_gxApi_name = _G["GXAPI_" .. editor_backup_gxApi]

-------------------------------------------------------------------------------
-- Check for correct gxApi on login and prompt user if needed
-------------------------------------------------------------------------------

-- Frame for event handling
local f = CreateFrame("Frame")

-- Get available gx APIs as a lookup table
local function GetAvailableGxAPIs()
	local apiSet = {}
	local apis = { GetGraphicsAPIs() }
	for _, api in ipairs(apis) do
		apiSet[api] = true
	end
	return apiSet
end
local availableGxAPIs = GetAvailableGxAPIs()
local target_gxApi_avail = availableGxAPIs[editor_target_gxApi] or false -- Check if target API is available
local backup_gxApi_avail = availableGxAPIs[editor_backup_gxApi] or false -- Check if backup API is available


-- Switch gxApi and reload UI to persist change
local function SwitchToTargetGXAPI()
	if not target_gxApi_avail and not backup_gxApi_avail then
		print("|cffFF0000Epsilon Editor Alert: Neither " .. target_gxApi_name .. " nor " .. backup_gxApi_name .. " are available. Please report to the #tech-support channel in Discord.")
		return
	end
	C_CVar.SetCVar("gxapi", (target_gxApi_avail and editor_target_gxApi) or (backup_gxApi_avail and editor_backup_gxApi))
	SendSystemMessage(green:WrapTextInColorCode("Epsilon Editor: Switching to " .. target_gxApi_name .. ". UI will now reload, then Graphics will restart after. UI Reload in 3..."))
	getSavedVars().restartGxOnReload = true
	C_Timer.After(1, function() SendSystemMessage(green:WrapTextInColorCode("UI Reload in 2...")) end)
	C_Timer.After(2, function() SendSystemMessage(green:WrapTextInColorCode("UI Reload in 1...")) end)
	C_Timer.After(3, function() C_Epsilon.RunPrivileged("ReloadUI()") end) -- Delay to ensure cvar is set before reload
end

-- Dialog definition (check insertedFrame for checkbox)
StaticPopupDialogs["EPSILON_SWITCH_GXAPI_ALERT"] = {
	text = "Epsilon Editor now requires %s for better performance (higher FPS!).\n\nWould you like to switch now?\n\r",
	OnShow = function(self)
		self.insertedFrame:ClearAllPoints()
		self.insertedFrame:SetPoint("TOP", self.text, "BOTTOM", -40, 0)
	end,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = SwitchToTargetGXAPI,
	OnCancel = function(_, data)
		if data and data:GetChecked() then
			getSavedVars().ignoreGXPrompt = true
		end
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
}

-- Dialog definition (check insertedFrame for checkbox)
StaticPopupDialogs["EPSILON_SWITCH_GXAPI_REQ"] = {
	text = "Epsilon Editor requires '%s' as your Graphics API setting.\n\nWould you like to switch now?\n\r",
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = SwitchToTargetGXAPI,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
}

-- Create checkbox frame once and reuse
local function CreateCheckBox()
	local checkbox = CreateFrame("CheckButton", "EpsilonGXPromptCheckbox", UIParent, "UICheckButtonTemplate")
	checkbox:SetSize(24, 24)
	checkbox:SetChecked(false)

	checkbox.text:SetText("Don't ask again")
	checkbox.text:SetPoint("LEFT", checkbox, "RIGHT", 0, 1)

	return checkbox
end

-- Check gxApi and prompt if needed
local function CheckGXAPISetting()
	local current = C_CVar.GetCVar("gxapi")
	if current == editor_target_gxApi then return end
	if getSavedVars().ignoreGXPrompt then return end

	local availableAPIs = availableGxAPIs or GetAvailableGxAPIs()

	-- Allow silently if target is unavailable and backup is current
	if not availableAPIs[editor_target_gxApi] and current == editor_backup_gxApi then
		return
	end

	-- Prompt only if target is available
	if availableAPIs[editor_target_gxApi] then
		local checkbox = CreateCheckBox()
		StaticPopup_Show("EPSILON_SWITCH_GXAPI_ALERT", target_gxApi_name, nil, checkbox, checkbox)
	end
end

-- Handle login
local function OnPlayerLogin()
	if getSavedVars().restartGxOnReload then
		getSavedVars().restartGxOnReload = nil
		SendSystemMessage(green:WrapTextInColorCode("Epsilon Editor: Restarting Graphics Engine to apply changes in 3..."))
		C_Timer.After(1, function()
			SendSystemMessage(green:WrapTextInColorCode("Restarting Gx in 2..."))
		end)
		C_Timer.After(2, function()
			SendSystemMessage(green:WrapTextInColorCode("Restarting Gx in 1..."))
		end)
		-- Restart the graphics engine
		C_Timer.After(3, function() C_Epsilon.RunPrivileged("RestartGx()") end)
		C_Timer.After(4, function() SendSystemMessage(green:WrapTextInColorCode("Epsilon Editor: Graphics Engine restarted successfully. You can use the Epsilon Editor now!")) end)
		return
	end

	CheckGXAPISetting()
end

-- Register events
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", function(_, event)
	if event == "PLAYER_LOGIN" then
		C_Timer.After(6, OnPlayerLogin)
	end
end)


-------------------------------------------------------------------------------
-- Epsilon Editor Minimap Button
-------------------------------------------------------------------------------

local function EpsilonOverlayUI_MinimapButton_OnClick(self)
	local curAPI = C_CVar.GetCVar("gxApi")

	-- If Current API is target, show menu
	if curAPI == editor_target_gxApi then
		C_Epsilon.ShowMenu()
		return

		-- If Current API is not target, check if target available & prompt to switch if so
	elseif target_gxApi_avail then
		StaticPopup_Show("EPSILON_SWITCH_GXAPI_REQ", target_gxApi_name)
		return

		-- If Current API is backup, show menu (we know main target not available already)
	elseif curAPI == editor_backup_gxApi then
		C_Epsilon.ShowMenu()
		return

		-- If Current API is not target or backup, but backup is available, prompt to switch
	elseif backup_gxApi_avail then
		StaticPopup_Show("EPSILON_SWITCH_GXAPI_REQ", backup_gxApi_name)
		return
	end
end

local tooltipGxStr
local curAPI = C_CVar.GetCVar("gxApi")
do
	-- No tooltip needed if already set to target API
	if curAPI == editor_target_gxApi then
		-- Target API Available, show tooltip for it's name
	elseif (target_gxApi_avail) then
		tooltipGxStr = CreateColor(0.8, 0.8, 0.8):WrapTextInColorCode(("Requires Graphics API set to %s."):format(target_gxApi_name))

		-- Target API not avail, check if we are on backup; no tooltip if we are
	elseif curAPI == editor_backup_gxApi then
		-- Not on target or backup; check if backup is available and show tooltip if so
	elseif (backup_gxApi_avail) then
		tooltipGxStr = CreateColor(0.8, 0.8, 0.8):WrapTextInColorCode(("Requires Graphics API set to %s."):format(backup_gxApi_name))

		-- Neither target nor backup API available, show warning tooltip
	else
		tooltipGxStr = CreateColor(0.8, 0.2, 0.2):WrapTextInColorCode(("Warning: Requires %s or %s, but neither are available. Please check with #tech-support in the Epsilon Discord."):format(target_gxApi_name, backup_gxApi_name))
	end
end

local function init()
	ns.Launcher.new(
		"Epsilon Editor",
		EpsilonOverlayUI_MinimapButton_OnClick,
		icon,
		{
			" ",
			"|cffFFD700Left-Click|r to open the Epsilon Editor",
			tooltipGxStr,
		}
	)
end
ns.Launcher.registerForInit(init)
