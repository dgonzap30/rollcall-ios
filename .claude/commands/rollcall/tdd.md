# Test-Driven Development for RollCall

Implement features using strict TDD methodology.

Usage: `/tdd [feature-name]`

## TDD Process:

### 1. Red Phase - Write Failing Test
First, write a test that fails for the feature you want to implement:

```swift
func test_whenUserTapsCreateRoll_shouldPresentCreateView() {
    // Arrange
    let sut = CreateRollViewModel()
    let expectation = XCTestExpectation(description: "Create view presented")
    
    // Act
    sut.onCreateTapped()
    
    // Assert
    XCTAssertTrue(sut.isShowingCreateView)
    expectation.fulfill()
    wait(for: [expectation], timeout: 1.0)
}
```

Run test to ensure it fails:
```bash
xcodebuild -project RollCall.xcodeproj -scheme RollCall test \
  -only-testing:RollCallTests/CreateRollViewModelTests
```

### 2. Green Phase - Minimal Implementation
Write the minimum code to make the test pass:

```swift
class CreateRollViewModel: ObservableObject {
    @Published var isShowingCreateView = false
    
    func onCreateTapped() {
        isShowingCreateView = true
    }
}
```

Run test to ensure it passes.

### 3. Refactor Phase - Improve Code Quality
Refactor while keeping tests green:
- Extract constants
- Improve naming
- Add proper error handling
- Apply MVVM-C patterns

### TDD Workflow for $ARGUMENTS:

1. **Identify Feature Requirements**:
   - Break down into testable units
   - Define expected behavior
   - Consider edge cases

2. **Write Test Suite**:
   ```swift
   // MARK: - Core Functionality
   func test_initialization_setsDefaultValues()
   func test_mainAction_updatesState()
   
   // MARK: - Error Handling  
   func test_whenErrorOccurs_showsAlert()
   func test_whenNetworkFails_retriesAutomatically()
   
   // MARK: - Edge Cases
   func test_withEmptyData_showsEmptyState()
   func test_withMaxItems_limitsDisplay()
   ```

3. **Implement Feature**:
   - One test at a time
   - Minimal code to pass
   - No premature optimization

4. **Refactor for Production**:
   - Apply design patterns
   - Add documentation
   - Ensure SOLID principles

## RollCall TDD Guidelines:

### ViewModel Tests
- Test all @Published properties
- Verify state transitions
- Mock service dependencies
- Test error scenarios

### Service Tests
- Mock network calls
- Test data transformation
- Verify error mapping
- Test caching behavior

### Coordinator Tests
- Test navigation flow
- Verify view controller creation
- Test deep linking
- Check memory management

### View Tests (Optional)
- Snapshot tests for critical UI
- Accessibility checks
- Dynamic Type support
- Dark mode compatibility

## Common TDD Patterns:

### Async Testing
```swift
func test_loadData_updatesViewModel() async {
    // Arrange
    let mockService = MockRollService()
    let sut = FeedViewModel(service: mockService)
    
    // Act
    await sut.loadRolls()
    
    // Assert
    XCTAssertEqual(sut.rolls.count, 3)
    XCTAssertFalse(sut.isLoading)
}
```

### State Testing
```swift
func test_stateTransitions() {
    let sut = CreateRollViewModel()
    
    // Initial state
    XCTAssertEqual(sut.state, .idle)
    
    // Loading state
    sut.save()
    XCTAssertEqual(sut.state, .loading)
    
    // Success state
    // ... trigger success
    XCTAssertEqual(sut.state, .success)
}
```

## Success Criteria:
- ✅ All tests written before implementation
- ✅ Each test tests one thing
- ✅ Tests are fast and isolated
- ✅ >80% code coverage
- ✅ No test interdependencies