--[[
	{
		text = L["|cff00ccffAdd Set|r"],
		notCheckable = true,
		func = function(self)
			for slot, v in pairs(currentPreview.slots) do
				--print(v.item);
				if v.item ~= nil then
				itemID = v.item:match("item:(%d*)")
				bonusID = v.item:match(":1:(%d*)")
				if itemID then
					message = "|cff00ccff[MogIt]|r adding item: "..itemID;
					if bonusID ~= nil then
						--print("[bonus] itemID "..itemID.." bonusID: "..bonusID)
						message = message.." with bonus: "..bonusID;
						SendChatMessage(".additem "..itemID.." 1 "..bonusID, "GUILD")
					--SendChatMessage(".add "..itemID)
					else
						--print("[no bonus] itemID "..itemID)
						SendChatMessage(".add "..itemID, "GUILD")
					end
					print(message)
				end
			else
			end
			end
		end,
	},
	{
		text = L["|cff00ccffEquip NPC|r"],
		notCheckable = true,
		func = function(self)
			for slot, v in pairs(currentPreview.slots) do
				--print(v.item);
				if v.item ~= nil then
				itemID = v.item:match("item:(%d*)")
				bonusID = v.item:match(":1:(%d*)")
				if itemID then
					message = "|cff00ccff[MogIt]|r equipping npc with item: "..itemID;
					if bonusID ~= nil then
						--print("[bonus] itemID "..itemID.." bonusID: "..bonusID)
						message = message.." bonus: "..bonusID;
						SendChatMessage(".ph forge npc outfit equip "..itemID.." 1 "..bonusID, "GUILD")
					--SendChatMessage(".add "..itemID)
					else
						--print("[no bonus] itemID "..itemID)
						SendChatMessage(".ph forge npc outfit equip "..itemID, "GUILD")
					end
					print(message)
				end
			else
			end
			end
		end,
	},
	{
		text = L["|cff00ccffToggle sheathe|r"],
		notCheckable = true,
		func = function(self)
			if toggle == 0 then
				MogItPreview1.model.model:SetSheathed(true)
				toggle = 1;
			elseif toggle == 1 then
				MogItPreview1.model.model:SetSheathed(false)
				toggle = 0
			end
		end,
	},
--]]
