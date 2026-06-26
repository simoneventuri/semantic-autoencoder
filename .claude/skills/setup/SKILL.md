---
name: setup
description: Run once at project start to interview the user and generate config/project_config.yaml. Covers: permissions, legacy code location, user profile, autonomy level, encoder parallelism, supplementary references, notation style, units registry and default-unit policy, decoder target language, and model assignments.
disable-model-invocation: true
---

<!-- FRAMEWORK FILE: improvements → PR to semantic-autoencoder -->


# Setup Skill

Run this once before starting any encoding work.
It interviews the user and writes `config/project_config.yaml`.

---

## Step 0.0 — Permission interview

Before touching any file, ask:

> "A few quick access defaults before we start — let me know if you want to change any:
>
> 1. **Filesystem boundary** — I will only read/write/execute inside this project folder.
>    Allow access to any paths outside it? (default: no)
>
> 2. **`encoded/legacy/` immutability** — once the legacy code is copied there, I will
>    never modify or delete any file inside it.  Override? (default: no)
>
> 3. **`workspaces/` lifecycle** — I'll use this folder for temporary runs and will
>    clean up each subdirectory when the task is done.  Any exceptions? (default: none)
>
> 4. **`artifacts/` lifecycle** — I'll use this folder for manifests and planning state,
>    and will delete each subdirectory after its canonical IR is merged.  Exceptions?
>    (default: none)
>
> Just say 'defaults are fine' to accept all of the above."

Record any non-default choices in `config/project_config.yaml` under `permissions:`.

---

## Step 0.1 — Confirm legacy code location

> "Is your legacy codebase already in `encoded/legacy/`, or should I help you set that up?"

- If yes: confirm the path and proceed.
- If no: ask where the code lives and copy/link it into `encoded/legacy/` (git submodule, symlink, or direct copy).

**The `encoded/` folder is immutable for the rest of the project. Agents must never modify it.**

---

## Step 0.2 — Check for existing config

- If `config/project_config.yaml` exists: summarize its content. Ask if they want to update anything.
  - If yes: continue to Step 0.4.
  - If no: exit setup.
- If it does not exist: continue to Step 0.4.

---

## Step 0.3 — Create GitHub repository (if needed)

Create a GitHub repository if one does not already exist.

---

## Step 0.4 — User profile assessment

Ask:
> "Have you used this semantic IR extractor before, or is this your first time?
> (Your answer helps me decide how much to explain along the way.)"

- **Mode A — First-time user:** Before each major step, briefly explain what you are about to do, why it is necessary, and what the user needs to do. Use analogies. Offer to slow down.
- **Mode B — Returning user:** Proceed without preamble.

Record as `profile.familiarity: A | B`.

---

## Step 0.5 — Autonomy level

Ask the user to choose:

- **Fully autonomous** — executes end-to-end; user reviews completed IR at the end
- **Semi-guided** (default) — proposes plan; pauses at each major decision point
- **Fully interactive** — pauses after every agent invocation

Record as `autonomy.mode: autonomous | semi-guided | interactive`.

---

## Step 0.6 — Supplementary materials

Ask:
- Is there a code manual, design document, or paper that describes the system?
- If yes: how confident is the user in its correctness and completeness?
- Should it be used as primary evidence, secondary confirmation, or treated with skepticism?

Record under `references:`.

---

## Step 0.7 — Notation style

Present choices for three dimensions:

**Variables, quantities, parameters** (choose one):
- LaTeX subscript (recommended): $r_\text{max}$, $n_\text{call}$
- Lowercase underscore: `r_max`, `n_call`
- PascalCase: `RMax`, `NCall`

**Vectors and matrices** (choose one):
- Bold LaTeX (recommended): $\mathbf{p}$, $\mathbf{T}_{pq}$
- Prose + symbol: "momentum vector $p$"

**Procedure names in body text** (choose one):
- Semantic prose only (recommended): code names appear only in `source:` fields
- Italic on first use: *assembleMatrix*
- Backtick code-style: `assembleMatrix()`

**Acronyms** (choose one):
- ALL CAPS (recommended): ODE, FFT, RHS
- Mixed: DoF, FFT

After the user chooses, create `semantic_ir/canonical/10_semantic_requirements/notation_style.md` from the template in `config/project_config.example.yaml` (see Notation Style section).

---

## Step 0.7b — Quantities and conventions

Explain briefly:
> "I centralize two things in one place. (a) **Dimensioned quantities** — for the
> genuinely physical quantities this domain carries (target labels and descriptors,
> e.g. solubility, binding affinity), each dimension gets one default unit and every
> other unit is recorded with its conversion to that default. Most ML tensors are
> dimensionless and stay out of this registry. (b) **Tensor/value conventions** —
> shapes, dtypes, normalization statistics, vocabularies, and random-seed/determinism
> notes; the ML analog of units discipline."

