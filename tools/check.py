#!/usr/bin/env python3
"""Read-only validation for the local .agents repository."""
from pathlib import Path
import re, sys

ROOT = Path(__file__).resolve().parents[1]
SKILLS = ROOT / "skills"
NAME_RE = re.compile(r"^[a-z0-9]+(?:-[a-z0-9]+)*$")

def fail(msg):
    print(msg, file=sys.stderr)
    return 1

def main():
    errors=[]
    shared = [x.strip() for x in (ROOT/"shared-skills.txt").read_text(encoding="utf-8").splitlines() if x.strip() and not x.startswith("#")]
    if len(shared) != len(set(shared)): errors.append("shared-skills.txt contains duplicates")
    for d in sorted(SKILLS.iterdir()):
        if not d.is_dir() or d.name.startswith("."): continue
        md=d/"SKILL.md"
        if not md.is_file(): errors.append(f"{d}: missing SKILL.md"); continue
        lines=md.read_text(encoding="utf-8").splitlines()
        if not lines or lines[0].strip() != "---": errors.append(f"{md}: missing frontmatter"); continue
        try: end=next(i for i,l in enumerate(lines[1:],1) if l.strip() in {"---","..."})
        except StopIteration: errors.append(f"{md}: unclosed frontmatter"); continue
        fm="\n".join(lines[1:end])
        m=re.search(r"^name:\s*([^#\n]+?)\s*$", fm, re.M)
        name=m.group(1).strip().strip("'\"") if m else None
        if name != d.name or not name or not NAME_RE.fullmatch(name): errors.append(f"{md}: invalid name {name!r}")
        disabled=bool(re.search(r"^disable-model-invocation:\s*true\s*$", fm, re.M))
        y=d/"agents"/"openai.yaml"
        if disabled and (not y.is_file() or not re.search(r"allow_implicit_invocation:\s*false", y.read_text(encoding="utf-8"))):
            errors.append(f"{d}: user-invoked skill lacks allow_implicit_invocation: false")
    for name in shared:
        if not (SKILLS/name).is_dir(): errors.append(f"shared skill missing: {name}")
    if errors:
        for e in errors: print(e, file=sys.stderr)
        return 1
    print(f"ok: {len([d for d in SKILLS.iterdir() if d.is_dir() and not d.name.startswith('.')])} skills; {len(shared)} shared")
    return 0

if __name__ == "__main__": raise SystemExit(main())
