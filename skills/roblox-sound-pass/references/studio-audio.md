# Studio audio APIs: what works where

## Which datamodel

| Task | Datamodel | Needs Play? | Notes |
|---|---|---|---|
| `AssetService:SearchAudio` | Server | yes (worked reliably there) | Edit is unavailable while Play runs, so do all of it in one Play session |
| Load-check (`Sound.IsLoaded`, `TimeLength`) | Server | yes | Parent the Sounds to SoundService; wait up to ~12 s |
| Key detection (`AudioPlayer` → `Wire` → `AudioAnalyzer`) | Client | yes | Nothing is heard: the player isn't wired to an output |
| Read audition picks | Client | yes | `Players.LocalPlayer:GetAttribute("AuditionPicks")` |
| Fire a moment to test (`Sounds.celebrate`, `hero`) | Client | yes | `require` in `execute_luau` returns a **fresh module copy**: its state (e.g. the music key, the streak) isn't the game's. To test the live state, go through the game's own entry point (e.g. click the admin button with `user_mouse_input` + `instance_path`) |

## SearchAudio

```lua
local p = Instance.new("AudioSearchParams")
p.SearchKeyword = "cash register"
p.AudioSubType = Enum.AudioSubType.SoundEffect -- or .Music
p.MaxDuration = 3 -- seconds (optional), MinDuration too
local pages = AssetService:SearchAudio(p)       -- pcall it
for _, a in pages:GetCurrentPage() do ... end    -- a.Id, a.Title, a.Artist, a.Duration, a.Description, a.Creator.Name
pages:AdvanceToNextPageAsync()                   -- pcall; stop at pages.IsFinished
```

- **The licence filter**: licensed results have `Description` containing "APM" or "Pro Sound
  Effects", or a DistroKid creator (music). Everything else is a community upload.
- APM descriptions often state the key ("Key: D Maj") and the BPM, which is a free cross-check
  for key detection.
- PSE sound effects come in families of consecutive ids (e.g. "Crowd Whoops 1..6"). When one
  take fits, its siblings usually make a ready-made pool.
- Searching is slow-ish (one request per page). Batch many queries into one `execute_luau` call
  and return one text block.

## Key detection, why it's built this way

- `AudioAnalyzer:GetSpectrum()` returns **512 bins over 0–24 kHz** (≈ 46.9 Hz each). At normal
  speed that can't separate semitones below ~800 Hz. **Playing at 4× speed** moves the content
  up, then the frequency is divided back by 4, which gives ~11.7 Hz effective resolution.
- Use **bin centers** (`(i − 0.5) × binWidth`). Using the bin's left edge shifted the result by
  a semitone or more (a D major sting read as F# minor).
- Fold 200–4000 Hz (true frequency) into 12 pitch classes, weighting by power (v²). Correlate
  with the Krumhansl-Kessler major and minor profiles at all 12 rotations, and take the best.
- **Songs**: analyse two windows (25 % and 60 % into the track, 24 s each) and trust the key only
  if they agree. **Stings**: the whole file, trusted at correlation ≥ 0.65.
- Validate on 1–2 ids whose key is printed in their APM description before trusting a batch.
- Analyse many ids in parallel (`task.spawn` each). About 40 ids finish in under 40 s.

## Other gotchas

- `SoundGroup` effects (`CompressorSoundEffect`, `ReverbSoundEffect`, `EqualizerSoundEffect`)
  parented to the group apply to every Sound in it. `CompressorSoundEffect.SideChain` = another
  SoundGroup works: the music compresses when that group is loud.
- A Studio Edit preview can leave effect instances saved in the place. Reuse them with
  `FindFirstChildOfClass` instead of stacking duplicates.
- `Sound.TimeLength` is 0 until it loads. Preload risers (`ContentProvider:PreloadAsync`) when you
  play only their tail so they end exactly on the hit.
- Built-in Roblox sounds (`rbxasset://sounds/...`) need no id and never go private. They're good
  fallbacks.
- Ids from the Toolbox can be private or region-locked. Always load-check in the actual place.
