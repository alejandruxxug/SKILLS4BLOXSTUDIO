--!strict
-- ONE place that defines every remote. The server creates them; the client waits for them.
-- Add a name to EVENTS (fire-and-forget) or FUNCTIONS (ask and get an answer), then use Net.<Name>.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local EVENTS: { string } = {}
local FUNCTIONS: { string } = { "Ping", "Debug" }

local FOLDER_NAME = "Net"

local folder: Instance
if RunService:IsServer() then
	folder = ReplicatedStorage:FindFirstChild(FOLDER_NAME) or Instance.new("Folder")
	folder.Name = FOLDER_NAME
	-- Reuse what exists: a second copy of this module (e.g. required from the Studio MCP's
	-- execute_luau) must not create duplicate remotes.
	local function ensure(className: string, name: string)
		if not folder:FindFirstChild(name) then
			local remote = Instance.new(className)
			remote.Name = name
			remote.Parent = folder
		end
	end
	for _, name in EVENTS do
		ensure("RemoteEvent", name)
	end
	for _, name in FUNCTIONS do
		ensure("RemoteFunction", name)
	end
	folder.Parent = ReplicatedStorage
else
	folder = ReplicatedStorage:WaitForChild(FOLDER_NAME)
end

local Net: { [string]: any } = {}
for _, name in EVENTS do
	Net[name] = folder:WaitForChild(name)
end
for _, name in FUNCTIONS do
	Net[name] = folder:WaitForChild(name)
end

return Net
