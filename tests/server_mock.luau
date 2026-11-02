-- Deterministic Roblox service boundary for server-flow tests.
-- No physics, rendering, replication or Studio behavior is claimed by this fixture.
local now = 0
local os = {
	clock = function()
		return now
	end,
}
local function signal()
	local handlers = {}
	return {
		Connect = function(_, f)
			table.insert(handlers, f)
			return { Disconnect = function() end }
		end,
		Fire = function(_, ...)
			for _, f in handlers do
				f(...)
			end
		end,
	}
end
local vmeta = {}
local nativeTypeof = typeof
local function typeof(value)
	return if type(value) == "table" and getmetatable(value) == vmeta
		then "Vector3"
		else nativeTypeof(value)
end
local function vec(x, y, z)
	return setmetatable({ X = x or 0, Y = y or 0, Z = z or 0 }, vmeta)
end
vmeta.__add = function(a, b)
	return vec(a.X + b.X, a.Y + b.Y, a.Z + b.Z)
end
vmeta.__sub = function(a, b)
	return vec(a.X - b.X, a.Y - b.Y, a.Z - b.Z)
end
vmeta.__mul = function(a, b)
	return vec(a.X * b, a.Y * b, a.Z * b)
end
vmeta.__div = function(a, b)
	return vec(a.X / b, a.Y / b, a.Z / b)
end
vmeta.__index = function(v, k)
	if k == "Magnitude" then
		return math.sqrt(v.X * v.X + v.Y * v.Y + v.Z * v.Z)
	end
	if k == "Unit" then
		return v / v.Magnitude
	end
	if k == "Dot" then
		return function(a, b)
			return a.X * b.X + a.Y * b.Y + a.Z * b.Z
		end
	end
end
local Vector3 = { new = vec, zero = vec(), one = vec(1, 1, 1) }
local cmeta = {}
local function cf(x, y, z)
	return setmetatable({ Position = if type(x) == "table" then x else vec(x, y, z) }, cmeta)
end
cmeta.__mul = function(a, b)
	return cf(a.Position + b.Position)
end
cmeta.__add = function(a, b)
	return cf(a.Position + b)
end
cmeta.__index = {
	Lerp = function(a, b, alpha)
		return cf(a.Position + (b.Position - a.Position) * alpha)
	end,
}
local CFrame = {
	new = cf,
	Angles = function()
		return cf()
	end,
}
local Color3 = {
	fromRGB = function(...)
		return { ... }
	end,
	new = function(...)
		return { ... }
	end,
}
local UDim2 = {
	fromOffset = function(...)
		return { ... }
	end,
	fromScale = function(...)
		return { ... }
	end,
}
local Enum = setmetatable({}, {
	__index = function(t, k)
		local group = setmetatable({}, {
			__index = function(_, name)
				return name
			end,
		})
		rawset(t, k, group)
		return group
	end,
})
local NumberSequence = {
	new = function(...)
		return { ... }
	end,
}
local ColorSequence = {
	new = function(...)
		return { ... }
	end,
}
local TweenInfo = {
	new = function(...)
		return { ... }
	end,
}
local RaycastParams = {
	new = function()
		return {}
	end,
}
local methods = {}
local imeta = {}
function methods:IsA(class)
	return self.ClassName == class
		or (class == "BasePart" and (self.ClassName == "Part" or self.ClassName == "SpawnLocation"))
end
function methods:GetChildren()
	return self._children
end
function methods:GetDescendants()
	local result = {}
	for _, child in self._children do
		table.insert(result, child)
		for _, desc in child:GetDescendants() do
			table.insert(result, desc)
		end
	end
	return result
end
function methods:FindFirstChild(name)
	for _, child in self._children do
		if child.Name == name then
			return child
		end
	end
	return nil
end
methods.WaitForChild = methods.FindFirstChild
function methods:FindFirstChildOfClass(class)
	for _, child in self._children do
		if child:IsA(class) then
			return child
		end
	end
	return nil
end
function methods:GetAttribute(name)
	return self._attributes[name]
