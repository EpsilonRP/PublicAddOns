local addonName, ns = ...
local baseAddonName = addonName:gsub("%-dev", "")

local EpsilonMap = LibStub("AceAddon-3.0"):NewAddon("Epsilon_Map", "AceConsole-3.0")

ns.utils = {}
EpsilonMap._Utils = ns.utils
local utils = ns.utils

utils.GetAddonAssetsPath = function(path)
	return ("Interface\\Addons\\%s\\Assets\\%s"):format(addonName, path or "")
end

utils.ApplyTexture = function(texObj, path)
	texObj:SetTexture(utils.GetTexturePath(path))
end

utils.ApplyNormalTexture = function(object, path)
	object:GetNormalTexture():SetTexture(utils.GetAddonAssetsPath(path))
end

local function convertDevFilePath(filePath)
	if not filePath then return end
	filePath = filePath:gsub("%-dev", "")
	filePath = filePath:gsub(baseAddonName, addonName)
	return filePath
end

function utils.AdjustDevTex(...)
	local textures = { ... }
	for i = 1, #textures do
		local tex = textures[i]

		local file = tex:GetTextureFilePath()
		if type(file) == "string" then
			file = convertDevFilePath(file)
			--print("Adjusting texture path from:", tex:GetTextureFilePath(), "to:", file)
			tex:SetTexture(file)
		end
	end
end

utils.AdjustAllDevTex = function(frame)
	EpsilonLib.Utils.Misc.AdjustAllDevTex(addonName, frame)
end

local lastTime;
local playerGUID;
utils.GenerateGUID = function()
	if not playerGUID then
		playerGUID = string.gsub(select(3, strsplit("-", UnitGUID("player"))), "^0+", "")
	end

	local time = time() - 1615000000;
	if lastTime == time then
		time = time + 1;
	end
	lastTime = time;

	local guid = playerGUID .. "_" .. string.format("%X", time);

	return guid;
end


local tooltipTimer = C_Timer.NewTimer(0, function() end)
function utils.AddTooltipToFrame(frame, title, text)
	if title then frame.tooltipTitle = title end
	if text then frame.tooltipText = text end
	frame:HookScript("OnEnter", function(self)
		if not self.tooltipTitle and not self.tooltipText then return end
		tooltipTimer:Cancel()
		tooltipTimer = C_Timer.NewTimer(0.33, function()
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -16, -4)
			if self.tooltipTitle then
				GameTooltip_SetTitle(GameTooltip, self.tooltipTitle, NORMAL_FONT_COLOR)
			end
			if type(self.tooltipText) == "table" then
				for k, v in ipairs(self.tooltipText) do GameTooltip_AddHighlightLine(GameTooltip, v) end
			elseif self.tooltipText then
				GameTooltip_AddHighlightLine(GameTooltip, self.tooltipText)
			end
			GameTooltip:Show()
		end)
	end)
	frame:HookScript("OnLeave", function()
		tooltipTimer:Cancel()
		GameTooltip_Hide()
	end)
end
