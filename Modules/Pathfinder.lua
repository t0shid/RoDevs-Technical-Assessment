local PathfindingService = game:GetService("PathfindingService")

local Pathfinder = {}
Pathfinder.__index = Pathfinder

function Pathfinder.new(agentParams: {[string]: any}?)
	local self = setmetatable({}, Pathfinder)
	self.AgentParams = agentParams or {
		AgentRadius = 3,
		AgentHeight = 6,
		AgentCanJump = true,
	}
	self.Path = PathfindingService:CreatePath(self.AgentParams)
	return self
end

function Pathfinder:CalculatePath(startPos: Vector3, targetPos: Vector3): {Vector3}?
	local success, errorMessage = pcall(function()
		self.Path:ComputeAsync(startPos, targetPos)
	end)

	if success and self.Path.Status == Enum.PathStatus.Success then
		local waypoints = self.Path:GetWaypoints()
		local positions = {}
		for _, waypoint in ipairs(waypoints) do
			table.insert(positions, waypoint.Position)
		end
		return positions
	else
		warn("Pathfinding failed: " .. tostring(errorMessage))
		return nil
	end
end

return Pathfinder
