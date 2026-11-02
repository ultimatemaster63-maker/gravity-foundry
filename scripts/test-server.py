"""Execute actual server logic against explicit simulated service boundaries."""
from pathlib import Path
import os
import subprocess

root = Path(__file__).resolve().parents[1]
source = (root / "src/server/Main.server.luau").read_text()
source = source.replace('require(shared.Progression)', 'Progression')
source = source.replace('require(shared.CombatRules)', 'CombatRules')
source = source.replace('require(shared.Orbit)', 'Orbit')
source = source.replace('require(shared.Gear)', '{build=function() error("Equipment is outside this server fixture") end}')
source = source.replace('require(script.Parent.Arena).build()', 'arena')
# Embed modules to share the mocked engine globals, leaving their logic intact.
def module(path):
    return "(function()\n" + (root / path).read_text() + "\nend)()\n"
program = (root / "tests/server_mock.luau").read_text() + "\n"
for name, path in [("Progression", "src/shared/Progression.luau"), ("CombatRules", "src/shared/CombatRules.luau"), ("Orbit", "src/shared/Orbit.luau"), ("Arena", "src/server/Arena.luau")]:
    program += f"local {name} = " + module(path)
program += "local arena = Arena.build()\nlocal function runServer()\n" + source + "\nend\nrunServer()\n"
program += (root / "tests/server_assertions.luau").read_text()
target = root / ".tools/server-test.luau"
target.parent.mkdir(exist_ok=True)
target.write_text(program)
result = subprocess.run([os.environ.get("LUAU", "luau"), str(target)], cwd=root)
raise SystemExit(result.returncode)
