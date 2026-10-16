# What the scaffold creates, and why

`scripts/scaffold.py` copies `assets/template/` and replaces `{{GAME_NAME}}` / `{{GAME_SLUG}}`.
Read this when the developer wants their own architecture or you're migrating an existing game:
keep the *jobs* below even if the files change shape.

| File | Job | Keep it because |
|---|---|---|
| `default.project.json` | Rojo map: `src/shared` → `ReplicatedStorage.Shared`, `src/server` → `ServerScriptService.Server`, `src/client` → `StarterPlayerScripts.Client` | Files become the source of truth; Studio becomes a viewer |
| `stylua.toml` | Formatter config (tabs, 110 cols) | Diffs stay about logic, not whitespace. Run from the repo root |
| `.gitignore` | Ignores place files, `sourcemap.json`, `.obsidian/`, `CLAUDE.local.md` | Place files are binary and huge; the code lives in `src/` |
| `src/server/Main.server.luau` | Requires every module in `Services/`, calls `Init(registry)` on all, then `Start()` on all | Init/Start split means services can reference each other without load-order bugs |
| `src/client/Main.client.luau` | Same for `Controllers/` | The client mirrors the server |
| `src/shared/Net.luau` | Defines every RemoteEvent/RemoteFunction in one list; server creates, client waits | One file to audit for "what can the client ask the server?" |
| `src/server/Services/DebugService.luau` | The agent backdoor: named commands (`GiveCoins`, `SkipToRound`) + `Dump` of registered state. Always on in Studio, off on live unless `DEBUG_ON_LIVE` (then admin ids only, logged) | Testers jump to a state in one call and read numbers back instead of guessing. Details + security: `agent-testing.md` |
| `src/server/Services/PingService.luau` + `src/client/Controllers/PingController.luau` | The smoke test: one remote round trip, prints `[init] ping ok` | Proves server, client, Net and Rojo all work. Delete once real systems exist |
| `src/shared/Config/GameConfig.luau` | First config module; `DEBUG_ON_LIVE`, `ADMIN_USER_IDS`, `DATA_SCOPE` | Every tunable number lives in Config; `DATA_SCOPE` keeps Studio tests out of live saves |
| `src/shared/Util/Signal.luau` | Tiny event class | Systems announce changes instead of polling |
| `src/shared/Util/Trove.luau` | Cleanup bag | Screens and objects destroy what they made; no leaks |
| `CLAUDE.md` | What every future agent reads first: note index, commands, rules, Studio gotchas, agent workflow | Without it, each session re-learns the project. Fill every `<!-- FILL -->` |
| `.claude/agents/{art,lead,builder,tester}.md` | The Opus/Sonnet team | See `agent-workflow.md` |
| `docs/Images/`, `docs/Batches/` | Screenshots; one brief per build batch | Notes and briefs live next to the code |
| `assets/src/`, `assets/models/` | `.blend` / `.aseprite` / svg sources; exported meshes | Art sources are versioned like code |
| `README.md` | Setup + structure for humans | |

## Migrating an existing place

1. Export its scripts first: for each script, `script_read` through the Studio MCP and write it to
   the matching `src/` path with the right suffix. Keep their names and their code.
2. Run the scaffolder; it refuses to overwrite, so move conflicting files aside or merge by hand.
3. Their bootstrap may differ (a single `init` script, a framework like Knit). Don't rewrite working
   code to match the template: point the Architecture note at what they have, and use the template
   pieces they're missing (Net list, DebugService, Config, CLAUDE.md).
4. Rojo connect, then check nothing got duplicated (scripts that existed in Studio *and* now come
   from Rojo). Delete the Studio copies only after the developer confirms.

## Their own architecture

If they picked "my own" in the interview, keep: one remotes list, a debug backdoor, Config for
numbers, server authority, and a CLAUDE.md. Those five are what make the agent workflow work; the
rest is taste.
