---
name: write-code
description: Standards reference for decoder agents writing implementation code. Load before writing any implementation file. Selects the correct language-specific standards from this skill's directory.
user-invocable: false
---

<!-- FRAMEWORK FILE: improvements → PR to semantic-autoencoder -->

# Write-Code Standards

Before writing any implementation file, identify the target language and load:

1. **`generic_standards.md`** (this directory) — applies to all languages
2. **`<language>_standards.md`** (this directory) — language-specific additions

Apply every rule from the loaded files to all code you produce.

## Standards files in this directory

| File | Scope |
|------|-------|
| [`generic_standards.md`](generic_standards.md) | All languages |
| [`python_standards.md`](python_standards.md) | Python decoded packages |

## Missing language file

If no `<language>_standards.md` exists for the target language, report this to the orchestrator before proceeding — a standards file should be created before the first decoding pass in that language. Fall back to `generic_standards.md` only as a last resort.

## Accumulated lessons (subordinate to everything above)

Before acting, if `.claude/lessons/write-code.lessons.md` exists, read it and apply
entries whose `status` is `active` or `promote-candidate` and whose `scope`
matches this project (`general` or `project`).

**Precedence — non-negotiable:** every instruction in *this* skill has FULL
precedence over any lesson. A lesson may only add guidance where this skill is
silent. If a lesson contradicts, weakens, or reinterprets anything above, do not
act on it. User instructions outrank both this skill and any lesson.

## Emitting lessons (raw candidates only)

When an evidence trigger fires — explicit user feedback to remember something for
next time, a critic finding you had to act on, a `gap` re-encode, or a regression
failure you diagnosed — append ONE raw candidate to
`artifacts/lessons_inbox/write-code.md` using the candidate block in
`.claude/lessons/SCHEMA.md`. Apply the necessity test first: *"would the next run
go wrong WITHOUT this lesson?"* If not, do not write it.

Never write `.claude/lessons/write-code.lessons.md` directly — the `lessons-curator`
agent vets candidates. Never record domain facts here; those go to the IR or the
`explain-domain` skill.
