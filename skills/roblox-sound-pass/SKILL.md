---
name: roblox-sound-pass
description: >
  Give a Roblox game a full sound pass through the Roblox Studio MCP. Audit every sound and find
  what repeats. Propose a sound plan the developer picks from. Source licensed music and SFX from
  Roblox's audio library (search, load-check, key detection). Build a pooled sound engine: shuffle
  bags, micro-jitter, celebration tiers, layered hero hits, streak ladders, sidechain ducking, room
  reverb, rotating playlists, tape-stops and babble voices. Add an in-game 🎧 audition panel so the
  developer picks takes by ear, then bake those picks back into code. Use this whenever the user
  says their game's sounds or music are repetitive, samey, boring or "always the same", wants new
  songs or better SFX, wants wins or celebrations to sound bigger, asks to rotate music, find Roblox
  audio ids, detect a song's key or "juice up" the audio, or says "bake my audition picks", even if
  they never say "sound pass". Not for swapping one sound id (just do that) or for audio outside
  Roblox.
user-invocable: true
---

# Roblox sound pass

The developer's complaint is almost always the same: *"the same sound plays every time and it
gets old."* They don't want the game's identity swapped out. They want it to **keep its voice
but never repeat the same line**, and to make the big moments sound *big*.

Your job has three parts, in this order of importance:
1. **Structure.** Build an engine where repetition is impossible and the size of a sound
   matches the size of the moment.
2. **Candidates.** Find licensed takes that fit, and check each one loads.
3. **Taste goes to the developer.** You can't hear audio. Every "this sounds great" is their
   call, made in an audition panel inside their own game. Never claim a sound *sounds* good. Say
   what it is (source, length, key) and let them judge.

## 0. Ground rules

- **Edit code in files** if the project syncs with Rojo or Argon (look for `default.project.json`
  or `*.project.json`). Use Studio only to run Play and `execute_luau` probes.
- **Ask before starting or stopping Play** if other sessions might share the Studio instance
  (`list_roblox_studios`). Starting Play takes over the Studio for everyone else.
- Load the Studio tools in one `ToolSearch` (`select:` list): list_roblox_studios,
  get_studio_state, start_stop_play, execute_luau, get_console_output, user_mouse_input,
  screen_capture.
- Respect the project's conventions: formatter (stylua), commit rules and folder layout. Write
  code that reads like the surrounding code.

## 1. Audit: where does it repeat?

Before proposing anything, map what exists. Grep the code for `SoundId`, `rbxassetid`,
`Instance.new("Sound")`, `:Play()` and any existing sound module. Also check the place for
`Sound` instances under the workspace and SoundService (`execute_luau` in Edit).

Build one table: **moment → how often it fires → id(s) → size of the moment**. Then mark:
- **Hotspots**: frequent moments (clicks, taps, every cash-out) that play one fixed id. These
  wear out first.
- **Size mismatches**: a small win and a jackpot that share a sound, or a fanfare on something
  that happens every 10 seconds (it stops feeling special).
- **One-song games**: a single music loop for a whole session.
- **Signature sounds**: the 3–6 sounds that *are* the game's identity (an opening bell, a
  countdown drum, a news sting, a mascot's call). These stay fixed: no rotation, no jitter.
  Recognisability is the point. Confirm the list with the developer.

## 2. Propose: let the developer pick

Present a menu, not a decision. `references/plan-menu.md` has the full menu (rules A–F, music
M-slots, quality bar Q1–Q6, new sounds, voices), each in plain language with an example from
*their* game. If an Artifact tool is available, publish the menu as a page they can read on
their phone. Otherwise use AskUserQuestion in rounds. Recommend a default, mark what's
expensive (uploads, commissioned stingers) and say clearly what you can't do (judge how it
sounds).

If they say "I want the best-sounding ones", don't promise taste. Explain that you'll build the
quality bar (layered hero hits, the mix, stingers in key) and hand them an audition panel to
choose by ear. That's the honest way to get "incredible".

## 3. Source licensed audio

Roblox's library has thousands of **licensed** tracks and effects (APM Music, Pro Sound Effects,
DistroKid). They're free to use in any experience and they don't go private. Community uploads
can be taken down at any time, so prefer licensed takes and flag every community id in the bank.

1. **Search**: run `scripts/search_audio.luau` with `execute_luau` in the **Server** datamodel
   while Play is running. Edit them in the query table at the top: keyword, subtype
   (Music/SoundEffect), duration bounds and count. It only returns licensed results (the
   description names APM or Pro Sound Effects, or the creator is DistroKid). Search for each
   moment several ways ("cash register", "coins", "register bell") and collect 3–6 candidates
   per pool.
2. **Load-check**: run `scripts/check_load.luau` (Server, Play) on every id before it goes in the
   bank. Bad ids fail silently in-game. Report it as "N/N load".
