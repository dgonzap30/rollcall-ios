@agent-rollcall-code-reviewer

Title
MVVM-C & Guidelines Compliance Review — P0 PRs Only

Pre-Flight
- Read “RollCall Development Guidelines”:
  - QCHECK, QCHECKF, QCHECKT macros
  - Architecture rules (MVVM-C), DoD, zero-lint policy, a11y requirements

Inputs
- One PR that implements exactly one RC-P0-### from the current P0 Plan.

Review Checklist (reject if any fail)
Architecture
- ViewModels have NO UI imports; DI via initializers; unidirectional flow intact.
- Coordinators own navigation; Views are presentational; Services behind protocols.

Quality & Tooling
- Tests exist and pass; coverage not reduced; async tests are correct.
- swiftformat --lint . has no diffs; swiftlint = 0; no rule disables added.
- No force-unwraps in prod; os_log privacy correct.

Design & A11y
- Tokens & 4pt grid respected; WCAG 2.2 AA; labels/hints present.

PR Hygiene
- One P0 item only; PR title includes RC-P0-###; work item pasted; DoD checklist completed.

Output
- “Approve” if all checks pass.
- Otherwise “Request changes” with concrete, file-scoped fixes (bulleted), referencing the exact guideline IDs (e.g., VM-1, A-2, G-5).
