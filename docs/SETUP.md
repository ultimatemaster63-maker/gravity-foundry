# Environment setup

Repository: `ultimatemaster63-maker/gravity-foundry`, branch `setup/gravity-foundry`. The initial prototype `c8f710b` was backed up before this expansion; see VALIDATION.md for paths and checksums.

The bundled development vault is present at `v2-vault-main/v2-vault-main/LihFolk Vault V2`. `docs/roblox-vault/README.md` points to it. The original uploaded-vault inspection found no separate files in `/workspace/library-files` or `/workspace/shared/downloads`; no additional upload is assumed. Vault content has not been edited or loaded wholesale.

## Development

Use the existing checkout. Keep the pinned Rojo 7.6.1, Selene 0.29.0 and StyLua 2.3.1 in `rokit.toml`. No Wally packages, secrets or Open Cloud credentials are required.

```sh
rokit install
python scripts/check.py
```

On the cloud Linux machine:

```sh
python3 scripts/install-cloud-tools.py
python3 scripts/install-validation-tools.py
export PATH="$PWD/.tools/bin:$PATH"
python3 scripts/check.py --extended
```

The prior Selene downloader blocker is **resolved** by a full pinned definition cache; see SELENE-CACHE.md. Checks do not need to fetch Roblox API definitions. Tool installation still needs verified HTTPS access to GitHub releases. Do not replace proxy bindings or disable TLS.

The game builds to `build/GravityFoundry.rbxlx`. Rojo maps code only; server code constructs the arena when Play begins. Live processes do not survive an environment snapshot. No cloud Rojo process needs to remain running; Studio sync runs on the user's computer as documented in STUDIO.md.

See PLAYTEST.md for the complete game route and VALIDATION.md for passed checks and the unavailable Studio connection. Session gear survives death/replay, but there is no cross-server DataStore persistence. Nothing has been published to Roblox.