3. **Key detection** (for music and melodic stingers): run `scripts/detect_key.luau` in the
   **Client** datamodel during Play. It plays each id at 4× speed into an AudioAnalyzer (not
   wired to any output, so nothing is heard), builds a chroma from the 512-bin spectrum and
   matches it against Krumhansl major/minor profiles. Store a key **only when it's confident**: a
   song whose two windows agree, or a sting whose correlation is ≥ 0.65. Store it as the major
   tonic in semitones above C, with a minor key stored as its relative major (A minor = 0). The
   script explains why 4× speed and bin centers matter. Without them, D major stings read as
   F# minor.

`references/studio-audio.md` has the API details and the gotchas (what works in which datamodel,
what the search returns, rate limits).

## 4. Build the engine

Start from the templates in `assets/templates/` and adapt them to the game. Rename the pools to
the game's moments and wire them into the existing call sites. Don't bolt a second sound system
on next to the old one. Replace the old call sites so everything goes through the engine.

| File | What it gives you |
|---|---|
| `SoundBank.luau` | Every sound as a **pool**: `{ids, volume, group, exact?, dry?, keys?}` |
| `Sounds.luau` | Shuffle bag · jitter · `celebrate(tier)` with fatigue · `hero()` · streak ladder · groups with sidechain ducking, EQ and room reverb · key transposition · `override()` for audition |
| `Music.luau` | Named tracks with crossfades, playlists that **roll** while silent, `duck`, `tapeStop`, `audition` and the music key feed |
| `Voices.luau` | Animal Crossing–style babble: random 80–120 ms slices of a gibberish recording at each speaker's pitch |
| `AuditionPanel.luau` | A self-contained admin panel to play each take, keep or drop it, and fire whole moments |

`references/engine.md` explains every rule, the numbers that worked and the ones that didn't
(e.g. a fatigue of 4 s swallowed fast back-to-back wins, so 1.5 s is used). Read it before you
change a constant.

Wiring checklist:
- Every frequent moment plays a pool of ≥ 3 takes. Signature sounds are `exact` with 1 take.
- Wins go through `Sounds.celebrate(tier)`, sized to the moment. The fanfare (huge tier) is kept
  for rare moments.
- The rarest moments use `Sounds.hero` (riser → 150 ms of silence → layered hit), and visuals land
  on the returned `hitIn`.
- Music: one playlist per phase or place, rolled at a natural boundary (a new day, a new round).
  Short themed loops go on special screens (a shop, a podium).
- UI clicks are `dry` (no room reverb). Positional world sounds pass `at`, and only play near the
  player.
- Volume settings: the player's sliders scale the groups (`Sounds.setVolume`).

## 5. The 🎧 audition panel and baking picks

Gate the panel behind the game's admin check. Every take gets ▶ (hear it alone; music plays on
its real track) and ✓/+ (keep or drop it, applied live via `Sounds.override`). Add extra
candidates per pool as grey **+** takes. Add ▶ MOMENT buttons that fire the real combination
(each celebration tier, a streak of 5, the hero hit, the tape-stop sequence). People judge a
sound in context, not alone.

Every change saves the attribute `AuditionPicks` (JSON: pool → kept ids) on the LocalPlayer and
prints it. When the developer says **"bake my audition picks"**:
1. With Play still running (the attribute dies with the session), run `scripts/read_picks.luau`
   in the Client datamodel.
2. Rewrite each pool's `ids` in `SoundBank.luau`. Keep the signature first, then the kept order.
   Keep `keys` entries for kept ids and for any candidates that are still listed.
3. Remove baked candidates from the panel's candidate list, run the formatter and show the diff
   summary (pool: before → after).

## 6. Verify in Play

Verify what code can verify, and say plainly what it can't.

- The console is clean after start (no "failed to load" or "unknown sound").
- The groups exist with their effects: SoundService → the Music group has a Compressor with
  SideChain set, the Sfx group has a Reverb.
- Music plays, and a roll swaps the take after a phase change. Sample `Volume` and
  `PlaybackSpeed` during a tape-stop: it should dip to near 0 at about 35 % speed, then recover.
- `celebrate` (each tier), `hero` and the streak run through `execute_luau` without errors.
- The audition panel renders and its buttons are on-screen (click them via `instance_path`).

Not verifiable by you: **how it sounds**, the balance on phone speakers, and real gameplay
triggers you didn't play through. List these in the report as the developer's to check.

## 7. Report

Keep it short and concrete. The developer reads it in chat:

```
**What changed:** <rules in plain words: "nothing plays the exact same twice in a row", tiers, hero
hits, the mix, music slots, new sounds, voices>, plus what stayed fixed (the signature list)
**Sources:** N sounds, all licensed (PSE/APM/DistroKid) unless flagged · N/N load
**How to pick by ear:** <where the 🎧 panel is> → ▶ / ✓ / + → say "bake my audition picks"
**Your jobs:** <uploads / commissioned stingers if they chose them, with the brief's location>
**Not verified:** how it sounds, phones, <triggers not played through>
```

If the project keeps design docs, add a sound page covering the files, rules, music slots,
audition how-to and any upload or stinger briefs (`references/plan-menu.md` → Q5/Q6 has the
brief template).