Ask (about the dimensioned quantities only):
> "How should I pick each dimension's default unit?
> 1. **Adopt the legacy code's prevailing unit** (default) — whatever the original
>    code mostly works in becomes the default; I discover this while encoding and
>    the merger freezes it. Fewest conversions, preserves the as-built numerics.
> 2. **You specify** — pin a unit (or a whole system) for some or all dimensions now,
>    and I convert everything to it.
> Either way you can pin individual overrides."

Record under `conventions:` (`default_policy: adopt-legacy | user-specified`, plus any
`default_overrides`).

Then create the **skeletons** from the Quantities & Conventions Template in
`config/project_config.example.yaml`:
- `semantic_ir/canonical/02_conventions/quantities.md` — the default-unit-per-dimension
  table (placeholders to be filled as dimensioned quantities are encoded, unless the
  user pinned defaults now) plus a one-line statement of the chosen policy.
- `semantic_ir/canonical/02_conventions/quantity_registry.csv` — header row only
  (`symbol,aliases,dimension,is_default,to_default_formula`).
- `semantic_ir/canonical/02_conventions/tensor_conventions.md` — headed skeleton for
  shape/axis conventions, dtypes, normalization statistics, vocabularies, and
  seed/determinism notes (filled as model objects are encoded).
The merger owns these files thereafter; encoders append to them.

---

## Step 0.8 — Encoder parallelism

Ask:
> "When I encode a chunk, I can run 1, 2, or 3 encoder agents in parallel depending on
> chunk complexity. Do you want to set a maximum, or let me decide each time?
> (Default: up to 3, decided per chunk based on complexity.)"

Record under `encoders:`.

---

## Step 0.9 — Model assignments

Present:
> "Default model assignment:
> - Orchestrator: `claude-opus-4-8`
> - Encoder / Critic / Merger / Tester agents: `claude-sonnet-4-6`
>
> Should I use these defaults, or would you like to change either?"

Record under `models:`.

---

## Step 0.9b — Decoder default language

Ask:
> "What language should the default decoded package target? This is the language
> the decoder writes the reference implementation in (the one validated against
> regression data). Default: **Python**."

Note for the user: there is **one** decoded package, written to a high standard in
that language and structured modularly so future IR parts extend it without
disturbing what already works.

Record under `decoder:` (`default_language`, default `python`; `package_root`,
default `decoded`).

---

## Step 0.A — Create domain-specific skill stubs

After all interview steps are complete, create the three project-specific skills that
do not exist in the framework skeleton. Use the information gathered in earlier steps
to populate them as fully as possible; insert `TODO:` markers for anything unknown.

### `.claude/skills/explain-domain/SKILL.md`

Reference knowledge for all agents. Claude auto-invokes this when it needs domain
context not yet in the canonical IR.

```markdown
---
name: explain-domain
description: Reference knowledge for agents operating on <PROJECT>. Covers the system being encoded, key domain concepts, IR section purposes, and output conventions. Load when you need background context that isn't in the canonical IR yet.
---

# Domain Knowledge — <PROJECT> Semantic Autoencoder

## What <SYSTEM> is

TODO: Describe what the legacy ML/AI system does — the learning task(s) (prediction /
classification / generative design), the chem/bio entities it operates on, its inputs
(datasets, structures, sequences), outputs (predictions, generated designs, metrics),
and main pipeline stages. (From supplementary materials gathered in Step 0.6.)

## Key concepts

TODO: List the 3–5 most important domain concepts an encoder needs to understand
(e.g., the domain entities — molecules / residues / binding sites — and how they are
represented; the model family; the training objective; the evaluation metrics).

## Canonical IR taxonomy guide

The IR is **object-oriented**: domain entities (chem/bio) composed upward into model
objects. The **merger owns the final taxonomy** — the object-body layout below is a
recommended default it may restructure to fit the objects actually discovered. The
reserved sections keep their names so every agent can rely on them.

| Section | Purpose | Key question |
|---------|---------|--------------|
| `00_task_and_domain` | The learning problem(s) and scientific objective | Predict / classify / generate what, over which entities? |
| `domain_objects/` | The chem/bio entities | Atoms, molecules, residues, sites, sequences, reactions — attributes & relationships? |
| `data/` | Datasets and how they are prepared | Sources, provenance, splits, labels, preprocessing? |
| `model_objects/` | Featurizers, layers, blocks, models | What is the architecture? Interfaces (shapes/dtypes)? Learned parameters? |
| `objectives/` | Losses, regularizers, constraints | What is optimized? |
| `training/` | Optimization procedure | Optimizer, schedule, hyperparameters, loop? |
| `inference/` | Prediction / generation / sampling | Forward pass, decoding, sampling, validity filtering? |
| `evaluation/` | Metrics and protocols | Accuracy / AUC / RMSE / validity-novelty-uniqueness? |
| `execution/` | Stage order and data flow | What runs in what order? |
| `02_conventions` *(reserved)* | Dimensioned-quantity units + tensor shape/dtype/normalization conventions | What units? What shapes/dtypes/normalization/vocab/seeds? |
| `10_semantic_requirements` *(reserved)* | What any re-implementation must do | Required? Forbidden? Allowed? |
| `11_pipeline_schematics` *(reserved)* | How stages connect into a pipeline | What flows between stages? (merger-produced) |
| `80_implementation_constraints` *(reserved)* | Required APIs, frameworks, formats | Only when justified |
| `90_human_overrides` *(reserved)* | Human-owned, highest priority | Never modified by agents |
| `99_review` *(reserved)* | Quality flags, gaps, contradictions | Critic findings |

## Output conventions

- IR files use GitHub-flavored Markdown
- All math in `$...$` (inline) or `$$...$$` (display) — never bare Unicode
- Statement format: `statement:` + `source:` + `confidence:` + `status:`
- Trained weights/embeddings are SIR data, co-located with their model object's page, in open binary (HDF5 / safetensors-style) — never pickle/.pt/.npy
- Reference data files (in `regression_tests/`): CSV with `#`-prefixed headers, full precision

