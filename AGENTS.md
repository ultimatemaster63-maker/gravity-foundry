# Gravity Foundry

This repository is exclusively Gravity Foundry. Never use Titan places, credentials, paths, or assets. The first gameplay loop is implemented; engine validation is still required.

- Use this existing checkout; cloud tasks are isolated. Do not create worktrees unless requested.
- Code lives in `src/shared`, `src/server`, `src/client`. Keep server rules private; shared modules contain only client-safe data/functions. Use strict Luau, explicit dependencies, no require cycles or `_G`.
- Rojo owns only the three GravityFoundry code folders. Studio owns Workspace, terrain, lighting and visual assets. Edit mapped code on disk.
- Run `python3 scripts/check.py` with pinned tools on PATH. Lint, formatting and a Rojo build do not replace Studio playtesting.
- Cloud has no inherited Studio connection. Follow `docs/STUDIO.md`; never connect to Titan or production. Keep `servePlaceIds` restricted to 0 until a dedicated Gravity Foundry development place is identified.
- Vault: `v2-vault-main/v2-vault-main/LihFolk Vault V2`. Search `INDEX_SLIM.md` or run `_tools/vault.py` with the task. Read only relevant TL;DRs/sections; cite note titles. Never load the whole vault or run its setup/generation scripts blindly. Leave bundled vault files unchanged.
