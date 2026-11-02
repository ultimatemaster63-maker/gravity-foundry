--!strict
-- One model builder for character equipment and the upgrade showroom.
local Gear = {}
function Gear.build(tier: number): Model
	local model = Instance.new("Model")
	model.Name = "GravityGauntlet"
	local rust = Color3.fromRGB(112, 67, 42)
	local steel = Color3.fromRGB(35, 46, 56)
	local copper = Color3.fromRGB(181, 112, 59)
	local cyan = Color3.fromRGB(85, 226, 245)
	local function piece(
		name: string,
		size: Vector3,
		cf: CFrame,
		color: Color3,
		neon: boolean?
	): Part
		local p = Instance.new("Part")
		p.Name = name
		p.Size = size
		p.CFrame = cf
		p.Color = color
		p.Material = if neon
			then Enum.Material.Neon
			elseif tier == 1 then Enum.Material.CorrodedMetal
			else Enum.Material.Metal
		p.Anchored = true
		p.CanCollide = false
		p.CanQuery = false
		p.CanTouch = false
		p.Massless = true
		p.Parent = model
		return p
	end
	local base =
		piece("Cuff", Vector3.new(1.25, 1.5, 1.25), CFrame.new(), if tier == 1 then rust else steel)
	model.PrimaryPart = base
	for _, side in { -1, 1 } do
		piece(
			"Knuckle plate",
			Vector3.new(0.28, 0.8, 1.6),
			CFrame.new(side * 0.68, -0.4, -0.2) * CFrame.Angles(0, 0, side * 0.12),
			if tier == 1 then rust else copper
		)
		for i = 1, 3 do
			piece(
				"Rivet",
				Vector3.new(0.13, 0.13, 0.13),
				CFrame.new(side * 0.84, i * 0.3 - 0.8, -0.6),
				steel
			)
		end
	end
	if tier >= 2 then
		for i = 1, 4 do
			for _, side in { -1, 1 } do
				piece(
					"Inductor",
					Vector3.new(0.22, 0.12, 1.35),
					CFrame.new(side * 0.84, i * 0.26 - 0.65, 0),
					copper
				)
			end
		end
		piece("Emitter", Vector3.new(0.6, 0.12, 0.65), CFrame.new(0, -0.8, -0.2), cyan, true)
	end
	if tier >= 3 then
		for i = 1, 4 do
			local angle = i * math.pi / 2
			piece(
				"Floating fin",
				Vector3.new(0.22, 1.7, 0.65),
				CFrame.Angles(0, angle, 0) * CFrame.new(1.12, 0.2, 0) * CFrame.Angles(0, 0, 0.3),
				steel
			)
			piece(
				"Fin seam",
				Vector3.new(0.08, 1.3, 0.12),
				CFrame.Angles(0, angle, 0) * CFrame.new(1.25, 0.2, 0),
				cyan,
				true
			)
		end
	end
	if tier >= 4 then
		local core = piece(
			"Suspended core",
			Vector3.new(0.85, 0.85, 0.85),
			CFrame.new(0, -1.5, 0),
			Color3.fromRGB(8, 15, 25)
		)
		core.Shape = Enum.PartType.Ball
		for i = 1, 12 do
			local angle = i * math.pi / 6
			piece(
				"Containment ring",
				Vector3.new(0.32, 0.08, 0.13),
				CFrame.new(math.cos(angle) * 0.78, -1.5, math.sin(angle) * 0.78)
					* CFrame.Angles(0, -angle, 0),
				cyan,
				true
			)
		end
	end
	if tier >= 5 then
		for i = 1, 6 do
			local angle = i * math.pi / 3
			piece(
				"Detached crown",
				Vector3.new(0.3, 0.8, 0.35),
				CFrame.Angles(0, angle, 0) * CFrame.new(1.3, -1.6, 0) * CFrame.Angles(0, 0, 0.4),
				Color3.fromRGB(190, 205, 215)
			)
		end
	end
	return model
end
return Gear
