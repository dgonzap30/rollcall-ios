# RollCall Development Guidelines

## Implementation Best Practices

### 0 — Purpose  

These rules ensure maintainability, safety, and developer velocity for RollCall - the social sushi logging app.
**MUST** rules are enforced by CI; **SHOULD** rules are strongly recommended.

---

### Iterative Workflow (P0 Loop) — Agent Contract

> Goal: Keep the plan truthful and shippable by iterating only on P0 (3–7 atomic, testable tasks) and syncing the canonical ROADMAP.md anchors.

#### Single Source of Truth

ROADMAP.md with anchors:
- `<!-- P0_TASKS -->` … `<!-- /P0_TASKS -->`
- `<!-- METRICS -->` … `<!-- /METRICS -->`
- `<!-- CHANGELOG -->` … `<!-- /CHANGELOG -->`
- `<!-- MACHINE_STATE -->` … `<!-- /MACHINE_STATE -->`

#### Roles

- **Architect agent**: Updates the four anchors only; emits a P0 Plan (JSON). No coding.
- **Coder agent**: Implements exactly the P0 Plan (one PR per RC-P0-###).
- **CI**: Publishes real metrics that drive the next Architect pass.

#### Loop (every iteration)

1. CI runs → emit ci-metrics.json (see schema below)
2. Architect reads ROADMAP anchors + metrics → rewrites anchors + outputs a P0 Plan JSON
3. Coder implements the plan (TDD, one PR per P0 item)
4. Merge → CI refreshes metrics → repeat

#### P0 Definition

- Only what unblocks MVP now (tests compile → coverage real → lint=0 → gates green)
- Atomic, testable, independently verifiable; each item has ID RC-P0-###

---

### 1 — Before Coding

- **BP-1 (MUST)** When a human is available, ask clarifying questions before coding.
- **BP-1a (MUST for agents)** In automated runs, proceed with minimal, standards-compliant defaults and record unknowns under assumptions in the P0 Plan JSON (do not block on questions).
- **BP-2 (SHOULD)** Draft and confirm an approach for complex work.  
- **BP-3 (SHOULD)** If ≥ 2 approaches exist, list clear pros and cons.

---

### 2 — While Coding

- **C-0 (MUST)** RollCall targets iOS 15+. All SwiftUI code requires `@available(iOS 15.0, *)`.
- **C-1 (MUST)** Follow TDD: write failing test -> implement -> refactor.
- **C-2 (MUST)** Name functions/types consistently with existing domain vocabulary (e.g., `Roll` for sushi entries, `Chef` for users).  
- **C-3 (SHOULD NOT)** Create complex class hierarchies when protocols and value types suffice.  
- **C-4 (SHOULD)** Prefer small, composable, testable functions over monolithic implementations.
- **C-5 (MUST)** Use strong typing for domain models:
  ```swift
  struct RollID: Hashable { let value: UUID }   // ✅ Good
  typealias RollID = UUID                       // ❌ Bad
  ```  
- **C-6 (MUST)** Mark SwiftUI views with `@MainActor`. ViewModels should NOT carry `@MainActor`; instead use `@MainActor` only on methods that update UI.
- **C-7 (SHOULD)** Add comments only for business rules, edge-case rationale, or non-obvious workarounds. Prefer self-explanatory code otherwise.
- **C-8 (SHOULD)** Prefer `struct` over `class` unless reference semantics or inheritance is required. 
- **C-9 (SHOULD)** Use Swift's Result type for operations that can fail.
- **C-10 (MUST)** Use `async`/`await` for all asynchronous operations.
- **C-11 (MUST)** Wrap SwiftUI extensions in `#if canImport(SwiftUI)` for future platform flexibility.
- **C-12 (MUST)** All builds must use Xcode exclusively. SwiftPM is not supported.
- **C-13 (SHOULD)** Leverage Swift 5.10 features like macros and `#Preview` for better developer experience, but keep usage behind `#if swift(>=5.10)` until Xcode 17 is stable.
- **C-14 (SHOULD)** Avoid ambiguous range operators by using parentheses: `-150...(-50)` instead of `-150...-50`. This is enforced via SwiftLint.

---

### 3 — Testing

- **T-1 (MUST)** Colocate unit tests in `Tests/[Module]Tests/` matching source file names.
- **T-2 (MUST)** For UI components, test view state logic separately from SwiftUI views.
- **T-3 (MUST)** Separate pure logic unit tests from integration tests requiring network/database.
- **T-4 (SHOULD)** Test edge cases for sushi-specific logic (e.g., roll ratings, chef rankings).  
- **T-5 (SHOULD)** Use `@MainActor` for tests involving UI components.
- **T-6 (SHOULD)** Prefer one logical expectation per test; multiple assertions are fine when they describe the same invariant.
- **T-7 (MUST)** Coverage is read from the Xcode *.xcresult via xcrun xccov (or slather) and written into ci-metrics.json.

---

### 4 — Architecture (MVVM-C)

> RollCall follows MVVM-C (Model-View-ViewModel-Coordinator) architecture for clean separation of concerns and testability.

#### Module & Target Layout

```
/App                 ← AppDelegate / SceneDelegate / AppCoordinator
/Core                ← Business & domain logic (no UI, no Apple frameworks)
/UI (DesignKit)      ← Reusable SwiftUI views, modifiers, color & typography tokens
/Features/Auth       ← AuthCoordinator, LoginViewModel, LoginView
/Features/Feed       ← FeedCoordinator, FeedViewModel, …
/Networking          ← API client, DTO ↔ Model mappers, error handlers
/Support             ← Preview data, dev–only utilities (excluded from Release)
```

#### Naming Conventions

| Element | Suffix | Example |
| ------- | ------ | ------- |
| SwiftUI view | View | LoginView.swift |
| View model | ViewModel | LoginViewModel.swift |
| Coordinator | Coordinator | AuthCoordinator.swift |
| Protocol abstractions | Servicing | AuthServicing |
| Mock implementations | Mock | AuthServiceMock.swift |

#### Core Architecture Rules

- **A-1 (MUST)** Keep business logic in Core, UI logic in Features/UI modules.
- **A-2 (MUST)** ViewModels contain NO UIKit/SwiftUI imports - pure Swift only.
- **A-3 (MUST)** Use unidirectional data flow: View → ViewModel → Service → ViewModel → View.
- **A-4 (MUST)** Coordinators handle all navigation; Views never access navigationController.
- **A-5 (MUST)** Define all API models as `Codable` structs in Core.
- **A-6 (MUST)** Use dependency injection via initializers, no singletons except AppCoordinator.

#### Unidirectional Data Flow

```
[User Tap] → View → ViewModel → Service
                                 ↓
                          ViewModel (state)
                                 ↓
                              View (UI)
                                 ↓
                          Coordinator (nav)
```

#### ViewModel Guidelines

- **VM-1 (MUST)** No UIKit/SwiftUI imports - unit test friendly
- **VM-2 (MUST)** Expose minimal `struct ViewState` so views don't see business objects
- **VM-3 (MUST)** Use `@Published private(set)` for observable state
- **VM-4 (SHOULD)** Keep async work in `Task { await service.fetch() }` blocks
- **VM-5 (SHOULD)** Add lightweight input methods for user intents (e.g., `func onLoginTapped()`)
- **VM-6 (MUST)** Use `@MainActor` only on methods that directly update UI, not on the entire ViewModel

#### Coordinator Guidelines

- **CO-1 (MUST)** One coordinator per navigation tree (Auth, MainTab, Settings)
- **CO-2 (MUST)** Coordinators own UINavigationController/NavigationStack, never the reverse
- **CO-3 (MUST)** Expose `start()` returning the root UIViewController/View
- **CO-4 (SHOULD)** Use Combine subjects to receive events from child ViewModels
- **CO-5 (SHOULD)** Retain child coordinators strongly while active (using arrays/dictionaries is allowed)

#### Service/Repository Layer

- **SR-1 (MUST)** Define protocols (e.g., `UserServicing`) in Core, concrete classes in Networking
- **SR-2 (MUST)** Return domain models, never URLSession/DTOs
- **SR-3 (MUST)** Centralize error mapping to AppError enum
- **SR-4 (SHOULD)** Add caching decorators behind the same protocol
- **SR-5 (MUST)** Use Core Data for local persistence. Schema files live in Core/Persistence/
- **SR-6 (SHOULD)** Wrap unfinished screens behind compile-time or runtime feature flags

#### Memory Management

- **MM-1 (MUST)** Mark service closures `[weak self]` in ViewModels
- **MM-2 (MUST)** Avoid reference cycles between Coordinator ↔ ChildCoordinator
- **MM-3 (MUST)** UI updates on `@MainActor`; heavy parsing on background queue
- **MM-4 (SHOULD)** Confirm zero leaks in Instruments before each release

#### Testing Strategy

| Layer | Test Type | Coverage Target |
| ----- | --------- | --------------- |
| ViewModel | Unit tests, async | >60% (MVP), >80% (Beta) |
| Services | Unit with mocks | >60% (MVP), >80% (Beta) |
| Coordinators | Integration | Post-MVP |
| Views | Snapshot (optional) | Critical flows |

#### Concurrency Guide

- **CG-1 (MUST)** Use structured concurrency with `Task {}` for async work
- **CG-2 (SHOULD)** Prefer `async let` for concurrent operations that can run in parallel
- **CG-3 (SHOULD)** Mark types as `@unchecked Sendable` only after careful audit
- **CG-4 (SHOULD)** Use `TaskGroup` for dynamic collections of concurrent work
- **CG-5 (MUST)** Handle task cancellation appropriately with `Task.checkCancellation()`
- **CG-6 (MUST)** Use `[weak self]` in Task closures when self is captured:
  - ✅ Required: When Task is stored as a property (animationTask, floatingAnimationTask)
  - ✅ Required: Long-running tasks that might outlive the object
  - ✅ Required: Tasks in ViewModels to prevent retain cycles
  - ❌ Exception: @MainActor contexts where Task is not stored

##### Task [weak self] Guidelines

```swift
// ✅ Use [weak self] - Task stored as property
private var animationTask: Task<Void, Never>?

func startAnimations() {
    animationTask = Task { [weak self] in
        await self?.performAnimationSequence()
    }
}

// ✅ Use [weak self] - Even for short tasks in ViewModels
func onButtonTapped() {
    Task { [weak self] in
        await self?.hapticService.impact(style: .light)
    }
}

// ✅ Use [weak self] - Long-running animation loops
func startFloatingAnimation() {
    floatingTask = Task { [weak self] in
        while !Task.isCancelled {
            guard let self else { return }
            await MainActor.run {
                self.viewState.offset = 10
            }
            try? await Task.sleep(nanoseconds: 1_000_000_000)
        }
    }
}
```

---

### 5 — Code Organization

- **O-1 (MUST)** Place shared types/logic in CoreKit only if used by multiple targets.
- **O-2 (SHOULD)** Group related files by feature (e.g., `Roll/`, `Chef/`, `Restaurant/`).
- **O-3 (MUST)** Keep SwiftUI views under 150 lines excluding previews and private extensions; extract subviews as needed.

---

### 6 — Tooling & Static Analysis

- **G-1 (MUST)** `xcodebuild` passes without warnings.  
- **G-2 (MUST)** `xcodebuild test` passes.  
- **G-3 (MUST)** Code formatted with SwiftFormat.
- **G-4 (MUST)** No force unwrapping (`!`) except in tests or with clear safety comments.
- **G-5 (SHOULD)** SwiftLint runs on every build aiming for zero violations. Temporary thresholds allowed during burn-down; must ramp to 0 within the next iteration. CI enforces 0 after that.
- **G-6 (MUST)** Dependency scanning runs in CI to check for vulnerabilities.
- **G-7 (SHOULD)** Run license-compliance scan monthly to ensure dependencies are appropriately licensed.
- **G-8 (SHOULD)** Configure terminal/CI to exit immediately when tests complete:
  ```bash
  # Set shorter timeout for test execution
  xcodebuild -project RollCall.xcodeproj -scheme RollCall test \
    -destination 'platform=iOS Simulator,name=iPhone 16' \
    -test-timeouts-enabled YES \
    -default-test-execution-time-allowance 60 \
    | xcpretty --test --color
  
  # Add to shell profile for faster test feedback
  alias rolltest='xcodebuild -project RollCall.xcodeproj -scheme RollCall test -destination "platform=iOS Simulator,name=iPhone 16" -test-timeouts-enabled YES | xcpretty -t && echo "Tests completed"'
  ```
- **G-9 (SHOULD)** Set reasonable test timeouts in test configuration:
  ```swift
  // In XCTestCase subclasses
  override func setUp() {
      super.setUp()
      // Prevent tests from hanging indefinitely
      executionTimeAllowance = 60.0  // 60 seconds max per test
  }
  ```

---

### 7 — Git & Branching

- **GH-1 (MUST)** Use Conventional Commits format: https://www.conventionalcommits.org/en/v1.0.0
- **GH-2 (SHOULD NOT)** Refer to Claude or Anthropic in commit messages.
- **GH-3 (SHOULD)** Include ticket/issue number in commit messages when applicable.
- **GH-4 (MUST)** Follow branching strategy:
  - `main` - production releases only
  - `develop` - next release integration
  - `feature/*` - new features
  - `bugfix/*` - bug fixes
  - `hotfix/*` - emergency production fixes
- **GH-5 (MUST)** All PRs require:
  - One approving review
  - All CI checks passing
  - Up-to-date with target branch

#### P0 IDs & PR Requirements

- **GH-6 (MUST)** Branch names and PR titles include the P0 ID: `feat(feed): split view model (RC-P0-012)`
- **GH-7 (MUST)** One PR per RC-P0-###
- **GH-8 (MUST)** PR must include the DoD checklist and paste the work item from the P0 Plan JSON (title, steps, acceptance)

---

### 8 — CI/CD Pipeline

#### GitHub Actions Workflow

```yaml
name: CI/CD
on:
  pull_request:
  push:
    branches: [main, develop]

jobs:
  build-test:
    runs-on: macos-latest
    steps:
      - Checkout code
      - Setup Xcode
      - Run SwiftLint
      - Run SwiftFormat --verify
      - Build project
      - Run tests with coverage
      - Upload coverage to Codecov
      
  security:
    runs-on: ubuntu-latest
    steps:
      - Dependency audit
      - SAST scan
      
  deploy:
    if: github.ref == 'refs/heads/main'
    needs: [build-test, security]
    steps:
      - Build for release
      - Upload to TestFlight
      - Upload dSYMs to Sentry
```

- **CI-1 (MUST)** Every PR runs: lint, format check, build, test, security scan
- **CI-2 (MUST)** Maintain >60% code coverage (MVP), >80% (Beta)
- **CI-3 (SHOULD)** Deploy to TestFlight on merge to main
- **CI-4 (MUST)** Upload dSYMs for crash reporting

#### CI Metrics Contract (drives the Architect)

**CI must upload a ci-metrics.json artifact on every run:**

```json
{
  "build_main": "green|yellow|red",
  "build_tests": "green|yellow|red",
  "coverage_percent": 73.6,
  "swiftlint_remaining": 12,
  "test_failures": ["CreateRollCoordinatorTests"]
}
```

**Thresholds:**
- MVP: coverage ≥ 60%, swiftlint_remaining == 0 (target; allow temporary thresholds only while burning down)
- Beta: coverage ≥ 80%

**Fail fast order:**
1. Format (no diffs)
2. Lint (0)
3. Build
4. Tests
5. Security

---

### 9 — Logging & Monitoring

- **LM-1 (MUST)** Use `os_log` with appropriate privacy levels:
  ```swift
  logger.debug("User \(userID, privacy: .private) viewed roll")
  logger.error("API failed: \(error, privacy: .public)")
  ```
- **LM-2 (MUST)** Configure Sentry for crash reporting with:
  - User context (anonymized ID only)
  - Breadcrumbs for navigation
  - Performance monitoring for key flows
- **LM-3 (SHOULD)** Log analytics events for:
  - Feature usage
  - Error rates
  - Performance metrics
- **LM-4 (MUST)** Sentry forced test event must be triggered for any new surface touched as part of a P0 item

---

## ROADMAP & Anchors Contract

**Only the four anchors above are auto-managed by the Architect.**

Human-maintained sections (Philosophy, Invariants, Dashboard, Phase Backlog, Risks, DoD, Acceptance Tests) must not be edited by agents.

**Machine State JSON (inside `<!-- MACHINE_STATE -->`) must remain valid JSON and include:**

```json
{
  "version": "5.0",
  "updated_at": "YYYY-MM-DDThh:mm:ss-06:00",
  "tz": "America/Mexico_City",
  "build_main": "green|yellow|red",
  "build_tests": "green|yellow|red",
  "coverage_percent": null,
  "swiftlint_remaining": 0,
  "perf": { "save_p90_ms": null, "feed_p90_ms": null },
  "stability_crash_free_pct": null,
  "a11y_core_paths_verified": false,
  "p0_ids": ["RC-P0-###"],
  "test_failures": []
}
```

---

## P0 Plan (JSON) — Handoff Schema

```json
{
  "next_steps": [
    {
      "id": "RC-P0-###",
      "title": "Concise action",
      "rationale": "Why this unblocks MVP now",
      "deliverables": ["artifact(s) after completion"],
      "steps": ["ordered, atomic coder steps"],
      "files": ["relative/paths.swift", "Tests/..."],
      "signatures": ["struct/func signatures if relevant"],
      "tests": ["Tests/...::testName"],
      "acceptance": ["verifiable reviewer checks"],
      "dependencies": ["RC-P0-###"],
      "estimate": "S|M|L"
    }
  ],
  "definition_of_done": [
    "All tests green; coverage ≥60% overall",
    "SwiftFormat/SwiftLint clean; no force-unwraps outside tests",
    "A11y labels present on any touched views; AA contrast holds",
    "Sentry receives a forced test event if a new surface was touched",
    "os_log added with privacy where new logic introduced"
  ],
  "verification_commands": [
    "xcodebuild -scheme RollCall -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16' test",
    "swiftformat --lint .",
    "swiftlint"
  ],
  "assumptions": ["unknowns resolved with minimal, compliant defaults"],
  "open_questions": []
}
```

---

## Writing Functions Best Practices

When evaluating function quality, use this checklist:

1. Can you read the function and easily understand its purpose?
2. Does it have high cyclomatic complexity (many nested if/guard statements)?
3. Are there Swift-specific patterns that would improve it (e.g., `map`, `filter`, `compactMap`)?
4. Are all parameters used and necessary?
5. Can it be tested without mocking Core Data or network calls?
6. Does it follow Swift API Design Guidelines naming conventions?
7. Are optionals handled safely with `guard let` or `if let`?

IMPORTANT: Extract functions only when:
  - The function is reused elsewhere
  - It enables unit testing of complex logic
  - It significantly improves readability

## Writing Tests Best Practices

Test quality checklist:

1. SHOULD use descriptive test names following `test_whenCondition_shouldExpectedBehavior()` pattern.
2. SHOULD NOT test trivial getters/setters or compiler-enforced behavior.
3. SHOULD test both success and failure paths for Result-returning functions.
4. SHOULD use XCTest's async testing support for async functions.
5. SHOULD test SwiftUI view models' published properties change correctly.
6. SHOULD use property-based testing for data validation (e.g., roll ratings 1-5).
7. Group related tests under `// MARK: - Feature Name`.
8. Use `XCTUnwrap` instead of force unwrapping in tests.
9. Test boundary conditions for sushi-specific logic (empty rolls list, duplicate entries).
10. Mock external dependencies (API, location services) using protocols.

## Project Structure (MVVM-C)

```
RollCall/
├── App/                      # App lifecycle & root coordinator
│   ├── AppDelegate.swift
│   ├── SceneDelegate.swift
│   └── AppCoordinator.swift
├── Core/                     # Business logic (no UI)
│   ├── Models/              # Domain models (Roll, Chef, Restaurant)
│   ├── Services/            # Service protocols
│   └── Repositories/        # Data access protocols
├── UI/                      # Design system
│   ├── Components/          # Reusable SwiftUI views
│   ├── Modifiers/          # Custom view modifiers
│   └── Tokens/             # Colors, typography, spacing
├── Features/               # Feature modules
│   ├── Onboarding/
│   │   ├── OnboardingCoordinator.swift
│   │   ├── WelcomeViewModel.swift
│   │   └── WelcomeView.swift
│   ├── Feed/
│   │   ├── FeedCoordinator.swift
│   │   ├── FeedViewModel.swift
│   │   └── FeedView.swift
│   └── Roll/
│       ├── RollCoordinator.swift
│       ├── CreateRollViewModel.swift
│       └── CreateRollView.swift
├── Networking/             # API implementation
│   ├── APIClient.swift
│   ├── DTOs/              # Data transfer objects
│   └── Mappers/           # DTO ↔ Model mappers
├── Support/               # Dev utilities
│   ├── PreviewData/
│   └── Mocks/
└── Tests/
    ├── CoreTests/
    ├── ViewModelTests/
    └── CoordinatorTests/
```

## Sushi Domain Concepts

Key domain terms to use consistently:
- `Roll` - A sushi entry/log
- `Chef` - A user who logs rolls
- `Restaurant` - Where a roll was consumed
- `Rating` - 1-5 star rating for a roll
- `Omakase` - Chef's choice experience
- `Nigiri`, `Maki`, `Sashimi` - Roll types

## Remember Shortcuts

### QNEW
```
Understand all BEST PRACTICES, ARCHITECTURE, and DESIGN PRINCIPLES listed in CLAUDE.md:
1. Review Implementation Best Practices (BP, C, T, A, O, G sections)
2. Review MVVM-C Architecture (Section 4 - A, VM, CO, SR, MM rules)
3. Review Design System principles (D-1 through D-5)
4. Review Design Addendum (AC, SL, VH, CT, IC, CD, MH, OB, MD sections)
5. Apply color tokens, typography, component specs, and 4pt spacing grid
6. Ensure WCAG 2.2 AA compliance for all UI elements
7. Follow unidirectional data flow: View → ViewModel → Service → ViewModel → View
Your code MUST follow MVVM-C architecture and all design guidelines.
```

### QPLAN
```
You are a senior iOS engineer. Analyze similar parts of the codebase and create a plan that:
1. Follows MVVM-C architecture patterns:
   - Coordinator handles navigation
   - ViewModel contains business logic (no UI imports)
   - View is purely presentational
   - Services defined as protocols in Core
2. Is consistent with existing codebase structure
3. Reuses existing components from UI/ and Core/
4. Follows Swift/SwiftUI conventions
5. Maintains unidirectional data flow
6. Uses dependency injection (no singletons)
7. Applies 4pt spacing grid and design tokens
```

### QCODE
```
You are a senior iOS engineer. Implement your plan following MVVM-C architecture and Swift best practices:
1. ViewModels: Pure Swift, no UIKit/SwiftUI imports
2. Views: SwiftUI only, bind to ViewModel's @Published properties
3. Coordinators: Handle all navigation logic
4. Use WelcomeConstants-style organization for magic numbers
5. Apply design tokens (colors, spacing, typography)
6. Ensure WCAG 2.2 AA compliance
7. Add proper error handling with AppError enum
8. Use @MainActor only on UI update methods, not entire ViewModels
Always run `xcodebuild test` to ensure tests pass.
Always run `xcodebuild` to check for warnings.
Write ViewModel unit tests with >80% coverage.
```

### QCHECK
```
You are a SKEPTICAL senior iOS engineer reviewing MVVM-C implementation.
For every MAJOR code change:

1. Review against CLAUDE.md Implementation Best Practices (BP, C, T, A, O, G).
2. Verify MVVM-C architecture compliance:
   - ViewModels have NO UI imports
   - Coordinators own navigation
   - Unidirectional data flow maintained
   - Proper dependency injection
3. Check Design System compliance:
   - 4pt spacing grid
   - WCAG 2.2 AA contrast
   - Consistent use of design tokens
4. Review memory management (weak refs, no cycles).
5. Verify proper use of @MainActor and concurrency.
6. Ensure ViewModel testability (>80% coverage achievable).
```

### QCHECKF
```
You are a SKEPTICAL senior iOS engineer reviewing function implementation.
Review every MAJOR function against:

1. CLAUDE.md checklist Writing Functions Best Practices.
2. Swift API Design Guidelines.
3. MVVM-C principles:
   - Is this in the right layer? (View/ViewModel/Service)
   - Does it maintain unidirectional data flow?
   - Are dependencies injected, not hardcoded?
4. Proper optional handling and error propagation.
5. Testability without mocking UI frameworks.
6. Use of proper async/await patterns.
```

### QCHECKT
```
You are a SKEPTICAL senior iOS engineer reviewing test implementation.
Review every MAJOR test against:

1. CLAUDE.md checklist Writing Tests Best Practices.
2. XCTest best practices.
3. MVVM-C testing requirements:
   - ViewModels tested without UI framework mocks
   - Services mocked via protocols
   - >80% coverage for ViewModels and Services
   - Coordinators have at least smoke tests
4. Async testing patterns with proper Task handling.
5. Test naming: test_whenCondition_shouldExpectedBehavior().
6. Boundary conditions for domain logic (empty rolls, ratings 1-5).
```

### QUX
```
Imagine you are a sushi enthusiast testing RollCall.
Output a comprehensive list of scenarios you would test, sorted by priority:
- Creating and rating rolls
- Browsing other chefs' rolls
- Restaurant discovery
- Social features
```

### QGIT
```
Add all changes to staging, create a commit, and push to remote.

Follow Conventional Commits format:
<type>[optional scope]: <description>

Types: feat, fix, docs, style, refactor, test, chore
Example: feat(roll): add photo upload to roll creation
```

### QMVVMC
```
You are implementing a new feature following MVVM-C architecture.
Create the following structure:
1. Coordinator - Handles navigation logic
2. ViewModel - Pure Swift, no UI imports, exposes ViewState
3. View - SwiftUI only, binds to ViewModel
4. Service protocol in Core (if needed)
5. Unit tests for ViewModel with >80% coverage

Ensure:
- Unidirectional data flow
- Dependency injection via initializers
- No singletons except AppCoordinator
- ViewModels use @MainActor only on UI methods
```

### QDESIGN
```
Review this UI implementation against Design System and Addendum:
1. Accessibility (AC rules):
   - WCAG 2.2 AA contrast check
   - Dynamic Type support
   - Accessibility labels and focus order
   - Custom actions support
2. Spacing & Layout (SL rules):
   - 4pt grid compliance
   - Vertical rhythm maintained
3. Visual Hierarchy (VH rules):
   - One focal element
   - Weight/size before color
4. Component Standards (CD rules):
   - Proper shadows and depth
   - Consistent border radius
5. Motion (MH rules):
   - 200ms standard transitions
   - Spring animations for delight
6. Check against Design QA Checklist
```

### QP0 (Architect quick macro)
```
Use ROADMAP v5.0. Update only P0_TASKS, METRICS, CHANGELOG, MACHINE_STATE. Keep P0 3–7 atomic items that unblock MVP now. Emit the P0 Plan JSON per schema. Record unknowns in assumptions.
```

### QP0-DO (Coder quick macro)
```
Implement this P0 Plan JSON exactly. TDD first. One PR per RC-P0-###. Pass DoD. Use Conventional Commits. Fail CI on any lint/format error.
```

## Development Workflow

### Pre-Development Checklist

Before starting any new feature development:

1. **Run full audit**:
   ```bash
   ./scripts/lint.sh
   ./scripts/build.sh
   ./scripts/test.sh
   ```

2. **Check for uncommitted changes**:
   ```bash
   git status
   ```

3. **Ensure tools are installed**:
   ```bash
   which swiftlint && which swiftformat
   ```

### Development Process

1. **Before coding**: Run `./scripts/lint.sh` to ensure clean baseline
2. **During development**: 
   - Run `swiftformat .` frequently to maintain code style
   - SwiftLint runs automatically via Xcode build phase
3. **Before committing**:
   - Run `./scripts/build.sh` to ensure compilation
   - Run `./scripts/test.sh` to verify all tests pass
   - Run `./scripts/lint.sh` for final quality check

### Automated Scripts

Located in `/scripts/`:
- `build.sh` - Formats code, lints, and builds the project using xcodebuild
- `test.sh` - Runs all unit tests using xcodebuild
- `lint.sh` - Checks code formatting and style violations

### SwiftLint Configuration

SwiftLint is integrated into the Xcode build process:
- Runs automatically on every build via Xcode build phase
- Configuration in `.swiftlint.yml`
- Must be installed via Homebrew: `brew install swiftlint`
- Build phase checks for SwiftLint in both `/usr/local/bin` and `/opt/homebrew/bin`

### Iteration Run Book (P0 Loop)

1. **CI facts**: grab the latest ci-metrics.json
2. **Architect**: run the "Iterative P0 Planner — ROADMAP v5.0 (Anchor-Synced)" prompt with:
   - current ROADMAP anchors
   - the CI metrics
   - Output: updated anchors + P0 Plan (JSON)
3. **Update ROADMAP**: replace the four anchors with the returned blocks; commit `docs(roadmap): refresh P0/Metrics/State`
4. **Coder**: paste the P0 Plan JSON into the coder prompt; implement one PR per P0 item with the DoD checklist
5. **Merge** → CI refreshes → go back to step 1

**North-star order**: tests compile → coverage real → lint = 0 → gates green

## SwiftLint Compliance

### Mandatory Zero-Violation Policy

- **G-5 (MUST)** All code MUST pass SwiftLint with zero violations before commit.
- **G-5a (MUST)** No trailing commas in collection literals (arrays, dictionaries).
- **G-5b (MUST)** Opening braces must be on the same line as the declaration.
- **G-5c (MUST)** Type bodies must be ≤250 lines, function bodies ≤50 lines, files ≤400 lines.
- **G-5d (MUST)** Use explicit parameter labels for Button(action:label:) instead of trailing closure.
- **G-5e (MUST)** Tuples are limited to 2 members maximum. Use structs for 3+ elements.
- **G-5f (MUST)** Lines must be ≤120 characters. Break long strings with concatenation.
- **G-5g (MUST)** Remove unused variables or use `_` assignment for intentionally unused values.

### Prevention Guidelines

#### Code Organization
- **SL-1 (SHOULD)** Extract helper methods when type bodies exceed 200 lines.
- **SL-2 (SHOULD)** Split test classes when they exceed 200 lines:
  - CoreTests: Initialization, basic functionality
  - CodableTests: Encoding/decoding, Sendable conformance
  - EqualityTests: Equatable, Hashable, comparison tests
- **SL-3 (SHOULD)** Move private helper methods to extensions to reduce type body size.

#### Swift 6 Compatibility
- **SC-1 (MUST)** Mark protocol methods with @MainActor when implementations are @MainActor:
  ```swift
  protocol MyProtocol {
      @MainActor func uiMethod()  // Required if implementers are @MainActor
  }
  ```

#### Collection Syntax
- **CS-1 (MUST)** Never add trailing commas to collection literals:
  ```swift
  // ✅ Correct
  let colors = [
      .rcPink500,
      .rcGradientOrange
  ]
  
  // ❌ Wrong
  let colors = [
      .rcPink500,
      .rcGradientOrange,  // Trailing comma
  ]
  ```

- **CS-2 (MUST)** NEVER use trailing commas in Swift collection literals. This is a hard rule with zero tolerance:
  ```swift
  // ❌ FORBIDDEN - Trailing commas violate SwiftLint and are not idiomatic Swift
  let array = [
      "item1",
      "item2",  // This trailing comma will cause SwiftLint violations
  ]
  
  let dictionary = [
      "key1": "value1",
      "key2": "value2",  // Trailing comma forbidden
  ]
  
  // ✅ REQUIRED - No trailing commas ever
  let array = [
      "item1",
      "item2"
  ]
  
  let dictionary = [
      "key1": "value1",
      "key2": "value2"
  ]
  ```
  **Rationale**: Swift does not require trailing commas, and SwiftLint enforces their absence. Unlike JavaScript/TypeScript, trailing commas are not idiomatic in Swift and should never be used.

#### Control Flow Syntax
- **CF-1 (MUST)** Keep opening braces on the same line:
  ```swift
  // ✅ Correct
  if let value = optional,
     let data = value.data(using: .utf8) {
      process(data)
  }
  
  // ❌ Wrong
  if let value = optional,
     let data = value.data(using: .utf8)
  {
      process(data)
  }
  ```

#### Button Syntax
- **BT-1 (MUST)** Use explicit parameter labels for Button with multiple closures:
  ```swift
  // ✅ Correct
  Button(action: { showPicker = true }, label: {
      Text("Select")
  })
  
  // ❌ Wrong
  Button(action: { showPicker = true }) {
      Text("Select")
  }
  ```

### Pre-Commit Checklist

Before every commit:
1. Run `swiftlint` and ensure 0 violations
2. Run `swiftformat .` to fix formatting
3. Check that build succeeds: `xcodebuild -scheme RollCall build`
4. Verify tests pass: `xcodebuild -scheme RollCall test`

### Automated Fixes

Common violations can be prevented with these practices:
- Use Xcode's automatic code formatting (Ctrl+I)
- Configure editor to show line length ruler at 120 characters
- Enable "Strip trailing whitespace" in Xcode preferences
- Use code snippets for common patterns (Button, if-let, etc.)

### CI Integration

- **CI-5 (MUST)** SwiftLint threshold set to 0 violations in GitHub Actions
- **CI-6 (MUST)** CI fails the build if any SwiftLint violations are detected
- **CI-7 (SHOULD)** Use SwiftLint strict mode in CI for maximum compliance

## Development Commands

### Building & Testing
```bash
# Build the project
xcodebuild -project RollCall.xcodeproj -scheme RollCall -configuration Debug build

# Run tests
xcodebuild -project RollCall.xcodeproj -scheme RollCall -configuration Debug test

# Clean build artifacts
xcodebuild -project RollCall.xcodeproj -scheme RollCall clean

# Build for release
xcodebuild -project RollCall.xcodeproj -scheme RollCall -configuration Release build
```

### Running in Xcode/Simulator
```bash
# Open project in Xcode
open RollCall.xcodeproj

# Open iOS Simulator directly
open -a Simulator

# Run specific test
swift test --filter ContentViewTests
```

### Windsurf/VSCode Shortcuts
- **Build**: `Cmd+Shift+B`
- **Run Tests**: `Cmd+Shift+P` → "Tasks: Run Task" → "Swift: Run Tests"
- **Open in Xcode**: `Cmd+Shift+P` → "Tasks: Run Task" → "Open in Xcode"
- **Debug Tests**: `F5`

### Xcode Shortcuts
- **Run App**: `Cmd+R`
- **Stop App**: `Cmd+.`
- **Build Only**: `Cmd+B`
- **Run Tests**: `Cmd+U`
- **Clean Build**: `Cmd+Shift+K`

### Simulator Shortcuts
- **Home**: `Cmd+Shift+H`
- **Rotate**: `Cmd+←` or `Cmd+→`
- **Screenshot**: `Cmd+S`
- **Shake Gesture**: `Cmd+Ctrl+Z`

### Common Workflows
```bash
# Quick test after changes
xcodebuild -project RollCall.xcodeproj -scheme RollCall test

# Full rebuild and test
xcodebuild -project RollCall.xcodeproj -scheme RollCall clean build test

# Open in Xcode to run on Simulator
open RollCall.xcodeproj
# Then in Xcode: Select iPhone simulator → Cmd+R
```

## SwiftUI Specific Guidelines

1. **MUST** use `@State` for view-local state, `@Binding` for parent-owned state
2. **SHOULD** extract complex views into separate files when > 100 lines
3. **MUST** use `.task` for async work in views, not `.onAppear`
4. **SHOULD** prefer `ViewModifier` for reusable styling
5. **MUST** test view models separately from views
6. **SHOULD** use `@Environment` for dependency injection
7. **MUST** handle loading/error states in async views
8. **SHOULD** Use `#Preview` macro for SwiftUI previews (iOS 15+)

## Performance Considerations

1. **SHOULD** use `LazyVStack`/`LazyHStack` for large lists of rolls
2. **MUST** implement proper image caching for roll photos
3. **SHOULD** paginate API requests for feed/timeline views
4. **MUST** optimize Core Data queries with proper indexes
5. **SHOULD** use `Instruments` to profile before optimizing
6. **SHOULD** Use `@ScaledMetric` for custom spacing that respects Dynamic Type
7. **SHOULD** Use `TimelineView` for time-based UI updates
8. **SHOULD** Use `ImageRenderer` for generating roll share cards

## Design System

### Core Principles

- **D-1 (MUST)** Apply Kawaii Minimalism: One focal illustration per screen, max 2 decorative elements
- **D-2 (MUST)** Use rounded corners (12-16px radius), soft shadows (≤24px blur @ 10% opacity)
- **D-3 (MUST)** Implement 200ms ease-in-out transitions for standard interactions
- **D-4 (SHOULD)** Include sushi-themed micro-copy for empty states and feedback
- **D-5 (MUST)** Maintain one core action per screen with 4pt spacing grid

### Color Tokens

```swift
// Primary
static let rcPink500 = Color(hex: "#FF6F9C")     // CTAs, active states
static let rcPink100 = Color(hex: "#FFE5EE")     // Light fills, hover
static let rcPink700 = Color(hex: "#E35680")     // Pressed, dark accent

// Neutrals
static let rcRice50 = Color(hex: "#FDF9F7")      // Background
static let rcSeaweed800 = Color(hex: "#273238")  // Primary text
static let rcSeaweed900 = Color(hex: "#1B1B1F")  // High contrast/dark bg

// Semantic
static let rcWasabi400 = Color(hex: "#9CCC7C")   // Success states
static let rcSoy600 = Color(hex: "#6B4F3F")      // Secondary text
static let rcGinger200 = Color(hex: "#FFB3C7")   // Info badges
static let rcSalmon300 = Color(hex: "#FFA56B")   // Attention/streaks
```

For automated color token generation, configure SwiftGen:
```yaml
# swiftgen.yml
colors:
  inputs:
    - Resources/Colors.xcassets
  outputs:
    - templateName: swift5
      output: Generated/Colors.swift
```

### Component Specs

- **Buttons**: 12px radius, rcPink500 background, white text
- **Cards**: 16px radius, rcRice50 background, 1px rcSoy600/20% border
- **Text Fields**: 12px radius, rcRice50 fill, rcSeaweed800 text
- **Icons**: 24x24px default, 2px stroke, squircle backgrounds when needed

### Typography

- **Headers**: Poppins SemiBold (rounded terminals match kawaii aesthetic)
- **Body**: Inter Regular (high legibility)
- **Sushi Glyphs**: Use SF Symbols or emoji sparingly

### Motion

- **Standard**: 200ms cubic-bezier(0.4, 0, 0.2, 1)
- **Celebratory**: 400ms spring animation for achievements/confetti

---

# RollCall Design Addendum — December 2024

> This addendum extends the existing **Design System** section. Follow all rules here **in addition** to the current D‑1 through D‑5 requirements.

---

## 0 — Rationale

These guidelines codify the visual‑design feedback gathered from onboarding‑screen critiques. Goals: 

* **Accessibility** that meets WCAG 2.2 AA.
* **Consistent visual rhythm** via a 4‑pt spacing grid.
* **Clear hierarchy & depth** so interactive elements feel obviously tappable.
* **Brand coherence** across color, illustration, and motion.

---

## 1 — Accessibility & Contrast (AC)

| ID                | Rule                                                                                       | Enforcement                  |
| ----------------- | ------------------------------------------------------------------------------------------ | ---------------------------- |
| **AC‑1 (MUST)**   | All text and interactive elements **pass WCAG 2.2 AA** contrast against their backgrounds. | CI – Figma + SwiftLint check |
| **AC‑2 (MUST)**   | Primary CTAs must pass **AAA** when feasible (small text ≤ 14 pt weight < 600).            | Manual review                |
| **AC‑3 (SHOULD)** | Provide **Dynamic Type** scaling up to XXL without clipping.                               | QA checklist                 |
| **AC‑4 (MUST)**   | All interactive elements have proper `accessibilityLabel` and `accessibilityHint`.          | SwiftLint                    |
| **AC‑5 (SHOULD)** | Support custom accessibility actions for complex gestures.                                   | Code review                  |

---

## 2 — Spacing & Layout (SL)

| ID                | Rule                                                                                                                |
| ----------------- | ------------------------------------------------------------------------------------------------------------------- |
| **SL‑1 (MUST)**   | Adopt a **4‑pt spacing grid** (4, 8, 12, 16, 20… 56). No bespoke pixel gaps.                                        |
| **SL‑2 (MUST)**   | Maintain a **vertical rhythm**: Logo → Headline = 10× grid; Headline → Subhead = 6× grid; Subhead → CTA ≥ 14× grid. |
| **SL‑3 (SHOULD)** | Keep > 32 pt padding from safe‑area edges to primary content.                                                       |

---

## 3 — Visual Hierarchy (VH)

* **VH‑1 (MUST)** The screen must present **one focal element** (Level 1), one primary action (Level 2), and supporting copy (Level 3). Nothing else competes for Level 1.
* **VH‑2 (SHOULD)** Use **weight & size** before color to establish hierarchy.
* **VH‑3 (MUST)** Avoid mixing illustration styles (e.g., outline icon + emoji) in the same component.

---

## 4 — Color & Tokens (CT)

> Adds new tokens to the existing palette.

```swift
// Neutrals / Accent
static let rcNori800  = Color(hex: "#15242F")   // Deep navy accent / strokes
static let rcRice75   = Color(hex: "#FFF8F9")   // Ultra‑light panel fill

// Gradient Primitives
static let rcGradientPink = Color(hex: "#FF477B")
static let rcGradientOrange = Color(hex: "#FFA56B")
```

* **CT‑1 (MUST)** CTA gradients **MUST** start at `rcGradientPink` → `rcGradientOrange` (Left → Right, 180°).
* **CT‑2 (SHOULD)** Surfaces that require elevation use an **inner stroke** `rcNori800` @ 8 % opacity plus a shadow (see CD‑2).

---

## 5 — Iconography & Illustration (IC)

| ID                | Rule                                                                                |
| ----------------- | ----------------------------------------------------------------------------------- |
| **IC‑1 (MUST)**   | Icons: 2 pt stroke, always `rcNori800` unless disabled.                             |
| **IC‑2 (MUST)**   | Illustration style: outlined with soft fill; **never** mix emojis in production UI. |
| **IC‑3 (SHOULD)** | Provide at least 24 pt tappable hit‑area even for 16 pt visual icons.               |

---

## 6 — Component Depth & States (CD)

| ID                    | Rule                                                                                               |
| --------------------- | -------------------------------------------------------------------------------------------------- |
| **CD‑1 (MUST)**       | Primary CTA: 1 pt **inset white stroke** @ 30 % + shadow (y = 3 dp, blur = 12 dp, opacity = 15 %). |
| **CD‑2 (SHOULD)**     | Logo container: dual shadow neumorphism (top‑left #FFFFFF99, bottom‑right #FFC1D480).              |
| **CD‑3 (SHOULD NOT)** | Avoid more than **two simultaneous shadows** on any element.                                       |

---

## 7 — Motion & Haptics (MH)

* **MH‑1 (MUST)** Standard transitions: `200 ms cubic‑bezier(0.4, 0, 0.2, 1)`.
* **MH‑2 (SHOULD)** Interactive elements provide **UIImpactFeedbackGenerator(style: .light)** on primary action.
* **MH‑3 (SHOULD)** Use **spring animations** (response ≈ 0.4, damping ≈ 0.8) for celebratory events.

---

## 8 — Onboarding Patterns (OB)

| ID                | Rule                                                                     |
| ----------------- | ------------------------------------------------------------------------ |
| **OB‑1 (MUST)**   | One CTA per onboarding page.                                             |
| **OB‑2 (MUST)**   | Pager dots: same shape, inactive `rcSoy600` @ 30 %, active `rcPink500`.  |
| **OB‑3 (SHOULD)** | At least one micro‑animation (icon pulse, confetti) per onboarding flow. |

---

## 9 — Micro‑Delight (MD)

| ID                | Rule                                                      |
| ----------------- | --------------------------------------------------------- |
| **MD‑1 (SHOULD)** | Show a random **sushi fun‑fact** in empty states.         |
| **MD‑2 (SHOULD)** | Confetti (Lottie) for first roll logged; 400 ms duration. |

---

## 10 — Design QA Checklist  ✅

Before merging UI work (manual process for MVP):

1. **Contrast check** – Figma plugin or manual verification passes.
2. **Spacing grid** – no off‑grid values.
3. **Hierarchy** – visually scan at 50 % blur; focal point obvious?
4. **Accessibility** – VoiceOver reads actionable elements clearly, proper focus order maintained.
5. **Motion** – All animations respect `reduceMotion` setting.
6. **Haptics** – Primary CTA only.

> **MVP Note:** Manual QA process. Automation will be added post-MVP when UI patterns stabilize.