"""Run from any directory with pinned Rojo, Selene and StyLua on PATH."""
from pathlib import Path
import subprocess

root = Path(__file__).resolve().parents[1]
(root / "build").mkdir(exist_ok=True)
failed = False
for command in [
    ["stylua", "--check", "src"],
    ["selene", "src"],
    ["rojo", "build", "default.project.json", "-o", "build/GravityFoundry.rbxlx"],
    ["rojo", "sourcemap", "default.project.json", "-o", "build/sourcemap.json"],
]:
    print("+ " + " ".join(command), flush=True)
    result = subprocess.run(command, cwd=root)
    failed = failed or result.returncode != 0
raise SystemExit(1 if failed else 0)
