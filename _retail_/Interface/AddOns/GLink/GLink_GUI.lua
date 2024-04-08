addonName, GLink = ...;

--Linkifier_Hover

local orig1, orig2 = {}, {}
local GameTooltip = GameTooltip

local linktypes = {
    item         = true,
    instancelock = true,
    quest        = true,
    spell        = true,
}		

--
-- 1 - Two Handed Sword Sheath
-- 2 - Two Handed Staff/Polearm Sheath
-- 3 - One Handed Hip Sheath
-- 4 - Shield Sheath
-- 5 - Offhand Sheath
-- 6 - Invisible Sheath
-- 7 - Ranged Two Handed Sword Sheath
-- 8 - Ranged Two Handed Staff/Polearm Sheath
-- 9 - Ranged One Handed Hip Sheath
-- 10 - Ranged Shield Sheath
-- 11 - Ranged Offhand Sheath
-- 12 - Ranged Invisible Sheath
--
local sheathes = {
    [1] = "2H Sword",
    [2] = "2H Staff/Polearm",
    [3] = "1H Hip",
    [4] = "Shield",
    [5] = "Offhand",
    [6] = "Invisible Sheath",
    [7] = "Ranged 2H Sword",
    [8] = "Ranged 2h Staff/Polearm",
    [9] = "Ranged 1H Hip",
    [10] = "Ranged Shield",
    [11] = "Ranged Offhand",
    [12] = "Ranged Invisible",
    [13] = "Invisible",
}

function OnHyperlinkEnter(frame, link, linkData, ...)


    local ID, IDType, hyperlink = GLink:GetCommand(link, linkData);

    local linktype = link:match('^([^:]+)')

    if link:match("ezc:") or link:match("PGUID:") or link:match("acc:") then
    --easycopy compatibility lol
    return false
    
    end
    if link:match("player:") or link:match("channel") or link:match("achieve") then
        return false;
    end
    
    local commandIndex;

    --get tooltip text

    if GLink_debugging then
        print("|cff00ccff[DEBUG]|r Hyperlink Hover",IDType, ID, hyperlink)
    end
    --Don't display item tooltip on hover if settings prohibit it
    if link:match("item:%d*:%d*:%d*") and GLink_Settings.clickableItemLinks == false then
        return false; 
    end

    if ID and IDType then
        for k,v in pairs(GLink.hyperlinks[IDType]["RETURNS"]) do
            if v == hyperlink then
                hyperlink = v;
                commandIndex = k;
            end
        end
    end


    
    if IDType and ID and hyperlink and commandIndex then
        if IDType == "gameobject_GPS" then
            local output;
            local x, y, z, ori, map = GLink:HandleMapCoordinates(":"..ID, IDType);
            if hyperlink == "[Teleport]" then
                output = string.format("Teleport to map %s%i|r (X: %s%#.3f|r, Y: %s%#.3f|r, Z: %s%#.3f|r)", GLink_Settings.colour, map, GLink_Settings.colour, x, GLink_Settings.colour, y, GLink_Settings.colour, z);
            elseif hyperlink == "[Copy Coordinates]" then
                output = "Copy Map Coordinates";
            end
            local tooltipMessage = output;
            ShowToolTip(tooltipMessage);

        elseif link:match("item:") or link:match("spell:") then
            --Check weapon sheathe

            GameTooltip:SetOwner(ChatFrame1, 'ANCHOR_CURSOR', 0, 20)
            GameTooltip:SetHyperlink(link)

            ID = ID:match("(%d*)") or ID;

            if ID then
                local sheatheID = math.floor(tonumber(ID)/1000000);

                if sheatheID > 6 then
                    sheatheID = sheatheID - 6;
                end
                --DEBUGGING
                if GLink_debugging == true then
                    print("|cff00ccff[DEBUG]|r tooltip:",sheatheID, sheathes[sheatheID], ID, IDType, type(ID));
                end

                if sheatheID > 0 and sheatheID <= #sheathes and link:match("item") then
                    GameTooltip:AddLine("|cff00CCFFSheathe:|r |cffADFFFF" .. sheathes[sheatheID] .. "|r");
                end
            end
            local tooltipMessage = GLink.hyperlinks[IDType]["TOOLTIP_TEXT"][commandIndex]:gsub("%#"..IDType,GLink_Settings.colour .. ID .. "|r");
            GameTooltip:AddLine(tooltipMessage,1,1,1,1,1,1)

            GameTooltip:Show()
        else
            if GLink_debugging == true then
                print("|cff00ccff[DEBUG]|r tooltip:", commandIndex, ID, IDType, link, GLink.hyperlinks[IDType]["TOOLTIP_TEXT"][commandIndex]);
            end
            local tooltipMessage = GLink.hyperlinks[IDType]["TOOLTIP_TEXT"][commandIndex]:gsub("%#"..IDType,GLink_Settings.colour .. ID .. "|r");

            ShowToolTip(tooltipMessage);
		end

    end
    

    if (orig1[frame]) then 
        return orig1[frame](frame, link, ...) 
    end
    
    end

local function OnHyperlinkClick(frame, ...)
    GameTooltip:Hide()
    if(orig2[frame]) then
        return orig2[frame](frame, ...)
    end
end

local function OnHyperlinkLeave(frame, ...)
    GameTooltip:Hide()
    if (orig2[frame]) then 
        return orig2[frame](frame, ...) 
    end
end

local function EnableItemLinkTooltip()
    for _, v in pairs(CHAT_FRAMES) do
        local chat = _G[v]
        if (chat and not chat.URLCopy) then
            orig1[chat] = chat:GetScript('OnHyperlinkEnter')
            chat:SetScript('OnHyperlinkEnter', OnHyperlinkEnter)

            orig2[chat] = chat:GetScript('OnHyperlinkLeave')
            chat:SetScript('OnHyperlinkLeave', OnHyperlinkLeave)
            chat.URLCopy = true
        end
    end
end
hooksecurefunc('FCF_OpenTemporaryWindow', EnableItemLinkTooltip)
EnableItemLinkTooltip()

function ShowToolTip(tooltipMessage)
    GameTooltip:SetOwner(ChatFrame1, 'ANCHOR_CURSOR', 0, 20)
    GameTooltip:ClearLines();
    if tooltipMessage then
        GameTooltip:AddLine(tooltipMessage,1,1,1,1,1,1)
    end
    GameTooltip:Show()
end