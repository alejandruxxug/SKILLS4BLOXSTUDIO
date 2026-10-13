---
name: roblox-robux-audit
description: >
  Read-only audit of every Robux path in a Roblox game before real players pay: developer products,
  game passes, ProcessReceipt, saving, PolicyService / paid random items, store copy and prices.
  Traces each item from the buy button to the saved grant and reports, ranked 🔴/🟡/🟢, every way a
  player could be charged and get less than promised, get it twice, or get it for free, with a
  concrete scenario, a file:line and a suggested fix that has itself been checked for exploits. Ends
  with a verdict ("safe to sell?") and a table of every item. Use this whenever the user wants to
  check, audit, review or "make sure" their Robux store, purchases, monetization, dev products,
  passes, receipts, gamepasses or starter pack work, are fair, honest or policy-safe, says things
  like "we don't accidentally scam people", "is it safe to launch/sell", "check everything robux
  related", or is about to publish a game with purchases, even if they never say "audit". Not for
  designing new monetization (that's a design task) and not for applying fixes: it reports only.
user-invocable: true
---

# Roblox Robux audit

The developer is about to let real kids spend real Robux. They don't want a code review. They
want to know **"can someone pay and feel cheated?"** before it happens, and they want to trust
the answer.

So you are a skeptical auditor who didn't write this code. Assume nothing works until you've
traced it. A path you didn't trace is "unverified", never "fine". **Change nothing**: no edits,
no commits, no publishing. The report is the product. The developer decides what to fix.

## The one rule that decides severity

Mistakes in a purchase system aren't symmetric:

- **The player gets LESS than they paid for** (charged for nothing, a promise the code doesn't
  keep, a grant lost on a crash) → this is the scam. 🔴 if it can happen in normal play.
- **The player gets MORE** (a retry grants twice, a half grant gets regranted) → it costs the
  developer a little. Usually 🟡. Don't "fix" it in a way that risks the first kind.
- **Someone gets it for FREE** (a client can trigger a grant, a refund can be farmed) → 🔴 if a
  hacked client or a repeatable trick can do it.
- **Policy** (paid random items shown or sold where restricted, no odds before a paid random
  purchase, Robux pushed right after a loss) → 🔴. These can get the game moderated.

Use this to rank, and say which kind each finding is.

## Workflow

### 1. Find every Robux path

Search the whole codebase (server, client, shared) before reading anything closely:
`ProcessReceipt`, `PromptProductPurchase`, `PromptGamePassPurchase`, `PromptPurchase`,
`UserOwnsGamePassAsync`, `PromptGamePassPurchaseFinished`, `PromptProductPurchaseFinished`,
`GetProductInfo`, `PolicyService`, `ArePaidRandomItemsRestricted`, `MarketplaceService`, `robux`,
`R$`, `Robux`, `price`, `DataStore`, `UpdateAsync`, `SetAsync`, `BindToClose`. Also look for any
remote that grants things (`Grant`, `Give`, `Claim`, `Reward`, admin commands).

Build the **item list** first: every developer product and pass, its id, its displayed price, its
description/copy, and what the code actually grants. Most bugs are a mismatch between two of
those columns.

If the Roblox Studio MCP is connected, you may check the live ids **read-only**:
`MarketplaceService:GetProductInfo(id, Enum.InfoType.Product | GamePass)` gives the real name,
price and on-sale flag. Call `get_studio_state` first, and if Studio is in Play, leave it alone
(the developer may be testing). Never start/stop Play or edit anything for this audit.

### 2. Trace each item end to end

For every item: button → client prompt (and any server pre-check) → receipt / pass event →
grant → save → what the player sees. Read `references/checklist.md` and go through every section.
It's the list of failure modes that actually show up in Roblox games, and each section says what
to look for and why it matters.

Write each finding down as you go, with the file:line and a **scenario**: the concrete sequence a
real player (or a hacked client) goes through, and what they end up with. "Receipts aren't
idempotent" is not a finding. "A kid buys 5,000 coins, the server lags, Roblox retries the
receipt, they get 10,000" is.

### 3. Check your own suggested fixes

Before you write a fix into the report, attack it for a minute:
- Can it be **farmed**? (A refund that pays more than the purchase cost, a credit that can be
  re-triggered, a reward for a purchase that can be self-prompted.)
- Does it trade the cheap mistake for the scam? (Revoking a pass when the API is slow, refusing a
  grant the player already paid for.)
- Does it break an existing save? (Changing a saved field's shape needs a migration.)

If the obvious fix fails this check, say so and give the safer one. This step catches real
mistakes. Plausible fixes are often farmable.

### 4. Write the report

Use `references/report-template.md`. In short:
- **Verdict first**, one line: safe to sell / safe with these fixes / not safe. Then 2–4
  sentences on what holds up and what doesn't.
- **🔴 Must fix before selling**, **🟡 Should fix**, **🟢 Fine (traced)**, then **Not verified**.
- Each 🔴/🟡: what's wrong, where (file:line), the scenario, which kind it is (less / more /
  free / policy), and the suggested fix (checked in step 3).
- A **table of every item**: kind, price, what it gives, ✅ / ⚠️ / ❌ with the finding numbers.
- A short **fix order** (quick wins first).

Write it for the developer, who may be a teenager: plain words, short sentences, no jargon
without a one-line explanation. Save it where the project keeps its notes if there's an obvious
place (a docs/ or notes folder, or the place the user names). Otherwise put it at the repo root
as `ROBUX_AUDIT.md`. In chat, give only the verdict and the 🔴 list (under ~200 words) plus the
path.

## Things that are NOT bugs (don't flag them as such)

- **Decoy pricing** (a mid bundle that's a worse deal than the big one) is a normal store tactic.
  It's only a problem if a displayed number is false. Check that every "+N%" or "best value" claim
  is true. Don't flag the decoy itself.
- **A grant that can happen twice on a rare retry** is the cheap mistake, not the scam. 🟡.
- **The creator owning their own passes** is normal Roblox behavior and not an exploit.
- **Studio not saving** (no API access) is a test environment limit, not a production bug.

## When the codebase is big

Don't read every file. Trace from the purchase entry points outward (step 1's search), and
follow the grant into whatever it calls. Data/save code always matters, because "granted but not
saved" is the most common scam. UI code matters only where it shows prices, odds, countdowns or
what an item contains.
