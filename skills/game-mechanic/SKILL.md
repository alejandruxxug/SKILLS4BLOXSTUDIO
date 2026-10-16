---
name: game-mechanic
description: >
  Turn a rough Roblox game-mechanic idea into a fully defined, build-ready spec (.md) by asking the
  developer easy, plain-language questions, where every question says how the mechanic plugs into the
  game they already have. Covers economy, randomness/gacha, inventory, UI, animation beats, tutorial,
  monetization (with Roblox policy checks), data, server/client split, edge cases and a build order,
  and ends by offering to build it. Use this whenever the user describes a new system, feature, loop
  or mechanic for their Roblox game and wants it designed, defined, specced, planned or "asked about"
  before coding: pets, eggs/gacha, shops, trading, quests, rebirths, inventories, hotbars, crates,
  battle passes, events, minigames. Use it even if they just dump the idea in one long message and
  say "ask me questions" or "define this". Not for fixing bugs or for playtesting.
user-invocable: true
---

# Roblox game-mechanic definer

The developer has an idea in their head. Your job is to get it **out of their head and into a spec
so complete that any agent (or the developer next week) can build it without asking again**.
The output is a `.md` file. Building is offered at the end, not started.

Two things make this work, and both matter more than the template:

1. **Questions a 13-year-old could answer in 5 seconds.** No jargon ("server-authoritative RNG",
   "schema"). Each question names the part of *their* game it touches ("this decides which wallet
   the boxes drain: right now Coins is what you spend on upgrades"). Each option says what would
   actually happen in the game if they pick it.
2. **Grounding in the real game.** A mechanic is never alone: it spends a currency that exists,
   lives on a screen that exists, collides with a tutorial that exists. A spec that ignores those
   gets rebuilt. Find them first.

## 1. Ground yourself (before the first question)

Look for what already exists, quickly (minutes, not an audit):
- **Design notes / knowledge base**: the project's docs, an Obsidian vault, a `docs/` folder, a
  CLAUDE.md, memory files. Look for currencies, the core loop, rules the developer has set
  ("Robux never buys X"), past decisions about this same idea.
- **Code** (if the project uses Rojo/files): config modules (catalogs, prices, rarities), services
  touching the same data, the UI root and theme, the player-data module (what's saved).
- **Studio**, only if there's no code on disk: `search_game_tree` / `script_search` through the
  Roblox Studio MCP. Read-only; don't edit anything.

Write yourself a short **integration map**: every existing system the mechanic will touch
(currency, saved data, UI buttons, NPCs, tutorial, other mechanics it overlaps or replaces). These
become the "how it plugs in" lines in your questions and a table in the spec.

If the developer's idea contradicts a rule they set earlier, or something already built, note
it now: you'll raise it as a question, not silently pick one side.

## 2. Ask

Use `AskUserQuestion` (4 questions per round, 2–4 options each, recommended option first with
"(Recommended)"). Plan the rounds from big to small, so early answers can reshape later ones:

1. **Money & getting it**: what it costs, which currency, Robux or not, what it replaces
2. **Rules & randomness**: odds, choice, duplicates, pity/bad-luck protection, limits
3. **Where it lives**: screens, buttons, world locations, when it's allowed (phases/zones)
4. **Feel**: animation beats, what's special for rare outcomes, what other players see
   + **art timing** for this mechanic: follow the game's build mode (CLAUDE.md / hub: greybox
   first or art first) unless its fun *is* its visuals (a reveal, an entrance) and it should be
   art-first. Ask only when it's not obvious; record the answer in the spec.
5. **Onboarding**: how a new player meets it, rigged first experience, tutorial steps
6. **Content & extras**: roster/items, Robux store items, what you should do next

Read `references/question-bank.md` for ready-made question shapes per category. Pick the ones
that matter for *this* mechanic and skip the rest.

How to write each question:
- One decision per question. Plain words. Put the integration fact in the question itself.
- Options are **consequences**, not labels: "Unpicked cards turn into shards, so bad luck still
  moves you forward" beats "Shards".
- Use `preview` (ASCII mockups) when the choice is visual: layout of a hotbar, a screen.
- **Don't ask what you can default.** Exact numbers (prices, odds, timings) go in the spec as
  tunables with your proposed values; ask only when the number is the design (e.g. "pity at 10?").
- Ask about the **next step** in the last round: spec only? also design screens? also build?
  commit/push? This lets the developer walk away while you work.

Reading answers: the developer often answers in the free-text "Other" field with something
bigger than any option ("both, AND the whole server should see it"). That free text is the real
answer: it may add scope, override a recommendation, or answer a different question. Restate
anything ambiguous as a confirm question in the next round rather than guessing. Keep going until
there are no gaps a builder would have to guess at. Usually that's 4–6 rounds for a big system.

If the developer is unavailable (they said "use your judgment", "I'm leaving", or you run without
a user), take the recommended option for each open decision and list it under **Assumptions** in
the spec so they can overturn it in one glance.

### Be honest, not agreeable

You're the designer in the room, not a yes-machine. Raise these as questions with the trade-off
spelled out, and let them decide:
- **Paid random items** (Robux → loot box/crate/egg/gacha pull). Roblox allows them only with odds
  shown **before** purchase and blocked where `PolicyService:GetPolicyInfoForPlayerAsync` says
  `ArePaidRandomItemsRestricted`. Many players are kids, and many games choose "Robux buys specific
  items, luck is earned" instead. Offer that alternative.
- **Pay-to-win** that touches a competitive leaderboard.
- Mechanics that **overlap** an existing one (two currencies doing the same job, two gacha machines).
- Scope the developer can't build in the time they have.

Once they've decided, write their decision down faithfully and move on. Don't re-argue it.

## 3. Write the spec

Save it where the project keeps design docs (next to the other design notes; ask only if there's
no obvious place). File name: `<Game> – <Mechanic>.md` or `<mechanic>-spec.md` to match the
folder's convention. Use the structure in `references/spec-template.md`. The non-negotiables:

- **Rules as numbered, testable statements** ("R7. Pity counts per box tier; a Rare+ card resets
  the Rare counter"). A builder checks them off; a tester verifies them.
- **Integration table**: existing system → what changes, file/module names when you know them.
- **Content tables with real proposed numbers** (odds per tier summing to 100%, prices, bonuses).
  Mark them as tunables and say where they'll live (a config module).
- **Animation beats with timings**, and what's different per rarity.
- **Assets needed**: every model, screen, icon and effect the mechanic needs, with where it's seen
  and any sketch the developer has. `roblox-art-pass` starts from this list.
- **Server/client split for Roblox**: all randomness, currency changes and saves happen on the
  server; the client only animates results it's told. Remotes listed with their validation.
  Robux purchases go through `MarketplaceService.ProcessReceipt` (developer products) or
  `UserOwnsGamePassAsync` (passes), are idempotent, and are granted only after the save succeeds.
  Cross-server announcements use `MessagingService`.
- **Saved data** additions and how old saves migrate (missing field → default).
- **Edge cases**: leaving mid-animation, full inventory, buying with not enough currency,
  double-taps, a purchase arriving while offline, a tutorial player who already owns the item.
- **Build order** in milestones, each with a "done when" check, smallest playable slice first.
- **Decision log**: every question you asked and the developer's answer, in their words where
  they wrote free text. This is how a future reader knows *why*.

Keep the developer's own names for things (their box names, their currency emoji), even if you'd
pick different ones.

If the project keeps a design log or changelog, add one row about this session.

## 4. Offer to build

End with a short message:
- where the spec is, in one line
- the 3–5 decisions that shaped it most, plus any assumption they should check
- the proposed build order (milestone names only)
- a direct offer: "Want me to build milestone 1 now?"

Don't start building until they say so. Building is a different kind of session (files, Studio,
playtests), and the developer may want to edit the spec first.
