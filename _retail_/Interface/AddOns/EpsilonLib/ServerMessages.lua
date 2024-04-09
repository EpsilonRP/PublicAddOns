local EpsilonLib, EpsiLib = ...;

EpsiLib.Server = {}

EpsiLib.channel = "xtensionxtooltip2"
EpsiLib.prefix = "EPSILON_";
local prefix = EpsiLib.prefix;
local channel = EpsiLib.channel;


EpsiLib.record = strchar(30)
EpsiLib.field = strchar(31)

Epsilon_debugging = false;

do -- Events
	EpsiLib.Server.Events = CreateFrame("FRAME")
	local events = EpsiLib.Server.Events
	
	events.registered = {}
	
	function events.on(event, func)
		events.registered[event] = events.registered[event] or {}
		table.insert(events.registered[event], func)
		events:RegisterEvent(event)
	end
	
	events:SetScript("OnEvent", function(self, event, ...)
		for i = 1, #events.registered[event] do
			events.registered[event][i](...)
		end
	end)

end

do -- Messages
	EpsiLib.Server.messages = {}
	local messages = EpsiLib.Server.messages
	
	messages.registered = {}
	
	function messages.receive(prefix, func)
		messages.registered[prefix] = messages.registered[prefix] or {}
		table.insert(messages.registered[prefix], func)
		C_ChatInfo.RegisterAddonMessagePrefix(prefix);
	end
	
	local events = EpsiLib.Server.Events
	
	events.on("CHAT_MSG_ADDON", function(prefix, message, ...)
		if prefix:match("EPSILON") and Epsilon_debugging then
			--print("|cff00CCFF[DEBUG]|r ADDON MSG RECEIVE", prefix, message);
		end
		if messages.registered[prefix] then
			for i = 1, #messages.registered[prefix] do
				--messages.registered[prefix][i](message,...)
				messages.registered[prefix][i](message,...)
			end
		end
	end)
	
	messages.queue = {}
	
	function messages.send(prefix, message)
		--print(prefix, message)
		local id = GetChannelName(channel)
		if id == 0 then
			table.insert(messages.queue, {prefix = prefix, message = message})
		else
			C_ChatInfo.SendAddonMessage(prefix, message, "CHANNEL", id)
		end
	end
	
	function messages.sendQueue()
		for i = 1, #messages.queue do
			messages.send(messages.queue[i].prefix, messages.queue[i].message)
		end
		messages.queue = {}
	end
	
	events.on("PLAYER_LOGIN", function()
		local id = GetChannelName(channel)
		if id == 0 then
			events.on("CHAT_MSG_CHANNEL_NOTICE", function(...)
				local message = select(1, ...)
				local channelName = select(9, ...)
				if (channelName == channel and message == "YOU_CHANGED") then
					messages.sendQueue()
				end
			end)
			C_Timer.After(5, function() JoinChannelByName(channel) end)
		else
			messages.sendQueue()
		end
	end)

end

do -- Server

	EpsiLib.Server.server = {}
	local server = EpsiLib.Server.server
	
	local messages = EpsiLib.Server.messages
	
	local self = table.concat({UnitFullName("PLAYER")}, "-")
	
	function server.send(suffix, message)
		
		if Epsilon_debugging == true then
			print("|cff00CCFF[DEBUG]|r |cffADFFFFSEND|r",prefix..suffix, message)
		end
		messages.send(prefix..suffix, message)
	end
	
	function server.receive(suffix, func)
		if Epsilon_debugging == true then
			print("|cff00CCFF[DEBUG]|r |cff00d111RECEIVE|r",prefix..suffix,suffix,channel.sender,message)
		end
		messages.receive(prefix..suffix, function(...)
		--print("...",...)
			local sender = select(3,...)
			if sender == self then
				func(...)
			else
				func(...)
				--print("ALERT: " .. sender .. " is trying to send server messages!", ...)
			end
		end)
	end

end