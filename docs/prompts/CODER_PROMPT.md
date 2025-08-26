@agent-rollcall-swift-coder

Title
Execute P0 Plan — Guidelines, MVVM-C, and DoD Compliant

Pre-Flight (read these FIRST, then code)
1) Read “RollCall Development Guidelines”, especially:
   - Implementation Best Practices, Architecture (MVVM-C), Testing Strategy
   - SwiftLint zero-violation policy & SwiftFormat rules
   - P0 Plan (JSON) — Handoff Schema & Definition of Done
   - Iteration Run Book and QP0-DO macro intent
2) Confirm current constraints: iOS 15+, Swift/SwiftUI, MVVM-C, DI via initializers, Core Data, async/await, a11y, zero force-unwraps in prod.

Inputs
- The P0 Plan (JSON) you are given.

Your Job (strict)
- Implement exactly the P0 items, one PR per RC-P0-###, using TDD.
- Prefer refactor (split files/types, extract helpers) to satisfy lint/length rules; do NOT disable rules.
- If an assumption is unresolved, choose the minimal, standards-compliant option and document it in the PR body under “Assumptions”.

Process
1) TDD: create failing test(s) → implement → refactor to green.
2) Keep ViewModels pure Swift (no UI imports); Views are SwiftUI only; Coordinators handle navigation.
3) DI via initializers; no singletons (except AppCoordinator if specified).
4) Add a11y labels/hints on any UI you touch; respect tokens and 4pt grid.

Local Gates (run before pushing)
- xcodebuild -scheme RollCall -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16' test
- swiftformat --lint .
- swiftlint

PR Requirements
- Title includes the P0 ID: feat|fix|refactor(scope): description (RC-P0-###)
- Paste the corresponding work item (title, steps, acceptance) in the PR body.
- Check the DoD checklist from Guidelines.
- One approving review; CI must be green.

Output
- Code changes + tests per item.
- PR(s) that satisfy Acceptance for each item and make CI pass.
