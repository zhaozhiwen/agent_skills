#!/usr/bin/env python3
# /// script
# dependencies = ["pyyaml"]
# ///
"""Validate every skills/<name>/SKILL.md against the Agent Skills spec
(https://agentskills.io/specification) plus this repo's rules. Exit 1 on any error."""
import re
import sys
from pathlib import Path

try:
    import yaml
except ImportError:
    sys.exit("needs PyYAML: pip install pyyaml  (or: uv run scripts/validate.py)")

SPEC_FIELDS = {"name", "description", "license", "compatibility", "metadata", "allowed-tools"}
NAME_RE = re.compile(r"[a-z0-9]+(-[a-z0-9]+)*")


def check(skill_dir):
    errors, warnings = [], []
    path = skill_dir / "SKILL.md"
    if not path.is_file():
        return ["missing SKILL.md"], warnings
    text = path.read_text(encoding="utf-8")
    parts = text.split("---", 2)
    if not text.startswith("---") or len(parts) < 3:
        return ["no YAML frontmatter between --- lines"], warnings
    try:
        fm = yaml.safe_load(parts[1]) or {}
    except yaml.YAMLError as e:
        return [f"frontmatter is not valid YAML: {e}"], warnings
    body = parts[2]

    name = fm.get("name")
    if not isinstance(name, str) or not NAME_RE.fullmatch(name) or len(name) > 64:
        errors.append(f"name {name!r}: need 1-64 chars of [a-z0-9-], no edge/double hyphens")
    elif name != skill_dir.name:
        errors.append(f"name {name!r} != directory {skill_dir.name!r}")

    desc = fm.get("description")
    if not isinstance(desc, str) or not 1 <= len(desc) <= 1024:
        errors.append("description: need 1-1024 chars")

    compat = fm.get("compatibility")
    if compat is not None and not (isinstance(compat, str) and 1 <= len(compat) <= 500):
        errors.append("compatibility: need 1-500 chars")

    meta = fm.get("metadata", {})
    if not isinstance(meta, dict) or not all(isinstance(v, str) for v in meta.values()):
        errors.append("metadata: must map strings to strings (quote versions)")

    # Repo rules
    if fm.get("license") != "MIT":
        errors.append("license: must be MIT (repo rule)")
    if isinstance(meta, dict):
        if not meta.get("author"):
            errors.append("metadata.author: required (repo rule)")
        elif meta["author"] != "zhaozhiwen":
            # Third-party skill: provenance and the original license must travel with it
            if not meta.get("upstream"):
                errors.append("metadata.upstream: required when author is not zhaozhiwen (repo rule)")
            if not (skill_dir / "LICENSE").is_file():
                errors.append("LICENSE: third-party skill must carry the upstream license file (repo rule)")

    extra = set(fm) - SPEC_FIELDS
    if extra:
        warnings.append(f"non-spec frontmatter fields (client-specific): {sorted(extra)}")
    lines = body.count("\n")
    if lines > 500:
        warnings.append(f"body is {lines} lines; spec recommends < 500")
    return errors, warnings


def main():
    root = Path(__file__).resolve().parent.parent / "skills"
    skill_dirs = sorted(d for d in root.iterdir() if d.is_dir())
    failed = False
    for d in skill_dirs:
        errors, warnings = check(d)
        status = "FAIL" if errors else "ok  "
        print(f"{status} {d.name}")
        for e in errors:
            print(f"     error: {e}", file=sys.stderr)
        for w in warnings:
            print(f"     warn:  {w}", file=sys.stderr)
        failed |= bool(errors)
    sys.exit(1 if failed else 0)


if __name__ == "__main__":
    main()