## Known behavioral hazards

TODO: Document any as-built behaviors decoded implementations MUST reproduce (not
"fix") — e.g. a normalization applied at train but not inference, a fixed random seed,
a non-obvious label encoding, leakage the legacy pipeline tolerates.
```

### `.claude/skills/run-legacy/SKILL.md`

How to install and run the legacy model/pipeline. Used by the tester agent to generate
reference predictions and metric values.

```markdown
---
name: run-legacy
description: Run the <PROJECT> legacy model/pipeline. Use when producing reference predictions/metrics or validating a build.
disable-model-invocation: true
---

# <PROJECT> Legacy Runner

**`encoded/legacy/` is immutable. Never write to it — stage all output in `workspaces/`.**
Stage any trained-weight files the model needs into `workspaces/` too; never modify them in place.

## Step 1 — Establish project root

\`\`\`bash
PROJECT_ROOT=$(git rev-parse --show-toplevel)
echo "Project root: $PROJECT_ROOT"
\`\`\`

## Step 2 — Source the environment

TODO: Describe how to activate the runtime environment (virtualenv/conda activate, env file, framework + GPU/CPU setup, etc.).

\`\`\`bash
source "$PROJECT_ROOT/.claude/<env-file>.sh"   # adjust as needed
\`\`\`

Stop if the environment or model entry point cannot be found.

## Step 3 — Prepare workspace

\`\`\`bash
WORKSPACE="$PROJECT_ROOT/workspaces/validation_run"
mkdir -p "$WORKSPACE"
cp -r "$PROJECT_ROOT/encoded/legacy/<test-dir>" "$WORKSPACE/"
\`\`\`

## Step 4 — Run

TODO: Replace with the actual run command.

\`\`\`bash
cd "$WORKSPACE/<test-dir>"
<run-command> 2>&1 | tee "$WORKSPACE/run.log"
echo "Exit: ${PIPESTATUS[0]}"
\`\`\`

## Step 5 — Verify

TODO: Describe what a successful run looks like (exit code, log string, output file).

## Step 6 — Clean up

\`\`\`bash
rm -rf "$WORKSPACE"
\`\`\`

---

## Install (only if Step 2 fails)

TODO: Describe how to install dependencies and obtain the model/weights for the legacy pipeline in `encoded/legacy/`.
```

### `.claude/skills/run-decoded/SKILL.md`

**Do not create this file at setup time.** It is created by `/orchestrate` immediately
before the decoder agent is dispatched for the first time, once the decoded package
structure is known. See the `/orchestrate` skill for the template.

---

## Final step — Write config/project_config.yaml

Write `config/project_config.yaml` with these fields only:

```yaml
project:
  name: ***

source:
  root: encoded/legacy/***

ir_root: semantic_ir

permissions:
  filesystem_boundary: project-local   # or: extended (list external paths below)
  external_paths: []                   # populated only if user grants access
  encoded_immutable: true              # always true; here for explicit audit trail

profile:
  familiarity: A | B

autonomy:
  mode: autonomous | semi-guided | interactive

encoders:
  max_parallel: 1 | 2 | 3   # orchestrator decides per chunk, capped by this value

references:
  supplementary: none | <description>
  confidence: primary | secondary | skeptical | n/a

models:
  orchestrator: claude-opus-4-8
  agents: claude-sonnet-4-6

notation:
  style_file: semantic_ir/canonical/10_semantic_requirements/notation_style.md

conventions:
  registry_file: semantic_ir/canonical/02_conventions/quantities.md
  registry_data: semantic_ir/canonical/02_conventions/quantity_registry.csv
  tensor_conventions: semantic_ir/canonical/02_conventions/tensor_conventions.md
  default_policy: adopt-legacy | user-specified   # dimensioned quantities only
  default_overrides: {}        # optional {dimension: unit} pins

decoder:
  default_language: python     # confirmed in Step 0.9b
  package_root: decoded

session_started: <DATE>
```

Do NOT add fields beyond this list.

---

## After setup

Tell the user:
> "Setup complete. Run `/orchestrate` to start encoding."