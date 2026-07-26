local ADDON_NAME = ...
---@class ns
local ns = select(2, ...)


local function isNotDefined(s)
	return s == nil or s == '';
end

function loadMasterTable()
	if not OPMasterTable then OPMasterTable = {} end
	if not OPMasterTable.Options then OPMasterTable.Options = {} end
	if isNotDefined(OPMasterTable.Options["debug"]) then OPMasterTable.Options["debug"] = false end
	if isNotDefined(OPMasterTable.Options["SliderStep"]) then OPMasterTable.Options["SliderStep"] = 0.01 end
	if isNotDefined(OPMasterTable.Options["locked"]) then OPMasterTable.Options["locked"] = false end
	if isNotDefined(OPMasterTable.Options["fadePanel"]) then OPMasterTable.Options["fadePanel"] = false end
	if isNotDefined(OPMasterTable.Options["autoShow"]) then OPMasterTable.Options["autoShow"] = false end
	if isNotDefined(OPMasterTable.Options["autoShowPopout"]) then OPMasterTable.Options["autoShowPopout"] = false end
	if isNotDefined(OPMasterTable.Options["wasPopoutShown"]) then OPMasterTable.Options["wasPopoutShown"] = false end
	if isNotDefined(OPMasterTable.Options["showMessages"]) then OPMasterTable.Options["showMessages"] = false end
	if isNotDefined(OPMasterTable.Options["showTooltips"]) then OPMasterTable.Options["showTooltips"] = true end
	if isNotDefined(OPMasterTable.Options["MovePlayer"]) then OPMasterTable.Options["MovePlayer"] = false end
	if isNotDefined(OPMasterTable.Options["useOverlayMethod"]) then OPMasterTable.Options["useOverlayMethod"] = false end
	if isNotDefined(OPMasterTable.Options["autoUpdateRot"]) then OPMasterTable.Options["autoUpdateRot"] = true end
	if isNotDefined(OPMasterTable.Options["autoUpdateTint"]) then OPMasterTable.Options["autoUpdateTint"] = true end

	if not OPMasterTable.ParamPresetKeys then OPMasterTable.ParamPresetKeys = { "Building Tile", "Fine Positioning" } end
	if not OPMasterTable.ParamPresetContent then
		OPMasterTable.ParamPresetContent = {
			["Building Tile"] = {
				["ObjectID"] = false,
				["Length"] = 4,
				["Width"] = 4,
				["Height"] = 0.25,
				["Scale"] = 1,
			},
			["Fine Positioning"] = {
				["ObjectID"] = false,
				["Length"] = 0.01,
				["Width"] = 0.01,
				["Height"] = 0.01,
				["Scale"] = 1,
			},
		}
	end

	if not OPMasterTable.RotPresetKeys then OPMasterTable.RotPresetKeys = { "Reset (0,0,0)" } end
	if not OPMasterTable.RotPresetContent then
		OPMasterTable.RotPresetContent = {
			["Reset (0,0,0)"] = {
				["RotX"] = 0,
				["RotY"] = 0,
				["RotZ"] = 0,
			},
		}
	end

	if not OPMasterTable.ColorPresetKeys then OPMasterTable.ColorPresetKeys = { "Reset (Remove Color)" } end
	if not OPMasterTable.ColorPresetContent then
		OPMasterTable.ColorPresetContent = {
			["Reset (Remove Color)"] = {
				r = 100,
				g = 100,
				b = 100,
				a = 0,
				s = 100,
				mode = 'tint'
			},
		}
	end



	---@class NS_Options
	ns.Options = {
		Options = OPMasterTable.Options,
		ParamPresetKeys = OPMasterTable.ParamPresetKeys,
		ParamPresetContent = OPMasterTable.ParamPresetContent,
		RotPresetKeys = OPMasterTable.RotPresetKeys,
		RotPresetContent = OPMasterTable.RotPresetContent,
		ColorPresetKeys = OPMasterTable.ColorPresetKeys,
		ColorPresetContent = OPMasterTable.ColorPresetContent,
	}
end

loadMasterTable()

local function onLoad(_, event, addon)
	if addon == ADDON_NAME then
		loadMasterTable()
		EpsilonLib.EventManager:Remove(onLoad, "ADDON_LOADED")
	end
end
EpsilonLib.EventManager:Register("ADDON_LOADED", onLoad)
