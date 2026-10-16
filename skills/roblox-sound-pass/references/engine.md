# The engine: rules, numbers, and why

The templates in `assets/templates/` implement all of this. This page is for when you adapt or
tune them.

## Pools and the shuffle bag (A)

- A pool is a list of takes. `deal(name)` shuffles a fresh bag when the old one is empty, deals
  from the end and **never starts a new bag with the take that just played**. You can't get the
  same take twice in a row, and every take plays once per cycle.
- 1 take = a signature sound. Mark it `exact`.
- The first id is the "signature take": the one a splash screen preloads and the panel lists
  first.

## Micro-jitter (B)

Pitch spread 0.06 (±3 %) and volume spread 0.16 (±8 %). More than about ±5 % pitch starts to
sound wrong on melodic stings, which is why stings with a key skip pitch jitter in practice (the
transposition already moves them) and brand stings are `exact`.

## Tiers + fatigue (D, E)

| Tier | Layers | Typical trigger |
|---|---|---|
| tiny | bright ding + a short clap | small win, harvest, minor reward |
| nice | the signature (e.g. a cash bell) + a rotating tail | a normal win |
| big | nice + punch (mid-bass) + crowd, music ducks to 45 % | a top-10 % win |
| huge | `hero()` with the fanfare pool + crowd | rarest moments only (top rarity, #1, jackpot) |

**Fatigue**: a celebration within **1.5 s** of the last plays one tier lighter (huge is exempt).
4 s was tried and it swallowed legitimate fast back-to-back wins, so keep it short. That's for
truly stacked events only. Loops where rapid repeats *are* the fun (harvest runs) pass
`noFatigue`.

## Hero hit (Q1)

```
[riser 1.0 s, music ducks to 35 %] → [150 ms silence, music at 2 %] → HIT:
   snap (first 30 ms transient) + body (the stinger) + punch (0.9×) + sparkle (+60 ms)
   → crowd: cheer +150 ms, applause +400 ms (0.8×) · music ducks to 30 % for 2.5 s
```

- The **silence** is the trick: contrast makes the hit feel louder than any volume could.
- Play only the riser's **tail** (`tail = RISER_LEAD + 0.05`) so it *ends* exactly on the hit,
  whatever its length. Preload risers so `TimeLength` is known.
- `hero()` returns `hitIn` (seconds to the hit). The caller times its flash, shake or confetti to
  it.

## Streak ladder (F)

The major scale `{0,2,4,5,7,9,11,12}` semitones. Each consecutive win plays its sound at
`2^(step/12)` pitch, capped at the octave. A loss resets. If the streak was ≥ 2, play a "bwomp"
(slide whistle down) so the loss lands with humour, not punishment.

## The mix (Q2)

- Groups under SoundService: **Music**, **Ambience**, **Sfx**, **SfxDry** (UI, no reverb; follows
  the Sfx slider). Group volume = mix level × player slider × Master.
- **Music**: `CompressorSoundEffect` with SideChain = the Sfx group. Threshold −28 dB, ratio 3,
  attack 0.02, release 0.35. That's automatic ducking under every effect. Add an
  `EqualizerSoundEffect` with MidGain −2.5 so voices and stings own the mids.
- **Sfx**: a `ReverbSoundEffect` with presets per room, switched as the player moves:
  - Hall: DecayTime 2.2, WetLevel −12 (big, echoey)
  - Street/outdoor: DecayTime 0.8, WetLevel −26 (almost dry)
  - Corridor/small: DecayTime 1.4, Diffusion 0.5, WetLevel −10 (tight, slappy)
- Explicit `Sounds.duck(seconds, level)` on top for the big moments (the compressor alone is
  gentle).

## Stingers in key (Q3)

- `keys[id]` = the major tonic in semitones above C (a minor key → its relative major).
- `Music._step` sets the music key from the **loudest playing song** that has a known key.
- `deal()` prefers the next take in the bag within **±2 semitones** of the music key (still
  never the last take).
- `play()` then transposes by the wrapped shift `(musicKey − key + 6) % 12 − 6` if
  `|shift| ≤ 3`. Beyond that, a stinger sounds chipmunked or muddy, so it plays as is.

## Music director

- Each track is one looping `Sound`. `set(mix)` sets each track's target (0..1), and a Heartbeat
  eases the volumes (1.5 s fades).
- **Roll**: `roll(name)` picks a different take as *pending*, and it swaps in once that track is
  silent. Roll at a natural boundary *before* the track is next faded in (e.g. roll the day
  playlist when the night starts). A new player starts each track on a random take.
- **Tape-stop**: volume and PlaybackSpeed ramp down together over 0.45 s to 35 % speed, hold in
  silence, then come back over 0.6 s. Play a "power down" or "record scratch" take at the start
  and the sting about 0.3 s in, into the silence. Verified numbers: volume about 0.07 at about
  ×0.54 speed 0.4 s in, back to normal by about 3.9 s with a 2.4 s hold.
- **Tension**: a ticking track fades in and the main song speeds up ×1.06 in the last N
  seconds.
- Moment themes (a shop, a podium) go through a `SetTheme(track | nil)` on the controller, and
  `nil` returns to the phase's music. Closing the audition panel also calls it.

## Voices

Pick a cartoon "nonsense / gibberish voice" recording (3–5 takes for variety). Each character
blip plays a random slice of 0.1 s ±20 % at the speaker's pitch × (1 ± 0.06). Skip
non-alphanumeric characters. Typical pitches: a small or old character 1.2–1.4, a big or bossy
one 0.7–0.8.
