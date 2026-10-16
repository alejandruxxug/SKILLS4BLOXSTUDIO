-- Server bootstrap: require every Service, Init them all (wire dependencies), then Start them all.
-- Not --!strict on purpose: the type checker can't follow requires of modules found at runtime.

local Services = script.Parent:WaitForChild("Services")

local registry = {}
for _, module in Services:GetChildren() do
	if module:IsA("ModuleScript") then
		registry[module.Name] = require(module)
	end
end

-- Init: grab other services from the registry, create state. Never yield here.
for _, service in registry do
	if service.Init then
		service:Init(registry)
	end
end

-- Start: begin running (connections, loops). Each in its own thread so one can't block another.
for _, service in registry do
	if service.Start then
		task.spawn(service.Start, service)
	end
end

print("[init] server ready")
