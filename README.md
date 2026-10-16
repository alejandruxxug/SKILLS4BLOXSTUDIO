# SKILLS4BLOXSTUDIO

Open-source [Claude Code](https://claude.com/claude-code) skills for building and testing Roblox games through **Roblox Studio's MCP server**.

## Skills

| Skill | What it does |
|---|---|
| [`roblox-playtest`](skills/roblox-playtest/SKILL.md) | A blind, first-time-player playtest: Claude starts Play in Studio, goes through your game like a brand-new player who knows nothing about it, then gives you a short report (best moments, bugs, confusion, polish, top 3 fixes) plus a full evidence-backed report a coding agent can plan fixes from. It separates real bugs from tester artifacts (its own latency, Studio overlays, test-mode timers) so you don't chase ghosts. |
| [`game-mechanic`](skills/game-mechanic/SKILL.md) | Turns a rough mechanic idea (eggs, gacha, shops, inventories, spin wheels, quests...) into a build-ready spec. Claude first reads your game (design notes, configs, saved data) so every question says how the mechanic plugs into what you already have. It then asks easy, kid-readable multiple-choice questions in rounds (money → rules → where → feel → onboarding → extras) and flags paid-random-item / PolicyService issues honestly. Finally it writes a `.md` with numbered rules, odds tables, animation beats, data + migration, remotes, edge cases, a build order and a decision log, and offers to build it. If you're away, it takes the recommended calls and lists them as assumptions. |
| [`roblox-robux-audit`](skills/roblox-robux-audit/SKILL.md) | A read-only audit of every Robux path before real players pay. Claude traces each developer product and pass from the buy button to the saved grant (ProcessReceipt, saving and session locks, passes, PolicyService / paid random items, odds, store copy, prices on screen, refunds, remotes) and reports every way a kid could be charged and get less than promised, get it twice, or get it for free, each with a concrete scenario, a file:line and a fix that was itself checked for exploits. You get a verdict ("safe to sell?"), 🔴/🟡/🟢 findings and a table of every item. It never edits your code. |
| [`roblox-bug-solver`](skills/roblox-bug-solver/SKILL.md) | Solves a bug the way a senior dev would. Claude asks a few plain-language questions about what you actually saw, traces the code, and **reproduces the bug in Studio** (Play, console, attributes, remotes, a stop/start rejoin when saved data is involved). Then it explains **why it happened** (a player-steps story, the root cause with file:line, the repro evidence, why your tests missed it) and **how it will fix it** (files, edge cases, saved-data changes). It waits for your OK, makes the smallest fix in your code's style, reruns the same repro to prove the bug is gone, and tells you how to test it yourself. |
| [`roblox-sound-pass`](skills/roblox-sound-pass/SKILL.md) | A full sound pass through the Studio MCP. Claude audits every sound and finds what repeats, proposes a sound plan you pick from, sources licensed music and SFX from Roblox's audio library (search, load-check, key detection), and builds a pooled sound engine: shuffle bags, micro-jitter, celebration tiers, layered hero hits, streak ladders, ducking, room reverb, rotating playlists, tape-stops and babble voices. An in-game 🎧 audition panel lets you pick takes by ear, and Claude bakes your picks back into code. |
| [`roblox-game-init`](skills/roblox-game-init/SKILL.md) | Starts a new game the right way on day 0. A plain-language interview (pitch, audience, the v0.1 "is it fun?" goal, **build mode**: greybox first or art first), then a design knowledge base in the repo's `docs/` (Obsidian-friendly), a Rojo + StyLua scaffold with a Services/Controllers bootstrap, one `Net` remotes list, Config, and a **debug backdoor** (`DebugService`: jump to any state and `Dump` it back, off on live servers, Studio saves kept apart from live data). It proves the wiring with a smoke Play through the Studio MCP and makes the first commit. **Simple** mode stops there; **Full studio** adds an Opus/Sonnet agent team (art, lead, builder, tester, run by the main session in small batches with briefs) and a Figma board. |
| [`roblox-art-pass`](skills/roblox-art-pass/SKILL.md) | Turns a spec's "Assets needed" list into approved, in-game art. Claude collects your sketches and references (and models against them), lists every asset and routes each to the right tool: **Blender** (via the blender MCP) for 3D, code-built parts as the fallback, **Figma** for UI and icons, Aseprite for pixel art, Canva/SVG for illustrations. Approval happens where it's truest: UI as the Figma frame before it's built, 3D as a **Studio screenshot** in a Review Room next to a character. Everything lands on the game's Figma board and is logged in its docs; asset ids go into config for the builder. Respects the build mode (no final art before the loop is approved in greybox-first games). |

## Requirements

- Claude Code
- Roblox Studio with the Studio MCP server connected (the `mcp__roblox-studio__*` tools)
- `roblox-game-init`: Rojo and StyLua (`gh` optional, for creating the GitHub repo)
- `roblox-art-pass` (optional per tool): Blender + the [blender MCP](https://github.com/ahujasid/blender-mcp), a Figma MCP, the Aseprite MCP

## Install

Copy (or symlink) a skill folder into your Claude Code skills directory:

```bash
git clone https://github.com/alejandruxxug/SKILLS4BLOXSTUDIO.git
mkdir -p ~/.claude/skills
ln -s "$PWD/SKILLS4BLOXSTUDIO/skills/roblox-playtest" ~/.claude/skills/roblox-playtest
```

Then open your place in Studio and ask Claude something like *"playtest my game as a brand-new player"*.

**Suggested flow:** `roblox-game-init` → `game-mechanic` → build (greybox) → `roblox-playtest` → `roblox-art-pass` → `roblox-sound-pass` → `roblox-robux-audit` before launch, and `roblox-bug-solver` whenever something breaks.

## Layout

```
skills/
└── <skill-name>/
    ├── SKILL.md        the skill (frontmatter + instructions)
    ├── references/     guides the skill loads when it needs them
    ├── scripts/ assets/  helpers and templates (some skills)
    └── evals/          test prompts used to evaluate it (some skills)
```

## Contributing

Issues and PRs welcome, especially lessons learned from driving Studio through MCP (input quirks, timing gotchas) that make the skills more reliable.

## License

[MIT](LICENSE)
