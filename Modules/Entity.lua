local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Signal = require(ReplicatedStorage.Modules.Signal)
local Pathfinder = require(ReplicatedStorage.Modules.Pathfinder)

local Entity = {}
Entity.__index = Entity


local HUNGER_THRESHOLD = 40
local ENERGY_THRESHOLD = 30

function Entity.new(instance: Instance)
	local self = setmetatable({}, Entity)

	self.Instance = instance

	
	if instance:IsA("Model") then
		self.PrimaryPart = instance.PrimaryPart or instance:FindFirstChildWhichIsA("BasePart")
	else
		self.PrimaryPart = instance :: BasePart
	end

	self.PathfindingLogic = Pathfinder.new()
	self.Stats = { Hunger = 100, Energy = 100, Health = 100 }
	self.StateChanged = Signal.new()
	self.CurrentState = "Idle"
	self.TargetPosition = nil
	self.IsActive = true

	task.spawn(function() self:_brainLoop() end)

	return self
end

function Entity:_brainLoop()
	while self.IsActive and self.Instance.Parent do
		task.wait(0.5)

		self.Stats.Hunger -= 1
		self.Stats.Energy -= 0.5

		local nextState = self:_decideNextState()
		if nextState ~= self.CurrentState then
			self.CurrentState = nextState
			self.StateChanged:Fire(nextState)
			self:_onStateEnter(nextState)
		end

		self:_processState()
	end
end

function Entity:_decideNextState(): string
	if self.Stats.Hunger < HUNGER_THRESHOLD then return "SearchingFood" end
	if self.Stats.Energy < ENERGY_THRESHOLD then return "Resting" end
	return "Roaming"
end

function Entity:_onStateEnter(state: string)
	if state == "Resting" then
		self.TargetPosition = nil
	elseif state == "Roaming" then
		self.TargetPosition = Vector3.new(math.random(-50, 50), 3, math.random(-50, 50))
	end
end

function Entity:_processState()
	if not self.PrimaryPart then return end

	if self.CurrentState == "Resting" then
		self.Stats.Energy = math.min(100, self.Stats.Energy + 5)
		self.PrimaryPart.Color = Color3.fromRGB(0, 170, 255)

	elseif self.CurrentState == "SearchingFood" or self.CurrentState == "Roaming" then
		if self.CurrentState == "SearchingFood" then
			self:_findFood() 
		else
			self.PrimaryPart.Color = Color3.fromRGB(100, 255, 100)
		end

		if self.TargetPosition then
			self:_moveToTarget()
		end
	end
end

function Entity:_findFood()
	local resources = workspace:FindFirstChild("Resources")
	if not resources or not self.PrimaryPart then return end

	local closest = nil
	local dist = 100

	for _, item in ipairs(resources:GetChildren()) do
		if item:IsA("BasePart") then
			local d = (item.Position - self.PrimaryPart.Position).Magnitude
			if d < dist then
				dist = d
				closest = item
			end
		end
	end

	if closest then
		self.TargetPosition = closest.Position
		self.PrimaryPart.Color = Color3.fromRGB(255, 150, 0)
		if dist < 5 then
			self.Stats.Hunger = 100
			closest:Destroy()
			self.TargetPosition = nil
		end
	end
end

function Entity:_moveToTarget()
	if not self.TargetPosition or not self.PrimaryPart then return end

	local path = self.PathfindingLogic:CalculatePath(self.PrimaryPart.Position, self.TargetPosition)

	if path and #path > 1 then
		local nextPoint = path[2]
		local direction = (nextPoint - self.PrimaryPart.Position).Unit
		
		self.PrimaryPart.AssemblyLinearVelocity = direction * 25
	end
end

return Entity
