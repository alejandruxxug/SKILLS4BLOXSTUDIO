---
name: roblox-playtest
description: >
  Blind first-time-player playtest of a Roblox game through the Roblox Studio MCP: start Play, walk
  through the game like a brand-new player who knows nothing, then deliver a short feedback report
  for the developer plus a full evidence-backed report an agent can plan fixes from. Use this
  whenever the user asks you to playtest, play through, "be a new player", "go through it blind /
  as a wiped session", try out their game in Studio, or asks for player-perspective feedback on a
  Roblox game, even if they don't say "playtest". Not for writing or fixing game code (that's
  ordinary development work); this skill observes and reports.
user-invocable: true
---

# Roblox blind playtest

You are a first-time player of the user's Roblox game. The whole value of this exercise is the
**naive perspective**: what a real kid who just joined sees, misreads, gets stuck on, and enjoys.
The developer can't see their game this way any more, and you can, as long as you don't spoil it.

What the developer wants most, in order: **real bugs**, **places a new player gets confused**, and
**no false alarms**. A report that blames the game for your own slowness costs them an evening
chasing a bug that doesn't exist, so being right matters more than finding a lot.

Fixing things is a separate step the user will ask for explicitly; don't edit code or the place
during a playtest.

## 1. Stay blind

Don't read the game's design notes, knowledge base, or scripts before or during play. Knowing that
"the gate opens next round" or "the pet unlocks after the quest" erases exactly the confusion
you're there to find. You may read code or config **after** playing, only to confirm whether
something you saw is a real bug or a test-mode setting (step 4), and say when you did.

If the user's memory or context already tells you things about the game, set them aside and judge
only by what's on screen.

## 2. Set up

1. Load the Studio tools in one go (`ToolSearch` with `select:` for the `mcp__roblox-studio__*`
   tools you need: list_roblox_studios, get_studio_state, start_stop_play, screen_capture,
   execute_luau, get_console_output, user_keyboard_input, user_mouse_input, search_game_tree,
   character_navigation).
2. `list_roblox_studios` → pick the instance (confirm with the user if several are open).
3. `start_stop_play(true)`, then read the console. Check you're on **fresh data**: Studio
   usually has no DataStore access, and many games log that they're using fresh/unsaved data. If
   it looks like a returning player (saved progress, tutorial already done), tell the user, because a
   "new player" run on veteran data isn't one.
4. Note any **test-mode signs** in the console or obvious from pacing (e.g. very short day/night
   timers). Findings that depend on timing get marked "may be Studio test-mode only".

## 3. Play like a new player

Loop: **screenshot → react as a player → act → screenshot**. Narrate briefly to the user as you
go (one or two lines per beat), because they like following the run as it unfolds.

- **Follow the game's own guidance**: arrows, pointing fingers, glowing trails, NPC lines. When
  there's none, do what a kid would: walk toward the obvious thing, click the big button. If the
  same action appears twice (a button on a card and one on a toolbar), use the one the game is
  pointing at.
- **Make honest choices.** When the game asks you to decide (buy/sell, pick a side), decide from
  what's on screen and say why. Your reasoning reveals whether the game's clues read correctly.
- **Log every friction moment the instant it happens**, with a screenshot id: darkness, overlaps,
  unlabeled buttons, numbers you can't interpret, walls you didn't expect, text cut off, moments
  where you didn't know what to do next. Also log the **delight** moments: what made you want
  to keep playing.
- Keep going when stuck: try other directions, wait a phase, look around. Being stuck IS a
  finding. Only after you've recorded it may you use introspection (below) to get unstuck.

### How long to play

Play **until you're truly stuck or you've done about 3 cycles** of the core loop (a round, a day,
a match, whatever repeats). One cycle shows onboarding; cycles 2 and 3 show whether the loop holds
up, what repeats, and what the game does with a returning player.

- **Cycle 1 is strictly player-only.** No admin panels, no debug commands, no introspection
  shortcuts. This is the run that tells the truth about onboarding.
- **From cycle 2 on, you may use the game's own admin/debug tools to skip dead waiting** (long
  timers, waiting for a phase) so the later cycles don't take forever. Use them only to save time,
  never to get money or skip content you haven't seen yet, and log every use ("used admin
  SKIP to jump to morning") so nobody mistakes a shortcut for game behavior.

### Driving Studio reliably (hard-won lessons)

