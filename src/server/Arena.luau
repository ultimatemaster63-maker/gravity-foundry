--!strict
local Arena = {}
function Arena.build(): any
	local world = Instance.new("Folder")
	world.Name = "GravityFoundryArena"
	world.Parent = workspace
	local scenery = Instance.new("Folder")
	scenery.Name = "NonBlockingDetails"
	scenery.Parent = world
	local targets: { any } = {}
	local scraps: { any } = {}
	local gates: { any } = {}
	local steel = Color3.fromRGB(42, 48, 53)
	local rust = Color3.fromRGB(117, 68, 40)
	local amber = Color3.fromRGB(255, 144, 45)
	local cyan = Color3.fromRGB(75, 218, 235)
	local function part(
		parent: Instance,
		name: string,
		size: Vector3,
		cf: CFrame,
		color: Color3?,
		material: Enum.Material?,
		decor: boolean?
	): Part
		local p = Instance.new("Part")
		p.Name = name
		p.Size = size
		p.CFrame = cf
		p.Anchored = true
		p.Color = color or steel
		p.Material = material or Enum.Material.Metal
		p.TopSurface = Enum.SurfaceType.Smooth
		p.BottomSurface = Enum.SurfaceType.Smooth
		if decor then
			p.CanCollide = false
			p.CanQuery = false
			p.CanTouch = false
		end
		p.Parent = parent
		return p
	end
	local function sign(parent: BasePart, title: string, offset: number?): TextLabel
		local g = Instance.new("BillboardGui")
		g.Size = UDim2.fromOffset(250, 46)
		g.StudsOffset = Vector3.new(0, offset or 5, 0)
		g.MaxDistance = 95
		g.Parent = parent
		local t = Instance.new("TextLabel")
		t.Size = UDim2.fromScale(1, 1)
		t.BackgroundTransparency = 1
		t.Font = Enum.Font.GothamBold
		t.TextSize = 16
		t.TextColor3 = Color3.fromRGB(235, 223, 195)
		t.TextStrokeTransparency = 0.35
		t.Text = title
		t.Parent = g
		return t
	end
	local function lamp(pos: Vector3, color: Color3)
		local p = part(
			scenery,
			"Worklight",
			Vector3.new(0.5, 2, 3),
			CFrame.new(pos),
			color,
			Enum.Material.Neon,
			true
		)
		local l = Instance.new("PointLight")
		l.Color = color
		l.Range = 27
		l.Brightness = 1.6
		l.Parent = p
	end
	local function detail(
		model: Model,
		name: string,
		size: Vector3,
		cf: CFrame,
		color: Color3,
		material: Enum.Material?
	): Part
		return part(model, name, size, cf, color, material, true)
	end
	local function target(
		kind: string,
		pos: Vector3,
		section: number,
		hp: number,
		reward: number
	): any
		local model = Instance.new("Model")
		model.Name = kind
		model.Parent = world
		local size = if kind == "guardian"
			then Vector3.new(13, 15, 11)
			elseif kind == "drone" then Vector3.new(5, 3, 5)
			elseif kind == "barrier" then Vector3.new(15, 8, 2)
			else Vector3.new(7, 8, 6)
		local root =
			part(model, "Hull", size, CFrame.new(pos), if kind == "machine" then rust else steel)
		model.PrimaryPart = root
		if kind == "drone" then
			root.Shape = Enum.PartType.Ball
			for _, side in { -1, 1 } do
				detail(
					model,
					"Rotor arm",
					Vector3.new(5, 0.5, 1),
					CFrame.new(pos + Vector3.new(side * 3, 0, 0)),
					steel
				)
				local rotor = detail(
					model,
					"Ducted rotor",
					Vector3.new(0.5, 4, 4),
					CFrame.new(pos + Vector3.new(side * 5, 0, 0)) * CFrame.Angles(0, 0, math.pi / 2),
					rust
				)
				rotor.Shape = Enum.PartType.Cylinder
			end
			detail(
				model,
				"Optic",
				Vector3.new(2, 0.65, 0.3),
				CFrame.new(pos + Vector3.new(0, 0, 2.5)),
				amber,
				Enum.Material.Neon
			)
		elseif kind == "guardian" then
			for _, side in { -1, 1 } do
				detail(
					model,
					"Piston shoulder",
					Vector3.new(5, 9, 7),
					CFrame.new(pos + Vector3.new(side * 10, 1, 0)),
					rust
				)
				detail(
					model,
					"Siege claw",
					Vector3.new(3, 13, 3),
					CFrame.new(pos + Vector3.new(side * 13, -3, 3))
						* CFrame.Angles(0, 0, side * 0.18),
					steel
				)
				detail(
					model,
					"Hydraulic rod",
					Vector3.new(1, 8, 1),
					CFrame.new(pos + Vector3.new(side * 10, -6, 3)),
					Color3.fromRGB(150, 165, 170)
				)
			end
			local heart = detail(
				model,
				"Reactor heart",
				Vector3.new(6, 6, 6),
				CFrame.new(pos + Vector3.new(0, 0, 6)),
				cyan,
				Enum.Material.Neon
			)
			heart.Shape = Enum.PartType.Ball
			local shield = detail(
				model,
				"Containment shield",
				Vector3.new(22, 22, 22),
				CFrame.new(pos),
				amber,
				Enum.Material.ForceField
			)
			shield.Shape = Enum.PartType.Ball
			shield.Transparency = 0.72

			for i = 1, 8 do
				local a = i * math.pi / 4
				detail(
					model,
					"Heart cage",
					Vector3.new(1.1, 3, 2),
					CFrame.new(pos + Vector3.new(math.cos(a) * 4, math.sin(a) * 4, 6))
						* CFrame.Angles(0, 0, a),
					steel
				)
			end
			detail(
				model,
				"Crown",
				Vector3.new(7, 2, 4),
				CFrame.new(pos + Vector3.new(0, 9, 0)),
				rust
			)
		elseif kind == "machine" then
			detail(
				model,
				"Pressure vessel",
				Vector3.new(6, 5, 5),
				CFrame.new(pos + Vector3.new(0, 4, 0)),
				steel
			).Shape =
				Enum.PartType.Cylinder
			for i = 1, 3 do
				detail(
					model,
					"Cooling vane",
					Vector3.new(8, 0.3, 7),
					CFrame.new(pos + Vector3.new(0, i * 1.3 - 2, 0)),
					steel
				)
			end
			detail(
				model,
				"Fault lamp",
				Vector3.new(1, 1, 0.4),
				CFrame.new(pos + Vector3.new(0, 2, 3.2)),
				amber,
				Enum.Material.Neon
			)
		else
			for i = -2, 2 do
				detail(
					model,
					"Hazard brace",
					Vector3.new(1.2, 9, 0.3),
					CFrame.new(pos + Vector3.new(i * 3, 0, 1.2)) * CFrame.Angles(0, 0, 0.45),
					amber
				)
			end
		end
		local label = sign(root, string.upper(kind) .. " / " .. hp, size.Y / 2 + 2)
		local t = {
			model = model,
			root = root,
			kind = kind,
			section = section,
			hp = hp,
			max = hp,
			reward = reward,
			home = model:GetPivot(),
			label = label,
			clock = 0,
			attack = nil,
		}
		table.insert(targets, t)
		return t
	end
	local function scrap(pos: Vector3, mass: number, section: number, component: boolean?)
		local model = Instance.new("Model")
		model.Name = if component
			then "Guardian coupling"
			else ({ "Bent plate", "Flywheel", "I-beam", "Reactor shard" })[mass]
		model.Parent = world
		local size = ({
			Vector3.new(2.5, 0.6, 2),
			Vector3.new(1, 3.4, 3.4),
			Vector3.new(4.5, 0.8, 1.4),
			Vector3.new(2.5, 3, 2.5),
		})[mass]
		local root = part(
			model,
			"Scrap",
			size,
			CFrame.new(pos),
			if component or mass == 4 then cyan else rust,
			if component or mass == 4 then Enum.Material.Neon else Enum.Material.DiamondPlate
		)
		if mass == 2 then
			root.Shape = Enum.PartType.Cylinder
		end
		if mass == 3 then
			for _, y in { -0.65, 0.65 } do
				detail(
					model,
					"Flange",
					Vector3.new(4.5, 0.3, 2),
					CFrame.new(pos + Vector3.new(0, y, 0)),
					steel
				)
			end
		end
		if mass == 4 then
			root.CFrame *= CFrame.Angles(0.3, 0.5, 0.4)
		end
		model.PrimaryPart = root
		root.CanCollide = false
		root:SetAttribute("MassClass", mass)
		root:SetAttribute("Pullable", true)
		local a = Instance.new("Attachment")
		a.Position = Vector3.new(0, 0.3, 0)
		a.Parent = root
		local b = Instance.new("Attachment")
		b.Position = Vector3.new(0, -0.3, 0)
		b.Parent = root
		local trail = Instance.new("Trail")
		trail.Attachment0 = a
		trail.Attachment1 = b
		trail.Lifetime = 0.2
		trail.Color = ColorSequence.new(cyan)
		trail.Transparency = NumberSequence.new(0.3, 1)
		trail.LightEmission = 0.8
		trail.Enabled = false
		trail.Parent = root

		local h = Instance.new("Highlight")
		h.FillTransparency = 1
		h.OutlineTransparency = 0.7
		h.OutlineColor = cyan
		h.DepthMode = Enum.HighlightDepthMode.Occluded
		h.Parent = model
		table.insert(scraps, {
			model = model,
			root = root,
			mass = mass,
			section = section,
			component = component or false,
			home = model:GetPivot(),
			owner = nil,
			shot = nil,
			respawn = 0,
		})
	end
	for sector = 1, 3 do
		local z = -(sector - 1) * 100
		part(
			world,
			"Concrete foundation",
			Vector3.new(82, 4, 100),
			CFrame.new(0, -2.5, z),
			Color3.fromRGB(52, 50, 46),
			Enum.Material.Concrete
		)
		for _, x in { -40, 40 } do
			part(
				world,
				"Brick retaining wall",
				Vector3.new(3, 26, 100),
				CFrame.new(x, 11, z),
				Color3.fromRGB(54, 43, 38),
				Enum.Material.Brick
			)
			for offset = -40, 40, 20 do
				part(
					world,
					"Load-bearing column",
					Vector3.new(4, 29, 4),
					CFrame.new(x * 0.94, 13, z + offset),
					steel
				)
				lamp(Vector3.new(x * 0.9, 8, z + offset), if sector == 3 then cyan else amber)
				part(
					scenery,
					"Ceiling truss",
					Vector3.new(77, 2, 2),
					CFrame.new(0, 26, z + offset),
					steel,
					nil,
					true
				)
			end
		end
		for _, x in { -12, 12 } do
			part(
				scenery,
				"Inset transport rail",
				Vector3.new(0.7, 0.12, 98),
				CFrame.new(x, -0.35, z),
				rust,
				nil,
				true
			)
		end
		for offset = -40, 40, 10 do
			part(
				scenery,
				"Walkway marking",
				Vector3.new(0.6, 0.08, 4),
				CFrame.new(0, -0.35, z + offset),
				Color3.fromRGB(182, 139, 59),
				nil,
				true
			)
		end
		local marker = part(
			scenery,
			"Sector signage",
			Vector3.one,
			CFrame.new(0, 15, z + 34),
			steel,
			nil,
			true
		)
		marker.Transparency = 1
		sign(
			marker,
			({ "01 • THE BREAKER YARD", "02 • THE CRUCIBLE", "03 • HEART OF THE FOUNDRY" })[sector],
			0
		)
		for i = 1, 10 do
			scrap(Vector3.new((i % 5 - 2) * 6, 1, z + 20 - math.floor(i / 5) * 22), 1, sector)
		end
		for mass = 2, 4 do
			for _, side in { -1, 1 } do
				scrap(Vector3.new(side * (14 + mass * 3), 2, z + 28 - mass * 12), mass, sector)
			end
		end
		if sector == 1 then
			for i = 1, 3 do
				part(
					world,
					"Stacked freight",
					Vector3.new(10, 5 + i, 12),
					CFrame.new(-28, 1 + i / 2, z + 26 - i * 22),
					rust,
					Enum.Material.CorrodedMetal
				)
				part(
					scenery,
					"Crane gantry",
					Vector3.new(2, 2, 80),
					CFrame.new(18, 23, z),
					Color3.fromRGB(178, 120, 38),
					nil,
					true
				)
			end
			target("machine", Vector3.new(-15, 4, -10), 1, 90, 65)
			target("machine", Vector3.new(19, 4, -21), 1, 90, 65)
			target("barrier", Vector3.new(0, 4, -37), 1, 140, 80)
			target("drone", Vector3.new(0, 8, -20), 1, 100, 90)
		elseif sector == 2 then
			for _, side in { -1, 1 } do
				part(
					world,
					"Furnace tower",
					Vector3.new(12, 17, 23),
					CFrame.new(side * 29, 7, z - 5),
					steel
				)
				part(
					scenery,
					"Furnace mouth",
					Vector3.new(0.3, 7, 15),
					CFrame.new(side * 22.8, 4, z - 5),
					amber,
					Enum.Material.Neon,
					true
				)
				lamp(Vector3.new(side * 20, 5, z - 5), amber)
				target("machine", Vector3.new(side * 15, 4, z + 10), 2, 170, 110)
				target("drone", Vector3.new(side * 13, 9, z - 22), 2, 145, 120)
			end
			target("barrier", Vector3.new(0, 4, z - 38), 2, 210, 100)
		else
			for _, side in { -1, 1 } do
				target("machine", Vector3.new(side * 23, 4, z + 4), 3, 200, 130)
				target("drone", Vector3.new(side * 16, 9, z - 12), 3, 180, 140)
				part(
					world,
					"Reactor cover",
					Vector3.new(9, 7, 5),
					CFrame.new(side * 18, 3, z + 22),
					steel
				)
			end
			for i = 1, 16 do
				local a = i * math.pi / 8
				part(
					scenery,
					"Reactor containment arc",
					Vector3.new(3, 1, 7),
					CFrame.new(math.cos(a) * 22, 0.2, z - 30 + math.sin(a) * 16)
						* CFrame.Angles(0, -a, 0),
					cyan,
					Enum.Material.Neon,
					true
				)
			end
		end
	end
	for i = 1, 2 do
		local p = part(
			world,
			"Security shutter",
			Vector3.new(78, 25, 3),
			CFrame.new(0, 11, 50 - i * 100),
			steel
		)
		local label = sign(p, "SECTOR LOCK / CLEAR MARKED TARGETS", 5)
		table.insert(gates, { part = p, home = p.CFrame, label = label })
	end
	part(world, "Intake back wall", Vector3.new(82, 27, 3), CFrame.new(0, 11, 49), steel)
	part(world, "Reactor back wall", Vector3.new(82, 32, 3), CFrame.new(0, 13, -249), steel)
	local boss = target("guardian", Vector3.new(0, 12, -231), 3, 1200, 500)
	for i = 1, 3 do
		scrap(Vector3.new((i - 2) * 12, 8, -219), 1, 3, true)
	end
	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "Intake refuge"
	spawn.Size = Vector3.new(9, 1, 9)
	spawn.Position = Vector3.new(0, 0, 35)
	spawn.Anchored = true
	spawn.Neutral = true
	spawn.Duration = 2
	spawn.Color = steel
	spawn.Material = Enum.Material.DiamondPlate
	spawn.Parent = world
	local station =
		part(world, "Forge terminal", Vector3.new(5, 4, 3), CFrame.new(-9, 2, 32), steel)
	local terminalModel = Instance.new("Model")
	terminalModel.Parent = scenery
	detail(
		terminalModel,
		"Terminal screen",
		Vector3.new(4, 1.5, 0.2),
		CFrame.new(-9, 3, 33.6),
		cyan,
		Enum.Material.Neon
	)
	sign(station, "FORGE • B / Y\nUPGRADES SURVIVE DEATH", 5)
	local lighting = game:GetService("Lighting")
	lighting.ClockTime = 0
	lighting.Brightness = 2
	lighting.Ambient = Color3.fromRGB(66, 74, 82)
	lighting.OutdoorAmbient = Color3.fromRGB(34, 38, 44)
	lighting.FogColor = Color3.fromRGB(35, 42, 47)
	lighting.FogStart = 130
	lighting.FogEnd = 360
	return {
		world = world,
		scenery = scenery,
		targets = targets,
		scraps = scraps,
		gates = gates,
		boss = boss,
		spawn = spawn,
	}
end
return Arena
