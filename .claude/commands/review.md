# Review RollCall Code Changes

Use the rollcall-code-reviewer agent to perform comprehensive code review.

Usage: `/review [PR-number|branch|all]`

## Review Process:

1. **Identify Changes to Review**:
   - If $ARGUMENTS is a PR number, review that PR
   - If $ARGUMENTS is "all", review all uncommitted changes
   - Otherwise, review changes in current branch vs main

2. **Launch Code Reviewer Agent**:
   Use Task tool to launch rollcall-code-reviewer to check:
   
   **Architecture Compliance**:
   - MVVM-C pattern adherence
   - Proper separation of concerns
   - Dependency injection patterns
   - No singletons except AppCoordinator
   
   **Swift Best Practices**:
   - No force unwrapping outside tests
   - Proper error handling with AppError
   - Async/await for all async operations
   - [weak self] in closures where needed
   
   **RollCall Guidelines**:
   - iOS 15+ compatibility
   - Design token usage
   - Accessibility labels present
   - 4pt spacing grid compliance
   
   **Testing**:
   - Test coverage >80% for ViewModels
   - TDD approach followed
   - Proper test naming conventions
   - Both success and failure paths tested

3. **Review Output Format**:
   ```
   🔍 Code Review Results
   =====================
   
   ✅ Passed:
   - MVVM-C architecture
   - No force unwrapping
   - Test coverage 85%
   
   ⚠️ Issues Found:
   - Missing [weak self] in Task closure (FeedViewModel.swift:45)
   - Hard-coded string should use constants (CreateRollView.swift:67)
   - Missing accessibility label (RollCardView.swift:23)
   
   📝 Suggestions:
   - Consider extracting complex view logic to ViewModifier
   - Add documentation for public API methods
   ```

4. **Generate Fix List**:
   Create actionable items for any issues found:
   - Critical (must fix): Architecture violations, memory leaks
   - Important (should fix): Best practice violations
   - Nice to have: Style improvements

## Arguments:
- PR number (e.g., "123") - Review specific PR
- "all" - Review all uncommitted changes
- "staged" - Review only staged changes
- No arguments - Review current branch changes