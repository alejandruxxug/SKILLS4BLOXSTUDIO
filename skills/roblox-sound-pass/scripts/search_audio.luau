-- Search Roblox's LICENSED audio library (APM Music, Pro Sound Effects, DistroKid).
-- Run with execute_luau in the SERVER datamodel while Play is running. Returns one text block.
-- Edit QUERIES: { keyword, "Music" | "SoundEffect", minSeconds?, maxSeconds?, howMany }
local QUERIES = {
	{ "cash register", "SoundEffect", nil, 3, 5 },
	{ "crowd cheer", "SoundEffect", nil, 5, 5 },
	{ "victory sting", "SoundEffect", nil, 6, 5 },
	{ "funk", "Music", 90, nil, 5 },
	{ "lofi", "Music", 90, nil, 5 },
}
local ALLOW_DISTROKID = true -- DistroKid tracks are licensed music too

local AssetService = game:GetService("AssetService")

local function licensed(a): string?
	local d = tostring(a.Description or "")
	if d:find("Pro Sound Effects") then
		return "PSE"
	elseif d:find("APM") then
		return "APM"
	end
	local creator = a.Creator and tostring(a.Creator.Name) or ""
	if ALLOW_DISTROKID and creator:lower():find("distrokid") then
		return "DK"
	end
	return nil
end

local function search(kw, subType, minDur, maxDur, n)
	local p = Instance.new("AudioSearchParams")
	p.SearchKeyword = kw
	p.AudioSubType = Enum.AudioSubType[subType]
	if minDur then
		p.MinDuration = minDur
	end
	if maxDur then
		p.MaxDuration = maxDur
	end
	local ok, pages = pcall(function()
		return AssetService:SearchAudio(p)
	end)
	if not ok then
		return { "  ERR " .. tostring(pages) }
	end
	local out = {}
	for _ = 1, 4 do
		for _, a in pages:GetCurrentPage() do
			local src = licensed(a)
			if src then
				local key = tostring(a.Description or ""):match("Key:%s*(%a[#b]?%s*%a+)") -- APM prints it
				table.insert(
					out,
					string.format(
						"  %d  %3ss  %-3s %-14s | %s%s",
						a.Id,
						tostring(a.Duration),
						src,
						tostring(a.Artist):sub(1, 14),
						tostring(a.Title):sub(1, 48),
						if key then "  [key " .. key .. "]" else ""
					)
				)
				if #out >= n then
					return out
				end
			end
		end
		if pages.IsFinished or not pcall(function()
			pages:AdvanceToNextPageAsync()
		end) then
			break
		end
	end
	return out
end

local lines = {}
for _, q in QUERIES do
	table.insert(lines, q[1] .. " (" .. q[2] .. "):")
	for _, l in search(q[1], q[2], q[3], q[4], q[5]) do
		table.insert(lines, l)
	end
end
return table.concat(lines, "\n")
