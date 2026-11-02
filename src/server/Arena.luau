--!strict
local Arena = {}
function Arena.build()
	local world = Instance.new("Folder")
	world.Name = "GravityFoundryArena"
	world.Parent = workspace
	local targets, scrap, gates = {}, {}, {}
	local function part(name, size, pos, color, material)
		local p = Instance.new("Part")
		p.Name, p.Size, p.Position = name, size, pos
		p.Anchored = true
		p.Color = color or Color3.fromRGB(47, 52, 58)
		p.Material = material or Enum.Material.Metal
		p.TopSurface = Enum.SurfaceType.Smooth
		p.BottomSurface = Enum.SurfaceType.Smooth
		p.Parent = world
		return p
	end
	local function label(p, text)
		local gui = Instance.new("BillboardGui")
		gui.Size = UDim2.fromOffset(260, 55)
		gui.StudsOffset = Vector3.new(0, 5, 0)
		gui.AlwaysOnTop = true
		gui.Parent = p
		local t = Instance.new("TextLabel")
		t.Size = UDim2.fromScale(1, 1)
		t.BackgroundTransparency = 1
		t.TextColor3 = Color3.fromRGB(255, 205, 130)
		t.TextStrokeTransparency = 0.3
		t.Font = Enum.Font.GothamBold
		t.TextSize = 18
		t.Text = text
		t.Parent = gui
		return t
	end
	for section = 1, 3 do
		local z = -(section - 1) * 90
		part("Foundry deck", Vector3.new(76, 3, 90), Vector3.new(0, -2, z))
		for _, x in { -39, 39 } do
			part("Riveted retaining wall", Vector3.new(3, 18, 90), Vector3.new(x, 6, z))
			for offset = -36, 36, 18 do
				part("Steel rib", Vector3.new(5, 25, 3), Vector3.new(x, 10, z + offset))
				local lamp = part(
					"Furnace strip",
					Vector3.new(1, 8, 2),
					Vector3.new(x * 0.95, 5, z + offset),
					Color3.fromRGB(255, 125, 36),
					Enum.Material.Neon
				)
				local light = Instance.new("PointLight")
				light.Color, light.Range, light.Brightness = lamp.Color, 24, 1.3
				light.Parent = lamp
			end
		end
		for _, x in { -27, 27 } do
			part(
				"Overhead pipe",
				Vector3.new(4, 4, 86),
				Vector3.new(x, 19, z),
				Color3.fromRGB(91, 63, 44)
			)
			for offset = -25, 25, 25 do
				local machine =
					part("Smelter housing", Vector3.new(12, 10, 12), Vector3.new(x, 4, z + offset))
				part(
					"Hot vent",
					Vector3.new(9, 1, 9),
					machine.Position + Vector3.new(0, 5.1, 0),
					Color3.fromRGB(255, 105, 22),
					Enum.Material.Neon
				)
			end
		end
		local sign = part("Sector marker", Vector3.new(1, 1, 1), Vector3.new(0, 12, z + 33))
		sign.Transparency = 1
		label(sign, ({ "01 / SCRAP INTAKE", "02 / PRESS HALL", "03 / REACTOR" })[section])
		for i = 1, 8 do
			local p = part(
				"Scrap",
				Vector3.new(2, 1.3, 2.8),
				Vector3.new((i % 4 - 1.5) * 9, 1, z + 15 - math.floor(i / 4) * 18),
				Color3.fromRGB(120, 132, 140),
				Enum.Material.DiamondPlate
			)
			p.Orientation = Vector3.new(i * 13, i * 31, 12)
			p:SetAttribute("Pullable", true)
			local highlight = Instance.new("Highlight")
			highlight.FillTransparency = 0.92
			highlight.OutlineTransparency = 0.4
			highlight.OutlineColor = Color3.fromRGB(70, 210, 230)
			highlight.DepthMode = Enum.HighlightDepthMode.Occluded
			highlight.Parent = p
			scrap[p] = { home = p.CFrame, owner = nil, projectile = nil, component = false }
		end
		for i = 1, 4 do
			local p = part(
				"Machinery",
				Vector3.new(6, 7, 5),
				Vector3.new((i % 2 == 0 and 1 or -1) * 15, 3, z - 8 - math.floor(i / 2) * 11),
				Color3.fromRGB(151, 90, 42),
				Enum.Material.CorrodedMetal
			)
			targets[p] = {
				hp = 60,
				max = 60,
				reward = 22,
				section = section,
				kind = "machine",
				home = p.CFrame,
			}
			label(p, "SALVAGE / 60")
		end
		for i = 1, section do
			local p = part(
				"Drone",
				Vector3.new(4, 2, 4),
				Vector3.new(i * 10 - 15, 7, z - 24),
				Color3.fromRGB(65, 72, 81)
			)

			targets[p] = {
				hp = 75,
				max = 75,
				reward = 35,
				section = section,
				kind = "drone",
				home = p.CFrame,
				clock = 0,
			}
			label(p, "SENTINEL / 75")
		end
	end
	for i = 1, 2 do
		local p = part(
			"Bulkhead",
			Vector3.new(75, 20, 3),
			Vector3.new(0, 8, 45 - i * 90),
			Color3.fromRGB(90, 65, 39)
		)
		gates[i] = p
		label(p, "CLEAR SECTOR TO OPEN")
	end
	part("Rear wall", Vector3.new(78, 20, 3), Vector3.new(0, 8, 44))
	part("Reactor wall", Vector3.new(78, 25, 3), Vector3.new(0, 10, -224))
	local boss = part(
		"Guardian",
		Vector3.new(15, 17, 12),
		Vector3.new(0, 8, -207),
		Color3.fromRGB(57, 67, 73)
	)
	targets[boss] = {
		hp = 650,
		max = 650,
		reward = 200,
		section = 3,
		kind = "boss",
		home = boss.CFrame,
		clock = 0,
	}
	label(boss, "REACTOR GUARDIAN / 650")
	for i = 1, 6 do
		local angle = i * math.pi / 3
		local p = part(
			"Exposed core",
			Vector3.new(3, 3, 3),
			boss.Position + Vector3.new(math.cos(angle) * 11, math.sin(angle) * 7, 8),
			Color3.fromRGB(77, 235, 255),
			Enum.Material.Neon
		)
		p:SetAttribute("Pullable", true)
		local highlight = Instance.new("Highlight")
		highlight.FillTransparency = 0.92
		highlight.OutlineTransparency = 0.4
		highlight.OutlineColor = Color3.fromRGB(70, 210, 230)
		highlight.DepthMode = Enum.HighlightDepthMode.Occluded
		highlight.Parent = p
		scrap[p] = { home = p.CFrame, owner = nil, projectile = nil, component = true }
	end
	local spawn = Instance.new("SpawnLocation")
	spawn.Size, spawn.Position = Vector3.new(8, 1, 8), Vector3.new(0, 0, 30)
	spawn.Anchored, spawn.Neutral = true, true
	spawn.Material, spawn.Color = Enum.Material.DiamondPlate, Color3.fromRGB(65, 100, 108)
	spawn.Parent = world
	local lighting = game:GetService("Lighting")
	lighting.ClockTime = 0
	lighting.Brightness = 2
	lighting.Ambient = Color3.fromRGB(65, 75, 85)
	lighting.OutdoorAmbient = Color3.fromRGB(45, 50, 60)
	lighting.FogColor = Color3.fromRGB(35, 43, 50)
	lighting.FogEnd = 300
	return {
		world = world,
		targets = targets,
		scrap = scrap,
		gates = gates,
		boss = boss,
		spawn = spawn,
	}
end
return Arena
