# RollCall Deferred Infrastructure Items

This document tracks all infrastructure and testing items deferred during MVP stabilization. These items were consciously deferred to focus on shipping features first.

## Overview

During the stabilization phase (January 2025), we made pragmatic decisions to simplify our infrastructure for MVP. This document captures what was deferred, why, and when each item should be revisited.

## Deferred Items from Stabilization Plan

### 1. Testing Infrastructure

#### Integration Tests (Priority 3.2) ⏸️
**Deferred from**: STABILIZATION_PLAN.md
**When to implement**: After Feed, Create Roll, and Profile features exist
- [ ] Test navigation flows between features
- [ ] Test data persistence across app sessions  
- [ ] Test service integration with real API
- [ ] Test error scenarios and recovery
- [ ] Test offline functionality

**Why deferred**: No features to integrate yet. Testing empty placeholders provides no value.

#### UI Tests (Priority 3.3) ⏸️
**Deferred from**: STABILIZATION_PLAN.md
**When to implement**: After UI is stable and features are complete
- [ ] Complete onboarding flow testing
- [ ] Main navigation testing with populated tabs
- [ ] Accessibility testing with VoiceOver
- [ ] Dynamic Type testing for all screens
- [ ] Dark mode testing across app

**Why deferred**: Current UI is mostly empty tabs. Comprehensive UI testing makes sense only with real content.

### 2. CI/CD Enhancements

#### Advanced GitHub Actions (Priority 4.1) ⏸️
**Deferred from**: STABILIZATION_PLAN.md - CI/CD Stabilization
**When to implement**: After initial App Store release

- [ ] Enable code coverage reporting with xcresult files
  - *Why deferred*: Coverage metrics for skeleton app are misleading
  
- [ ] Add proper test result artifacts and trending
  - *Why deferred*: Overkill for current simple test suite
  
- [ ] Implement dependency security scanning
  - *Why deferred*: No external dependencies to scan (only SwiftLint via Homebrew)
  
- [ ] SwiftFormat in CI
  - *Why deferred*: SwiftLint handles most formatting concerns for MVP

#### Quality Gates (Priority 4.2) ⏸️
**Deferred from**: STABILIZATION_PLAN.md
**When to implement**: When team grows beyond 3 developers

- [ ] Enforce minimum test coverage (80%)
  - *Why deferred*: Coverage metrics meaningless without features
  
- [ ] Add build time monitoring
  - *Why deferred*: Premature optimization; builds are fast
  
- [ ] Setup comprehensive branch protection rules
  - *Why deferred*: Can be added via GitHub UI when needed
  
- [ ] Automated PR checks beyond basic CI
  - *Why deferred*: Current simple CI is sufficient for small team

#### Development Workflow (Priority 4.3) ⏸️
**Deferred from**: STABILIZATION_PLAN.md
**When to implement**: As team and codebase grow

- [ ] Create development branch and git-flow
  - *Why deferred*: Main-only is simpler for MVP
  
- [ ] Add CODEOWNERS file
  - *Why deferred*: Unnecessary overhead for small team
  
- [ ] Complex PR templates
  - *Why deferred*: Current minimal template is sufficient

### 3. Documentation & Standards (Priority 5)

#### Technical Documentation ⏸️
**Deferred from**: STABILIZATION_PLAN.md
**When to implement**: Before scaling team

- [ ] Architecture Decision Records (ADRs)
- [ ] Comprehensive API documentation
- [ ] Inline code documentation
- [ ] Detailed setup instructions beyond CONTRIBUTING.md

**Why deferred**: CLAUDE.md provides sufficient guidance for current needs

#### Development Standards ⏸️
**Deferred from**: STABILIZATION_PLAN.md
**When to implement**: As patterns emerge

- [ ] Pre-commit hooks for linting
- [ ] Xcode build phase scripts for formatting
- [ ] Detailed branching strategy documentation
- [ ] Xcode workspace setup automation
- [ ] MVVM-C Xcode templates

**Why deferred**: Team can follow existing patterns; automation adds complexity

### 4. Xcode-Specific Items

#### Build Configuration ⏸️
**Deferred from**: STABILIZATION_PLAN.md - Xcode Considerations
**When to implement**: For App Store release

- [ ] Configure build settings for Debug/Release configurations
- [ ] Set up proper code signing
- [ ] Configure provisioning profiles
- [ ] Pin Xcode version in CI

**Why deferred**: Not needed until App Store deployment

#### Project Organization ⏸️
**Deferred from**: STABILIZATION_PLAN.md
**When to implement**: As needed

- [ ] Folder references matching file system
- [ ] Additional build phase scripts
- [ ] Complex test target configuration

**Why deferred**: Current setup works well

## Implementation Triggers

### Immediate (When Triggered)
1. **Branch protection**: When first external contributor joins
2. **Code signing**: When preparing for TestFlight
3. **Coverage reporting**: When features provide meaningful metrics

### Short Term (1-2 months)
1. **Integration tests**: Once Feed + Create Roll features complete
2. **Build configurations**: For TestFlight beta
3. **Basic UI tests**: For critical user paths

### Medium Term (3-6 months)
1. **Advanced CI/CD**: After App Store launch
2. **Comprehensive documentation**: Before hiring
3. **Performance monitoring**: Based on user feedback

### Long Term (6+ months)
1. **Full automation suite**: When team > 5 developers
2. **Complex workflows**: When feature velocity demands it
3. **Modularization**: When build times become problematic

## Decision Framework

Before implementing any deferred item, ask:

1. **Does this solve a real problem we're experiencing?**
2. **Will this speed up development or slow it down?**
3. **Is the team size/velocity appropriate for this complexity?**
4. **Do we have features that make this meaningful?**
5. **What's the maintenance cost?**

## Related Documents

- `STABILIZATION_PLAN.md` - Original stabilization plan with deferrals marked
- `FUTURE_TEST_PLAN.md` - Comprehensive testing strategy for when features exist
- `FUTURE_DEV.md` - Feature development roadmap
- `CLAUDE.md` - Current development guidelines

## Conclusion

These deferrals represent conscious trade-offs to achieve MVP faster. Each item has clear triggers for when it becomes valuable. This approach prevents over-engineering while maintaining a path for growth.

**Remember**: The goal is to ship value to users, not to build perfect infrastructure.

---

Created: 2025-01-21
Last Updated: 2025-01-21
Status: Living Document - Review quarterly