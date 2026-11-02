# Setup evidence and remaining checks

## Files verified

- Git checkout: `/workspace/gravity-foundry`, origin `ultimatemaster63-maker/gravity-foundry`, starting HEAD `5c2602132f5dc9e2188700e8e27f50bb64a86c81`. Existing HTTPS proxy authentication successfully read origin HEAD.
- Bundled vault: `v2-vault-main/v2-vault-main/LihFolk Vault V2`, including `INDEX_SLIM.md`, search tools, notes and bundled reference assets. No separate uploaded files were found in `/workspace/library-files` or `/workspace/shared/downloads`. The bundled vault is present; any additional intended upload remains unverified.
- Consulted only relevant index entries and sections from **External Tooling - Rojo Wally Selene StyLua**, **Project Structure and Bootstrapping**, and search summaries from **Code Pipeline - Rojo Git and CI**. No bundled setup or generation scripts were run. Search created only its ignored cache.

## Current cloud validation

- Pinned Linux tool installer completed, checking SHA-256 on official HTTPS release downloads. Its script is available for refresh; installed executables are ignored under `.tools/bin`.
- StyLua formatting check passed on all three Luau files.
- Rojo build passed: `build/GravityFoundry.rbxlx`.
- Rojo sourcemap passed: `build/sourcemap.json`.
- Parsed the resulting XML and verified exactly one Script, one LocalScript and one ModuleScript. No Workspace mapping is present.
- Rojo loopback startup and GET `/api/rojo` succeeded: project `Gravity Foundry`, version 7.6.1, allowed place IDs `[0]`. The validation server was stopped afterward. Sandbox network operations required the permitted execution route.
- **Selene lint remains blocked in this cloud:** its Roblox standard-library generator attempts direct DNS for `raw.githubusercontent.com` and fails. The same API download succeeds via curl using the configured proxy. Lowercase proxy variables did not resolve Selene's downloader behavior. No TLS verification or lint rules were disabled, and no empty substitute library was introduced. `python3 scripts/check.py` deliberately exits nonzero while this remains unresolved, but still runs the independent build checks.
- GitHub Actions workflow is configured but has not run. It uses the pinned tool installer and the same check runner. Standard GitHub runners should permit Selene's API download; that result is unverified.

## Remaining requirements

On your computer: Roblox Studio, the matching Rojo plugin, Git, Python 3 and the pinned toolchain (Rokit recommended). Run Selene with access to its Roblox API download, Studio Script Analysis, and the Play smoke test in `STUDIO.md`. No gameplay or engine behavior has been tested in cloud, and no Luau type-checker CLI has been installed.

No additional cloud secrets or Open Cloud credentials are needed. No Titan project or existing place was accessed. The setup handoff is committed on `setup/gravity-foundry`; consult Git history for the commit. Push status is reported in the handoff message. No Roblox experience or environment snapshot has been published. The scaffold is buildable; full lint readiness remains blocked as described above.

## Selene diagnosis and supported cache handoff

Examined official Selene **0.29.0** source: [generator](https://github.com/Kampfkarren/selene/blob/0.29.0/selene/src/roblox/generate_std.rs), [cache loader](https://github.com/Kampfkarren/selene/blob/0.29.0/selene/src/roblox/collect_std.rs), and [configuration](https://github.com/Kampfkarren/selene/blob/0.29.0/selene-lib/src/lib.rs). Its downloader calls `ureq::get` on a hard-coded Roblox-Client-Tracker API URL. The detailed failure is `Dns Failed ... raw.githubusercontent.com:443 ... Temporary failure in name resolution`. Curl retrieves the same URL through the inherited HTTPS proxy with TLS verification. Both uppercase and lowercase proxy variables were present; explicitly setting lowercase variables did not help. This isolates the observed failure to Selene's downloader route, rather than missing GitHub credentials or an unavailable API file. Official 0.31.0 source retains this downloader, so an untested version upgrade was not used as a fix.

Selene supports a **generated project-local `roblox.yml`** with `roblox-std-source = "pinned"`. Its default floating cache is refreshed after six hours; it is not a reproducible pin. A downloaded raw API-Dump.json cannot be used as `roblox.yml`: the official generator transforms API classes and enums into Selene's schema and adds built-in Roblox/Luau definitions. This release's generator accepts no offline JSON input or alternate URL. There is no existing generated cache in this checkout. A pinned, valid cache therefore cannot currently be seeded by this cloud's installed official binary. Lint stays blocked, not passed.

On a connected local computer, from the repository root after `rokit install`, seed the supported cache once:

```sh
selene --version
selene generate-roblox-std
```

Require version 0.29.0. Only after generation succeeds, add `roblox-std-source = "pinned"` beneath `std = "roblox"` in `selene.toml`. Record the generated file's SHA-256 (PowerShell: `Get-FileHash roblox.yml -Algorithm SHA256`; macOS: `shasum -a 256 roblox.yml`), generator version and generation date in this document. Review and commit **both `roblox.yml` and `selene.toml`**. The committed file bytes, Git commit and recorded checksum then pin the definitions; ordinary checks must reuse that file, never regenerate it implicitly. Run `python scripts/check.py` again. Transfer that reviewed cache commit back to cloud and rerun the checks there to verify offline linting. This cache-seeding step has **not** been performed, and no checksum or passing lint result has been invented. Until then the configuration retains the default Roblox library rather than pretending a pinned cache exists.
