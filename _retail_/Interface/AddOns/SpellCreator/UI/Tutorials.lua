---@class ns
local ns = select(2, ...)

local addonName = ...

local Constants = ns.Constants
local ASSETS_PATH = Constants.ASSETS_PATH
local Tooltip = ns.Utils.Tooltip

local function getTex(tex) return (ASSETS_PATH .. "/" .. tex) end

local Logging = ns.Logging
local cprint = Logging.cprint

local Tutorials = {}
LibStub("CustomTutorials-2.1e"):Embed(Tutorials)

local arcTutorialTitle = "Arcanum - Basic Spell Tutorial"
local arcTutorialTitlePageFormat = "(%s / %s)"
local maxSteps = 13
local curStep = 0
local function autoTitle()
	curStep = curStep + 1
	return arcTutorialTitle .. " " .. arcTutorialTitlePageFormat:format(curStep, maxSteps)
end

local function formatTutorialText(text)
	-- replace < > text with contrast text; support for a few colors also for simplicity
	text = string.gsub(text, "<c:a:(.-)>", function(m) return Constants.ADDON_COLORS.ADDON_COLOR:WrapTextInColorCode(m) end)
	text = string.gsub(text, "<c:b:(.-)>", function(m) return Constants.ADDON_COLORS.MID_CYAN:WrapTextInColorCode(m) end)
	text = string.gsub(text, "<c:lb:(.-)>", function(m) return Constants.ADDON_COLORS.LIGHT_BLUE:WrapTextInColorCode(m) end)
	text = string.gsub(text, "<c:g:(.-)>", function(m) return Constants.ADDON_COLORS.GAME_GOLD:WrapTextInColorCode(m) end)
	text = string.gsub(text, "<c:r:(.-)>", function(m) return Constants.ADDON_COLORS.TOOLTIP_WARNINGRED:WrapTextInColorCode(m) end)
	text = string.gsub(text, "<c:gr:(.-)>", function(m) return Constants.ADDON_COLORS.TOOLTIP_EXAMPLE:WrapTextInColorCode(m) end)
	text = string.gsub(text, "<(.-)>", function(m) return Tooltip.genContrastText(m) end)

	return text
end
local _t = formatTutorialText

