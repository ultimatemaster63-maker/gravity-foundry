# Gravity Foundry first playable

Runtime code constructs an industrial arena under Workspace.GravityFoundryArena when Play starts. Stop Play removes the runtime world. The Rojo code-folder mappings and pinned tools are unchanged. Existing Studio world objects are not deleted; use the dedicated empty Gravity Foundry place to prevent overlapping geometry.

Implemented: three gated sectors, 12 salvage machines, six hovering sentinels, orbit capture, aimed swept-sphere projectiles, server damage/rewards, Salvage, power and orbit upgrades, guardian with six throwable exposed cores, integrity display, touch/gamepad bindings, furnace lighting, cyan highlights and impact bursts, and shared-session replay retaining upgrades. Kills repair 8 health. Progress and upgrades last only for the current server session. Replay resets the shared arena for all players. There are no paid items, DataStores or external asset dependencies.

## Local handoff

After the gameplay commit is pushed, in your dedicated checkout:

```sh
git fetch origin
git switch setup/gravity-foundry
git pull --ff-only origin setup/gravity-foundry
rokit install
python scripts/check.py
rojo serve default.project.json --address 127.0.0.1 --port 34872
```

Install the matching plugin with `rojo plugin install` while Studio is closed if needed. Open `build/GravityFoundry.rbxlx`, connect the plugin to localhost:34872, verify Gravity Foundry, then Play. Keep the place unpublished with servePlaceIds [0], or explicitly configure your own Gravity Foundry development place ID. Never use Titan. See STUDIO.md for transfer and rebuild details.

## Controls and test route

- WASD / thumbstick: move; right mouse drag / right stick: aim camera. Crosshair is the launch aim point.
- E / L2 / Pull touch button: capture nearest visible scrap within 48 studs. Initially two pieces fit in orbit.
- Left click / R2 / Launch touch button: fire one held piece toward the center crosshair.
- Click upgrade buttons to spend earned Salvage (maximum level 5). Buttons work anywhere.
- Destroy every machine and sentinel in Intake to open Press Hall; repeat to open Reactor. Orange enemy pulses warn of an attack; machinery provides cover. Destroyed targets stop blocking projectiles.
- In Reactor, pull the cyan exposed cores and fire them into the guardian for bonus damage. Defeat it to unlock replay with current upgrades.

## Required Studio validation

Run Play and Script Analysis; inspect Output for errors. Verify capture through walls is rejected, fast shots hit, every sector unlocks, death clears held scrap, players respawn, upgrades deduct the right amount, guardian cores deal bonus damage, and replay restores targets/labels/gates while retaining upgrades. Run a two-player server test for remote ownership, shared progression, disconnect while holding scrap, and simultaneous kills/replay. Test controller and narrow mobile layouts; check that UI buttons do not launch shots. Tune enemy pressure, camera readability, network orbit smoothness and costs after an actual full run.

Cloud evidence: StyLua and Rojo build/sourcemap pass; official Luau 0.744 compiler accepts gameplay scripts. Selene remains blocked by the documented Roblox-definition downloader issue. No Studio engine, strict type-analysis, latency test or complete human playthrough has run here. The implementation is a first playable candidate, not a verified polished release. Audio, authored animation and persistence are not implemented. No experience was published.
