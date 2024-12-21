---@class ns
local ns = select(2, ...)

local Cmd = ns.Cmd
local Execute = ns.Actions.Execute
local Logging = ns.Logging
local Permissions = ns.Permissions
local Vault = ns.Vault

local HTML = ns.Utils.HTML

local cmdWithDotCheck = Cmd.cmdWithDotCheck
local cmd = Cmd.cmd
local runMacroText = Cmd.runMacroText
local cprint, dprint, eprint = Logging.cprint, Logging.dprint, Logging.eprint
local executePhaseSpell = Execute.executePhaseSpell
local isDMEnabled = Permissions.isDMEnabled
local phaseVault = Vault.phase

local CloseGossip = CloseGossip or C_GossipInfo.CloseGossip;
local GetNumGossipOptions = GetNumGossipOptions or C_GossipInfo.GetNumOptions;
local SelectGossipOption = SelectGossipOption or C_GossipInfo.SelectOption;
local GetGossipText = GetGossipText or C_GossipInfo.GetText;

local modifiedGossips = {}
local isGossipLoaded

local spellsToCast = {}
local shouldAutoHide = false
local shouldLoadSpellVault = false
local loadPhaseVault

local gossipScript
local gossipTags

-- Closure Util to generate prefab functions with embedded args
local f = function(f, ...)
	local args = { ... }
	local numArgs = select("#", ...)
	return function()
		f(unpack(args, 1, numArgs))
	end
end

local function onGossipShow()
	isGossipLoaded = true
end

local function onGossipClosed()
	isGossipLoaded = false
end

local function isLoaded()
	return isGossipLoaded
end

local function hideCheck(button)
	if button then -- came from an OnClick, so we need to close now, instead of toggling AutoHide which already past.
		CloseGossip();
		return true
	else
		shouldAutoHide = true
		return false
	end
end

local function CallbackClosure(func, ...)
	if type(func) ~= "function" then error("newCallback arg #1 must be a function") end
	local args = { ... }
	local numArgs = select("#", ...)
	return function() func(unpack(args, numArgs)) end
end

local function cast(id, trig, self, revert)
	if trig == nil then trig = true end
	if self == nil then self = true end
	cmd(("cast %s %s %s"):format(id, (trig and "triggered" or ""), (self and "self" or "")))

	if revert then
		C_Timer.After(tonumber(revert) or 0.25, CallbackClosure(cmd, "unaura " .. id .. " self"))
	end
end

---@class CastSpellData
---@field [1] number SpellID
---@field [2] boolean? triggered
---@field [3] boolean? self
---@field [4] boolean|number? revert (true, false, or a number to specify the revert time)

---@alias TeleVisual CastSpellData[]

---@type TeleVisual[]
local teleVisuals = {
	{ -- Classic
		delay = 0.8,
		{ 41232 },
	},
	{ -- Bastion
		{ 367049 },
		{ 364475, false, false },
	},
	{ -- Arcane
		-- 361504,361505,355673,367731
		{ 361504 },
		{ 361505 },
	},
	{ -- Holy
		{ 253303, nil, nil, true }
		--317142
	}
}

local function tele(comm, visualID)
	visualID = tonumber(visualID)
	if not visualID then visualID = 1 end

	for _, v in ipairs(teleVisuals[visualID]) do
		cast(v[1], v[2], v[3], v[4])
	end

	local delay = teleVisuals[visualID].delay or 1

	C_Timer.After(delay, CallbackClosure(cmd, comm))
end

