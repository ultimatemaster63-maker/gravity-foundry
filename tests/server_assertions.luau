local assertions = 0
local function check(condition, message)
	assert(condition, message)
	assertions += 1
end
local function step(delta)
	now += delta
	RunService.Heartbeat:Fire(delta)
end
local function action(name, aim)
	now += 0.6
	remote.OnServerEvent:Fire(player, name, aim)
end
local function refresh()
	action("ready")
	return player.state
end
local function aimScrap()
	local r = player.Character.HumanoidRootPart
	return r.Position + Vector3.new(0, -1, -20)
end
local function shoot(target)
	action("pull", aimScrap())
	if player.state.held == 0 then
		-- Aim at an explicit visible scrap in the unlocked sector.
		for _, d in arena.scraps do
			if
				d.section == player.state.sector
				and not d.component
				and d.mass == 1
				and d.respawn <= now
			then
				action("pull", d.root.Position)
				break
			end
		end
	end
	check(player.state.held > 0, "capture available scrap")
	action("launch", target.root.Position)
	hitTarget = target
	step(0.016)
end
action("ready")
check(player.state.tier == 1 and player.state.cash == 0, "initial player state")
action("upgrade")
check(player.state.tier == 1 and player.state.cash == 0, "unaffordable upgrade rejected")
blocked = true
action("pull", aimScrap())
check(player.state.held == 0, "wall blocks capture")
blocked = false
action("pull", Vector3.new(0 / 0, 0, 0))
check(player.state.held == 0, "NaN aim rejected")
action("pull", aimScrap())
check(player.state.held == 1, "visible scrap captured")
local before = player.state.held
action("launch", Vector3.new(math.huge, 0, 0))
refresh()
check(player.state.held == before, "infinite launch rejected")
local r = player.Character.HumanoidRootPart
for section = 1, 3 do
	r.CFrame = CFrame.new(0, 3, 20 - (section - 1) * 100)
	for _, target in arena.targets do
		if target.section == section and target.kind ~= "guardian" then
			local limit = 0
			while target.hp > 0 do
				shoot(target)
				limit += 1
				assert(limit < 30, "target must be destroyable")
			end
			check(
				not target.root.CanQuery and not target.root.CanCollide,
				"destroyed target stops blocking"
			)
		end
	end
	refresh()
	if section < 3 then
		check(player.state.sector == section + 1, "sector gate advances")
	end
	action("upgrade")
end
refresh()
check(player.state.bossActive, "reactor clear activates guardian")
local hp = arena.boss.hp
shoot(arena.boss)
-- Depending on elapsed combat simulation, explicit shield check starts before its first attack.
check(arena.boss.hp == hp, "shield rejects ordinary projectile before exposure")
for _ = 1, 100 do
	step(0.1)
end
refresh()
check(player.state.exposed, "guardian attack opens coupling window")
r.CFrame = CFrame.new(0, 3, -205)
local component
for _, d in arena.scraps do
	if d.component then
		component = d
		break
	end
end
-- Empty normal orbit first so the component is launched, not another held piece.
while player.state.held > 0 do
	action("launch", arena.boss.root.Position)
	step(0.01)
	refresh()
end
action("pull", component.root.Position)
check(component.owner == player, "exposed component is pullable")
hp = arena.boss.hp
action("launch", arena.boss.root.Position)
hitTarget = arena.boss
step(0.016)
check(arena.boss.hp < hp, "returned component damages guardian")
local guard = 0
while arena.boss.hp > 0 do
	r.CFrame = CFrame.new(0, 3, -120) -- retreat out of the arena while waiting for the next window
	for _ = 1, 95 do
		step(0.1)
	end
	-- Target ordinary visible scrap during its window; rewind character to the pickup area.
	r.CFrame = CFrame.new(0, 3, -180)
	shoot(arena.boss)
	guard += 1
	assert(guard < 40, "guardian is completable")
end
refresh()
check(player.state.won, "guardian defeat reaches ending")
local cash, tier = player.state.cash, player.state.tier
local partner = newPlayer(2)
Players.PlayerAdded:Fire(partner)
action("vote")
refresh()
check(player.state.won, "one crew vote cannot reset another player's ending")
now += 0.6
remote.OnServerEvent:Fire(partner, "vote")
refresh()
check(
	player.state.cycle == 2 and player.state.sector == 1 and not player.state.won,
	"replay resets run"
)
check(
	player.state.cash == cash and player.state.tier == tier,
	"replay retains currency and appearance"
)
for _, target in arena.targets do
	check(target.hp == target.max and target.root.CanQuery, "replay restores targets")
end
for _, gate in arena.gates do
	check(gate.part.CanCollide, "replay closes gates")
end
r.CFrame = CFrame.new(0, 3, 20)
action("pull", aimScrap())
check(player.state.held > 0, "capture after replay")
player.Character.Humanoid:TakeDamage(100)
refresh()
check(player.state.held == 0, "death releases orbit")
for _, d in arena.scraps do
	check(d.owner ~= player, "no orphan ownership after death")
end
print(
	string.format(
		"PASS: %d server-flow assertions (simulated services; no Studio physics)",
		assertions
	)
)

partner.Character.HumanoidRootPart.CFrame = CFrame.new(0, 3, 20)
now += 1
remote.OnServerEvent:Fire(partner, "pull", Vector3.new(0, 1, 0))
local owned = false
for _, d in arena.scraps do
	if d.owner == partner then
		owned = true
	end
end
check(owned, "second player can capture independent scrap")
now += 1
remote.OnServerEvent:Fire(partner, "pull", Vector3.new(0, 1, 0))
now += 1
remote.OnServerEvent:Fire(partner, "launch", Vector3.new(0, 3, -30))
Players.PlayerRemoving:Fire(partner)
for _, d in arena.scraps do
	check(d.owner ~= partner, "disconnect releases ownership")
	check(not d.shot or d.shot.player ~= partner, "disconnect cancels active projectiles")
end
print(
	string.format(
		"PASS: %d total server-flow assertions including multiplayer replay consent and disconnect cleanup",
		assertions
	)
)
