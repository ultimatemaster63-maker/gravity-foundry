"""Base checks, plus --extended for compiler, server tests and Roblox type analysis."""
from pathlib import Path
import argparse
import hashlib
import json
import os
import subprocess
import sys

parser = argparse.ArgumentParser()
parser.add_argument("--extended", action="store_true")
args = parser.parse_args()
root = Path(__file__).resolve().parents[1]
(root / "build").mkdir(exist_ok=True)
manifest = json.loads((root / "tools/selene-cache.json").read_text())
if hashlib.sha256((root / "roblox.yml").read_bytes()).hexdigest() != manifest["generated_sha256"]:
    raise SystemExit("Pinned Roblox definitions failed checksum verification")
commands = [
    ["stylua", "--check", "src", "tests"],
    ["selene", "src"],
    ["rojo", "build", "default.project.json", "-o", "build/GravityFoundry.rbxlx"],
    ["rojo", "sourcemap", "default.project.json", "-o", "build/sourcemap.json"],
]
if args.extended:
    commands += [
        ["luau-compile", "--null", *[str(p.relative_to(root)) for p in sorted((root / "src").rglob("*.luau"))]],
        [os.environ.get("LUAU", "luau"), "tests/rules.luau"],
        [sys.executable, "scripts/test-server.py"],
        ["luau-lsp", "analyze", "--platform", "roblox", "--sourcemap", "build/sourcemap.json", "--definitions", "@roblox=.tools/roblox-types.luau", "src"],
    ]
failed = False
for command in commands:
    print("+ " + " ".join(command), flush=True)
    try:
        result = subprocess.run(command, cwd=root)
        failed = failed or result.returncode != 0
    except FileNotFoundError as error:
        print("Missing required tool:", error.filename, file=sys.stderr)
        failed = True
if not args.extended:
    print("Extended compiler/type/server tests not requested; use --extended after installing validation tools.")
raise SystemExit(1 if failed else 0)
