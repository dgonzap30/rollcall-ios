# RollCall Development Guidelines v2.0

> **Purpose**: Ensure maintainability, safety, and velocity for RollCall - the social sushi logging app.
> **Enforcement**: MUST rules are CI-enforced; SHOULD rules are strongly recommended.

## 🎯 Quick Reference

**Platform**: iOS 15+ • Swift/SwiftUI • Xcode-only • MVVM-C • Core Data  
**Quality**: TDD • ≥60% coverage (MVP) • SwiftLint/Format clean • Zero force-unwraps  
**Domain**: Roll (entry) • Chef (user) • Restaurant • Rating (1-5) • Omakase • Nigiri/Maki/Sashimi

## 📁 Project Structure
```
/App          → AppCoordinator, RootView
/Core         → Models, Services (protocols), Repositories
/UI           → Components, Modifiers, Tokens (Design System)
/Features     → [Feature]/Coordinator+ViewModel+View
/Networking   → APIClient, DTOs, Mappers
/Tests        → Mirrors source structure
```

## 🏗️ Architecture: MVVM-C

### Core Flow
```
User → View → ViewModel → Service → ViewModel → View → Coordinator
```

### Critical Rules

| ID | Rule | Priority |
|----|------|----------|
| **A1** | ViewModels: Pure Swift, NO UIKit/SwiftUI imports | MUST |
| **A2** | Coordinators own all navigation | MUST |
| **A3** | DI via initializers (no singletons except AppCoordinator) | MUST |
| **A4** | Unidirectional data flow | MUST |
| **A5** | `@MainActor` only on UI methods, not entire ViewModels | MUST |
| **A6** | Services as protocols in Core, implementations in Networking | MUST |

### Naming Conventions
- Views: `*View` • ViewModels: `*ViewModel` • Coordinators: `*Coordinator`
- Protocols: `*Servicing` • Mocks: `*Mock`

## ⚡ Swift Standards

### Coding Rules

| Category | Rules | Examples |
|----------|-------|----------|
| **Types** | Strong typing for models | `struct RollID: Hashable { let value: UUID }` ✅ |
| **Async** | Always use async/await | `Task { [weak self] in await self?.load() }` |
| **Memory** | `[weak self]` in Tasks | Required for stored Tasks & ViewModels |
| **SwiftUI** | Views: `@MainActor` | ViewModels: `@MainActor` on methods only |
| **Structure** | Prefer struct over class | Unless reference semantics needed |
| **Collections** | NO trailing commas | `[.pink, .orange]` ✅ • `[.pink, .orange,]` ❌ |

### SwiftLint Compliance

**Zero violations required**. Key limits:
- Files ≤400 lines • Types ≤250 lines • Functions ≤50 lines • Lines ≤120 chars
- No trailing commas • Opening braces same line • Explicit Button parameters

## 🧪 Testing Standards

| Layer | Type | Coverage | Notes |
|-------|------|----------|-------|
| ViewModel | Unit, async | ≥60% MVP, ≥80% Beta | Test state changes |
| Services | Unit + mocks | ≥60% MVP, ≥80% Beta | Protocol-based mocks |
| Coordinators | Integration | Post-MVP | Navigation flow |
| Views | Snapshot | Optional | Critical flows only |

**Test Naming**: `test_whenCondition_shouldExpectedBehavior()`  
**Best Practice**: XCTUnwrap > force unwrap • Test boundaries • Mock externals

## 🔄 P0 Workflow

