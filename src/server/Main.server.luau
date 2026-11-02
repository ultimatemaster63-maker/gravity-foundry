--!strict
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local arena = require(script.Parent.Arena).build()
local remote = Instance.new("RemoteEvent")
remote.Name = "FoundryAction"
remote.Parent = ReplicatedStorage.GravityFoundryShared
local states = {}
local sector = 1
local won = false
local function root(player)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid and humanoid.Health > 0 then
		return character:FindFirstChild("HumanoidRootPart")
	end
	return nil
end
local function sync(player)
	local s = states[player]
	remote:FireClient(player, "state", {
		salvage = s.cash,
		power = s.power,
		capacity = s.capacity,
		sector = sector,
		won = won,
		powerCost = 60 * s.power,
		capacityCost = 80 * s.capacity,
	})
end
local function broadcast()
	for player in states do
		sync(player)
	end
end
local function resetScrap(p, data)
	data.owner = nil
	data.projectile = nil
	p.CFrame = data.home
	p.Transparency = 0
	p.CanCollide = true
end
local function join(player)
	states[player] = { cash = 0, power = 1, capacity = 1, last = 0, held = {} }
	player.CharacterAdded:Connect(function()
		local s = states[player]
		if s then
			for _, p in s.held do
				resetScrap(p, arena.scrap[p])
			end
			s.held = {}
		end
	end)
end
Players.PlayerAdded:Connect(join)
for _, player in Players:GetPlayers() do
	join(player)
end
Players.PlayerRemoving:Connect(function(player)
	for p, data in arena.scrap do
		if data.owner == player then
			resetScrap(p, data)
		end
	end
	states[player] = nil
end)
remote.OnServerEvent:Connect(function(player, action, aim)
	local s = states[player]
	if not s or typeof(action) ~= "string" or os.clock() - s.last < 0.12 then
		return
	end
	s.last = os.clock()
	if action == "ready" then
		sync(player)
		return
	end
	local r = root(player)
	if not r then
		return
	end
	if action == "power" or action == "capacity" then
		local level = s[action]
		local cost = (action == "power" and 60 or 80) * level
		if s.cash >= cost and level < 5 then
			s.cash -= cost
			s[action] += 1
			sync(player)
		end
	elseif action == "pull" and not won then
		if #s.held >= s.capacity + 1 then
			return
		end
		local closest, best = nil, 48
		local params = RaycastParams.new()
		params.FilterDescendantsInstances = { player.Character }
		for p, data in arena.scrap do
			local distance = (p.Position - r.Position).Magnitude
			if not data.owner and not data.projectile and distance < best then
				local hit = workspace:Raycast(r.Position, p.Position - r.Position, params)
				if not hit or hit.Instance == p then
					closest, best = p, distance
				end
			end
		end
		if closest then
			arena.scrap[closest].owner = player
			closest.CanCollide = false
			table.insert(s.held, closest)
			remote:FireClient(player, "notice", "SCRAP CAPTURED")
		end
	elseif action == "launch" and not won then
		if
			typeof(aim) ~= "Vector3"
			or aim.X ~= aim.X
			or aim.Y ~= aim.Y
			or aim.Z ~= aim.Z
			or aim.Magnitude > 100000
		then
			return
		end
		local p = s.held[1]
		if not p then
			return
		end
		local direction = aim - p.Position
		if direction.Magnitude < 0.1 then
			return
		end
		table.remove(s.held, 1)
		arena.scrap[p].owner = nil
		arena.scrap[p].projectile =
			{ velocity = direction.Unit * 120, age = 0, player = player, power = s.power }
	elseif action == "replay" and won then
		won = false
		sector = 1
		for p, t in arena.targets do
			t.hp = t.max
			t.clock = 0
			p.CanQuery = true
			local label = p:FindFirstChildOfClass("BillboardGui")
			if label then
				label.TextLabel.Text = p.Name .. " / " .. t.hp
			end
			p.Transparency = 0
			p.CanCollide = true
			p.CFrame = t.home
		end
		for _, p in arena.gates do
			p.Transparency = 0
			p.CanCollide = true
			p.CanQuery = true
		end
		for p, d in arena.scrap do
			resetScrap(p, d)
		end
		for pl, st in states do
			st.held = {}
			local pr = root(pl)
			if pr then
				pr.CFrame = CFrame.new(0, 5, 30)
			end
		end
		broadcast()
	end
end)
local function damage(p, t, shot, component)
	if t.hp <= 0 or t.section > sector then
		return
	end
	t.hp = math.max(0, t.hp - (component and 180 or 35 + shot.power * 15))
	local gui = p:FindFirstChildOfClass("BillboardGui")
	if gui then
		gui.TextLabel.Text = p.Name .. " / " .. t.hp
	end
	remote:FireAllClients("impact", p.Position)
	if t.hp == 0 then
		p.Transparency = 1
		p.CanCollide = false
		p.CanQuery = false
		if gui then
			gui.TextLabel.Text = ""
		end
		local s = states[shot.player]
		if s then
			s.cash += t.reward
			remote:FireClient(shot.player, "notice", "+" .. t.reward .. " SALVAGE")
			local character = shot.player.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			if humanoid then
				humanoid.Health = math.min(humanoid.MaxHealth, humanoid.Health + 8)
			end
			sync(shot.player)
		end
		if t.kind == "boss" then
			won = true
			broadcast()
			return
		end
		local remaining = false
		for _, other in arena.targets do
			if other.section == sector and other.hp > 0 and other.kind ~= "boss" then
				remaining = true
			end
		end
		if not remaining and sector < 3 then
			local gate = arena.gates[sector]
			gate.CanCollide = false
			gate.CanQuery = false
			gate.Transparency = 0.85
			sector += 1
			broadcast()
		end
	end
