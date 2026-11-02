--!strict
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local shared = ReplicatedStorage:WaitForChild("GravityFoundryShared")
local Progression = require(shared.Progression)
local Gear = require(shared.Gear)
local CombatRules = require(shared.CombatRules)
local Orbit = require(shared.Orbit)
local arena = require(script.Parent.Arena).build()
local remote = Instance.new("RemoteEvent")
remote.Name = "FoundryAction"
remote.Parent = shared
local states: { [Player]: any } = {}
local sector, cycle = 1, 1
local won = false
local bossActive = false
local bossClock = 0
local exposedUntil = 0
local phaseLockUntil = 0
local wave = 0
local runStarted = os.clock()
local clearTime = 0
local votes: { [Player]: boolean } = {}
local threats: { any } = {}
local lastSync = 0
local function root(player: Player): BasePart?
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local r = character and character:FindFirstChild("HumanoidRootPart")
	if humanoid and humanoid.Health > 0 and r and r:IsA("BasePart") then
		return r
	end
	return nil
end
local function remaining(): number
	local n = 0
	for _, t in arena.targets do
		if t.kind ~= "guardian" and t.section == sector and t.hp > 0 then
			n += 1
		end
	end
	return n
end
local function voteCount(): number
	local n = 0
	for player in votes do
		if states[player] then
			n += 1
		end
	end
	return n
