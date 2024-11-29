-------------------------------------------------------------------------------
--
-- Book Editing Panel
--
local addonName, ns = ...
local addon_path = "Interface/AddOns/" .. addonName

local filteredList = nil

-------------------------------------------------------------------------------
-- StaticPopupDialogs
--

StaticPopupDialogs["EPSILONBOOK_EDITBOOKTITLE"] = {
	text = "Choose a title for this book:",
	button1 = "Accept",
	button2 = "Cancel",
	OnShow = function(self, data)
		self.editBox:SetText(data)
		self.editBox:HighlightText()
	end,
	OnAccept = function(self, data)
		local text = tostring(self.editBox:GetText()) or EpsilonBookFrame.TitleText:GetText();

		if not EpsilonBookFrame.bookData then
			return
		end

		EpsilonBookFrame.bookData.title = text;
		EpsilonBookFrame_Update()
		EpsilonBook_SaveCurrentBook()
	end,
	hasEditBox = true,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	enterClicksFirstButton = true,
	preferredIndex = 3,
}

StaticPopupDialogs["EPSILONBOOK_INSERTPAGELINK"] = {
	text = "Page number:",
	button1 = "Accept",
	button2 = "Cancel",
	OnShow = function(self, data)
		self.editBox:SetText("1")
	end,
	OnAccept = function(self, data)
		local text = tostring(self.editBox:GetText());

		if not EpsilonBookFrame.bookData then
			return
		end

		EpsilonBookEditor_Insert("{link:" .. text .. "}Your Text Here{/link}");
	end,
	hasEditBox = true,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	enterClicksFirstButton = true,
	preferredIndex = 3,
}

StaticPopupDialogs["EPSILONBOOK_INSERTURLLINK"] = {
	text = "Paste your URL below:",
	button1 = "Accept",
	button2 = "Cancel",
	OnAccept = function(self, data)
		local text = tostring(self.editBox:GetText());

		if not EpsilonBookFrame.bookData then
			return
		end

		EpsilonBookEditor_Insert("{url:" .. text .. "}Your Text Here{/url}");
	end,
	hasEditBox = true,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	enterClicksFirstButton = true,
	preferredIndex = 3,
}

StaticPopupDialogs["EPSILONBOOK_INSERTWOWLINK"] = {
	text = "Paste a spellString or itemString below:|n|nExample: spell:192 (where 192 is the spellID).",
	button1 = "Accept",
	button2 = "Cancel",
	OnAccept = function(self, data)
		local text = tostring(self.editBox:GetText());

		if not EpsilonBookFrame.bookData or not (text:find("spell") or text:find("item")) then
			return
		end

		EpsilonBookEditor_Insert("{" .. text .. "}");
	end,
	hasEditBox = true,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	enterClicksFirstButton = true,
	preferredIndex = 3,
}

StaticPopupDialogs["EPSILONBOOK_SHOWPAGELINK"] = {
	text = "Copy the URL and paste in your browser:",
	button1 = "Close",
	OnShow = function(self, data)
		self.editBox:SetText(data)
		self.editBox:HighlightText()
	end,
	OnAccept = function(self)
	end,
	hasEditBox = true,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	enterClicksFirstButton = true,
	preferredIndex = 3,
}

StaticPopupDialogs["EPSILONBOOK_DELETEBOOKPAGE"] = {
	text = "Are you sure you want to delete this page?",
	button1 = "Accept",
	button2 = "Cancel",
	OnAccept = function(self, data)
		tremove(EpsilonBookFrame.bookData.pages, EpsilonBookFrame.currentPage)
		EpsilonBookFrame.currentPage = 1
		EpsilonBookFrame_Update()
		EpsilonBook_SaveCurrentBook()
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
}

StaticPopupDialogs["EPSILONBOOK_DELETEBOOK"] = {
	text = "Are you sure you want to delete this book?|n|nOnce deleted, a book cannot be recovered!",
	button1 = "Accept",
	button2 = "Cancel",
	OnAccept = function(self, data)
		EpsilonBook_DeleteBook(data);
	end,
	timeout = 0,
	showAlert = true,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
}

StaticPopupDialogs["EPSILONBOOK_ADDGOSSIPOPTIONTONPC"] = {
	text = "Enter Gossip Text:",
	button1 = "Accept",
	button2 = "Cancel",
	OnShow = function(self, data)
		self.editBox:SetText("");
		self.editBox:HighlightText();
	end,
	OnAccept = function(self, data)
		local text = self.editBox:GetText();
		EpsilonBook_AddBookToNPCGossip(text, data);
	end,
	hasEditBox = true,
	timeout = 0,
	showAlert = true,
	whileDead = true,
	hideOnEscape = true,
	enterClicksFirstButton = true,
	preferredIndex = 3,
}

StaticPopupDialogs["EPSILONBOOK_TURNNPCINTOBOOK"] = {
	text = "Are you sure you want to turn this NPC into a book?|n|nThis will suppress other gossip features and make them unavailable on this NPC.",
	button1 = "Accept",
	button2 = "Cancel",
	OnAccept = function(self, data)
		EpsilonBook_TurnNPCIntoBook(data);
	end,
	timeout = 0,
	showAlert = true,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
}

StaticPopupDialogs["EPSILONBOOK_LINKITEMTOBOOK"] = {
	text = "Enter the itemID:|n|nNote: Players must be currently in the phase in which the book was created to read it!",
	button1 = "Accept",
	button2 = "Cancel",
	OnShow = function(self, data)
		self.editBox:SetText("");
		self.editBox:HighlightText();
	end,
	OnAccept = function(self, data)
		local itemID = self.editBox:GetText();
		EpsilonBook_LinkItemToBook(itemID, data);
	end,
	hasEditBox = true,
	timeout = 0,
	showAlert = true,
	whileDead = true,
	hideOnEscape = true,
	enterClicksFirstButton = true,
	preferredIndex = 3,
}

-------------------------------------------------------------------------------
-- BBCode to HTML converter
--

-- Return an texture text tag based on the given image url and size.
local function GetTextureTag(iconPath, iconSize)
	if not iconPath then
		return
	end

	iconSize = iconSize or 16;
	return strconcat("|T", iconPath, ":", iconSize, ":", iconSize, "|t");
end

-- Return an texture text tag based on the given icon url and size. Nil safe.
local function GetIconTag(iconPath, iconSize)
	iconPath = iconPath or "Interface/Icons/inv_misc_questionmark";
	return GetTextureTag(iconPath, iconSize);
end

local directReplacements = {
	["/color"] = "|r",
	["/colour"] = "|r",
	["rule"] = "|n|TInterface/COMMON/UI-TooltipDivider:4:250|t|n",
};

local function convertTextTag(tag)
	if directReplacements[tag] then             -- Direct replacement
		return directReplacements[tag];
	elseif tag:match("^color:%x%x%x%x%x%x$") then -- Hexa color replacement
		return "|cff" .. tag:match("^color:(%x%x%x%x%x%x)$");
	elseif tag:match("^colour:%x%x%x%x%x%x$") then -- Hexa color replacement
		return "|cff" .. tag:match("^colour:(%x%x%x%x%x%x)$");
	elseif tag:match("^icon%:[^:]+%:%d+$") then -- Icon
		local icon, size = tag:match("^icon%:([^:]+)%:(%d+)$");
		return GetIconTag(icon, size);
	end

	return "{" .. tag .. "}";
end

local function convertTextTags(text)
	if text then
		text = text:gsub("%{(.-)%}", convertTextTag);
		return text;
	end
end

local escapedHTMLCharacters = {
	["<"] = "&lt;",
	[">"] = "&gt;",
	["\""] = "&quot;",
};

local structureTags = {
	["{h(%d)}"] = "<h%1>",
	["{h(%d):l}"] = "<h%1 align=\"left\">",
	["{h(%d):c}"] = "<h%1 align=\"center\">",
	["{h(%d):r}"] = "<h%1 align=\"right\">",
	["{/h(%d)}"] = "</h%1>",

	["{p}"] = "<P>",
	["{p:l}"] = "<P align=\"left\">",
	["{p:c}"] = "<P align=\"center\">",
	["{p:r}"] = "<P align=\"right\">",
	["{/p}"] = "</P>",
};

--- alignmentAttributes is a conversion table for taking a single-character
--  alignment specifier and getting a value suitable for use in the HTML
--  "align" attribute.
local alignmentAttributes = {
	["c"] = "center",
	["l"] = "left",
	["r"] = "right",
};

