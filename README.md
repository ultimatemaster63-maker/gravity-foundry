# Gravity Foundry

A standalone Roblox project scaffold. No gameplay, third-party packages, remote events, or persistence yet. This project has no Titan connection or place IDs.

- `src/server`: one server entry point; add private systems as ModuleScripts here.
- `src/client`: one client entry point; add controllers as ModuleScripts here.
- `src/shared`: client-safe shared modules, currently only project identity.
- `default.project.json`: maps dedicated GravityFoundry code folders only. Studio owns the world.
- `v2-vault-main/v2-vault-main`: bundled LihFolk development reference; not part of the built game.

## Tools and checks

Pinned in `rokit.toml`: Rojo 7.6.1, Selene 0.29.0, StyLua 2.3.1. With [Rokit](https://github.com/rojo-rbx/rokit) installed, run `rokit install` from this directory. Python 3 is required by the check runner. No Wally packages are needed.

Linux cloud alternative:

```sh
python3 scripts/install-cloud-tools.py
export PATH="$PWD/.tools/bin:$PATH"
python3 scripts/check.py
```

Checks cover StyLua formatting, Selene lint, Rojo place build and sourcemap generation. `--!strict` marks Luau files for Studio analysis; Selene is not a Luau type checker. Studio Script Analysis and Play remain required.

See [Studio handoff](docs/STUDIO.md) for exact local setup, transfer and playtesting steps, and [setup evidence](docs/SETUP.md) for validation and limitations.
