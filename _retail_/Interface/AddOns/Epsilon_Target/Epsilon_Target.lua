--
--
--
local EpsiLib_Server = EpsilonLib.Server
local server = EpsiLib_Server.server

-- local function getAuras(targetType)


--     local numBuffs = 0;
--     local numDebuffs = 0;

--     for i = 1,40 do

--         local buffName = UnitBuff(targetType, i);
--         local debuffName = UnitDebuff(targetType,i);

--         if buffName ~= nil then
--             numBuffs = i;
--         end

--         if debuffName ~= nil then
--             numDebuffs = i;
--         end

--     end
--         return numBuffs, numDebuffs;
-- end

local targetMorph = CreateFrame("Frame", "TargetFrameDisplayInfo", TargetFrame);
targetMorph:SetPoint("TOP", TargetFrame, "TOP", -50, 8)
targetMorph:SetSize(150, 24)
targetMorph:RegisterEvent("PLAYER_TARGET_CHANGED")
targetMorph:RegisterEvent("UNIT_AURA")
targetMorph:SetScript("OnEvent", function(self, event, unitID)
	if event == "PLAYER_TARGET_CHANGED" then
		server.send("P_DSPLY", "CLIENT_READY")
		--numBuffs,numDebuffs = getAuras("target")
	end
	-- if event == "UNIT_AURA" then
	--     numBuffs,numDebuffs = getAuras("target")
	-- end
	-- if numBuffs > 0 then
	--     rows = math.floor(numBuffs / 5);
	--     if numBuffs % 5 > 0 then
	--         rows = rows + 1;
	--     end
	--     --targetMorph:SetPoint("CENTER", TargetFrame, 0, -30-(rows*25));
	-- end
	-- if numBuffs == 0 then
	--     --targetMorph:SetPoint("CENTER", TargetFrame, 0, -30);
	-- end

	self:Show()
end);

local targetMorphtext = targetMorph:CreateFontString("TargetFrameDisplayInfoText", nil, "GameFontHighlightSmall");
--targetMorphtext:SetText("Display: 49")
targetMorphtext:SetPoint("CENTER", targetMorph, 0, 0)

server.receive("DSPLY", function(message, channel, sender)
	--print(message,channel.sender)
	local records = { string.split(EpsilonLib.record, message) }
	for _, record in pairs(records) do
		local displayid = string.split(EpsilonLib.field, record)
		if displayid ~= "" then
			targetMorphtext:SetText("Display: " .. tostring(displayid));
			--print(targetMorphtext:GetText())
		end
	end
end)
