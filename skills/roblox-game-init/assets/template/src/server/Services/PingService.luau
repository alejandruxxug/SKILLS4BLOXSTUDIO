--!strict
-- Smoke-test service: answers the client's Ping so day 0 proves server, client and remotes all work.
-- Safe to delete once the first real service exists (remove "Ping" from Net too).

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = require(ReplicatedStorage.Shared.Net)

local PingService = {}

function PingService:Init(_registry: { [string]: any }) end

function PingService:Start()
	-- Server is the authority: validate what the client sends, even for a ping.
	Net.Ping.OnServerInvoke = function(_player: Player, sentAt: unknown): number?
		if typeof(sentAt) ~= "number" then
			return nil
		end
		return sentAt
	end
end

return PingService
