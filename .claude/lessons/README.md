<!-- FRAMEWORK FILE: improvements → PR to semantic-autoencoder -->

# Lessons

Per-agent accumulated lessons. **Subordinate to the framework `.md`/`SKILL.md`
files** — see precedence in [SCHEMA.md](SCHEMA.md).

- One file per agent/skill: `<name>.lessons.md`
- Written only by the `lessons-curator` agent (agents drop raw candidates in
  `artifacts/lessons_inbox/`, never here directly)
- Loaded by the matching agent at the start of every run
- Promoted to the template with `/harvest-lessons` (manual, `general` scope only)

If a lesson ever fights its SOT, the SOT wins and the lesson is marked `stale`.
