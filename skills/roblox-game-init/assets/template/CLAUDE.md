# CLAUDE.md

Guidance for Claude Code sessions in this repo. The developer gives short instructions like "build the shop" or "fix the round timer". This file and `docs/` hold everything you need to act on them without asking for context.

## What this is

**{{GAME_NAME}}**: <!-- FILL: the one-sentence pitch, genre, audience (age, phone/PC) -->

**Build mode:** <!-- FILL: "Mechanic-led: greybox first. Build every mechanic with tidy placeholders (right size, Style Guide colors, labels, sounds and pops kept); no final art until the loop is approved in a playtest." OR "Visual-led: art first. Style test + one finished scene approved before the rest; mechanics stay simple until the look is locked." --> A mechanic's spec can override this.

## The knowledge base: `docs/`

`docs/` is the design knowledge base. <!-- FILL if Obsidian: It's the same folder the developer sees in Obsidian (`<vault path>` is a symlink to it), so anything you write there shows up in their vault immediately. Notes use `[[WikiLinks]]`. --> Note names use an en dash: `[[{{GAME_NAME}} – Game Design]]` means `docs/{{GAME_NAME}} – Game Design.md`.

| Note | Read it when |
|---|---|
| `docs/{{GAME_NAME}}.md` | Always first: the hub, non-negotiables, open questions |
| `docs/{{GAME_NAME}} – Game Design.md` | Anything about gameplay; the **design log** is at the bottom |
| `docs/{{GAME_NAME}} – Architecture.md` | Writing code: principles, folder tree, where new code goes |
| `docs/{{GAME_NAME}} – Build Plan.md` | Picking what to do next: milestones, lanes, the **progress log** |
| `docs/{{GAME_NAME}} – Style Guide.md` | Anything visual: palette, fonts, UI shapes, 3D style rules, the art log |
| `docs/{{GAME_NAME}} – Tools & Setup.md` | Tools, versions, the every-session checklist |

**Figma board:** <!-- FILL: file name + key, and which Figma MCP to use --> The game's visual board: pages 🖼️ Inputs, 🎨 Style, 🧪 Reviews, ✅ Approved, plus UI pages. Every sketch, review screenshot and approved asset lands there (`roblox-art-pass`).

**Keep the docs current as you work:**
- Finished something → a row in the Build Plan's **progress log**, tick the milestone.
- The developer decided something → a row in the Game Design **design log** (date, decision, why, in their words).
- Notes are written for the developer: plain English, tables, short sentences.

## Commands

```bash
rojo serve      # sync src/ into Studio (then Plugins → Rojo → Connect)
stylua src      # format; run FROM THE REPO ROOT so stylua.toml is used
```

## Code rules

- **Edit code in files, never in Studio.** Rojo overwrites Studio edits. Studio is for playtests, 3D building and screenshots.
- **Server is the authority.** The client only asks (remotes in `Shared/Net`); the server validates and is the only place currency, items or saves change.
- Services (server) / Controllers (client): `:Init(registry)` wires dependencies (never yields), `:Start()` runs. A new one is just a ModuleScript in `Services/` or `Controllers/`; the bootstraps pick it up.
- `--!strict` on every module. Classes = `.new` + `__index`. Tunables in `Shared/Config`. Clean up with `Trove`.

## Non-negotiables (the developer's rules)

<!-- FILL: 3–5 rules from the interview, numbered, in their words -->

## Studio MCP

Use the `roblox-studio` MCP for Play, console, screenshots and `execute_luau`.

- After the place is reopened, Rojo must be reconnected (the developer clicks Connect), or file edits silently never reach Studio. Check a script's Source in Edit before testing.
- Ask before starting or stopping Play: the developer may be playing.
- `require` inside `execute_luau` returns a fresh, uninitialized module copy: test through remotes or admin commands, not by calling services directly.
- Things built in Studio by hand (lighting, terrain, a hand-built map) live in the place file, not in Rojo: they survive only after **Ctrl+S / publish**.
- **Testing = the backdoor.** Jump to states with `Net.Debug:InvokeServer("<Command>", ...)` and read them back with `Net.Debug:InvokeServer("Dump")`, from the client side of Play. Every new testable state gets a command (`DebugService:Register`) and its numbers a `RegisterState`. Off on live servers unless `GameConfig.DEBUG_ON_LIVE`.
- **Studio saves hit the real DataStores** when API access is on. The save service must use `GameConfig.DATA_SCOPE` ("studio" in Studio) as its DataStore scope.
<!-- FILL: add each new Studio gotcha here the day it's found -->

