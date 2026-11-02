--!strict
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local CAS = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")
local player = Players.LocalPlayer
local shared = game:GetService("ReplicatedStorage"):WaitForChild("GravityFoundryShared")
local remote = shared:WaitForChild("FoundryAction") :: RemoteEvent
local Progression = require(shared.Progression)
local Gear = require(shared.Gear)
local Orbit = require(shared.Orbit)
local Effects = require(script.Parent.Effects)
local gui = Instance.new("ScreenGui")
gui.Name = "FoundryHUD"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player:WaitForChild("PlayerGui")
local dark = Color3.fromRGB(15, 22, 29)
local cyan = Color3.fromRGB(98, 222, 238)
local cream = Color3.fromRGB(236, 230, 211)
local state: any = nil
local menu = false
local previewTier = 2
local previewModel: Model? = nil
local displayedTier = 0
local noticeUntil = 0
local shake = 0
local hitUntil = 0
local lastInput = UIS:GetLastInputType()
local function frame(parent: Instance, name: string, size: UDim2, pos: UDim2): Frame
	local f = Instance.new("Frame")
	f.Name = name
	f.Size = size
	f.Position = pos
	f.BackgroundColor3 = dark
	f.BackgroundTransparency = 0.08
	f.BorderSizePixel = 0
	f.Parent = parent
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = f
	local line = Instance.new("UIStroke")
	line.Color = Color3.fromRGB(45, 79, 86)
	line.Parent = f
	return f
end
local function label(
	parent: Instance,
	text: string,
	size: UDim2,
	pos: UDim2,
	fontSize: number?
): TextLabel
	local l = Instance.new("TextLabel")
	l.Size = size
	l.Position = pos
	l.BackgroundTransparency = 1
	l.TextColor3 = cream
	l.Font = Enum.Font.GothamMedium
	l.TextSize = fontSize or 16
	l.TextWrapped = true
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.Text = text
	l.Parent = parent
	return l
end
local function button(
	parent: Instance,
	text: string,
	size: UDim2,
	pos: UDim2,
	callback: () -> ()
): TextButton
	local b = Instance.new("TextButton")
	b.Size = size
	b.Position = pos
	b.BackgroundColor3 = Color3.fromRGB(39, 88, 96)
	b.TextColor3 = cream
	b.Font = Enum.Font.GothamBold
	b.TextSize = 15
	b.TextWrapped = true
	b.Text = text
	b.Parent = parent
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 8)
	c.Parent = b
	b.Activated:Connect(callback)
	return b
end
local hud = frame(gui, "Vitals", UDim2.fromOffset(244, 112), UDim2.fromOffset(18, 55))
label(hud, "GRAVITY / FOUNDRY", UDim2.new(1, -24, 0, 24), UDim2.fromOffset(12, 8), 16)
local tierLabel = label(hud, "RUSTHAND", UDim2.new(1, -24, 0, 22), UDim2.fromOffset(12, 34), 14)
tierLabel.TextColor3 = cyan
local cashLabel = label(hud, "SALVAGE 0", UDim2.new(1, -24, 0, 25), UDim2.fromOffset(12, 58), 19)
local healthBack = frame(hud, "Health", UDim2.new(1, -24, 0, 7), UDim2.fromOffset(12, 93))
local healthFill = frame(healthBack, "Fill", UDim2.fromScale(1, 1), UDim2.fromScale(0, 0))
healthFill.BackgroundColor3 = cyan
local objectivePanel = frame(gui, "Objective", UDim2.new(0.48, 0, 0, 69), UDim2.new(0.5, 0, 0, 55))
objectivePanel.AnchorPoint = Vector2.new(0.5, 0)
local objective = label(
	objectivePanel,
	"Loading foundry…",
	UDim2.new(1, -24, 1, -16),
	UDim2.fromOffset(12, 8),
	16
)
local orbit = label(gui, "", UDim2.fromOffset(250, 28), UDim2.new(0.5, -125, 1, -100), 16)
orbit.TextXAlignment = Enum.TextXAlignment.Center
local notice = label(
	gui,
	"Aim at scrap • E to pull • click to launch • B for Forge",
	UDim2.new(0.7, 0, 0, 50),
	UDim2.new(0.15, 0, 1, -70),
	15
)
notice.TextXAlignment = Enum.TextXAlignment.Center
local cross = label(gui, "+", UDim2.fromOffset(26, 26), UDim2.new(0.5, -13, 0.5, -13), 25)
cross.TextXAlignment = Enum.TextXAlignment.Center
cross.TextColor3 = cyan
local hit = label(gui, "", UDim2.fromOffset(120, 30), UDim2.new(0.5, 20, 0.5, 12), 18)
hit.TextColor3 = cream
local hurt = Instance.new("Frame")
hurt.Size = UDim2.fromScale(1, 1)
hurt.BackgroundColor3 = Color3.fromRGB(180, 40, 20)
hurt.BackgroundTransparency = 1
hurt.ZIndex = 8
hurt.Parent = gui
local bossPanel = frame(gui, "Guardian", UDim2.new(0.45, 0, 0, 48), UDim2.new(0.5, 0, 0, 135))
bossPanel.AnchorPoint = Vector2.new(0.5, 0)
bossPanel.Visible = false
local bossText =
	label(bossPanel, "WARDEN / SHIELDED", UDim2.new(1, -20, 0, 25), UDim2.fromOffset(10, 3), 14)
