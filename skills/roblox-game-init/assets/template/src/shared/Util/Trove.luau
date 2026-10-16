--!strict
-- Cleanup bag: Add instances, connections, threads, functions or anything with :Destroy(),
-- then Clean() removes them all at once. Every screen/object owns one, so nothing leaks.

local Trove = {}
Trove.__index = Trove

export type Trove = typeof(setmetatable({} :: { _items: { any } }, Trove))

function Trove.new(): Trove
	return setmetatable({ _items = {} }, Trove)
end

function Trove.Add<T>(self: Trove, item: T): T
	table.insert(self._items, item)
	return item
end

function Trove.Clean(self: Trove)
	local items = self._items
	self._items = {}
	-- Newest first, so things are torn down in the reverse order they were built.
	for index = #items, 1, -1 do
		local item: any = items[index]
		local kind = typeof(item)
		if kind == "Instance" then
			item:Destroy()
		elseif kind == "RBXScriptConnection" then
			item:Disconnect()
		elseif kind == "function" then
			item()
		elseif kind == "thread" then
			pcall(task.cancel, item)
		elseif kind == "table" then
			if item.Destroy then
				item:Destroy()
			elseif item.Disconnect then
				item:Disconnect()
			end
		end
	end
end

Trove.Destroy = Trove.Clean

return Trove
