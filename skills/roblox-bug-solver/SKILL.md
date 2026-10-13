---
name: roblox-bug-solver
description: >
  Solve a bug in a Roblox game the way a senior dev would: ask the developer plain-language
  questions about what they saw, trace the code, REPRODUCE the bug in Roblox Studio through the
  Studio MCP (Play, console, attributes, remotes, a rejoin when saved data is involved), then explain
  in plain words WHY it happened (the root cause, with file:line and the repro evidence) and HOW
  you're going to fix it (the plan, the files, the edge cases), and wait for the developer's OK before
  touching code. After the OK: the smallest fix in the game's own style, the same repro run again to
  prove it's gone, and how to test it. Use this whenever the user reports something wrong in their
  Roblox game: "there's a bug", "X doesn't work", "this happens when it shouldn't", "players say...",
  "it plays again when I come back", "it only breaks on live", "why does X happen", "fix this", even
  if they never say "bug". Not for new features (game-mechanic), blind playtests (roblox-playtest) or
  Robux audits (roblox-robux-audit).
user-invocable: true
---

# Roblox bug solver

A developer who reports a bug wants three things, in this order: to be **understood** (you know
what they actually saw), to **understand** (why it happened, in words they can repeat to a
teammate), and to **trust the fix** (it fixes the real cause, nothing else breaks, and they could
check it themselves). Jumping straight to a code change fails all three: you often fix a different
bug than the one they saw, and they learn nothing.

So the job is: listen → trace → **reproduce** → explain why → propose how → wait for OK → fix →
prove it.

## 1. Understand what they saw

Bug reports are compressed. "The tutorial plays on the server's first and second day, not yours"
could mean five different bugs. Before reading much code, skim just enough to know the system's
names (a `grep` for the feature), then ask with `AskUserQuestion` (one round, 2–3 questions,
options grounded in what the code can do):

