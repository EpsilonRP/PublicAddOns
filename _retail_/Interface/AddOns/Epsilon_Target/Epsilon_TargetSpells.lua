local function getAuras(targetType)


    local numBuffs = 0;
    local numDebuffs = 0;
    
    for i = 1,40 do
        
        local buffName = UnitBuff(targetType, i);
        local debuffName = UnitDebuff(targetType,i);
    
        if buffName ~= nil then
            numBuffs = i;
        end
    
        if debuffName ~= nil then
            numDebuffs = i;
        end
    end

    return numBuffs, numDebuffs;
end
    
local function unauraClick(buffs,debuffs,targetType)

    --print("auras",buffs,debuffs)
    local buffButtonName = "";
    local debuffButtonName = "";
    if targetType == "target" then
        buffButtonName = "TargetFrameBuff";
        debuffButtonName = "TargetFrameDebuff";
    else
        buffButtonName = "BuffButton";
        debuffButtonName = "DebuffButton";
    end



    for i = 1,buffs do
        --print(i)
        --_G[buffButtonName..i]:RegisterForClicks("LeftButtonUp")
        _G[buffButtonName..i]:RegisterForClicks("RightButtonUp", "LeftButtonUp")
        _G[buffButtonName..i]:SetScript("OnClick", function(self, event)
            --print("BUFFCLICK", event)
            local name,_,_,_,_,_,_,_,_,spellId = UnitAura(targetType:upper(), i);
            --print("buff click",name,spellId,IsShiftKeyDown())
            if IsShiftKeyDown() == true then
                --SendChatMessage("|cff71d5ff|Hspell:"..spellId..":0|h["..name.."]|h|r")
                print("")
                ChatFrame1EditBox:SetFocus()
                ChatFrame1EditBox:SetText("|cff71d5ff|Hspell:"..spellId..":0|h["..name.."]|h|r")
            else
                if targetType == "target" then
                    --print("buff",name,spellId)
                    if IsControlKeyDown() == true then
                        SendChatMessage(".unaura "..spellId, "GUILD");
                    else
                        SendChatMessage(".aura "..spellId, "GUILD");
                    end
                else
                SendChatMessage(".unaura "..spellId, "GUILD");
                end
            end
        end)
    end

    for i = 1,debuffs do
    --_G[debuffButtonName..i]:RegisterForClicks("LeftButtonUp")
    _G[debuffButtonName..i]:RegisterForClicks("RightButtonUp", "LeftButtonUp")
    _G[debuffButtonName..i]:SetScript("OnClick", function(self, event)
        print("BUFFCLICK")
        local name,_,_,_,_,_,_,_,_,spellId = UnitAura(targetType:upper(), i, "HARMFUL");
        --print("buff click",name,spellId,IsShiftKeyDown())
        if IsShiftKeyDown() == true then
            --SendChatMessage("|cff71d5ff|Hspell:"..spellId..":0|h["..name.."]|h|r")
            ChatFrame1EditBox:SetFocus()
            ChatFrame1EditBox:SetText("|cff71d5ff|Hspell:"..spellId..":0|h["..name.."]|h|r")
        else
            if targetType == "target" then
                --print("debuff",name,spellId)
                if IsControlKeyDown() == true then
                    SendChatMessage(".unaura "..spellId, "GUILD");
                else
                    SendChatMessage(".aura "..spellId, "GUILD");
                end

            else
            SendChatMessage(".unaura "..spellId, "GUILD");
            end
        end
    end)
end
end

local unaura = CreateFrame("Frame");
unaura:RegisterEvent("UNIT_AURA")
unaura:RegisterEvent("PLAYER_ENTERING_WORLD")
unaura:RegisterEvent("PLAYER_TARGET_CHANGED")
unaura:SetScript("OnEvent", function(self, event, unitID)

    if event == "PLAYER_TARGET_CHANGED" then

        numBuffs,numDebuffs = getAuras("target")
        unauraClick(numBuffs,numDebuffs, "target")
    else

        numBuffs,numDebuffs = getAuras("player")
        unauraClick(numBuffs,numDebuffs, "player")
    end

end);