-------------------------------------------------------------------------------
-- Initialize Variables
-------------------------------------------------------------------------------
---@class ns
local ns = select(2, ...)

local ADDON_NAME = ...
local tooltip = ns.Utils.Tooltip

local _depAddOn = "Gobviewer"
local icon = ns.Launcher.CONSTANTS.assetsPath .. "EpsilonTrayIconViewer"

-------------------------------------------------------------------------------
-- Register Icon
-------------------------------------------------------------------------------

local function init()

	local depAddOnLoaded = ns.Utils.isAddOnLoaded(_depAddOn)

	if depAddOnLoaded then

		local addonVersion, addonAuthor, addonName = GetAddOnMetadata(depAddOnLoaded, "Version"), GetAddOnMetadata(depAddOnLoaded, "Author"), GetAddOnMetadata(depAddOnLoaded, "Title")

		ns.Launcher.new(
			"Object Viewer",
			SlashCmdList["GOB"],
			icon,
			{
				" ",
				"|cffFFD700Left-Click|r to open the Object Viewer!",
				tooltip.createDoubleLine(" ", addonName.." v"..addonVersion, nil, nil, nil, 0.8, 0.8, 0.8),
				tooltip.createDoubleLine(" ", "by "..addonAuthor, nil, nil, nil, 0.8, 0.8, 0.8),
			}
		)--:RegisterForClicks("LeftButtonUp", "RightButtonUp", "MiddleButtonUp")
	end
end

ns.Launcher.registerForInit(init)