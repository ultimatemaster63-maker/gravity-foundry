"""Install pinned Linux x86_64 tools without changing system packages.
Archives are obtained from official releases over verified HTTPS and SHA-256 checked.
Hashes were recorded from those release downloads during onboarding.
"""
from pathlib import Path
import hashlib
import platform
import subprocess
import tempfile
import zipfile

if platform.system() != "Linux" or platform.machine() != "x86_64":
    raise SystemExit("Use rokit install on your computer; this installer is Linux x86_64 only.")
root = Path(__file__).resolve().parents[1]
bin_dir = root / ".tools/bin"
bin_dir.mkdir(parents=True, exist_ok=True)
releases = [
    ("rojo", "rojo-rbx/rojo", "v7.6.1", "rojo-7.6.1-linux-x86_64.zip", "a9542a713036897fdbd0173e7a105ea409658333133c949025fcb6f1a7ca909d"),
    ("selene", "Kampfkarren/selene", "0.29.0", "selene-0.29.0-linux.zip", "e2510f91826373dafb77e741b2df826ecfe4b94dfb20f8939809773ee4d53b6d"),
    ("stylua", "JohnnyMorganz/StyLua", "v2.3.1", "stylua-linux-x86_64.zip", "f0cfea40b3d72223497fa1650061f866e0d19a93a871aae22d3849f1bc9c2722"),
]
with tempfile.TemporaryDirectory() as tmp:
    for name, repo, tag, asset, digest in releases:
        archive = Path(tmp) / asset
        subprocess.run(["curl", "--fail", "--silent", "--show-error", "--location", "--retry", "2",
                        f"https://github.com/{repo}/releases/download/{tag}/{asset}", "-o", str(archive)], check=True)
        if hashlib.sha256(archive.read_bytes()).hexdigest() != digest:
            raise SystemExit(f"Checksum mismatch for {asset}; refusing installation")
        with zipfile.ZipFile(archive) as bundle:
            target = bin_dir / name
            target.write_bytes(bundle.read(name))
            target.chmod(0o755)
        subprocess.run([str(target), "--version"], check=True)
print(f"Add {bin_dir} to PATH for this shell.")
