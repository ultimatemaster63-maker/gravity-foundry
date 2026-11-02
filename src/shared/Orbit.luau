--!strict
local Orbit = {}
function Orbit.pose(
	position: Vector3,
	tier: number,
	index: number,
	count: number,
	time: number
): CFrame
	local angle = time * (1.1 + tier * 0.18) + (index - 1) * math.pi * 2 / math.max(count, 1)
	local radius = 4.5 + tier * 0.35 + (if tier >= 4 and index % 2 == 0 then 1.6 else 0)
	local tilt = if tier >= 3 then math.sin(angle) * 1.7 else 0.3 * math.sin(angle * 1.3)
	return CFrame.new(
		position + Vector3.new(math.cos(angle) * radius, 1.8 + tilt, math.sin(angle) * radius)
	) * CFrame.Angles(angle * 0.35, angle, 0.3)
end
return Orbit
