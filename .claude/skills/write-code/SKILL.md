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