end
RunService.Heartbeat:Connect(function(dt)
	local now = os.clock()
	for p, data in arena.scrap do
		if data.owner then
			local r = root(data.owner)
			if r then
				local index = table.find(states[data.owner].held, p) or 1
				local angle = now * 1.8 + index * 2.4
				local target = r.Position
					+ Vector3.new(
						math.cos(angle) * 5,
						2 + math.sin(angle * 0.7),
						math.sin(angle) * 5
					)
				p.CFrame = p.CFrame:Lerp(
					CFrame.new(target) * CFrame.Angles(now, index, now * 0.6),
					1 - math.exp(-12 * dt)
				)
			else
				resetScrap(p, data)
			end
		elseif data.projectile then
			local shot = data.projectile
			shot.age += dt
			local params = RaycastParams.new()
			params.FilterDescendantsInstances = { p, shot.player.Character }
			local delta = shot.velocity * dt
			local hit = workspace:Spherecast(p.Position, 1, delta, params)
			if hit or shot.age > 2 then
				if hit then
					local target = arena.targets[hit.Instance]
					if target then
						damage(hit.Instance, target, shot, data.component)
					end
					remote:FireAllClients("impact", hit.Position)
				end
				resetScrap(p, data)
			else
				p.Position += delta
			end
		end
	end
	for p, t in arena.targets do
		if
			t.hp > 0
			and t.section == sector
			and (t.kind == "drone" or t.kind == "boss")
			and not won
		then
			if t.kind == "drone" then
				p.Position = t.home.Position
					+ Vector3.new(math.sin(now) * 6, math.sin(now * 2) * 1.5, 0)
			end
			t.clock += dt
			p.Color = t.clock > 2 and Color3.fromRGB(255, 100, 30) or Color3.fromRGB(65, 72, 81)
			if t.clock > 3 then
				t.clock = 0
				for player in states do
					local r = root(player)
					if r and (r.Position - p.Position).Magnitude < 55 then
						local params = RaycastParams.new()
						params.FilterDescendantsInstances = { p }
						local hit = workspace:Raycast(p.Position, r.Position - p.Position, params)
						if hit and hit.Instance:IsDescendantOf(player.Character) then
							player.Character
								:FindFirstChildOfClass("Humanoid")
								:TakeDamage(t.kind == "boss" and 18 or 9)
							remote:FireClient(
								player,
								"notice",
								"INCOMING FIRE — BREAK LINE OF SIGHT"
							)
							remote:FireAllClients("impact", r.Position)
						end
					end
				end
			end
		end
	end
end)
