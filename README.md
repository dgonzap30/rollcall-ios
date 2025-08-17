# 🍣 RollCall

A social sushi logging iOS app built with SwiftUI and MVVM-C architecture.

## 🚀 Quick Start

### Requirements
- Xcode 17.0+
- iOS 15.0+
- Swift 6.0
- SwiftLint (via Homebrew)

### Setup
1. Install SwiftLint:
   ```bash
   brew install swiftlint
   ```

2. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/rollcall.git
   cd rollcall
   ```

3. Open in Xcode:
   ```bash
   open RollCall/RollCall.xcodeproj
   ```

4. Build and run (⌘R)

## 📱 Project Overview

RollCall allows users ("chefs") to:
- 📸 Log sushi experiences with photos and ratings
- 🍱 Track different roll types (nigiri, maki, sashimi)
- 📍 Remember restaurants and locations
- 📊 View statistics and history
- 👥 Share experiences with other sushi enthusiasts (future)

## 🏗 Architecture

The app follows **MVVM-C** (Model-View-ViewModel-Coordinator) architecture:

```
RollCall/
├── App/              # App lifecycle & coordinators
├── Core/             # Business logic & models
├── Features/         # Feature modules (Onboarding, Feed, etc.)
├── UI/               # Design system & reusable components
├── Platform/         # iOS-specific implementations
└── Support/          # Utilities & extensions
```

## 📖 Documentation

- **[CLAUDE.md](./CLAUDE.md)** - Comprehensive development guidelines, coding standards, and architecture patterns
- **[ROADMAP.md](./ROADMAP.md)** - Development roadmap, current progress, and feature planning
- **[CONTRIBUTING.md](./CONTRIBUTING.md)** - How to contribute to the project

## 🧪 Testing

Run tests:
```bash
# In Xcode
⌘U

# From terminal
xcodebuild -project RollCall/RollCall.xcodeproj -scheme RollCall test
```

Current test coverage:
- ViewModels: >80%
- Services: >80%
- Core Data: >80%

## 🛠 Development Scripts

Located in `/scripts/`:
- `build.sh` - Format, lint, and build the project
- `test.sh` - Run all unit tests
- `lint.sh` - Check code style and formatting

## 🎯 Current Status

**Phase 0**: ✅ Onboarding Complete  
**Phase 1**: 🚧 Design System Compliance (In Progress)  
**Next**: Authentication & User Management

See [ROADMAP.md](./ROADMAP.md) for detailed progress and upcoming features.

## 📄 License

Copyright © 2025 RollCall Team. All rights reserved.