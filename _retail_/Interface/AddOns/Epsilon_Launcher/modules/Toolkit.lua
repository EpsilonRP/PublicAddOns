-------------------------------------------------------------------------------
-- Initialize Variables
-------------------------------------------------------------------------------
---@class ns
local ns = select(2, ...)

local ADDON_NAME = ...
local tooltip = ns.Utils.Tooltip

local _depAddOn = "PhaseToolkit"
local icon = ns.Launcher.CONSTANTS.assetsPath .. "EpsilonTrayIconPhaseToolkit"

-------------------------------------------------------------------------------
-- Register Icon
-------------------------------------------------------------------------------

local function init()

	local depAddOnLoaded = ns.Utils.isAddOnLoaded(_depAddOn)

	if depAddOnLoaded then

		local addonVersion, addonAuthor, addonName = GetAddOnMetadata(depAddOnLoaded, "Version"), GetAddOnMetadata(depAddOnLoaded, "Author"), GetAddOnMetadata(depAddOnLoaded, "Title")

		ns.Launcher.new(
			"Phase Toolkit",
			SlashCmdList["PTK"],
			icon,
			{
				" ",
				"|cffFFD700Left-Click|r to open the Phase Toolkit!",
				tooltip.createDoubleLine(" ", addonName.." v"..addonVersion, nil, nil, nil, 0.8, 0.8, 0.8),
				tooltip.createDoubleLine(" ", "by "..addonAuthor, nil, nil, nil, 0.8, 0.8, 0.8),
			}
		)--:RegisterForClicks("LeftButtonUp", "RightButtonUp", "MiddleButtonUp")
	end
end

ns.Launcher.registerForInit(init)
