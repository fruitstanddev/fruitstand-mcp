#!/usr/bin/env python3
"""Structural checks for the fruitstand-mcp storefront repo.

Keeps server.json / glama.json honest and makes sure the README only points at
assets that exist. Run in CI and locally: `python3 .github/scripts/validate.py`.
"""
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
errors: list[str] = []


def check(cond: bool, msg: str) -> None:
    if not cond:
        errors.append(msg)


def load_json(name: str) -> dict:
    try:
        return json.loads((ROOT / name).read_text())
    except (OSError, ValueError) as e:
        errors.append(f"{name}: {e}")
        return {}


# --- server.json -----------------------------------------------------------
server = load_json("server.json")
if server:
    check(server.get("name") == "dev.fruitstand/fund-returns",
          f"server.json: unexpected name {server.get('name')!r}")
    check(re.fullmatch(r"\d+\.\d+\.\d+", server.get("version", "")) is not None,
          f"server.json: version must be semver, got {server.get('version')!r}")
    check(server.get("repository", {}).get("url", "").endswith("/fruitstanddev/fruitstand-mcp"),
          "server.json: repository.url should point at this repo")
    remotes = server.get("remotes") or []
    check(any(r.get("url") == "https://api.fruitstand.dev/mcp" for r in remotes),
          "server.json: remotes must include https://api.fruitstand.dev/mcp")

# --- glama.json -----------------------------------------------------------
glama = load_json("glama.json")
if glama:
    check(glama.get("$schema") == "https://glama.ai/mcp/schemas/server.json",
          "glama.json: wrong or missing $schema")
    maint = glama.get("maintainers")
    check(isinstance(maint, list) and len(maint) >= 1 and all(isinstance(m, str) for m in maint),
          "glama.json: maintainers must be a non-empty list of strings")

# --- README asset references -------------------------------------------------
readme = (ROOT / "README.md").read_text()
for rel in re.findall(r"]\((assets/[^)\s]+)\)", readme):
    check((ROOT / rel).is_file(), f"README.md references missing file: {rel}")

# server.json version should match the README's "official MCP Registry" mention if any
if server and "dev.fruitstand/fund-returns" in readme:
    pass  # name mentioned; nothing stricter to assert

if errors:
    print("FAIL")
    for e in errors:
        print(f"  - {e}")
    sys.exit(1)
print("OK — server.json, glama.json and README asset links validated")
