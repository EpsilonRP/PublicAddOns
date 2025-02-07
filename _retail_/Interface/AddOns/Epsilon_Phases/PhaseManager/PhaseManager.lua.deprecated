--d
local phases, EPSILON_PHASES = ...
local EpsiLib = EpsilonLib;


local _containers = EpsiLib.ContainerTemplate
local headers = _containers.Headers
local tabs = _containers.Tabs

local server = EpsiLib.Server.messages

local main = EpsiLib.Container

main.phasemanager = tabs.createTab("Phase Manager", main)
local container = main.phasemanager

local currentPhase = 169;

local _settingsArea = headers.createHeader("Settings", container)
_settingsArea:SetScript("OnShow", function(self)
	self.weather.text:SetText("Weather for "..GetZoneText())
	server.send("G_TOGLS","1")
	server.send("P_PHASE", "CLIENT_READY");
end)

local changes = CreateFrame("BUTTON", "$parentSave", _settingsArea, "UIPanelButtonTemplate")
changes:SetPoint("BOTTOMLEFT", main)
changes:SetWidth(container:GetWidth()/4)
changes:SetFrameStrata("HIGH")
MagicButton_OnLoad(changes)
hooksecurefunc(changes, "Enable", function(self)
	self:SetText("Save")
end)
hooksecurefunc(changes, "Disable", function(self)
	self:SetText("No Changes")
end)
changes:Disable()

local abandon = CreateFrame("BUTTON", "$parentCancel", _settingsArea, "UIPanelButtonTemplate")
abandon:SetPoint("BOTTOMRIGHT", main)
abandon:SetWidth(container:GetWidth()/4)
abandon:SetFrameStrata("HIGH")
abandon:SetText("Cancel")
MagicButton_OnLoad(abandon)
abandon:SetScript("OnClick", function()
	changes:Disable()
end)

local MARGIN = 7

