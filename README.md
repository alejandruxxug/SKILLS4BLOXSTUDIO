# SKILLS4BLOXSTUDIO

Open-source [Claude Code](https://claude.com/claude-code) skills for building and testing Roblox games through **Roblox Studio's MCP server**.

## Skills

| Skill | What it does |
|---|---|
| [`roblox-playtest`](skills/roblox-playtest/SKILL.md) | A blind, first-time-player playtest: Claude starts Play in Studio, goes through your game like a brand-new player who knows nothing about it, then reports what works, real bugs, where a new player gets confused, polish issues, and the top 3 things to fix. |

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
