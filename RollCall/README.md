# 🍣 RollCall

[![CI/CD Pipeline](https://github.com/yourusername/rollcall/actions/workflows/ci.yml/badge.svg)](https://github.com/yourusername/rollcall/actions/workflows/ci.yml)
[![SwiftLint](https://img.shields.io/badge/SwiftLint-0%20violations-success)](https://github.com/realm/SwiftLint)
[![Code Coverage](https://img.shields.io/badge/coverage-60%25-yellow)](https://codecov.io/gh/yourusername/rollcall)
[![License](https://img.shields.io/badge/license-MIT-blue)](LICENSE)

RollCall is a social sushi logging app for iOS that helps sushi enthusiasts track, rate, and share their culinary adventures.

## 📱 Features

- **Roll Tracking**: Log your sushi experiences with photos, ratings, and notes
- **Chef Profiles**: Build your reputation as a sushi connoisseur
- **Restaurant Discovery**: Find and rate sushi restaurants
- **Social Feed**: Share your rolls with the community
- **Achievements**: Unlock badges and track your sushi journey

## 🛠 Tech Stack

- **Platform**: iOS 15+
- **Language**: Swift 5.10
- **UI Framework**: SwiftUI
- **Architecture**: MVVM-C (Model-View-ViewModel-Coordinator)
- **Persistence**: Core Data
- **Concurrency**: Swift Concurrency (async/await)
- **Design System**: Custom tokens with 4pt grid

## 🚀 Getting Started

### Prerequisites

- Xcode 16.0+
- iOS 15.0+ deployment target
- SwiftLint (`brew install swiftlint`)
- SwiftFormat (`brew install swiftformat`)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/rollcall.git
cd rollcall/RollCall
```

2. Open in Xcode:
```bash
open RollCall.xcodeproj
```

3. Select a simulator and build:
```bash
# Command line build
xcodebuild -project RollCall.xcodeproj -scheme RollCall -sdk iphonesimulator build

# Or press Cmd+B in Xcode
```

## 🧪 Testing

### Run All Tests
```bash
xcodebuild test \
  -project RollCall.xcodeproj \
  -scheme RollCall \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

### Run with Coverage
```bash
./scripts/run-tests.sh
```

### Check Code Quality
```bash
# SwiftLint check
swiftlint

# SwiftFormat check
swiftformat --lint .

# Full CI checks
./scripts/lint.sh
```

## 📊 CI/CD

This project uses GitHub Actions for continuous integration and deployment.

### Pipeline Stages

1. **Lint & Format**: SwiftLint and SwiftFormat checks
2. **Build & Test**: Compiles and runs unit tests
3. **Coverage**: Ensures ≥60% code coverage (MVP)
4. **Security**: Dependency and SAST scanning
5. **Deploy**: TestFlight deployment (main branch only)

### Branch Protection

The following rules are enforced on `main` and `develop`:

- ✅ Require PR reviews (1 approval minimum)
- ✅ Require status checks to pass
- ✅ Require branches to be up to date
- ✅ Include administrators in restrictions
- ✅ Restrict force pushes

### Quality Gates

| Metric | MVP Target | Beta Target |
|--------|------------|-------------|
| Build | ✅ Green | ✅ Green |
| Tests | ✅ Pass | ✅ Pass |
| Coverage | ≥60% | ≥80% |
| SwiftLint | 0 violations | 0 violations |
| WCAG 2.2 | AA | AA |

## 🏗 Architecture

RollCall follows MVVM-C architecture:

```
RollCall/
├── App/                 # App lifecycle & root coordinator
├── Core/                # Business logic (no UI)
│   ├── Models/         # Domain models
│   ├── Services/       # Service protocols
│   └── Repositories/   # Data access
├── UI/                 # Design system
│   ├── Components/     # Reusable views
│   └── Tokens/        # Colors, typography
├── Features/           # Feature modules
│   ├── Feed/          # Feed feature
│   ├── Roll/          # Roll creation
│   └── Onboarding/    # Onboarding flow
└── Tests/             # Unit & integration tests
```

### Key Principles

- **Unidirectional Data Flow**: View → ViewModel → Service → ViewModel → View
- **Dependency Injection**: Via initializers, no singletons
- **Protocol-Oriented**: Services defined as protocols
- **Testable**: ViewModels have no UI imports

## 🎨 Design System

RollCall uses a kawaii-minimalist design language:

- **Colors**: Sushi-inspired palette (Pink, Rice, Seaweed, Wasabi)
- **Typography**: Poppins (headers), Inter (body)
- **Spacing**: 4pt grid system
- **Motion**: 200ms standard transitions

## 📝 Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

### Development Workflow

1. Create a feature branch from `develop`
2. Implement following TDD approach
3. Ensure all tests pass and coverage maintained
4. Run SwiftLint and SwiftFormat
5. Create PR with template filled out
6. Wait for review and CI checks

### Commit Convention

We use [Conventional Commits](https://www.conventionalcommits.org/):

```
feat(scope): add new feature
fix(scope): fix bug
docs(scope): update documentation
test(scope): add tests
refactor(scope): refactor code
chore(scope): maintenance tasks
```

## 📄 License

This project is licensed under the MIT License - see [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Design inspiration from Japanese minimalism
- SwiftUI community for best practices
- Contributors and testers

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/yourusername/rollcall/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/rollcall/discussions)
- **Email**: support@rollcallapp.com

## 🚦 Project Status

Current Phase: **MVP Development**

- ✅ Core architecture setup
- ✅ MVVM-C implementation
- ✅ CI/CD pipeline
- 🔄 Feature implementation
- ⏳ Beta testing
- ⏳ App Store release

---

Made with 🍣 and ❤️ by the RollCall team