end
local function sync(player: Player)
	local s = states[player]
	if not s then
		return
	end
	for index, d in s.held do
		d.root:SetAttribute("OrbitOwner", player.UserId)
		d.root:SetAttribute("OrbitSlot", index)
		d.root:SetAttribute("OrbitCount", #s.held)
	end
	remote:FireClient(player, "state", {
		cash = s.cash,
		tier = s.tier,
		held = #s.held,
		sector = sector,
		remaining = remaining(),
		won = won,
		cycle = cycle,
		bossActive = bossActive,
		bossPhase = if arena.boss.hp > arena.boss.max * 2 / 3
			then 1
			elseif arena.boss.hp > arena.boss.max / 3 then 2
			else 3,
		bossHp = arena.boss.hp,
		bossMax = arena.boss.max,
		exposed = os.clock() < exposedUntil,
		seconds = if won then clearTime else math.floor(os.clock() - runStarted),
		kills = s.kills,
		voted = votes[player] == true,
		votes = voteCount(),
		players = #Players:GetPlayers(),
	})
end
local function broadcast()
	for player in states do
		sync(player)
	end
end
local function notice(player: Player, message: string)
	remote:FireClient(player, "notice", message)
end
local function fx(kind: string, data: any)
	remote:FireAllClients(kind, data)
end
local function setVisible(model: Model, visible: boolean)
	for _, p in model:GetDescendants() do
		if p:IsA("BasePart") then
			if p:GetAttribute("OriginalTransparency") == nil then
				p:SetAttribute("OriginalTransparency", p.Transparency)
			end
			local original = p:GetAttribute("OriginalTransparency")
			p.Transparency = if visible and typeof(original) == "number"
				then original
				else if visible then 0 else 1
		elseif p:IsA("BillboardGui") then
			p.Enabled = visible
		end
		if p:IsA("Highlight") then
			p.Enabled = visible
		end
	end
end
local function resetScrap(d: any, delay: number?)
	d.owner = nil
	d.shot = nil
	d.respawn = os.clock() + (delay or 0)
	d.model:PivotTo(d.home)
	d.root.CanCollide = false
	d.root.CanQuery = (delay or 0) == 0
	d.root:SetAttribute("Held", false)
	d.root:SetAttribute("OrbitOwner", nil)
	local trail = d.root:FindFirstChildOfClass("Trail")
	if trail then
		trail.Enabled = false
	end
	setVisible(d.model, (delay or 0) == 0)
end
local function release(player: Player)
	local s = states[player]
	if not s then
		return
	end
	for _, d in s.held do
		resetScrap(d, 0.5)
	end
	s.held = {}
end
local function equip(player: Player)
	local character = player.Character
	local s = states[player]
	if not character or not s then
		return
	end
	local hand = character:FindFirstChild("RightHand") or character:FindFirstChild("Right Arm")
	if not hand or not hand:IsA("BasePart") then
		return
	end
	local old = character:FindFirstChild("GravityGauntlet")
	if old then
		old:Destroy()
	end
	local model = Gear.build(s.tier)
	model:PivotTo(hand.CFrame * CFrame.new(0, -0.1, 0))
	for _, p in model:GetDescendants() do
		if p:IsA("BasePart") then
			p.Anchored = false
			local weld = Instance.new("WeldConstraint")
			weld.Part0 = hand
			weld.Part1 = p
			weld.Parent = p
		end
	end
	model.Parent = character
	player:SetAttribute("FoundryTier", s.tier)
end
local function characterAdded(player: Player, character: Model)
	release(player)
	local r = character:WaitForChild("HumanoidRootPart", 10)
	local humanoid = character:WaitForChild("Humanoid", 10)
	if not states[player] or player.Character ~= character then
		return
	end
	if r and r:IsA("BasePart") then
		r.CFrame = CFrame.new(0, 5, 35 - (sector - 1) * 100)
	end
	if humanoid and humanoid:IsA("Humanoid") then
		humanoid.WalkSpeed = 20
		humanoid.Died:Connect(function()
			release(player)
			sync(player)
		end)
	end
	equip(player)
	sync(player)
end
local function join(player: Player)
	if states[player] then
		return
	end
	states[player] = { cash = 0, tier = 1, held = {}, last = 0, launch = 0, pull = 0, kills = 0 }
	player.CharacterAdded:Connect(function(c)
		characterAdded(player, c)
	end)
	if player.Character then
		task.spawn(characterAdded, player, player.Character)
	end
end
Players.PlayerAdded:Connect(join)
for _, player in Players:GetPlayers() do
	join(player)
end
Players.PlayerRemoving:Connect(function(player)
	release(player)
	for _, d in arena.scraps do
		if d.shot and d.shot.player == player then
			resetScrap(d, 0.5)
		end
	end
	states[player] = nil
	votes[player] = nil
end)
local function resetRun()
	cycle += 1
	sector = 1
	won = false
	bossActive = false
	bossClock = 0
	exposedUntil = 0
	phaseLockUntil = 0
	wave = 0
	runStarted = os.clock()
	votes = {}
	threats = {}
	for _, t in arena.targets do
		if not t.baseHp then
			t.baseHp = t.max
		end
		t.max = math.floor(t.baseHp * Progression.multiplier(cycle))
		t.hp = t.max
		t.clock = 0
		t.model:PivotTo(t.home)
		setVisible(t.model, true)
		t.root.CanCollide = true
		t.root.CanQuery = true
		t.label.Text = string.upper(t.kind) .. " / " .. t.hp
	end
	for _, g in arena.gates do
		g.part.CFrame = g.home
		g.part.CanCollide = true
		g.part.CanQuery = true
		g.label.Text = "SECTOR LOCK / CLEAR MARKED TARGETS"
	end
	for _, d in arena.scraps do
		resetScrap(d)
	end
	arena.spawn.Position = Vector3.new(0, 0, 35)
	for player, s in states do
		s.held = {}
		local r = root(player)
		if r then
			r.CFrame = CFrame.new(0, 5, 35)
			local h = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
			if h then
				h.Health = h.MaxHealth
			end
		end
	end
	fx("replay", { cycle = cycle })
	broadcast()
end
local function visible(player: Player, origin: Vector3, d: any): boolean
	local params = RaycastParams.new()
	local ignores: { Instance } = { arena.scenery }
	if player.Character then
		table.insert(ignores, player.Character)
	end
	for _, other in arena.scraps do
		if other.owner == player then
			table.insert(ignores, other.model)
		end
	end
	params.FilterDescendantsInstances = ignores
	local hit = workspace:Raycast(origin, d.root.Position - origin, params)
	return not hit or hit.Instance:IsDescendantOf(d.model)
end
remote.OnServerEvent:Connect(function(player: Player, action: any, aim: any)
	local s = states[player]
	if not s or typeof(action) ~= "string" or #action > 16 then
		return
	end
	local now = os.clock()
	if now - s.last < 0.055 then
		return
	end
	s.last = now
	if action == "ready" then
		sync(player)
		return
	end
	local r = root(player)
	if not r then
		return
	end
	local tier = Progression.tiers[s.tier]
	if action == "upgrade" then
		local cash, newTier, ok = Progression.purchase(s.cash, s.tier)
		if not ok then
			notice(
				player,
				if s.tier == #Progression.tiers
					then "EVENT HORIZON / fully evolved"
					else "More Salvage needed. Clear marked machinery and drones."
			)
			return
		end
		s.cash = cash
		s.tier = newTier
		equip(player)
		remote:FireClient(player, "evolve", { tier = newTier })
		sync(player)
	elseif action == "vote" and won then
		votes[player] = true
		if voteCount() >= #Players:GetPlayers() then
			resetRun()
		else
			broadcast()
		end
	elseif action == "pull" and not won then
		if now - s.pull < 0.22 then
			return
		end
		s.pull = now
		if #s.held >= tier.capacity then
			notice(player, "Orbit full — launch a piece first")
			return
		end
		if typeof(aim) ~= "Vector3" or not Progression.finiteVector(aim) then
			return
		end
		local direction = aim - r.Position
		if direction.Magnitude < 0.1 then
			return
		end
		local best, bestScore = nil, -math.huge
		local tooHeavy = false
		for _, d in arena.scraps do
			local delta = d.root.Position - r.Position
			local distance = delta.Magnitude
			if
				not d.owner
				and not d.shot
				and now >= d.respawn
				and d.section <= sector
				and distance < tier.range
				and distance > 0.1
			then
				local alignment = direction.Unit:Dot(delta.Unit)
				if alignment > 0.05 and visible(player, r.Position, d) then
					if d.mass > tier.mass then
						tooHeavy = true
					elseif not d.component or (bossActive and now < exposedUntil) then
						local score = alignment * 60 - distance * 0.35
						if score > bestScore then
							best = d
							bestScore = score
						end
					end
				end
			end
		end
		if not best then
			notice(
				player,
				if tooHeavy
					then "Too heavy — evolve your gauntlet in the Forge"
					elseif
						bossActive and now >= exposedUntil
					then "Aim at visible scrap • guardian couplings open after its attack"
					else "Aim toward visible scrap within " .. tier.range .. " studs"
			)
			return
		end
		best.owner = player
		best.root.CanCollide = false
		best.root.CanQuery = false
		best.root:SetAttribute("Held", true)
		table.insert(s.held, best)
		fx(
			"capture",
			{ from = best.root.Position, to = r.Position, tier = s.tier, owner = player.UserId }
		)
		sync(player)
	elseif action == "launch" and not won then
		if
			now - s.launch < tier.cooldown
			or typeof(aim) ~= "Vector3"
			or not Progression.finiteVector(aim)
		then
			return
		end
		local d = s.held[1]
		if not d then
			notice(player, "Pull scrap with E / L2 first")
			return
		end
		local direction = aim - d.root.Position
		if direction.Magnitude < 0.1 then
			return
		end
		local clearance = RaycastParams.new()
		local ignore: { Instance } = { arena.scenery }
		if player.Character then
			table.insert(ignore, player.Character)
		end
		for _, held in s.held do
			table.insert(ignore, held.model)
		end
		clearance.FilterDescendantsInstances = ignore
		if workspace:Raycast(r.Position, d.root.Position - r.Position, clearance) then
			notice(player, "Orbit obstructed — step away from cover to launch")
			return
		end
		s.launch = now
		d.root:SetAttribute("OrbitOwner", nil)
		local trail = d.root:FindFirstChildOfClass("Trail")
		if trail then
			trail.Enabled = true
			trail.Lifetime = 0.12 + s.tier * 0.035
		end
		table.remove(s.held, 1)
		d.owner = nil
		d.shot = {
			velocity = direction.Unit * tier.speed,
			age = 0,
			player = player,
			tier = s.tier,
			damage = tier.damage * (1 + (d.mass - 1) * 0.25),
		}
		fx("launch", { position = d.root.Position, tier = s.tier, owner = player.UserId })
		sync(player)
	end
end)
local function advance()
	if remaining() > 0 then
		return
	end
	if sector < 3 then
		local g = arena.gates[sector]
		g.part.CanCollide = false
		g.part.CanQuery = false
		g.label.Text = "SECTOR CLEARED"
		TweenService:Create(
			g.part,
			TweenInfo.new(1.8, Enum.EasingStyle.Quad),
			{ CFrame = g.home + Vector3.new(0, 28, 0) }
		):Play()
		sector += 1
		arena.spawn.Position = Vector3.new(0, 0, 35 - (sector - 1) * 100)
		for _, s in states do
			s.cash += 50
		end
		fx("sector", { sector = sector })
	elseif not bossActive then
		bossActive = true
		bossClock = 0
		local count = math.max(1, #Players:GetPlayers())
		arena.boss.max = math.floor(1200 * Progression.multiplier(cycle) * (1 + (count - 1) * 0.5))
		arena.boss.hp = arena.boss.max
		fx("bossIntro", { position = arena.boss.root.Position })
	end
	broadcast()
end
local function reward(player: Player, amount: number)
	local s = states[player]
	if not s then
		return
	end
	s.cash += amount
	s.kills += 1
	local h = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if h then
		h.Health = math.min(h.MaxHealth, h.Health + 10)
	end
	remote:FireClient(player, "reward", { amount = amount })
end
local function damage(t: any, shot: any, component: boolean)
	if t.hp <= 0 or t.section > sector then
		return
	end
	if
		t.kind == "guardian" and (not bossActive or (os.clock() >= exposedUntil and not component))
	then
		notice(shot.player, "Guardian shielded — wait for cyan couplings to open")
		return
	end
	if t.kind == "guardian" and os.clock() < phaseLockUntil then
		notice(shot.player, "Containment rebuilding — dodge the next wave")
		return
	end
	local amount = if component then 260 else shot.damage
	local previousHealth = t.hp
	t.hp = CombatRules.damage(t.hp, t.max, amount, t.kind == "guardian")
	if t.kind == "guardian" and t.hp > 0 then
		local crossed = (previousHealth > t.max * 2 / 3 and t.hp <= t.max * 2 / 3)
			or (previousHealth > t.max / 3 and t.hp <= t.max / 3)
		if crossed then
			phaseLockUntil = os.clock() + 2
			exposedUntil = 0
			bossClock = 7
			fx("phase", {})
		end
	end
	t.label.Text = string.upper(t.kind) .. " / " .. math.ceil(t.hp)
	remote:FireClient(
		shot.player,
		"hit",
		{ damage = math.floor(previousHealth - t.hp), position = t.root.Position }
	)
	if t.hp <= 0 then
		t.root.CanQuery = false
		t.root.CanCollide = false
		setVisible(t.model, false)
		fx("destroy", { position = t.root.Position, size = t.root.Size, tier = shot.tier })
		reward(shot.player, math.floor(t.reward * (1 + (cycle - 1) * 0.1)))
		if t.kind == "guardian" then
			won = true
			clearTime = math.floor(os.clock() - runStarted)
			threats = {}
			for player, s in states do
				s.cash += 200
				release(player)
			end
			fx("victory", { seconds = clearTime, cycle = cycle })
		else
			advance()
		end
	end
	broadcast()
end
local function threaten(
	source: any,
	pos: Vector3,
	radius: number,
	delay: number,
	amount: number,
	ring: boolean?
)
	local item = {
		source = source,
		pos = pos,
		radius = radius,
		expires = os.clock() + delay,
		damage = amount,
		ring = ring or false,
	}
	table.insert(threats, item)
	fx("warning", { position = pos, radius = radius, duration = delay, ring = ring or false })
end
local function nearest(pos: Vector3, range: number): BasePart?
	local best = nil
	local distance = range
	for player in states do
		local r = root(player)
		if r then
			local d = (r.Position - pos).Magnitude
			if d < distance then
				best = r
				distance = d
			end
		end
	end
	return best
end
local function lineClear(pos: Vector3, r: BasePart, source: Model): boolean
	local params = RaycastParams.new()
	params.FilterDescendantsInstances = { source, arena.scenery }
	local hit = workspace:Raycast(pos, r.Position - pos, params)
	return not hit or (r.Parent ~= nil and hit.Instance:IsDescendantOf(r.Parent))
end
local simulationTime = 0
RunService.Heartbeat:Connect(function(delta: number)
	local dt = math.min(delta, 0.1)
	local now = os.clock()
	simulationTime += dt
	for _, d in arena.scraps do
		if d.owner then
			local r = root(d.owner)
			local s = states[d.owner]
			if r and s then
				local index = table.find(s.held, d) or 1
				local desired =
					Orbit.pose(r.Position, s.tier, index, #s.held, workspace:GetServerTimeNow())
				d.model:PivotTo(d.model:GetPivot():Lerp(desired, 1 - math.exp(-(9 + s.tier) * dt)))
			else
				resetScrap(d, 0.5)
			end
		elseif d.shot then
			local shot = d.shot
			shot.age += dt
			local params = RaycastParams.new()
			local ignores: { Instance } = { arena.scenery }
			if shot.player.Character then
				table.insert(ignores, shot.player.Character)
			end
			for _, other in arena.scraps do
				table.insert(ignores, other.model)
			end
			params.FilterDescendantsInstances = ignores
			local move = shot.velocity * dt
			local hit = workspace:Spherecast(d.root.Position, 0.7 + d.mass * 0.15, move, params)
			if hit or shot.age > 2.5 then
				if hit then
					for _, t in arena.targets do
						if hit.Instance:IsDescendantOf(t.model) then
							damage(t, shot, d.component)
							break
						end
					end
					fx("impact", { position = hit.Position, tier = shot.tier })
				end
				resetScrap(d, if d.component then 4 else 2)
			else
				d.model:PivotTo(d.model:GetPivot() + move)
			end
		elseif d.respawn > 0 and now >= d.respawn then
			d.respawn = 0
			d.root.CanQuery = true
			setVisible(d.model, true)
		end
		if d.component and not d.owner and not d.shot and d.respawn == 0 then
			d.root.Color = if bossActive and now < exposedUntil
				then Color3.fromRGB(85, 235, 255)
				else Color3.fromRGB(70, 80, 85)
			d.root.Material = if bossActive and now < exposedUntil
				then Enum.Material.Neon
				else Enum.Material.Metal
		end
	end
	for _, t in arena.targets do
		if not won and t.hp > 0 and t.section == sector and t.kind == "drone" then
			t.model:PivotTo(
				t.home
					* CFrame.new(
						math.sin(simulationTime * 0.8 + t.home.Position.X) * 5,
						math.sin(simulationTime * 1.7) * 0.7,
						0
					)
			)
			t.clock += dt
			if t.clock > 4.5 then
				local r = nearest(t.root.Position, 60)
				if r and lineClear(t.root.Position, r, t.model) then
					t.clock = 0
					threaten(t, Vector3.new(r.Position.X, 0.05, r.Position.Z), 5, 1.25, 12)
				end
			end
		end
	end
	if bossActive and not won then
		local heart = arena.boss.model:FindFirstChild("Reactor heart")
		local shield = arena.boss.model:FindFirstChild("Containment shield")
		if heart then
			heart.Color = if now < exposedUntil
				then Color3.fromRGB(75, 218, 235)
				else Color3.fromRGB(240, 126, 40)
		end
		if shield then
			shield.Transparency = if now < exposedUntil then 1 else 0.72
		end
		arena.boss.model:PivotTo(
			arena.boss.home * CFrame.new(0, math.sin(simulationTime * 1.5) * 0.4, 0)
		)
		bossClock += dt
		if bossClock >= 9 then
			bossClock = 0
			wave += 1
			local phase = if arena.boss.hp > arena.boss.max * 2 / 3
				then 1
				elseif arena.boss.hp > arena.boss.max / 3 then 2
				else 3
			if wave % 2 == 0 then
				threaten(arena.boss, Vector3.new(0, 0.1, -215), 34, 1.8, 22, true)
			else
				for player in states do
					local r = root(player)
					if r and r.Position.Z < -150 then
						threaten(
							arena.boss,
							Vector3.new(r.Position.X, 0.1, r.Position.Z),
							6 + phase,
							1.45,
							18 + phase * 3
						)
					end
				end
			end
			if phase >= 2 and wave % 2 == 1 then
				for player in states do
					local r = root(player)
					if r and r.Position.Z < -150 then
						threaten(
							arena.boss,
							Vector3.new(r.Position.X + 10, 0.1, r.Position.Z),
							6,
							2.1,
							20
						)
					end
				end
			end
			if phase == 3 and wave % 2 == 1 then
				threaten(arena.boss, Vector3.new(0, 0.1, -215), 34, 2.8, 22, true)
			end
			exposedUntil = now + 8
			fx("expose", { phase = phase })
		end
	end
	for i = #threats, 1, -1 do
		local attack = threats[i]
		if now >= attack.expires then
			if not won and attack.source.hp > 0 then
				fx("strike", { position = attack.pos, radius = attack.radius, ring = attack.ring })
				for player in states do
					local r = root(player)
					if r then
						local canHit = CombatRules.inThreat(
							r.Position.X - attack.pos.X,
							r.Position.Z - attack.pos.Z,
							r.Position.Y,
							attack.radius,
							attack.ring
						)
						if
							canHit
							and lineClear(attack.source.root.Position, r, attack.source.model)
						then
							local h = player.Character
								and player.Character:FindFirstChildOfClass("Humanoid")
							if h then
								h:TakeDamage(attack.damage)
								remote:FireClient(player, "hurt", {})
							end
						end
					end
				end
			end
			table.remove(threats, i)
		end
	end
	if now - lastSync > 0.5 then
		lastSync = now
		broadcast()
	end
	if won and voteCount() > 0 and voteCount() >= #Players:GetPlayers() then
		resetRun()
	end
end)
