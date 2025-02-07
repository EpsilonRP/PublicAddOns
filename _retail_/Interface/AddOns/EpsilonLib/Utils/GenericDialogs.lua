local EpsilonLib, EpsiLib = ...;


-- //  Generic Popups System - this is a copy of Blizzard's GENERIC_CONFIRMATION and GENERIC_INPUT_BOX system added in Dragonflight, modified for BFA/SL compatibility & Expanded

-------------------------------
---#region Generic Dialog Helpers
-------------------------------

local function standardNonEmptyTextHandler(self)
	local parent = self:GetParent();
	parent.button1:SetEnabled(strtrim(parent.editBox:GetText()) ~= "");
end

local function standardEditBoxOnEscapePressed(self)
	self:GetParent():Hide();
end

local function hideCancelIfNeeded(dialogTemplate, customData)
	if customData.cancelText == false then -- accept false as "DON'T SHOW THIS BUTTON"
		dialogTemplate.button2 = nil
	end
end

local function restoreCancelButton(dialogTemplate)
	dialogTemplate.button2 = "" -- supplied dynamically
end

local hardOverrides = {
	"editBoxWidth",
    "subText",
    "noCancelOnEscape",
    "exclusive"
}
local function runOverrides(dialogTemplate, customData)
	for i = 1, #hardOverrides do
		local field = hardOverrides[i]
		if customData[field] then
			dialogTemplate[field] = customData[field]
        else
            -- always default to nil so that subsequent calls are clean
            dialogTemplate[field] = nil
        end
	end
	hideCancelIfNeeded(dialogTemplate, customData)
end
local function resetOverrides(dialogTemplate)
	for i = 1, #hardOverrides do
		local field = hardOverrides[i]
		dialogTemplate[field] = nil
	end

	restoreCancelButton(dialogTemplate)
end

-------------------------------
---#region Generic Input Box
-------------------------------

StaticPopupDialogs["EPSILIB_GENERIC_INPUT_BOX"] = {
	text = "", -- supplied dynamically.
    subText = "",
	button1 = "", -- supplied dynamically.
	button2 = "", -- supplied dynamically.
	hasEditBox = 1,
	OnShow = function(self, data)
		self.text:SetFormattedText(data.text, data.text_arg1, data.text_arg2);
		self.button1:SetText(data.acceptText or DONE);
		self.button2:SetText(data.cancelText or CANCEL);
		self.editBox:SetMaxLetters(data.maxLetters or 24);
		self.editBox:SetCountInvisibleLetters(not not data.countInvisibleLetters);

		if data.inputText then
			self.editBox:SetText(data.inputText)
			self.editBox:HighlightText()
		end

		standardNonEmptyTextHandler(self.editBox)
	end,
    OnHide = function(self)
        --resetOverrides(StaticPopupDialogs[self.which])
    end,
	OnAccept = function(self, data)
		if not data then return end
		local text = self.editBox:GetText();
		data.callback(text);
	end,
	OnCancel = function(self, data, from)
		if not data then return end
		local cancelCallback = data.cancelCallback;
		local text = self.editBox:GetText();
		if type(cancelCallback) == "function" then
			cancelCallback(text, from);
		end
	end,
	EditBoxOnEnterPressed = function(self, data)
		local parent = self:GetParent();
		if parent.button1:IsEnabled() then
			local text = parent.editBox:GetText();
			data.callback(text);
			parent:Hide();
		end
	end,
	EditBoxOnTextChanged = standardNonEmptyTextHandler,
	EditBoxOnEscapePressed = standardEditBoxOnEscapePressed,
	hideOnEscape = 1,
    cancels = "EPSILIB_GENERIC_INPUT_BOX",
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
};

---@class GenericInputCustomData
---@field text string the text for the confirmation
---@field subText? string additional text for the confirmation
---@field text_arg1? string formatted into text if provided
---@field text_arg2? string formatted into text if provided
---@field callback fun(text: string) the callback when the player accepts
---@field cancelCallback? fun(text: string?) the callback when the player cancels / not called on accept
---@field acceptText? string custom text for the accept button
---@field cancelText? string custom text for the cancel button
---@field maxLetters? integer the maximum text length that can be entered
---@field countInvisibleLetters? boolean used in tandem with maxLetters
---@field inputText? string default text for the input box
---@field editBoxWidth? number override width of input box