--- IMAGE_PATTERN is the string pattern used for performing image replacements
--  in strings that should be rendered as HTML.
---
--- The accepted form this is "{img:<src>:<width>:<height>[:align]}".
---
--- Each individual segment matches up to the next present colon. The third
--- match (height) and everything thereafter needs to check up-to the next
--- colon -or- ending bracket since they could be the final segment.
---
--- Optional segments should of course have the "?" modifer attached to
--- their preceeding colon, and should use * for the content match rather
--- than +.
local IMAGE_PATTERN = [[{img%:([^:]+)%:([^:]+)%:([^:}]+)%:?([^:}]*)%}]];

--- Note that the image tag has to be outside a <P> tag.
---@language HTML
local IMAGE_TAG = [[</P><img src="%s" width="%s" height="%s" align="%s"/><P>]];

local function FormatLink(type, url, text)
	if type == "spell" then
		text = GetSpellLink(url);
	elseif type == "item" then
		_, text = GetItemInfo(url);
	end

	return string.format([[<a href="%1$s:%2$s">%3$s</a>]], type, url, text or "");
end

-- Convert the given text by his HTML representation
local toHTML = function(text, noColor, noBrackets)
	-- 1) Replacement : & character
	text = text:gsub("&", "&amp;");

	-- 2) Replacement : escape HTML characters
	for pattern, replacement in pairs(escapedHTMLCharacters) do
		text = text:gsub(pattern, replacement);
	end

	-- 3) Replace Markdown
	local titleFunction = function(titleChars, title)
		local titleLevel = #titleChars;
		return "\n<h" .. titleLevel .. ">" .. strtrim(title) .. "</h" .. titleLevel .. ">";
	end;

	text = text:gsub("^(#+)(.-)\n", titleFunction);
	text = text:gsub("\n(#+)(.-)\n", titleFunction);
	text = text:gsub("\n(#+)(.-)$", titleFunction);
	text = text:gsub("^(#+)(.-)$", titleFunction);

	-- 4) Replacement : text tags
	for pattern, replacement in pairs(structureTags) do
		text = text:gsub(pattern, replacement);
	end

	local tab = {};
	local i = 1;
	while text:find("<") and i < 500 do
		local before;
		before = text:sub(1, text:find("<") - 1);
		if #before > 0 then
			tinsert(tab, before);
		end

		local tagText;

		local tag = text:match("</(.-)>");
		if tag then
			tagText = text:sub(text:find("<"), text:find("</") + #tag + 2);
			if #tagText == #tag + 3 then
				return
			end
			tinsert(tab, tagText);
		else
			return
		end

		local after;
		after = text:sub(#before + #tagText + 1);
		text = after;

		--- 	Log.log("Iteration "..i);
		--- 	Log.log("before ("..(#before).."): "..before);
		--- 	Log.log("tagText ("..(#tagText).."): "..tagText);
		--- 	Log.log("after ("..(#before).."): "..after);

		i = i + 1;
		if i == 500 then
			break;
		end
	end
	if #text > 0 then
		tinsert(tab, text); -- Rest of the text
	end

	--- log("Parts count "..(#tab));

	local finalText = "";
	for _, line in pairs(tab) do
		if not line:find("<") then
			line = "<P>" .. line .. "</P>";
		end
		line = line:gsub("\n", "<br/>");

		-- Image tag. Specifiers after the height are optional, so they
		-- must be suitably defaulted and validated.
		line = line:gsub(IMAGE_PATTERN, function(img, width, height, align)
			-- If you've not given an alignment, or it's entirely invalid,
			-- you'll get the old default of center.
			align = alignmentAttributes[align] or "center";

			-- Don't blow up on non-numeric inputs. They won't display properly
			-- but that's a separate issue.
			width = tonumber(width) or 128;
			height = tonumber(height) or 128;

			-- Width and height should be absolute.
			-- The tag accepts negative value but people used that to fuck up their profiles
			return string.format(IMAGE_TAG, img, math.abs(width), math.abs(height), align);
		end);

		line = line:gsub("%!%[(.-)%]%((.-)%)", function(icon, size)
			if icon:find("\\") then
				-- If icon text contains \ we have a full texture path
				local width, height;
				if size:find("%,") then
					width, height = strsplit(",", size);
				else
					width = tonumber(size) or 128;
					height = width;
				end
				-- Width and height should be absolute.
				-- The tag accepts negative value but people used that to fuck up their profiles
				return string.format(IMAGE_TAG, icon, math.abs(width), math.abs(height), "center");
			end
			return GetIconTag(icon, tonumber(size) or 25);
		end);

		do -- Link tags
			line = line:gsub("{(link):([^}]+)}([^{]+){/link}", FormatLink);
			line = line:gsub("{(url):([^}]+)}([^{]+){/url}", FormatLink);
			line = line:gsub("{(spell):([^}]+)}", FormatLink);
			line = line:gsub("{(item):([^}]+)}", FormatLink);
		end

		finalText = finalText .. line;
	end

	finalText = convertTextTags(finalText);

	return "<HTML><BODY>" .. finalText .. "</BODY></HTML>";
end

local BOOK_MATERIALS = {
	["Legion"] = {
		["Burning Legion"] = {
			path = "QuestBackgroundBurningLegion",
			type = "custom",
		},
		["Eredar"] = {
			path = "QuestBackgroundEredar",
			type = "custom",
		},
		["Hand of Fate"] = {
			atlas = "QuestBG-TheHandofFate",
			type = "quest",
		},
		["Legionfall"] = {
			atlas = "QuestBG-Legionfall",
			type = "quest",
		},
	},
	["Shadowlands"] = {
		["Shadowlands"] = {
			atlas = "questbg-shadowlands",
			type = "quest",
		},
		["Ardenweald"] = {
			atlas = "questbg-ardenweald",
			type = "quest",
		},
		["Ascended"] = {
			path = "QuestBackgroundShadowlandsBastion",
			type = "custom",
		},
		["Bastion"] = {
			atlas = "questbg-bastion",
			type = "quest",
		},
		["Fae-Touched"] = {
			path = "QuestBackgroundShadowlandsArdenweald",
			type = "custom",
		},
		["Kyrian"] = {
			atlas = "questbg-kyrian",
			type = "quest",
		},
		["Maldraxxus"] = {
			atlas = "questbg-maldraxxus",
			type = "quest",
		},
		["Maw"] = {
			path = "QuestBackgroundShadowlandsMaw",
			type = "custom",
		},
		["Necrolords"] = {
			atlas = "questbg-necrolord",
			type = "quest",
		},
		["Night Fae"] = {
			atlas = "questbg-fey",
			type = "quest",
		},
		["Oribos"] = {
			atlas = "questbg-oribos",
			type = "quest",
		},
		["Revendreth"] = {
			atlas = "questbg-revendreth",
			type = "quest",
		},
		["Risen"] = {
			path = "QuestBackgroundShadowlandsMaldraxxus",
			type = "custom",
		},
		["Tazavesh"] = {
			path = "QuestBackgroundShadowlandsTazavesh",
			type = "custom",
		},
		["Tithed"] = {
			path = "QuestBackgroundShadowlandsRevendreth",
			type = "custom",
		},
		["Venthyr"] = {
			atlas = "questbg-venthyr",
			type = "quest",
		},
		["Zereth Mortis"] = {
			path = "QuestBackgroundShadowlandsZerethMortis",
			type = "custom",
		},
	},
	["Dragonflight"] = {
		["Dragonflight"] = {
			path = "QuestBackgroundDragonflightDragonflight",
			type = "custom",
		},
		["Emerald Dream"] = {
			path = "QuestBackgroundDragonflightEmeraldDream",
			type = "custom",
		},
		["Black Dragonflight"] = {
			path = "QuestBackgroundDragonflightDracthyrAwaken",
			type = "custom",
		},
		["Blue Dragonflight"] = {
			path = "QuestBackgroundDragonflightAzureSpan",
			type = "custom",
		},
		["Bronze Dragonflight"] = {
			path = "QuestBackgroundDragonflightThaldraszus",
			type = "custom",
		},
		["Green Dragonflight"] = {
			path = "QuestBackgroundDragonflightOhnplains",
			type = "custom",
		},
		["Red Dragonflight"] = {
			path = "QuestBackgroundDragonflightWalkingshore",
			type = "custom",
		},
		["Zaralek Cavern"] = {
			path = "QuestBackgroundDragonflightZaralekCavern",
			type = "custom",
		},
	},
	["The War Within"] = {
		["The Assembly of the Deeps"] = {
			path = "QuestBackgroundTheWarWithinCandle",
			type = "custom",
		},
		["Council of Dornogal"] = {
			path = "QuestBackgroundTheWarWithinStorm",
			type = "custom",
		},
		["Hallowfall Arathi"] = {
			path = "QuestBackgroundTheWarWithinFlame",
			type = "custom",
		},
		["The Severed Threads"] = {
			path = "QuestBackgroundTheWarWithinWeb",
			type = "custom",
		},
		["Rocket"] = {
			path = "questbackgroundthewarwithinrocket",
			type = "custom",
		},
	},
	["Professions"] = {
		["Alchemy"] = {
			path = "QuestBackgroundProfessionAlchemy",
			type = "custom",
		},
		["Blacksmithing"] = {
			path = "QuestBackgroundProfessionBlacksmithing",
			type = "custom",
		},
		["Cooking"] = {
			path = "QuestBackgroundProfessionCooking",
			type = "custom",
		},
		["Enchanting"] = {
			path = "QuestBackgroundProfessionEnchanting",
			type = "custom",
		},
		["Engineering"] = {
			path = "QuestBackgroundProfessionEngineering",
			type = "custom",
		},
		["Fishing"] = {
			path = "QuestBackgroundProfessionFishing",
			type = "custom",
		},
		["Herbalism"] = {
			path = "QuestBackgroundProfessionHerbalism",
			type = "custom",
		},
		["Inscription"] = {
			path = "QuestBackgroundProfessionInscription",
			type = "custom",
		},
		["Jewelcrafting"] = {
			path = "QuestBackgroundProfessionJewelcrafting",
			type = "custom",
		},
		["Leatherworking"] = {
			path = "QuestBackgroundProfessionLeatherworking",
			type = "custom",
		},
		["Mining"] = {
			path = "QuestBackgroundProfessionMining",
			type = "custom",
		},
		["Skinning"] = {
			path = "QuestBackgroundProfessionSkinning",
			type = "custom",
		},
		["Tailoring"] = {
			path = "QuestBackgroundProfessionTailoring",
			type = "custom",
		},
	},
	["Standard"] = {
		["Alliance"] = {
			atlas = "QuestBG-Alliance",
			type = "quest",
		},
		["Auction"] = {
			path = "AuctionStationery",
			type = "stationery"
		},
		["Book"] = {
			atlas = "book-bg",
			type = "book",
		},
		["Bronze"] = {
			path = "Bronze",
			type = "itemtext"
		},
		["Blood Elf"] = {
			path = "QuestBackgroundBloodElf",
			type = "custom",
		},
		["Darkmoon"] = {
			path = "QuestBackgroundDarkmoon",
			type = "custom",
		},
		["Exile's Reach"] = {
			path = "QuestBackgroundExilesReach",
			type = "custom",
		},
		["Horde"] = {
			atlas = "QuestBG-Horde",
			type = "quest",
		},
		["Illidari"] = {
			path = "Stationery_ill",
			type = "stationery"
		},
		["Love is in the Air"] = {
			path = "Valentine",
			type = "itemtext"
		},
		["Marble"] = {
			path = "Marble",
			type = "itemtext"
		},
		["Pandaria"] = {
			path = "QuestBackgroundPandaria",
			type = "custom"
		},
		["Passport"] = {
			path = "QuestBackgroundPassport",
			type = "custom"
		},
		["Quilboar"] = {
			path = "QuestBackgroundQuilboar",
			type = "custom"
		},
		["Orc"] = {
			path = "Stationery_OG",
			type = "stationery"
		},
		["Quest"] = {
			atlas = "questbg-parchment",
			type = "quest",
		},
		["Silver"] = {
			path = "Silver",
			type = "itemtext"
		},
		["Stone"] = {
			path = "Stone",
			type = "itemtext"
		},
		["Tauren"] = {
			path = "QuestBackgroundTauren",
			type = "custom"
		},
		["Thunder Bluff"] = {
			path = "Stationery_TB",
			type = "stationery"
		},
		["Trading Post"] = {
			path = "QuestBackgroundTradingPost",
			type = "custom"
		},
		["Undead"] = {
			path = "Stationery_UC",
			type = "stationery"
		},
		["Winter Veil"] = {
			path = "Stationery_Chr",
			type = "stationery"
		},
	},
	["Cosmic"] = {
		["Blue"] = {
			path = "QuestBackgroundEpsilonCosmicBlue",
			type = "custom"
		},
		["Dark Blue"] = {
			path = "QuestBackgroundEpsilonCosmicDarkBlue",
			type = "custom"
		},
		["Green"] = {
			path = "QuestBackgroundEpsilonCosmicGreen",
			type = "custom"
		},
		["Orange"] = {
			path = "QuestBackgroundEpsilonCosmicOrange",
			type = "custom"
		},
		["Red"] = {
			path = "QuestBackgroundEpsilonCosmicRed",
			type = "custom"
		},
		["Yellow"] = {
			path = "QuestBackgroundEpsilonCosmicYellow",
			type = "custom"
		},
	},
	["Epsilon"] = {
		["Epsilon Metal"] = {
			path = "QuestBackgroundEpsilonMetal",
			type = "custom"
		},
		["Epsilon Paper"] = {
			path = "QuestBackgroundEpsilonPaper",
			type = "custom"
		},
		["Epsilon Paper (Engraved)"] = {
			path = "QuestBackgroundEpsilonPaperEngraved",
			type = "custom"
		},
		["Epsilon Stone"] = {
			path = "QuestBackgroundEpsilonStone",
			type = "custom"
		},
	},
}

local BOOK_TEXT_COLOURS = {
	["Blue"]						= { 0.25, 0.78, 0.92 },
	["Dark Blue"]					= { 0.00, 0.44,	0.87 },
	["Green"]						= { 0.67, 0.83, 0.45 },
	["Orange"]						= { 1, 0.49, 0.04 },
	["Red"]							= { 0.77, 0.12, 0.23 },
	["Yellow"]						= { 1.00, 0.96,	0.41 },
	["Epsilon Metal"]				= { 1, 1, 1 },
	["Epsilon Paper"]				= { 1, 1, 1 },
	["Epsilon Paper (Engraved)"]	= { 1, 1, 1 },
	["Epsilon Stone"]				= { 1, 1, 1 },
	["Ascended"]					= { 1, 1, 1 },
	["Fae-Touched"]					= { 1, 1, 1 },
	["Maw"]							= { 1, 1, 1 },
	["Risen"]						= { 1, 1, 1 },
	["Tazavesh"]					= { 1, 1, 1 },
	["Tithed"]						= { 1, 1, 1 },
	["Zereth Mortis"]				= { 1, 1, 1 },
	["Burning Legion"]				= { 0, 1, 0 },
	["Eredar"]						= { 1, 0, 0 },
}

local BOOK_FONTS = {
	["Basic"] = {
		["Morpheus"] = "Fonts\\MORPHEUS.TTF",
		["Frizqt"] = "Fonts\\FRIZQT__.TTF",
		["Arialn"] = "Fonts\\ARIALN.TTF",
		["Skurri"] = "Fonts\\SKURRI.TTF",
		["Holy Empire"] = addon_path .. "\\Fonts\\HOLY.TTF",
		["Trade Winds"] = addon_path .. "\\Fonts\\TradeWinds-Regular.TTF",
		["Deutsch Gothic"] = addon_path .. "\\Fonts\\Deutsch.TTF",
		["VINYL"] = addon_path .. "\\Fonts\\VINYL.TTF",
		["Aka Posse"] = addon_path .. "\\Fonts\\akaPosse.TTF",
		["Ketupat Ramadhan"] = addon_path .. "\\Fonts\\Ketupat Ramadhan.TTF",
		["Elementary Gothic Bookhand"] = addon_path .. "\\Fonts\\Elementary_Gothic_Bookhand.TTF",
		["Belwe Medium"] = addon_path .. "\\Fonts\\Belwe_Medium.TTF",
		["Irish Uncialfabeta Bold"] = addon_path .. "\\Fonts\\IrishUncialfabeta-Bold.TTF",
		["Exocet"] = addon_path .. "\\Fonts\\exocet-blizzard-medium.TTF",
		["Atlas of the Magi"] = addon_path .. "\\Fonts\\Atlas of the Magi.TTF",
		["Almanac of the Apprentice"] = addon_path .. "\\Fonts\\Almanac of the Apprentice.TTF",
		["Barrelhouse All Caps"] = addon_path .. "\\Fonts\\Barrelhouse All Caps.TTF",
		["Dragon Harbour"] = addon_path .. "\\Fonts\\Dragon Harbour.TTF",
		["Knits and Scraps"] = addon_path .. "\\Fonts\\Knits and Scraps.TTF",
		["Spacedock Stencil"] = addon_path .. "\\Fonts\\Spacedock Stencil.TTF",
		["Thunder Thighs  Shadow"] = addon_path .. "\\Fonts\\Thunder Thighs  Shadow.TTF",
		["Wolves and Ravens"] = addon_path .. "\\Fonts\\Wolves and Ravens.TTF",
	},
	["Script and Handwriting"] = {
		["Black Chancery"] = addon_path .. "\\Fonts\\blkchcry.TTF",
		["Abuget"] = addon_path .. "\\Fonts\\Abuget.TTF",
		["Tangerine"] = addon_path .. "\\Fonts\\Tangerine_Regular.TTF",
		["Ode an Erik"] = addon_path .. "\\Fonts\\Ode-Erik.TTF",
		["Sade Kids"] = addon_path .. "\\Fonts\\Sadekids-Regular.TTF",
	},
	["Runes and Symbols"] = {
		["Ancient Runes"] = addon_path .. "\\Fonts\\AncientRunes.TTF",
		["Arathi Caligraphy"] = addon_path .. "\\Fonts\\Arathi_caligraphy-Regular.TTF",
		["Hymnus FG"] = addon_path .. "\\Fonts\\Hymnus212.TTF",
		["RITVAL"] = addon_path .. "\\Fonts\\RITVAL.TTF",
		["Legion Runes"] = addon_path .. "\\Fonts\\LegionRunes.TTF",
		["Darnassian"] = addon_path .. "\\Fonts\\DarnassianRunes-Regular.TTF",
		["Thalassian"] = addon_path .. "\\Fonts\\Thalassian_Font.TTF",
		["Shalassian"] = addon_path .. "\\Fonts\\ShalassianFont-Regular.TTF",
		["Pandaren"] = addon_path .. "\\Fonts\\PandarenFont-Regular.TTF",
		["Zandali"] = addon_path .. "\\Fonts\\Zandali-Regular.TTF",
		["Draenei"] = addon_path .. "\\Fonts\\Draenei-Regular.TTF",
		["Dwarvish"] = addon_path .. "\\Fonts\\Dwarvish-Regular.TTF",
		["Taur-ahe"] = addon_path .. "\\Fonts\\Taur_ahe-Regular.TTF",
		["Rune"] = addon_path .. "\\Fonts\\rune.TTF",
		["Yemite Snow Letters"] = addon_path .. "\\Fonts\\Yemite Snow Letters.TTF",
		["Temphis Brick"] = addon_path .. "\\Fonts\\Temphis Brick.TTF",
	},
}

local function GetBookFont( fontFamily )
	if not fontFamily then 
		return "Fonts\\FRIZQT__.TTF"
	end

	local found = false;
	for k, v in pairs(BOOK_FONTS) do
		for name, path in pairs(v) do
			if name == fontFamily then
				return path
			end
		end
	end
	return "Fonts\\FRIZQT__.TTF";
end

local function SetBookMaterial(materialType)
	EpsilonBookFramePageBg:SetTexture(nil)
	EpsilonBookMaterialLeft:SetTexture(nil)
	EpsilonBookMaterialRight:SetTexture(nil)
	EpsilonBookMaterialTopLeft:SetTexture(nil);
	EpsilonBookMaterialTopRight:SetTexture(nil);
	EpsilonBookMaterialBotLeft:SetTexture(nil);
	EpsilonBookMaterialBotRight:SetTexture(nil);

	local material = BOOK_MATERIALS["Standard"]["Book"];
	for k, v in pairs(BOOK_MATERIALS) do
		for mat, data in pairs(v) do
			if mat == materialType then
				material = data;
				break
			end
		end
	end

	if material then
		if material.type == "stationery" then
			EpsilonBookMaterialLeft:SetTexture("Interface/Stationery/" .. (material.path) .. "1");
			EpsilonBookMaterialRight:SetTexture("Interface/Stationery/" .. (material.path) .. "2");
		elseif material.type == "itemtext" then
			EpsilonBookMaterialTopLeft:SetTexture("Interface/ItemTextFrame/ItemText-" .. material.path .. "-TopLeft");
			EpsilonBookMaterialTopRight:SetTexture("Interface/ItemTextFrame/ItemText-" .. material.path .. "-TopRight");
			EpsilonBookMaterialBotLeft:SetTexture("Interface/ItemTextFrame/ItemText-" .. material.path .. "-BotLeft");
			EpsilonBookMaterialBotRight:SetTexture("Interface/ItemTextFrame/ItemText-" .. material.path .. "-BotRight");
		elseif material.type == "custom" then
			EpsilonBookFramePageBg:SetTexture(addon_path .. "\\Texture\\Backdrop\\" .. material.path);
			EpsilonBookFramePageBg:SetTexCoord(0.00195312, 0.585938, 0.00195312, 0.796875);
		elseif material.type == "quest" or material.type == "book" then
			EpsilonBookFramePageBg:SetTexCoord(0, 1, 0, 1);
			EpsilonBookFramePageBg:SetAtlas(material.atlas, false)
		end
	end
end

local function GetBookTextColours( material )
	local colours = BOOK_TEXT_COLOURS[material] or nil;

	if not( colours ) then
		colours = GetMaterialTextColors(material)
	end
	return colours;
end

function EpsilonBookEditorMaterial_OnClick(self, arg1, arg2, checked)
	UIDropDownMenu_SetText(EpsilonBookEditor.MaterialButton, self:GetText());

	if not EpsilonBookFrame.bookData then
		return
	end

	EpsilonBookFrame.bookData.material = self:GetText();
	EpsilonBookFrame_Update()
	EpsilonBook_SaveCurrentBook()
end

local function CreateMaterialMenu(dropdown, level, title)
	local info = UIDropDownMenu_CreateInfo();
	info.text = title;
	info.notCheckable = true;
	info.hasArrow = true;
	info.keepShownOnClick = true;
	info.menuList = title;
	UIDropDownMenu_AddButton(info, level);
end

function EpsilonBookEditorMaterial_OnLoad(frame, level, menuList)
	local info = UIDropDownMenu_CreateInfo()
	if level == 1 then
		info.text = "Book Material";
		info.notCheckable = true;
		info.isTitle = true;
		UIDropDownMenu_AddButton(info, level);
		local keys = {};
		for k in pairs(BOOK_MATERIALS) do
			table.insert(keys, k)
		end
		table.sort(keys)
		for _, k in ipairs(keys) do
			CreateMaterialMenu(frame, level, k);
		end
	elseif level == 2 then
		local materials = {};
		for k in pairs(BOOK_MATERIALS[menuList]) do
			table.insert(materials, k)
		end
		table.sort(materials)
		for _, material in pairs(materials) do
			local info = UIDropDownMenu_CreateInfo();
			info.text = material;
			info.checked = UIDropDownMenu_GetText(EpsilonBookEditor.MaterialButton) == info.text;
			info.notCheckable = false;
			info.func = EpsilonBookEditorMaterial_OnClick;
			UIDropDownMenu_AddButton(info, level)
		end
	end
end

function EpsilonBookEditorFont_OnClick(self, arg1, arg2, checked)
	UIDropDownMenu_SetText(arg1, self:GetText());

	if not EpsilonBookFrame.bookData then
		return
	end

	if arg1 == EpsilonBookEditor.FontButtonH1 then
		EpsilonBookFrame.bookData.fontFamily.h1 = self:GetText();
	elseif arg1 == EpsilonBookEditor.FontButtonH2 then
		EpsilonBookFrame.bookData.fontFamily.h2 = self:GetText();
	elseif arg1 == EpsilonBookEditor.FontButtonH3 then
		EpsilonBookFrame.bookData.fontFamily.h3 = self:GetText();
	else
		EpsilonBookFrame.bookData.fontFamily.p = self:GetText();
	end
	EpsilonBookFrame_Update()
	EpsilonBook_SaveCurrentBook()
end

local fontPreview = [[abcdefghijklmnopqrstuvwxyz|nABCDEFGHIJKLMNOPQRSTUVWXYZ|n1234567890.:,;'"(!?)+-*/=]]

function EpsilonBookEditorFont_OnLoad(frame, level, menuList)
	local info = UIDropDownMenu_CreateInfo()
	if level == 1 then
		info.text = "Font Family";
		info.notCheckable = true;
		info.isTitle = true;
		UIDropDownMenu_AddButton(info, level);
		local keys = {};
		for k in pairs(BOOK_FONTS) do
			table.insert(keys, k)
		end
		table.sort(keys)
		for _, k in ipairs(keys) do
			CreateMaterialMenu(frame, level, k);
		end
	elseif level == 2 then
		local fonts = {};
		for k in pairs(BOOK_FONTS[menuList]) do
			table.insert(fonts, k)
		end
		table.sort(fonts)
		for _, font in pairs(fonts) do
			local fontObject = CreateFont(font);
			if font == "Elementary Gothic Bookhand" then
				fontObject:SetFont(BOOK_FONTS[menuList][font], 8, "");
			else
				fontObject:SetFont(BOOK_FONTS[menuList][font], 16, "");
			end
			info.fontObject = fontObject;
			info.text = font;
			info.arg1 = frame;
			info.checked = UIDropDownMenu_GetText(frame) == info.text;
			info.notCheckable = false;
			info.disabled = false;
			info.isTitle = false;
			info.funcOnEnter = function( self )
				EpsilonBookFontTooltip:ClearAllPoints();
				EpsilonBookFontTooltip:SetPoint("BOTTOMLEFT", self, "TOPRIGHT");
				EpsilonBookFontTooltip.Title:SetText(font);
				EpsilonBookFontTooltip.Preview:SetText(fontPreview);
				EpsilonBookFontTooltip.Preview:SetFont(BOOK_FONTS[menuList][font], 24, "");
				EpsilonBookFontTooltip:Show();
			end;
			info.funcOnLeave = function( self )
				EpsilonBookFontTooltip:Hide();
			end;
			info.func = EpsilonBookEditorFont_OnClick;
			UIDropDownMenu_AddButton(info, level)
		end
	end
end

local function GetHighlightedText(editbox)
	if not editbox then
		return nil
	end

	local origText = editbox:GetText();
	if not (origText) then return nil end

	local cPos = editbox:GetCursorPosition();

	editbox:Insert("\127");
	local a = string.find(editbox:GetText(), "\127");
	local dLen = math.max(0, string.len(origText) - (string.len(editbox:GetText()) - 1));
	editbox:SetText(origText);

	editbox:SetCursorPosition(cPos);
	local hs, he = a - 1, a + dLen - 1;
	if hs < he then
		editbox:HighlightText(hs, he);
		return hs, he;
	end
end

function EpsilonBookEditor_Insert(text)
	EpsilonBookPageTextEditor:Insert(text);
end

function EpsilonBookEditor_InsertTag(tag, tag2)
	local hi1, hi2 = GetHighlightedText(EpsilonBookPageTextEditor);
	local s;

	local inner = "";
	if hi1 and hi2 then
		inner = string.sub(EpsilonBookPageTextEditor:GetText(), hi1 + 1, hi2);
	end
	if tag2 then
		s = string.format("{%s}%s{/%s}", tag, inner, tag2);
	else
		s = string.format("{%s}%s{/%s}", tag, inner, tag);
	end
	EpsilonBookPageTextEditor:Insert(s);
end

function EpsilonBookEditor_DeletePage()
	if not EpsilonBookFrame.bookData then
		return
	end

	local pages = EpsilonBookFrame.bookData.pages
	local currentPage = EpsilonBookFrame.currentPage or 1
	local data = {
		pages = pages,
		currentPage = currentPage,
	}

	if (#pages == 1) then
		UIErrorsFrame:AddMessage("You cannot delete the last page.", 1.0, 0.0, 0.0, 53, 5);
	else
		StaticPopup_Show("EPSILONBOOK_DELETEBOOKPAGE", nil, nil, data)
	end
end

function EpsilonBookEditor_InsertPage(before)
	if not EpsilonBookFrame.bookData then
		return
	end

	if before then
		tinsert(EpsilonBookFrame.bookData.pages, #EpsilonBookFrame.bookData.pages, "")
	else
		tinsert(EpsilonBookFrame.bookData.pages, "")
	end

	EpsilonBookFrame_Update()
	EpsilonBook_SaveCurrentBook()
end

function EpsilonBookEditor_InsertLink()
	if not EpsilonBookFrame.bookData then
		return
	end

	local pages = EpsilonBookFrame.bookData.pages
	local currentPage = EpsilonBookFrame.currentPage or 1
	local data = {
		pages = pages,
		currentPage = currentPage,
	}

	StaticPopup_Show("EPSILONBOOK_INSERTURLLINK", nil, nil, data)
end

function EpsilonBookEditor_CreateBook()
	if not EPSILON_BOOK_LIST then
		EPSILON_BOOK_LIST = {};
	end

	EpsilonBookEditPageButton:Show();
	EpsilonBookFrame.ReturnButton:Show();
	EpsilonBookCurrentPage:Show();
	EpsilonBookNextPageButton:Show();
	EpsilonBookPrevPageButton:Show();
	EpsilonBookPageText:Show();
	EpsilonBookScrollFrame:Show();
	EpsilonBookLibraryFrame:Hide();

	local bookID, bookData = EpsilonBook_CreateBook();

	EpsilonBookFrame.bookID = bookID;
	EpsilonBookFrame.bookData = bookData;
	EpsilonBookFrame.currentPage = 1;
	EpsilonBookFrame_Update()
	EpsilonBook_SaveCurrentBook()

	EpsilonBookEditPageButton:SetText("View Text")
	EpsilonBookEditor_Show();
	EpsilonBookPageTextEditor:SetFocus();
end

function EpsilonBookEditor_SaveCurrentPage()
	if not EpsilonBookFrame.bookData then
		return
	end

	EpsilonBookFrame.bookData.pages[EpsilonBookFrame.currentPage] = EpsilonBookPageTextEditor:GetText() or "";
	EpsilonBookFrame_Update()
	EpsilonBook_SaveCurrentBook()
end

function EpsilonBookEditor_Show()
	if not EpsilonBookFrame.bookData then
		return
	end

	EpsilonBookEditor:Show()

	local data = EpsilonBookFrame.bookData

	UIDropDownMenu_SetText(EpsilonBookEditor.MaterialButton, data.material or "Book");
	UIDropDownMenu_SetText(EpsilonBookEditor.FontButtonReg, data.fontFamily.p or "Frizqt");
	UIDropDownMenu_SetText(EpsilonBookEditor.FontButtonH1, data.fontFamily.h1 or "Frizqt");
	UIDropDownMenu_SetText(EpsilonBookEditor.FontButtonH2, data.fontFamily.h2 or "Frizqt");
	UIDropDownMenu_SetText(EpsilonBookEditor.FontButtonH3, data.fontFamily.h3 or "Frizqt");

	EpsilonBookEditor.FontSizeReg:SetText(data.fontSize.p or "13");
	EpsilonBookEditor.FontSizeH1:SetText(data.fontSize.h1 or "18");
	EpsilonBookEditor.FontSizeH2:SetText(data.fontSize.h2 or "16");
	EpsilonBookEditor.FontSizeH3:SetText(data.fontSize.h3 or "14");

	EpsilonBookPageText:Hide()
	EpsilonBookPageTextEditor:SetText(data.pages[EpsilonBookFrame.currentPage])
	EpsilonBookPageTextEditor:Show()
end

function EpsilonBookEditor_Hide()
	EpsilonBookEditor:Hide()

	EpsilonBookPageText:Show()
	EpsilonBookPageTextEditor:Hide()
end

EpsilonBookTutorialMixin = {}

function EpsilonBookTutorialMixin:OnLoad()
	self.helpInfo = {
		FramePos = { x = 0,	y = -20 },
		FrameSize = { width = 336, height = 430	},
	};
end

function EpsilonBookTutorialMixin:OnHide()
	self:CheckAndHideHelpInfo();
end

function EpsilonBookTutorialMixin:CheckAndShowTooltip()
	if not HelpPlate:IsShown() then
		HelpPlate_ShowTutorialPrompt(self.helpInfo, self);
	end
end

function EpsilonBookTutorialMixin:CheckAndHideHelpInfo()
	if HelpPlate:IsShown() then
		HelpPlate_Hide();
		HelpPlate_TooltipHide();
	end
end

local TUTORIAL_INFO = {
	"Use the search bar to search for books by keyword or GUID.|n|nYou can view how many total books are in the current phase on the Total Books counter.",
	"Phase books are listed here.|n|nClick 'Create Book' to create or import a new book.|n|nClick the dropdown button to expand a menu of additional options, allowing you to edit, duplicate, export, or delete the book.|n|nYou can also add a link to the book as a gossip option, or turn an NPC into the book (so that it automatically displays when a player interacts with the NPC).",
	"Use the buttons at the bottom of the frame to change pages.",
	"Click the Return to Library button to return to the phase's Book Library.",
	"You can edit the text content of the book's page here.|n|nWhile the toolbar on the right is expanded, you'll see the markdown version of the text.|n|nWhile the toolbar is collapsed, you'll see a preview of how the formatted page looks.",
	"Click the toolbar to open a panel of editing tools to edit the book.",
}

function EpsilonBookTutorialMixin:ToggleHelpInfo()
	for i = 1, #self.helpInfo do
		self.helpInfo[i] = nil;
	end
	if ( EpsilonBookLibraryFrame:IsShown() ) then
		self.helpInfo[1] = { ButtonPos = { x = 145,	y = 2 }, HighLightBox = { x = 60, y = -2, width = 265, height = 39 },	ToolTipDir = "DOWN", ToolTipText = TUTORIAL_INFO[1] };
		self.helpInfo[2] = { ButtonPos = { x = 145,	y = -50 }, HighLightBox = { x = 10, y = -47, width = 315, height = 315 },	ToolTipDir = "DOWN", ToolTipText = TUTORIAL_INFO[2] };
		self.helpInfo[3] = { ButtonPos = { x = 145,	y = -356 }, HighLightBox = { x = 10, y = -365, width = 315, height = 30 },	ToolTipDir = "UP", ToolTipText = TUTORIAL_INFO[3] };
	elseif ( EpsilonBookFrame:IsShown() ) then
		self.helpInfo[1] = { ButtonPos = { x = 45,	y = 2 }, HighLightBox = { x = 30, y = -2, width = 70, height = 39 },	ToolTipDir = "RIGHT", ToolTipText = TUTORIAL_INFO[4] };
		self.helpInfo[2] = { ButtonPos = { x = 145,	y = -50 }, HighLightBox = { x = 10, y = -47, width = 295, height = 345 },	ToolTipDir = "DOWN", ToolTipText = TUTORIAL_INFO[5] };
		self.helpInfo[3] = { ButtonPos = { x = 325,	y = -160 }, HighLightBox = { x = 330, y = -115, width = 35, height = 155 },	ToolTipDir = "LEFT", ToolTipText = TUTORIAL_INFO[6] };
	end

	if ( not HelpPlate:IsShown() and EpsilonBookFrame:IsShown()) then
		HelpPlate_Show(self.helpInfo, EpsilonBookFrame, self, true);
	else
		HelpPlate_Hide(true);
	end
end

local function NewItemDropdown(frame)
	local menu = {
		{ 
			text = "Create Book",															
			isTitle = true,											
			notCheckable = true,
		},
		{ 
			text = "|TInterface/PaperDollInfoFrame/Character-Plus:16|t |cFF00FF00New",	
			func = function() EpsilonBookEditor_CreateBook(); end,	
			notCheckable = true,
		},
		{ 
			text = "Import",																
			func = function()
				EpsilonBookExportDialog.Title:SetText("Import Book");
				EpsilonBookExportDialog:Show();
				EpsilonBookExportDialog.ImportButton:Show();
				EpsilonBookExportDialog.CancelButton:Show();
				EpsilonBookExportDialog.ImportControl.InputContainer.EditBox:SetText( "" );
				EpsilonBookExportDialog.ImportControl.InputContainer:UpdateScrollChildRect();
				EpsilonBookExportDialog.ImportControl.InputContainer:SetVerticalScroll(EpsilonBookExportDialog.ImportControl.InputContainer:GetVerticalScrollRange());
				EpsilonBookExportDialog.ImportControl.InputContainer.EditBox:HighlightText();
				EpsilonBookExportDialog.ImportControl.InputContainer.EditBox:SetFocus();
			end,	
			notCheckable = true,
		},
	};

	if not (frame.menuFrame) then
		frame.menuFrame = CreateFrame("Frame", nil, frame, "UIDropDownMenuTemplate");
		frame.menuFrame:SetPoint("BOTTOMRIGHT");
		frame.menuFrame:Hide();
	end
	
	frame:SetScript("OnClick", function(self, button)
		EasyMenu(menu, self, self, 0, 0, "MENU");
		self:SetSize(37, 37);
	end);
end

function EpsilonBookLibraryItem_CreateDropdown(frame, guid)
	local menu = {
		{ 
			text = frame:GetParent().Title:GetText(),
			isTitle = true,
			notCheckable = true,
		},
		{ 
			text = "Edit",
			func = function() 
				EpsilonBook_LoadBook(guid); 
			end,
			notCheckable = true,
			tooltipTitle = "Edit",
			tooltipText = "Edit this book.",
		},
		{ 
			text = "Duplicate",
			func = function() 
				EpsilonBook_DuplicateBook(guid)
			end,
			notCheckable = true,
			tooltipTitle = "Duplicate",
			tooltipText = "Create an exact copy of this book with a new GUID.",
		},
		{ 
			text = "Export",
			func = function() 
				EpsilonBook_ExportBook(guid) 
			end,
			notCheckable = true,
			tooltipTitle = "Export",
			tooltipText = "Generate an import code you can copy and share with other players.",
		},
		{ 
			text = "Delete",
			func = function() 
				StaticPopup_Show("EPSILONBOOK_DELETEBOOK", nil, nil, guid) 
			end,
			notCheckable = true,
			tooltipTitle = "Delete",
			tooltipText = "Delete this book.",
		},
		{ 
			text = "Add Gossip Option to NPC",
			func = function()
				if not UnitExists("target") then
					UIErrorsFrame:AddMessage("Invalid target", 1.0, 0.0, 0.0, 53, 5);
				elseif not ( C_Epsilon.IsOfficer() or C_Epsilon.IsOwner() ) then
					UIErrorsFrame:AddMessage("You must be the phase owner or an officer to do that.", 1.0, 0.0, 0.0, 53, 5);
				else
					StaticPopup_Show("EPSILONBOOK_ADDGOSSIPOPTIONTONPC", nil, nil, guid);
				end
			end,
			notCheckable = true,
			tooltipTitle = "Add Gossip Option to NPC",
			tooltipText = "Add a gossip option to your current target that opens this book.",
		},
		{ 
			text = "Turn NPC Into Book",
			func = function() 
				if not UnitExists("target") then
					UIErrorsFrame:AddMessage("Invalid target", 1.0, 0.0, 0.0, 53, 5);
				elseif not ( C_Epsilon.IsOfficer() or C_Epsilon.IsOwner() ) then
					UIErrorsFrame:AddMessage("You must be the phase owner or an officer to do that.", 1.0, 0.0, 0.0, 53, 5);
				else
					StaticPopup_Show("EPSILONBOOK_TURNNPCINTOBOOK", nil, nil, guid);
				end
			end,
			notCheckable = true,
			tooltipTitle = "Turn NPC Into Book",
			tooltipText = "Turn your current target into a book.|n|nWhen players interact with this NPC, it will open override the Gossip Frame with this book instead.",
		},
		{ 
			text = "Link Item to Book",
			func = function() 
				if ( C_Epsilon.IsOfficer() or C_Epsilon.IsOwner() ) then
					StaticPopup_Show("EPSILONBOOK_LINKITEMTOBOOK", nil, nil, guid);
				else
					UIErrorsFrame:AddMessage("You must be the phase owner or an officer to do that.", 1.0, 0.0, 0.0, 53, 5);
				end
			end,
			notCheckable = true,
		},
	}

	if not (frame.menuFrame) then
		frame.menuFrame = CreateFrame("Frame", nil, frame, "UIDropDownMenuTemplate");
		frame.menuFrame:SetPoint("BOTTOMRIGHT");
		frame.menuFrame:Hide();
	end

	frame:SetScript("OnClick", function(self, button)
		EasyMenu(menu, self, self, 0, 0, "MENU");
		self:SetSize(24, 24);
	end);
end

function EpsilonBookLibrary_NextPage()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	EpsilonBookLibraryFrame.pageNum = EpsilonBookLibraryFrame.pageNum + 1;
	EpsilonBookLibrary_Update();
end

function EpsilonBookLibrary_PrevPage()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	EpsilonBookLibraryFrame.pageNum = EpsilonBookLibraryFrame.pageNum - 1;
	EpsilonBookLibrary_Update();
end

function EpsilonBookLibrary_OnMouseWheel(self, value)
	if (value > 0) then
		if (EpsilonBookLibraryFrame.PrevPageButton:IsEnabled()) then
			EpsilonBookLibrary_PrevPage();
		end
	else
		if (EpsilonBookLibraryFrame.NextPageButton:IsEnabled()) then
			EpsilonBookLibrary_NextPage();
		end
	end
end

function EpsilonBookLibrary_Show()
	EpsilonBookEditor_Hide()
	EpsilonBookLibraryFrame.pageNum = 1;
	EpsilonBook_GetBookList()
	
	EpsilonBookFrameCloseButton:SetScript("OnClick", EpsilonBookFrame_Hide)

	EpsilonBookEditPageButton:Hide();
	EpsilonBookFrame.ReturnButton:Hide();
	EpsilonBookPageText:Hide();
	EpsilonBookScrollFrame:Hide();
	EpsilonBookCurrentPage:Hide();
	EpsilonBookNextPageButton:Hide();
	EpsilonBookPrevPageButton:Hide();

	EpsilonBookFrame.TitleText:SetText("Book Library");
	SetPortraitToTexture(EpsilonBookFrame.portrait, "Interface/Icons/inv_misc_book_09")

	EpsilonBookLibrary_Update()
	EpsilonBookLibraryFrame:Show();
	EpsilonBookFrame:Show();
end

-------------------------------------------------------------------------------
-- Called when the user types into the search box.
--

function EpsilonBookLibrary_FilterChanged()
	if not EPSILON_BOOK_LIST then
		return
	end

	local filter = EpsilonBookLibraryFrame.SearchBar:GetText():lower();
	if #filter < 3 then
		-- Ignore filters less than three characters
		if filteredList then
			filteredList = nil;
			EpsilonBookLibrary_Update();
		end
	else
		-- build new list
		filteredList = {};
		for k,v in pairs( EPSILON_BOOK_LIST ) do
			if v.title:lower():find( filter ) or k:lower():find( filter ) then
				filteredList[k] = v;
			end	
		end
		EpsilonBookLibrary_Update();
	end
end


local function ConnectedItemsDropdown(self, guid)
	local menu = {
		{ 
			text = "Connected Items",															
			isTitle = true,											
			notCheckable = true,
		},
	};

	for i = 1, #self.connectedItems do
		local itemLink = self.connectedItems[i];
		local itemID, _ = GetItemInfoInstant(itemLink)
		local item = {
			text = itemLink,
			notCheckable = true,
			hasArrow = true,
			menuList = {
				{ text = "Remove", notCheckable = true, func = function() EpsilonBook_RemoveBookItemLink(itemID, guid); end };
			}
		};
		tinsert( menu, item );
	end

	if not (self.menuFrame) then
		self.menuFrame = CreateFrame("Frame", nil, self, "UIDropDownMenuTemplate");
		self.menuFrame:SetPoint("BOTTOMRIGHT");
		self.menuFrame:Hide();
	end
	
	self:SetScript("OnClick", function(self, button)
		EasyMenu(menu, self, self, 0, 0, "MENU");
		self:SetSize(16, 16);
	end);
end

-------------------------------------------------------------------------------
-- Refresh the library frame.
--

function EpsilonBookLibrary_Update()
	if not EPSILON_BOOK_LIST then
		return
	end

	if not( EPSILON_BOOK_ITEMS ) then
		EpsilonBook_GetBookItemList();
	end

	local numBooks = 0;
	local list = filteredList or EPSILON_BOOK_LIST;
	local bookList = {};
	if list ~= {} then
		for k, v in pairs(list) do
			numBooks = numBooks + 1
			local book = {
				icon = v.icon,
				title = v.title,
				guid = k,
			};
			tinsert(bookList, book);
		end
	end

	EpsilonBookLibraryFrame.BookCount.Count:SetText(numBooks);

	local book = {
		icon = "Interface/PaperDollInfoFrame/Character-Plus",
		title = "Create Book",
		guid = 0,
	};
	tinsert(bookList, book);
	numBooks = numBooks + 1;

	local index = ((EpsilonBookLibraryFrame.pageNum - 1) * 7) + 1;

	local button, buttonIcon, titleText, guidText, connectedItemsIcon, buttonDropdown
	for i = 1, 7 do
		if (index <= numBooks) then
			local icon = bookList[index].icon or "Interface/Icons/inv_misc_book_09";
			local title = bookList[index].title;
			local guid = bookList[index].guid;

			button = _G["EpsilonBookLibraryItem" .. i .. "Button"];
			buttonIcon = _G["EpsilonBookLibraryItem" .. i .. "ButtonIcon"];
			titleText = _G["EpsilonBookLibraryItem" .. i .. "Title"];
			guidText = _G["EpsilonBookLibraryItem" .. i .. "GUID"];
			connectedItemsIcon = _G["EpsilonBookLibraryItem" .. i .. "ItemConnectedButton"];
			buttonDropdown = _G["EpsilonBookLibraryItem" .. i .. "DropdownButton"];

			button:Show();
			button.guid = guid;
			button.index = index;
			buttonIcon:SetTexture(icon);
			titleText:SetText(title);
			connectedItemsIcon:Hide();
			button:SetScript("OnEnter", nil);

			if guid == 0 then
				titleText:SetPoint("TOPLEFT", 47, -12);
				titleText:SetTextColor(0, 1, 0);
				guidText:SetText("");
				NewItemDropdown(button);
				buttonDropdown:Disable();
				buttonDropdown:Hide();
			else
				titleText:SetPoint("TOPLEFT", 47, -4);
				titleText:SetTextColor(1, 0.81, 0);
				guidText:SetText("GUID: " .. guid);
				button:SetScript("OnClick", function(self)
					EpsilonBook_LoadBook(self.guid);
				end);
				button:SetScript("OnEnter", function(self)
					GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
					GameTooltip:SetText(title);
					GameTooltip:Show();
				end);
				connectedItemsIcon.connectedItems = {};
				if EPSILON_BOOK_ITEMS then
					for k, v in pairs( EPSILON_BOOK_ITEMS ) do
						if v == guid then
							connectedItemsIcon:Show();
							local itemName, itemLink = GetItemInfo( k );
							tinsert( connectedItemsIcon.connectedItems, itemLink );
						end
					end
				end
				if connectedItemsIcon:IsShown() then
					ConnectedItemsDropdown(connectedItemsIcon, guid);
				end

				buttonDropdown:Enable();
				buttonDropdown:Show();
				EpsilonBookLibraryItem_CreateDropdown(buttonDropdown, guid);
				buttonDropdown:SetSize(24, 24);
			end
		else
			-- Clear everything
			_G["EpsilonBookLibraryItem" .. i .. "Button"]:Hide();
			_G["EpsilonBookLibraryItem" .. i .. "Title"]:SetText("");
			_G["EpsilonBookLibraryItem" .. i .. "GUID"]:SetText("");
			_G["EpsilonBookLibraryItem" .. i .. "DropdownButton"]:Disable();
			_G["EpsilonBookLibraryItem" .. i .. "DropdownButton"]:Hide();
		end
		index = index + 1;
	end
	
	local page = EpsilonBookLibraryFrame.pageNum or 1;
	local numPages = math.ceil( numBooks / 7 );
	EpsilonBookLibraryFrame.CurrentPage:SetText(page .. "/" .. numPages);

	-- Handle page arrows
	if (page == 1) then
		EpsilonBookLibraryFrame.PrevPageButton:Disable();
	else
		EpsilonBookLibraryFrame.PrevPageButton:Enable();
	end
	if (page < numPages) then
		EpsilonBookLibraryFrame.NextPageButton:Enable();
	else
		EpsilonBookLibraryFrame.NextPageButton:Disable();
	end
end

function EpsilonBookFrame_Show(bookID, data, canEdit, isAttached)
	if not bookID or not data or not data.title or not data.material or not data.pages or not data.fontFamily or not data.fontSize then
		return
	end

	EpsilonBookFrame.isAttached = isAttached;

	if canEdit and not( isAttached ) then
		EpsilonBookEditPageButton:Show();
		EpsilonBookFrame.ReturnButton:Show();
		EpsilonBookFrameCloseButton:SetScript("OnClick", function()
			EpsilonBookLibrary_Show();
			PlaySound(SOUNDKIT.IG_SPELLBOOK_CLOSE);
		end);
	else
		EpsilonBookEditPageButton:Hide();
		EpsilonBookFrame.ReturnButton:Hide();
		EpsilonBookFrameCloseButton:SetScript("OnClick", EpsilonBookFrame_Hide)
	end
	
	EpsilonBookEditor_Hide()
	EpsilonBookPageText:Show();
	EpsilonBookScrollFrame:Show();
	EpsilonBookLibraryFrame:Hide();

	EpsilonBookFrame.bookID = bookID;
	EpsilonBookFrame.bookData = data;
	EpsilonBookFrame.currentPage = 1;
	EpsilonBookFrame_Update()
	EpsilonBookFrame:Show()
end

function EpsilonBookFrame_Update()
	if not EpsilonBookFrame.bookData then
		return
	end

	local data = EpsilonBookFrame.bookData;

	local material = data.material
	if (not material) then
		material = "Book";
	end

	EpsilonBookFrame:SetWidth(DEFAULT_ITEM_TEXT_FRAME_WIDTH);
	EpsilonBookFrame:SetHeight(DEFAULT_ITEM_TEXT_FRAME_HEIGHT);
	EpsilonBookScrollFrame:SetPoint("TOPRIGHT", EpsilonBookFrame, "TOPRIGHT", -31, -63);
	EpsilonBookScrollFrame:SetPoint("BOTTOMLEFT", EpsilonBookFrame, "BOTTOMLEFT", 6, 6);
	EpsilonBookPageText:SetPoint("TOPLEFT", 18, -15);
	EpsilonBookPageText:SetWidth(270);
	EpsilonBookPageText:SetHeight(304);

	-- Add some padding at the bottom if the bar can scroll appreciably
	EpsilonBookScrollFrame:GetScrollChild():SetHeight(1);
	EpsilonBookScrollFrame:UpdateScrollChildRect();
	if (floor(EpsilonBookScrollFrame:GetVerticalScrollRange()) > 0) then
		EpsilonBookScrollFrame:GetScrollChild():SetHeight(EpsilonBookScrollFrame:GetHeight() + EpsilonBookScrollFrame:GetVerticalScrollRange() + 30);
	end

	EpsilonBookScrollFrameScrollBar:SetValue(0);
	EpsilonBookScrollFrame:Show();
	local page = EpsilonBookFrame.currentPage or 1;
	local hasNext = false;
	if (page + 1 <= #data.pages) then
		hasNext = true;
	end

	SetBookMaterial(material)
	SetPortraitToTexture(EpsilonBookFrame.portrait, data.icon or "Interface/Icons/inv_misc_book_09")
	EpsilonBookFrame.TitleText:SetText(data.title);
	EpsilonBookPageText:SetText(toHTML(data.pages[page]));
	EpsilonBookPageText:SetFont("P", GetBookFont(data.fontFamily.p), data.fontSize.p);
	EpsilonBookPageText:SetFont("H1", GetBookFont(data.fontFamily.h1), data.fontSize.h1);
	EpsilonBookPageText:SetFont("H2", GetBookFont(data.fontFamily.h2), data.fontSize.h2);
	EpsilonBookPageText:SetFont("H3", GetBookFont(data.fontFamily.h3), data.fontSize.h3);

	local textColor = GetBookTextColours( material );

	EpsilonBookPageText:SetTextColor(textColor[1] or 0, textColor[2] or 0, textColor[3] or 0);
	EpsilonBookPageText:SetTextColor("H1", textColor[1] or 0, textColor[2] or 0, textColor[3] or 0);
	EpsilonBookPageText:SetTextColor("H2", textColor[1] or 0, textColor[2] or 0, textColor[3] or 0);
	EpsilonBookPageText:SetTextColor("H3", textColor[1] or 0, textColor[2] or 0, textColor[3] or 0);

	EpsilonBookPageText:SetScript("OnHyperlinkEnter", function(self, link, text)
		GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
		GameTooltip:ClearLines();
		linkType, payload = strsplit(":", link, 2);
		if linkType:match("^item") or linkType:match("^spell") then
			GameTooltip:SetHyperlink(link)
		elseif linkType:match("^url") then
			GameTooltip:SetText("Copy Link: " .. payload, 1, 1, 1)
		elseif linkType:match("^link") then
			GameTooltip:SetText("Go to Page " .. payload, 1, 1, 1);
		end
		GameTooltip:Show()
	end)

	EpsilonBookPageText:SetScript("OnHyperlinkLeave", function(self, link, text)
		GameTooltip:Hide();
	end)

	EpsilonBookPageText:SetScript("OnHyperlinkClick", function(self, link, text)
		GameTooltip:Hide()
		linkType, payload = strsplit(":", link, 2);
		if linkType:match("^item") or linkType:match("^spell") then
			-- TODO ?
		elseif linkType:match("^url") then
			C_Epsilon.RunPrivileged("CopyToClipboard( '"..payload.."' )");
			PlaySound(3081);
			print("|cFFFFFF00Link copied to clipboard.")
			--StaticPopup_Show("EPSILONBOOK_SHOWPAGELINK", nil, nil, payload)
		elseif linkType:match("^link") then
			local pageRequested = tonumber(payload) or 1;
			if pageRequested <= #data.pages then
				EpsilonBookFrame.currentPage = pageRequested;
				EpsilonBookFrame_Update();
			end
		end
	end)

	EpsilonBookPageTextEditor:SetText(data.pages[page]);
	EpsilonBookPageTextEditor:SetFont(GetBookFont(data.fontFamily.p), data.fontSize.p);

	EpsilonBookPageTextEditor:SetTextColor(textColor[1] or 0, textColor[2] or 0, textColor[3] or 0)

	EpsilonBookCurrentPage:Hide()
	EpsilonBookNextPageButton:Hide();
	EpsilonBookPrevPageButton:Hide();

	if ((page > 1) or hasNext) then
		EpsilonBookCurrentPage:SetText(page .. "/" .. #data.pages);
		EpsilonBookCurrentPage:Show();
		if (page > 1) then
			EpsilonBookPrevPageButton:Show();
		else
			EpsilonBookPrevPageButton:Hide();
		end
		if (hasNext) then
			EpsilonBookNextPageButton:Show();
		else
			EpsilonBookNextPageButton:Hide();
		end
	end
end

function EpsilonBookFrame_NextPage()
	if not EpsilonBookFrame.bookData or not EpsilonBookFrame.currentPage then
		return
	end

	local data = EpsilonBookFrame.bookData
	if (EpsilonBookFrame.currentPage + 1 <= #data.pages) then
		EpsilonBookFrame.currentPage = EpsilonBookFrame.currentPage + 1
	end

	EpsilonBookFrame_Update()
end

function EpsilonBookFrame_PrevPage()
	if not EpsilonBookFrame.bookData or not EpsilonBookFrame.currentPage then
		return
	end

	local data = EpsilonBookFrame.bookData
	if (EpsilonBookFrame.currentPage > 1) then
		EpsilonBookFrame.currentPage = EpsilonBookFrame.currentPage - 1
	end

	EpsilonBookFrame_Update()
end

function EpsilonBookFrame_Hide()
	if ( EpsilonBookFrame.isAttached ) then
		C_GossipInfo.CloseGossip();
	else
		GossipFrame:SetAlpha(1);
		GossipFrame:EnableMouse(true);
	end
	EpsilonBookEditor_Hide()
	EpsilonBookLibraryFrame:Hide();
	HideUIPanel(EpsilonBookFrame);
	EpsilonBookFrameCloseButton:SetScript("OnClick", EpsilonBookFrame_Hide)
end
