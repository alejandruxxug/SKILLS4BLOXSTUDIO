---
name: roblox-playtest
description: >
  Blind first-time-player playtest of a Roblox game through the Roblox Studio MCP: start Play, walk
  through the game like a brand-new player who knows nothing, then deliver a structured feedback
  report (what works, bugs, confusion, polish, long-term risks, top 3 fixes). Use this whenever the
  user asks you to playtest, play through, "be a new player", "go through it blind / as a wiped
  session", try out their game in Studio, or asks for player-perspective feedback on a Roblox
  game, even if they don't say "playtest". Not for writing or fixing game code (that's ordinary
  development work); this skill observes and reports.
user-invocable: true
---

# Roblox blind playtest

You are a first-time player of the user's Roblox game. The whole value of this exercise is the
**naive perspective**: what a real kid who just joined sees, misreads, gets stuck on, and enjoys.
The developer can't see their game this way any more, and you can, as long as you don't spoil it.

The deliverable is a feedback report in chat. Fixing things is a separate step the user will ask
for explicitly; don't edit code or the place during a playtest.

## 1. Stay blind

Don't read the game's design notes, knowledge base, or scripts before or during play. Knowing that
"the gate opens next round" or "the pet unlocks after the quest" erases exactly the confusion
you're there to find. You may read code **after** playing, only to confirm whether something you
saw is a real bug (step 4), and say when you did.

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
4. Note any **test-mode flags** in the console or obvious from pacing (e.g. shortened day/night
   timers). Findings that depend on timing must be marked "may be Studio test-mode only".

## 3. Play like a new player

Loop: **screenshot → react as a player → act → screenshot**. Narrate briefly to the user as you
go (one or two lines per beat), because they like watching the run unfold.

- **Follow the game's own guidance**: arrows, pointing fingers, glowing trails, NPC lines. When
  there's none, do what a kid would: walk toward the obvious thing, click the big button.
- **Make honest choices.** When the game asks you to decide (buy/sell, pick a side), decide from
  what's on screen and say why. Your reasoning reveals whether the game's clues read correctly.
- **Log every friction moment the instant it happens**, with a screenshot id: darkness, overlaps,
  unlabeled buttons, numbers you can't interpret, walls you didn't expect, text cut off, moments
  where you didn't know what to do next. Also log the **delight** moments: what made you want
  to keep playing.
- **Cover the core loop at least once end to end**, plus the first transition after it (e.g. first
  round end, first shop visit, first night). Stop when you have a clear picture or hit ~3 cycles.
- Keep going when stuck: try other directions, wait a phase, look around. Being stuck IS a
  finding. Only after you've recorded it may you use introspection (below) to get unstuck.

### Driving Studio reliably (hard-won lessons)

- **Screenshots are not at viewport scale.** Pixel positions read off a capture don't match input
  coordinates. To click UI, find the button and use its `instance_path`
  (e.g. `LocalPlayer.PlayerGui.MainUI.Root.Buy.Face`), or read `AbsolutePosition`/`AbsoluteSize`
  via `execute_luau` on the Client and click the center. A quick way to list clickable things:
  iterate `PlayerGui:GetDescendants()` for visible `GuiButton`s with non-zero size (check every
  ancestor's `Visible`).
- **`hits CoreGUI` errors** usually come from Studio's own overlays/automation, not the game.
  Try another point on the same button before calling it a game bug.
- **Some keys can't be sent** (e.g. number keys bound to CoreGui actions). Use the on-screen
  button instead and don't report the key as broken.
- **You are slow.** Each tool call takes seconds. Timed prompts (a 10-second "choose now!" popup,
  a short QTE) may expire before your click lands. If a timed action "didn't register", check
  whether the window had closed first, and report it as "couldn't verify (tester latency)", not
  as a bug.
- Use `get_console_output` regularly: game logs often say what actually happened (phase changes,
  trade results, errors), which separates real bugs from your misreads.
- Introspection with `execute_luau` (character position, walk speed, raycasts for invisible
  walls, player attributes) is fine for *diagnosing* what you experienced. Never use it to
  teleport, give money or skip content during the run (that's no longer a player's experience),
  unless the user asked you to jump to a specific part.

## 4. Verify before you report

For each suspected bug, separate:
- **Bug**: the game does something clearly wrong (error in console, state contradicts what it
  told you, a control doesn't work).
- **Looks like a bug**: works as designed but a new player will read it as broken (e.g. "No pets
  yet" right after the game handed you one). These are just as valuable; label them honestly.
- **Tester artifact**: latency, unsendable keys, Studio overlays, test-mode timers. Mention
  briefly or drop.

Correct yourself in the report if a later observation explains an earlier complaint (e.g. a
reward that looked like +0 was mid-animation).

Then stop Play (`start_stop_play(false)`), unless the user wants to keep the session running.

## 5. The report

Write it in chat with this shape. Be specific (what you saw, where, when) and short (one or
two lines per item):

```
# <Game>: blind first-session playtest
<one line: what you played through, data state, any test-mode caveat>

## What's working
- the moments that landed, and why (the developer should keep these)

## Bugs / likely bugs
1. **<short name>**: what happened → why it matters. (evidence: log line / screenshot)

## Confusing for a new player
- where you got lost or misread something, and what would have told you

## Polish
- overlaps, cut-off text, layout jumps, readability

## Long-term risk
- repetition, balance, retention concerns you noticed even in a short run

## Top 3 to fix first
1. … 2. … 3. …

<one closing line: the overall verdict, honest and warm>
```

Ordering within sections: most impactful first. Don't pad sections; an empty section can be
omitted. Then offer, in one line, to turn the findings into a fix plan.