---@param customData GenericInputCustomData
---@param insertedFrame frame?
local function showCustomGenericInputBox(customData, insertedFrame)
	local template = "EPSILIB_GENERIC_INPUT_BOX"
	runOverrides(StaticPopupDialogs[template], customData)
	local shownFrame = StaticPopup_Show(template, nil, nil, customData, insertedFrame);
	--resetOverrides(StaticPopupDialogs[template])
    restoreCancelButton(StaticPopupDialogs[template])
    
	return shownFrame
end

-------------------------------
--#endregion
-------------------------------


-------------------------------
---#region Generic Multi-Line Input
-------------------------------

local function multiLineNonEmptyTextHandler(self)
	local scrollframe = self:GetParent();
	local dialog = scrollframe:GetParent();
	dialog.button1:SetEnabled(strtrim(self:GetText()) ~= "");
end

local function multiLineEditBoxOnEscapePressed(self)
	self:GetParent():GetParent():Hide();
end

StaticPopupDialogs["EPSILIB_GENERIC_MULTILINE_INPUT_BOX"] = {
	text = "",  -- supplied dynamically.
	button1 = "", -- supplied dynamically.
	button2 = "", -- supplied dynamically.
	subText = " ", -- always a blank space to start so it buffers space for the multi-line edit box
	OnShow = function(self, data)
		self.text:SetFormattedText(data.text, data.text_arg1, data.text_arg2);
		if data.subText then self.SubText:SetText(data.subText .. "\n\r") end -- force extra lines at the end to buffer space for the multi-line edit box
		self.button1:SetText(data.acceptText or DONE);
		self.button2:SetText(data.cancelText or CANCEL);
		self.insertedFrame.EditBox:SetMaxLetters(data.maxLetters or 999999);
		self.insertedFrame.EditBox:SetCountInvisibleLetters(not not data.countInvisibleLetters);

		if data.inputText then
			self.insertedFrame.EditBox:SetText(data.inputText)
			self.insertedFrame.EditBox:HighlightText()
		end

		self.insertedFrame.EditBox:SetScript("OnTextChanged", multiLineNonEmptyTextHandler)
		--self.insertedFrame.EditBox:SetScript("OnEscapePressed", multiLineEditBoxOnEscapePressed) -- nah

		multiLineNonEmptyTextHandler(self.insertedFrame.EditBox)
	end,
    OnHide = function(self)
        --resetOverrides(StaticPopupDialogs[self.which])
    end,
	OnAccept = function(self, data)
		if not data then return end
		local text = self.insertedFrame.EditBox:GetText();
		data.callback(text);
	end,
	OnCancel = function(self, data, from)
		if not data then return end
		local cancelCallback = data.cancelCallback;
		local text = self.insertedFrame.EditBox:GetText();
		if type(cancelCallback) == "function" then
			cancelCallback(text, from);
		end
	end,
	--[[
	EditBoxOnEnterPressed = function(self, data)
		local parent = self:GetParent();
		if parent.button1:IsEnabled() then
			local text = parent.editBox:GetText();
			data.callback(text);
			parent:Hide();
		end
	end,
	EditBoxOnTextChanged = standardNonEmptyTextHandler,
	EditBoxOnEscapePressed = standardEditBoxOnEscapePressed,
	--]]
	hideOnEscape = 1,
	timeout = 0,
	exclusive = 1,
    cancels = "EPSILIB_GENERIC_MULTILINE_INPUT_BOX",
	whileDead = 1,
	editBoxWidth = 340
};

