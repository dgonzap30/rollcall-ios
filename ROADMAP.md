# 🍣 RollCall Development Roadmap (v5.0 — Iterative Canonical)

**Philosophy**: Local-first, cloud-backed. iOS 15+, MVVM-C, Xcode-only builds, DI via initializers, TDD. The phone is the source of truth; server is a replica for sharing.

## Invariants (do not change)
- **Platform**: iOS 15+ only; Swift/SwiftUI; Xcode builds (no SwiftPM).
- **Architecture**: MVVM-C; strict boundaries; DI via initializers; unidirectional flow.
- **Data**: Core Data local storage.
- **Concurrency**: async/await; structured concurrency; careful cancellation.
- **Quality**: TDD; ≥60% coverage for MVP (≥80% for Sync Beta); SwiftFormat/SwiftLint; zero force-unwraps outside tests (tests allowed w/ rationale).
- **CI/CD**: xcodebuild build/test; Conventional Commits; Sentry + dSYMs; os_log with privacy levels.
- **Design System**: "Kawaii Minimalism"; tokens (rcPink/rcRice/rcSeaweed…); WCAG 2.2 AA (AAA for CTAs); a11y labels/hints.
- **Domain vocabulary**: Roll, Chef, Restaurant, Rating, Omakase, Nigiri/Maki/Sashimi.

## Status Codes: `PLANNED` | `IN_PROGRESS` | `DONE` | `BLOCKED` | `DEFERRED` | `FLAGGED`

**Last Updated**: Aug 13, 2025 (America/Mexico_City)

## Quick Status Dashboard

| Phase | Status | Timeline | Priority |
|-------|--------|----------|----------|
| **0.0: Emergency Fixes** | DONE | DONE (Aug 12) | CRITICAL |
| **0.1: Extract & Refactor Feed** | DONE | DONE (Aug 13 AM) | CRITICAL |
| **0.2: CreateRoll Implementation** | DONE | DONE (Aug 13 PM) | CRITICAL |
| **0.3: Critical Bug Fixes** | DONE | DONE (Aug 13 PM) | RESOLVED |
| **0.4: Test Infrastructure Fix** | IN_PROGRESS | Aug 13–14 | CRITICAL |
| **1: Design System + API Contracts** | DEFERRED | Aug 15–16 | HIGH |
| **2: Infra + Observability** (Perf, Photos, Analytics) | PLANNED | Aug 17–19 | HIGH |
| **3: Roll Creation Polish** | PLANNED | Aug 20–22 | HIGH |
| **4: My Rolls** (local list + details + edit/delete) | PLANNED | Aug 23–26 | HIGH |
| **5: Profile & Polish + TestFlight Prep** | PLANNED | Aug 27–29 | MEDIUM |
| **6: Cloud Sync + Basic Auth** (Beta, FF) | PLANNED | Sep 1–5 | HIGH (FLAGGED) |

<!-- P0_TASKS -->
## P0 Immediate Next Steps (auto-managed)

**Scope**: Only the smallest set of actions required to unblock MVP progress right now. Each item must be atomic, testable, and independently verifiable.

- **RC-P0-029** — Fix missing waitForExpectations in MainTabViewModelTests
  - **Rationale**: Test has 4 expectations with fulfill() but no waitForExpectations causing test timeout.
  - **Deliverables**: Add waitForExpectations after all expectations set up.
  - **Acceptance**: MainTabViewModelTests runs without timeout.

- **RC-P0-030** — Fix missing waitForExpectations in AppCoordinatorTests
  - **Rationale**: Test has expectations with fulfill() but no waitForExpectations causing test timeout.
  - **Deliverables**: Add waitForExpectations after all expectations set up.
  - **Acceptance**: AppCoordinatorTests runs without timeout.

- **RC-P0-031** — Verify full test suite execution
  - **Rationale**: After fixing expectation waits, need to verify all tests pass and measure coverage.
  - **Deliverables**: All tests execute successfully with coverage metrics.
  - **Acceptance**: `xcodebuild test` completes within 120 seconds with coverage ≥60%.
  - **Dependencies**: RC-P0-029, RC-P0-030

- **RC-P0-032** — Set up CI metrics collection
  - **Rationale**: Need automated CI metrics to drive future P0 iterations.
  - **Deliverables**: Script to generate ci-metrics.json from test results.
  - **Acceptance**: ci-metrics.json generated with accurate build/test/coverage data.
  - **Dependencies**: RC-P0-031
<!-- /P0_TASKS -->

<!-- PHASE_BACKLOG -->
## Phase Backlog (reference, stable)

### 1 — Design System + API Contracts (DEFERRED Aug 15–16)
Tokens (DesignSystem/Tokens.swift), components (PrimaryButton, EmptyStateView, LoadingView, RollCard), a11y audit. API DTOs frozen in `/docs/api_v1.md`.

### 2 — Infra + Observability (Aug 17–19)
Photos pipeline (sandbox copy, thumbnail cache), perf harness with deterministic inputs, Telemetry + Sentry, AppError, feature flags/killswitch.

### 3 — Roll Creation Polish (Aug 20–22)
Guest profile UUID, biometric lock toggle, 3-tap creation, optimistic insert, bg photo processing.

### 4 — My Rolls (Local) (Aug 23–26)
Fast list + details + edit/delete; search/filter; persist prefs; 60fps on 200 items.

### 5 — Profile & Polish + TestFlight (Aug 27–29)
Profile stats, settings, App Store privacy strings, icon/launch assets, CI gates.

