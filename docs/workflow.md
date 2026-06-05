<!-- FRAMEWORK FILE: improvements → PR to semantic-autoencoder -->

# Semantic Autoencoder Workflow

Single source of truth for agent order and data flow.
Regenerate with `/draw-workflow` whenever agents or their sequence change.

## Scope of this diagram

**This diagram shows the workflow for a single chunk.**

The orchestrator (not drawn) manages the full pipeline:

1. It splits the legacy codebase into **parts** (coarse logical groupings).
2. It splits each part into **chunks** (fine-grained units of work).
3. It iterates the encode → test → review → merge cycle over every chunk, in
   dependency order, before running the final decode and validation.

The diagram below is what happens inside one iteration of that loop.
The orchestrator dispatches every agent shown; every agent is dispatched by it.

```mermaid
%%{init: {'theme':'base','themeVariables':{
  'fontFamily':'ui-sans-serif, system-ui, -apple-system, sans-serif','fontSize':'14px',
  'primaryColor':'#ffffff','primaryTextColor':'#333333','primaryBorderColor':'#333333',
  'lineColor':'#333333','tertiaryColor':'#F7F5F0','background':'#F7F5F0',
  'clusterBkg':'#F7F5F0','clusterBorder':'#cccccc'
}}}%%
flowchart TD

  %% ---- data (parallelogram) ----
  T[/legacy code chunk/]
  CI[/chunk IR/]
  RD[/chunk regression data/]
  CN[/canonical IR/]
  DC[/decoded code/]

  %% ---- agents (uniform circles) ----
  subgraph ENC [encoders · 1–3, parallel]
    direction LR
    E1(("<div style='width:90px;text-align:center'>encoder</div>"))
    E2(("<div style='width:90px;text-align:center'>encoder</div>"))
    E3(("<div style='width:90px;text-align:center'>encoder</div>"))
  end
  R1(("<div style='width:90px;text-align:center'>tester</div>"))
  X(("<div style='width:90px;text-align:center'>critic</div>"))
  M(("<div style='width:90px;text-align:center'>merger</div>"))
  K(("<div style='width:90px;text-align:center'>decoder</div>"))
  R2(("<div style='width:90px;text-align:center'>tester</div>"))

  %% ---- decisions (diamond) + terminal ----
  C{issues?}
  V{pass?}
  D[done]

  %% ---- edges ----
  T --> E1
  T --> E2
  T --> E3
  ENC --> CI
  CI --> R1
  R1 --> RD
  RD --> X
  X --> C
  C -->|clean| M
  M --> CN
  CN --> K
  K --> DC
  DC --> R2
  R2 --> V
  V -->|ok| D
  %% feedback loops all return to the encoder group; the group emits one arrow to
  %% chunk IR so the loops don't push the output arrows off-centre.
  C -->|fix now| ENC
  CN -.->|context| ENC
  V -->|gap| ENC

  %% ---- style classes ----
  classDef data     fill:#ffffff,stroke:#333333,stroke-width:1.5px,color:#333333;
  classDef keydata  fill:#E8633A,stroke:#E8633A,stroke-width:1.5px,color:#ffffff;
  classDef agent    fill:#ffffff,stroke:#333333,stroke-width:1.5px,color:#333333;
  classDef decision fill:#ffffff,stroke:#E8633A,stroke-width:1.5px,color:#333333;
  classDef terminal fill:#1A1A1A,stroke:#1A1A1A,stroke-width:1px,color:#ffffff;

  class CI,RD data;
  class T,CN,DC keydata;
  class E1,E2,E3,R1,X,M,K,R2 agent;
  class C,V decision;
  class D terminal;

  %% orange = forward pipeline; grey = feedback loops
  linkStyle 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14 stroke:#E8633A,stroke-width:2px;
  linkStyle 15,16,17 stroke:#BBBBBB,stroke-width:1px;
```

## Stage descriptions

| Stage | Agent | Reads | Writes |
|-------|-------|-------|--------|
| Extract semantics | encoder ×1–3 (parallel; count set by orchestrator based on chunk complexity and user preference) | `encoded/legacy/` + accumulated `semantic_ir/canonical/` | `semantic_ir/chunk_NNN/` |
| Generate regression data | tester | `encoded/legacy/` (binary) | `regression_tests/` |
| Review quality | critic | `semantic_ir/chunk_NNN/` | `semantic_ir/chunk_NNN/99_review/` |
| Merge to canonical | merger | `semantic_ir/chunk_NNN/` | `semantic_ir/canonical/` |
| Decode | decoder | `semantic_ir/canonical/` **only** | `decoded/` |
| Validate decoded | tester | `regression_tests/` (reference) | `decoded/regression_tests/` |

## Feedback loops (grey)

All three return to the **encoders**:

- **context** — the canonical IR built by the merger feeds back as context to the
  encoders, so later chunks never re-derive or contradict established facts.
- **fix now** — a failing critic review re-runs the encoders.
- **gap** — a failing validation re-runs the encoders to patch the IR gap before
  re-decoding.

The encoder group emits a single arrow to `chunk IR`; routing the loops into the group
this way keeps that output arrow from being pushed off-centre.

## Legend

- **Parallelogram** — data: input, artifact, or intermediate product
- **Orange parallelogram** — the headline artifacts: input, canonical IR, decoded output
- **Circle** — agent (own context window, own tools); all drawn the same size
- **Diamond** — decision or quality gate
- **Solid black** — terminal state
- **Orange arrow** — the forward pipeline
- **Grey arrow** — a feedback loop