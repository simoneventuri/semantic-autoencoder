---
name: setup
description: Run once at project start to interview the user and generate config/project_config.yaml. Covers: permissions, legacy code location, user profile, autonomy level, encoder parallelism, supplementary references, notation style, and model assignments.
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

TODO: Describe what the legacy system computes. What are its inputs, outputs, and
main execution stages? (From supplementary materials gathered in Step 0.6.)

## Key concepts

TODO: List the 3–5 most important domain concepts an encoder needs to understand
(e.g., physical model, governing equations, key quantities).

## Canonical IR section guide

| Section | Purpose | Key question |
|---------|---------|--------------|
| `01_system_model` | What physical/logical system is modeled? | What world? What assumptions? |
| `02_quantities` | What quantities exist? Units? | What can vary? What is fixed? |
| `03_equations` | Governing relationships | What equations define behavior? |
| `04_representations` | How are quantities represented? | Arrays? Grids? Particles? |
| `05_discretization` | How are continuous equations approximated? | FD? FEM? Quadrature? |
| `06_algorithms` | What procedures are used? | Newton? Runge-Kutta? |
| `07_numerics` | Numerical behavior | Stability? Tolerances? Singularities? |
| `08_execution_model` | In what order does computation occur? | Dependencies? Events? |
| `09_validation` | How do we know it's correct? | Tests? Reference data? |
| `10_semantic_requirements` | What must any re-implementation do? | Required? Forbidden? Allowed? |
| `11_pipeline_schematics` | How do stages connect into a pipeline? | What flows between stages? (merger-produced) |
| `80_implementation_constraints` | Required APIs, file layouts, deployment | Only when justified |
| `90_human_overrides` | Human-owned, highest priority | Never modified by agents |
| `99_review` | Quality flags, gaps, contradictions | Critic findings |

## Output conventions

- IR files use GitHub-flavored Markdown
- All math in `$...$` (inline) or `$$...$$` (display) — never bare Unicode
- Statement format: `statement:` + `source:` + `confidence:` + `status:`
- Reference data files: CSV with `#`-prefixed headers, scientific notation, full double-precision

## Known behavioral hazards

TODO: Document any as-built deviations from physical intent that decoded
implementations MUST reproduce (not fix).
```

### `.claude/skills/run-legacy/SKILL.md`

How to install and run the legacy binary. Used by the tester agent to generate
regression reference data.

```markdown
---
name: run-legacy
description: Run the <PROJECT> legacy binary. Use when producing regression reference data or validating a build.
disable-model-invocation: true
---

# <PROJECT> Legacy Runner

**`encoded/legacy/` is immutable. Never write to it — stage all output in `workspaces/`.**

## Step 1 — Establish project root

\`\`\`bash
PROJECT_ROOT=$(git rev-parse --show-toplevel)
echo "Project root: $PROJECT_ROOT"
\`\`\`

## Step 2 — Source the environment

TODO: Describe how to activate the runtime environment (env file, module load, conda activate, etc.).

\`\`\`bash
source "$PROJECT_ROOT/.claude/<env-file>.sh"   # adjust as needed
\`\`\`

Stop if the binary cannot be found.

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

TODO: Describe how to build the binary from source in `encoded/legacy/`.
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

session_started: <DATE>
```

Do NOT add fields beyond this list.

---

## After setup

Tell the user:
> "Setup complete. Run `/orchestrate` to start encoding."