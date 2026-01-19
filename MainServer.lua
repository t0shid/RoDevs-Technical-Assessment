local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Entity = require(ReplicatedStorage.Modules.Entity)


local resourceFolder = workspace:FindFirstChild("Resources") or Instance.new("Folder")
resourceFolder.Name = "Resources"
resourceFolder.Parent = workspace


local function spawnFood()
	local p = Instance.new("Part")
	p.Size = Vector3.new(2, 2, 2)
	p.Color = Color3.fromRGB(255, 255, 0)
	p.Position = Vector3.new(math.random(-60, 60), 1, math.random(-60, 60))
	p.Name = "Food"
	p.Anchored = true 
	p.Parent = resourceFolder
end


for i = 1, 5 do
	local part = Instance.new("Part")
	part.Name = "Agent_AI_" .. i
	part.Size = Vector3.new(4, 4, 4)
	part.Position = Vector3.new(math.random(-10, 10), 10, math.random(-10, 10))
	part.Material = Enum.Material.Neon
	part.Anchored = false 
	part.Parent = workspace

	local agent = Entity.new(part)
	agent.StateChanged:Connect(function(s)
		print("Agent " .. i .. " est maintenant : " .. s)
	end)
end


task.spawn(function()
	while true do
		if #resourceFolder:GetChildren() < 10 then
			spawnFood()
		end
		task.wait(3)
	end
end)