### Iterative Loop
1. **CI** → Generates `ci-metrics.json`
2. **Architect** → Updates ROADMAP anchors + emits P0 Plan JSON
3. **Coder** → Implements P0 items (TDD, one PR per RC-P0-###)
4. **Merge** → CI refreshes → Repeat

### ROADMAP Anchors (Auto-managed)
- `<!-- P0_TASKS -->` - Current sprint items
- `<!-- METRICS -->` - Quality gates
- `<!-- CHANGELOG -->` - Recent changes
- `<!-- MACHINE_STATE -->` - CI state JSON

### P0 Definition
- Atomic, testable, verifiable
- ID format: RC-P0-###
- One PR per P0 item

## 🎨 Design System

### Tokens
```swift
// Primary
rcPink500    (#FF6F9C)  // CTAs
rcRice50     (#FDF9F7)  // Background
rcSeaweed800 (#273238)  // Text

// Components
Button:     12px radius, rcPink500 bg, white text
Card:       16px radius, rcRice50 bg, 1px border
TextField:  12px radius, rcRice50 fill
Icon:       24×24px, 2px stroke

// Motion
Standard:   200ms cubic-bezier(0.4, 0, 0.2, 1)
Spring:     400ms (response: 0.4, damping: 0.8)
```

### Accessibility
- WCAG 2.2 AA minimum (AAA for CTAs)
- 4pt spacing grid
- Dynamic Type support
- VoiceOver labels/hints

## 🛠️ Development Commands

### Essential
```bash
# Build & Test
xcodebuild -project RollCall.xcodeproj -scheme RollCall build
xcodebuild -project RollCall.xcodeproj -scheme RollCall test

# Quality
swiftlint
swiftformat .

# Scripts
./scripts/build.sh   # Format + Lint + Build
./scripts/test.sh    # Run all tests
./scripts/lint.sh    # Check violations
```

### Git Workflow
```bash
# Branches: main, develop, feature/*, bugfix/*, hotfix/*
# Commits: Conventional format (feat|fix|docs|test|chore)
# Example: feat(roll): add photo upload

# PR Requirements
- One PR per RC-P0-###
- CI passing
- One review
```

## 🚀 Agent Shortcuts

### Core Macros
- **QNEW**: Initialize with all guidelines
- **QPLAN**: Analyze and plan implementation
- **QCODE**: Implement with TDD
- **QCHECK**: Review implementation
- **QP0**: Architect P0 planning
- **QP0-DO**: Execute P0 plan

### Quick Checks
```bash
# Before commit
swiftlint && swiftformat . && xcodebuild build

# Full validation
xcodebuild clean build test
```

## 📊 CI/CD Pipeline

### GitHub Actions Flow
1. **Format** → SwiftFormat check
2. **Lint** → SwiftLint (0 violations)
3. **Build** → Xcode build
4. **Test** → Unit tests + coverage
5. **Security** → Dependency scan

### Metrics Contract
```json
{
  "build_main": "green|yellow|red",
  "build_tests": "green|yellow|red", 
  "coverage_percent": 60.0,
  "swiftlint_remaining": 0,
  "test_failures": []
}
```

## 📝 JSON Schemas

### P0 Plan
```json
{
  "next_steps": [{
    "id": "RC-P0-###",
    "title": "Action",
    "rationale": "Why MVP critical",
    "deliverables": ["artifacts"],
    "acceptance": ["criteria"],
    "dependencies": ["RC-P0-###"]
  }],
  "definition_of_done": [
    "Tests green, coverage ≥60%",
    "SwiftLint/Format clean",
    "Accessibility verified"
  ]
}
```

### Machine State
```json
{
  "version": "5.0",
  "build_main": "green",
  "build_tests": "green",
  "coverage_percent": 60.0,
  "swiftlint_remaining": 0,
  "p0_ids": ["RC-P0-###"],
  "test_failures": []
}
```

## 🔍 Function Quality Checklist
✓ Clear purpose  
✓ Low complexity  
✓ Swift patterns (map/filter)  
✓ Safe optionals  
✓ Testable without mocks  
✓ API Guidelines naming

## 🎯 Test Quality Checklist
✓ Descriptive names  
✓ Success + failure paths  
✓ Async support  
✓ Boundary conditions  
✓ Protocol mocks  
✓ XCTUnwrap usage

---

## Appendix: Extended Examples

### Task Memory Management
```swift
// ✅ Required: Stored task property
private var animationTask: Task<Void, Never>?
func startAnimations() {
    animationTask = Task { [weak self] in
        await self?.performAnimationSequence()
    }
}

// ✅ Required: ViewModel tasks
func onButtonTapped() {
    Task { [weak self] in
        await self?.hapticService.impact(style: .light)
    }
}
```

### SwiftLint Prevention
```swift
// Collections - NO trailing commas
let colors = [.rcPink500, .rcGradientOrange]  // ✅
let colors = [.rcPink500, .rcGradientOrange,] // ❌

// Button syntax - explicit parameters
Button(action: { }, label: { Text("Tap") })   // ✅
Button(action: { }) { Text("Tap") }           // ❌
```

### Pre-Development Checklist
1. Run `./scripts/lint.sh` for baseline
2. Check `git status` for changes
3. Verify tools: `which swiftlint && which swiftformat`

### Development Process
1. **Before**: Clean baseline
2. **During**: Format frequently
3. **Before commit**: Build + Test + Lint

### P0 Loop Runbook
1. Get `ci-metrics.json`
2. Run Architect with metrics
3. Update ROADMAP anchors
4. Implement P0 items
5. Merge → CI → Repeat

---

**Remember**: Tests compile → Coverage real → Lint = 0 → Gates green 🚀