--!strict
-- ⏱ Rounds: 3 minutes of collecting coins, then a 15 s intermission. Coins are per ROUND:
-- everyone starts each round at 0, and the top 3 at the end get a trophy.
local Players = game:GetService("Players")

local CoinService = require(script.Parent.CoinService)

local ROUND_SECONDS = 180
local INTERMISSION = 15

local RoundService = {
	round = 0,
}

function RoundService:_startRound()
	self.round += 1
	for _, player in Players:GetPlayers() do
		CoinService:Reset(player)
	end
	workspace:SetAttribute("Round", self.round)
	workspace:SetAttribute("RoundEndsAt", os.time() + ROUND_SECONDS)
end

function RoundService:_endRound()
	local standings = CoinService:Standings()
	for place = 1, math.min(3, #standings) do
		local player = Players:GetPlayerByUserId(standings[place].userId)
		if player then
			player:SetAttribute("Trophies", (player:GetAttribute("Trophies") or 0) + 1)
		end
	end
end

function RoundService:Start()
	task.spawn(function()
		while true do
			self:_startRound()
			task.wait(ROUND_SECONDS)
			self:_endRound()
			task.wait(INTERMISSION)
		end
	end)
end

return RoundService
