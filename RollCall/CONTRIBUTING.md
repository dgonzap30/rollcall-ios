# Contributing to RollCall

Thank you for your interest in contributing to RollCall! This document provides guidelines and instructions for contributing to the project.

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Process](#development-process)
- [Pull Request Process](#pull-request-process)
- [Coding Standards](#coding-standards)
- [Testing Requirements](#testing-requirements)
- [Documentation](#documentation)

## 📜 Code of Conduct

By participating in this project, you agree to abide by our Code of Conduct:

- Be respectful and inclusive
- Welcome newcomers and help them get started
- Focus on constructive criticism
- Accept feedback gracefully
- Prioritize the project's best interests

## 🚀 Getting Started

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/yourusername/rollcall.git
   cd rollcall/RollCall
   ```
3. **Add upstream remote**:
   ```bash
   git remote add upstream https://github.com/originalowner/rollcall.git
   ```
4. **Create a feature branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```

## 💻 Development Process

### 1. Before You Start

- Check existing issues and PRs to avoid duplicate work
- For significant changes, open an issue first to discuss
- Ensure you have the latest code from upstream:
  ```bash
  git fetch upstream
  git rebase upstream/develop
  ```

### 2. Development Guidelines

Follow the RollCall Development Guidelines (CLAUDE.md):

- **Architecture**: MVVM-C pattern strictly enforced
- **TDD**: Write tests first, then implementation
- **Swift Version**: 5.10+ features supported
- **iOS Target**: 15.0+ minimum deployment

### 3. Code Quality Checks

Before committing, run:

```bash
# Format code
swiftformat .

# Check linting
swiftlint

# Run tests
xcodebuild test -project RollCall.xcodeproj -scheme RollCall \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

## 🔄 Pull Request Process

### 1. PR Preparation

- Ensure your branch is up-to-date with `develop`
- All tests pass locally
- Code coverage maintained or improved
- SwiftLint shows 0 violations
- Commit messages follow convention

### 2. PR Submission

Use the PR template and ensure:

- [ ] Clear description of changes
- [ ] P0 work item referenced (if applicable)
- [ ] Definition of Done checklist completed
- [ ] Screenshots added (for UI changes)
- [ ] Tests added/updated
- [ ] Documentation updated

### 3. PR Review Process

- PRs require at least 1 approval
- All CI checks must pass
- Reviewer feedback addressed
- Branch up-to-date with target

### 4. After Merge

- Delete your feature branch
- Pull latest changes to your local develop
- Celebrate your contribution! 🎉

## 📝 Coding Standards

### Swift Style Guide

```swift
// MARK: - Good Example
struct Roll: Identifiable, Codable {
    let id: RollID
    let name: String
    let rating: Int
    
    init(id: RollID, name: String, rating: Int) {
        self.id = id
        self.name = name
        self.rating = rating
    }
}

// MARK: - Bad Example
struct roll {  // Wrong: lowercase type name
    var Id: UUID  // Wrong: capitalized property
    var Name: String!  // Wrong: force unwrap
}
```

### File Organization

```swift
// 1. Imports
import SwiftUI

// 2. Protocol definitions
protocol RollServicing {
    func fetchRolls() async throws -> [Roll]
}

// 3. Main type
@MainActor
final class RollViewModel: ObservableObject {
    // 3a. Published properties
    @Published private(set) var viewState: ViewState
    
    // 3b. Private properties
    private let service: RollServicing
    
    // 3c. Initialization
    init(service: RollServicing) {
        self.service = service
        self.viewState = .idle
    }
    
    // 3d. Public methods
    func loadRolls() async {
        // Implementation
    }
    
    // 3e. Private methods
    private func handleError(_ error: Error) {
        // Implementation
    }
}

// 4. Extensions
extension RollViewModel {
    struct ViewState {
        // State definition
    }
}
```

### Naming Conventions

| Element | Convention | Example |
|---------|------------|---------|
| Types | PascalCase | `RollViewModel` |
| Properties | camelCase | `rollCount` |
| Methods | camelCase | `fetchRolls()` |
| Constants | camelCase | `maximumRollCount` |
| Protocols | Suffix with -ing/-able | `RollServicing` |

## 🧪 Testing Requirements

### Test Coverage Targets

- **ViewModels**: >80% coverage required
- **Services**: >80% coverage required
- **Overall**: ≥60% (MVP), ≥80% (Beta)

### Test Naming Convention

```swift
func test_whenCondition_shouldExpectedBehavior() {
    // Arrange
    let sut = SystemUnderTest()
    
    // Act
    let result = sut.performAction()
    
    // Assert
    XCTAssertEqual(result, expectedValue)
}
```

### Test Organization

```
RollCallTests/
├── Core/
│   ├── Models/
│   └── Services/
├── Features/
│   ├── Feed/
│   └── Roll/
└── Mocks/
```

## 📚 Documentation

### Code Comments

Only add comments for:
- Complex business logic
- Non-obvious workarounds
- API documentation
- TODOs with ticket references

```swift
/// Fetches rolls for the current chef with pagination support.
/// - Parameters:
///   - limit: Maximum number of rolls to fetch
///   - offset: Number of rolls to skip
/// - Returns: Array of Roll objects
/// - Throws: AppError.network if request fails
func fetchRolls(limit: Int = 20, offset: Int = 0) async throws -> [Roll] {
    // Implementation
}
```

### README Updates

Update README.md when:
- Adding new dependencies
- Changing setup instructions
- Adding new features
- Modifying architecture

## 🎯 P0 Work Items

When working on P0 items:

1. Reference the P0 ID in branch name: `feature/RC-P0-035-roll-save`
2. Include P0 details in PR description
3. Ensure all acceptance criteria met
4. Follow the Definition of Done

## 🔧 Troubleshooting

### Common Issues

**SwiftLint Violations**
```bash
# Auto-fix where possible
swiftlint --fix

# Check specific file
swiftlint lint --path path/to/file.swift
```

**Test Failures**
```bash
# Run specific test
xcodebuild test -project RollCall.xcodeproj \
  -scheme RollCall \
  -only-testing:RollCallTests/SpecificTest
```

**Build Errors**
```bash
# Clean build folder
xcodebuild clean -project RollCall.xcodeproj

# Delete derived data
rm -rf ~/Library/Developer/Xcode/DerivedData/RollCall-*
```

## 🙋 Getting Help

- **Discord**: Join our developer community
- **GitHub Issues**: Report bugs or request features
- **GitHub Discussions**: Ask questions and share ideas
- **Stack Overflow**: Tag questions with `rollcall-ios`

## 🏆 Recognition

Contributors are recognized in:
- README.md contributors section
- Release notes
- Annual contributor spotlight

Thank you for contributing to RollCall! 🍣