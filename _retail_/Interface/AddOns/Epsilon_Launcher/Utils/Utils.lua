---@class ns
local ns = select(2, ...)

---@param name string
---@return string
local function isAddOnLoaded(name)
	if IsAddOnLoaded(name) then return name
	elseif IsAddOnLoaded(name.."-dev") then return name.."-dev" end
end

---@field Tooltip Utils_Tooltip
ns.Utils = {}
ns.Utils.isAddOnLoaded = isAddOnLoaded
