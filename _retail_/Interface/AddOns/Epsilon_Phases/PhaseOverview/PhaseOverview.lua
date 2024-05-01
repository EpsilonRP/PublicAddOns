--[[
	Module: Phase Overview
	Author: Gardener

]]

--Epsilon Phases Namespace
local phases, EPSILON_PHASES = ...

--EpsilonLib dependency.
local EpsiLib = EpsilonLib;

local main = EpsiLib.Container;
local container = EpsiLib.ContainerTemplate.Headers.createHeader("Phase Overview", EpsilonPhases);

local phases = {}
local init;

local server = EpsiLib.Server.server;
local messages = EpsiLib.Server.messages;


local function checkPhases(id)

	local phaseExists = false;

	for k,v in pairs(phases) do
		--print("|cffff0000",v.id, v.name)
		if tonumber(id) == v.id then
			phaseExists = true;
		end

	end
	return phaseExists;

end

local function addPhaseToList(phase)

	print("addPhaseToList")
	if checkPhases(phase[1]) == true then
		--phase already exists
	else
		--print(phase[1], phase[2])
		if phase[1] == nil then
			--phase is nil
		else
			table.insert(phases, {
				id = tonumber(phase[1]),
				name = phase[3],
				description = phase[7],
				icon = "|h|TINTERFACE\\ICONS\\ability_ambush:25:25|t|h|r",
				comment = phase[6],
				region = phase[8],
			});
		end
	end
end

local function UpdatePhaseList()
	init = true;
	messages.send("EPSILON_G_PHASES", "CLIENT_READY");
	server.send("G_PHASES", "CLIENT_READY")
end

server.receive("PHASE", function(message, channel, sender)
	--print(message,channel.sender)

	local records = {string.split(EpsiLib.record, message)}
	for _, record in pairs(records) do
		local id, name, description, icon, information, owner = string.split(EpsiLib.field, record)
		--print("PHASE",id, owner, name, comment, description)
		if id and name and description then

		table.insert(phases, {
			id = id,
			owner = owner,
			name = name,
			icon = "|h|TINTERFACE\\ICONS\\"..icon..":30:30|t|h|r",
			comment = comment,
			description = description,
			information = information,
		});
		if Epsilon_debugging == true then
			print("|cff00CCFF[DEBUG]|r |cff00d111RECEIVE|r PHASE", id, name, description, icon, information, owner)
		end
		--print(id,name,description,icon)
		addPhaseToList(id)
	end
	end
end)

server.receive("PHASES", function(message, channel, sender)
	--print(message,channel.sender)

	local records = {string.split(EpsiLib.record, message)}
	for _, record in pairs(records) do
		local id, name, description, icon, information, owner = string.split(EpsiLib.field, record)
		--print("PHASE",id, owner, name, comment, description)
		if id and name and description then

		table.insert(phases, {
			id = id,
			owner = owner,
			name = name,
			icon = "|h|TINTERFACE\\ICONS\\"..icon..":30:30|t|h|r",
			comment = comment,
			description = description,
			information = information,
		});
		if Epsilon_debugging == true then
			print("|cff00CCFF[DEBUG]|r |cff00d111RECEIVE|r PHASE", id, name, description, icon, information, owner)
		end
		--print(id,name,description,icon)
		addPhaseToList(id)
	end
	end
end)

server.receive("UPDATE", function(message, channel, sender)
	--print(message,channel.sender)

	local records = {string.split(EpsiLib.record, message)}
	for _, record in pairs(messages) do
		local id, field, newValue = string.split(EpsiLib.field, record)
		for k, v in pairs(phases) do
			if v.id == id then
				phases[field] = newValue;
				break;
			end
			if Epsilon_debugging == true then
				print("|cff00CCFF[DEBUG]|r |cff00d111RECEIVE|r PHASE UPDATE", v.id, field, newValue)
			end
		end
	end
end)
server.receive("UNLIST", function(message, channel, sender)

	--print("UNLIST",message,channel.sender)

	if Epsilon_debugging == true then
		print("|cff00CCFF[DEBUG]|r |cff00d111RECEIVE|r PHASE UNLIST", message)
	end
	local phaseID = message;

	for k, v in pairs(phases) do
		if v.id == phaseID then
			table.remove(phases, k)
			break;
		end
	end

end)
messages.send("EPSILON_G_PHASES", "CLIENT_READY");




local left = CreateFrame("FRAME", "$parentLeftInset", container, "EpsiLibInsetFrameTemplate")
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
	label:SetTextColor(1,1,1,0.5)
	
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
for key,value in pairs({["id"] = {name = "Phase ID", uiName = "Phase"}, ["icon"] = {name = "", uiName = "icon"}, ["name"] = {name = "Phase Name", uiName = "Name"}}) do
	local label = CreateLabel(value.name, left, lastAnchor);
	label:SetPoint("CENTER", left, "CENTER", (left:GetWidth() / 2) - label:GetWidth(), 0)
	--label:SetPoint("LEFT", left, "LEFT", 5, 0);
	local fs = left:CreateFontString("$parent"..value.uiName, nil, "GameFontHighlightSmall");
	fs:SetPoint("TOP", label, "BOTTOM", 0, -10);
	values[key] = fs;
	lastAnchor = fs;
