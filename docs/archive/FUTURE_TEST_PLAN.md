# RollCall Future Test Plan

## Current State (January 2025)

RollCall is currently a **well-architected skeleton app** with:
- ✅ Complete MVVM-C architecture foundation
- ✅ Core Data persistence layer with repositories
- ✅ Dependency injection container
- ✅ Onboarding flow
- ❌ **No actual features implemented** (Feed, Create Roll, Profile are all placeholders)

## Tests Currently Implemented

### Foundation Tests (Make Sense Now)
- ✅ Domain Models (Chef, Roll, Restaurant)
- ✅ Core Data Stack & Repositories
- ✅ MainTabViewModel
- ✅ WelcomeViewModel
- ✅ Basic Coordinators (smoke tests)
- ✅ HapticFeedbackService

### Tests Removed (Not Applicable)
- ❌ AuthServiceTests - Current implementation not testable
- ❌ Feature tests - No features exist yet

## Future Test Requirements

### When Feed Feature is Implemented

**FeedViewModel Tests**
```swift
// Test feed loading states
// Test pull-to-refresh
// Test pagination
// Test error handling
// Test empty state
```

**FeedCoordinator Tests**
```swift
// Test navigation to roll details
// Test navigation to chef profiles
// Test modal presentations
```

**Integration Tests**
```swift
// Test feed updates when new rolls created
// Test real-time updates
// Test offline behavior
```

### When Create Roll Feature is Implemented

**CreateRollViewModel Tests**
```swift
// Test form validation
// Test photo selection/capture
// Test restaurant search
// Test rating selection
// Test tag management
// Test submission flow
```

**CreateRollCoordinator Tests**
```swift
// Test camera permissions
// Test restaurant picker flow
// Test cancellation handling
```

### When Profile Feature is Implemented

**ProfileViewModel Tests**
```swift
// Test stats calculations
// Test roll history loading
// Test profile editing
// Test settings management
```

**ProfileCoordinator Tests**
```swift
// Test navigation to roll history
// Test settings flow
// Test logout flow
```

### When Networking is Implemented

**API Client Tests**
```swift
// Test request construction
// Test response parsing
// Test error handling
// Test authentication headers
// Test retry logic
```

**Service Layer Tests**
```swift
// Test RollService implementation
// Test RestaurantService implementation
// Test real AuthService with network calls
```

### Integration Test Suite

**User Journey Tests**
```swift
// Test complete onboarding → create first roll flow
// Test browse feed → like roll → view chef profile flow
// Test create roll → see in feed → edit → delete flow
```

**Data Synchronization Tests**
```swift
// Test offline → online sync
// Test conflict resolution
// Test data consistency
```

## Testing Strategy Recommendations

### 1. **Test-Driven Feature Development**
When implementing new features:
- Write ViewModel tests first
- Implement ViewModel logic
- Write View tests (if needed)
- Implement Views
- Write integration tests
- Connect everything

### 2. **Maintain Test Pyramid**
```
         UI Tests (10%)
        /              \
    Integration (20%)    
   /                    \
Unit Tests (70%)         
```

### 3. **Coverage Goals**
- ViewModels: >80%
- Services: >80%
- Repositories: >80%
- Coordinators: Smoke tests
- Views: Snapshot tests for critical screens

### 4. **Performance Testing**
When features exist:
- Test large feed scrolling
- Test image loading performance
- Test Core Data query performance
- Test memory usage

## Implementation Priority

1. **When First Feature Ships** (e.g., Create Roll)
   - Full test coverage for that feature
   - Integration with existing foundation
   - End-to-end test for complete flow

2. **When Networking Arrives**
   - Comprehensive API testing
   - Mock server for reliable tests
   - Network failure scenarios

3. **Before Beta Release**
   - Full test suite across all features
   - Performance benchmarks
   - UI automation tests

## Current Action Items

1. **Keep existing foundation tests**
2. **Fix AuthService to be testable** (inject KeychainService)
3. **Don't over-test the skeleton** - Wait for features
4. **Use TDD when building features**

## Testing Tools to Add Later

- [ ] Snapshot testing (pointfree/swift-snapshot-testing)
- [ ] Network mocking (OHHTTPStubs)
- [ ] Performance testing (XCTest metrics)
- [ ] UI testing (XCUITest)

---

**Remember**: Tests should validate behavior, not implementation. Focus on testing what the app does for users, not how it does it internally.