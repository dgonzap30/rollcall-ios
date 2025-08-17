# RollCall Architecture & Performance Considerations

This document outlines architectural decisions, performance considerations, and optimization opportunities identified during the onboarding navigation implementation.

## Navigation Architecture

### Current Implementation

The app uses a root-level state observation pattern:
- `RootView` observes `AppCoordinator.isOnboarding` to switch between app states
- New coordinators are created on each state transition
- `AnyView` is used to type-erase coordinator views

### Benefits
- Clean separation between onboarding and main app states
- Simple, declarative navigation
- Proper SwiftUI state observation
- Easy to reason about and debug

### Trade-offs
- Creating new coordinators on each transition may impact performance
- `AnyView` usage can prevent SwiftUI optimizations
- Memory overhead from recreating view hierarchies

## Performance Considerations

### 1. Coordinator Lifecycle Management

**Current Behavior**: New coordinators are instantiated each time the app state changes.

```swift
func createOnboardingView() -> some View {
    let onboardingCoordinator = OnboardingCoordinator(container: container)
    onboardingCoordinator.delegate = self
    return AnyView(onboardingCoordinator.start())
}
```

**Potential Optimization**: Cache coordinators to avoid recreation.

```swift
// Future optimization
private lazy var onboardingCoordinator: OnboardingCoordinator = {
    let coordinator = OnboardingCoordinator(container: container)
    coordinator.delegate = self
    return coordinator
}()
```

**Trade-offs**:
- ✅ Reduces instantiation overhead
- ✅ Preserves coordinator state
- ❌ Increases memory footprint
- ❌ May complicate state management

### 2. AnyView Usage

**Current Implementation**: `AnyView` is used to abstract coordinator view types.

**Impact**:
- Prevents SwiftUI from optimizing view diffs
- May cause unnecessary redraws
- Acceptable for root-level navigation (infrequent changes)

**Alternative Approaches**:
1. Use `@ViewBuilder` with conditional views
2. Create protocol-based view abstractions
3. Accept the performance trade-off for cleaner architecture

### 3. State Update Synchronization

**Improvement Made**: Removed async `Task` wrapper from state updates to ensure synchronous TabView selection binding.

**Before**:
```swift
private var currentPageIndex = 0 {
    didSet {
        Task { @MainActor in
            selection = currentPageIndex
            updateViewState()
        }
    }
}
```

**After**:
```swift
private var currentPageIndex = 0 {
    didSet {
        selection = currentPageIndex
        updateViewState()
    }
}
```

**Result**: Immediate UI updates, better SwiftUI integration.

## Monitoring Recommendations

### Performance Metrics to Track

1. **App Launch Time**
   - Measure time from launch to first interactive view
   - Target: < 1.5 seconds

2. **State Transition Time**
   - Measure onboarding → main app transition
   - Target: < 300ms

3. **Memory Usage**
   - Monitor coordinator lifecycle memory impact
   - Check for retained references

4. **View Rendering**
   - Use Instruments to profile view updates
   - Check for excessive redraws

### Implementation Points

```swift
// Add performance monitoring
let startTime = CFAbsoluteTimeGetCurrent()
let view = createOnboardingView()
let loadTime = CFAbsoluteTimeGetCurrent() - startTime
print("[Performance] Onboarding view created in \(loadTime)s")
```

## Future Optimization Opportunities

### 1. Lazy Coordinator Loading
Only instantiate coordinators when needed:
```swift
enum AppState {
    case onboarding
    case main
    
    @ViewBuilder
    func view(container: Container) -> some View {
        switch self {
        case .onboarding:
            OnboardingCoordinator(container: container).start()
        case .main:
            MainTabCoordinator(container: container).start()
        }
    }
}
```

### 2. Coordinator Pool
Implement a coordinator cache with lifecycle management:
```swift
class CoordinatorPool {
    private var coordinators: [String: Any] = [:]
    
    func coordinator<T: Coordinator>(ofType type: T.Type, 
                                     container: Container) -> T {
        let key = String(describing: type)
        if let existing = coordinators[key] as? T {
            return existing
        }
        let new = T(container: container)
        coordinators[key] = new
        return new
    }
}
```

### 3. View State Preservation
Save and restore view state across coordinator recreations:
```swift
protocol StatefulCoordinator {
    associatedtype State: Codable
    func saveState() -> State
    func restoreState(_ state: State)
}
```

## Architecture Decision Records

### ADR-001: Root View Pattern
**Decision**: Use `RootView` with `@StateObject` to observe `AppCoordinator`.

**Rationale**: 
- Fixes SwiftUI state observation issues
- Provides clean separation of concerns
- Enables smooth transitions

**Consequences**:
- Must manage coordinator lifecycle explicitly
- Need to monitor performance impact

### ADR-002: Synchronous State Updates
**Decision**: Remove async wrappers from state updates in ViewModels.

**Rationale**:
- SwiftUI bindings require synchronous updates
- Async updates caused navigation delays

**Consequences**:
- Better UI responsiveness
- Must ensure no blocking operations in state updates

### ADR-003: Debug Logging Strategy
**Decision**: Add comprehensive debug logging wrapped in `#if DEBUG`.

**Rationale**:
- Essential for debugging navigation flows
- No performance impact in release builds

**Consequences**:
- Easier troubleshooting
- Must maintain logging consistency

## Testing Considerations

### State Transition Tests
Need comprehensive tests for:
- Onboarding completion → Main app
- Deep linking scenarios (future)
- State persistence across app launches

### Performance Tests
Implement benchmarks for:
- Coordinator instantiation time
- View rendering performance
- Memory usage patterns

### Example Test Structure
```swift
func test_rootView_transitionPerformance() {
    measure {
        let coordinator = AppCoordinator.shared
        coordinator.isOnboarding = true
        coordinator.isOnboarding = false
    }
}
```

## Conclusion

The current architecture provides a solid foundation with clear separation of concerns and proper SwiftUI integration. Performance optimizations should be implemented based on actual metrics rather than premature optimization. The coordinator pattern allows for future enhancements without major architectural changes.

### Next Steps
1. Implement performance monitoring
2. Establish baseline metrics
3. Optimize based on real-world usage
4. Consider coordinator caching if needed

---
Last Updated: 2025-01-21