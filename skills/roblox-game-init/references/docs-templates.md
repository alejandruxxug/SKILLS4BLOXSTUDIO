# Knowledge base templates

Six notes in `docs/`, named `<Game> – <Note>.md` (en dash). Fill them from the interview, in the
developer's words. Short is fine: each note grows with the game. Emoji section headers and tables
read well in Obsidian and on GitHub.

---

## `<Game>.md` (the hub)

```markdown
# <emoji> <GAME NAME>

> <one-sentence pitch>. Started <YYYY-MM-DD>.

## 🗂️ Knowledge base
| Note | What's inside |
|---|---|
| [[<Game> – Game Design]] | Core loop, v0.1 scope, the design log |
| [[<Game> – Architecture]] | How the code is organized and why |
| [[<Game> – Build Plan]] | Milestones, lanes, progress log; batch briefs in `Batches/` |
| [[<Game> – Style Guide]] | Visual direction, palette, 3D/UI rules, art log |
| [[<Game> – Tools & Setup]] | Tools, versions, every-session checklist |

**Repo:** `<path>` · <GitHub URL or "local only"> · **Figma board:** <file name / link>

## ⚡ The game in 30 seconds
| | |
|---|---|
| 🎮 **Genre** | ... |
| 👥 **Players** | age, phone/PC, solo/multiplayer |
| 🔁 **Core loop** | verb → reward → spend → bigger verb |
| 🎯 **v0.1 goal** | "Is it fun?" = <the signal they'll watch for> |
| 🧱 **Build mode** | Mechanic-led → greybox first, art after the loop is approved · or Visual-led → art first (style test + one scene) |

## 🧭 Non-negotiables
1. ...

## 🤔 Assumptions (took the recommended option; overturn any)
| Decision | Picked | Why |

## ❓ Open questions
```

## `<Game> – Game Design.md`

```markdown
# 🎮 <Game>: Game Design
> Part of [[<Game>]].

## 🔁 Core loop
## 🎯 v0.1: "Is it fun?"
What's in: ... · What's cut (for now): ... · The friends test: ...
## 🧩 Systems (one line each; each gets its own spec note via game-mechanic)
## 📓 Design log
| Date | Decision | Why |
|---|---|---|
| <today> | <each interview decision> | <their words> |
```

## `<Game> – Architecture.md`

```markdown
# 🏛️ <Game>: Architecture
> Part of [[<Game>]]. Written before the first line of game code.

## 📦 Where the code lives
Repo, Rojo mapping (src/shared → ReplicatedStorage.Shared, src/server → ServerScriptService.Server,
src/client → StarterPlayerScripts.Client), file suffixes, "edit files, never Studio".

## 🧭 Principles
| # | Principle | What it means here |
(server authority · single responsibility · pure logic separate from Roblox I/O · config-driven ·
events not polling (Signal) · Init/Start lifecycle · clean up with Trove · --!strict)

## 🗂️ Folder structure
(tree with a one-line job per module; grows as systems are added)

## 🛠️ Debug backdoor
`DebugService` commands table: name · args · what it does · added in batch.

**Rule of thumb:** Shared = rules and data both sides agree on. Server = truth and money.
Client = display and input. The client never requires a server module.
```

## `<Game> – Build Plan.md`

```markdown
# 🗓️ <Game>: Build Plan
> Part of [[<Game>]]. Each milestone leaves a playable game.

## ⏳ Waiting on you
| What | Why it's blocking | Where to look | Since |
|---|---|---|---|
(approvals, Import 3D clicks, playtests: asked in groups, cleared at the start of each session)

## 🧱 Milestones
Order depends on the build mode.

**Mechanic-led (greybox first):**
| # | Milestone | Done when |
|---|---|---|
| **M0** | Foundation | Smoke Play prints server ready, client ready, ping ok |
| **M1** | Core loop, greybox | Playable start to finish with placeholders + feel (sounds, pops) |
| **M2** | 🧪 Loop approved | Developer + friends playtest; the "is it fun?" signal seen. Cut or change what isn't |
| **M3** | Art pass | `roblox-art-pass` on the approved mechanics: style test first, then everything |
| **M4** | Polish + release prep | |

**Visual-led (art first):**
| # | Milestone | Done when |
|---|---|---|
| **M0** | Foundation | Smoke Play passes |
| **M1** | 🎨 Look locked | Style test + one finished scene approved |
| **M2** | Scenes + simple mechanics | Every scene built in the approved look; mechanics kept minimal |
| **M3** | 🧪 Playtest | The experience works start to finish |
| **M4** | Polish + release prep | |

## 🛣️ Lanes (only if several sessions)
| Lane | Owns | Depends on |

## 📦 Batches
Briefs live in `Batches/` (B001, B002…). See CLAUDE.md → Agent workflow.

## ✅ Progress log
| Date | What | Result |
```

## `<Game> – Style Guide.md`

```markdown
# 🎨 <Game>: Style Guide
> Part of [[<Game>]]. The rules every asset follows. Grows with roblox-art-pass.

## 🧭 Direction in one line
## 🖼️ Inputs from the developer
Files live in `Art/Sketches/` (their drawings) and `Art/References/` (screenshots, photos, games).
| File | Kind (sketch / reference / style) | For which asset | What to take from it | Added |
Games they love: <name> → what to take (shape language? colors? UI feel?)
## 🎨 Palette (hex, role: primary, accent, danger, background, outline)
## 🔤 Fonts (Roblox built-in names; titles vs body)
## 🟦 UI shape language (corners, outlines, gradients, button feel)
## 🧊 3D style (low-poly / blocky / realistic; triangle budget; texture approach; outline?)
## 📓 Art log
| Date | Asset | From sketch/ref | Tool | Check (Blender design · Studio) | Verdict | Asset id |
```

## `<Game> – Tools & Setup.md`

```markdown
# 🛠️ <Game>: Tools & Setup
> Part of [[<Game>]].

| Tool | Version | Notes |
(Rojo, StyLua, git/gh, Roblox Studio MCP, Blender + blender MCP, Figma MCP, Aseprite...)

## 🔌 Every session
1. Open the place in Studio
2. Enable the Studio MCP server (Assistant → Manage MCP Servers)
3. `rojo serve` → Plugins → Rojo → **Connect**
4. Blender work: open Blender → sidebar (N) → MCP for Blender → Start MCP Server
5. Figma work: open the game's Figma file with the Figma MCP's plugin running, if it needs one
6. Save a copy of the place before big sessions

## ⚠️ Things only the developer can do
(publish the place, enable Studio API access, upload meshes through the 3D Importer, create Open Cloud keys)
```
