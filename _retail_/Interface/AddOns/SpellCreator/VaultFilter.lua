---@class ns
local ns = select(2, ...)

local Constants = ns.Constants
local ProfileFilter = ns.ProfileFilter

local shouldFilterFromPersonalVault = ProfileFilter.shouldFilterFromPersonalVault
local VAULT_TYPE = Constants.VAULT_TYPE

local isPersonalVault = true
local searchText = ""
local searchEnabled = false
---@type fun()
local updateRows

---@param spell VaultSpell
---@return boolean isFiltered true if should be filtered out, false if should still be shown
local function isFilteredBySearch(spell)
	if not searchEnabled then
		return false
	end

	local nameMatch = false
	if spell.fullName then
		nameMatch = spell.fullName:lower():find(searchText) ~= nil
	end

	local commIDMatch = false
	if spell.commID ~= nil then
		commIDMatch = tostring(spell.commID):lower():find(searchText) ~= nil
	end

	return not (nameMatch or commIDMatch)
end

---@param spell VaultSpell
---@return boolean
local function shouldFilter(spell)
	return (isPersonalVault and shouldFilterFromPersonalVault(spell)) or isFilteredBySearch(spell)
end

---@param text string
local function onSearchTextChanged(text)
	searchText = text:lower()
	searchEnabled = (#searchText > 1)
	updateRows()
end

local function onProfileFilterChanged()
	updateRows()
end

---@param vaultType VaultType
local function prepareFilter(vaultType)
	-- avoid complex operations during vault iteration
	isPersonalVault = (vaultType == VAULT_TYPE.PERSONAL)
end

---@param inject { updateRows: fun() }
local function init(inject)
	updateRows = inject.updateRows
end

---@class VaultFilter
ns.VaultFilter = {
	init = init,
	onProfileFilterChanged = onProfileFilterChanged,
	onSearchTextChanged = onSearchTextChanged,
	prepareFilter = prepareFilter,
	shouldFilter = shouldFilter,
}
