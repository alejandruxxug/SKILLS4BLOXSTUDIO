-- Client bootstrap: the mirror of the server's Main. Controllers → Init all → Start all.
-- Not --!strict on purpose: the type checker can't follow requires of modules found at runtime.

local Controllers = script.Parent:WaitForChild("Controllers")

local registry = {}
for _, module in Controllers:GetChildren() do
	if module:IsA("ModuleScript") then
		registry[module.Name] = require(module)
	end
end

for _, controller in registry do
	if controller.Init then
		controller:Init(registry)
	end
end

for _, controller in registry do
	if controller.Start then
		task.spawn(controller.Start, controller)
	end
end

print("[init] client ready")
