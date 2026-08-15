# Contributing to ForgeFPV

Thank you for helping harden ForgeFPV. This project is a **playable tactical trainer**. Protecting flight feel is more important than clever refactors.

## Before you change code

1. Read [docs/CHANGE_POLICY.md](docs/CHANGE_POLICY.md).
2. Read [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).
3. If your change affects flight, controls, scoring, or aquatic physics, **get explicit approval** first.

## Preferred contribution types

- Documentation accuracy
- Export / release process
- Bug fixes that restore documented behavior
- Additive maps following `BaseTrainingScene`
- Tooling under `tools/`

## Workflow

1. Branch from `main`.
2. Keep doc-only commits separate from logic commits.
3. Manually smoke-test: MainMenu → Donbas → target hit → ESC menu.
4. Describe test steps in the PR / commit message.

## Style

- GDScript: clear names, no silent gameplay tuning “while there”.
- Do not reformat entire files unrelated to your change.
- Match existing folder ownership (see `docs/DIRECTORY_MAP.md`).

## Security / compliance

- Do not commit secrets, certs, or large binary exports.
- Do not add real-world restricted technical data that would create ITAR/EAR issues in a public repo.
