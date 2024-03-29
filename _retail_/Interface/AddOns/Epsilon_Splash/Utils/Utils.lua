---@class ns
local ns = select(2, ...)

local LibDBIcon

local function getLibDBIcon()
	if LibDBIcon then return end -- already found it
	if LibStub then
		LibDBIcon = LibStub("LibDBIcon-1.0")
	end
end
getLibDBIcon()

---------------------------------
-- General Util Functions
---------------------------------

---@param name string
---@return string
local function isAddOnLoaded(name)
	if IsAddOnLoaded(name) then return name
	elseif IsAddOnLoaded(name.."-dev") then return name.."-dev" end
end

local SendChatMessage = SendChatMessage
local function cmd(text)
    SendChatMessage("."..text, "GUILD");
end

local mmIcon
local function clickIconFromLauncherTray(name)
	getLibDBIcon()
	if not mmIcon then mmIcon = LibDBIcon:GetMinimapButton("Epsilon_Launcher") end
	if not mmIcon then mmIcon = LibDBIcon:GetMinimapButton("Epsilon_Launcher-dev") end
	if not mmIcon then return end
	local icon = mmIcon._Icons[name]
	if icon then icon:Click() end
end

---------------------------------
-- Class Table
---------------------------------

---@class Utils
---@field Tooltip Utils_Tooltip
ns.Utils = {}

ns.Utils.isAddOnLoaded = isAddOnLoaded
ns.Utils.cmd = cmd
ns.Utils.clickIconFromLauncherTray = clickIconFromLauncherTray
