--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Project =
	require(ReplicatedStorage:WaitForChild("GravityFoundryShared"):WaitForChild("Project"))

print(string.format("[%s] Client scaffold ready", Project.Name))
