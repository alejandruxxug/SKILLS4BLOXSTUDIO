-- Check that every id actually loads in THIS place (private / deleted / region-locked ids fail
-- silently in game). Run with execute_luau in the SERVER datamodel while Play is running.
local IDS = { 9113728049, 9114015257 } -- paste every candidate id here

local holder = Instance.new("Folder")
holder.Name = "_AudioLoadCheck"
holder.Parent = game:GetService("SoundService")
local sounds = {}
for _, id in IDS do
	local s = Instance.new("Sound")
	s.SoundId = "rbxassetid://" .. id
	s.Parent = holder
	sounds[id] = s
end
local t0 = os.clock()
while os.clock() - t0 < 12 do
	local all = true
	for _, s in sounds do
		if not s.IsLoaded then
			all = false
			break
		end
	end
	if all then
		break
	end
	task.wait(0.25)
end
local bad, good = {}, {}
for _, id in IDS do
	local s = sounds[id]
	if s.IsLoaded and s.TimeLength > 0 then
		table.insert(good, string.format("%d=%.1fs", id, s.TimeLength))
	else
		table.insert(bad, tostring(id))
	end
end
holder:Destroy()
return string.format(
	"LOAD %d/%d\nBAD: %s\nGOOD: %s",
	#good,
	#IDS,
	table.concat(bad, ", "),
	table.concat(good, "  ")
)
