--!strict
-- Every sound in the game, as POOLS. A name ("WinBell") is a family of takes: Sounds.play deals
-- them from a shuffle bag, so the same take never plays twice in a row. The first id is the
-- signature take. Rename the pools to your game's moments and replace the ids with your
-- picks. The ids below are licensed Pro Sound Effects / APM examples, so load-check them in your
-- place (scripts/check_load.luau). Mark community uploads with "community": they can go private.
--
-- Fields:
--   ids     the takes (pool)
--   volume  base volume
--   group   Music · Ambience · Sfx (the player's volume sliders)
--   exact   brand / signature stings: no pitch or volume jitter
--   dry     UI sounds: skip the room reverb
--   keys    [id] = the key as its MAJOR tonic in semitones above C (0 = C, 2 = D, 9 = A; a minor
--           key is stored as its relative major: A minor = 0). Stingers with a key are dealt and
--           transposed to fit the music; songs with a key set it. Only confident detections
--           (scripts/detect_key.luau).
--
-- 🎧 The admin AUDITION panel plays every take in context and lets the developer keep or drop
-- each one. Its picks are baked back into this file.

export type Entry = {
	ids: { number },
	volume: number,
	group: "Music" | "Ambience" | "Sfx",
	exact: boolean?,
	dry: boolean?,
	keys: { [number]: number }?,
	note: string?,
}

local function sfx(ids: { number }, volume: number, extra: { [string]: any }?): Entry
	local e: any = { ids = ids, volume = volume, group = "Sfx" }
	for k, v in extra or {} do
		e[k] = v
	end
	return e
end

local function music(ids: { number }, volume: number, keys: { [number]: number }?): Entry
	return { ids = ids, volume = volume, group = "Music", exact = true, keys = keys }
end

local SoundBank: { [string]: Entry } = {
	-- ── music: one playlist per phase, rolled at each boundary (Music.luau) ──────────────────
	MusicMain = music({ 1841069215, 9042763691 }, 0.5, { [1841069215] = 0, [9042763691] = 0 }), -- KPM "Disco Biscuits" · "Gravy Train" (A minor)
	MusicCalm = music({ 1842211849 }, 0.4), -- swap in a lo-fi playlist
	TickTock = music({ 9043366464 }, 0.55), -- tension: last seconds of a timer
	MusicVictory = music({ 9045045062, 9045044931 }, 0.55, { [9045045062] = 6, [9045044931] = 6 }), -- "Victory March" C / B

	-- ── brand stings: never rotate, never jitter ────────────────────────────────────────────
	Bell = sfx({ 9113804401 }, 0.8, { exact = true }), -- a round starts / ends
	NewsSting = sfx({ 9042410252 }, 0.7, { exact = true }), -- the game's "big news" moment
	TapeStop = sfx({ 9117869243, 9113908286, 9118089309 }, 0.45), -- power down / record scratch

	-- ── UI ──────────────────────────────────────────────────────────────────────────────────
	Click = sfx({ 9119717529, 9119717523 }, 0.5, { dry = true }),

	-- ── celebration tiers (Sounds.celebrate) ────────────────────────────────────────────────
	Ding = sfx({ 9126073318, 9126072452 }, 0.35), -- tiny: one bright bell
	Clap = sfx({ 9113137945, 9113137718, 9113138088 }, 0.5), -- tiny: a short tight clap
	WinBell = sfx({ 9113728049 }, 0.7, { exact = true }), -- nice: the signature (PSE cash register)
	WinTail = sfx({ 9113849731, 9125444677, 9125444505, 9113849011 }, 0.45), -- nice: rotating coins under it
	Cheer = sfx({ 9114015257, 9114015379, 9114015460, 9114015321 }, 0.6), -- big: PSE "Crowd Whoops"
	Applause = sfx({ 9113137529 }, 0.5), -- huge only
	Fanfare = sfx({ 1836473422, 1844584698, 1845411858, 1842141543 }, 0.65, {
		keys = { [1836473422] = 7, [1844584698] = 10, [1845411858] = 5, [1842141543] = 2 },
	}), -- huge: APM victory stings, rotated and kept rare
	Trombone = sfx({ 1841185078, 1841185109, 9120066378 }, 0.6), -- a loss
	Bwomp = sfx({ 9119197920, 9119198132 }, 0.45), -- a streak ends

	-- ── hero-hit layers (Sounds.hero) ───────────────────────────────────────────────────────
	Riser = sfx({ 9043344250, 9120768247 }, 0.55), -- build-up (only its tail plays)
	Snap = sfx({ 9043367155, 9119717529 }, 0.5), -- the first 30 ms
	Punch = sfx({ 9113551983, 9043341746, 9125401735 }, 0.7), -- the boom you feel
	Sparkle = sfx({ 9126073318, 9126072452, 9125635650 }, 0.45), -- shimmer tail

	-- ── voices: babble (Voices.luau chops 80–120 ms syllables) ──────────────────────────────
	Babble = sfx({ 9125857684, 9125857919, 9125857923 }, 0.35, { dry = true }), -- PSE cartoon nonsense voice
}

return SoundBank
