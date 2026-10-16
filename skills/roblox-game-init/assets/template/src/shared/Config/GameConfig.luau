--!strict
-- Every number you might tune lives in a Config module. No magic numbers in logic.

local RunService = game:GetService("RunService")

local GameConfig = {
	GAME_NAME = "{{GAME_NAME}}",
	IS_STUDIO = RunService:IsStudio(),

	-- 🛠️ DebugService (the agent backdoor). Always on in Studio. On live servers it's OFF unless
	-- DEBUG_ON_LIVE is true, and then only for ADMIN_USER_IDS. Every live use is logged.
	DEBUG_ON_LIVE = false,
	ADMIN_USER_IDS = {} :: { number },

	-- 💾 Saved data. Studio with API access writes to the REAL DataStores of the published game,
	-- so Studio sessions use their own scope: tests and debug commands never touch live saves.
	DATA_SCOPE = if RunService:IsStudio() then "studio" else "live",
}

return table.freeze(GameConfig)
