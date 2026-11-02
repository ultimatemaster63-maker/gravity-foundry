# Gravity Foundry

Pull visible scrap into orbit, launch it through abandoned foundry machinery, forge increasingly strange gravity equipment, and dismantle the reactor Warden.

The first-version route includes three distinct areas, destructible machinery/barriers, telegraphed drone attacks, a three-phase guardian with throwable couplings, five visibly different gear stages, a Forge preview, victory and cooperative replay consent. Session upgrades survive death and in-game replay. Cross-server saving is not implemented.

- `src/server`: authored runtime arena and authoritative combat/progression.
- `src/client`: controls, responsive HUD/Forge, visual and audio feedback.
- `src/shared`: progression rules, gear geometry, orbit pose and damage rules.
- `default.project.json`: existing code-only Rojo mappings; no Titan connection.
- `docs/PLAYTEST.md`: exact controls and full completion route.
- `docs/VALIDATION.md`: automated evidence and what still needs Studio testing.

## Checks

```sh
rokit install
python scripts/check.py
```

Rojo 7.6.1, Selene 0.29.0 and StyLua 2.3.1 remain pinned. Selene now reads a committed, checksum-verified API cache; no API download is required for linting. For supplemental compiler/type/server-flow tests, see VALIDATION.md and run `python scripts/check.py --extended` after installing those tools.

Open and sync using [the Studio guide](docs/STUDIO.md). The arena is generated when Play begins. Automated checks pass, but no agent-operated Studio connection was available for this revision; engine acceptance remains outstanding. No experience was published.
