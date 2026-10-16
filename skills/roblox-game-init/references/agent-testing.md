# Agent testing: the easy way in

Testing a Roblox game by *playing* it through MCP is slow and flaky: a 5-minute round to reach the
boss, clicks that miss, prompts that only fire on screen. The fix is the same idea as a desktop
game's `-agent` flag: **a backdoor that jumps straight to a state and reads the state back as
data.** In Roblox that's `DebugService` (scaffolded) + the Studio MCP.

## What the tester can do

| Need | Desktop game (`-agent`) | Roblox (this scaffold) |
|---|---|---|
| Jump to a state | `-scene day.reception -day 3` | `Net.Debug:InvokeServer("SkipToRound", 3)` |
| Set up the player | flags | `Net.Debug:InvokeServer("GiveCoins", 500)` |
| Read the state | `-dump state.json` | `Net.Debug:InvokeServer("Dump")` → a table of every registered state |
| Deterministic randomness | `-seed 7` | a `SetSeed` command feeding the services' `Random.new(seed)` (add it when the game has randomness) |
| Scripted input | an input script | call the same remotes the UI calls, or click GUI by `instance_path` through the MCP |
| Screenshot | `-shot` | `screen_capture` |
| Console | stdout | `get_console_output` |

## How it lands in Studio

```
tester (Sonnet)
  │  start_stop_play (start)
  │  execute_luau (client side, in Play):
  │     local Net = require(game.ReplicatedStorage.Shared.Net)
  │     return Net.Debug:InvokeServer("GiveCoins", 500)
  ▼
Net.Debug  (RemoteFunction in ReplicatedStorage.Net)
  ▼
DebugService (server): allowed? → known command? → pcall(command, player, 500)
  ▼
returns  true, <result>   or   false, "not allowed" / "unknown command" / "<error>"
  │
  │  execute_luau: return Net.Debug:InvokeServer("Dump")   → check the numbers
  │  screen_capture                                          → check the screen
  │  get_console_output                                      → check for errors
  ▼
report: ✅/❌ per test step, with the exact commands to reproduce
```

Rules for testers:
- Call the backdoor from the **client** side of Play, like a real player's request. On the server
  side, `require` of a service returns a fresh, uninitialized copy, so calling services directly
  tests nothing.
- Prefer `Dump` over screenshots for numbers; use screenshots for what the player *sees*.
- Every test step in a batch brief is written as backdoor calls + the expected `Dump`, so any agent
  can rerun it exactly.

## Adding commands (builders)

Every state a tester needs gets a command, added in the service that owns it:

```lua
function ShopService:Init(registry)
	registry.DebugService:Register("GiveCoins", function(player: Player, amount: unknown)
		assert(typeof(amount) == "number" and amount > 0 and amount <= 1e9, "amount must be 1..1e9")
		return self:AddCoins(player, amount)
	end)
	registry.DebugService:RegisterState("Coins", function(player: Player)
		return self:GetCoins(player)
	end)
end
```

Commands go through the **same service methods** the real game uses, so a test exercises real
code paths. List each new command in Architecture → Debug backdoor.

## How secure is it

| Threat | What stops it |
|---|---|
| An exploiter on a live server calls `Net.Debug` | `DEBUG_ON_LIVE = false` by default: every call returns "not allowed". The check runs on the server |
| An exploiter fakes being an admin | The server gets the caller's `Player` from Roblox; the UserId can't be forged by the client |
| An exploiter learns the command names | `List` is behind the same check. The remote's existence leaks only the word "Debug" |
| Bad arguments crash a service | Every command runs in `pcall`, and commands validate their arguments anyway |
| Your admin account is compromised, or you test on live | Live use needs `DEBUG_ON_LIVE = true` on purpose, and every live call is logged with a `warn`. Turn it back off after |
| **Tests in Studio overwrite real saves** | The big one. Studio with API access writes to the published game's real DataStores. `GameConfig.DATA_SCOPE` is `"studio"` in Studio: the save service must use it as the DataStore scope, so tests and debug commands never touch live data |

What it does **not** protect against: logic bugs in a command itself (a `GiveCoins` with no upper
bound on live). Keep commands small, validated, and built on the real service methods. Before a
public launch, `roblox-robux-audit` reads the backdoor too.

## Studio quirks to expect

- `RunService:IsStudio()` is also true in Team Test, so collaborators in Team Test can use the
  backdoor. That's usually what you want.
- If `Net.Debug` doesn't exist, Rojo isn't synced or DebugService errored in Start: read the console.
- A Play started by the developer may be running old code. Check before testing (ask, or compare
  a script's Source with the file).
