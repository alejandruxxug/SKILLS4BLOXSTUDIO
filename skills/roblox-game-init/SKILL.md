---
name: roblox-game-init
description: >
  Start a new Roblox game the right way on day 0: interview the developer in plain language (pitch,
  audience, the v0.1 "is it fun?" goal, style, how they work), then write the game's knowledge base
  in the repo's docs/ folder (hub, Game Design with a design log, Architecture, Build Plan with
  "done when" milestones, Style Guide, Tools & Setup) and collect their sketches and reference art,
  scaffold a Rojo + StyLua project with a Services/Controllers bootstrap, Net remotes, Config, a
  debug backdoor, a CLAUDE.md and an Opus/Sonnet agent team (art, lead, builder, tester run by an
  orchestrating main session in small batches), connect Roblox Studio through
  the Studio MCP and prove it with a smoke Play (server + client + one remote round trip), make the
  first commit, and hand off to game-mechanic for the first system. Use this whenever the user wants
  to start, set up, bootstrap, scaffold, initialize or "init" a new Roblox game or place, says "I have
  a new game idea, let's set it up", "new project", "fresh place", "set up Rojo", or wants an existing
  messy place moved into files with docs, even if they never say "init". Not for designing a single
  mechanic (game-mechanic), fixing bugs (roblox-bug-solver) or playtesting (roblox-playtest).
user-invocable: true
---

# Roblox game init

A new game usually starts as a Studio place with scripts typed straight into it, design decisions
living in someone's head, and the first week spent rediscovering Studio's traps. This skill makes
day 0 boring on purpose: **by the end the developer has a repo where design notes, code and Studio
are wired together, a first Play proves the wiring works, and every future session (human or agent)
knows where everything goes.**

What makes it work:

1. **Docs before code, in the repo.** The design lives in `docs/` next to the code, written for the
   developer (plain words, tables). If they use Obsidian, `docs/` is symlinked into their vault, so
   one set of files serves both. A `CLAUDE.md` tells future agents which note to read for what.
2. **A skeleton that runs, not a framework.** Empty Services/Controllers with a real lifecycle, one
   remote round trip, Config modules. Nothing game-specific gets built here; that's `game-mechanic`
   and the sessions after it.
3. **Day-0 traps caught on day 0.** Rojo not connected, API access off, StreamingEnabled hiding
   things: each is checked once now instead of costing an afternoon in week two.

## 0. Look before you ask (2 minutes)

- Is there already a repo, a `default.project.json`, a `docs/` folder, a CLAUDE.md? Is a place open
  in Studio (`get_studio_state`, `search_game_tree`)? If a game already exists, this becomes a
  **migration**: keep their code and names, move it under the layout, and say so in the interview.
- Tools: `rojo --version`, `stylua --version`, `git --version`, `gh --version`, and whether a
  toolchain manager is used (`rokit.toml` / `aftman.toml` / `foreman.toml`). Art MCPs for later:
  `claude mcp list` for blender, a Figma MCP, aseprite. Missing tools are reported and their
  install command offered; don't install without a yes.
- Where the developer keeps notes: a CLAUDE.md, memory, an Obsidian vault path they've mentioned.

## 1. Simple or Full studio (ask first)

One question before the interview, because it decides how much of this skill runs:

- **Simple (Recommended for a first game):** the docs, the Rojo scaffold with the debug backdoor,
  the smoke Play, the first commit. One Claude session builds; no agent team, no Figma board.
  Everything still works with the other skills.
- **Full studio:** all of the above plus the build mode, the Opus/Sonnet agent team with batch
  briefs, the art inputs and the Figma board. For developers who'll run several agents and want
  the full art pipeline.