### 6 — Cloud Sync + Basic Auth (Sep 1–5, FF)
Backend (Fastify/Postgres/R2), signed uploads, LWW merge, updated_since + cursor pagination, iOS Sync Service, public feed (flagged).
<!-- /PHASE_BACKLOG -->

<!-- METRICS -->
## Quality Gates & Metrics (auto-managed)

- **Build (main target)**: GREEN ✅
- **Build (test targets)**: GREEN ✅
- **Coverage**: BLOCKED (tests timeout due to missing waitForExpectations)
- **SwiftLint**: 0 violations ✅ (clean!)
- **SwiftFormat**: 0 errors ✅ (clean!)
- **Tests Passing**: TIMEOUT ❌ (19 expectation.fulfill() with 0 waitForExpectations)
- **Architecture**: MVVM-C compliance ✅
- **Perf (p90)**: Save ≤700ms (not measured); Feed load ≤200ms (not measured)
- **Stability (TF cohort)**: Target ≥99.5% crash-free (not measured)
- **A11y**: Primary flows AA ✅; VoiceOver path (not verified)
<!-- /METRICS -->

<!-- RISKS -->
## Risks & Mitigations (living)

- **Tests blocked** → Mitigation: RC-P0-001; CI "fail fast" on compile errors.
- **Lint debt hides defects** → Mitigation: RC-P0-003; forbid rule disables.
- **Timeline squeeze** → Mitigation: Keep P0 small; defer polish to Phase 3/5.
<!-- /RISKS -->

## Definition of Done (per phase)

- Follows CLAUDE.md + RollCall guidelines (MVVM-C, unidirectional flow, @MainActor only in UI).
- Tests pass; coverage gate met; perf gate met; lint clean.
- Feature works offline; AA audit passed.
- Merged to main with CI green and release notes updated.

<!-- ACCEPTANCE_TESTS -->
## Lightweight Acceptance Tests (copy to CI)

1. **Create Roll E2E (offline)** → persists across relaunch.
2. **Edit/Delete** → list/UI consistent; Core Data state correct.
3. **Perf** → save p90 ≤700ms; list p90 ≤200ms (seeded).
4. **A11y** → VoiceOver completes Create→Save; 44pt targets; AA contrast.
5. **Sync (flagged)** → Two devices converge <10s; backend down = app usable.
<!-- /ACCEPTANCE_TESTS -->

<!-- CHANGELOG -->
## Changelog (auto-append)

- **2025-08-13**: v5.0 created from v4.6; added anchors; added Phase 0.4; captured P0 RC-P0-001..004; initialized Metrics.
- **2025-08-13**: Main build green; tests fail on CreateRollCoordinatorTests constructor; 77 lint violations identified; P0 tasks refined for test fix priority.
- **2025-08-13**: Tests compile successfully; coverage 73.6%; SwiftLint reduced to 15; SwiftFormat clean; new P0 tasks RC-P0-005..007.
- **2025-01-14**: Updated P0 priorities; resolved SwiftLint (0 violations) and Info.plist tasks; identified test compilation failures as primary blocker; new P0 tasks RC-P0-008..010.
- **2025-01-14**: Code review revealed RC-P0-008 partially complete; core APIs fixed but 27 trailing comma violations found; added CS-2 to CLAUDE.md; new P0 tasks RC-P0-011..012.
- **2025-01-14**: SwiftLint violations increased to 53 (41 trailing commas); test compilation still blocked by mock interfaces; new P0 tasks RC-P0-013..017 prioritize lint cleanup then test fixes.
- **2025-01-14**: RC-P0-015 complete (test compilation fixed); RC-P0-013/014 incomplete (41 trailing commas, 2 braces remain); tests timeout; added RC-P0-018 for timeout fix.
- **2025-08-14**: Test build green but execution times out due to expectation waits; 50 SwiftLint violations remain (41 trailing_comma, 8 opening_brace, 1 trailing_newline); new P0 tasks RC-P0-019..023 focus on lint cleanup and test timeout fix.
- **2025-08-14**: Progress on lint cleanup - SwiftLint down to 10 violations (all opening_brace); SwiftFormat shows 10 brace errors; test timeout persists; new P0 tasks RC-P0-024..028 focus on final lint fixes and test timeout resolution.
- **2025-08-14**: Major progress - SwiftLint and SwiftFormat now clean (0 violations); test timeout root cause identified: 19 expectation.fulfill() calls with 0 waitForExpectations in 2 test files; new P0 tasks RC-P0-029..032 focus on fixing expectation waits and establishing CI metrics.
<!-- /CHANGELOG -->

<!-- MACHINE_STATE -->
## Machine State (JSON, auto-managed)

```json
{
  "version": "5.0",
  "updated_at": "2025-08-14T16:40:00-06:00",
  "tz": "America/Mexico_City",
  "build_main": "green",
  "build_tests": "green",
  "coverage_percent": null,
  "swiftlint_remaining": 0,
  "swiftformat_errors": 0,
  "perf": { "save_p90_ms": null, "feed_p90_ms": null },
  "stability_crash_free_pct": null,
  "a11y_core_paths_verified": false,
  "p0_ids": ["RC-P0-029", "RC-P0-030", "RC-P0-031", "RC-P0-032"],
  "test_failures": ["MainTabViewModelTests_timeout", "AppCoordinatorTests_timeout"]
}
```
<!-- /MACHINE_STATE -->