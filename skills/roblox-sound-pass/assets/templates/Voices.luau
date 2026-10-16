--!strict
-- 🗣️ Character voices, Animal Crossing style: as a speech bubble types out, each syllable plays
-- a 80–120 ms slice cut from a random spot of a cartoon gibberish recording (SoundBank.Babble).
-- Every speaker has a fixed pitch (a small character high, a boss deep, a guard gruff...), so
-- they sound like THEMSELVES, and since every slice is random it never repeats exactly.

local Sounds = require(script.Parent.Sounds)

local Voices = {}

local SLICE = 0.1 -- seconds per syllable (±20 %)

-- One syllable in a voice of `pitch`. Spaces and punctuation stay silent.
function Voices.blip(pitch: number, char: string?)
	if char and not string.match(char, "%w") then
		return
	end
	Sounds.play("Babble", {
		slice = SLICE * (0.8 + math.random() * 0.4),
		pitch = pitch * (0.92 + math.random() * 0.16), -- a voice wobbles a little, like talking
	})
end

return Voices
