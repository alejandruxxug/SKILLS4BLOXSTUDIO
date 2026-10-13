--!strict
-- Chat tags: [DEV] for the developer, [MOD] for moderators.

local TextChatService = game:GetService("TextChatService")
local Players = game:GetService("Players")

local DEV_IDS = { 1234567 }
local MOD_IDS = { 7654321 }

TextChatService.OnIncomingMessage = function(message: TextChatMessage)
	local props = Instance.new("TextChatMessageProperties")
	local source = message.TextSource
	if source then
		local userId = source.UserId
		if table.find(DEV_IDS, userId) then
			props.PrefixText = "<font color='#FF5555'>[DEV]</font> " .. message.PrefixText
		elseif table.find(MOD_IDS, userId) then
			props.PrefixText = "<font color='#55AAFF'>[MOD]</font> " .. message.PrefixText
		end
	end
	return props
end

return {}
