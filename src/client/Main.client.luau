--!strict
local Players = game:GetService("Players")
local CAS = game:GetService("ContextActionService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local player = Players.LocalPlayer
local remote = game:GetService("ReplicatedStorage")
	:WaitForChild("GravityFoundryShared")
	:WaitForChild("FoundryAction")
local gui = Instance.new("ScreenGui")
gui.Name = "FoundryHUD"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")
local function text(name, size, pos, content)
	local t = Instance.new("TextLabel")
	t.Name = name
	t.Size = size
	t.Position = pos
	t.BackgroundColor3 = Color3.fromRGB(17, 24, 29)
	t.BackgroundTransparency = 0.15
	t.TextColor3 = Color3.fromRGB(220, 238, 240)
	t.Font = Enum.Font.GothamBold
	t.TextSize = 16
	t.TextWrapped = true
	t.Text = content
	t.Parent = gui
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(58, 116, 126)
	stroke.Parent = t
	return t
end
text("Title", UDim2.fromOffset(290, 48), UDim2.fromOffset(20, 18), "GRAVITY / FOUNDRY")
local status =
	text("Status", UDim2.fromOffset(290, 70), UDim2.fromOffset(20, 74), "Linking gauntlet…")
local objective = text(
	"Objective",
	UDim2.new(0.6, 0, 0, 52),
	UDim2.fromScale(0.2, 0.02),
	"PULL SCRAP • SMASH MACHINERY • CLEAR THE FOUNDRY"
)
local notice = text(
	"Notice",
	UDim2.new(0.6, 0, 0, 42),
	UDim2.fromScale(0.2, 0.82),
	"E / L2: pull nearby scrap     Click / R2: launch at crosshair"
)
local cross = text("Reticle", UDim2.fromOffset(24, 24), UDim2.new(0.5, -12, 0.5, -12), "+")
cross.BackgroundTransparency = 1
local function button(y, caption, action)
	local b = Instance.new("TextButton")
	b.Size = UDim2.fromOffset(290, 42)
	b.Position = UDim2.fromOffset(20, y)
	b.BackgroundColor3 = Color3.fromRGB(37, 71, 78)
	b.TextColor3 = Color3.new(1, 1, 1)
	b.Font = Enum.Font.GothamBold
	b.TextSize = 15
	b.Text = caption
	b.Parent = gui
	b.Activated:Connect(function()
		remote:FireServer(action)
	end)
	return b
end
local power = button(154, "POWER", "power")
local capacity = button(202, "ORBIT", "capacity")
local replay = button(250, "RESTART WITH UPGRADES", "replay")
replay.Visible = false
local function action(name, state)
	if state ~= Enum.UserInputState.Begin then
		return Enum.ContextActionResult.Pass
	end
	if name == "Pull" then
		remote:FireServer("pull")
	else
		local camera = workspace.CurrentCamera
		local ray = camera:ViewportPointToRay(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
		local params = RaycastParams.new()
		params.FilterDescendantsInstances = { player.Character }
		local hit = workspace:Raycast(ray.Origin, ray.Direction * 500, params)
		remote:FireServer("launch", hit and hit.Position or ray.Origin + ray.Direction * 500)
	end
	return Enum.ContextActionResult.Sink
end
CAS:BindAction("Pull", action, true, Enum.KeyCode.E, Enum.KeyCode.ButtonL2)
CAS:BindAction("Launch", action, true, Enum.UserInputType.MouseButton1, Enum.KeyCode.ButtonR2)
CAS:SetPosition("Pull", UDim2.fromScale(0.7, 0.65))
CAS:SetPosition("Launch", UDim2.fromScale(0.85, 0.55))
remote.OnClientEvent:Connect(function(kind, data)
	if kind == "state" then
		status.Text = "SALVAGE  "
			.. data.salvage
			.. "\nPOWER "
			.. data.power
			.. "   •   ORBIT "
			.. (data.capacity + 1)
		power.Text = "UPGRADE POWER / " .. data.powerCost .. " Salvage"
		capacity.Text = "UPGRADE ORBIT / " .. data.capacityCost .. " Salvage"
		objective.Text = data.won and "REACTOR SILENCED / FOUNDRY RECLAIMED"
			or ({
				"01 / Clear machinery and sentinels to open the press hall",
				"02 / Clear the press hall to breach the reactor",
				"03 / Pull cyan guardian cores and throw them back",
			})[data.sector]
		replay.Visible = data.won
	elseif kind == "notice" then
		notice.Text = data
	elseif kind == "impact" then
		local p = Instance.new("Part")
		p.Shape = Enum.PartType.Ball
		p.Size = Vector3.one
		p.Anchored = true
		p.CanCollide = false
		p.CanQuery = false
		p.Material = Enum.Material.Neon
		p.Color = Color3.fromRGB(90, 235, 255)
		p.Position = data
		p.Parent = workspace
		TweenService
			:Create(p, TweenInfo.new(0.3), { Size = Vector3.new(8, 8, 8), Transparency = 1 })
			:Play()
		Debris:AddItem(p, 0.35)
		for _ = 1, 7 do
			local shard = Instance.new("Part")
			shard.Size = Vector3.new(0.2, 0.2, 0.8)
			shard.Anchored = true
			shard.CanCollide = false
			shard.CanQuery = false
			shard.Material = Enum.Material.Neon
			shard.Color = Color3.fromRGB(255, 170, 65)
			shard.Position = data
			shard.Parent = workspace
			local offset = Vector3.new(math.random(-7, 7), math.random(1, 7), math.random(-7, 7))
			TweenService
				:Create(shard, TweenInfo.new(0.4), { Position = data + offset, Transparency = 1 })
				:Play()
			Debris:AddItem(shard, 0.45)
		end
	end
end)
remote:FireServer("ready")

-- A local gauntlet silhouette follows the character's right hand.
local function equip(character)
	local hand = character:WaitForChild("RightHand", 3) or character:FindFirstChild("Right Arm")
	if not hand then
		return
	end
	local shell = Instance.new("Part")
	shell.Name = "GravityGauntlet"
	shell.Size = Vector3.new(1.2, 1, 1.4)
	shell.Material = Enum.Material.Metal
	shell.Color = Color3.fromRGB(43, 56, 64)
	shell.CanCollide = false
	shell.CanQuery = false
	shell.Massless = true
	shell.CFrame = hand.CFrame
	shell.Parent = character
	local weld = Instance.new("WeldConstraint")
	weld.Part0, weld.Part1 = hand, shell
	weld.Parent = shell
	local glow = Instance.new("PointLight")
	glow.Color = Color3.fromRGB(70, 225, 255)
	glow.Range = 7
	glow.Brightness = 0.7
	glow.Parent = shell
end
player.CharacterAdded:Connect(equip)
if player.Character then
	task.spawn(equip, player.Character)
end
local health =
	text("Health", UDim2.fromOffset(290, 32), UDim2.new(0, 20, 1, -50), "INTEGRITY / 100")
game:GetService("RunService").RenderStepped:Connect(function()
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		health.Text = "INTEGRITY / " .. math.ceil(humanoid.Health)
	end
end)
