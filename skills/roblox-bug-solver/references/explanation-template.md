# The explanation (step 4)

Plain words, short sentences, the game's own names for things. Write it so the developer could
explain the bug to a teammate after reading it once. Keep it to one screen. Put details in
`file:line` references, not in paragraphs.

```markdown
**What you saw:** <one line, in their words>

### Why it happened
<The story, as player steps → what the code does → what they see. 2–4 sentences.>

**Root cause:** <one sentence> (`path/File.luau:LINE`)
<The design mistake behind it, if there is one, e.g. "it counted the day at the end of the
round instead of when it happened".>

**Reproduced in Studio:** <the exact steps you ran → the evidence (console line, attribute value,
saved field, screenshot)>. Or: **Not reproduced:** <why Studio can't run it> + <what would
confirm it>.

**Why it wasn't caught:** <one line, only if there's a real reason>

### How I'll fix it
- <The change in plain words, one bullet per file: `File.luau`: what changes>
- **Stays the same:** <behavior you're deliberately not touching>
- **Edge cases:** <rejoin, same round, admin tools, old saves, NPCs, client/server>
- **Data:** <new saved fields + default, or "no saved data changes">
- **Alternative:** <one line + why not> (only if there's a real one)

### How we'll know it's fixed
<The same repro steps → the evidence you expect now>
```

Then ask for the OK, for example with `AskUserQuestion`:
"Go with this fix?" → **Go** / **Change the plan** / **Explain more**.

## Example

**What you saw:** you came back to the game and Grandma's rookie hints played from day 1 again.

### Why it happened
Your rookie day only goes up at the closing bell, and only if you're still in the hall. If you
trade and then leave before the bell, that day is never counted, so it's never saved. When you
come back, the save still says day 1, and the full hints play again.

**Root cause:** the day is counted at the bell, not when you trade (`RookieHintService.luau:72`).
Counting at the *end* of something misses everyone who leaves before the end.

**Reproduced in Studio:** API access on → Play → traded once on day 1 → stopped Play before the
bell → Play again → the player's `TradeDays` attribute is 0 again and the giant 🚀 stamp shows.

### How I'll fix it
- `RookieHintService.luau`: count the day at your **first trade** of the round and save it then.
  The hint level you're *on* still only changes at the bell, so today's hints don't stop early.
- `PlayerDataService.luau`: new saved field `tradeDayKey` (server + round), so rejoining the same
  round doesn't count it twice. Old saves get `""`.
- **Stays the same:** a "day" is still a round you traded in. Day 1 full hints, day 2 nudges.
- **Edge cases:** rejoin in the same round, the admin ROOKIE D1/D2/D3 buttons, NPC traders, trades
  in the tutorial corridor. Studio's `game.JobId` is `""`, so the key uses a per-server GUID.

### How we'll know it's fixed
Same steps → after the rejoin `TradeDays` = 1 and only the day-2 nudge plays.
