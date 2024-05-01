---@class ns
local ns = select(2, ...)

-------------------------------
--#region Generic Popups
-------------------------------

local function standardNonEmptyTextHandler(self)
	local parent = self:GetParent();
	parent.button1:SetEnabled(strtrim(parent.editBox:GetText()) ~= "");
end

local function standardEditBoxOnEscapePressed(self)
	self:GetParent():Hide();
end

StaticPopupDialogs["KINESIS_GENERIC_INPUT_BOX"] = {
	text = "", -- supplied dynamically.
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
	end,
	OnAccept = function(self, data)
		if not data then return end
		local text = self.editBox:GetText();
		data.callback(text);
	end,
	OnCancel = function(self, data)
		if not data then return end
		local cancelCallback = data.cancelCallback;
		if type(cancelCallback) == "function" then
			cancelCallback();
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
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
};

---@class GenericInputCustomData
---@field text string the text for the confirmation
---@field text_arg1 string formatted into text if provided
---@field text_arg2 string formatted into text if provided
---@field callback fun(text: string) the callback when the player accepts
---@field cancelCallback fun() the callback when the player cancels / not called on accept
---@field acceptText string custom text for the accept button
---@field cancelText string custom text for the cancel button
---@field maxLetters integer the maximum text length that can be entered
---@field countInvisibleLetters boolean used in tandem with maxLetters
---@field inputText string default text for the input box

---@param customData GenericInputCustomData
---@param insertedFrame frame?
local function showCustomGenericInputBox(customData, insertedFrame)
	StaticPopup_Show("KINESIS_GENERIC_INPUT_BOX", nil, nil, customData, insertedFrame);
end

StaticPopupDialogs["KINESIS_GENERIC_CONFIRMATION"] = {
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
	OnAccept = function(self, data)
		if not data then return end
		if data.callback then
			data.callback();
		end
	end,
	OnCancel = function(self, data)
		if not data then return end
		local cancelCallback = data.cancelCallback;
		if type(cancelCallback) == "function" then
			cancelCallback();
		end
	end,
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
	if customData.cancelText == false then
		StaticPopupDialogs["KINESIS_GENERIC_CONFIRMATION"].button2 = nil
		StaticPopup_Show("KINESIS_GENERIC_CONFIRMATION", nil, nil, customData, insertedFrame);
		StaticPopupDialogs["KINESIS_GENERIC_CONFIRMATION"].button2 = ""
	else
		StaticPopup_Show("KINESIS_GENERIC_CONFIRMATION", nil, nil, customData, insertedFrame);
	end
end

---@param text string the text for the confirmation
---@param callback fun()? the callback when the player accepts
---@param insertedFrame frame?
local function showGenericConfirmation(text, callback, insertedFrame)
	local data = { text = text, callback = callback, };
	showCustomGenericConfirmation(data, insertedFrame);
end

-------------------------------
--#endregion
-------------------------------

-------------------------------
--#region Profile Dialog
-------------------------------

local function profileNonEmptyTextHandler(self)
	local parent = self:GetParent();
	local text = strtrim(parent.editBox:GetText())
	if text == "Default" then text = "default" end
	parent.button1:SetEnabled((text ~= "" and not KinesisOptions.profiles[text]));
	parent.button1:SetText(KinesisOptions.profiles[text] and "Already in Use" or ACCEPT)
end

StaticPopupDialogs["KINESIS_NEW_PROFILE"] = {
	text = "Create New Kinesis Profile:",
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 36,
	OnAccept = function(self)
		local text = self.editBox:GetText();
		ns.Main.createNewProfile(text);
	end,
	EditBoxOnEnterPressed = function(self)
		local text = self:GetText();
		if text == "Default" then text = "default" end
		if text ~= "" and not KinesisOptions.profiles[text] then
			ns.Main.createNewProfile(text)
			self:GetParent():Hide();
		end
	end,
	EditBoxOnEscapePressed = function(self)
		self:GetParent():Hide();
	end,
	OnShow = function(self)
		self.editBox:SetFocus();
	end,
	OnHide = function(self)
		ChatEdit_FocusActiveWindow();
		self.editBox:SetText("");
	end,
	EditBoxOnTextChanged = profileNonEmptyTextHandler,
	timeout = 0,
	cancels = true,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1,
	enterClicksFirstButton = true,
};
local function showNewProfilePopup()
	StaticPopup_Show("KINESIS_NEW_PROFILE")
end

-------------------------------
--#endregion
-------------------------------

-------------------------------
--#region Hyperlink Copy Dialog
-------------------------------

local HyperLinkCopyDialogName = "HTMLUTILS_HYPERLINK_COPYBOX" -- Rename this if you want to hook into your own popup dialog, otherwise this will use a default one
if not StaticPopupDialogs[HyperLinkCopyDialogName] then
	StaticPopupDialogs[HyperLinkCopyDialogName] = {
		text = "%s",
		button1 = CLOSE,
		OnAccept = function(self)
			self.editBox:SetText("")
		end,
		hasEditBox = true,
		timeout = 0,
		cancels = HyperLinkCopyDialogName,
		whileDead = true,
		hideOnEscape = true,
		preferredIndex = 3,
	}
end

local function copyLink(link)
	local popup = StaticPopup_Show(HyperLinkCopyDialogName, link);
	local width = max(popup.text:GetStringWidth(), 100)
	width = min((GetScreenWidth() * .8), width) -- clamp to 80% screen width so it's not obnoxiously large..
	popup.editBox:SetWidth(width);
	popup:SetWidth(width + 50)
	popup.text:SetText(BROWSER_COPY_LINK)
	popup.editBox:SetText(link)
	popup.editBox:SetFocus()
	popup.editBox:HighlightText()
end

-------------------------------
--#endregion
-------------------------------

ns.Dialogs = {
	showCustomGenericInputBox = showCustomGenericInputBox,
	showCustomGenericConfirmation = showCustomGenericConfirmation,
	showGenericConfirmation = showGenericConfirmation,
	showNewProfilePopup = showNewProfilePopup,
	copyLink = copyLink,
}
