<!-- FRAMEWORK FILE: improvements → PR to semantic-autoencoder -->

# Semantic Autoencoder

This project extracts a language-independent Semantic IR from a legacy codebase
and decodes it into a clean reimplementation in a target language.

**Domain for this project:** the codebase being encoded is *not* a physical
simulation. It is a composition of ML/AI routines for **prediction, classification,
and generative design in chemistry/biology** — few equations, many model layers,
datasets, and learned parameters. The Semantic IR is organized **object-orientedly**:
domain entities (atoms, bonds, functional groups, molecules, residues, amino-acids,
binding sites, sequences, reactions, assays, datasets) composed upward into model
objects (featurizers, layers, blocks, modules, models, losses, optimizers, training
loops, samplers, evaluators). The **merger owns the canonical taxonomy** — there is no
fixed numbered section grid for the object body (see rule 16).

**First time here?** Run `/setup` before anything else.
**Ready to encode?** Run `/orchestrate`.
**Need domain background?** Run `/explain-domain`.

@docs/workflow.md

---

## Core principle

This project treats legacy code as a compressed implementation of a model.
The objective is not code translation — it is **semantic extraction**.
A successful decoder should be able to regenerate an equivalent implementation
without ever reading the original source code.

---

## Global rules (apply to every agent in every session)

1. `encoded/legacy/` is **immutable**. No agent may write to it under any circumstance.
2. `semantic_ir/canonical/` is the authoritative IR. It has higher priority than any chunk-level IR.
3. `90_human_overrides/` has the highest priority of all IR content.
4. Decoder agents may only read `semantic_ir/canonical/`. They must never access `encoded/`.
5. All mathematics in IR files uses `$...$` or `$$...$$`. No bare Unicode math.
6. All IR statements carry `source:`, `confidence:`, and `status:` metadata.
7. Code names (variable names, function names, class names) appear only in `source:` fields — never in IR body text.
8. Decoded packages must be self-contained: all runtime data files copied from `semantic_ir/canonical/` into `decoded/` during decoding. Data must never flow directly from `encoded/` to `decoded/`.
9. Do not modify shell profile files (`~/.zshrc`, `~/.zprofile`, etc.). Use `.claude/<project>_env.sh` for env setup.
10. `semantic_ir/canonical/` is the sole source of truth for runtime data. Encoders extract data from `encoded/` and write it co-located with the IR object/section it belongs to (e.g., a featurizer's vocabulary at `canonical/model_objects/tokenizer/vocab.csv`, or a model's trained weights at `canonical/model_objects/encoder/weights.h5`); decoders copy from there. **Trained parameters (weights, embeddings) are SIR data**, co-located with their model object's page — not regression reference data.
11. Runtime data files in SIR use universal, language-agnostic formats. Preference order: **CSV (comma-separated, no spaces) → JSON → `.dat` → open binary (e.g., HDF5)**. Plain text is strongly preferred; open binary formats are acceptable when text is impractical (e.g., large weight tensors and multi-dimensional arrays). Never use framework-native or language-specific serialization (pickle, `.npy`, `.pt`, `.ckpt`, `.mat`, framework checkpoints, etc.). Never store regression or validation reference data in SIR — that belongs in `regression_tests/`.
12. **SOT precedence over lessons (non-negotiable).** Each agent/skill is governed by its framework `.md`/`SKILL.md` (the SOT). An agent may also load a subordinate `.claude/lessons/<name>.lessons.md`. The SOT has **full precedence**: a lesson that contradicts, weakens, or reinterprets it is ignored and marked `status: stale`. Lessons may only add guidance the SOT leaves open. User instructions outrank both.
13. **Lessons capture is curated, not self-edited.** Agents append *raw* candidates to `artifacts/lessons_inbox/<name>.md` on an evidence trigger (user feedback, critic finding, gap re-encode, regression failure). Only the `lessons-curator` agent writes vetted entries into `.claude/lessons/`. Promotion of `general` lessons into the template is manual, via `/harvest-lessons`.
14. **Quantities and conventions are centralized.** Two complementary concerns live in `canonical/02_conventions/` (created at `/setup`, owned by the merger): (a) **Dimensioned quantities** — for the genuinely physical quantities this domain carries (target labels and descriptors such as solubility, binding affinity in kcal/mol, energies), every dimension has exactly one default unit, recorded with each unit's conversion to that default in a registry; IR body and data express these in the default unit, named by the shortest standard symbol. *Most ML tensors are dimensionless and are never forced into the unit registry.* (b) **Tensor/value conventions** — shape and axis conventions, dtypes, normalization/scaling statistics, tokenization/vocabularies, and random-seed/determinism notes. This is the ML analog of units discipline: consistent shapes, dtypes, and normalization are what keep reconstructions equivalent. No agent introduces a unit or a convention without registering it.
15. **One decoded package, built to grow.** Each decode target is a single, coherent package in the configured default language (chosen at `/setup`), following that language's standard conventions and organized modularly along the IR's structure (one concern/object/part per module, shared foundations factored out). Extending the IR adds new modules through existing interfaces without rewriting or degrading already-decoded, already-validated ones.
16. **The canonical taxonomy is object-oriented and merger-owned.** The IR body is a hierarchy of *objects*: domain entities (chem/bio) composed upward into model objects (featurizers, layers, blocks, models, objectives, training, inference, evaluation). Each object is one IR page that states its identity/interface/behavior and references the sub-objects it is built from. Encoders extract per-object pages into chunk IR organized by object cluster, not a fixed section grid; the **merger decides the final grouping, hierarchy, and section naming/numbering** that best fits the objects actually discovered. The reserved sections (`02_conventions/`, `10_semantic_requirements/`, `11_pipeline_schematics/`, `80_implementation_constraints/`, `90_human_overrides/`, `99_review/`) keep their names so every agent can rely on them.

