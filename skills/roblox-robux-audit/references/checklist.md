# Robux audit checklist

Go through every section. For each item, either write a finding (with a scenario) or note it
under 🟢 Fine with the file:line you traced. "Didn't check" goes under Not verified.

## Contents
1. ProcessReceipt (developer products)
2. Saving the grant
3. Game passes
4. Promise vs delivery (copy, descriptions, what the card shows)
5. Prices and honesty on screen
6. Paid random items and PolicyService
7. Purchases that depend on state (capacity, pending deals, one-time offers)
8. Refunds, credits and fallbacks
9. Exploits (free stuff)
10. Player wellbeing rules

---

## 1. ProcessReceipt (developer products)

Roblox calls `MarketplaceService.ProcessReceipt` for every product purchase and keeps retrying
(on later joins too) until it returns `PurchaseGranted`. The developer's money and the player's
item both hang on this one function.

- **Exactly one** script sets `ProcessReceipt` (a second one silently replaces the first).
- **`PurchaseGranted` only after the grant is SAVED.** If it returns Granted and the server then
  crashes before a save, the player paid and the item is gone. Look for: Granted returned while
  the save result is ignored, a save inside a `pcall` whose failure isn't checked, or "mark dirty,
  autosave later".
- **Every early exit returns `NotProcessedYet`**: player not in the server, data not loaded yet,
  save offline/failed, unknown product id, grant refused. Returning Granted in any of these
  charges the player for nothing (🔴 *less*).
- **Idempotent**: the `PurchaseId` is stored with the data, and a receipt whose id is already
  stored is answered without granting again. The stored id must be saved together with the grant
  (same save), or a crash between them double-grants or loses it.
- **Errors**: if the grant can throw halfway, what happens on the retry? A partial grant that's
  then fully regranted is *more* (🟡). Granted after a partial grant is *less* (🔴).
- **Never yields forever** (a `WaitForChild` with no timeout, an infinite wait for data).
- **The receipt list is bounded** but big enough that a retried receipt is still found.

## 2. Saving the grant

Most "I paid and lost it" stories are save bugs, not store bugs.

- **Failed load**: if loading a player's data fails, does the game play on with fresh data and
  then SAVE over their real data? (🔴, they lose everything incl. purchases.) The safe pattern:
  mark the session offline and never save it. And then purchases must wait (see 7).
- **Session locking / server hopping**: a player leaves server A and joins server B before A's
  leave-save lands. Plain `GetAsync`/`SetAsync` lets B load stale data and later overwrite A's
  newer save (a purchase made in A vanishes). Look for `UpdateAsync` with a lock (job id + time),
  or a library like ProfileStore. 🔴 if there's nothing.
