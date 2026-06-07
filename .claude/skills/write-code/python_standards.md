<!-- FRAMEWORK FILE: improvements → PR to semantic-autoencoder -->

# Python Coding Standards

These apply **in addition to** `generic_standards.md` for all Python decoded packages.

## Style and formatting

- Follow PEP 8.
- Enforce formatting and linting with **Ruff** (replaces Black + Flake8); use its autofix.

## Documentation

- Write **Google-style docstrings** for all public functions and classes.

## Type hints

- Add explicit type hints to every function and method.
- Type-check with **mypy**.

## Testing

- Use **pytest** for all tests.
- See the tester agent for the regression test structure inside decoded packages.

## Paths

- Use `pathlib.Path` for all file, data, and config paths — never raw strings.
- Keep paths relative to the package or CWD.
- If a path must live in a config file (JSON/YAML), wrap it in `Path` when parsing.

## Pre-commit hooks

- Configure `pre-commit` to run Ruff (and other tools) on every commit.

## Version control

- Named feature branches: `yourname/branch-name`.
- Conventional commit messages: `type: brief summary (#issue)`.
- Squash and merge; delete feature branches after merging.

## Library idioms

- **scikit-learn**: follow `fit`/`transform`/`predict`; build transformers on `BaseEstimator`/`TransformerMixin`; compose with `Pipeline`.
- **PyTorch**: encapsulate models in a custom `torch.nn.Module`; use `LightningModule` to structure training; avoid hand-rolled training loops.
- Match the idioms of whatever library you build on rather than inventing parallel patterns.