---@param callbacks { openArcanum: fun(), saveToPersonal: fun(phaseVaultIndex: integer, sendLearnedMessage: boolean), loadPhaseVault: fun(callback: fun()) }
local function init(callbacks)
	loadPhaseVault = callbacks.loadPhaseVault

	-- gossipScript functions are passed the 'payload' / matched text from a tag, along with the 'button' clicked if it was a button, or nil if it was auto / from the gossip main text ('greetingText')
	gossipScript = {
		show = callbacks.openArcanum,
		auto_cast = function(payLoad)
			table.insert(spellsToCast, payLoad)
			dprint("Adding AutoCast from Gossip: '" .. payLoad .. "'.")
		end,
		click_cast = function(payLoad)
			if phaseVault.isSavingOrLoadingAddonData then
				eprint("Phase Vault was still loading. Casting when loaded..!")
				table.insert(spellsToCast, payLoad)
				return
			end
			executePhaseSpell(payLoad)
		end,
		save = function(payLoad)
			if phaseVault.isSavingOrLoadingAddonData then
				eprint("Phase Vault was still loading. Please try again in a moment."); return;
			end
			dprint("Scanning Phase Vault for Spell to Save: " .. payLoad)

			local index = Vault.phase.findSpellIndexByID(payLoad)
			if index ~= nil then
				dprint("Found & Saving Spell '" .. payLoad .. "' (" .. index .. ") to your Personal Vault.")
				callbacks.saveToPersonal(index, true)
			end
		end,
		copy = function(payLoad)
			HTML.copyLink(nil, payLoad)
		end,
		cmd = function(payLoad)
			cmdWithDotCheck(payLoad)
		end,
		tele = function(payLoad)
			local loc, visual = strsplit(":", payLoad, 2)
			CloseGossip() -- Teleports have a forced close always
			tele("tele " .. loc, visual)
		end,
		ptele = function(payLoad)
			local loc, visual = strsplit(":", payLoad, 2)
			CloseGossip() -- Teleports have a forced close always
			tele("phase tele " .. loc, visual)
		end,
		hide = CloseGossip,
		hide_check = hideCheck, -- Unused? I don't think we need to worry about this any more, as auto-runs are still run after parsing the entire text.
	}

	gossipTags = {
		default = "<arc[anum]-_.->",
		capture = "<arc[anum]-_(.-)>",
		dm = "<arc-DM :: ",
		option = {                                          -- note, the tag field is pointless, I changed it to tags are the table key, but kept for readability
			show = { tag = "show", script = gossipScript.show },
			toggle = { tag = "toggle", script = gossipScript.show }, -- kept for back-compatibility, but undocumented. They should use Show now.
			cast = { tag = "cast", script = gossipScript.click_cast },
			save = { tag = "save", script = gossipScript.save },
			cmd = { tag = "cmd", script = gossipScript.cmd },
			macro = { tag = "macro", script = runMacroText },
			copy = { tag = "copy", script = gossipScript.copy },
			tele = { tag = "tele", script = gossipScript.tele },
			ptele = { tag = "ptele", script = gossipScript.ptele },
		},
		extensions = {
			{ ext = "hide", script = gossipScript.hide },
			-- auto is officially deprecated. Use greeting text. For a gob tele, use an auto-spark.
		},
	}

	-- NEW GOSSIP SECTION:

	local arc_tag_predicate = function(text)
		return (text and text:find(gossipTags.default))
	end

	local arc_tag_filter = function(text)
		if isDMEnabled() then
			text = text:gsub(gossipTags.capture, gossipTags.dm .. "%1>")
		else
			text = text:gsub(gossipTags.default, "")
		end
		return text
	end

	local option_callback = function(self, button, down, originalText)
		local main_funcs = {}
		local ext_funcs = {}

		for payload in originalText:gmatch(gossipTags.capture) do
			local strTag, strArg = strsplit(":", payload, 2) -- split the tag from the data
			local mainTag, extTags = strsplit("_", strTag, 2) -- split the main tag from the extension tags
			if gossipTags.option[mainTag] then       -- Checking Main Tags & Running their code if present
				--gossipTags.body[mainTag].script(strArg)
				table.insert(main_funcs, f(gossipTags.option[mainTag].script, strArg, button))
			end
			dprint("Clicked Option with ArcTag | Tag: " ..
				mainTag .. " | Spell: " .. (strArg or "none") .. " | Ext: " .. (tostring(extTags) or "none"))

			if extTags then
				for _, v in ipairs(gossipTags.extensions) do -- Checking for any tag extensions
					if extTags:match(v.ext) then
						--v.script()
						table.insert(ext_funcs, v.script)
					end
				end
			end
		end

		local function runCallbacks()
			for i = 1, #ext_funcs do
				ext_funcs[i](button)
			end
			for i = 1, #main_funcs do
				main_funcs[i](button)
			end

			if shouldAutoHide then
				CloseGossip()
			end
			shouldAutoHide = false
		end

		if phaseVault.isLoaded then
			runCallbacks()
		else
			loadPhaseVault(runCallbacks)
		end
	end

	local function greeting_callback(text, isReload)
		if isReload then
			dprint("Gossip Reload of Same Page - Auto Functions Skipped.")
			return
		end
		if isDMEnabled() then
			dprint("DM Enabled - Auto Gossip Greeting Tags Skipped.")
			return
		end
		option_callback(nil, nil, nil, text)
	end

	EpsilonLib.Utils.Gossip:RegisterGreetingHook(arc_tag_predicate, greeting_callback, arc_tag_filter)
	EpsilonLib.Utils.Gossip:RegisterButtonHook(arc_tag_predicate, option_callback, arc_tag_filter)
end

ns.Gossip = {
	init = init,
	onGossipShow = onGossipShow,
	onGossipClosed = onGossipClosed,
	isLoaded = isLoaded,
}