- **Which thing**: name the candidate systems you found ("the rookie hints in the hall", "the
  corridor tutorial", "the plot tutorial"), each described the way a player sees it.
- **What exactly happened**: concrete symptoms as options ("stopped too early", "a late joiner got
  nothing", "came back and it played again"). The symptom picks the bug; the developer's theory of
  *why* often doesn't, so don't anchor on their explanation.
- **Where**: Studio Play, a live server, a friend's phone. Studio and live differ in ways that
  cause or hide bugs (see `references/studio-repro.md`).
- **What it should do**, only when the intended behavior is genuinely unclear.

Their answers can surprise you. In the example above the developer picked "came back, hints
again", which moved the bug from *how a day is defined* to *the day count isn't kept across a
rejoin*. Read the answers literally, and if one of them contradicts your theory, drop the theory.

If the developer already gave a precise symptom, a place and the expected behavior, skip the
questions. If they're away (no answer possible), take the most likely reading, say so, and go on with steps
2–4. Being away doesn't skip the OK in step 4.

## 2. Trace the code

Follow the data, not the file list. For the symptom, find:

- **Where the state lives** (a variable, an attribute, a DataStore field, a server-only table).
- **Every writer** of that state, and *when* each one runs (which event, which phase, which side).
- **Every reader**, especially the one that makes the visible decision.
- **The lifetime**: is it per player or per server? Saved or session-only? Reset on rejoin, on a new
  round, on a Studio Play?

Write down 1–3 hypotheses, each as a concrete sequence a player could go through ("trades on day 1 →
leaves before the bell → the count only moves at the bell → never saved → rejoins → day 1 again").
A hypothesis you can't phrase as player steps isn't ready to test.

Check what's uncommitted (`git status`) and whether another session or person owns the files. In a
shared repo, announce which files you'll touch before you touch them.

## 3. Reproduce it in Studio

A bug you've reproduced is a bug you understand. A bug you've only read about is a guess, and
guesses produce fixes for the wrong bug. Reproduce before proposing anything.

Read `references/studio-repro.md` for the recipes (setup checks, driving the game through remotes
and admin commands, faking time, rejoining with saved data, reading the server and client sides).
The short version:

1. **Be a good guest in Studio.** `list_roblox_studios`, then `get_studio_state`. If Play is
   already running, someone may be using it: ask before starting or stopping Play. Check that file
   edits reach Studio (Rojo connected: compare a script's `Source` in the Edit datamodel with the
   file).
2. **Set up the exact conditions** from the hypothesis: the saved state, the phase or round, the
   player's progress. Use the game's own admin commands or remotes. Don't hand-edit state in ways a
   real player can't reach, unless you mark that step as a shortcut.
3. **Run the player's steps** and capture evidence at the moment it matters: console lines, a
   player attribute, a saved field, a screenshot of the UI. Read the server and client datamodels
   separately. They can disagree, and that's often the bug.
4. **Compare against the hypothesis.** Reproduced = the evidence shows the wrong behavior *and* the
   step that causes it. Add a temporary `print` if you must, and remove it afterwards.

If you **can't** reproduce it (Studio can't run the situation, e.g. two real servers, a real
DataStore outage, a phone-only input), say so plainly, say why, and fall back to the strongest
evidence you have: a code path traced line by line, plus what would confirm it (a log line to add,
a test on a published server). Never present an unreproduced cause as confirmed.

If the repro shows something different from the hypothesis, that's the most valuable result of the
whole job. Go back to step 2.

## 4. Explain why, and propose how. Then stop.

Write it for the developer, not for a code reviewer. They might be a student or a kid, so use plain
words, short sentences, and the game's own names. Use `references/explanation-template.md`. It
covers:

- **What you saw**: one line in their words, to confirm you fixed the right bug.
- **Why it happened**: the story first (player steps → what the code does at each step → the
  visible result), then the root cause in one sentence with `file:line`, then the repro evidence
  ("in Studio: traded, left before the bell, rejoined → `TradeDays` = 0 again"). Name the *design*
  mistake behind the line when there is one (e.g. "counted at the end instead of when it
  happened"). That's the lesson they keep.
- **Why it wasn't caught**: one line, if there's a real reason (a Studio-only config hid it, the
  path only runs on a rejoin). This helps them test the next feature.
- **How I'll fix it**: the change in plain words, the files, what stays exactly the same, the edge
  cases you'll handle (rejoin in the same round, admin tools, old saves, NPCs, the client and server
  sides), and any data change (new saved fields, migration of old saves). If there's a real
  alternative, give it in one line and say why you picked this one.
- **How we'll know it's fixed**: the same repro steps, now with the expected evidence.

Then **stop and ask for the OK**. A one-line `AskUserQuestion` works (Go / Change the plan /
Explain more). Don't edit game code before the answer. The developer often knows something you
don't (a design rule, another session's work, "that's actually intended"). The explanation is
also how they learn their own codebase, and they can't redirect a fix that's already written.

Being told not to wait **for questions** is not an OK to edit. "I'm away", "I'm going to sleep",
"don't wait for my answers" means: don't block on step 1, make your best reading and keep
investigating. It still ends here, with the explanation and the plan ready for when they're back.
Coming back to a clear diagnosis and a plan they can approve in one word costs them nothing.
Coming back to code they didn't approve means they first have to review it, and maybe undo it.

The only exception is an explicit go-ahead to change code for this bug ("just fix it", "go ahead
and fix it", "you can edit the code"). Then give the explanation and continue to step 5 in the same
turn.

## 5. Fix, then prove it

- **Smallest change at the root cause.** Fix where the wrong state is produced, not where it's
  displayed. Don't refactor neighbours, rename things or "improve" unrelated code in the same change.
- **Match the codebase**: its patterns (services/controllers, config modules, attributes), comment
  density, naming, `--!strict`, the formatter (`stylua` from the repo root if the project uses it).
- **Respect the boundaries**: never trust the client for anything that grants or saves; keep
  server-authoritative state on the server; new saved fields get defaults so old saves load.
- **Watch for Studio-only differences** your fix might rely on (`game.JobId` is `""` in Studio,
  `RunService:IsStudio()` test configs, DataStore access off).
- **Run the same repro again** and show the new evidence. Then try one or two neighbouring cases
  the fix could break (the normal path still works, the edge case from the plan). If you can't
  rerun it (Play is busy, Studio closed), say exactly what is untested.
- **Don't commit or publish** unless asked. Leave the change in the working tree, and list the files.

## 6. Report

End with a short report:

- What was wrong (one line) and the root cause (`file:line`).
- What changed (files, one line each).
- **Verified**: what you reran and what you saw. **Not verified**: what you couldn't run, and why.
- How the developer can test it themselves (3–5 steps a person can follow in Studio).
- Anything you noticed but didn't touch (a related bug, a risky pattern), as one-line follow-ups.
