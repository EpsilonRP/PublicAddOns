-------------------------------------------------------------------------------
-- Initialize Variables
-------------------------------------------------------------------------------
---@class ns
local ns = select(2, ...)

local ADDON_NAME = ...

local tooltip = ns.Utils.Tooltip

local icon = ns.Launcher.CONSTANTS.assetsPath .. "EpsilonTrayIconEditor"

local graphicsAPIs
local directX11Avail

-------------------------------------------------------------------------------
-- Editor UI
-------------------------------------------------------------------------------

local function EpsilonOverlayUI_MinimapButton_OnClick(self)
	if C_CVar.GetCVar("gxApi"):find("D3D11_LEGACY") then
		C_Epsilon.ShowMenu()
	else
		if not graphicsAPIs then
			graphicsAPIs = { GetGraphicsAPIs() }
		end

		if directX11Avail == nil then
			for k, v in pairs(graphicsAPIs) do
				if v:find("D3D11_LEGACY") then
					directX11Avail = true; return
				end
			end
			directX11Avail = false -- fallback
		end

		if not directX11Avail then
			print("|cffFF0000Epsilon Editor Alert: Your settings are incompatible with the Epsilon Editor, and DirectX 11 is not available. If you are on Windows, please see the #tech-faq channel in Discord for links to install DirectX 11.")
		else
			print("|cffFF0000Epsilon Editor Alert: Your settings are incompatible with the Epsilon Editor. Please change your Graphics API in System Settings > Advanced to DirectX 11 (Legacy).")
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