- **Save order**: can an older save (an autosave that copied the data earlier) land after a newer
  one (the receipt's save)? One save at a time per player, or comparing versions, prevents it.
- **Shutdown**: `BindToClose` waits for every save to finish (up to ~30 s), not a fixed short
  `task.wait`.
- **Leaving mid-purchase**: the receipt arrives after the player left → must be
  `NotProcessedYet` (Roblox retries on their next join).

## 3. Game passes

- **Checked on join** with `UserOwnsGamePassAsync` inside `pcall`. One failed call means the
  owner doesn't get what they paid for all session. Look for retries, or a re-check later.
- **Bought in game**: `PromptGamePassPurchaseFinished(player, id, wasPurchased)` should grant
  right away (making a real buyer wait or relog feels like a scam). Optionally double-check with
  `UserOwnsGamePassAsync` and log a mismatch. Don't revoke on a slow API (that hurts real buyers).
- **Every effect the pass promises is applied everywhere it's promised** (see 4). "2× coins"
  applied to one coin source out of four is the classic miss.
- **Passes can be bought on the website** (the experience's Store tab) by anyone, including
  players for whom paid random items are restricted, and while the game hides them. What does
  the game give such a buyer? Nothing at all = 🔴 *less* if it's a random-item pass.

## 4. Promise vs delivery

Put every description, card line, tooltip and purchase-screen string next to the grant code.

- Every noun in the copy exists in the grant: "+ VIP TAG", "FOUNDER badge", "exclusive pet",
  "chat title". A tag that's set as an attribute but read by no script doesn't exist (🔴 *less*).
- Amounts match (displayed 10,000 vs granted 1,000, "×3" vs ×2).
- Scope matches: "every payout", "all coins", "forever", "every server" are claims to verify.
- "One-time offer" / "limited": is it really once? Can it be bought twice (see 7)?

## 5. Prices and honesty on screen

- **Displayed price = real price.** Roblox charges the dashboard price in its own prompt, but
  the game's button text usually comes from a config number. Compare them (GetProductInfo, if
  the Studio MCP is available). A button that says R$ 99 for a R$ 149 product is 🔴.
- **No invented reference prices**: "WAS R$ 999", strikethroughs, "−80%" that compare against a
  price the item never actually had. Comparisons against a real, currently available price are
  fine.
- **Computed claims are true**: "+32% MORE", "BEST VALUE", "save R$ 50". Recompute them.
- **Countdowns and scarcity are real**: a "6d 4h left" timer must match what the server enforces.
  A timer that resets, or stock that's fake, is 🔴.

## 6. Paid random items and PolicyService

Roblox requires: odds shown before any purchase of a random item, and no paid random items for
players where `PolicyService:GetPolicyInfoForPlayerAsync(player).ArePaidRandomItemsRestricted` is
true.

- **What counts as paid random**: buying a loot box/egg/crate with Robux, AND buying something
  that's then spent on random items: soft currency that buys eggs, "free egg every day" passes,
  starter packs that include that currency.
- **Hidden AND refused on the server** for restricted players. Hidden only in the UI isn't enough
  (a client can prompt any product).
- **Fails closed**: if the policy call errors, treat the player as restricted.
- **Odds before purchase**: on the purchase surface itself (the card, or a confirm step before the
  prompt), not only in some other menu.
- Grey areas (a 2× currency pass for restricted players): don't decide for the developer. Flag it
  as a decision to write down.

## 7. Purchases that depend on state

Anything bought "for this moment" (extra picks for this draw, the pet the shop showed, a
one-time pack) can go wrong between the prompt and the receipt.

- **Check before charging**: inventory/bench full, already owns it, offer expired, not eligible.
  A check that only runs after payment (and then refuses) is 🔴 *less*.
- **Pending state is saved before the prompt**: if the server stores "this receipt is for pet X"
  in memory only, a crash before the next save turns the receipt into something else.
- **One pending slot overwritten by a second tap**: the first receipt then finds the wrong deal.
  Key pending deals by product (or purchase), not one global slot.
- **Double prompts**: can a one-time offer be prompted again while its first receipt is in
  flight? (The card is still on screen until the grant runs.)
- **Paid extra that goes unused**: paid for "keep 3", then kept 1. Is the payment lost, or kept as
  a credit?
- **Offline sessions**: purchases should be refused while the player's save is offline, with a
  message, rather than waiting on a receipt that can't be saved.

## 8. Refunds, credits and fallbacks

Fallback paths ("no pending deal → give currency instead") are where farmable bugs hide.

- **Never pays more than was charged.** If a fallback refunds in soft currency, at what rate?
  Can a player self-prompt the product (any client can prompt any product id) to get the
  fallback on purpose? If the fallback is worth more than the price → 🔴 *free*.
- **Credits can't be re-triggered** (granted once per purchase id).

## 9. Exploits (free stuff)

Assume the client is hacked.

- **Any remote that grants value** (`ClaimReward`, `GiveStarter`, `BuyItem` with a client-sent
  price) must check on the server that it was paid or earned. A client-callable grant is 🔴 *free*.
- **Remote arguments validated**: types, ranges, indices, ids that exist.
- **Lists the client sends** (picks, slots, item indices): a range check per entry isn't enough.
  Look for duplicates (`{3,3,3,…}` keeps 40 copies of the best card for one paid credit), no
  count limit, non-integers (`1.5`) and sparse tables (`{[1]=3,[5]=3}` makes `#t` say 1 while a
  loop sees 2). The server should rebuild the list: a plain array, distinct integers, max N.
- **Prices come from the server's config**, never from the client.
- **Admin commands** checked against a server-side allow list on every call.
- **Client-side "owned" flags** are never trusted by the server.

## 10. Player wellbeing rules

- **No Robux pushed after a loss** (going broke, losing a round, a bad pull). A purchase prompt or
  "buy more?" pop-up triggered by losing is chasing losses → 🔴 *policy*.
- **Robux doesn't buy competitive advantage** where the game promises fairness (leaderboards,
  PvP stats). Flag it if it contradicts the game's own stated rules. It's not a Roblox rule.
- **Kids can't overspend by accident**: double prompts, no confirm on big bundles, prompts that
  open from a mis-tap on a crowded HUD.
