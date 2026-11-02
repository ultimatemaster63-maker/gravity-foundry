-- Pure gameplay tests; these exercise the same modules used by the server.
local Progression = require("../src/shared/Progression")
local Rules = require("../src/shared/CombatRules")
local count = 0
local function check(condition, message)
	assert(condition, message)
	count += 1
end
local cash, tier, ok = Progression.purchase(139, 1)
check(not ok and cash == 139 and tier == 1, "cannot buy without sufficient salvage")
cash, tier, ok = Progression.purchase(140, 1)
check(ok and cash == 0 and tier == 2, "exact price upgrades once")
local remaining, newTier, again = Progression.purchase(cash, tier)
check(not again and remaining == 0 and newTier == 2, "duplicate purchase cannot overspend")
check(select(3, Progression.purchase(99999, 5)) == false, "final tier cannot overflow")
for i = 2, #Progression.tiers do
	local previous = Progression.tiers[i - 1]
	local current = Progression.tiers[i]
	check(
		current.capacity > previous.capacity
			and current.range > previous.range
			and current.damage > previous.damage,
		"every evolution changes gameplay"
	)
	check(current.cost > previous.cost, "prestige stages require increasing investment")
end
-- First-run budget from authored targets plus two checkpoint bonuses and ending payout.
local budget = 300 + 560 + 540 + 500 + 100 + 200
local earned = budget
local level = 1
while true do
	local nextCash, nextLevel, bought = Progression.purchase(earned, level)
	if not bought then
		break
	end
	earned = nextCash
	level = nextLevel
end
check(level == 4, "a complete first run affords Singularity, not the final appearance")
check(earned < Progression.tiers[5].cost, "Event Horizon requires replay effort")
check(
	Progression.multiplier(1) == 1 and Progression.multiplier(100) == 1.9,
	"replay health scaling is capped"
)
check(Rules.damage(1200, 1200, 5000, true) == 800, "huge hit cannot skip phase one")
check(Rules.damage(800, 1200, 5000, true) == 400, "huge hit cannot skip phase two")
check(Rules.damage(400, 1200, 5000, true) == 0, "phase three can be defeated")
check(Rules.damage(90, 90, 48, false) == 42, "ordinary damage applies exactly")
check(Rules.damage(42, 90, 48, false) == 0, "ordinary target never goes below zero")
check(Rules.inThreat(3, 4, 3, 5, false), "warning disc includes its visible boundary")
check(not Rules.inThreat(3, 4.1, 3, 5, false), "outside warning disc is safe")
check(not Rules.inThreat(0, 0, 7, 34, true), "jump clears shockwave")
check(Rules.inThreat(0, 0, 3, 34, true), "standing in shockwave is hit")
print(string.format("PASS: %d gameplay-rule assertions", count))
