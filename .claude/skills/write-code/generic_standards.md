<!-- FRAMEWORK FILE: improvements → PR to semantic-autoencoder -->

# Generic Coding Standards (all languages)

## Naming

- Use descriptive, self-explanatory names. In scientific code prefer `velocity_field`, `temperature_solution` over `u`, `T`.
- Reserve single-letter names for simple loop indices only.

## Documentation

- Write docstrings (or the language equivalent) for every public function and class.
- Document the contract: what the function does, its parameters, return values, and units where relevant.
- Do not restate the implementation — explain the *why* when it is not obvious.

## Design

- Before writing new code, check whether a mature library already provides the capability. Justify any from-scratch reimplementation explicitly.
- Prefer simple built-in data structures over feature-rich custom classes until complexity actually demands more.
- Keep interfaces small and purpose-clear. A function or module should do one thing.
- Avoid global state, deep nesting, and string-built control flow.
- Split functionality into logical modules; entangled code is harder to test and re-decode.
- For new ideas: write a pedagogical prototype first — write the math, show intermediate steps. Productionize only after the prototype validates.
- Do not over-design. Note hacks explicitly. Revisit when they accumulate.

## Testing

- Test core functionality and, for numerical models, convergence and expected limiting behavior.
- When the spec is fuzzy, apply TDD: write the test first to pin down intended behavior before writing the implementation.
- Tests serve as executable documentation — they should clarify intended behavior, not just pass.

## Examples

- Ship runnable examples in a top-level `./examples/` directory.
- Notebooks are preferred when visualization and narrative are useful.
- Any data needed to run examples goes in `./examples/data/`.
- Examples must run without modification after install — any team member, no changes.

## Paths

- Use relative paths, localized to the package or script.
- Never hardcode absolute or OS-specific paths.
- If a path must live in a config file, wrap it in the language's path abstraction when parsing.
