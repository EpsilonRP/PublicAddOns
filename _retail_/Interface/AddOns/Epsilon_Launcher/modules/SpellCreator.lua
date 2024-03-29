-------------------------------------------------------------------------------
-- Initialize Variables
-------------------------------------------------------------------------------
---@class ns
local ns = select(2, ...)

local ADDON_NAME = ...

local _depAddOn = "SpellCreator"

-------------------------------------------------------------------------------
-- Register Icon
-------------------------------------------------------------------------------

local function init()
		
	local depLoaded = IsAddOnLoaded(_depAddOn) or IsAddOnLoaded(_depAddOn.."-dev")

	if depLoaded and SpellCreatorMinimapButton then
		ns.Launcher.new(SpellCreatorMinimapButton)
	end
end

ns.Launcher.registerForInit(init)
