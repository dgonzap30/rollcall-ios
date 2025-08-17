## What & Why

**RC-P0-ID(s)**: <!-- e.g., RC-P0-001, RC-P0-002 -->

**Summary**: <!-- Brief description of changes and rationale -->

## Changes Made

<!-- List key changes -->
- 
- 
- 

## Definition of Done Checklist

### Code Quality
- [ ] TDD: Tests written first, then implementation
- [ ] All new/updated tests passing
- [ ] Coverage unchanged or increased (MVP target ≥60%)
- [ ] `swiftformat .` yields no changes  
- [ ] `swiftlint` shows 0 violations (no new rule disables added)
- [ ] No force-unwraps in production code (tests allowed with rationale)

### Architecture & Design  
- [ ] Follows MVVM-C architecture patterns
- [ ] ViewModels contain NO UIKit/SwiftUI imports
- [ ] Unidirectional data flow maintained
- [ ] Dependency injection via initializers (no singletons except AppCoordinator)
- [ ] @MainActor only on UI update methods, not entire ViewModels

### Accessibility & UX
- [ ] Accessibility labels/hints on all interactive views
- [ ] WCAG 2.2 AA contrast preserved (AAA for CTAs)
- [ ] 44pt minimum touch targets
- [ ] VoiceOver path tested for new/changed flows

### Testing & Monitoring
- [ ] Unit tests cover critical paths
- [ ] If new surface added: Sentry test event triggered successfully
- [ ] Performance targets met (save ≤700ms p90, feed ≤200ms p90)
- [ ] Works offline (if applicable to feature)

## Test Plan

<!-- How to verify the changes work -->
1. 
2. 
3. 

## Screenshots/Videos

<!-- If UI changes, include before/after screenshots -->

## Related Issues

<!-- Link to related issues/tickets -->
- Closes #
- Related to #