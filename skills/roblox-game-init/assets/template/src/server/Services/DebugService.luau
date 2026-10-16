--!strict
-- 🛠️ The agent backdoor: named debug commands that testers (and you) call to jump straight to a
-- state instead of playing there ("skip to round 3", "give 10K coins", "start the boss"), plus a
-- Dump of the game's state so a tester can check numbers instead of guessing from screenshots.
--
-- Security: always allowed in Studio. On live servers it's refused unless GameConfig.DEBUG_ON_LIVE
-- is true AND the caller is in GameConfig.ADMIN_USER_IDS (the server knows who called; a client
-- can't fake its UserId). Every live use is logged. Commands still validate their arguments.
--
-- Add commands and state from any service's Init:
--     registry.DebugService:Register("GiveCoins", function(player, amount) ... end)
--     registry.DebugService:RegisterState("Coins", function(player) return coinsOf(player) end)
-- Call them from a client (or the Studio MCP's execute_luau in Play, client side):
--     Net.Debug:InvokeServer("GiveCoins", 10000)  --> true, <result>  |  false, "<why>"
--     Net.Debug:InvokeServer("Dump")              --> true, { Coins = 10000, ... }

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local GameConfig = require(ReplicatedStorage.Shared.Config.GameConfig)
local Net = require(ReplicatedStorage.Shared.Net)

type Command = (player: Player, ...any) -> any
type StateProvider = (player: Player) -> any

local commands: { [string]: Command } = {}
local stateProviders: { [string]: StateProvider } = {}

local DebugService = {}

function DebugService:Register(name: string, command: Command)
	assert(commands[name] == nil, "debug command registered twice: " .. name)
	commands[name] = command
end

function DebugService:RegisterState(name: string, provider: StateProvider)
	assert(stateProviders[name] == nil, "debug state registered twice: " .. name)
	stateProviders[name] = provider
end

local function isAllowed(player: Player): boolean
	if RunService:IsStudio() then
		return true
	end
	return GameConfig.DEBUG_ON_LIVE and table.find(GameConfig.ADMIN_USER_IDS, player.UserId) ~= nil
end

function DebugService:Init(_registry: { [string]: any })
	DebugService:Register("List", function()
		local names = {}
		for name in commands do
			table.insert(names, name)
		end
		table.sort(names)
		return names
	end)

	-- Everything registered with RegisterState, for this player. One provider failing doesn't
	-- hide the others: its entry becomes "error: <message>".
	DebugService:Register("Dump", function(player: Player)
		local state = {}
		for name, provider in stateProviders do
			local ok, value = pcall(provider, player)
			state[name] = if ok then value else "error: " .. tostring(value)
		end
		return state
	end)
end

function DebugService:Start()
	Net.Debug.OnServerInvoke = function(player: Player, name: unknown, ...: any)
		if not isAllowed(player) then
			return false, "not allowed"
		end
		if typeof(name) ~= "string" or commands[name] == nil then
			return false, "unknown command"
		end
		if not RunService:IsStudio() then
			warn(string.format("[debug] LIVE command %s by %s (%d)", name, player.Name, player.UserId))
		end
		return pcall(commands[name], player, ...)
	end
end

return DebugService
