# Pull, sync and playtest in Studio

Use a dedicated Gravity Foundry checkout and unpublished place. Cloud localhost is not your computer; this session has no inherited Studio connection.

## First local installation

Install Git, Python 3, Roblox Studio and Rokit. Then:

```sh
git clone --branch setup/gravity-foundry https://github.com/ultimatemaster63-maker/gravity-foundry.git
cd gravity-foundry
rokit install
rojo --version
rojo plugin install
python scripts/check.py
```

Run plugin installation with Studio closed. The pinned CLI is Rojo 7.6.1. Use `python3` on systems where that is the launcher.

Open `build/GravityFoundry.rbxlx` using **File > Open from File**. The world appears when Play starts; the edit-time file contains the mapped game code. From your local repository root:

```sh
rojo serve default.project.json --address 127.0.0.1 --port 34872
```

In Studio's Rojo plugin connect to `localhost:34872`, confirm **Gravity Foundry**, inspect the proposed sync, then Play with Output visible. Follow PLAYTEST.md from the Breaker Yard through guardian victory and replay.

`servePlaceIds: [0]` permits unpublished places only. Do not publish as part of this task. If you later choose an existing Gravity Foundry development place, explicitly replace the allowlist with that numeric **place ID**, never Titan's ID, before reconnecting.

## Updating an existing checkout

Stop Play and preserve any local edits before switching or pulling. Then:

```sh
git fetch origin
git switch setup/gravity-foundry
git pull --ff-only origin setup/gravity-foundry
git log -1 --oneline
rokit install
python scripts/check.py
```

Confirm the commit matches the handoff. Keep local Rojo running for code-only changes, allow the plugin to sync, then start a fresh Play session. Code is authoritative on disk; do not edit mapped scripts in Studio. Session-only upgrades reset when you stop and restart the server; in-game Reignite retains them.

| Change | Required action |
| --- | --- |
| Luau edits/new modules inside existing mapped folders | Pull, check, allow live sync, then restart Play. A Rojo reconnect is normally unnecessary. |
| Rojo mappings, place allowlist, port/address | Restart local Rojo and reconnect the plugin; inspect the sync. |
| CLI/plugin version | Install matching versions, restart Rojo, reconnect; restart Studio if plugin installation requires it. |
| Build-only properties or artifact-only workflow | Rebuild with `rojo build default.project.json -o build/GravityFoundry.rbxlx`; reopen the new file. |
| Docs, lint definitions or CI | Run affected checks; no Studio reconnect needed. |

The generated arena is under `Workspace.GravityFoundryArena`; client effects are under `Workspace.FoundryLocalEffects`. Use an otherwise empty test place so Studio-owned geometry does not overlap it. Rojo owns only `ReplicatedStorage.GravityFoundryShared`, `ServerScriptService.GravityFoundryServer`, and `StarterPlayer.StarterPlayerScripts.GravityFoundryClient`. No broad Workspace mapping is introduced.

## File fallback

Download `build/GravityFoundry.rbxlx` from the cloud workspace and open it locally. This needs no Rojo connection but is a point-in-time build: every update needs a new build/download. A fresh file does not merge an existing hand-built world; preserve that work separately.

No cloud port exposure, Roblox credentials or experience publication is required.
