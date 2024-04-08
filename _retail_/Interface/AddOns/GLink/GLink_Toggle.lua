--GLink toggle hyperlink functionality
addonName, GLink = ...;

GLink_Settings.hiddenLinks = GLink_Settings.hiddenLinks or {}

--Toggle glink hyperlinks
function GLink:ToggleHyperlink(IDType, hyperlink, hidden)

	if hidden ~= nil and GLink_Settings.hiddenLinks[IDType][hyperlink][1] then

		hidden = tonumber(hidden);
		--print("HIDDEN",hidden)
		GLink_Settings.hiddenLinks[IDType][hyperlink][1] = tonumber(hidden);

		if hidden == 0 then
			print(GLink_Settings.colour .. "[GLink]|r displaying hyperlink: " .. GLink_Settings.colour .. hyperlink .. "|r")
			
		else
			print(GLink_Settings.colour .. "[GLink]|r hiding hyperlink: " .. GLink_Settings.colour .. hyperlink .. "|r")
		end
	else
		--First get index of command
		if GLink_Settings.hiddenLinks[IDType][hyperlink][1] then
			GLink_Settings.hiddenLinks[IDType][hyperlink][1] = 1;
			print(GLink_Settings.colour.."[GLink]|r hiding hyperlink: " .. GLink_Settings.colour .. hyperlink .. "|r")
		end
	end
end

function GLink:ToggleOption()

	print(GLink_Settings.colour .. "[GLink]|r Toggle Hyperlink Options")
	for k,v in pairs(GLink_Settings.hiddenLinks) do
		for k1,v1 in pairs(v) do
			local hidden = v1[1];
			--print("IS IT HIDDEN", hidden)
			if hidden == 0 then
				hidden = "|cff00ff00True|r - " .. GLink_Settings.colour .. "|HGLink_Toggle:0"..k.."0:"..k1..":1|h[Hide]|h|r";
			else
				hidden = "|cffff0000False|r - " .. GLink_Settings.colour .. "|HGLink_Toggle:0"..k.."0:"..k1..":0|h[Show]|h|r";
			end

			print(k,GLink_Settings.colour .. "|HGLink_Toggle_Link:1|h" .. k1 .. "|h|r", "displayed:",hidden)
			
		end
	end
	print("End of Hyperlink list")
end


--FIRST TIME LOAD
local GLinkToggle_Startup = CreateFrame("FRAME");
GLinkToggle_Startup:RegisterEvent("ADDON_LOADED");
GLinkToggle_Startup:SetScript("OnEvent", function(self, event, addon)
	if addon == "GLink" and GLink_Settings.firstLoad == nil then
		print(GLink_Settings.colour.."[GLink]|r preparing toggle options.")
		if not GLink_Settings.hiddenLinks then
			GLink_Settings.hiddenLinks = GLink_Settings.hiddenLinks or {};
		end
		for k,v in pairs(GLink.hyperlinks) do
			GLink_Settings.hiddenLinks[k] = {};
			for k1,v1 in pairs(v["RETURNS"]) do
				GLink_Settings.hiddenLinks[k][v1] = {}
				tinsert(GLink_Settings.hiddenLinks[k][v1], 0)
			end
		end
		GLink_Settings.firstLoad = false;
	end
end) 