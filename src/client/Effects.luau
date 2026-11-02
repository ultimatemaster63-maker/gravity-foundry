--!strict
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local SoundService = game:GetService("SoundService")
local Effects = {}
local cyan = Color3.fromRGB(85, 225, 245)
local amber = Color3.fromRGB(255, 152, 52)
local folder = Instance.new("Folder")
folder.Name = "FoundryLocalEffects"
folder.Parent = workspace
Effects.folder = folder
local active = 0
local sounds = 0
local function part(position: Vector3, size: Vector3, color: Color3): Part?
	if active >= 100 then
		return nil
	end
	active += 1
	local p = Instance.new("Part")
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.Material = Enum.Material.Neon
	p.Color = color
	p.Size = size
	p.Position = position
	p.Parent = folder
	p.Destroying:Once(function()
		active -= 1
	end)
	return p
end
function Effects.sound(kind: string, tier: number?)
	if sounds >= 12 then
		return
	end
	sounds += 1
	local s = Instance.new("Sound")
	-- Roblox-bundled sounds: no third-party asset IDs or publishing dependency.
	s.SoundId = if kind == "impact" or kind == "launch"
		then "rbxasset://sounds/action_jump_land.mp3"
		else "rbxasset://sounds/action_jump.mp3"
	s.Volume = if kind == "impact" then 0.22 else 0.16
	s.PlaybackSpeed = if kind == "launch"
		then 1.05 - (tier or 1) * 0.1
		else 0.8 + (tier or 1) * 0.13
	local equalizer = Instance.new("EqualizerSoundEffect")
	equalizer.LowGain = if kind == "launch" then (tier or 1) * 2 else 0
	equalizer.HighGain = if kind == "launch" then -5 else 2
	equalizer.Parent = s
	if kind == "launch" and (tier or 1) >= 3 then
		local distortion = Instance.new("DistortionSoundEffect")
		distortion.Level = 0.08 * (tier or 1)
		distortion.Parent = s
	end
	s.Parent = SoundService
	s:Play()
	task.delay(2, function()
		sounds -= 1
		s:Destroy()
	end)
end
function Effects.burst(pos: Vector3, tier: number, destroy: boolean?)
	local flash = part(pos, Vector3.one, cyan)
	if flash then
		flash.Shape = Enum.PartType.Ball
		TweenService
			:Create(
				flash,
				TweenInfo.new(0.22),
				{ Size = Vector3.one * (3 + tier), Transparency = 1 }
			)
			:Play()
		Debris:AddItem(flash, 0.25)
	end
	for _ = 1, if destroy then 14 else 5 do
		local p = part(
			pos,
			if destroy then Vector3.new(0.5, 0.5, 0.8) else Vector3.new(0.12, 0.12, 0.8),
			amber
		)
		if p then
			local spread = if destroy then 10 else 5
			local destination = pos
				+ Vector3.new(
					math.random(-spread, spread),
					math.random(1, spread),
					math.random(-spread, spread)
				)
			TweenService:Create(
				p,
				TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{ Position = destination, Transparency = 1, Orientation = Vector3.new(80, 150, 40) }
			):Play()
			Debris:AddItem(p, 0.5)
		end
	end
	Effects.sound("impact", tier)
end
function Effects.beam(from: Vector3, to: Vector3, tier: number)
	local distance = (to - from).Magnitude
	if distance < 0.1 then
		return
	end
	local p =
		part((from + to) / 2, Vector3.new(0.08 + tier * 0.025, 0.08 + tier * 0.025, distance), cyan)
	if p then
		p.CFrame = CFrame.lookAt((from + to) / 2, to)
		TweenService:Create(p, TweenInfo.new(0.22), { Transparency = 1 }):Play()
		Debris:AddItem(p, 0.25)
	end
	Effects.sound("pull", tier)
end
function Effects.warning(data: any)
	-- A filled circular disc communicates the exact planar damage radius.
	local p = part(data.position, Vector3.new(0.08, data.radius * 2, data.radius * 2), amber)
	if not p then
		return
	end
	p.Shape = Enum.PartType.Cylinder
	p.CFrame = CFrame.new(data.position) * CFrame.Angles(0, 0, math.pi / 2)
	p.Transparency = 0.78
	TweenService:Create(
		p,
		TweenInfo.new(data.duration),
		{ Transparency = 0.4, Color = Color3.fromRGB(255, 65, 35) }
	):Play()
	Debris:AddItem(p, data.duration + 0.04)
end
function Effects.strike(data: any)
	local p = part(data.position, Vector3.new(0.2, data.radius * 2, data.radius * 2), amber)
	if p then
		p.Shape = Enum.PartType.Cylinder
		p.CFrame = CFrame.new(data.position) * CFrame.Angles(0, 0, math.pi / 2)
		TweenService:Create(p, TweenInfo.new(0.3), { Transparency = 1 }):Play()
		Debris:AddItem(p, 0.35)
	end
	Effects.sound("impact", 2)
end
local ambience = Instance.new("Sound")
ambience.Name = "Foundry ventilation"
ambience.SoundId = "rbxasset://sounds/action_falling.ogg"
ambience.Looped = true
ambience.Volume = 0.035
ambience.PlaybackSpeed = 0.35
ambience.Parent = SoundService
ambience:Play()
function Effects.calm(calm: boolean)
	TweenService:Create(ambience, TweenInfo.new(2), { Volume = if calm then 0.005 else 0.035 })
		:Play()
end
return Effects