local row = 1
local rows;
local function CreateGroup(size, name)
	local group = CreateFrame("FRAME", "$parent"..name, _settingsArea, "BackdropTemplate")
	_settingsArea[name:lower()] = group
	group:SetHeight(1) -- Temporary
	if size == "FULL" then
		group:SetWidth(_settingsArea:GetWidth() - MARGIN * 2)
	elseif size == "HALF" then
		group:SetWidth(_settingsArea:GetWidth() / 2 - MARGIN / 2 - MARGIN)
	end
	if rows then
		group:SetPoint("TOPLEFT", rows[row][#rows[row]], "TOPRIGHT", MARGIN, 0)
		if group:GetRight() > _settingsArea:GetRight() then
			group:SetPoint("TOPLEFT", rows[row][1], "BOTTOMLEFT", 0, -MARGIN)
			row = row + 1
			rows[row] = {}
		end
	else
		rows = {{}}
		group:SetPoint("TOPLEFT", MARGIN, -MARGIN)
	end
	group.row = row
	table.insert(rows[row], group)
	hooksecurefunc(group, "SetHeight", function(self, height, skip)
		if skip then return end
		local largest = 0
		for i = 1, #rows[self.row] do
			if height > largest then largest = height end
		end
		for i = 1, #rows[self.row] do
			rows[self.row][i]:SetHeight(largest, true)
		end
	end)
	group:SetBackdrop({bgFile = "Interface/BUTTONS/WHITE8X8", tile = true})
	group:SetBackdropColor(0.95,0.95,1,0.09);
	group.text = group:CreateFontString(nil, nil, "GameFontNormal")
	group.text:SetPoint("TOPLEFT", MARGIN, -MARGIN)
	group.text:SetPoint("RIGHT", -MARGIN, 0)
	group.text:SetJustifyH("LEFT")
	group.text:SetWordWrap(false)
	group.text:SetText(name)
	group:SetScript("OnUpdate", function(self)
		for k, v in pairs({self:GetChildren()}) do
			local height = self:GetTop() - v:GetBottom() + MARGIN
			if height > self:GetHeight() then
				self:SetHeight(height)
			end
		end
		self:SetScript("OnUpdate", nil)
	end)
	return group
end
local privacy_settings = {
	[0] = "on",
	[1] = "off",
}

local privacy = CreateGroup("HALF", "Privacy")
privacy.whitelist = CreateFrame("CHECKBUTTON", "$parentWhitelist", privacy, "UIRadioButtonTemplate")
privacy.whitelist:SetPoint("TOPLEFT", privacy.text, "BOTTOMLEFT", 0, -MARGIN)
privacy.whitelist.text:SetText("Whitelist")
privacy.whitelist.text:SetTextColor(1, 1, 1, 1)
privacy.whitelist:SetScript("OnClick", function(self)
	privacy.blacklist:SetChecked(not self:GetChecked())
	changes:Enable()
end)
privacy.blacklist = CreateFrame("CHECKBUTTON", "$parentBlacklist", privacy, "UIRadioButtonTemplate")
privacy.blacklist:SetPoint("TOP", privacy.whitelist)
privacy.blacklist:SetPoint("LEFT", privacy, "CENTER")
privacy.blacklist.text:SetText("Blacklist")
privacy.blacklist.text:SetTextColor(1, 1, 1, 1)
privacy.blacklist:SetChecked(true)
privacy.blacklist:SetScript("OnClick", function(self)
	privacy.whitelist:SetChecked(not self:GetChecked())

	changes:Enable()
end)

local starting = CreateGroup("HALF", "Starting")
starting.set = CreateFrame("BUTTON", "$parentNew", starting, "UIPanelButtonTemplate")
starting.set:SetPoint("TOP", starting.text, "BOTTOM", 0, -MARGIN)
starting.set:SetPoint("LEFT", MARGIN, 0)
starting.set:SetPoint("RIGHT", -MARGIN, 0)
starting.set:SetText("Set Current Location")
starting.set:SetFrameStrata("HIGH")
starting.set:SetScript("OnClick", function()
	changes:Enable()
	SendChatMessage(".phase set start", "GUILD");
end)


local time = CreateGroup("FULL", "Time")
time.text:ClearAllPoints()
time.text:SetPoint("TOPLEFT", MARGIN, -MARGIN)
time.slider = CreateFrame("Slider", "$parentSlider", time, "OptionsSliderTemplate")
time.slider:SetPoint("LEFT", time.text, "RIGHT", MARGIN, 0)
time.slider.text = _G[time.slider:GetName().."Text"]
time.slider.text:ClearAllPoints()
time.slider.text:SetPoint("RIGHT", time, -MARGIN, 0)
time.slider.text:SetPoint("CENTER", time.text)
time.slider:SetPoint("RIGHT", -time.text:GetWidth() - MARGIN * 3, 0)
time.slider:SetMinMaxValues(0, 1439)
time.slider:SetValueStep(1)
time.slider:SetObeyStepOnDrag(true)
_G[time.slider:GetName().."Low"]:Hide()
_G[time.slider:GetName().."High"]:Hide()
function time.slider.getTime(value)
	local hours = string.format("%.2d", math.floor(value/60))
	local minutes = string.format("%.2d", value % 60)
	return hours..":"..minutes
end
time.slider:SetValue(0)
local settingTime = false;
time.slider:SetScript("OnValueChanged", function(self, value)
	if self.last == value then return end
	local time = self.getTime(value)
	--server.send("S_TIME", time)
	SendChatMessage(".ph set time "..time, "GUILD");
	self.text:SetText(time)
	settingTime = true;
	changes:Enable()
	self.last = value
	C_Timer.NewTicker(20, function(self)
		settingTime = false;
	end,1)
end)

local function timemessageFilter(self,event,message,...)

	if message:match("You have set the time of phase") then
		return settingTime;
	end
end
ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", timemessageFilter);

local OFFSET = 25

local weather = CreateGroup("HALF", "Weather")
weather.dropdown = CreateFrame("FRAME", "$parentDropDown", weather, "UIDropDownMenuTemplate")
weather.dropdown:SetPoint("TOP", weather.text, "BOTTOM", 0, -MARGIN)
weather.dropdown:SetPoint("LEFT", -OFFSET / 3, 0)
weather.dropdown:SetPoint("RIGHT")
weather.dropdown.list = {
	{"Fine", "Normal", 0},
	{"Fog", "Fog", 10},
	{"Light Rain", "Rain", 30},
	{"Medium Rain", "Rain", 40},
	{"Heavy Rain", "Rain", 50},
	{"Purple Rain", "arcanespark", 64},
	{"Blood Rain", "blood", 100},
	{"Thunder", "Thunderstorm", 86},
	{"Light Snow", "Snow", 60},
	{"Medium Snow", "Snow", 70},
	{"Heavy Snow", "Snow", 80},
	{"Heavy Snowballs", "Snow", 39},	
	{"Light Sandstorm", "Sandstorm", 22},
	{"Medium Sandstorm", "Sandstorm", 41},
	{"Heavy Sandstorm", "Sandstorm", 42},
	{"Black Rain", "BlackRain", 90},
	{"Black Snow", "BlackSnow", 100},
	{"Light Ash", "fireball", 23},
	{"Large Ash", "fireball", 43},
	{"Arcane Sparks", "arcanespark", 82},
	{"Fire Sparks", "firespark", 69},
	{"Lava Blood", "deathwing", 68},
	{"Tavern Ambience", "mistgrain", 55},
	{"Crowd Ambience", "fireball", 56},
}
UIDropDownMenu_SetWidth(weather.dropdown, weather.dropdown:GetWidth() - OFFSET - OFFSET / 3 * 2)
UIDropDownMenu_Initialize(weather.dropdown, function(self)
	local info = UIDropDownMenu_CreateInfo()
	for i = 1, #self.list do
		info.text = self.list[i][1]
		info.func = function(item)
			UIDropDownMenu_SetSelectedID(self, item:GetID())
			changes:Enable()
		end
		info.checked = false
		UIDropDownMenu_AddButton(info)
	end
end);
UIDropDownMenu_SetSelectedID(weather.dropdown, 1)

local toggles = CreateGroup("HALF", "Toggles")
toggles.dropdown = CreateFrame("FRAME", "$parentDropDown", toggles, "UIDropDownMenuTemplate")
toggles.dropdown:SetPoint("TOP", toggles.text, "BOTTOM", 0, -MARGIN)
toggles.dropdown:SetPoint("LEFT", -OFFSET / 3, 0)
toggles.dropdown:SetPoint("RIGHT")
toggles.dropdown.list = {
	{"Cheats"},
	{"Spells"},
	{"Modify"},
	{"Flight"},
	{"Teleport"}
}
toggles_checked = {

}

server.receive("TOGGLES", function(message, channel, sender)

	local records = {string.split(EpsiLib.record, message)}

	for _, record in pairs(records) do
		local cheats, spell, modify, flight, teleport = string.split(EpsiLib.field, record)
		if Epsilon_debugging == true then
			print(record,id,field)
		end
		if cheats and spell and modify and flight and teleport then
			toggles_checked[1] = tonumber(cheats)
			toggles_checked[2] = tonumber(spell)
			toggles_checked[3] = tonumber(modify)
			toggles_checked[4] = tonumber(flight)
			toggles_checked[5] = tonumber(teleport)			
		end
		if Epsilon_debugging == true then
			print("|cff00CCFF[DEBUG]|r |cff00d111RECEIVE|r TOGGLES",cheats, spell, modify, flight, teleport)
		end
	end

end)


UIDropDownMenu_SetWidth(toggles.dropdown, toggles.dropdown:GetWidth() - OFFSET - OFFSET / 3 * 2)
UIDropDownMenu_Initialize(toggles.dropdown, function(self)
	--server.send("G_TOGLS","1")
	local info = UIDropDownMenu_CreateInfo()
	for i = 1, #self.list do
		info.text = self.list[i][1]
		info.func = function(item)
			self.list[i][2] = not self.list[i][2]
			if self.list[i][2] == true then
				toggles_checked[i] = 1;
			else
				toggles_checked[i] = 0;
			end
			changes:Enable()
		end

		local check = false;

		if toggles_checked[i] and toggles_checked[i] > 0 then
			check = true;
		end
		
		info.isNotRadio = true;
		info.keepShownOnClick = true
		info.checked = check;
		UIDropDownMenu_AddButton(info)
	end
end);
UIDropDownMenu_SetText(toggles.dropdown, "Configure Toggles");

local name = CreateGroup("HALF", "Name")
name.edit = CreateFrame("EDITBOX", "$parentEdit", name, "InputBoxTemplate")
name.edit:SetAutoFocus(false)
name.edit:SetHeight(20)
name.edit:SetPoint("TOP", name.text, "BOTTOM", 0, -MARGIN)
name.edit:SetPoint("LEFT", name, MARGIN + 5, 0)
name.edit:SetPoint("RIGHT", name, -MARGIN, 0)
name.edit:SetScript("OnTextChanged", function(self, userInput)
	if not userInput then return end
	changes:Enable()
end)

local comment = CreateGroup("HALF", "Description")
comment.edit = CreateFrame("EDITBOX", "$parentEdit", comment, "InputBoxTemplate")
comment.edit:SetAutoFocus(false)
comment.edit:SetHeight(20)
comment.edit:SetPoint("TOP", comment.text, "BOTTOM", 0, -MARGIN)
comment.edit:SetPoint("LEFT", comment, MARGIN + 5, 0)
comment.edit:SetPoint("RIGHT", comment, -MARGIN, 0)
comment.edit:SetScript("OnTextChanged", function(self, userInput)
	changes:Enable()
end)

local motd = CreateGroup("FULL", "Message of the Day")
motd:SetPoint("BOTTOM", 0, MARGIN)
motd.edit = CreateFrame("FRAME", "$parentEdit", motd, "EpsilonInputScrollTemplate")
motd.edit:SetPoint("TOPLEFT", motd.text, "BOTTOMLEFT", 0, -MARGIN)
motd.edit:SetPoint("BOTTOMRIGHT", -MARGIN, MARGIN)
motd.edit.ScrollFrame.EditBox:SetScript("OnTextChanged", function(self, userInput)
	changes:Enable()
end)

changes:SetScript("OnClick", function(self)
	local mask = 0
	local output = "";

	if tonumber(currentPhase) ~= 169 then 
		for i = 1, 5 do
			output = output .. ":" .. toggles_checked[i];
			mask = mask + math.pow(2, i-1) * (toggles_checked[i] and 1 or 0)
		end

		server.send("S_TOGLS", output);
		server.send("S_PRVCY", privacy.whitelist:GetChecked() and 1 or 2)
		--server.send("S_START", "")
		server.send("S_TIME", time.slider.getTime(time.slider:GetValue()))

		--print(weather.dropdown.list[UIDropDownMenu_GetSelectedID(weather.dropdown)][1], weather.dropdown.list[UIDropDownMenu_GetSelectedID(weather.dropdown)][2], weather.dropdown.list[UIDropDownMenu_GetSelectedID(weather.dropdown)][3])
		SendChatMessage(".phase set weather " .. weather.dropdown.list[UIDropDownMenu_GetSelectedID(weather.dropdown)][2]:lower() .. " " .. weather.dropdown.list[UIDropDownMenu_GetSelectedID(weather.dropdown)][3], "GUILD")

		server.send("S_NAME", name.edit:GetText())
		server.send("S_DESC", comment.edit:GetText())
		server.send("S_MOTD", motd.edit.ScrollFrame.EditBox:GetText())
		if Epsilon_debugging == true then
			print("|cff00CCFF[DEBUG]|r |cff00d111SETTINGS SET|r WEATHER", weather.dropdown.list[UIDropDownMenu_GetSelectedID(weather.dropdown)][2]:lower(), weather.dropdown.list[UIDropDownMenu_GetSelectedID(weather.dropdown)][3]);
			print("|cff00CCFF[DEBUG]|r |cff00d111SETTINGS SET|r TEXT FIELDS", name.edit:GetText(), comment.edit:GetText(), motd.edit.ScrollFrame.EditBox:GetText());
			print("|cff00CCFF[DEBUG]|r |cff00d111SETTINGS SET|r TOGGLES", output)
			print("|cff00CCFF[DEBUG]|r |cff00d111SETTINGS SET|r TIME",time.slider.getTime(time.slider:GetValue()))
			print("|cff00CCFF[DEBUG]|r |cff00d111SETTINGS SET|r PRIVACY", privacy.whitelist:GetChecked() and 1 or 2)
			
		end
		server.send("G_TOGLS","1")
		server.send("P_PHASE","1");
		self:Disable()
	end
end)


server.receive("PPHASE", function(message, channel, sender)

	local records = {string.split(EpsiLib.record, message)}

	for _, record in pairs(records) do
		local pid, pname, pmotd, pdescription = string.split(EpsiLib.field, record)
		currentPhase = pid;
		if Epsilon_debugging == true then
			print(record,id,field)
			print("|cff00CCFF[DEBUG]|r |cff00d111RECEIVE|r PPHASE",pid, pname, pmotd, pdescription);
		end
		if pname and pmotd then
			name.edit:SetText(pname);
			motd.edit.ScrollFrame.EditBox:SetText(pmotd);
			comment.edit:SetText(pdescription)
		end

	end

end)

server.send("P_PHASE","1");

SLASH_PHASE1 = '/phase'
function SlashCmdList.PHASE()
	--UpdatePhaseList();
	phases = {}
	server.send("P_PHASE", "CLIENT_READY");
	server.send("G_TOGLS","1")
	tabs.setTab(main, 2)
end

changes:Disable()