end

local right = CreateFrame("FRAME", "$parentRightInset", container, "EpsiLibInsetFrameTemplate")
right:SetPoint("TOP", container, 0, -25)
right:SetPoint("LEFT", left, "RIGHT")
right:SetPoint("RIGHT")
right:SetPoint("BOTTOM", container, 0, 25)

local updated;

local selected = {};
local scroll = CreateFrame("SCROLLFRAME", "$parentScrollFrame", right, "EpsilonHybridScrollFrameTemplate")

function scroll.updateInfo()
	local htmlscroll = PhaseInfo.scroll
	local scrollBar = htmlscroll.scrollBar
	local html = htmlscroll.html
	html:SetText('<html><body><h2 align="CENTER">'..selected.name..'|r</h2><br /><p align="CENTER">Phase: '..selected.id..'</p><br /><p align="center">'..selected.description..'</p><br /><p align="center">'..selected.information..'</p></body></html>')
	html:SetHeight(html:GetContentHeight() + 1)
	local scrollMax = html:GetHeight() - htmlscroll:GetHeight()
	scrollMax = scrollMax > 0 and scrollMax or 0
	scrollBar:SetMinMaxValues(0, scrollMax)
	htmlscroll.range = scrollMax
	scrollBar:SetValue(0)
	if PhaseInfo:IsShown() then
		--PlaySoundFile("igSpellBookOpen")
	end
end
HybridScrollFrame_CreateButtons(scroll, "EpsilonThreeButtonTemplate")
scroll:SetScript("OnUpdate", function(self)
	local offset = HybridScrollFrame_GetOffset(self)
	local buttons = self.buttons
	for i = 1, #buttons do
		local button = buttons[i]
		local phase = phases[offset + i]
		if phase then
			if phase == self.selected then button:LockHighlight() else button:UnlockHighlight() end
			if updated ~= self.selected then self.updateInfo() updated = self.selected end
			button.entry = phase
			button.left:SetText(phase.name)
			button.left:SetTextColor(0,0.8,1)
			button.middle:SetText(phase.description)
			button.right:SetText(phase.id)
			button:Show()
		else
			button:Hide()
		end
	end
	HybridScrollFrame_Update(self, 20 * #phases, 20)
end)
for _,button in pairs(scroll.buttons) do
	button:SetScript("OnClick", function(self)
		for k,v in pairs(phases) do
			if v.id == button.entry.id then
				UpdateLabels(v);
				selected.id = button.entry.id;
				selected.name = button.entry.name;
				selected.description = button.entry.description;
				selected.information = v.information;
				button:LockHighlight();
			end
		end
	end);
end

local header1 = CreateFrame("BUTTON", "$parentHeader1", right, "WhoFrameColumnHeaderTemplate")
header1:SetPoint("BOTTOMLEFT", right, "TOPLEFT")
header1:SetPoint("RIGHT", scroll.buttons[1].left)
header1:SetText("Name")
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


local join = CreateFrame("BUTTON", "$parentJoin", container, "UIPanelButtonTemplate")
join:SetPoint("BOTTOMLEFT", main)
join:SetPoint("LEFT", right)
join:SetText("Join")
join:SetWidth(container:GetWidth() / 4)
MagicButton_OnLoad(join)
join:SetScript("OnClick", function()
	local id = values.id:GetText();
	if id then
		SendChatMessage(".phase enter " .. id)
	else

	end
end)

local info = CreateFrame("BUTTON", "$parentJoin", container, "UIPanelButtonTemplate")
info:SetPoint("BOTTOMRIGHT", main, -25, 5)
info:SetWidth(container:GetWidth() / 4)
info:SetText("Information")
MagicButton_OnLoad(info)

info:SetScript("OnClick", function()
	local id = values.id:GetText();
	if id then
		scroll.updateInfo()
		ShowUIPanel(PhaseInfo)
	else
		--no phase selected
	end
end)

local refresh = CreateFrame("BUTTON", "$parentJoin", container, "UIPanelButtonTemplate")
refresh:SetPoint("BOTTOM", main)
refresh:SetWidth(container:GetWidth() / 4)
refresh:SetText("Refresh")
MagicButton_OnLoad(refresh)

refresh:SetScript("OnClick", function()
	phases = {}
	messages.send("EPSILON_G_PHASES", "CLIENT_READY");
	
	if Epsilon_debugging then
		print("|cff00CCFF[DEBUG]|r |cff00d111CLICK|r: PHASE REFRESH")
	end
	
end)