local multiLineInputBox
local function genMultiLineInputBoxOnDemand(width)
	if not multiLineInputBox then
		multiLineInputBox = CreateFrame("ScrollFrame", nil, nil, "InputScrollFrameTemplate")
		multiLineInputBox:SetSize(330, 180)
	end

	multiLineInputBox:SetWidth(width and tonumber(width) or 180)
	multiLineInputBox.EditBox:SetWidth(multiLineInputBox:GetWidth() - 18)
	multiLineInputBox.maxLetters = 999999

	return multiLineInputBox
end

---@param customData GenericInputCustomData
local function showCustomMultiLineInputBox(customData)
	local template = "EPSILIB_GENERIC_MULTILINE_INPUT_BOX"
	runOverrides(StaticPopupDialogs[template], customData)
	local shownFrame = StaticPopup_Show(template, nil, nil, customData, genMultiLineInputBoxOnDemand(customData.editBoxWidth));
	--resetOverrides(StaticPopupDialogs[template])
    restoreCancelButton(StaticPopupDialogs[template])

	return shownFrame
end

-------------------------------
---#endregion
-------------------------------

-------------------------------
---#region Generic Confirmation
-------------------------------

StaticPopupDialogs["EPSILIB_GENERIC_CONFIRMATION"] = {
	text = "", -- supplied dynamically.
	button1 = "", -- supplied dynamically.
	button2 = "", -- supplied dynamically.
	OnShow = function(self, data)
		self.text:SetFormattedText(data.text, data.text_arg1, data.text_arg2);
		self.button1:SetText(data.acceptText or YES);
		self.button2:SetText(data.cancelText or NO);

		self.AlertIcon = _G[self:GetName() .. "AlertIcon"]; -- fix for this not being defined in the frame table before DF
		if data.showAlert then
			self.AlertIcon:SetTexture(STATICPOPUP_TEXTURE_ALERT);
			if (self.button3:IsShown()) then
				self.AlertIcon:SetPoint("LEFT", 24, 10);
			else
				self.AlertIcon:SetPoint("LEFT", 24, 0);
			end
			self.AlertIcon:Show();
		else
			self.AlertIcon:Hide();
		end
	end,
    OnHide = function(self)
        --resetOverrides(StaticPopupDialogs[self.which])
    end,
	OnAccept = function(self, data)
		if not data then return end
		if data.callback then
			data.callback();
		end
	end,
	OnCancel = function(self, data, from)
		if not data then return end
		local cancelCallback = data.cancelCallback;
		if type(cancelCallback) == "function" then
			cancelCallback(from);
		end
	end,
	OnHyperlinkEnter = function(self, link, text, region, boundsLeft, boundsBottom, boundsWidth, boundsHeight)
		GameTooltip:SetOwner(self, "ANCHOR_PRESERVE");
		GameTooltip:ClearAllPoints();
		local cursorClearance = 30;
		GameTooltip:SetPoint("TOPLEFT", region, "BOTTOMLEFT", boundsLeft, boundsBottom - cursorClearance);
		GameTooltip:SetHyperlink(link);
	end,
	OnHyperlinkLeave = function(self)
		GameTooltip:Hide();
	end,
	OnHyperlinkClick = function(self, link, text, button)
		GameTooltip:Hide();
	end,
    exclusive = 1,
    cancels = "EPSILIB_GENERIC_CONFIRMATION",
	hideOnEscape = 1,
	timeout = 0,
	multiple = 1,
	whileDead = 1,
	wide = 1, -- Always wide to accommodate the alert icon if it is present.
};

---@class GenericConfirmationCustomData
---@field text string? the text for the confirmation
---@field text_arg1 string? formatted into text if provided
---@field text_arg2 string? formatted into text if provided
---@field callback fun()? the callback when the player accepts
---@field cancelCallback fun()? the callback when the player cancels / not called on accept
---@field acceptText string? custom text for the accept button
---@field cancelText string|boolean? custom text for the cancel button - provide false to hide the cancel button
---@field showAlert boolean? whether or not the alert texture should show
---@field referenceKey string? used with StaticPopup_IsCustomGenericConfirmationShown / not implemented here

