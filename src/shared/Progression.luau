--!strict
-- Pure progression rules; the server owns currency and unlock decisions.
local Progression = {}
export type Tier = {
	name: string,
	cost: number,
	capacity: number,
	range: number,
	mass: number,
	damage: number,
	speed: number,
	cooldown: number,
	description: string,
}
Progression.tiers = {
	{
		name = "RUSTHAND",
		cost = 0,
		capacity = 2,
		range = 34,
		mass = 1,
		damage = 48,
		speed = 105,
		cooldown = 0.42,
		description = "A welded cuff. Bent plates and bolts. Make something from nothing.",
	},
	{
		name = "INDUCTION",
		cost = 140,
		capacity = 3,
		range = 46,
		mass = 2,
		damage = 72,
		speed = 130,
		cooldown = 0.34,
		description = "Twin copper coils • heavy flywheels • three-piece orbit",
	},
	{
		name = "HELIX",
		cost = 420,
		capacity = 4,
		range = 60,
		mass = 3,
		damage = 100,
		speed = 155,
		cooldown = 0.28,
		description = "Split armor and floating fins • I-beams • tilted orbit",
	},
	{
		name = "SINGULARITY",
		cost = 1000,
		capacity = 5,
		range = 74,
		mass = 4,
		damage = 135,
		speed = 185,
		cooldown = 0.23,
		description = "Suspended dark core • reactor fragments • double orbit",
	},
	{
		name = "EVENT HORIZON",
		cost = 2200,
		capacity = 6,
		range = 88,
		mass = 4,
		damage = 180,
		speed = 215,
		cooldown = 0.19,
		description = "Detached crown and satellite plates • six-body gravity storm",
	},
} :: { Tier }
function Progression.purchase(cash: number, tier: number): (number, number, boolean)
	local nextTier = Progression.tiers[tier + 1]
	if not nextTier or cash < nextTier.cost then
		return cash, tier, false
	end
	return cash - nextTier.cost, tier + 1, true
end
function Progression.multiplier(cycle: number): number
	return 1 + math.min(cycle - 1, 5) * 0.18
end
function Progression.finiteVector(v: Vector3): boolean
	return v.X == v.X and v.Y == v.Y and v.Z == v.Z and v.Magnitude < 100000
end
return Progression
