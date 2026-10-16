-- Read the 🎧 audition picks (pool → kept ids). Run with execute_luau in the CLIENT datamodel
-- during the same Play session the developer auditioned in (the attribute dies when Play stops).
local json = game:GetService("Players").LocalPlayer:GetAttribute("AuditionPicks")
return json or "NO PICKS (was the panel used in this Play session?)"
