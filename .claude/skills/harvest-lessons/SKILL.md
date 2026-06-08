---
name: harvest-lessons
description: Promote project-local general lessons into the semantic-autoencoder template via a reviewed PR. Collects scope=general, status=promote-candidate entries across .claude/lessons/, shows them for approval, edits the template SOT in the sibling clone, opens a PR, then marks promoted entries merged.
disable-model-invocation: true
argument-hint: (none)
allowed-tools: Bash(git *), Bash(gh *)
---

<!-- FRAMEWORK FILE: improvements → PR to semantic-autoencoder -->

# Harvest Lessons

Manual, user-invoked promotion of `general` lessons into the template. Never runs
automatically (side effects: edits the template clone, opens a PR).

## Preconditions

- A sibling clone of the template exists at `../semantic-autoencoder`.
- `gh` is authenticated.

## Steps

1. **Collect candidates.** Across every `.claude/lessons/*.lessons.md`, gather
   entries with `scope: general` and `status: promote-candidate`. Group by
   `applies_to` target.

2. **Present for approval.** Show a table: target SOT file, the lesson text, its
   evidence, and `template_base`. Ask the user which to promote. Promote only the
   approved subset.

3. **Stale-check against current template.** For each approved lesson, read the
   target SOT in `../semantic-autoencoder`. If the SOT already covers it, skip and
   tell the user (mark the local entry `merged` anyway — it is already in the SOT).
   If it contradicts the current SOT, skip and flag for manual resolution.

4. **Edit the template SOT.** Integrate each approved lesson into the appropriate
   section of the target `.md`/`SKILL.md` in `../semantic-autoencoder`, in the
   house style — as a first-class instruction, not as a "lesson" annotation. Show
   the diff.

5. **Branch, commit, PR.** On a new branch in `../semantic-autoencoder`, commit
   the edits and open a PR (reuse the framework-update flow). Show the PR URL.

6. **Mark merged locally.** In the project's `.claude/lessons/*.lessons.md`, set
   the promoted entries to `status: merged`. The curator prunes `merged` entries on
   its next run.

## Guardrails

- Promote `general` only. `project` lessons stay local forever.
- Never weaken the SOT. A lesson that contradicts the current template is a signal
  for human design discussion, not an automated edit.
- Always show diffs and the PR before pushing.