local bossFill = frame(bossPanel, "Health", UDim2.new(1, -20, 0, 7), UDim2.fromOffset(10, 33))
bossFill.BackgroundColor3 = Color3.fromRGB(240, 141, 56)
local overlay = frame(gui, "Forge", UDim2.fromScale(0.86, 0.76), UDim2.fromScale(0.07, 0.12))
overlay.Visible = false
overlay.ZIndex = 10
-- Descendants use the same screen layer; the forge is created after the HUD.
label(
	overlay,
	"THE FORGE / EVOLVE YOUR GRAVITY",
	UDim2.new(1, -70, 0, 40),
	UDim2.fromOffset(20, 12),
	21
)
local viewport = Instance.new("ViewportFrame")
viewport.Size = UDim2.fromScale(0.42, 0.65)
viewport.Position = UDim2.fromScale(0.03, 0.18)
viewport.BackgroundTransparency = 1
viewport.Ambient = Color3.fromRGB(170, 190, 205)
viewport.LightColor = Color3.fromRGB(170, 235, 255)
viewport.Parent = overlay
local previewCamera = Instance.new("Camera")
previewCamera.CFrame = CFrame.lookAt(Vector3.new(4, 2.5, 5.5), Vector3.new(0, -0.4, 0))
previewCamera.Parent = viewport
viewport.CurrentCamera = previewCamera
local previewTitle = label(overlay, "", UDim2.fromScale(0.49, 0.1), UDim2.fromScale(0.48, 0.18), 23)
local description = label(overlay, "", UDim2.fromScale(0.48, 0.21), UDim2.fromScale(0.48, 0.3), 16)
local stats = label(overlay, "", UDim2.fromScale(0.48, 0.2), UDim2.fromScale(0.48, 0.51), 16)
local buy: TextButton
local function showPreview()
	local tier = Progression.tiers[previewTier]
	if previewTier ~= displayedTier then
		if previewModel then
			previewModel:Destroy()
		end
		previewModel = Gear.build(previewTier)
		if previewModel then
			previewModel.Parent = viewport
		end
		displayedTier = previewTier
	end
	previewTitle.Text = string.format("%02d / %s", previewTier, tier.name)
	description.Text = tier.description
	stats.Text = string.format(
		"ORBIT %d    REACH %d\nMASS CLASS %d    IMPACT %d",
		tier.capacity,
		tier.range,
		tier.mass,
		tier.damage
	)
	if state then
		buy.Text = if previewTier <= state.tier
			then "OWNED"
			elseif previewTier == state.tier + 1 then "FORGE / " .. tier.cost .. " SALVAGE"
			else "EVOLVE PREVIOUS STAGE FIRST"
	end
