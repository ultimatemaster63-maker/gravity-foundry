"""Maintenance-only cache generation. Requires cargo/rustup with Rust 1.85.1.
Normal checks read committed roblox.yml and need no network or Rust compiler.
Only the upstream generator's API input is adapted; its transforms are unchanged.
"""
from pathlib import Path
import hashlib
import json
import os
import re
import subprocess
import tempfile
import zipfile

root = Path(__file__).resolve().parents[1]
manifest = json.loads((root / "tools/selene-cache.json").read_text())
with tempfile.TemporaryDirectory(prefix="foundry-selene-") as tmp:
    work = Path(tmp)
    for kind, name in [("source", "source.zip"), ("api", "API-Dump.json")]:
        path = work / name
        subprocess.run(["curl", "-fsSL", manifest[kind + "_url"], "-o", str(path)], check=True)
        if hashlib.sha256(path.read_bytes()).hexdigest() != manifest[kind + "_sha256"]:
            raise SystemExit(f"Checksum mismatch: {name}")
    with zipfile.ZipFile(work / "source.zip") as archive:
        archive.extractall(work)
    source = work / "selene-0.29.0"
    generator = source / "selene/src/roblox/generate_std.rs"
    text = generator.read_text()
    start = text.index("        let api: ApiDump = ureq::get(API_DUMP)")
    end = text.index("\n\n        self.write_class", start)
    text = text[:start] + '''        let api: ApiDump = serde_json::from_reader(std::fs::File::open(std::env::var("GRAVITY_API_SNAPSHOT")?)?)
            .context("error when parsing pinned local API dump")?;''' + text[end:]
    generator.write_text(text)
    subprocess.run(["cargo", "+" + manifest["rust_version"], "build", "--locked", "-p", "selene", "-j", "4"], cwd=source, check=True)
    executable = source / "target/debug" / ("selene.exe" if os.name == "nt" else "selene")
    subprocess.run([str(executable), "generate-roblox-std"], cwd=work,
                   env={**os.environ, "GRAVITY_API_SNAPSHOT": str(work / "API-Dump.json")}, check=True)
    text = (work / "roblox.yml").read_text()
    text = re.sub(r"^# This file was @generated.*$", "# Generated with Selene 0.29.0 from API snapshot " + manifest["api_commit"] + "; see docs/SELENE-CACHE.md.", text, flags=re.M)
    text = re.sub(r"^last_updated: .*$", "last_updated: 0", text, flags=re.M)
    data = text.encode()
    if hashlib.sha256(data).hexdigest() != manifest["generated_sha256"]:
        raise SystemExit("Generated definitions differ from the reviewed cache; do not replace automatically.")
    (root / "roblox.yml").write_bytes(data)
    print("Verified and regenerated the pinned Selene API cache.")
