#!/usr/bin/env python3
"""Synchronize shared skills across .agents repositories."""
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
PROTOCOL = ("shared-skills.txt", "AGENTS.md", "tools")
WIN_TREE = Path("/mnt/c/Users/38993/.agents")
CLAUDE_SKILLS = Path.home() / ".claude" / "skills"


def git(cwd: Path, *args: str) -> tuple[int, str, str]:
    r = subprocess.run(
        ["git", *args],
        cwd=cwd,
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="replace",
    )
    return r.returncode, r.stdout.strip(), r.stderr.strip()


def must(cwd: Path, *args: str) -> str:
    rc, out, err = git(cwd, *args)
    if rc != 0:
        raise SystemExit(err or out or f"git {' '.join(args)} failed in {cwd}")
    return out


def shared_names(cwd: Path, ref: str) -> list[str]:
    rc, out, err = git(cwd, "show", f"{ref}:shared-skills.txt")
    if rc != 0:
        return []
    return [
        line.strip()
        for line in out.splitlines()
        if line.strip() and not line.strip().startswith("#")
    ]


def ref_has_path(cwd: Path, ref: str, path: str) -> bool:
    rc, _, _ = git(cwd, "cat-file", "-e", f"{ref}:{path}")
    return rc == 0


def overlay(target_repo: Path, source_ref: str, commit_msg: str = "sync: shared set from wsl/main") -> None:
    new_names = shared_names(target_repo, source_ref)
    if not new_names:
        print(f"[{target_repo.name}] no shared skills found in {source_ref}, skip overlay")
        return
    old_names = shared_names(target_repo, "HEAD")

    # 1. Clean dropped shared skills (prevent ghost skills)
    dropped_skills = set(old_names) - set(new_names)

    # 2. Check protocol files on source_ref (only checkout what actually exists on source)
    checkout_paths = [p for p in PROTOCOL if ref_has_path(target_repo, source_ref, p)]

    # 3. Add active shared skills to checkout list
    for name in new_names:
        checkout_paths.append(f"skills/{name}")

    # 4. Remove active skills and dropped skills before checkout
    # tools/ stays in working tree during rm to avoid breaking running script
    rm_paths = [*(f"skills/{name}" for name in dropped_skills), *[p for p in checkout_paths if p != "tools"]]
    if rm_paths:
        rc, out, err = git(target_repo, "rm", "-rf", "--ignore-unmatch", "--", *rm_paths)
        if rc != 0:
            git(target_repo, "reset", "--hard", "HEAD")
            raise SystemExit(f"git rm failed in {target_repo}, reset to HEAD:\n{err or out}")

    # 5. Check out clean copies from source_ref
    rc, out, err = git(target_repo, "checkout", source_ref, "--", *checkout_paths)
    if rc != 0:
        git(target_repo, "reset", "--hard", "HEAD")
        raise SystemExit(f"overlay failed in {target_repo}, reset to HEAD:\n{err or out}")

    # 6. Check if any previously tracked protocol files were deleted in source_ref
    for old_proto in ("CONTEXT.md", "docs", "docs/adr"):
        if ref_has_path(target_repo, "HEAD", old_proto) and not ref_has_path(target_repo, source_ref, old_proto):
            git(target_repo, "rm", "-rf", "--ignore-unmatch", "--", old_proto)

    # 7. Check staged changes and commit
    _, staged, _ = git(target_repo, "diff", "--cached", "--stat")
    if staged:
        print(f"[{target_repo.name}] overlay {len(new_names)} shared skills ({len(dropped_skills)} dropped):")
        print(staged)
        must(target_repo, "commit", "-m", commit_msg)
        print(f"[{target_repo.name}] [ok] committed")
    else:
        print(f"[{target_repo.name}] [ok] already matched shared set")


def link_claude(repo: Path) -> None:
    """Claude Code only loads ~/.claude/skills; mirror skills/ there as per-skill symlinks."""
    src = repo / "skills"
    CLAUDE_SKILLS.mkdir(parents=True, exist_ok=True)
    linked = skipped = pruned = 0
    for d in sorted(p for p in src.iterdir() if (p / "SKILL.md").is_file()):
        link = CLAUDE_SKILLS / d.name
        if link.is_symlink():
            if link.resolve() == d.resolve():
                continue
            link.unlink()
        elif link.exists():
            print(f"[claude] [warn] {link} is a real path, skip")
            skipped += 1
            continue
        link.symlink_to(d, target_is_directory=True)
        linked += 1
    # Prune links into skills/ whose target is gone
    for link in CLAUDE_SKILLS.iterdir():
        if link.is_symlink() and not link.exists() and Path(link.readlink()).parent.resolve() == src.resolve():
            link.unlink()
            pruned += 1
    print(f"[claude] [ok] links {CLAUDE_SKILLS}: +{linked} -{pruned} skip {skipped}")


def check(repo: Path) -> int:
    r = subprocess.run(
        [sys.executable, str(repo / "tools" / "check.py")],
        cwd=repo,
    )
    return r.returncode


def main() -> int:
    print(f"=== .agents sync ({ROOT.name}) ===")
    _, dirty, _ = git(ROOT, "status", "--porcelain")
    if dirty:
        print(f"[{ROOT.name}] [warn] dirty working tree:\n" + dirty)
    rc, out, err = git(ROOT, "pull", "--ff-only")
    print(f"[{ROOT.name}] [ok] pull {out}" if rc == 0 else f"[{ROOT.name}] [warn] pull: {err or out}")

    remotes = git(ROOT, "remote")[1].split()

    if "wsl" in remotes:
        # Running on Windows standalone worktree
        must(ROOT, "fetch", "wsl")
        overlay(ROOT, "wsl/main")
    else:
        # Running on WSL (source worktree)
        print(f"[{ROOT.name}] [ok] source tree")
        link_claude(ROOT)
        if WIN_TREE.is_dir() and (WIN_TREE / ".git").is_dir() and WIN_TREE.resolve() != ROOT.resolve():
            print(f"=== syncing Windows tree at {WIN_TREE} ===")
            _, win_dirty, _ = git(WIN_TREE, "status", "--porcelain")
            if win_dirty:
                print(f"[{WIN_TREE.name}] [warn] dirty working tree:\n" + win_dirty)
            # Fetch local WSL tree into Windows git
            must(WIN_TREE, "fetch", str(ROOT), "HEAD")
            overlay(WIN_TREE, "FETCH_HEAD", commit_msg="sync: shared set from wsl")
            rc_win = check(WIN_TREE)
            if rc_win != 0:
                return rc_win

    print(f"[{ROOT.name}] check...")
    rc = check(ROOT)
    if rc != 0:
        return rc
    print("=== done ===")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
