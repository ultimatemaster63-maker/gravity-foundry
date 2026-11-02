--!strict
local Rules = {}
function Rules.damage(hp: number, maximum: number, amount: number, boss: boolean): number
	local floor = 0
	if boss then
		floor = if hp > maximum * 2 / 3
			then maximum * 2 / 3
			elseif hp > maximum / 3 then maximum / 3
			else 0
	end
	return math.max(floor, hp - amount)
end
function Rules.inThreat(
	x: number,
	z: number,
	height: number,
	radius: number,
	shockwave: boolean
): boolean
	return x * x + z * z <= radius * radius and (not shockwave or height < 6)
end
return Rules
