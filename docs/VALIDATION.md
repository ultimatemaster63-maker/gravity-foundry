# Validation evidence

## Passing automated checks

`PATH="$PWD/.tools/bin:$PATH" python3 scripts/check.py --extended` completed successfully:

- StyLua 2.3.1 formatting for source and tests.
- Selene 0.29.0: **0 errors, 0 warnings, 0 parse errors**, using the checked-in, checksum-verified Roblox definition cache.
- Rojo 7.6.1 place build and sourcemap.
- Official Luau 0.744 compiler on every gameplay source file.
- **24** pure gameplay-rule assertions: purchases, budget, replay scaling, boss phase floors and warning geometry.
- **255** simulated server-flow assertions: actual arena construction and server logic, blocked/invalid capture, launching, destruction, all gates, shield/exposed guardian, victory, retained upgrades, unanimous replay consent, death and projectile/disconnect cleanup.
- Supplemental luau-lsp 1.70.1 strict Roblox type analysis using the project's sourcemap and matching Roblox definitions: no type errors. Its warning about unavailable watched-file registration is a CLI capability message, not a source diagnostic.
- Saved cache generator executed successfully and reproduced `roblox.yml` byte-for-byte.

The server fixture supplies fake services, vectors, simple transforms, predetermined ray/sphere hits, a deterministic clock and event signals. It executes the actual Arena and Main server source. **It is not a Roblox engine emulator**: collision geometry, visuals, replication, sounds, camera and client UI are not validated by it. The 24 rule assertions execute the same pure modules used by the server, not copies of their logic.

## Reproduce

Base tools remain pinned in `rokit.toml`. Base checks require no Roblox API network fetch:

```sh
rokit install
python scripts/check.py
```

For the full suite on Linux x86_64:

```sh
python3 scripts/install-cloud-tools.py
python3 scripts/install-validation-tools.py
export PATH="$PWD/.tools/bin:$PATH"
python3 scripts/check.py --extended
```

The supplemental installer verifies checksums before installing Luau 0.744, luau-lsp 1.70.1 and its Roblox definitions. It does not alter the original Rojo/Selene/StyLua pins. CI uses this same extended command. A local pass does not claim a GitHub Actions result.

On other platforms, install the corresponding official Luau 0.744 and luau-lsp 1.70.1 release binaries on PATH and place the matching `scripts/globalTypes.RobloxScriptSecurity.d.luau` from the luau-lsp 1.70.1 tag at `.tools/roblox-types.luau`. Then run `python scripts/check.py --extended`. The checked-in tests are independent of Windows/macOS; the provided binary installer is Linux-specific.

## Backup and boundaries

Before substantial edits, the working `c8f710b28ff6a1291c500ec03b1ff742f85c04fc` prototype was backed up outside the checkout:

- `/workspace/gravity-backups/c8f710b/source.tar` — SHA-256 `b840dddca2fef4846e3fe3e41538884567b01941f732a660e5840ec403977345`
- `/workspace/gravity-backups/c8f710b/GravityFoundry.rbxlx` — SHA-256 `e2f09203696787d9afeeb5823a788793fd8812f0adf16adfeb4d95b4b1bc140e`

The original commit remains in Git history. Rojo project mappings and `rokit.toml` are unchanged. Bundled vault files are unchanged. No Titan files, credentials or places were used.

**Studio personally verified: none for this revision.** No computer-control/Studio connector was available, and no Studio process was running in the attached Linux workspace. User feedback establishes that the previous prototype ran, not that this update has passed a Studio playthrough. The remaining acceptance route is in PLAYTEST.md.
