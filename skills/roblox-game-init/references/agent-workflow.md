# Agent workflow (orchestrator playbook)

The scaffold installs four agents in `.claude/agents/` and a matching section in `CLAUDE.md`.
This file is for the **orchestrator** (the main session): how to run them.

## Why it's shaped like this

| Choice | Why |
|---|---|
| Opus for art and diagnosis, Sonnet for building and testing | Taste and root-cause thinking are where the bigger model pays off; implementing a clear brief and running test steps aren't |
| The orchestrator is the main session | Subagents can't start subagents. It also keeps one place that sees the whole picture |
| Fresh builder + tester per batch | Long-lived agents fill their context with old diffs and start guessing. A fresh agent with a good brief is faster and more accurate |
| Briefs as files in `docs/Batches/` | The brief is the agent's whole memory, the developer can read it in their notes, and it's the audit trail of what each commit was meant to do |
| Opus confirms the unclear issues | Testers driving Studio through MCP see artifacts (latency, overlays, test-mode timers). Confirming WEIRD and VISUAL issues first stops builders from "fixing" things that aren't broken; obvious BUGs skip it |
| One tester in Studio at a time | One Studio = one Play session. Two testers stopping each other's Play produce garbage reports |
| Two failed fixes → ask the developer | Past that point the brief or the design is wrong, and more agents won't fix it |

## Not everything is a batch

| Change | Route |
|---|---|
| One file, a few lines, no Robux/saves/remotes (typo, tuning number, color, copy) | **Fast lane**: the orchestrator edits, checks, commits. No brief, no agents |
| Anything a tester should play | A batch |
| Touches Robux, saved data, or a currency/item remote | A batch + `lead` review, however small |

The full loop has a real cost: every fresh agent re-reads CLAUDE.md and the docs. Worth it for a
feature, wasteful for a typo.

## Routing issues

| Tester says | Goes to | Why |
|---|---|---|
| `BUG` with clear evidence (error + file:line, wrong config value) | fresh `builder` directly | Opus adds nothing when the cause is on screen |
| `BUG` whose first fix failed | `lead` | Now it's not obvious anymore |
| `WEIRD` | `lead` | Unexplained = needs diagnosis, and may be a tester artifact |
| `VISUAL` | `art` | Taste call + the art source |

## Shared files

`Shared/Net.luau`, config index modules and `default.project.json` are touched by almost every
feature. The orchestrator owns them: builders list the remotes/config keys they need in their
report, the orchestrator adds them. This removes the most common parallel-builder collision.

## Build mode decides when art happens

Read the build mode in CLAUDE.md. **Mechanic-led:** batches use tidy placeholders (right size and
silhouette, Style Guide colors, labels, sounds and pops kept) and the art pass starts only after
the Build Plan's 🧪 loop-approved milestone. **Visual-led:** the art pass comes first (style test +
one scene), and batches build on approved art. A spec can override the mode for one mechanic.

## The developer is the bottleneck: batch and don't wait

Count what only the developer can do: open Studio, turn on the MCP, Rojo Connect, start the Blender
server, open the Figma plugin, approve frames and screenshots, click Import 3D, playtest. Agents
are fast; the pipeline moves at the speed of those approvals. So:

- **Queue, don't interrupt.** Everything waiting on the developer goes in the Build Plan's
  **⏳ Waiting on you** table (what · why it's blocking · where to look · since). Ask in **groups**:
  "3 screens and 2 models are ready on the board, section R004", one `AskUserQuestion` round
  (multi-select "which are ✅?", then a tweak question only for the rest).
- **Keep working.** Order batches so something independent is always ready: logic batches while
  art waits, the next screen's Figma design while the last one is being built.
- **Session start:** list the ⏳ table first, plus the manual setup steps for today's work
  (Tools & Setup → Every session), in one message. The developer clears it, then walks away.

## Sizing a batch

A batch is the smallest slice a tester can verify in one Play: one service + its controller, one
screen, one rule group. Rule of thumb: ≤ 5 files, one "done when", ≤ 10 test steps. A milestone
from the Build Plan is usually 3–8 batches.

## Batch brief template (`docs/Batches/B<nnn> – <name>.md`)

```markdown
# B012 – Shop purchase flow

Milestone: M3 Shop · Spec: [[<Game> – Shop]] rules R1–R6 · Lane: Core

## Goal
One sentence: what a player can do after this batch that they couldn't before.

## Files allowed
- src/server/Services/ShopService.luau (new)
- src/shared/Config/ShopConfig.luau (new)
- src/shared/Net.luau (add "BuyItem")

## Must follow
- R3 Price is read from ShopConfig on the server; the client never sends a price.
- Server is the authority; DebugService command `GiveCoins` for testing.

## Done when
- Buying with enough coins deducts the price and adds the item (saved).
- Buying without enough coins changes nothing and returns "not enough".

## Test steps (tester)
1. Play → `Net.Debug:InvokeServer("GiveCoins", 500)`
2. `Net.BuyItem:InvokeServer("Sword")` → expect true, coins 400
3. Repeat 5× → expect "not enough" on the 5th, coins never negative
4. Stop + start Play → item still owned

## Result
(orchestrator fills: tester verdict, issues, lead review, commit hash)
```

## Relaying issues

Subagents can't message each other; the orchestrator passes reports along **unchanged**
(paraphrasing loses the repro details):

- `WEIRD` (or a BUG whose fix failed) → `lead`: the tester's issue text + the brief path.
- Clear `BUG` → a fresh `builder`: the issue text + the brief path.
- `VISUAL` → `art`: the issue text, the screenshot path, the approved art reference.
- The confirmed fix order → a **new** `builder` with the fix order + the brief path.
- Then the **same** tester steps again (a new tester is fine; the steps are in the brief).

## Risky batches

Anything touching Robux (`MarketplaceService`, `ProcessReceipt`, passes), saved data
(DataStores, session locks, migrations), or a remote that changes currency/items gets a `lead`
review of the diff before commit. If the `roblox-robux-audit` skill is installed, `lead` runs it
on Robux batches.

## Commits

After the tester is green (and `lead` for risky batches): `stylua src`, then commit **only the
batch's files, by path**, message `B012 Shop purchase flow`, and fill the brief's Result section.
One batch = one commit makes rollbacks trivial.

## Running agents on their own

The developer can also start a whole session on one model, e.g. `claude --model opus` for an art
session. The agent files still apply when the orchestrator delegates by name.
