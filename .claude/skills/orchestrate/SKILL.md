---
name: orchestrate
description: Coordinates the full semantic encoding pipeline. Dispatches encoder, tester, critic, merger, and decoder agents in the correct order. References docs/workflow.md as the canonical pipeline diagram.
disable-model-invocation: true
---

<!-- FRAMEWORK FILE: improvements → PR to semantic-autoencoder -->


# Orchestrator Skill

You coordinate the pipeline described in `docs/workflow.md`.
Read that file now to confirm the current agent order.

**If you change agents or their order, run `/draw-workflow` to regenerate
`docs/workflow.md` so the diagram never drifts from the real roster.**

---

## Pre-flight checks

Before starting:
1. Confirm `config/project_config.yaml` exists. If not: tell the user to run `/setup` first.
2. Read `config/project_config.yaml` and apply `autonomy.mode`, `profile.familiarity`, and `encoders.max_parallel` throughout.
3. Confirm `encoded/legacy/` exists and is non-empty.

---

## Level 1 — Part planning

Ask (or auto-plan based on `autonomy.mode`):

> "Should we create a Semantic IR for the entire codebase, or only selected parts?"

For each part, record a Part Manifest in `artifacts/chunks/part_index.md`:

```yaml
part_id:
part_name:
description:
source_root:
excluded_files:
dependencies:
dependents:
priority:
chunks: []
autonomy:
status: pending
```

Apply the **Dependency-First Ordering Principle**: parts that others depend on get lower part numbers.

---

## Level 2 — Chunk planning (per part)

For each part, before encoding:

> "Should I encode this part all at once, or split it into smaller chunks?"

For each chunk, create a Chunk Manifest in `artifacts/chunks/`:

```yaml
part_id:
chunk_id:
chunk_name:
source_files:
source_symbols:
dependencies:
dependents:
physical_concepts:
numerical_concepts:
expected_ir_targets:
recommended_encoder_agents:
execution_priority:
```

---

## Per-chunk execution

For each chunk, execute in order:

1. **Load accumulated IR** into every agent's context:
   - `semantic_ir/canonical/` (ground truth)
   - `semantic_ir/chunk_{N-1}/` (preceding chunk within the part)

2. **Propose APIs/schemas to keep** — collect user feedback

3. **Determine encoder count** — choose 1–3 based on chunk complexity, capped by `encoders.max_parallel`:
   - 1 encoder: simple chunk, single IR section, few source files
   - 2 encoders: moderate chunk, two or three IR sections
   - 3 encoders: complex chunk, many IR sections or large source files
   State the chosen count and rationale before dispatching.

4. **Dispatch encoder agents** — use the `encoder` subagent (1–3 in parallel); specify which IR sections each should produce

5. **Dispatch tester agent** — use the `tester` subagent; it runs the original binary and produces `regression_tests/<UnitName>/`

6. **Dispatch critic agent** — use the `critic` subagent for all three checks (consistency, leakage, decoder readiness)

7. **Present findings** — ask user:
   - Fix critical issues now → dispatch correction encoders
   - Log and proceed → record in `99_review/`
   - User reviews files → pause

8. **Dispatch merger agent** — use the `merger` subagent

9. **Offer MR** — "Create a GitHub merge request for chunk_N before proceeding?"

---

## Post-part steps

After all chunks in a part complete:

1. Run the full Merge Protocol (merger agent handles this)
2. Ask: "Part {P} is complete. Should I create a GitHub MR before moving on to the next part?"

---

## Decoding (on explicit user request only)

The Decoder Agent is never invoked automatically. On user request:

1. **Verify `run-decoded` skill exists** — check `.claude/skills/run-decoded/SKILL.md`.
   If missing, create it now (see template below) before dispatching the decoder.
   This skill must exist so the tester agent and the user know how to run the decoded package.
2. Dispatch the `decoder` subagent with access to `semantic_ir/canonical/` only
3. After decoding: dispatch `tester` subagent in Mode B to validate
4. If validation fails: report the specific gap, dispatch encoder to patch IR, re-invoke decoder

### run-decoded skill template

If `.claude/skills/run-decoded/SKILL.md` does not exist, create it with this structure,
filling in the actual install and run commands for the decoded package:

```markdown
---
name: run-decoded
description: Install and run the decoded <TARGET> package. Use when testing the decoded implementation or validating against regression reference data.
disable-model-invocation: true
---

# Decoded Package Runner

**`encoded/` and `semantic_ir/canonical/` are read-only. Only `decoded/` and `workspaces/` are writable.**

## Step 1 — Establish project root

\`\`\`bash
PROJECT_ROOT=$(git rev-parse --show-toplevel)
cd "$PROJECT_ROOT"
\`\`\`

## Step 2 — Install the package

TODO: Add install command (e.g. `pip install -e decoded/<target>` or `cargo build`).

## Step 3 — Run the test suite

TODO: Add test command (e.g. `pytest decoded/<target>/tests/ -v`).

All tests must pass before claiming the decoded implementation is correct.

## Step 4 — Run validation against regression references

TODO: Add validation command that compares decoded output against `regression_tests/` CSVs.

## Step 5 — Clean up

TODO: Remove any build artifacts, caches, or temporary files.
Do not delete `decoded/` itself.
```

---

## Autonomy modes

| Mode | Behavior |
|------|----------|
| `autonomous` | Execute end-to-end; pause only for blocking decisions |
| `semi-guided` | Pause at part/chunk boundaries and after critic findings |
| `interactive` | Pause after every agent invocation |

Respect the mode recorded in `config/project_config.yaml`.
The user may change mode at any time by stating their preference.

---

## Workflow reference

`docs/workflow.md` is the authoritative Mermaid diagram. It shows the workflow for
**a single chunk**. This skill manages the outer loop: legacy code → parts → chunks → iterate.

This skill and all agents must stay consistent with `docs/workflow.md`.
Regenerate it with `/draw-workflow` (never hand-edit the diagram block) so every
diagram keeps the same house style.