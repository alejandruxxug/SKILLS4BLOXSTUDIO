# Spec template

Use these sections in this order. Drop a section only if it truly doesn't apply (say "n/a: why"
in one line rather than deleting it silently). Tables over prose wherever a builder will look
things up.

```markdown
# <Mechanic name>: build spec

> Status: ready to build · Defined <YYYY-MM-DD> with <developer> · Source: this Q&A (see Decision log)

## 1. In one breath
One paragraph: what the player does, why it's fun, what it feeds into.
**Player fantasy:** one line.

## 2. Player flow
Numbered steps from "player sees it" to "player uses the result", including the first-time path.

## 3. How it plugs into the game
| Existing system | What changes | Where (module/file/place) |

## 4. Rules
R1. … (numbered, each one testable)

## 5. Content & numbers (tunables → <ConfigModule>)
Tiers/items/rarities/odds (each tier's odds sum to 100%)/prices/bonuses/pity.
Say which numbers the developer fixed and which are your proposals.

## 6. Economy & monetization
Sources and sinks. Robux items (product type: developer product vs game pass), what each grants.
Policy: odds display, PolicyService check, no paid random unless the developer chose it (then how).

## 7. Screens & UI
For each screen/HUD piece: purpose · elements · states (empty, can't afford, full, cooldown) ·
phone layout · which existing theme/components to reuse. ASCII sketch if useful.

## 8. Animation & feel
Beat table: | Beat | Time | What happens | Rarity differences |
What other players see (nearby / server / global).

**Assets needed** (handed to `roblox-art-pass`): | # | Asset | Where it's seen | Kind (3D model / UI screen / icon / texture / sprite / thumbnail) | Size or budget | Sketch/reference from the developer | Priority (v0.1 / later) |
**Art timing:** greybox first (placeholders until the loop is approved) / art first (and why). Default = the game's build mode.
Reuse existing assets where possible and say which. Placeholders (parts, emoji) are fine for the first build; note which ones.

## 9. Onboarding / tutorial
When, who guides, rigged outcome, steps, skip, returning players.

## 10. Data
New saved fields (name, type, default), migration for old saves, what's session-only.

## 11. Server / client
Services/controllers (new + changed). Remotes: name · direction · args · server validation.
Where randomness happens (server). Purchase flow (ProcessReceipt, idempotent, grant after save).
Cross-server messaging if any. Anti-exploit notes (rate limits, ownership checks).

## 12. Edge cases
| Situation | What happens |

## 13. Build order
| # | Milestone | Done when |
Smallest playable slice first; tutorial and monetization usually last.

## 14. Test plan
Acceptance checks a tester (or a Studio playtest) can run, mapped to rules (R#).

## 15. Decision log
| # | Question | Answer (developer's words where free text) |

## 16. Assumptions & open questions
Anything you defaulted without asking, and anything still open.
```
