# GitHub Copilot — Project-specific instructions for quickshel (v0.2)

## Purpose
# GitHub Copilot — Project-specific instructions for quickshel (v0.2)

## Purpose
- Always consult the official QuickShell documentation at https://quickshell.org/docs/v0.2.1/ (QuickShell v0.2.1) for authoritative guidance on configuration and runtime behavior.
- Treat the attached project at `#file:example` as the single source of truth for design, configuration, assets and style decisions. Do not modify files inside the `#file:example` folder; use them only as inspiration for configuration, syntax, and design patterns.
- Always target quickshel v0.2 and Qt 6.10; do not assume other runtime versions unless explicitly instructed.
- Refer to official Qt 6 documentation (https://doc.qt.io/qt-6/) for correctness of QML/Qt APIs and configuration.

## Primary rules
1. Always consult `#file:example` before proposing code, config changes, or design changes. Prefer reusing components, styles and patterns from that tree.
2. For Qt/QML specifics, consult official Qt 6 documentation only for import syntax, QML types, bindings and module configuration. Use Qt 6.10 semantics and APIs.
3. Respect the repository layout and conventions:
    - QML components: `components/`, `modules/`, `services/`
    - Configuration files: `config/`

    ## Purpose
    # GitHub Copilot — Project-specific instructions for quickshel (v0.2)

    ## Purpose
    - Always consult the official QuickShell documentation at https://quickshell.org/docs/v0.2.1/ (QuickShell v0.2.1) for authoritative guidance on configuration and runtime behavior.
    - Treat the attached project at `#file:example` as the single source of truth for design, configuration, assets and style decisions. Do not modify files inside the `#file:example` folder; use them only as inspiration for configuration, syntax, and design patterns.
    - Always target quickshel v0.2 and Qt 6.10; do not assume other runtime versions unless explicitly instructed.
    - Refer to official Qt 6 documentation (https://doc.qt.io/qt-6/) for correctness of QML/Qt APIs and configuration.

    ## Primary rules
    1. Always consult `#file:example` before proposing code, config changes, or design changes. Prefer reusing components, styles and patterns from that tree.
    2. For Qt/QML specifics, consult official Qt 6 documentation only for import syntax, QML types, bindings and module configuration. Use Qt 6.10 semantics and APIs.
    3. Respect the repository layout and conventions:
        - QML components: `components/`, `modules/`, `services/`
        - Configuration files: `config/`
        - Build files: top-level `CMakeLists.txt`, `extras/`, `plugin/`, `nix/` (note: do not introduce or require editing build systems for config-only changes, this #example folde ris for a repositery ignore all cmake and nix related things, becuase thaht system is nix based)
        - Assets, shaders, scripts: `assets/`, `utils/scripts/`
    4. Reuse existing component naming and styles (e.g., `Styled*`, `IconButton`, `MaterialIcon`). Match casing, property names and signal names observed in the tree.
    5. Follow `.clang-format` and project coding style. Keep formatting consistent with existing files.
    6. Prefer QML-first solutions when the project uses QML. Introduce C++ only when strictly required for performance, platform APIs, or when QML cannot express the behavior.
    7. Do not require Nix or CMake workflows for configuration changes. For local verification on the user's environment (Arch Linux + Hyprland), prefer running the QuickShell binary directly using system Qt 6.10 packages.

    ## UI/UX guidance
    - Prioritize fluid, polished animations and motion design consistent with the example tree. When asked to implement visual or interaction changes, implement smooth, performant animations and transitions using existing patterns and assets.
    - Use the project's shaders, easing curves, and components to achieve a responsive look-and-feel; prefer hardware-accelerated effects and avoid blocking the UI thread.

    ## Implementation guidance when asked to produce code
    - Provide minimal, complete edits scoped to specific files. Show the exact new file path and full file contents in the response (ready to save).
    - If modifying existing files, provide a concise patch/unified diff or the full updated file content.
    - Prefer small, reviewable changes. When adding features, also add or update a config in `config/` to match project conventions.
    - Use explicit QML import lines that match Qt 6.10, for example:
      ```qml
      import QtQuick 6.10
      import QtQuick.Controls 6.10
      ```
    - Use existing assets and shaders by referencing relative paths used in the repo (`assets/`, `components/`, etc.).

    ## Verification and local testing
    - Run changes locally by launching QuickShell on your Arch Linux + Hyprland environment and observing runtime output and errors. Provide exact terminal commands for verification and capture logs/output to validate behavior.
      - Example runtime checks (Wayland/Hyprland):
        - quickshell --config /path/to/config
        - QT_QPA_PLATFORM=wayland quickshell --config /path/to/config
      - Capture stdout/stderr and share relevant error traces or UI output snippets. Report expected output and any deviations.
    - Do not introduce Nix/CMake build instructions in verification steps unless explicitly requested.

    ## Documentation and external references
    - QuickShell docs (authoritative for QuickShell config): https://quickshell.org/docs/v0.2.1/
    - Authoritative Qt docs: https://doc.qt.io/qt-6/

    ## Interaction protocol
    For each instruction provided by the user (one-by-one):
    - Confirm any ambiguous requirements with 1–2 clarifying questions.
    - Produce the best-working implementation:
      - Full file(s) in code blocks, concise explanation (1–3 lines), and suggested verification steps.
      - If changes span multiple files, list all modified paths and show their full contents.
      - Provide run commands for verification on the user's environment (Arch Linux/Hyprland) and a short test-case or verification steps.
    - When breaking changes are proposed, include a migration note and automated upgrade steps if possible.

    ## Safety and scope
    - Do not change project-wide policies (license, CI names) without explicit approval.
    - Do not invent global services or architectures not evidenced by `#file:example`.
    - If a requested change would violate Qt 6.10 compatibility or repository constraints, refuse and propose an alternative that preserves compatibility.

    ## Examples of expected outputs
    - New QML component: full file contents, correct imports (Qt 6.10), properties and signals following existing patterns.
    - Configuration change: updated file under `config/` matching project conventions and example patterns.
    - Verification: exact terminal commands to run QuickShell, captured output snippets and suggested fixes.

    ## When ready
    - After you provide the first instruction, I will confirm any ambiguities (1–2 brief questions) then produce requested file edits, code and verification steps following these rules.