---@param customData GenericConfirmationCustomData
---@param insertedFrame? frame
local function showCustomGenericConfirmation(customData, insertedFrame)
	local template = "EPSILIB_GENERIC_CONFIRMATION"

	runOverrides(StaticPopupDialogs[template], customData)
	local shownFrame = StaticPopup_Show(template, nil, nil, customData, insertedFrame);
	--resetOverrides(StaticPopupDialogs[template])
    restoreCancelButton(StaticPopupDialogs[template])

	return shownFrame
end

---@param text string the text for the confirmation
---@param callback fun()? the callback when the player accepts
---@param insertedFrame frame?
local function showGenericConfirmation(text, callback, insertedFrame)
	local data = { text = text, callback = callback, };
	return showCustomGenericConfirmation(data, insertedFrame);
end

-------------------------------
---#endregion
-------------------------------



-------------------------------
---#region Generic Drop Down
-------------------------------

StaticPopupDialogs["EPSILIB_GENERIC_DROP_DOWN"] = {
	text = "", -- supplied dynamically.
	button1 = ACCEPT,
	button2 = CANCEL,
	hasDropDown = 1,
	dropDownOptions = {},
	OnShow = function(self, data)
		self.text:SetFormattedText(data.text, data.text_arg1, data.text_arg2);
		self.button1:SetText(data.acceptText or OKAY);
		self.button2:SetText(data.cancelText or CANCEL);

		if not self.DropDownControl then
			self.DropDownControl = CreateFrame("Frame", nil, self, "DropDownControlTemplate")
			self.DropDownControl:SetPoint("BOTTOM", 0, 45)
		end
		self.DropDownControl:Show()
		self.DropDownControl:ClearSelectedValue();
		self.DropDownControl:SetOptions(data.options, data.defaultOption);
		local hasButtons = not not data.hasButtons;
		self.button1:SetShown(hasButtons);
		if data.cancelText ~= false then
			self.button2:SetShown(hasButtons);
		end
		if hasButtons then
			self.DropDownControl:SetOptionSelectedCallback(nil);
		else
			local function StaticPopupGenericDropDownOptionSelectedCallback(option)
				data.callback(option);
				self:Hide();
			end
			self.DropDownControl:SetOptionSelectedCallback(StaticPopupGenericDropDownOptionSelectedCallback);
		end
	end,
	OnAccept = function(self, data)
		data.callback(self.DropDownControl:GetSelectedValue());
	end,
	OnHide = function(self)
		self.DropDownControl:SetOptionSelectedCallback(nil);
		self.DropDownControl:ClearOptions();
		self.DropDownControl:Hide()
        --resetOverrides(StaticPopupDialogs[self.which])
	end,
	hideOnEscape = 1,
	timeout = 0,
	exclusive = 1,
    cancels = "EPSILIB_GENERIC_DROP_DOWN",
	whileDead = 1,
};

local function showCustomGenericDropDown(customData, insertedFrame)
	local template = "EPSILIB_GENERIC_DROP_DOWN"
	runOverrides(StaticPopupDialogs[template], customData)
	local shownFrame = StaticPopup_Show(template, nil, nil, customData, insertedFrame);
	shownFrame:SetHeight(shownFrame:GetHeight() + 40) -- manual adjust for dropdown lol
	--resetOverrides(StaticPopupDialogs[template])
    restoreCancelButton(StaticPopupDialogs[template])

	return shownFrame
end

local function showGenericDropDown(text, callback, options, hasButtons, defaultOption, insertedFrame)
	local customData = { text = text, callback = callback, options = options, hasButtons = hasButtons, defaultOption = defaultOption };

	return showCustomGenericDropDown(customData, insertedFrame)
end



EpsiLib.Utils.GenericDialogs = {
    CustomInput = showCustomGenericInputBox,
    CustomMultiLineInput = showCustomMultiLineInputBox,

    CustomConfirmation = showCustomGenericConfirmation,
    GenericConfirmation = showGenericConfirmation,

    CustomDropDown = showCustomGenericDropDown,
    GenericDropDown = showGenericDropDown,
};