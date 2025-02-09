--d
local phases, EPSILON_PHASES = ...
local EpsiLib = EpsilonLib;

do return end -- not reliable atm

local mallPhases = EpsiLib.ContainerTemplate.Headers.createHeader("Mall Phases", EpsilonPhases);

EPSILON_PHASES.PhaseMalls = {}

local malls = malls or {}

PhaseMalls = EPSILON_PHASES.PhaseMalls;

function PhaseMalls:addMall(phaseID, mallType, mallOwner)

    malls[#malls+1] = { ["phaseID"] = phaseID, ["mallType"] = mallType, ["mallOwner"] = mallOwner }

end

local function buildMallList()

    print("Building list", #malls);
    for k,v in pairs(malls) do
        print(k,v)
    end

end

local left = CreateFrame("FRAME", "$parentLeftInset", mallPhases, "EpsiLibInsetFrameTemplate")
left:SetPoint("TOPLEFT")
left:SetWidth(10);
left:SetPoint("BOTTOM")
left:Hide()

local function CreateLabel(text, parent, relativeTo, offsetX, offsetY)
	local label = parent:CreateFontString(nil, nil, "GameFontNormalSmall")
    if (parent == relativeTo) then
        label:SetPoint("TOP", relativeTo, "TOP", 0, -10);
    else
        label:SetPoint("TOP", relativeTo, "BOTTOM", 0, -16);
    end
	label:SetText(text);
	return label;
end

local values = {};
function UpdateLabels(data)
	for k,v in pairs(values) do
		local text;
		if not data then 
			text = "None Selected" 
		else
			text = data[k]
		end
		v:SetText(text);
	end
end


local lastAnchor = left;
for key,value in pairs(malls) do
	local label = CreateLabel(value, left, lastAnchor);
	label:SetPoint("CENTER", left, "CENTER", (left:GetWidth() / 2) - label:GetWidth() - 5, 0)
	--label:SetPoint("LEFT", left, "LEFT", 5, 0);
	local fs = left:CreateFontString("$parent"..value.uiName, nil, "GameFontHighlightSmall");

	fs:SetPoint("TOP", label, "BOTTOM", 0, -10);
	values[key] = fs;
	lastAnchor = fs;
end

local right = CreateFrame("FRAME", "$parentRightInset", mallPhases, "EpsiLibInsetFrameTemplate")
right:SetPoint("TOP", mallPhases, 0, -25)
right:SetPoint("LEFT", left, "RIGHT")
right:SetPoint("RIGHT")
right:SetPoint("BOTTOM", mallPhases, 0, 25)


local updated;

local selected = {};
local scroll = CreateFrame("SCROLLFRAME", "$parentScrollFrame", right, "EpsilonHybridScrollFrameTemplate")

HybridScrollFrame_CreateButtons(scroll, "EpsilonThreeButtonTemplate")
scroll:SetScript("OnUpdate", function(self)
	local offset = HybridScrollFrame_GetOffset(self)
	local buttons = self.buttons
	for i = 1, #buttons do
		local button = buttons[i]
		local mall = malls[offset+i];
        
        -- for k,v in pairs(malls) do
        --     print(k,v, v.type, v.phaseid);
        --     for k1,v1 in pairs(v) do
        --         print(k,k1,v1)
        --     end
        -- end

		if mall then
            --print("mallex", mall.mallOwner)
			if mall == self.selected then button:LockHighlight() else button:UnlockHighlight() end
			if updated ~= self.selected then self.updateInfo() updated = self.selected end
			button.entry = mall
			button.left:SetText(mall["mallOwner"])
			button.middle:SetText(mall["mallType"])
			button.right:SetText(mall["phaseID"])
            --print("MAKEBUTTON", mall.owner, mall.type,mall.phaseid)
			button:Show()
		else
			button:Hide()
		end
	end
	HybridScrollFrame_Update(self, 20 * #malls, 20)
end)
for _,button in pairs(scroll.buttons) do
	button:SetScript("OnClick", function(self)
		for k,v in pairs(malls) do
			if v.id == button.entry.id then
				UpdateLabels(v);
				selected.id = button.entry.id;
				selected.name = button.entry.name;
				selected.description = button.entry.description;
				selected.information = v.information;
			end
		end
	end);
end

local header1 = CreateFrame("BUTTON", "$parentHeader1", right, "WhoFrameColumnHeaderTemplate")
header1:SetPoint("BOTTOMLEFT", right, "TOPLEFT")
header1:SetPoint("RIGHT", scroll.buttons[1].left)
header1:SetText("Mall")
header1.Middle:SetWidth(header1:GetWidth() - 9)



local header2 = CreateFrame("BUTTON", "$parentHeader2", right, "WhoFrameColumnHeaderTemplate")
header2:SetPoint("LEFT", header1, "RIGHT", -2, 0)
header2:SetPoint("RIGHT", scroll.buttons[1].middle, -2, 0)
header2:SetText("Description")
header2.Middle:SetWidth(header2:GetWidth() - 9)

local header3 = CreateFrame("BUTTON", "$parentHeader3", right, "WhoFrameColumnHeaderTemplate")
header3:SetPoint("LEFT", header2, "RIGHT", -2, 0)
header3:SetPoint("RIGHT", scroll.buttons[1].right, -2, 0)
header3:SetText("Phase ID")
header3.Middle:SetWidth(header3:GetWidth() - 9)

local refresh = CreateFrame("BUTTON", "$parentMallRefresh", right, "UIPanelButtonTemplate")
refresh:SetPoint("LEFT", header3, "RIGHT", -35, 0)
--refresh:SetPoint("RIGHT", scroll.buttons[1].right, -2, 0)
refresh:SetText("Refresh")
refresh:SetWidth(mallPhases:GetWidth() * 0.15)
MagicButton_OnLoad(refresh)

refresh:SetScript("OnClick", function()

    print("Rssss")
    buildMallList();

end)



PhaseMalls:addMall(26000, "Hub", "Builder's Haven")