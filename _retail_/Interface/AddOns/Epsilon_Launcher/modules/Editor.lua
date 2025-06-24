-------------------------------------------------------------------------------
-- Initialize Variables
-------------------------------------------------------------------------------
---@class ns
local ns = select(2, ...)

local ADDON_NAME = ...

local tooltip = ns.Utils.Tooltip

local icon = ns.Launcher.CONSTANTS.assetsPath .. "EpsilonTrayIconEditor"

local graphicsAPIs
local target_gxApi_avail
local backup_gxApi_avail

-------------------------------------------------------------------------------
-- Editor UI
-------------------------------------------------------------------------------

local editor_target_gxApi = "D3D11"
local editor_backup_gxAPI = "D3D11_LEGACY"
local target_gxApi_name = _G["GXAPI_" .. editor_target_gxApi]
local function EpsilonOverlayUI_MinimapButton_OnClick(self)
	local curAPI = C_CVar.GetCVar("gxApi")
	if curAPI == editor_target_gxApi then
		C_Epsilon.ShowMenu()
	else
		if not graphicsAPIs then
			graphicsAPIs = { GetGraphicsAPIs() }
		end

		if target_gxApi_avail == nil then
			target_gxApi_avail = false -- fallback
			for k, v in ipairs(graphicsAPIs) do
				if v == editor_target_gxApi then
					target_gxApi_avail = true
				elseif v == editor_backup_gxAPI then
					backup_gxApi_avail = true
				end
			end
		end

		if not target_gxApi_avail then
			-- Target not available, and we are using backup, allow menu without warnings.
			if curAPI == editor_backup_gxAPI then
				C_Epsilon.ShowMenu()
				return
			end
			print(
				"|cffFF0000Epsilon Editor Alert: Your settings are incompatible with the Epsilon Editor, and " ..
				target_gxApi_name .. " is not available. If you are on Windows, please see the #tech-faq channel in Discord for links to install DirectX 11.")
		else
			print("|cffFF0000Epsilon Editor Alert: Your settings are incompatible with the Epsilon Editor. Please change your Graphics API in System Settings > Advanced to " .. target_gxApi_name .. ".")
			OptionsFrame_OpenToCategory(VideoOptionsFrame, "Advanced")
		end
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
			CreateColor(0.8, 0.8, 0.8):WrapTextInColorCode("If it doesn't open, please change your Graphics API in ESC > System > Advanced Settings to DirectX 11 Legacy."),
		}
	)
end

ns.Launcher.registerForInit(init)
