# Open and test Gravity Foundry in Studio

The cloud environment does **not** connect to your computer's Roblox Studio. Cloud localhost is a different machine. No Studio credentials or local connection are inherited.

## Recommended: Git transfer, then local Rojo

1. Use a **dedicated Gravity Foundry checkout** on your computer. After the setup branch has been pushed, first-time setup is:

   ```sh
   git clone --branch setup/gravity-foundry https://github.com/ultimatemaster63-maker/gravity-foundry.git
   cd gravity-foundry
   git log -1 --oneline
   ```

   For an existing dedicated checkout with no uncommitted changes:

   ```sh
   git fetch origin
   git switch setup/gravity-foundry
   git pull --ff-only origin setup/gravity-foundry
   git log -1 --oneline
   ```

   Confirm the commit matches the setup handoff. Do not run these commands in Titan's checkout. If local changes exist, preserve them before switching; do not reset them.
2. Install Roblox Studio, Git, Python 3 and Rokit locally. In the repository root run `rokit install`, then verify `rojo --version` is 7.6.1. Install the matching Studio plugin using `rojo plugin install` on your computer with Studio closed (or the official Rojo plugin from https://rojo.space/docs/v7/getting-started/installation/).
3. Run `python scripts/check.py` (`python3` on macOS). Then open `build/GravityFoundry.rbxlx` in Studio using **File > Open from File**. It is a minimal place with code only; no map or gameplay is expected.
4. Keep this place unpublished for the first sync. `servePlaceIds: [0]` restricts live sync to unpublished places. From the **local repository root** run `rojo serve default.project.json --address 127.0.0.1 --port 34872`. In Studio's Rojo plugin connect to `localhost:34872`. Confirm the project name **Gravity Foundry** and inspect the proposed changes before syncing.
5. Open Output and Script Analysis, then click **Play**. Expect `[Gravity Foundry] Server scaffold ready` and `[Gravity Foundry] Client scaffold ready`, and no script errors. Stop the session. This verifies the entry points and shared module; gameplay is intentionally absent. Cloud builds do not establish this result.
6. If you want a persistent development place, publish using **Publish to Roblox As** into a **new Gravity Foundry experience**, never Titan. Record its development **place ID** and replace `[0]` in `servePlaceIds` with `[YOUR_NUMERIC_DEV_PLACE_ID]` (actual JSON numbers). Commit that explicit change before reconnecting. No ID has been invented here. Save the world using Studio/version history.
7. For later cloud work: review and push the cloud code commit, stop Play locally, pull that commit on your computer, run the checks and let your **local** Rojo server sync it. Re-run Play and inspect Output. Do not edit mapped code in Studio; Rojo treats the filesystem as authoritative.

Rojo owns only `ReplicatedStorage.GravityFoundryShared`, `ServerScriptService.GravityFoundryServer`, and `StarterPlayer.StarterPlayerScripts.GravityFoundryClient`. Keep hand-built world objects outside those folders. No Workspace mapping or broad world deletion is configured. The initial file contains no baseplate; build a test world locally when gameplay work begins.

## Offline artifact fallback

Download `build/GravityFoundry.rbxlx` from the cloud workspace to your computer and open it via File > Open from File. This is a point-in-time build and needs no Rojo connection. Download a fresh build after changes. Opening a fresh build does not merge or preserve a world edited in an older file: use the local Git/Rojo workflow for ongoing work.

Never expose the cloud Rojo port or enter Titan IDs as a shortcut. No Open Cloud API key is required for this workflow.

## When to reconnect, restart, or rebuild

| Change | Required local action |
| --- | --- |
| `.luau` edits inside existing mapped folders | Stop Play, pull, run checks; the running local Rojo normally live-syncs. Re-run Play to execute fresh server/client code and clear ModuleScript caches. No Rojo reconnect or place rebuild is normally needed. |
| Add/remove/rename mapped code files or folders | Inspect the Rojo diff carefully; live sync normally handles these. Re-run Play. A mapping/root change falls under the next row. |
| `default.project.json`, mapped roots, place restrictions, address or port | Stop the local Rojo server, pull, restart it, then disconnect/reconnect the Studio plugin and inspect the proposed sync. A change from unpublished to a published dev place requires the correct place-ID allowlist before reconnecting. |
| CLI/plugin version change | Run `rokit install`, update the local Studio plugin to match, restart Rojo and reconnect. Restart Studio if required by plugin installation. |
| Build-only/non-live-sync properties or imported assets Rojo cannot update live | Run `rojo build default.project.json -o build/GravityFoundry.rbxlx` and open the rebuilt file for inspection. This scaffold has no such world properties. Preserve Studio-owned world work; a fresh scaffold file is not a merge into your existing world. |
| Documentation, formatter/linter configuration or CI only | No Studio reconnect or rebuild needed; run affected checks. |
| Downloaded `.rbxlx` artifact workflow | Every code change needs a fresh build and download/open; there is no live connection. |

A successful sync alone does not rerun already-executed scripts or invalidate every required module. Stop and start Play after code changes. Build checks do not constitute an engine playtest.
