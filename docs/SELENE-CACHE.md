# Reproducible Selene Roblox definitions

Selene remains **0.29.0**. `selene.toml` selects `std = "roblox"` and `roblox-std-source = "pinned"`; the full generated `roblox.yml` is committed. Ordinary checks verify its SHA-256 and read it offline. No lint rules or TLS checks were disabled.

The original downloader used `ureq::get` against a hard-coded URL and attempted direct DNS in this proxy-only environment. A verified curl download could fetch the API, but the binary had no offline-input flag. To resolve this, a maintenance generator builds the exact Selene 0.29.0 source with its locked Cargo dependencies. Its only code adaptation replaces the HTTP input expression with reading `GRAVITY_API_SNAPSHOT` through `serde_json::from_reader`. All upstream Roblox/Luau definitions, enum/class conversion and serialization logic remain unchanged. This maintenance binary is **not** the linter used by checks; checks use the original pinned release binary.

Inputs, source URLs and SHA-256 checksums are recorded in `tools/selene-cache.json`:

- API revision: `MaximumADHD/Roblox-Client-Tracker@84e5cc5fd8405e75c9f8c70116e450aef327ff56`.
- Generator: Selene 0.29.0 source archive, SHA-256 verified before extraction.
- Toolchain for maintenance generation: Rust 1.85.1, `cargo build --locked`.
- Generated cache SHA-256: `514ca076f91e5d66838ebc4b94b2a1be245341b434a768876a5b49dee5dd2bcb`.

For byte reproducibility, only the generated comment timestamp and `last_updated` metadata are normalized. `last_updated: 0` does not weaken validation: pinned mode uses the local file and does not implement the floating cache's expiry/refresh path.

`python scripts/generate-selene-cache.py` requires Rust 1.85.1 via rustup, Cargo and curl. It downloads both inputs with TLS and checksum verification, builds the adapted input loader, generates definitions, normalizes timestamp metadata, and refuses to replace the cache unless the output matches the reviewed checksum. This exact script was executed and the output matched. Normal setup does not need Rust or this maintenance step.

Updating definitions is a deliberate maintenance change: review new source/API revisions, generated diff and checksums together; do not simply change a checksum to accept unexplained differences. Preserve the generator's upstream transforms and license. Selene source is MPL-2.0; source and its license remain available at the pinned upstream tag. The generated cache contains API metadata, not a redistributed tool binary.
