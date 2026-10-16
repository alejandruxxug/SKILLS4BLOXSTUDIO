--!strict
-- Smoke-test controller: pings the server once and prints the round trip.
-- Safe to delete together with PingService.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = require(ReplicatedStorage.Shared.Net)

local PingController = {}

function PingController:Init(_registry: { [string]: any }) end

function PingController:Start()
	local sentAt = os.clock()
	local ok, echoed = pcall(function()
		return Net.Ping:InvokeServer(sentAt)
	end)
	if ok and echoed == sentAt then
		print(string.format("[init] ping ok (%d ms)", math.floor((os.clock() - sentAt) * 1000)))
	else
		warn("[init] ping FAILED:", echoed)
	end
end

return PingController