local arcTutorialFrame
function Tutorials:OnLoad()
	arcTutorialFrame = self:RegisterTutorials({
		title = "Arcanum - Forge Tutorial",
		savedvariable = SpellCreatorMasterTable,
		key = 'Tutorial',
		bg = getTex("frame_bg_fractalengraving"),

		{ -- 1
			title = autoTitle(),
			image = getTex("arc_logo_web"),
			imageH = 256 * 0.6,
			imageW = 512 * 0.6,
			text = _t([[

Welcome to Arcanum!

It looks like this is your first time using Arcanum. Would you like to start the tutorial to learn the basics?
]]),
			startHook = {
				frame = SpellCreatorMinimapButton,
				hookScript = "OnClick",
				condition = function()
					if Tutorials:GetLastUnlockedTutorial() < 1 and #ns.Vault.personal.getIDs() < 1 then
						return true
					end
				end
			},
			button1 = {
				text = "No thanks!",
				callback = function(self, frame, ...) Tutorials:HideTutorial() end,
			},
			button2 = {
				text = "Let's do it!",
				callback = function(self, frame, ...) Tutorials:Next() end,
			},
		},
		{ -- 2
			title = autoTitle(),
			image = getTex("tut_img_" .. curStep),
			imageY = 50,
			text = _t([[
Welcome to the Arcanum - Basic Spell Creation Tutorial!

This tutorial will guide you in creating a simple starter spell using the Spell Forge.

Watch for glowing highlights to help you find the referenced areas.

For most steps in the tutorial, completing the instructions will auto-progress to the next step; otherwise click <c:g:Continue> at the bottom.

Click the <c:a:Arcanum> icon (%s) on your mini-map to open the Forge UI, or click <c:g:Continue> below if already open.
]]):format(CreateTextureMarkup(ns.UI.Gems.gemPath("Violet"), 16, 16, 20, 20, 0, 1, 0, 1)),
			flash = SpellCreatorMinimapButton.Flash,
			button1 = { text = "Continue", callback = function() Tutorials:Next() end, shown = function() return SCForgeMainFrame:IsShown() end },
			continueHook = { frame = SCForgeMainFrame, hookScript = "OnShow" }
		},
		{ -- 3
			title = autoTitle(),
			image = getTex("tut_img_" .. curStep),
			imageY = 50,
			text = _t([[
This is the Forge UI - The main interface for creating & editing ArcSpells.

For this tutorial, we'll create a simple spell to stack lightning buffs until it explodes, highlighting the basics of spell creation, including Actions, Reverts, and Conditions.

Start by naming your spell and setting an ArcSpell ID in the top section of the Forge (called the 'Attic').

• The name can be anything, like <c:lb:Building Storm>.
• The ArcSpell ID must be unique, and can only contain letters, numbers, and _.

Use <stacklightning> as the ArcID for this tutorial.
]]),
			shine = SCForgeMainFrame.SpellInfoNameBox,
			shineRight = SCForgeMainFrame.SpellInfoCommandBox:GetWidth() + 16,
			shineBottom = -6,
			shineTop = 6,
			shineLeft = -16,
			button1 = { text = "Continue", callback = function() Tutorials:Next() end, enabled = function() return (#SCForgeMainFrame.SpellInfoNameBox:GetText() > 1 and SCForgeMainFrame.SpellInfoCommandBox:GetText() == "stacklightning") end },
			continue = function() if #SCForgeMainFrame.SpellInfoNameBox:GetText() > 1 and SCForgeMainFrame.SpellInfoCommandBox:GetText() == "stacklightning" then return true end end,
		},
		{ -- 4
			title = autoTitle(),
			image = getTex("tut_img_" .. curStep),
			imageY = 50,
			text = _t([[
Next, we need to set up the actual Actions.

Actions define what the spell does when cast. Each action requires:

• A delay (set to 0 if none is needed).
• An action type.
• Input details (if applicable).

For the first action, we'll use 'Cast Spell' with 0 delay:

1. Enter 0 in the <c:g:Delay> field of the first row.

2. Open the <c:g:Action> dropdown and select <c:b:Cast> -> <c:b:Cast Spell>.

3. Check the <c:g:Self> box to cast the spell on yourself (note: not all actions support 'Self').
]]),
			shine = SCForgeMainFrame.spellRows[1],
			shineBottom = -4,
			shineTop = 3,
			shineLeft = -6,
			shineRight = -SCForgeMainFrame.spellRows[1]:GetWidth() * (0.54),
			continue = function()
				if SCForgeMainFrame.spellRows[1]
					and SCForgeMainFrame.spellRows[1].mainDelayBox:GetText() == "0"
					and SCForgeMainFrame.spellRows[1].SelectedAction == "SpellCast"
					and SCForgeMainFrame.spellRows[1].SelfCheckbox:GetChecked()
				then
					return true
				end
			end,
			button1 = {
				text = "Continue",
				callback = function() Tutorials:Next() end,
				enabled = function()
					if SCForgeMainFrame.spellRows[1]
						and SCForgeMainFrame.spellRows[1].mainDelayBox:GetText() == "0"
						and SCForgeMainFrame.spellRows[1].SelectedAction == "SpellCast"
						and SCForgeMainFrame.spellRows[1].SelfCheckbox:GetChecked()
					then
						return true
					end
				end
			},
		},
		{ -- 5
			title = autoTitle(),
			image = getTex("tut_img_" .. curStep),
			imageY = 50,
			text = _t([[
With the action set to 'Cast Spell,' we now need to specify which spell to use.

For this tutorial, we'll use a simple stacking lightning buff spell.

Enter <215632> into the <c:g:Input> editbox of the first action.
]]),
			shine = SCForgeMainFrame.spellRows[1].InputEntryScrollFrame or SCForgeMainFrame.spellRows[1].InputEntryBox,
			shineBottom = -12,
			shineTop = 12,
			shineLeft = -12,
			shineRight = 12,
			continue = function()
				if SCForgeMainFrame.spellRows[1]
					and SCForgeMainFrame.spellRows[1].InputEntryBox:GetText() == "215632"
				then
					return true
				end
			end,
			button1 = {
				text = "Continue",
				callback = function() Tutorials:Next() end,
				enabled = function()
					if SCForgeMainFrame.spellRows[1]
						and SCForgeMainFrame.spellRows[1].InputEntryBox:GetText() == "215632"
					then
						return true
					end
				end
			},
		},
		{ -- 6
			title = autoTitle(),
			image = getTex("tut_img_" .. curStep),
			imageY = 50,
			text = _t([[
Great! You've set up your first action. You can test it now by clicking the <c:g:Cast> button at the bottom of the Forge (the 'Basement').

Next, let's add more flare by making the lightning 'explode' after stacking enough charges.

In the 2nd Action Row:
• Set a <c:g:Delay> of <0.5> (seconds).
• Open the <c:g:Action> dropdown menu & select <c:b:Cast> -> <c:b:Cast Spell (Trig)> as the action type
• Enable the <c:g:Self> checkbox.
• Enter the following as the <c:g:Input> exactly: <218963, 136490, 233442, 265673, 215632>.

By using multiple ID's in this input, the action will cast all of these spells at the same time, to create a lightning 'explosion' effect.

Tip: Use 'Copy Input' below to copy the input to your clipboard and paste it into the input field.
]]),
			shine = SCForgeMainFrame.spellRows[2],
			shineBottom = -4,
			shineTop = 3,
			shineLeft = -6,
			shineRight = -4,
			button1 = {
				text = "Copy Input",
				callback = function()
					C_Epsilon.RunPrivileged("CopyToClipboard('218963, 136490, 233442, 265673, 215632')")
					print(Constants.ADDON_COLORS.ADDON_COLOR:WrapTextInColorCode("Copied!"))
				end
			},
			button2 = {
				text = "Continue",
				callback = function() Tutorials:Next() end,
				enabled = function()
					if SCForgeMainFrame.spellRows[2]
						and SCForgeMainFrame.spellRows[2].mainDelayBox:GetText() == "0.5"
						and SCForgeMainFrame.spellRows[2].SelectedAction == "SpellTrig"
						and SCForgeMainFrame.spellRows[2].SelfCheckbox:GetChecked()
						and SCForgeMainFrame.spellRows[2].InputEntryBox:GetText() == "218963, 136490, 233442, 265673, 215632"
					then
						return true
					end
				end
			},
			continue = function()
				if SCForgeMainFrame.spellRows[2]
					and SCForgeMainFrame.spellRows[2].mainDelayBox:GetText() == "0.5"
					and SCForgeMainFrame.spellRows[2].SelectedAction == "SpellTrig"
					and SCForgeMainFrame.spellRows[2].SelfCheckbox:GetChecked()
					and SCForgeMainFrame.spellRows[2].InputEntryBox:GetText() == "218963, 136490, 233442, 265673, 215632"
				then
					return true
				end
			end,
		},
		{ -- 7
			title = autoTitle(),
			image = getTex("tut_img_" .. curStep),
			imageY = 50,
			text = _t([[
Actions can be reverted using the <c:g:Revert> column. Adding a delay here causes the action to 'undo' itself after the set time.

For our tutorial, we want these spells to unaura quickly after being cast.

• Set the <c:g:Revert> delay to <0.25> (seconds).

This ensures enough time for the server to process adding and removing the spells, preventing them from getting stuck.
]]),
			shine = SCForgeMainFrame.spellRows[2].RevertDelayBox,
			shineBottom = -10,
			shineTop = 10,
			shineLeft = -14,
			shineRight = 12,
			continue = function()
				if SCForgeMainFrame.spellRows[2]
					and SCForgeMainFrame.spellRows[2].RevertDelayBox:GetText() == "0.25"
				then
					return true
				end
			end,
			button1 = {
				text = "Continue",
				callback = function() Tutorials:Next() end,
				enabled = function()
					if SCForgeMainFrame.spellRows[2]
						and SCForgeMainFrame.spellRows[2].RevertDelayBox:GetText() == "0.25"
					then
						return true
					end
				end
			},
		},
		{ -- 8
			title = autoTitle(),
			image = getTex("tut_img_" .. curStep),
			imageY = 50,
			text = _t([[
Now that we've created the explosion effect, we need to limit it to trigger only when enough stacks are built up. This is done using <c:g:Conditions>.

Conditions are set in the '<c:g:If>' column and determine whether an action runs based on specific criteria.

To add conditions to your explosion action, click the conditions button (%s) on the right side of that row.
]]):format(CreateTextureMarkup(ASSETS_PATH .. "/" .. "ConditionsButtonGreyed", 16, 16, 20, 20, 0, 1, 0, 1)),
			shine = SCForgeMainFrame.spellRows[2].ConditionalButton,
			shineBottom = -12,
			shineTop = 12,
			shineLeft = -12,
			shineRight = 12,
			continueHook = { frame = SCForgeMainFrame.spellRows[2].ConditionalButton, hookScript = "OnClick" },
		},
		{ -- 9
			title = autoTitle(),
			image = getTex("tut_img_" .. curStep),
			imageY = 50,
			text = _t([[
<c:gr:INFO>:
Actions can have multiple conditions arranged in groups to allow both '<c:lb:and>' & '<c:lb:or>' logic:

• Click 'Add Condition' to add another <condition> to the same condition <group> ('<c:lb:and>' logic).
• Click the big + button to create a <new group> ('<c:lb:or>' logic).

For simplicity: If any single <condition> in a group fails, the <entire group fails>. If any single <group> passes, the action runs.

You can remove conditions by clicking the red <c:r:x> at the end of a row, and remove groups using the gold <c:g:X> at their top right.


<c:gr:ACTIONS ITEMS>:
For this spell, we'll use a single condition (Note: Steps here cannot be highlighted, so please follow the instructions carefully):

• Open the 'Select a Condition' dropdown & select '<c:b:Spells & Effects>' -> '<c:b:Has Number of Aura (Self)>'.
• Enter <215632, 3, true> as the input and click <c:g:Save Conditions>.

This makes it so that the action only runs if your character has 3 (or more) of the <c:lb:Focused Lightning (215632)> buff.
]]),
			point = "LEFT",
			x = 30,
			continue = function()
				local cdData = SCForgeMainFrame.spellRows[2].conditionsData and SCForgeMainFrame.spellRows[2].conditionsData[1]
				if not cdData then return end
				if cdData and cdData[1] and cdData[1].Type == "hasAuraNum" and cdData[1].Input == "215632, 3, true" then
					return true
				end
			end,
			button1 = {
				text = "Continue",
				callback = function() Tutorials:Next() end,
				enabled = function()
					local cdData = SCForgeMainFrame.spellRows[2].conditionsData and SCForgeMainFrame.spellRows[2].conditionsData[1]
					if not cdData then return end
					if cdData and cdData[1] and cdData[1].Type == "hasAuraNum" and cdData[1].Input == "215632, 3, true" then
						return true
					end
				end
			},
		},
		{ -- 10
			title = autoTitle(),
			image = getTex("tut_img_" .. curStep),
			imageY = 50,
			text = _t([[
Now that we've set up the spell's actions, you'll notice one extra row in the editor that we don't need. Let's remove it.

• Hover over the third row and click the remove button (%s) at the top right of the row to delete it.
]]):format(CreateAtlasMarkup("communities-chat-icon-minus", 20, 20)),
			button1 = { text = "Continue", callback = function() Tutorials:Next() end, shown = function() return not SCForgeMainFrame.spellRows[3]:IsShown() end },
			continue = function()
				if SCForgeMainFrame.spellRows[3] and not SCForgeMainFrame.spellRows[3]:IsShown() then
					return true
				end
			end,
			shine = SCForgeMainFrame.spellRows[3].RemoveSpellRowButton,
			shineBottom = -6,
			shineTop = 6,
			shineLeft = -6,
			shineRight = 6,
		},
		{ -- 11
			title = autoTitle(),
			image = getTex("tut_img_" .. curStep),
			imageY = 50,
			text = _t([[
Now, let's test the spell:

• Click the <c:g:Cast> button to trigger the spell.
• Repeat casting until you have 3 stacks, and watch as the third cast triggers the full power of the spell!


Once you're happy with how it works, it's time to save your spell:

• Click <c:g:Create> to store it in your <c:a:Personal Vault>.
• Note: The Personal Vault is account-wide, but the spell is tagged to the character that created it by default.

After saving, click <c:g:Vault> in the 'Basement' to open the Vault tab, or click <c:g:Continue> below if the Vault is already open.
]]),
			button1 = { text = "Continue", callback = function() Tutorials:Next() end, shown = function() return SCForgeLoadFrame:IsShown() end },
			continueHook = { frame = SCForgeLoadFrame, hookScript = "OnShow" },
		},
		{ -- 12
			title = autoTitle(),
			image = getTex("tut_img_" .. curStep),
			imageY = 50,
			text = _t([[
You can <Right-click> the spell in your vault to access additional options. We won't dive into those right now, but feel free to explore them on your own.

Your vault can be searched using the search bar, or filtered using 'Profiles' (%s).

You can also access your Personal Vault from the Spellbook. This allows you to manage your saved spells in a more traditional manner.

To use your spell in-game, you can:

• Drag the Arc Spell's icon onto your action bar,
• Assign it to an Arc Quickcast Book for even faster casting,
• Add it to a macro using '/arcanum stacklightning'.
]]):format(CreateAtlasMarkup("socialqueuing-icon-group", 20, 20, 0, 0, 1 * 255, 0.8 * 255, 0 * 255)),
			button1 = { text = "Continue", callback = function() Tutorials:Next() end },
		},
		{ -- 13
			title = autoTitle(),
			image = getTex("tut_img_" .. curStep),
			imageY = 50,
			text = _t([[
Congratulations! You've successfully created an Arc Spell and completed this tutorial!

Tips:

• Want to make changes to your spell? Open your Personal Vault and click the %s / edit icon next to the spell.
• This will load the spell into the Forge where you can edit it and save the changes.
]]):format(CreateTextureMarkup(ASSETS_PATH .. "/" .. "icon-edit", 16, 16, 16, 16, 0.2, 0.8, 0.2, 0.85))
		},
	})
end

function Tutorials:Start(id)
	self:StartTutorial(id)
end

function Tutorials:Show(id)
	self:ShowTutorial(id)
end

---Continue the Tutorial, optionally with a forced ID to skip to
---@param id any
function Tutorials:Continue(id)
	if arcTutorialFrame:IsShown() then
		if id then
			self:ShowTutorial(id)
		else
			self:NextTutorial()
		end
	end
end

function Tutorials:Next()
	if arcTutorialFrame:IsShown() then
		self:NextTutorial()
	end
end

ns.Utils.Hooks.HookEvent("ADDON_LOADED", function(self, event, name)
	if name ~= addonName then return end

	C_Timer.After(1, function() Tutorials:OnLoad() end)
end)




---@class UI_Tutorials
ns.UI.Tutorials = Tutorials

-- Add to our API
ARC.TUTORIALS = Tutorials
