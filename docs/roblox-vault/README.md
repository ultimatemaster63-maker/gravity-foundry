# Roblox development vault location

The vault is bundled at `../../v2-vault-main/v2-vault-main/LihFolk Vault V2` relative to this directory (repository root: `v2-vault-main/v2-vault-main/LihFolk Vault V2`). This directory is a pointer, not a duplicate vault.

Search its `INDEX_SLIM.md` or use `_tools/vault.py`; read only relevant note summaries and sections. Do not execute generation/setup tools blindly or modify bundled notes.

Guidance used for this revision:

- **Server Authority and Validation** — full Common mistakes and Checklist: validate values as well as types, server-owned rewards/damage, no yield between check and spend, cooldowns and ownership.
- **Projectiles and Ballistics** — swept casts instead of Touched for fast shots.
- **Boss Fight Design Patterns** — committed attack markers, punish windows and phase floors.
- **Genre Playbook - Combat and RPG** — distinct silhouettes and visible DPS upgrades per zone.
- **Progression and Pacing Design** — milestone upgrades and first-run/replay budget checks.

The engine and platform claims in notes are references to verify, not authority to invent asset IDs or bypass validation.
