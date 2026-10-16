#!/usr/bin/env python3
"""Copy the roblox-game-init template into a repo, filling in the game's name.

Usage:
    python3 scaffold.py --dest <repo> --name "<Game Name>" --slug <game-slug> [--simple] [--add-missing] [--dry-run]

Never overwrites: if any target file already exists, it lists every conflict and exits 1
without writing anything, so a migration keeps the developer's code. With --add-missing it
writes only the missing files and keeps every existing one (used to go from Simple to Full).
"""

import argparse
import shutil
import sys
from pathlib import Path

TEMPLATE = Path(__file__).resolve().parent.parent / "assets" / "template"

# Files stored under a different name in the template (dotfiles get lost when skills are packaged).
RENAMES = {"_gitignore": ".gitignore", "_claude": ".claude"}

# Skipped by --simple: the agent team and its batch briefs (Full studio only).
SIMPLE_SKIP = {"_claude", "Batches"}

TEXT_SUFFIXES = {".luau", ".lua", ".json", ".toml", ".md", ""}


def plan(dest: Path, simple: bool) -> list[tuple[Path, Path]]:
    pairs = []
    for src in sorted(TEMPLATE.rglob("*")):
        if src.is_dir():
            continue
        if simple and SIMPLE_SKIP.intersection(src.relative_to(TEMPLATE).parts):
            continue
        rel = Path(*(RENAMES.get(part, part) for part in src.relative_to(TEMPLATE).parts))
        pairs.append((src, dest / rel))
    return pairs


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--dest", required=True, type=Path, help="repo folder (created if missing)")
    parser.add_argument("--name", required=True, help='display name, e.g. "Coin Tycoon"')
    parser.add_argument("--slug", required=True, help="kebab-case id, e.g. coin-tycoon")
    parser.add_argument("--simple", action="store_true", help="no agent team (.claude/agents, docs/Batches)")
    parser.add_argument(
        "--add-missing",
        action="store_true",
        help="write only files that don't exist yet, skip the rest (e.g. Simple → Full studio)",
    )
    parser.add_argument("--dry-run", action="store_true", help="list what would be written")
    args = parser.parse_args()

    dest: Path = args.dest.expanduser().resolve()
    pairs = plan(dest, args.simple)

    conflicts = [target for _, target in pairs if target.exists()]
    if args.add_missing:
        for target in conflicts:
            print(f"kept   {target.relative_to(dest)} (exists)")
        pairs = [(src, target) for src, target in pairs if not target.exists()]
        conflicts = []
    if conflicts:
        print("Refusing to overwrite these existing files (nothing was written):")
        for target in conflicts:
            print(f"  {target.relative_to(dest)}")
        print("Move or merge them by hand, or scaffold into an empty folder.")
        return 1

    for src, target in pairs:
        rel = target.relative_to(dest)
        if args.dry_run:
            print(f"would write {rel}")
            continue
        target.parent.mkdir(parents=True, exist_ok=True)
        if src.suffix in TEXT_SUFFIXES:
            text = src.read_text(encoding="utf-8")
            text = text.replace("{{GAME_NAME}}", args.name).replace("{{GAME_SLUG}}", args.slug)
            target.write_text(text, encoding="utf-8")
        else:
            shutil.copy2(src, target)
        print(f"wrote {rel}")

    if not args.dry_run:
        print(f"\nScaffolded {args.name} into {dest}")
        print("Next: fill every <!-- FILL --> in CLAUDE.md, then `stylua src` from the repo root.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