end
local function toggleForge()
	if state and state.won then
		return
	end
	menu = not menu
	overlay.Visible = menu
	if menu then
		previewTier = math.min((state and state.tier or 1) + 1, #Progression.tiers)
		showPreview()
		GuiService.SelectedObject = buy
	else
		GuiService.SelectedObject = nil
	end
end
buy = button(overlay, "FORGE", UDim2.fromScale(0.48, 0.12), UDim2.fromScale(0.48, 0.75), function()
	if state and previewTier == state.tier + 1 then
		remote:FireServer("upgrade")
	else
		Effects.sound("denied", 1)
	end
end)
button(overlay, "×", UDim2.fromOffset(40, 36), UDim2.new(1, -52, 0, 12), toggleForge)
for i = 1, #Progression.tiers do
	button(
		overlay,
		tostring(i),
		UDim2.fromScale(0.065, 0.09),
		UDim2.fromScale(0.035 + (i - 1) * 0.08, 0.82),
		function()
			previewTier = i
			showPreview()
		end
	)
end
label(
	overlay,
	"SESSION GEAR • retained through death and replay; resets on leaving this server",
	UDim2.new(1, -40, 0, 25),
	UDim2.new(0, 20, 1, -30),
	12
)
local forgeButton =
	button(gui, "FORGE [B / Y]", UDim2.fromOffset(244, 38), UDim2.fromOffset(18, 178), toggleForge)
local ending = frame(gui, "Ending", UDim2.fromScale(0.72, 0.58), UDim2.fromScale(0.14, 0.21))
ending.Visible = false
label(
	ending,
	"THE FOUNDRY BREATHES AGAIN",
	UDim2.fromScale(0.9, 0.18),
	UDim2.fromScale(0.05, 0.06),
	25
)
local endingText = label(ending, "", UDim2.fromScale(0.9, 0.45), UDim2.fromScale(0.05, 0.25), 18)
local replayButton = button(
	ending,
	"REIGNITE / KEEP YOUR GEAR",
	UDim2.fromScale(0.8, 0.14),
	UDim2.fromScale(0.1, 0.78),
	function()
		remote:FireServer("vote")
	end
)
local reveal = frame(gui, "Reveal", UDim2.fromScale(0.65, 0.23), UDim2.fromScale(0.175, 0.32))
reveal.Visible = false
reveal.ZIndex = 20
local revealTitle = label(reveal, "", UDim2.fromScale(0.9, 0.4), UDim2.fromScale(0.05, 0.12), 28)
revealTitle.TextColor3 = cyan
revealTitle.TextXAlignment = Enum.TextXAlignment.Center
local revealBody = label(reveal, "", UDim2.fromScale(0.9, 0.4), UDim2.fromScale(0.05, 0.54), 16)
revealBody.TextXAlignment = Enum.TextXAlignment.Center
local revealId = 0
local function announce(title: string, body: string)
	revealId += 1
	local id = revealId
	revealTitle.Text = title
	revealBody.Text = body
	reveal.Visible = true
	task.delay(3.2, function()
		if revealId == id then
			reveal.Visible = false
		end
	end)
end
local function notify(message: string, duration: number?)
	notice.Text = message
	noticeUntil = os.clock() + (duration or 3)
end
local function aimPoint(): Vector3
	local camera = workspace.CurrentCamera
	if not camera then
		return Vector3.zero
	end
	local position = if UIS.TouchEnabled or lastInput.Name:find("Gamepad")
		then camera.ViewportSize / 2
		else UIS:GetMouseLocation()
	local ray = camera:ViewportPointToRay(position.X, position.Y)
	local params = RaycastParams.new()
	local ignores: { Instance } = { Effects.folder }
	if player.Character then
		table.insert(ignores, player.Character)
	end
	local world = workspace:FindFirstChild("GravityFoundryArena")
	if world then
		for _, p in world:GetDescendants() do
			if p:IsA("BasePart") and p:GetAttribute("Held") then
				table.insert(ignores, p.Parent or p)
			end
		end
	end
	params.FilterDescendantsInstances = ignores
	local result = workspace:Raycast(ray.Origin, ray.Direction * 500, params)
	return if result then result.Position else ray.Origin + ray.Direction * 500
end
local function fire(action: string)
	if menu or (state and state.won) then
		return
	end
	remote:FireServer(action, aimPoint())
end
local function bound(name: string, inputState: Enum.UserInputState): Enum.ContextActionResult
	if inputState ~= Enum.UserInputState.Begin then
		return Enum.ContextActionResult.Pass
	end
	if name == "Forge" then
		toggleForge()
	elseif name == "Pull" then
		fire("pull")
	else
		fire("launch")
	end
	return Enum.ContextActionResult.Sink
end
CAS:BindAction("Pull", bound, false, Enum.KeyCode.E, Enum.KeyCode.ButtonL2)
CAS:BindAction("Launch", bound, false, Enum.KeyCode.ButtonR2)
CAS:BindAction("Forge", bound, false, Enum.KeyCode.B, Enum.KeyCode.ButtonY)
UIS.InputBegan:Connect(function(input, processed)
	if not processed and input.UserInputType == Enum.UserInputType.MouseButton1 then
		fire("launch")
	end
end)
UIS.LastInputTypeChanged:Connect(function(input)
	lastInput = input
end)
local pullTouch = button(
	gui,
	"PULL",
	UDim2.fromOffset(85, 60),
	UDim2.new(1, -205, 1, -185),
	function()
		fire("pull")
	end
)
local launchTouch = button(
	gui,
	"LAUNCH",
	UDim2.fromOffset(85, 60),
	UDim2.new(1, -110, 1, -225),
	function()
		fire("launch")
	end
)
pullTouch.Visible = UIS.TouchEnabled
launchTouch.Visible = UIS.TouchEnabled
remote.OnClientEvent:Connect(function(kind: string, data: any)
	if kind == "state" then
		local wasWon = state and state.won
		state = data
		tierLabel.Text = Progression.tiers[data.tier].name .. " / CYCLE " .. data.cycle
		cashLabel.Text = "SALVAGE  " .. data.cash
		orbit.Text =
			string.format("ORBIT  %d / %d", data.held, Progression.tiers[data.tier].capacity)
		objective.Text = if data.won
			then "REACTOR SILENCED"
			elseif
				data.bossActive
			then "WARDEN / dodge amber marks; pull cyan couplings when exposed"
			else ({ "BREAKER YARD", "THE CRUCIBLE", "REACTOR ACCESS" })[data.sector]
				.. " / "
				.. data.remaining
				.. " marked targets remain"
		bossPanel.Visible = data.bossActive and not data.won
		bossText.Text = if data.exposed
			then "WARDEN " .. data.bossPhase .. "/3 • EXPOSED • PULL COUPLINGS"
			else "WARDEN " .. data.bossPhase .. "/3 • SHIELDED • DODGE, THEN PUNISH"
		bossFill.Size = UDim2.new(math.clamp(data.bossHp / data.bossMax, 0, 1), -20, 0, 7)
		ending.Visible = data.won
		if data.won and not wasWon and lastInput.Name:find("Gamepad") then
			GuiService.SelectedObject = replayButton
		end
		if data.won then
			menu = false
			overlay.Visible = false
			endingText.Text = string.format(
				"Cycle %d cleared in %d:%02d\n%d session targets dismantled • %d Salvage banked\n\nThe Warden is silent. Reignite a harder foundry to earn the next evolution. Your gear and Salvage stay with you this session.",
				data.cycle,
				math.floor(data.seconds / 60),
				data.seconds % 60,
				data.kills,
				data.cash
			)
			replayButton.Text = if data.voted
				then "WAITING FOR CREW / " .. data.votes .. " of " .. data.players
				else "REIGNITE / KEEP YOUR GEAR"
		end
		if menu then
			showPreview()
		end
	elseif kind == "notice" then
		notify(data)
	elseif kind == "capture" then
		Effects.beam(data.from, data.to, data.tier)
	elseif kind == "launch" then
		Effects.sound("launch", data.tier)
		if data.owner == player.UserId then
			shake = 0.045 + data.tier * 0.025
		end
	elseif kind == "impact" then
		Effects.burst(data.position, data.tier)
	elseif kind == "destroy" then
		Effects.burst(data.position, data.tier, true)
	elseif kind == "warning" then
		Effects.warning(data)
		notify(
			if data.ring then "SHOCKWAVE — JUMP OR TAKE COVER" else "AMBER MARK — MOVE OUT",
			data.duration
		)
	elseif kind == "strike" then
		Effects.strike(data)
	elseif kind == "hit" then
		hit.Text = "× " .. data.damage
		hitUntil = os.clock() + 0.45
	elseif kind == "reward" then
		notify("+" .. data.amount .. " SALVAGE  /  +10 integrity")
		Effects.sound("reward", 2)
	elseif kind == "hurt" then
		hurt.BackgroundTransparency = 0.8
		TweenService:Create(hurt, TweenInfo.new(0.5), { BackgroundTransparency = 1 }):Play()
		shake = 0.12
	elseif kind == "evolve" then
		menu = false
		overlay.Visible = false
		GuiService.SelectedObject = nil
		local tier = Progression.tiers[data.tier]
		announce(tier.name .. " / ONLINE", tier.description)
		for i = 1, 3 do
			task.delay(i * 0.18, function()
				Effects.sound("evolve", data.tier + i)
			end)
		end
	elseif kind == "sector" then
		announce(
			({ "", "CRUCIBLE UNSEALED", "REACTOR BREACHED" })[data.sector],
			"Checkpoint reached • +50 Salvage • Forge your next evolution"
		)
		Effects.sound("reward", 3)
	elseif kind == "bossIntro" then
		announce(
			"WARDEN / CONTAINMENT PROTOCOL",
			"Dodge its attacks. Tear off cyan couplings. Return them to the heart."
		)
	elseif kind == "phase" then
		notify("CONTAINMENT REFORMS • NEXT PHASE INCOMING", 3)
		Effects.sound("reward", 1)
	elseif kind == "expose" then
		notify("COUPLINGS EXPOSED • PULL AND RETURN TO THE HEART", 5)
		Effects.sound("reward", 2)
	elseif kind == "victory" then
		Effects.calm(true)
		announce("CONTAINMENT BROKEN", "+200 crew Salvage • the foundry belongs to you")
		Effects.sound("evolve", 5)
	elseif kind == "replay" then
		Effects.calm(false)
		ending.Visible = false
		GuiService.SelectedObject = nil
		announce("CYCLE " .. data.cycle, "Gear retained. Tougher machines. Greater Salvage.")
	end
end)
local lastViewport = Vector2.zero
local orbitModels: { Model } = {}
local orbitScan = 0
RunService:BindToRenderStep("FoundryFeedback", Enum.RenderPriority.Camera.Value + 1, function(dt)
	local camera = workspace.CurrentCamera
	if not camera then
		return
	end
	local size = camera.ViewportSize
	if os.clock() - orbitScan > 0.5 then
		orbitScan = os.clock()
		table.clear(orbitModels)
		local world = workspace:FindFirstChild("GravityFoundryArena")
		if world then
			for _, model in world:GetChildren() do
				if
					model:IsA("Model")
					and model.PrimaryPart
					and model.PrimaryPart:GetAttribute("Pullable")
				then
					table.insert(orbitModels, model)
				end
			end
		end
	end
	for _, model in orbitModels do
		local p = model.PrimaryPart
		if p then
			local id = p:GetAttribute("OrbitOwner")
			local owner = if typeof(id) == "number" then Players:GetPlayerByUserId(id) else nil
			local character = owner and owner.Character
			local r = character and character:FindFirstChild("HumanoidRootPart")
			if owner and r and r:IsA("BasePart") then
				local tier = owner:GetAttribute("FoundryTier") or 1
				local desired = Orbit.pose(
					r.Position,
					tier,
					(p:GetAttribute("OrbitSlot") :: number?) or 1,
					(p:GetAttribute("OrbitCount") :: number?) or 1,
					workspace:GetServerTimeNow()
				)
				model:PivotTo(model:GetPivot():Lerp(desired, 1 - math.exp(-(9 + tier) * dt)))
			end
		end
	end

	if size ~= lastViewport then
		lastViewport = size
		local small = size.X < 850
		hud.Size = UDim2.fromOffset(if small then 190 else 244, 112)
		forgeButton.Size = UDim2.fromOffset(if small then 190 else 244, 38)
		objectivePanel.Position = if small
			then UDim2.new(1, -15, 0, 55)
			else UDim2.new(0.65, 0, 0, 55)
		objectivePanel.AnchorPoint = if small then Vector2.new(1, 0) else Vector2.new(0.5, 0)
		objectivePanel.Size = UDim2.new(if small then 0.46 else 0.45, 0, 0, 69)
		objective.TextSize = if small then 13 else 16
		description.TextSize = if small then 12 else 16
		stats.TextSize = if small then 12 else 16
		previewTitle.TextSize = if small then 16 else 23
	end
	local position = if UIS.TouchEnabled or lastInput.Name:find("Gamepad")
		then size / 2
		else UIS:GetMouseLocation()
	cross.Position = UDim2.fromOffset(position.X - 13, position.Y - 13)
	cross.Visible = not menu and not (state and state.won)
	if shake > 0.001 then
		local strength = shake
		shake *= math.exp(-16 * dt)
		camera.CFrame *= CFrame.new(
			(math.random() - 0.5) * strength,
			(math.random() - 0.5) * strength,
			0
		)
	end
	if menu and previewModel then
		previewModel:PivotTo(CFrame.Angles(0, os.clock() * 0.4, 0))
	end
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	healthFill.Size = UDim2.fromScale(
		if humanoid then math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1) else 0,
		1
	)
	if os.clock() > hitUntil then
		hit.Text = ""
	end
	if os.clock() > noticeUntil then
		notice.Text = if state and state.tier < 5
			then "E / L2: pull  •  click / R2: launch  •  B / Y: evolve in Forge"
			else "EVENT HORIZON ONLINE • reignite the foundry for another run"
	end
end)
remote:FireServer("ready")
