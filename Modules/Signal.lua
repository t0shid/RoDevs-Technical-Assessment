local Signal = {}
Signal.__index = Signal

type Connection = {
	Disconnect: (self: Connection) -> (),
	Connected: boolean
}

function Signal.new()
	local self = setmetatable({}, Signal)
	self._listeners = {}
	return self
end

function Signal:Connect(callback: (...any) -> ()): Connection
	local connection = {
		Connected = true,
		Disconnect = function(self)
			self.Connected = false
		end
	}

	table.insert(self._listeners, {callback = callback, conn = connection})

	
	connection.Disconnect = function(innerSelf)
		innerSelf.Connected = false
		for i, listener in ipairs(self._listeners) do
			if listener.conn == innerSelf then
				table.remove(self._listeners, i)
				break
			end
		end
	end

	return connection
end

function Signal:Fire(...: any)
	for _, listener in ipairs(self._listeners) do
		if listener.conn.Connected then
			task.spawn(listener.callback, ...)
		end
	end
end

function Signal:Destroy()
	self._listeners = {}
end

return Signal