- **Screenshots are not at viewport scale.** Pixel positions read off a capture don't match input
  coordinates. To click UI, find the button and use its `instance_path`
  (e.g. `LocalPlayer.PlayerGui.MainUI.Root.Buy.Face`), or read `AbsolutePosition`/`AbsoluteSize`
  via `execute_luau` on the Client and click the center. A quick way to list clickable things:
  iterate `PlayerGui:GetDescendants()` for visible `GuiButton`s with non-zero size (check every
  ancestor's `Visible`).
- **When a click is blocked or does nothing, find out what's on top before blaming anything.**
  Run `PlayerGui:GetGuiObjectsAtPosition(x, y)` on the Client at that point. If a game element
  (a speech bubble, an invisible frame, a banner) sits over the button, that's a real finding:
  "X covers the button". If nothing from the game is there and the tool says `hits CoreGUI`,
  it's Studio's own overlay: click another part of the button and don't report it.
- **Some keys can't be sent** (e.g. number keys bound to CoreGui actions). Use the on-screen
  button instead and don't report the key as broken.
- **You are slow.** Each tool call takes seconds, while prices move, timers run and popups expire.
  If a timed prompt "didn't register", or a trade lost money between deciding and clicking, check
  the timing first (console timestamps, whether the window had already closed). Report those as
  "couldn't verify (tester latency)", not as bugs. A real player reacts in a quarter-second.
- Use `get_console_output` regularly: game logs often say what actually happened (phase changes,
  trade results, errors), which separates real bugs from your misreads.
- Introspection with `execute_luau` (character position, walk speed, raycasts for invisible
  walls, player attributes, what GUI is under a point) is fine for *diagnosing* what you
  experienced. Don't use it to teleport, give money or skip content.

## 4. Verify before you report

Give every finding exactly one label. Pick the most specific one, because a developer triages by
label, and if everything says "bug" the real bugs get lost:
- **Bug**: the game does something clearly wrong (error in console, state contradicts what it
  told you, a control doesn't work for a real player, two displays disagree).
- **Looks like a bug**: works as designed but a new player will read it as *broken* (e.g. "No pets
  yet" right after the game handed you one, money that silently resets).
- **Confusing**: nothing looks broken, but a new player won't understand it or will make the
  wrong choice (an unexplained currency, a toggle with no hint, a clue that points both ways).
  If something might be an intentional mechanic, it goes here, with that caveat.
- **Polish**: readability and presentation (overlaps, cut-off text, grammar, darkness, layout
  jumps).
- **Tester artifact**: your latency, unsendable keys, Studio overlays, test-mode timers. Leave
  these out of the short report; list them briefly at the end of the full report so the developer
  knows you saw them and why you discounted them.

A finding that depends on timing and might be caused by test-mode pacing stays in, marked "may be
test-mode only". If it's cheap, confirm after play by reading the relevant config value.

Correct yourself if a later observation explains an earlier complaint (e.g. a reward that looked
like +0 was mid-animation).

Then stop Play (`start_stop_play(false)`) and confirm the studio is back in Edit, unless the user
wants to keep the session running.

## 5. Two reports

The developer reads the **short report** in chat. A coding agent (often the next step: "turn this
into a fix plan") reads the **full report**, so it has to carry all the evidence. Write the full
one first, then distill the short one from it.

### Full report (for agents)

Save it as `playtests/<YYYY-MM-DD>-<game-slug>.md` in the current working directory and give the
path in chat. If you can't write files (for example, you're running as a subagent that must return
text), put the full report in your reply after the short one, under a `## Full report` heading.

```
# <Game>: blind playtest, full report (<date>)
Setup: studio instance, data state (+ console line), test-mode signs, cycles played, admin used (where)

## Findings
### F1. <short name>  [Bug | Looks like a bug | Confusing | Polish]  [severity: high/med/low]
- What happened: <exact on-screen text, numbers, place, phase/time>
- Repro: <steps a developer can follow from a fresh join>
- Evidence: <screenshot ids, console lines, inspected state (attribute values, GUI under point)>
- Player impact: <what a kid concludes / does wrong>
- Likely area: <the UI element / system it seems to involve, by what you saw; say "guess" if guessing>
- Caveats: <may be test-mode only? couldn't fully verify?>
(repeat for every finding, ordered by severity; Polish items can be one-liners)

## What's working (keep these)
- <moment>: why it landed (evidence)

## Long-term risks
- <observation from the cycles> → <why it matters>

## Discounted (tester artifacts)
- <what looked wrong> → <why it's on the tester, not the game>

## Session log
1. <one line per beat, with screenshot ids and console lines>
```

### Short report (for the developer, in chat)

Aim for something readable in under a minute. Most impactful first; drop empty sections.

```
# <Game>: blind playtest
<one line: what you played, data state, cycles, test-mode caveat>

**Best moments:** <1–3 short bullets>

**Bugs:** <Bug + Looks like a bug, numbered one-liners with F-numbers, real bugs first>
**Confusing for new players:** <one-liners with F-numbers>
**Polish:** <only the most visible few>

**Top 3 to fix first:** 1. … 2. … 3. …

<one closing line: the overall verdict, honest and warm>
Full report: playtests/<file>.md (or "below")
```

End by offering, in one line, to turn the findings into a fix plan.
