"""Optional Linux x86_64 validation tools; leaves rokit.toml's tools unchanged."""
from pathlib import Path
import hashlib
import platform
import subprocess
import tempfile
import zipfile

if platform.system() != "Linux" or platform.machine() != "x86_64":
    raise SystemExit("This installer is Linux x86_64 only; see docs/VALIDATION.md for local tools.")
root = Path(__file__).resolve().parents[1]
bin_dir = root / ".tools/bin"
bin_dir.mkdir(parents=True, exist_ok=True)
artifacts = [
    ("https://github.com/luau-lang/luau/releases/download/0.744/luau-ubuntu.zip", "6506f0852c623aaffcb28494aac16c26dc04a269ea0e16cc0aafc8c8ac79f3ec", ["luau", "luau-compile"]),
    ("https://github.com/JohnnyMorganz/luau-lsp/releases/download/1.70.1/luau-lsp-linux-x86_64.zip", "1a2ea1ae4f98f8946cefd970a4b54853e11ab4775e6932faa7f60cf920346567", ["luau-lsp"]),
    ("https://raw.githubusercontent.com/JohnnyMorganz/luau-lsp/1.70.1/scripts/globalTypes.RobloxScriptSecurity.d.luau", "2857efa8245485f8c25c19c018ee1ef9b46afab4efd2ea70fc3257cd3faf7080", []),
]
with tempfile.TemporaryDirectory() as tmp:
    for url, expected, members in artifacts:
        path = Path(tmp) / "download"
        subprocess.run(["curl", "-fsSL", "--retry", "2", url, "-o", str(path)], check=True)
        if hashlib.sha256(path.read_bytes()).hexdigest() != expected:
            raise SystemExit("Validation-tool checksum mismatch: " + url)
        if members:
            with zipfile.ZipFile(path) as bundle:
                for member in members:
                    executable = bin_dir / member
                    executable.write_bytes(bundle.read(member))
                    executable.chmod(0o755)
        else:
            (root / ".tools/roblox-types.luau").write_bytes(path.read_bytes())
print("Installed Luau 0.744, luau-lsp 1.70.1 and matching Roblox definitions.")
