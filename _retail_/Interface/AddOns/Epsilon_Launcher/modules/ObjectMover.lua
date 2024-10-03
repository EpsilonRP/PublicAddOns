-------------------------------------------------------------------------------
-- Initialize Variables
-------------------------------------------------------------------------------
---@class ns
local ns = select(2, ...)

local ADDON_NAME = ...
local tooltip = ns.Utils.Tooltip

local _depAddOn = "ObjectMover"
local icon = ns.Launcher.CONSTANTS.assetsPath .. "EpsilonTrayIconObjectMover"

-------------------------------------------------------------------------------
-- Register Icon
-------------------------------------------------------------------------------

local function init()
	local depAddOnLoaded = ns.Utils.isAddOnLoaded(_depAddOn)

	if depAddOnLoaded then
		local addonVersion, addonAuthor, addonName = GetAddOnMetadata(depAddOnLoaded, "Version"), GetAddOnMetadata(depAddOnLoaded, "Author"), GetAddOnMetadata(depAddOnLoaded, "Title")

		local onClick = function(self, button)
			if button == "RightButton" then
				if not OPNewOptionsFrame:IsShown() then OPNewOptionsFrame:Show() else OPNewOptionsFrame:Hide() end
			elseif button == "LeftButton" then
				SlashCmdList.OM_SHOWCLOSE()
			elseif button == "MiddleButton" then
				if OPPanelPopout:IsShown() then
					OPPanelPopout:Hide()
				else
					OPPanelPopout:Show()
				end
			end
		end

		ns.Launcher.new(
			"Object Mover",
			onClick,
			icon,
			{
				" ",
				"/om - Toggle UI",
				" ",
				"|cffFFD700Left-Click|r to toggle the main UI!",
				"|cffFFD700Middle-Click|r to toggle the Selected Object panel!",
				"|cffFFD700Right-Click|r for Options, Changelog, and the Help Manual!",
				" ",
				"Mouse over most UI Elements to see tooltips for help! (Like this one!)",
				tooltip.createDoubleLine(" ", addonName .. " v" .. addonVersion, nil, nil, nil, 0.8, 0.8, 0.8),
				tooltip.createDoubleLine(" ", "by " .. addonAuthor, nil, nil, nil, 0.8, 0.8, 0.8),
			}
		):RegisterForClicks("LeftButtonUp", "RightButtonUp", "MiddleButtonUp")
	end
end

ns.Launcher.registerForInit(init)
