#!/usr/bin/env python3
"""Pull this tree. On Windows, replace the shared set with wsl/main."""
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
PROTOCOL = ("shared-skills.txt", "AGENTS.md", "CONTEXT.md", "docs/adr", "tools")


def git(*args: str) -> tuple[int, str, str]:
    r = subprocess.run(
        ["git", *args],
        cwd=ROOT,
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="replace",
    )
    return r.returncode, r.stdout.strip(), r.stderr.strip()


def must(*args: str) -> str:
    rc, out, err = git(*args)
    if rc != 0:
        raise SystemExit(err or out or f"git {' '.join(args)} failed")
    return out


def shared_names(ref: str) -> list[str]:
    rc, out, err = git("show", f"{ref}:shared-skills.txt")
    if rc != 0:
        raise SystemExit(err or f"no shared-skills.txt on {ref}")
    return [
        line.strip()
        for line in out.splitlines()
        if line.strip() and not line.strip().startswith("#")
    ]


def overlay(names: list[str]) -> None:
    paths = [*PROTOCOL, *(f"skills/{name}" for name in names)]
    # tools/ stays: this file may be the running script. skills/ is rm'd so
    # unreadable working-tree files (broken ACLs) cannot block checkout.
    rm_paths = [p for p in paths if p != "tools"]
    rc, out, err = git("rm", "-rf", "--ignore-unmatch", "--", *rm_paths)
    if rc != 0:
        git("reset", "--hard", "HEAD")
        raise SystemExit(f"git rm failed, reset to HEAD:\n{err or out}")
    rc, out, err = git("checkout", "wsl/main", "--", *paths)
    if rc != 0:
        git("reset", "--hard", "HEAD")
        raise SystemExit(f"overlay failed, reset to HEAD:\n{err or out}")


def check() -> int:
    r = subprocess.run(
        [sys.executable, str(ROOT / "tools" / "check.py")],
        cwd=ROOT,
    )
    return r.returncode


def main() -> int:
    print("=== .agents sync ===")
    _, dirty, _ = git("status", "--porcelain")
    if dirty:
        print("[warn] dirty working tree:\n" + dirty)
    rc, out, err = git("pull", "--ff-only")
    print(f"[ok] pull {out}" if rc == 0 else f"[warn] pull: {err or out}")

    remotes = git("remote")[1].split()
    if "wsl" not in remotes:
        print("[ok] no wsl remote; source tree, skip overlay")
    else:
        must("fetch", "wsl")
        names = shared_names("wsl/main")
        print(f"overlay {len(names)} shared skills from wsl/main")
        overlay(names)
        _, staged, _ = git("diff", "--cached", "--stat")
        if staged:
            print(staged)
            must("commit", "-m", "sync: shared set from wsl/main")
            print("[ok] committed")
        else:
            print("[ok] already matched wsl/main shared set")

    print("check...")
    rc = check()
    if rc != 0:
        return rc
    print("=== done ===")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
