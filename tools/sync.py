#!/usr/bin/env python3
"""Automated synchronization tool for .agents repository."""
import os
from pathlib import Path
import re
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
SKILLS_DIR = ROOT / "skills"
SHARED_FILE = ROOT / "shared-skills.txt"
SHARED_COMMIT_RE = re.compile(r"^shared\(([^)]+)\):\s*(.+)$")


def run_cmd(cmd: list[str], cwd=ROOT) -> tuple[int, str, str]:
    res = subprocess.run(
        cmd,
        cwd=cwd,
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="replace",
    )
    return res.returncode, res.stdout.strip(), res.stderr.strip()


def get_shared_skills() -> set[str]:
    if not SHARED_FILE.is_file():
        return set()
    return {
        line.strip()
        for line in SHARED_FILE.read_text(encoding="utf-8").splitlines()
        if line.strip() and not line.strip().startswith("#")
    }


def sync():
    shared_skills = get_shared_skills()
    print("=== .agents Sync Tool ===")

    # 1. Check working tree status
    rc, stdout, _ = run_cmd(["git", "status", "--porcelain"])
    if stdout:
        print("[warn] Working tree has uncommitted modifications:")
        for line in stdout.splitlines():
            print(f"       {line}")
    else:
        print("[ok] Working tree is clean.")

    # 2. git pull --ff-only
    print("\n[1/3] Pulling latest from origin...")
    rc, stdout, stderr = run_cmd(["git", "pull", "--ff-only"])
    if rc != 0:
        print(f"[warn] git pull failed (will continue): {stderr or stdout}")
    else:
        print(f"[ok] {stdout}")

    # 3. Windows / WSL remote check
    rc, remotes_out, _ = run_cmd(["git", "remote"])
    remotes = remotes_out.split()
    if "wsl" in remotes:
        print("\n[2/3] Fetching remote 'wsl'...")
        rc, _, stderr = run_cmd(["git", "fetch", "wsl"])
        if rc != 0:
            print(f"[warn] git fetch wsl failed: {stderr}")

        # List candidate commits between current branch and wsl/main
        rc, commits_out, _ = run_cmd(
            ["git", "log", "--reverse", "--format=%H %s", "main..wsl/main"]
        )
        candidates = [c.strip() for c in commits_out.splitlines() if c.strip()]

        applied = []
        skipped = []
        conflicts = []

        for item in candidates:
            parts = item.split(" ", 1)
            commit_hash = parts[0]
            commit_msg = parts[1] if len(parts) > 1 else ""

            m = SHARED_COMMIT_RE.match(commit_msg)
            if not m:
                skipped.append((commit_hash, commit_msg, "non-shared commit format"))
                continue

            skill_name = m.group(1).strip()
            if skill_name not in shared_skills:
                skipped.append((commit_hash, commit_msg, f"'{skill_name}' not in shared-skills.txt"))
                continue

            # Verify paths changed in this commit
            rc, files_out, _ = run_cmd(["git", "show", "--name-only", "--format=", commit_hash])
            changed_files = [f.strip() for f in files_out.splitlines() if f.strip()]

            # Allowed files: skills/<skill_name>/**, shared-skills.txt, tools/**, AGENTS.md
            invalid_files = []
            for f in changed_files:
                f_norm = f.replace("\\", "/")
                if f_norm.startswith(f"skills/{skill_name}/"):
                    continue
                if f_norm in ("shared-skills.txt", "AGENTS.md") or f_norm.startswith("tools/"):
                    continue
                invalid_files.append(f)

            if invalid_files:
                skipped.append(
                    (commit_hash, commit_msg, f"touches non-shared paths: {invalid_files}")
                )
                continue

            # Attempt cherry-pick
            print(f"  -> Cherry-picking: {commit_msg} ({commit_hash[:7]})")
            rc, cp_out, cp_err = run_cmd(["git", "cherry-pick", commit_hash])
            if rc == 0:
                applied.append((commit_hash, commit_msg))
            else:
                combined_err = (cp_err + " " + cp_out).lower()
                if "nothing to commit" in combined_err or "already applied" in combined_err or "previous cherry-pick is now empty" in combined_err:
                    run_cmd(["git", "cherry-pick", "--skip"])
                    skipped.append((commit_hash, commit_msg, "already applied / empty"))
                else:
                    # Conflict
                    run_cmd(["git", "cherry-pick", "--abort"])
                    conflicts.append((commit_hash, commit_msg, cp_err or cp_out))
                    print(f"[conflict] Cherry-pick conflict on {commit_hash[:7]}: {commit_msg}")
                    break

        print("\n--- Cherry-pick Summary ---")
        print(f"Applied: {len(applied)}")
        for ch, cm in applied:
            print(f"  + {ch[:7]} {cm}")
        print(f"Skipped: {len(skipped)}")
        for ch, cm, reason in skipped:
            print(f"  - {ch[:7]} {cm} ({reason})")
        if conflicts:
            print(f"Conflicts: {len(conflicts)} (aborted)")
            for ch, cm, reason in conflicts:
                print(f"  ! {ch[:7]} {cm} -> {reason}")
    else:
        print("\n[2/3] No 'wsl' remote found, skipping cross-tree cherry-pick.")

    # 4. Run validation check
    print("\n[3/3] Running tools/check.py...")
    rc, stdout, stderr = run_cmd([sys.executable, str(ROOT / "tools" / "check.py")])
    if rc == 0:
        print(f"[ok] {stdout}")
    else:
        print(f"[err] Validation check failed:\n{stderr or stdout}")
        return 1

    print("\n=== Sync Completed Successfully ===")
    return 0


if __name__ == "__main__":
    sys.exit(sync())
