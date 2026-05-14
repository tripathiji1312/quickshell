# Contributing to QuickShell Configuration

Thanks for your interest in contributing! This document explains how to report issues, propose changes, and submit pull requests for this QuickShell configuration.

## Code of Conduct
Be respectful and constructive. If the project does not yet include an explicit Code of Conduct, please follow the [Contributor Covenant v2.0](https://www.contributor-covenant.org/version/2/0/code_of_conduct/).

## Before you start
- Search existing issues and pull requests to avoid duplicates.
- Consult maintainer-provided style guidance and the repository's existing components for design and style references.
- Target QuickShell v0.2 and Qt 6.10 compatibility when editing QML and config.

## Reporting Issues
When filing an issue, include:

- **Summary**: one-line description of the problem.
- **Steps to reproduce**: exact steps, sample config, or the QML file causing the issue.
- **Environment**: QuickShell version, Qt version (6.10), compositor (e.g. Hyprland) and OS.
- **Logs & screenshots**: add relevant logs from the `logs/` directory and a screenshot if visual.

Good issue reports speed up fixes — be as precise as possible.

## Security
If you discover a security vulnerability, please follow the instructions in `SECURITY.md` and report privately via GitHub Security Advisories (recommended) or contact the maintainers. Do not disclose vulnerabilities publicly until a fix or coordinated disclosure is available.

## Proposing Changes (Features / Fixes)
1. Fork the repository and create a branch named using this pattern:
   - `feature/<short-description>` for new features
   - `fix/<short-description>` for bug fixes
2. Keep changes focused and small; one logical change per branch makes reviews faster.
3. Reuse existing components and styles from the `components/`, `modules/`, and `services/` folders.
4. Follow the repository's conventions: QML-first solutions, explicit QtQuick imports (target Qt 6.10), and consistent naming (e.g., `Styled*`, `IconButton`).

## Coding Style
- Prefer QML and existing patterns; introduce C++ only when strictly necessary.
- Match indentation and formatting used in the repo. If a formatter is available, run it before submitting.
- Add new QML components to their appropriate `qmldir` and update any indexes if present.

## Commit Messages
- Use imperative, concise summaries (e.g., "Add volume popup action").
- If needed, include a short body explaining the motivation and any breaking changes.

## Pull Request Process
- Open a PR against `main` (or the branch specified by maintainers). Include a clear description and link to related issues.
- Keep PRs small and focused. Large changes may be split into multiple PRs.
- Maintain backwards compatibility with user configs when possible; clearly document any required migration steps.
- Reviewers may request changes — please respond to feedback promptly.

## Testing & Verification
- Run `./setup.sh` for environment checks and follow the project's verification steps.
- To test UI changes quickly, use the project's reload script: `./reload-quickshell.sh` after making changes.
- Verify QML imports are `QtQuick 6.10` and that components work on Wayland/Hyprland if applicable.

## Adding New Features or Components
- Add new assets under `assets/` and reference them with relative paths.
- Place reusable UI elements in `components/` and add module entries to `qmldir` as needed.

## Security and Sensitive Data
- Do not commit secrets, private keys, or personal credentials. Use placeholders in examples and configuration snippets.

## Want to help but unsure where to start?
- Look for issues tagged `good first issue` or `help wanted`.
- Ask on an issue or open a discussion proposing a small, incremental improvement.

## Thanks
Thanks for improving this project — contributions are welcome! We have included a `CODE_OF_CONDUCT.md` and PR templates to help streamline collaboration. When opening a pull request, please follow the PR template and keep changes focused.
