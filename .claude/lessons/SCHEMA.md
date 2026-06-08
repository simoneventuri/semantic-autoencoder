<!-- FRAMEWORK FILE: improvements → PR to semantic-autoencoder -->

# Lessons Schema

Lessons are **additive, project-local deltas** to an agent's or skill's framework
instructions. They never override the SOT.

## Precedence (non-negotiable)

The framework `.md`/`SKILL.md` has FULL precedence over any lesson. A lesson may
only add guidance where the SOT is silent. If a lesson contradicts, weakens, or
reinterprets the SOT, it is ignored and marked `status: stale`. User instructions
outrank both.

## What is a lesson (and what is NOT)

A lesson is a **process/method** improvement to how an agent does its job.

- general — generalizes to other legacy codebases (template-promotion candidate)
- project — specific to *this* project's quirks (stays local forever)
- NOT a domain fact about the legacy code — that does NOT belong here. Redirect to
  the canonical IR or the `explain-domain` skill.

## Necessity test

Before writing a candidate: *"Would the next run go wrong WITHOUT this lesson?"*
If not, do not write it. Over-encoding lessons is the same silent poison as
over-encoding the IR — prefer too few.

## Raw candidate block (agents → `artifacts/lessons_inbox/<name>.md`)

Agents append this minimal block; the curator fills in the rest.

```yaml
- candidate: <one-sentence process lesson, no code names in the text>
  applies_to: <agent or skill name>
  trigger: user-feedback | critic-finding | gap | test-failure
  evidence: <path/link: review file, failing test, PR, or chunk id>
  proposed_scope: general | project
```

## Vetted entry (curator → `.claude/lessons/<name>.lessons.md`)

```yaml
- lesson: <one-sentence process lesson>
  scope: general | project
  trigger: user-feedback | critic-finding | gap | test-failure
  evidence: <path/link>
  confidence: high | medium | low
  status: active | promote-candidate | merged | stale
  template_base: <semantic-autoencoder commit SHA this was derived from, or "unknown">
```

Body lines below each entry, mirroring the memory convention:

> **Why:** <why this matters>
> **How to apply:** <what to do differently>

`status` meaning: `active` (apply it), `promote-candidate` (general + eligible for
`/harvest-lessons`), `merged` (already in the template SOT — safe to prune),
`stale` (contradicts current SOT — do not apply).
