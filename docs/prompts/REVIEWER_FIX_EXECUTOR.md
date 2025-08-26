@agent-rollcall-swift-coder

Title
Auto-Resolve Reviewer Findings — Stabilize CI Before Next Architect Pass

Pre-Flight (read FIRST)
1) Open “RollCall Development Guidelines” and internalize:
   - Iterative Workflow (P0 Loop) — Agent Contract
   - P0 Plan (JSON) — Handoff Schema & Definition of Done
   - ROADMAP & Anchors Contract, CI Metrics Contract
   - MVVM-C rules, zero-lint/format policy, a11y requirements
2) Priorities (must follow in order):
   a) Tests compile & RUN without hangs
   b) Coverage ≥ 60% (keep or improve)
   c) SwiftFormat no diffs, SwiftLint = 0
   d) CI build+test GREEN
3) If something is unknown, choose minimal, standards-compliant defaults and record under **Assumptions** in the PR.

Inputs (paste below)
- Reviewer output (raw text):
<PASTE REVIEWER COMMENTS HERE>

- Latest CI facts (ci-metrics.json):
<PASTE JSON HERE>

- Current PR/branch context (optional):
<NOTES / FILES TO CHECK>

Objective (strict)
Resolve **all** issues named by the reviewer. Keep work inside the current PR unless a separate P0 item is explicitly required. Do NOT expand scope or modify ROADMAP anchors. When CI is green and DoD is satisfied, output a short “READY_FOR_ARCHITECT” summary with fresh metrics.

Work Policy
- TDD: reproduce → failing test (if applicable) → fix → refactor.
- Prefer refactors (split files/types; extract helpers) over disabling lint rules.
- Track async Tasks started during tests and cancel in tearDown().
- Keep ViewModels UI-free; DI via initializers; a11y labels/hints on any touched UI.

Resolution Playbook (execute in order)
1) **Stop test hangs**
   - Run single-threaded with strict timeouts:
     xcodebuild -scheme "RollCall" -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16' \
       -parallel-testing-enabled NO -maximum-parallel-testing-workers 1 \
       -test-timeouts-enabled YES -default-test-execution-time-allowance 60 test
   - Bisect with -only-testing to isolate class/test.
   - Fix causes: always fulfill expectations; avoid DispatchQueue.main.sync; resume all continuations; cancel Tasks in tearDown(); guard long loops with Task.isCancelled; use short XCTWaiter timeouts (1–2s).
2) **Formatter drift**
   - Pin SwiftFormat version (Mint or pinned tool); harmonize .swiftformat to match lint policy; run swiftformat . until no diffs; make CI fail fast on format diffs.
3) **Lint = 0 (keep it)**
   - Ensure no rule disables were introduced; split long files/types to satisfy length/complexity rules if needed.
4) **Coverage & stability**
   - Keep coverage ≥ 60%; add minimal tests if your fixes reduced coverage.
5) **Re-enable CI defaults** (optional)
   - After stability proven locally, keep parallel testing OFF in CI for one cycle; re-enable in a follow-up P0 if needed.

Acceptance (must pass locally and in CI)
- `swiftformat --lint .` → no changes
- `swiftlint` → 0 violations
- `xcodebuild … test` (single-threaded flags above) → completes with no timeouts/hangs
- CI `build/test` job GREEN; coverage ≥ 60%

PR Requirements
- Keep this PR scoped to reviewer-identified issues.
- PR title includes related P0 id(s) if any, and “review-fix”.
- PR body includes:
  - **Fixed Issues** (bullet list mapping reviewer comments → changes)
  - **Assumptions** (if any)
  - **Verification Commands** (you ran them)
  - **DoD checklist** from Guidelines (checked)

Verification Commands (run before push)
- xcodebuild -scheme RollCall -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16' \
  -parallel-testing-enabled NO -maximum-parallel-testing-workers 1 \
  -test-timeouts-enabled YES -default-test-execution-time-allowance 60 test
- swiftformat --lint .
- swiftlint

Output (when done)
1) A concise status block:

READY_FOR_ARCHITECT
build_main=GREEN
build_tests=GREEN
coverage_percent=<number>
swiftlint_remaining=0
notes=“Review issues resolved; tests stable; formatter pinned.”

2) If anything still blocks, output instead:

BLOCKED_FOR_ARCHITECT
reason=<short reason>
owner_action=<your next concrete step>
need_human=<yes|no>

Do NOT edit ROADMAP.md or call other agents.
