# SKILLS4BLOXSTUDIO

Open-source [Claude Code](https://claude.com/claude-code) skills for building and testing Roblox games through **Roblox Studio's MCP server**.

## Skills

| Skill | What it does |
|---|---|
| [`roblox-playtest`](skills/roblox-playtest/SKILL.md) | A blind, first-time-player playtest: Claude starts Play in Studio, goes through your game like a brand-new player who knows nothing about it, then gives you a short report (best moments, bugs, confusion, polish, top 3 fixes) plus a full evidence-backed report a coding agent can plan fixes from. It separates real bugs from tester artifacts (its own latency, Studio overlays, test-mode timers) so you don't chase ghosts. |
| [`game-mechanic`](skills/game-mechanic/SKILL.md) | Turns a rough mechanic idea (eggs, gacha, shops, inventories, spin wheels, quests...) into a build-ready spec. Claude first reads your game (design notes, configs, saved data) so every question says how the mechanic plugs into what you already have. It then asks easy, kid-readable multiple-choice questions in rounds (money → rules → where → feel → onboarding → extras) and flags paid-random-item / PolicyService issues honestly. Finally it writes a `.md` with numbered rules, odds tables, animation beats, data + migration, remotes, edge cases, a build order and a decision log, and offers to build it. If you're away, it takes the recommended calls and lists them as assumptions. |
| [`roblox-robux-audit`](skills/roblox-robux-audit/SKILL.md) | A read-only audit of every Robux path before real players pay. Claude traces each developer product and pass from the buy button to the saved grant (ProcessReceipt, saving and session locks, passes, PolicyService / paid random items, odds, store copy, prices on screen, refunds, remotes) and reports every way a kid could be charged and get less than promised, get it twice, or get it for free, each with a concrete scenario, a file:line and a fix that was itself checked for exploits. You get a verdict ("safe to sell?"), 🔴/🟡/🟢 findings and a table of every item. It never edits your code. |

## Requirements

- Claude Code
- Roblox Studio with the Studio MCP server connected (the `mcp__roblox-studio__*` tools)

## Install

Copy (or symlink) a skill folder into your Claude Code skills directory:

```bash
git clone https://github.com/alejandruxxug/SKILLS4BLOXSTUDIO.git
mkdir -p ~/.claude/skills
ln -s "$PWD/SKILLS4BLOXSTUDIO/skills/roblox-playtest" ~/.claude/skills/roblox-playtest
```

Then open your place in Studio and ask Claude something like *"playtest my game as a brand-new player"*.

## Layout

```
skills/
└── <skill-name>/
    ├── SKILL.md        the skill (frontmatter + instructions)
    └── evals/          test prompts used to evaluate it
```

## Contributing

Issues and PRs welcome, especially lessons learned from driving Studio through MCP (input quirks, timing gotchas) that make the skills more reliable.

## License

[MIT](LICENSE)
