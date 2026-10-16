-- Detect the musical key of tracks / stings. Run with execute_luau in the CLIENT datamodel while
-- Play is running. Nothing is heard: the AudioPlayer is wired only to an analyzer.
--
-- How: play each id at SPEED× into an AudioAnalyzer. GetSpectrum() has 512 bins over 0–24 kHz
-- (≈47 Hz each), too coarse for semitones at normal speed. At 4× the content moves up, and we
-- divide back down, which gives ≈12 Hz resolution. Use bin CENTERS (i − 0.5); the left edge
-- mis-reads keys. The power in 200–4000 Hz is folded into 12 pitch classes and correlated with
-- the Krumhansl major/minor profiles.
--
-- Output per id: best key, correlation, [per-window keys], length.
-- Trust it when: a song's windows agree, or a sting's correlation ≥ 0.65. Store it as the
-- MAJOR tonic (0 = C … 11 = B); minor → its relative major (A minor = 0, i.e. +3 semitones).
-- Validate first on an APM id whose description prints "Key: …".
local IDS = { 1841069215, 9042409054 } -- paste ids here (about 40 at once is fine)

local SPEED, BIN = 4, 24000 / 512
local MAJ = { 6.35, 2.23, 3.48, 2.33, 4.38, 4.09, 2.52, 5.19, 2.39, 3.66, 2.29, 2.88 }
local MIN = { 6.33, 2.68, 3.52, 5.38, 2.60, 3.53, 2.54, 4.75, 3.98, 2.69, 3.34, 3.17 }
local NAMES = { "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B" }

local function corr(x, prof, r)
	local mx, mp = 0, 0
	for i = 1, 12 do
		mx += x[i]
		mp += prof[i]
	end
	mx /= 12
	mp /= 12
	local num, dx, dp = 0, 0, 0
	for i = 1, 12 do
		local xi = x[((i - 1 + r) % 12) + 1] - mx
		local pi = prof[i] - mp
		num += xi * pi
		dx += xi * xi
		dp += pi * pi
	end
	return num / math.sqrt(dx * dp)
end

local function keyOf(acc)
	local chroma = table.create(12, 0)
	for i, v in acc do
		local freq = (i - 0.5) * BIN / SPEED
		if freq > 200 and freq < 4000 then
			local pc = (math.floor(12 * math.log(freq / 440, 2) + 0.5) + 9) % 12
			chroma[pc + 1] += v
		end
	end
	local best, bk, bm = -2, 0, ""
	for k = 0, 11 do
		for _, m in { { "maj", MAJ }, { "min", MIN } } do
			local c = corr(chroma, m[2], k)
			if c > best then
				best, bk, bm = c, k, m[1]
			end
		end
	end
	return bk, bm, best
end

-- the value to store in SoundBank keys
local function storeAs(k, mode)
	return if mode == "min" then (k + 3) % 12 else k
end

local results = {}
local function analyze(id)
	local p = Instance.new("AudioPlayer")
	p.Asset = "rbxassetid://" .. id
	p.PlaybackSpeed = SPEED
	local a = Instance.new("AudioAnalyzer")
	local w = Instance.new("Wire")
	local f = Instance.new("Folder")
	f.Name = "_KeyDetect"
	f.Parent = workspace
	p.Parent, a.Parent, w.Parent = f, f, f
	w.SourceInstance, w.TargetInstance = p, a
	local t0 = os.clock()
	while not p.IsReady and os.clock() - t0 < 10 do
		task.wait(0.1)
	end
	if not p.IsReady then
		f:Destroy()
		results[id] = id .. " NOT READY (bad id?)"
		return
	end
	local len = p.TimeLength
	local song = len > 40
	-- songs: two 24 s windows (25 % and 60 % in) that must agree; stings: the whole file
	local windows = if song then { len * 0.25, len * 0.6 } else { 0 }
	local keys, total = {}, table.create(512, 0)
	for _, start in windows do
		local acc = table.create(512, 0)
		p.TimePosition = start
		p:Play()
		local tEnd = os.clock() + (if song then 24 else len) / SPEED
		while os.clock() < tEnd and p.IsPlaying do
			task.wait(0.02)
			for i, v in a:GetSpectrum() do
				acc[i] += v * v
				total[i] += v * v
			end
		end
		p:Stop()
		local k, m = keyOf(acc)
		table.insert(keys, NAMES[k + 1] .. m)
	end
	f:Destroy()
	local k, m, c = keyOf(total)
	local agree = #keys < 2 or keys[1] == keys[2]
	local confident = if song then agree else c >= 0.65
	results[id] = string.format(
		"%d  %s%s  r=%.2f  [%s]  %.0fs  %s",
		id,
		NAMES[k + 1],
		m,
		c,
		table.concat(keys, "/"),
		len,
		if confident then "→ keys[" .. id .. "] = " .. storeAs(k, m) else "(not confident: skip)"
	)
end

for _, id in IDS do
	task.spawn(analyze, id)
end
local t0 = os.clock()
while os.clock() - t0 < 60 do
	local done = 0
	for _ in results do
		done += 1
	end
	if done == #IDS then
		break
	end
	task.wait(0.3)
end
local out = {}
for _, id in IDS do
	table.insert(out, results[id] or (id .. " TIMEOUT"))
end
return table.concat(out, "\n")
