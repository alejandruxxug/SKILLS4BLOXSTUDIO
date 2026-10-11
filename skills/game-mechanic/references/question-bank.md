# Question bank

Question shapes that come up again and again for Roblox mechanics. Adapt the wording to the game:
replace `<Coins>`, `<shop>` and so on with the developer's real names, and always add the
integration fact ("right now Coins is what you spend on upgrades").

Recommended option first. Each option says what happens in the game.

## Contents
1. Money & getting it
2. Rules & randomness
3. Inventory & ownership
4. Where it lives (UI + world)
5. Feel (animation, rarity moments, social)
6. Onboarding
7. Monetization (Robux)
8. Content
9. Next steps

## 1. Money & getting it
- **Which wallet pays for it?** Options: the earned soft currency (the item becomes a currency sink) /
  a new token from missions / Robux. Say what each wallet currently does.
- **Does this replace or sit beside something that exists?** (an existing shop, NPC or stall)
  Options: keep both (one for luck, one for "no luck") / replace / the old NPC sells the new thing.
- **How often can you do it?** Unlimited / daily limit / only in a phase (night, lobby).

## 2. Rules & randomness
- **Blind pull or a choice?** (1 random result / pick 1 of 3 / see the results and keep all)
- **What happens to what you didn't pick?** Gone / turns into shards / pay to reroll.
- **Better tier = better luck: what's the floor of each tier?** ("worst you can get from the gold box")
- **Bad-luck protection (pity)?** Visible bar / hidden / none. And is it per tier or shared?
  Ask the number only if they clearly have one in mind; otherwise propose it.
- **Odds shown?** Always show them for anything random (players and Roblox both expect it).

## 3. Inventory & ownership
- **Duplicates?** Stack / merge N → upgraded version / auto-convert to shards.
- **Inventory cap?** Cap + sell back / no cap / small cap + Robux expansion.
- **Equipped vs owned**: what counts as "in use" (seated, equipped, following you) and how you put
  one in use: tap-then-tap (phone-friendly) / drag / walk up + prompt.
- **Can you trade or gift it?** (opens a whole trading system: usually "not now".)

## 4. Where it lives
- **Where do you do it?** A place in the world / a button from anywhere / both.
- **When is it blocked?** e.g. never during the competitive phase, so a 5-second animation never
  costs you the round.
- **Hotbar / HUD layout** (use an ASCII `preview`): what's in the bar, where the new button sits.
- **Phone first**: if an option is fiddly on touch (drag-and-drop, tiny targets), say so.

## 5. Feel
- **How does rarity show?** The box glows the best result's color / cards flip one by one / both.
- **What's special for the best rarity?** A unique animation, sound, camera.
- **Who sees it?** Just you / everyone nearby / the whole server (banner) / all servers
  (MessagingService).
- **After you get it, what plays?** Reuse an existing reveal / fly straight into the inventory /
  big reveal only for high rarities.
- **Skip / fast mode for repeat use?**

## 6. Onboarding
- **When does a new player first meet it?** Which day, round or step, and who guides them
  (an NPC, arrows).
- **Rigged first time?** Guaranteed good result; how the cards look (1 good + fillers with the good
  one highlighted / all good / free choice).
- **Where does the first currency come from?** A bonus equal to the exact price, and when it lands.
- **Does the tutorial also teach the follow-up action** (equip, seat, place)?
- **Edge**: a returning player who already did it, or who skips.

## 7. Monetization (Robux)
- **Paid random?** If they want Robux → random result, raise it plainly (policy + audience) and
  offer: earned currency for the random version + Robux buys specific items directly.
- **What's in the Robux store?** Starter pack (one-time, fixed contents) / specific premium items /
  passes (more slots, 2x, skip animations, +1 free daily) / soft-currency bundles.
- **Where does the store open?** Its own button / a tab in the existing shop / a world stall.
- **Does anything bought touch a competitive leaderboard?** It shouldn't, unless they insist.

## 8. Content
- **How big is the roster?** You invent ~N per rarity for them to edit / fill gaps only / they write it.
- **Rarity names and colors**: keep theirs.
- **Visual rules for new items** (art style the game already uses).

## 9. Next steps (always the last round)
- **What should I do now?** Spec only / spec + design screens (Figma etc.) / spec + build.
- **Version control**: commit / commit + push / leave the files.
