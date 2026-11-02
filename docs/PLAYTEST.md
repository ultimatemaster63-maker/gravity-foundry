# Gravity Foundry — full first-version playtest

The full completion route is implemented. Automated checks pass, including a simulated server flow, but this revision has **not been personally played in Studio by the agent**. It is awaiting engine acceptance, not being represented as a verified finished experience.

## Open the right build

In your dedicated Gravity Foundry checkout (preserve any local edits first):

```sh
git fetch origin
git switch setup/gravity-foundry
git pull --ff-only origin setup/gravity-foundry
rokit install
python scripts/check.py
rojo serve default.project.json --address 127.0.0.1 --port 34872
```

Use `python3` where appropriate. With the matching Rojo Studio plugin installed, open `build/GravityFoundry.rbxlx`, connect to **localhost:34872**, verify the project name, sync, and Play. A local Rojo server runs on your computer; cloud localhost does not connect to your Studio. The code generates the world when Play starts. Stop Play before pulling changes and start a fresh session afterward. Do not test inside Titan or an existing hand-built map.

No place has been published. `[0]` still restricts sync to unpublished places; a published development place requires explicitly configuring that Gravity Foundry place ID.

## Actual controls

| Action | Mouse/keyboard | Controller | Touch |
| --- | --- | --- | --- |
| Move / jump | WASD / Space | Left stick / jump button | Roblox movement controls |
| Aim | Mouse reticle; right-drag to turn camera | Center reticle / right stick | Center reticle / drag camera |
| Pull visible scrap | E | L2 | PULL button |
| Launch oldest orbiting piece | Left click | R2 | LAUNCH button |
| Open/close Forge | B or FORGE button | Y | FORGE button |
| Buy / choose preview | Click | UI navigation / activate | Tap |
| Replay after victory | Ending button | Select/activate ending button | Ending button |

Pull chooses visible scrap near your aim direction within your current reach. Walls block capture; your tier limits mass and orbit capacity. A blocked orbit cannot launch through cover. Empty orbit, full capacity, heavy scrap and insufficient currency produce messages. Forge/UI clicks should never fire a projectile. The game continues while Forge is open: use cleared space.

## Short completion route

1. **Breaker Yard:** Aim at the outlined plates ahead of spawn, pull two pieces, then launch at the marked pressure machines, drone and hazard-braced barrier. Amber floor marks announce incoming attacks; step outside them. Destroy all **4** targets to open the shutter. Kills repair 10 integrity. At **140 Salvage**, open Forge and buy **Induction**; verify the new copper coils, third orbit slot, heavier flywheels and reveal/audio.
2. **Crucible:** Clear **5** marked targets between the furnace towers. Use machinery for cover and step out of blast marks. Buy **Helix for 420** when affordable. Check the floating armor fins, tilted four-piece orbit and pullable I-beams. Clearing this room opens Reactor and moves the respawn checkpoint. Each sector unlock awards 50 crew Salvage.
3. **Reactor access:** Destroy the **4** support targets. The Warden awakens only afterward. Avoid committed amber blast discs. On shockwave warnings, jump or use cover. During cyan exposure, pull the three coupling blocks in front of the guardian and throw them into its heart. Ordinary scrap also damages the exposed guardian; returned couplings penetrate its shield. Its three phases add staggered blast zones and a combined final shockwave. Damage cannot skip a phase; each transition reforms containment briefly before the next attack. Scrap and couplings replenish after use, so misses cannot exhaust the fight.
4. **Ending:** Defeat the Warden. Verify the arena falls quiet, the completion time/Salvage screen appears, and the crew gets 200 Salvage. The killer also earns the guardian bounty. Select **REIGNITE**. In multiplayer, every connected player must consent. Verify shutters, targets and boss reset while gear and Salvage remain.
5. **Visual chase:** Buy **Singularity for 1,000** during the first run or after replay: suspended core, containment ring, double orbit, reactor shards. **Event Horizon costs 2,200 after previous stages** and requires replay earnings: detached crown, satellites and six-piece orbit. Preview every form in the Forge; owned stages cannot be purchased twice. Repeat cycles raise target health gradually, capped at +90%, and increase kill rewards.

A solo first clear awards 2,200 total Salvage before spending, enough to purchase through Singularity (1,560 cumulative), but not Event Horizon (3,760 cumulative). Multiplayer distributes kill rewards to the player responsible, with checkpoint and ending bonuses shared.

## Acceptance checklist in Studio

- Complete the route above with Output and Script Analysis visible; record errors verbatim.
- Check gauntlet geometry on R15 and R6, all five previews/reveals, and audio audibility at comfortable volume. Audio uses Roblox-bundled samples with pitch/EQ/layered reveal timing; listening quality is not verified in cloud.
- Verify mouse reticle matches shot direction, UI buttons never shoot, and gamepad can navigate Forge and ending. Try a narrow phone viewport; check all labels and buttons are reachable without overlap.
- Pull through a wall (must fail), try a too-heavy piece, fill orbit, miss shots, die while holding scrap, and respawn at the latest checkpoint. Held pieces must release; upgrades and currency must remain.
- Verify guardian warnings match damage areas; jump the shockwave; test cover and core recovery after misses. No damage after victory; no phase skipped by a heavy hit.
- Start a two-player server: compete for one piece, join late, disconnect with a piece in flight, and vote for replay separately. One player must not reset another's ending. Check anchored-orbit smoothing at simulated latency.
- Watch performance during repeated impacts and two full replay cycles. Cosmetic parts and sounds have lifetime/concurrency limits; verify no accumulation in the engine.

## Scope and access limitation

Progress is **session-only**: retained through death/replay, reset on leaving the server. No DataStore, purchases, external asset IDs or publishing credentials are required. The environment is built from authored arrangements of Roblox geometry; no external mesh pack is needed. The runtime owns only `Workspace.GravityFoundryArena` and its local effects, while Rojo mappings remain code-only.

This session exposed no computer-control tools or Roblox Studio connector, and the attached Linux workspace had no running Studio process. No desktop on the user's computer was accessible. Automated tests are explicitly simulated; they cannot establish physics, replication, rendering, audio or input quality. See VALIDATION.md for evidence. No experience was published.