---

## Permissions and workspace discipline

At project start (`/setup`), Claude conducts a brief permission interview.
The defaults below apply throughout every session unless the user explicitly overrides
them during that interview or at any later point.

**Filesystem access — default: project-local only**
- Claude may only read, write, or execute files within this project directory.
- No access to paths outside the project root without explicit user approval.
- The user may grant access to external paths (e.g., reference datasets, HPC scratch).

**`encoded/legacy/` — immutable after initial copy**
- Once the legacy codebase is copied into `encoded/legacy/`, Claude may never modify,
  delete, or overwrite any file inside it, under any circumstances.
- Builds and test runs that need to write output must stage into `workspaces/`.

**`workspaces/` — temporary execution area (clean when done)**
- Use for anything that requires writing alongside or running the code: trial runs,
  build artifacts, exploratory edits, one-off executions.
- Every subdirectory here is disposable — delete and recreate freely.
- Delete the workspace subdirectory when the task that created it is complete.

**`artifacts/` — planning area (clean when merged)**
- Use for part manifests, chunk manifests, and orchestration state.
- Contents are planning artifacts, not semantic knowledge — safe to delete once
  the corresponding part or chunk is merged into the canonical IR.
- Delete part/chunk artifact subdirectories after their canonical IR is merged.

---

## Directory map

```
encoded/          — Original legacy codebase. Immutable.
semantic_ir/      — Extracted knowledge (primary product)
  canonical/      — Authoritative merged IR
  chunk_NNN/      — Per-chunk extraction artifacts
decoded/          — Decoder outputs (self-contained packages)
regression_tests/ — Reference predictions and metric values from the legacy model
artifacts/        — Evidence and planning (not semantic knowledge); includes lessons_inbox/ (disposable raw lesson candidates)
workspaces/       — Temporary reasoning; disposable
logs/             — Execution history
config/           — Project configuration
docs/             — Human-readable project documentation
  workflow.md     — Canonical agent-workflow diagram (regenerate via /draw-workflow)
.claude/
  agents/         — Subagents: orchestrator, encoder, critic, merger, decoder, tester
  rules/          — Path-scoped instruction files (loaded when Claude reads matching files)
  skills/         — On-demand workflows: /setup, /orchestrate, /draw-workflow
                    + project-created: /explain-domain, /run-legacy, /run-decoded
  lessons/        — Per-agent accumulated lessons (subordinate to the SOT .md files)
```

### Domain-specific skills (created per project, not in the skeleton)

Three skills must be created for each new project. `/setup` creates the first two;
`/orchestrate` creates the third before the decoder runs for the first time.

| Skill | Created by | Purpose |
|-------|-----------|---------|
| `explain-domain` | `/setup` | Domain knowledge (chem/bio + ML), key concepts, IR object/section guide |
| `run-legacy` | `/setup` | How to install and run the legacy model/pipeline |
| `run-decoded` | `/orchestrate` (pre-decode) | How to install and run the decoded package |

---

## Preservation priorities

**Preserve:** learning task & scientific objective · data semantics, schema &
provenance · train/val/test split definitions · entity representations & featurization ·
model architecture & layer composition · learned-parameter semantics (and the parameter
data itself) · loss & training objectives · optimization procedure & hyperparameters ·
inference / sampling / decoding procedure · evaluation metrics & protocol · numerical
and stochastic behavior that affects results (seeds, determinism, normalization) ·
required integrations

**Do NOT preserve by default:** framework/library choice (PyTorch/TF/JAX) · file &
folder layout · module structure · class hierarchy · function/layer/variable names ·
tensor-library idioms · serialization formats · device/placement code ·
logging/checkpointing plumbing

**Information density:** prefer under-encoding over over-encoding. Over-encoding
silently inflates the IR with facts that are hard to identify and remove; under-encoding
causes detectable decoding failures that trigger a clean encoder iteration. Apply a
three-tier test to every candidate fact: (1) necessary for reconstruction → full
semantic statement; (2) not required but has documentary value (intent, design
rationale, domain context from the legacy source) → comment annotation, clearly marked
as originating from the legacy code; (3) purely redundant or language-specific
implementation detail → drop.

---

## Success criteria

The project succeeds when:
1. Original source can be discarded
2. Canonical IR is self-contained
3. Equivalent implementation can be regenerated from the IR alone
4. The decoded model reproduces the legacy model's predictions and evaluation metrics within ML-appropriate tolerances (not bit-exact)
5. Translation to another language remains possible