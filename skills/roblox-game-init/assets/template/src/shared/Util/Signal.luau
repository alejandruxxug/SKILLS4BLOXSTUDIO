--!strict
-- Tiny event class: Connect a listener, Fire to call every listener, Destroy to drop them all.
-- Use it so systems announce changes ("OnPhaseChanged") instead of others polling every frame.

local Signal = {}
Signal.__index = Signal

export type Connection = { Disconnect: (any) -> () }
export type Signal = typeof(setmetatable({} :: { _listeners: { (...any) -> () } }, Signal))

function Signal.new(): Signal
	return setmetatable({ _listeners = {} }, Signal)
end

function Signal.Connect(self: Signal, listener: (...any) -> ()): Connection
	table.insert(self._listeners, listener)
	return {
		Disconnect = function(_)
			local index = table.find(self._listeners, listener)
			if index then
				table.remove(self._listeners, index)
			end
		end,
	}
end

function Signal.Fire(self: Signal, ...: any)
	-- Clone so a listener that disconnects while firing doesn't skip the next one.
	for _, listener in table.clone(self._listeners) do
		task.spawn(listener, ...)
	end
end

function Signal.Destroy(self: Signal)
	table.clear(self._listeners)
end

return Signal
