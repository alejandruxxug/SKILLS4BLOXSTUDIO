# The sound plan menu

Present these to the developer as options, each with a one-line example from **their** game.
Group them the way they're grouped here. Recommend a default (✅ below), but let them pick.
"Everything" is a valid answer.

## Rules: how repetition dies (A–F) ✅ all recommended, they're cheap

| | Rule | Plain words | Example to show |
|---|---|---|---|
| A | **Shuffle bag** | Each sound has 3–6 versions, dealt like cards: all of them play before any repeats, and never the same one twice in a row | "Your coin sound has 4 takes now; you'd need 5 cash-outs to hear one twice" |
| B | **Micro-jitter** | Every play shifts pitch ±3 % and volume ±8 %, so even the same take never sounds identical | "Ten clicks in a row sound like a hand, not a machine" |
| C | **Signature + flavour** | The iconic part stays fixed, and a layer under it rotates | "The cha-ching bell is always the same; the coins under it change" |
| D | **Tiers** | tiny / nice / big / huge: the size of the sound matches the size of the moment | "A +5 % win gets a ding; a 10× gets cha-ching + crowd; a jackpot gets the fanfare" |
| E | **Fatigue** | A celebration right after another plays one tier lighter, so stacked moments don't turn into noise | "Three sells in one second won't triple-fanfare" |
| F | **Streak ladder** | Back-to-back wins climb a musical scale; a loss after a streak goes "bwomp" | "Win 5 in a row and you hear it climbing" |

## Music (M-slots), one per phase or place the game has

Map each to the game's real phases and screens. Typical slots:
- **Phase playlists** (day/night, lobby/round, calm/combat): 3–5 tracks each, a new one at each
  boundary, never the one just heard.
- **Moment themes**: a victory/podium march, a shop loop, a boss sting, a tutorial pulse.
- **Interrupt effect**: a tape-stop (the music winds down, a sting hits into the silence, the
  music comes back), for the game's "big news" moment.
- **Rarity hits**: a draw/gacha/egg sound per rarity, getting bigger as the rarity goes up.
- **Tension**: the last N seconds of a timer add a ticking layer and speed the song up slightly.

## Quality bar (Q1–Q6): making the best moments *incredible*

| | Option | Cost | What to say honestly |
|---|---|---|---|
| Q1 | **Layered hero hits**: riser → 150 ms of silence → snap + body + punch + sparkle at once, then the crowd | Code only ✅ | This is how film and AAA trailers make a hit feel huge. Keep it for the rarest moments |
| Q2 | **The mix**: music ducks under every effect on its own (sidechain), reverb that matches the room, a music EQ dip so stings cut through | Code only ✅ | Makes everything sound "produced" without new sounds |
| Q3 | **Stingers in key**: win stings are dealt and transposed to fit the key of the song that's playing | Code + key detection ✅ | Detection is automatic but not perfect, so only confident keys are used |
| Q4 | **🎧 Audition panel** in the admin menu, to pick takes by ear in context | Code ✅ | The only way to get "the best sounding". The developer has the ears |
| Q5 | **Pro royalty-free packs** (e.g. the Sonniss GDC bundles, Kenney CC0) uploaded to Roblox | The developer's time + monthly upload limit | Uploads go through their account. Read each pack's licence |
| Q6 | **Custom signature stingers**: a 2–3 s jingle, the big-news sting, the rarest-reward sting, a podium march built on the jingle's motif | Money/time (commission or produce) | Gives the game sounds no other game has. Ask for stems, 48 kHz and a written commercial licence or work-for-hire |

### Q6 brief template (put it in the design docs)

| Stinger | Length | Feel | Where it plays | Key |
|---|---|---|---|---|
| Jingle | 2–3 s | <the game's attitude in 3 adjectives + instruments> | splash, phase start | <a key near the music's keys> |
| Big-news sting | ~1.5 s | urgency with a wink | the interrupt moment | — |
| Rarest reward | ~2.5 s | orchestra hit + choir + harp up | top-rarity reveal | pick from the detected keys |
| Podium / victory | 8–15 s, loopable | the jingle's motif as a march | end-of-round winners | same as the jingle |

### Q5 upload steps

1. Pick only what the hero moments need. Trim the silence, export .ogg or .mp3 (mono for 3D
   sounds).
2. Creator Hub → Creations → Development Items → Audio → Upload (limited per month; more when
   ID-verified).
3. Paste the ids into the matching pool. They show up in the 🎧 panel.

## New sounds (S)

Go through the audit's **silent moments**: actions with no sound at all (planting, equipping,
seating, an NPC appearing, a door, a button that toggles). Propose one sound family for each,
with a short reason. Positional world sounds only play near the player.

## Voices (V)

**Babble**: speech bubbles "talk" in gibberish syllables (random 80–120 ms slices of a
cartoon-nonsense recording), with a pitch per character. Cheap, charming and it makes every
NPC feel alive. Silent on spaces and punctuation, so sentences have rhythm.