end
function methods:SetAttribute(name, value)
	self._attributes[name] = value
end
function methods:IsDescendantOf(parent)
	local p = self.Parent
	while p do
		if p == parent then
			return true
		end
		p = p.Parent
	end
	return false
end
function methods:GetPivot()
	return self.PrimaryPart and self.PrimaryPart.CFrame or cf()
end
function methods:PivotTo(pivot)
	local offset = pivot.Position - self:GetPivot().Position
	for _, part in self:GetDescendants() do
		if part:IsA("BasePart") then
			part.CFrame = part.CFrame + offset
		end
	end
end
function methods:Destroy()
	if self.Parent then
		local index = table.find(self.Parent._children, self)
		if index then
			table.remove(self.Parent._children, index)
		end
	end
	self.Parent = nil
end
function methods:TakeDamage(amount)
	self.Health = math.max(0, self.Health - amount)
	if self.Health == 0 then
		self.Died:Fire()
	end
end
imeta.__index = function(self, key)
	if key == "Position" then
		return self._props.CFrame.Position
	end
	return methods[key] or self._props[key] or methods.FindFirstChild(self, key)
end
imeta.__newindex = function(self, key, value)
	if key == "Position" then
		self._props.CFrame = cf(value)
	elseif key == "Parent" then
		local old = self._props.Parent
		if old then
			local i = table.find(old._children, self)
			if i then
				table.remove(old._children, i)
			end
		end
		self._props.Parent = value
		if value then
			table.insert(value._children, self)
		end
	else
		self._props[key] = value
	end
end
local Instance = {
	new = function(class)
		return setmetatable({
			_children = {},
			_attributes = {},
			_props = {
				ClassName = class,
				Name = class,
				CFrame = cf(),
				Transparency = 0,
				CanQuery = true,
				CanCollide = true,
			},
		}, imeta)
	end,
}
local workspace = Instance.new("Workspace")
local hitTarget = nil
local blocked = false
function workspace:Raycast()
	if blocked then
		return { Instance = Instance.new("Part") }
	end
	return nil
end
function workspace:Spherecast()
	if hitTarget then
		local target = hitTarget
		hitTarget = nil
		return { Instance = target.root, Position = target.root.Position }
	end
	return nil
end
function workspace:GetServerTimeNow()
	return now
end
local players = {}
local Players = {
	PlayerAdded = signal(),
	PlayerRemoving = signal(),
	GetPlayers = function()
		return players
	end,
}
local RunService = { Heartbeat = signal() }
local storage = Instance.new("ReplicatedStorage")
local shared = Instance.new("Folder")
shared.Name = "GravityFoundryShared"
shared.Parent = storage
local TweenService = {
	Create = function(_, object, _, properties)
		return {
			Play = function()
				for key, value in properties do
					object[key] = value
				end
			end,
		}
	end,
}
local services = {
	Players = Players,
	RunService = RunService,
	ReplicatedStorage = storage,
	TweenService = TweenService,
	Lighting = {},
}
local game = {
	GetService = function(_, name)
		return services[name]
	end,
}
local task = {
	spawn = function(f, ...)
		f(...)
	end,
}
local originalNew = Instance.new
local remote
Instance.new = function(class)
	local instance = originalNew(class)
	if class == "RemoteEvent" then
		remote = instance
		instance.OnServerEvent = signal()
		instance.FireClient = function(_, player, kind, data)
			if kind == "state" then
				player.state = data
			end
		end
		instance.FireAllClients = function() end
	end
	return instance
end
local function newPlayer(id)
	local p = Instance.new("Player")
	p.UserId = id
	p.CharacterAdded = signal()
	local character = Instance.new("Model")
	local r = Instance.new("Part")
	r.Name = "HumanoidRootPart"
	r.Parent = character
	local h = Instance.new("Humanoid")
	h.Health = 100
	h.MaxHealth = 100
	h.Died = signal()
	h.Parent = character
	p.Character = character
	table.insert(players, p)
	return p
end
local player = newPlayer(1)
