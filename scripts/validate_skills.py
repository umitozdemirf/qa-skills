#!/usr/bin/env python3
"""Validate skill metadata and internal references."""

from __future__ import annotations

import re
import sys
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parent.parent
SKILLS_ROOT = REPO_ROOT / "qa-skills-plugin" / "skills"
LOCAL_PATH_RE = re.compile(r"`((?:references|assets|examples|scripts|test)/[^`\n]+|examples/|scripts/|test/|assets/templates/)`")
SKILL_REF_RE = re.compile(r"`([a-z0-9-]+)`")


def parse_frontmatter(text: str) -> dict[str, str]:
    if not text.startswith("---\n"):
        raise ValueError("missing frontmatter")

    _, raw, _rest = text.split("---\n", 2)
    data: dict[str, str] = {}
    for line in raw.splitlines():
        if not line.strip():
            continue
        if ":" not in line:
            raise ValueError(f"invalid frontmatter line: {line}")
        key, value = line.split(":", 1)
        data[key.strip()] = value.strip()
    return data


def validate_skill(skill_dir: Path, known_skills: set[str]) -> list[str]:
    errors: list[str] = []
    skill_file = skill_dir / "SKILL.md"
    if not skill_file.exists():
        return [f"{skill_dir.name}: missing SKILL.md"]

    text = skill_file.read_text(encoding="utf-8")
    try:
        frontmatter = parse_frontmatter(text)
    except ValueError as exc:
        return [f"{skill_dir.name}: {exc}"]

    if frontmatter.get("name") != skill_dir.name:
        errors.append(
            f"{skill_dir.name}: frontmatter name '{frontmatter.get('name')}' does not match directory"
        )
    if not frontmatter.get("description"):
        errors.append(f"{skill_dir.name}: missing frontmatter description")

    for rel_path in LOCAL_PATH_RE.findall(text):
        target = skill_dir / rel_path
        if not target.exists():
            errors.append(f"{skill_dir.name}: referenced path does not exist: {rel_path}")

    for ref in sorted(set(SKILL_REF_RE.findall(text))):
        if ref.endswith(".md") or "/" in ref:
            continue
        if ref == skill_dir.name:
            continue
        if ref.endswith(".py") or ref.endswith(".ts") or ref.endswith(".js"):
            continue
        if ref in {"TODO", "JWT", "OAuth2", "Basic", "OpenAPI", "Swagger"}:
            continue
        looks_like_skill = (
            ref.endswith("-generator")
            or ref.endswith("-analyzer")
            or ref.endswith("-detector")
            or ref.endswith("-tester")
        )
        if looks_like_skill and ref not in known_skills:
            errors.append(f"{skill_dir.name}: references unknown skill `{ref}`")

    if "## Source Links" not in text:
        errors.append(f"{skill_dir.name}: missing '## Source Links' section")

    return errors


def main() -> int:
    skill_dirs = sorted(path for path in SKILLS_ROOT.iterdir() if path.is_dir())
    known_skills = {path.name for path in skill_dirs}
    errors: list[str] = []

    for skill_dir in skill_dirs:
        errors.extend(validate_skill(skill_dir, known_skills))

    if errors:
        print("Skill validation failed:")
        for error in errors:
            print(f"- {error}")
        return 1

    print(f"Validated {len(skill_dirs)} skills successfully.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