Say it plainly: "Simple gets you building today; you can switch to Full later by running this
skill again on the repo (it only adds what's missing)." (That rerun uses `scaffold.py
--add-missing`, then fills the new CLAUDE.md sections by hand, since CLAUDE.md already exists.) If the developer's CLAUDE.md or memory
says they always want Full, skip the question. In Simple mode skip round 4's Figma board, the
agent-team question and `references/agent-workflow.md`, and scaffold with `--simple`.

## 2. Interview

Use `AskUserQuestion` (up to 4 questions per round, 2–4 options, recommended first with
"(Recommended)"). Questions must be answerable in 5 seconds by a teen developer, and each option
says what will actually happen. Three rounds is usually enough:

1. **The game**: name, one-sentence pitch, genre (simulator, tycoon, obby, round-based, story...),
   who plays it (age, phone vs PC). Let them answer in free text; that's often the best answer.
2. **v0.1**: the smallest version that answers "is it fun?" (one map, the core loop, one reward),
   and how they'll know (friends ask for one more round? they come back tomorrow?). Plus 3–5
   **non-negotiables** they already feel strongly about (e.g. "Robux never buys power", "every
   round under 5 minutes").
   **And the build mode**, the most important question here. Ask it in plain words: *"What makes
   a friend say 'whoa' in the first 30 seconds: how it looks, or what you get to do?"*
   - **Mechanic-led** (simulators, tycoons, obbies, round-based): **greybox first**. Every
     mechanic is built with tidy placeholders, playtested, and only after the loop is approved
     does `roblox-art-pass` do the full art. Spending on art for a mechanic that gets cut after
     the first playtest is the classic waste.
   - **Visual-led** (story, horror, exploration, showcase): **art first**. The look *is* the
     experience, so a style test + one finished scene comes before the rest, and mechanics stay
     simple until the look is locked.
   Write the mode into the hub, the Build Plan (it decides the milestone order, see
   `references/docs-templates.md`) and CLAUDE.md. It's the game's **default**; each mechanic can
   override it in `game-mechanic` (a door-kick entrance in a mechanic-led game *is* its visuals).
3. **How you work**: where notes go (repo `docs/` (Recommended), + Obsidian symlink, or elsewhere),
   architecture (Services/Controllers (Recommended) or their own), the agent team (Opus art + lead,
   Sonnet builder + tester, the main session orchestrating (Recommended), or solo), git remote
   (private GitHub via `gh` (Recommended), public, local only).
4. **The Figma board and art inputs.** First ask for (or offer to create) the game's **Figma file**:
   it's the full design board where inputs, reviews and approved art all land (`roblox-art-pass`
   fills it). **Which Figma MCP:** if the developer's global or project instructions name one, use
   it; if several are connected and nothing says, ask (some have monthly call caps that a busy
   board burns through). Record the file name/key and the MCP in CLAUDE.md and Tools & Setup.
   **Create the board's pages now** (🖼️ Inputs, 🎨 Style, 🧪 Reviews, ✅ Approved), with a short
   note on 🖼️ Inputs ("drop sketches here, one frame per asset"), so the developer has somewhere
   to drop sketches today, not after the first art pass.
   Then offer, plainly: "Do you have sketches, reference pictures or a style you're going for?
   **Drop them straight onto the 🖼️ Inputs page of the Figma board**, or tell me where they are
   (a folder, a path) and I'll put them on the board for you." Sketches really help the 3D
   modelling later: the art agent loads them as reference images in Blender and models against
   them. Then:
   - Whatever the source, every input ends up **on the board** (🖼️ Inputs, grouped by asset,
     labelled) **and** as a file in `docs/Art/Sketches/` or `docs/Art/References/`: Blender needs a
     local file to load a reference image. Board → disk: export the image fills (Figwright
     `save_image_fills` / a frame screenshot). Disk → board: import the image.
   - Images pasted into chat may not exist as files; ask them to drop it on the board or give a path.
   - Look at each one (Read the image) and log it in the Style Guide's inputs table: what it's
     for and what to take from it.
   No art yet is fine; say they can drop some on the board any time.
   No Figma (or Simple mode)? Then the `docs/Art/` folders are the inbox.

If they're away or said "use your judgment", take the recommended options and list them under
**Assumptions** in the hub note.

Push back honestly where it matters: a v0.1 with five systems isn't a v0.1; "Robux → random item"
needs odds shown and `PolicyService` checks; a target audience of kids changes what's okay to sell.
Once they decide, write it down and move on.

## 3. Write the knowledge base (`docs/`)

Use the templates in `references/docs-templates.md`. Files are named `<Game> – <Note>.md` (en dash)
so they stay unique in an Obsidian vault:

| Note | Holds |
|---|---|
| `<Game>.md` | The hub: pitch, the game in 30 seconds table, non-negotiables, note index, assumptions, open questions |
| `– Game Design.md` | Core loop, v0.1 scope, what's cut, and the **design log** (date · decision · why, in their words) |
| `– Architecture.md` | Principles, the folder tree, who owns what, "where does new code go?" |
| `– Build Plan.md` | Milestones M0…Mn, each with **Done when**; lanes if parallel; the **progress log** |
| `– Style Guide.md` | Visual direction: their sketches and references (logged), palette, fonts, UI shape language, 3D style rules, the art log. Starts short; `roblox-art-pass` grows it |
| `– Tools & Setup.md` | Tools and versions, the every-session checklist (open place → Rojo Connect → MCP on) |

Write in the developer's voice and names. Keep it short: these notes grow with the game, and a
bloated day-0 doc nobody reads is worse than a short one everybody does.

**Obsidian symlink** (only if they use a vault): `ln -s "<repo>/docs" "<vault>/<folder>/<Game>"`.
Check the target doesn't exist first. Images go in `docs/Images/`.

## 4. Scaffold the repo

Run the bundled scaffolder. It copies `assets/template/` and fills in the game name:

```bash
python3 <skill-dir>/scripts/scaffold.py --dest <repo> --name "<Game Name>" --slug <game-slug> [--simple]
```

It refuses to overwrite existing files (it lists them and stops), so a migration keeps its code.
Besides the Rojo skeleton it adds a **`DebugService`** (the agent backdoor: named commands like
`GiveCoins` that testers call instead of playing to a state), the **agent team** in
`.claude/agents/` (`art` + `lead` on Opus, `builder` + `tester` on Sonnet), and `docs/Batches/`,
`docs/Art/`, `assets/src/`. What each piece is for is in `references/scaffold.md`. Read it if the
developer picked their own architecture or you're migrating, so you know what to adapt. If they
chose Simple, `--simple` leaves out `.claude/agents/` and `docs/Batches/`; also delete the Agent
workflow section and the Figma board line from CLAUDE.md.

Then:
- Fill `CLAUDE.md` from the template's placeholders using what you learned (note index, commands,
  non-negotiables, lanes). It's the file every future session reads first; make it accurate.
  Remove every `<!-- FILL -->` marker.
- `git init` (if needed), `stylua src` **from the repo root** (from `src/` it misses `stylua.toml`).

## 5. Connect Studio and prove it (smoke Play)

Follow `references/day0-checklist.md`. In short:

1. `rojo serve` in the background. Ask the developer to open the place and click **Plugins → Rojo →
   Connect** (an agent can't click plugin buttons reliably). Verify sync by reading
   `ServerScriptService.Server.Main` in the Edit datamodel; if it's missing, Rojo isn't connected.
2. Run the Studio checks from the checklist (StreamingEnabled, API access, place published?), and
   **tell** the developer the ones only they can change. Don't flip settings silently.
3. `start_stop_play` → read the console. Pass = all three lines appear:
   `[init] server ready`, `[init] client ready`, `[init] ping ok (<n> ms)`. No errors. Then the
   backdoor: `Net.Debug:InvokeServer("List")` returns `true` and a list, `"Dump"` returns `true`.
   Stop Play. How testers use the backdoor, and why it's safe on live servers, is in
   `references/agent-testing.md`; explain it to the developer in two lines.
4. Screenshot (`screen_capture`) for the Build Plan's progress log.

If it fails, fix the wiring, not the symptom (wrong `$path`, file suffix, Rojo on another port),
and rerun until all three lines appear. A skeleton that hasn't run once isn't done.

## 6. First commit and remote

One commit: `Foundation: docs, Rojo scaffold, bootstrap, smoke test`. Create the remote only with
the developer's yes (from round 3): `gh repo create <slug> --private --source . --push`. Never push
to an existing remote without asking.

Add the first rows: Build Plan progress log (M0 ✅ with the smoke result) and the design log
(the interview decisions).

## 7. Hand off

End with a short message:
- where the repo and docs are (one line each), and the smoke result
- anything only they can do (enable API access, publish the place, reconnect Rojo after reopening)
- the v0.1 milestones by name
- the next step: "Want to define the first system? I'll run `game-mechanic` on <core loop>."
  After a mechanic is specced, `roblox-art-pass` turns its asset list into approved art.

## The agent team (if they chose it)

The main session becomes the **orchestrator**: it splits each milestone into small batches, writes
a brief per batch in `docs/Batches/`, starts a **fresh** `builder` and then a **fresh** `tester` for
every batch (so context stays light), relays BUG/WEIRD issues to `lead` and VISUAL ones to `art`
(Opus confirms before anyone fixes), and commits each green batch by path. Two failed fix rounds
on the same issue → stop and ask the developer. The full playbook, the brief template and the
reasons behind each rule are in `references/agent-workflow.md`. Explain it to the developer in
three lines during the hand-off.

If several **human-started** sessions will also work at once, write **lanes** into the Build Plan
and CLAUDE.md (each lane owns folders; nobody edits another's), plus: one Play session at a time,
ask before starting/stopping Play, commit only your own files. Five minutes on day 0 saves the
merge mess that otherwise shows up on day 2.