## Agent workflow: Opus thinks, Sonnet builds and tests

Four project agents live in `.claude/agents/`. **The main session is the orchestrator**: it plans, splits work into small batches, starts agents, relays issues and commits. It doesn't write feature code itself (subagents can't start other subagents, so the orchestrator has to be the main session).

| Agent | Model | Job |
|---|---|---|
| `art` | Opus | Every visual: Blender models, Figma UI, previews, VISUAL issues |
| `lead` | Opus | Confirms WEIRD issues (and BUGs whose first fix failed), finds the root cause, writes fix orders; reviews risky batches (Robux, saves, remotes) |
| `builder` | Sonnet | Implements one batch brief or fix order, inside its listed files |
| `tester` | Sonnet | Plays the batch in Studio via `Net.Debug`, reports BUG / WEIRD / VISUAL; never fixes |

**The loop, per batch** (a batch = one small slice with a "done when", a few files):
1. Orchestrator writes the brief in `docs/Batches/B<nnn> – <name>.md` (goal, files allowed, spec rules R#, done when, test steps).
2. **Fresh** `builder` builds it → **fresh** `tester` tests it. New agents every batch keep context light; the brief carries everything they need.
3. Issues, routed by how clear they are:
   - **BUG with an obvious cause** (an error with a file:line, a wrong number in config) → straight to a fresh `builder` with the tester's evidence. If that fix fails once → `lead`.
   - **WEIRD** (unexplained behavior) → `lead` (Opus) confirms + writes the fix order → fresh `builder`.
   - **VISUAL** → `art` (Opus) confirms + fixes or orders.
   Then the same `tester` steps again.
4. Green → risky batch? `lead` reviews first. Then the orchestrator commits that batch's files by path and adds a progress-log row.
5. **Two failed fix rounds on the same issue → stop and ask the developer.** Don't loop.

**Never idle on the developer.** Their approvals and clicks (Figma ✅, Studio screenshot ✅, Import 3D, Rojo Connect, playtests) are the slowest part of the pipeline. Collect them in the Build Plan's **⏳ Waiting on you** table and ask for them **in groups** (one review section, one question), not one at a time. While something waits, keep building batches that don't depend on it.

**Fast lane:** tiny changes (one file, a few lines, no Robux/saves/remotes: a typo, a tuning number, a color) the orchestrator makes itself, runs a quick check, and commits. No brief, no agents. Use batches for anything a tester should play.

**Shared files** (`Shared/Net.luau`, config index modules, `default.project.json`) are edited by the orchestrator only; builders list what they need added in their report. Parallel builders otherwise collide there.

Builders may run in parallel on separate files; **only one tester uses Studio Play at a time** (Studio is the real speed limit, so size batches for the tester). Visuals are never coded before the developer approves the art. Testers check that things *work*; whether they're *fun* is decided by the developer's own playtests (and `roblox-playtest`) at the Build Plan's 🧪 milestones.

## Git

- Commit after each finished feature, `stylua` clean, messages in English. **Never push** unless the developer asks.
<!-- FILL if parallel sessions: lanes (who owns which folders), one Play session at a time, commit only your own files by path, ListAgents at session start -->

## Layout

```
src/shared/   → ReplicatedStorage.Shared       Config, Net, Util (Signal, Trove), pure classes
src/server/   → ServerScriptService.Server     Main bootstrap, Services
src/client/   → StarterPlayerScripts.Client    Main bootstrap, Controllers, UI
docs/         the knowledge base (Batches/ = one brief per build batch)
assets/       art sources (.blend, .aseprite, svg) and exports
.claude/agents/  art, lead (Opus) · builder, tester (Sonnet)
```
