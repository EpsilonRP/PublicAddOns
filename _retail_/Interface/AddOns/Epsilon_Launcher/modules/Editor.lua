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

-------------------------------------------------------------------------------
-- Editor UI
-------------------------------------------------------------------------------

local editor_target_gxApi = "D3D11"
local function EpsilonOverlayUI_MinimapButton_OnClick(self)
	--if C_CVar.GetCVar("gxApi"):find("D3D11_LEGACY") then
	if C_CVar.GetCVar("gxApi") == editor_target_gxApi then
		C_Epsilon.ShowMenu()
	else
		if not graphicsAPIs then
			graphicsAPIs = { GetGraphicsAPIs() }
		end

		if target_gxApi_avail == nil then
			target_gxApi_avail = false -- fallback
			for k, v in ipairs(graphicsAPIs) do
				--if v:find("D3D11_LEGACY") then
				if v == editor_target_gxApi then
					target_gxApi_avail = true
					break
				end
			end
		end

		if not target_gxApi_avail then
			print("|cffFF0000Epsilon Editor Alert: Your settings are incompatible with the Epsilon Editor, and DirectX 11 is not available. If you are on Windows, please see the #tech-faq channel in Discord for links to install DirectX 11.")
		else
			print("|cffFF0000Epsilon Editor Alert: Your settings are incompatible with the Epsilon Editor. Please change your Graphics API in System Settings > Advanced to DirectX 11.")
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
