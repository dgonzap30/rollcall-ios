# 🍣 RollCall Development Roadmap v2.0

## Project Overview
RollCall is a social sushi logging app that allows users ("chefs") to track, rate, and share their sushi experiences. The app follows MVVM-C architecture with a local-first approach.

## Current State (January 2025)
- ✅ **Infrastructure**: Complete MVVM-C skeleton with Core Data, DI, and navigation
- ✅ **Architecture**: Production-ready foundation with ~80% test coverage
- ✅ **CI/CD**: Simplified pipeline appropriate for MVP
- ✅ **Onboarding**: Complete multi-page onboarding with tutorial screens
- 🔲 **Features**: Feed, Create Roll, and Profile are placeholders

## Development Philosophy
1. **Local-First**: All features work offline; networking added later
2. **Incremental Delivery**: Ship one complete feature before starting the next
3. **Test-Driven**: Maintain >80% coverage for ViewModels and Services
4. **User-Centric**: Each phase delivers tangible user value

## Phase-by-Phase Development Plan

### Phase 0: Onboarding Polish (3 days) ✅
**Goal**: Complete the first-run experience
**Status**: COMPLETED (2025-01-21)

#### Tasks:
- [x] Welcome screen with animations
- [x] Add 2 tutorial screens explaining core features
- [x] Implement page indicators with smooth transitions
- [x] Add "Skip" functionality that stores preference
- [x] Store onboarding completion in UserDefaults
- [x] Add haptic feedback for all interactions

#### Success Criteria:
- ✅ Users understand app purpose within 30 seconds
- ✅ Onboarding completion tracked in UserDefaults
- ✅ No onboarding shown on subsequent launches

#### Implementation Highlights:
- **Architecture**: Proper MVVM-C with delegate patterns
- **Services**: Created UserPreferencesServicing for UserDefaults abstraction
- **Testing**: Comprehensive test coverage for ViewModels (>80%)
- **Accessibility**: Full WCAG 2.2 AA compliance with proper labels
- **Navigation**: TabView-based page navigation with smooth transitions
- **Design**: Followed 4pt spacing grid and design tokens

### Phase 1: Authentication & User Management (1 week) 🔐
**Goal**: Secure user accounts with biometric support

#### 1.1 Authentication UI
- [ ] Create AuthCoordinator following existing patterns
- [ ] Build LoginView with email/password fields
- [ ] Build SignupView with validation
- [ ] Implement forgot password flow
- [ ] Add loading states and error handling

#### 1.2 Authentication Logic
- [ ] Create AuthViewModel with login/signup logic
- [ ] Implement Keychain wrapper for secure storage
- [ ] Add biometric authentication (Face ID/Touch ID)
- [ ] Create authenticated state management in AppCoordinator
- [ ] Add logout functionality to ProfileView

#### 1.3 User Profile Setup
- [ ] Create profile completion screen post-signup
- [ ] Allow username selection (unique validation)
- [ ] Optional profile photo upload
- [ ] Store user data in Core Data Chef entity

#### Testing Requirements:
- [ ] AuthViewModel unit tests (>80%)
- [ ] Keychain wrapper tests
- [ ] Integration tests for auth flow
- [ ] UI tests for critical paths

#### Success Criteria:
- Secure credential storage
- Biometric login working
- Smooth transition from auth to main app
- Profile data persisted locally

### Phase 2: Roll Creation - Core Feature (1.5 weeks) 📸
**Goal**: Enable users to log their first sushi roll

#### 2.1 Camera & Photo Selection
- [ ] Create RollCreationCoordinator
- [ ] Implement camera capture with AVFoundation
- [ ] Add photo picker for library images
- [ ] Build image preview/crop interface
- [ ] Implement image compression (2048x2048 max)
- [ ] Generate and cache thumbnails

#### 2.2 Roll Details Form
- [ ] Create RollCreationViewModel
- [ ] Build form UI with SwiftUI:
  - [ ] Roll name text field with suggestions
  - [ ] Roll type picker (Nigiri, Maki, Sashimi, etc.)
  - [ ] Rating component (1-5 stars) with haptics
  - [ ] Notes text editor with character limit
  - [ ] Price input (optional)
- [ ] Add form validation and error states
- [ ] Implement draft saving (prevent data loss)

#### 2.3 Restaurant Selection
- [ ] Create restaurant search/selection view
- [ ] Implement manual restaurant entry
- [ ] Add location permission request
- [ ] Use Core Location for current location
- [ ] Store restaurant in Core Data

#### 2.4 Save & Confirmation
- [ ] Create preview screen before saving
- [ ] Implement Core Data save with relationships
- [ ] Add success animation (confetti)
- [ ] Navigate to new roll in feed
- [ ] Handle save errors gracefully

#### Testing Requirements:
- [ ] RollCreationViewModel tests
- [ ] Image compression tests
- [ ] Core Data save tests
- [ ] Form validation tests

#### Success Criteria:
- Users can capture/select photos
- All roll details saved correctly
- No data loss on app termination
- <3 seconds to save a roll

### Phase 3: Feed & Discovery (1.5 weeks) 📱
**Goal**: Users can view and interact with their roll history

#### 3.1 Personal Feed
- [ ] Create FeedCoordinator and FeedViewModel
- [ ] Build timeline view showing user's rolls
- [ ] Implement RollCardView component:
  - [ ] Photo with aspect ratio preservation
  - [ ] Roll name and type
  - [ ] Rating display
  - [ ] Restaurant name and date
- [ ] Add pull-to-refresh functionality
- [ ] Implement Core Data fetch with sorting
- [ ] Add empty state for new users

#### 3.2 Roll Detail View
- [ ] Create RollDetailViewModel
- [ ] Build detailed view with:
  - [ ] Full-size photo with zoom
  - [ ] Complete roll information
  - [ ] Edit functionality
  - [ ] Delete with confirmation
- [ ] Add swipe navigation between rolls
- [ ] Implement share sheet functionality

#### 3.3 Search & Filters
- [ ] Add search bar to feed
- [ ] Implement filters:
  - [ ] By roll type
  - [ ] By rating (4+ stars, etc.)
  - [ ] By date range
  - [ ] By restaurant
- [ ] Create filter persistence
- [ ] Add sort options (date, rating, name)

#### Testing Requirements:
- [ ] FeedViewModel pagination tests
- [ ] Core Data fetch performance tests
- [ ] Filter logic tests
- [ ] Memory usage tests with large datasets

#### Success Criteria:
- Smooth scrolling with 100+ rolls
- <100ms search response time
- Filters work correctly
- No memory leaks

### Phase 4: User Profile & Settings (1 week) 👤
**Goal**: Complete user experience with profile and preferences

#### 4.1 Profile Screen
- [ ] Create ProfileCoordinator
- [ ] Build profile header:
  - [ ] Profile photo
  - [ ] Username and join date
  - [ ] Editable bio
- [ ] Add statistics dashboard:
  - [ ] Total rolls logged
  - [ ] Favorite roll type (calculated)
  - [ ] Top-rated restaurant
  - [ ] Average rating given
  - [ ] Rolls this month/year
- [ ] Create roll collection view
- [ ] Add profile editing functionality

#### 4.2 Settings Implementation
- [ ] Create SettingsViewModel
- [ ] Build settings sections:
  - [ ] Account (email, password change)
  - [ ] Privacy (future: visibility settings)
  - [ ] Notifications (future: push settings)
  - [ ] Display (dark mode, haptics)
  - [ ] Data (export, clear cache)
  - [ ] About (version, terms, privacy policy)
- [ ] Implement data export as JSON/CSV
- [ ] Add cache management

#### 4.3 User Preferences
- [ ] Store preferences in UserDefaults
- [ ] Implement dark mode toggle
- [ ] Add haptic feedback preferences
- [ ] Create app icon alternatives
- [ ] Implement app review prompt logic

#### Testing Requirements:
- [ ] Profile statistics accuracy tests
- [ ] Settings persistence tests
- [ ] Data export format tests
- [ ] Theme switching tests

#### Success Criteria:
- All statistics calculate correctly
- Settings persist between launches
- Data export includes all user data
- Smooth theme transitions

### Phase 5: MVP Polish & Release Prep (1 week) 🚀
**Goal**: Prepare for TestFlight beta

#### 5.1 UI/UX Polish
- [ ] Review all screens for design consistency
- [ ] Add loading skeletons for all async operations
- [ ] Implement error recovery flows
- [ ] Add contextual help/tooltips
- [ ] Ensure all animations respect reduce motion
- [ ] Complete accessibility audit

#### 5.2 Performance Optimization
- [ ] Profile app with Instruments
- [ ] Optimize image loading and caching
- [ ] Reduce app launch time to <1s
- [ ] Minimize memory footprint
- [ ] Add performance monitoring

#### 5.3 Release Preparation
- [ ] Create App Store Connect record
- [ ] Design app icon (1024x1024)
- [ ] Create screenshots for all device sizes
- [ ] Write App Store description
- [ ] Implement analytics (privacy-friendly)
- [ ] Add crash reporting (Sentry)
- [ ] Create TestFlight beta test plan

#### Success Criteria:
- No crashes in 24-hour test period
- All critical user paths smooth
- App size <50MB
- TestFlight build approved

## Post-MVP Phases

### Phase 6: Social Features (v1.1)
**Timeline**: Post-launch based on user feedback

- Restaurant discovery map
- Follow other chefs
- Like and comment on rolls
- Activity feed
- Push notifications

### Phase 7: Advanced Features (v1.2)
**Timeline**: 3-6 months post-launch

- Backend API integration
- Multi-device sync
- Advanced statistics
- Restaurant partnerships
- Social sharing enhancements

### Phase 8: Platform Expansion (v2.0)
**Timeline**: 6-12 months post-launch

- iPad optimization
- Apple Watch app
- Widget for quick logging
- Siri Shortcuts
- CloudKit sync

## 📋 Implementation Guidelines

### Technical Standards

1. **Architecture**: Strict MVVM-C adherence
   - ViewModels: Pure Swift, no UI imports
   - Views: SwiftUI only, @MainActor compliant
   - Coordinators: Own all navigation logic
   - Services: Protocol-based with mock implementations

2. **Data Persistence**
   - Core Data for all local storage (already set up)
   - UserDefaults for simple preferences only
   - Keychain for sensitive data (auth tokens)
   - No third-party databases

3. **Testing Requirements**
   - ViewModels: >80% coverage required
   - Services: >80% coverage required
   - UI Tests: Critical paths only
   - Performance tests for data operations

4. **Code Quality**
   - SwiftLint must pass (already configured)
   - No force unwrapping without safety comments
   - All errors handled with AppError enum
   - Memory leaks checked before each PR

### Development Workflow

1. **Feature Development Process**
   ```bash
   # Start feature
   git checkout -b feature/[phase]-[feature-name]
   
   # Development cycle
   - Write failing tests first (TDD)
   - Implement feature
   - Run tests: xcodebuild test
   - Fix SwiftLint warnings
   - Create PR with template
   ```

2. **Definition of Done**
   - [ ] Feature works offline
   - [ ] ViewModels have >80% test coverage
   - [ ] No SwiftLint violations
   - [ ] PR approved by one reviewer
   - [ ] Tested on iPhone 15 & iPhone SE
   - [ ] Memory profiled (no leaks)
   - [ ] Accessibility tested

### Performance Guidelines

1. **Image Handling**
   - Max size: 2048x2048 @ 0.8 JPEG compression
   - Thumbnails: 400x400 for feed, 200x200 for lists
   - Use NSCache for memory management
   - Lazy load images in ScrollView

2. **Data Operations**
   - Batch Core Data operations
   - Use background contexts for heavy writes
   - Implement pagination (20 items per page)
   - Cache calculated statistics

3. **UI Responsiveness**
   - All animations: 200ms standard
   - Haptic feedback: light impact only
   - Debounce search inputs (300ms)
   - Show loading states within 100ms

## 🎯 Feature Prioritization

### MVP (v1.0) - Local Only
**Target**: 6 weeks from now
- ✅ Onboarding flow
- 🔲 User authentication (local)
- 🔲 Roll creation with photos
- 🔲 Personal feed view
- 🔲 Roll detail/edit/delete
- 🔲 User profile with stats
- 🔲 Settings & data export
- 🔲 Offline-first architecture

### v1.1 - Enhanced Local
**Target**: 2 weeks post-MVP
- Search and filters
- Restaurant management
- Roll collections/categories
- Advanced statistics
- CSV/JSON export
- Alternate app icons

### v1.2 - Social Foundation
**Target**: Based on user metrics
- Backend API integration
- User accounts sync
- Basic social features
- Push notifications
- Share to social media

### v2.0 - Platform Growth
**Target**: 6+ months
- iPad optimization
- Apple Watch app
- Widgets
- CloudKit sync
- Restaurant partnerships

## 🧪 Testing Strategy by Phase

### Phase 0 (Onboarding)
- ✅ WelcomeViewModel tests
- ✅ OnboardingViewModel tests
- ✅ OnboardingViewState tests
- ✅ UserDefaults persistence tests (via UserPreferencesService)
- ✅ Delegate pattern tests
- ✅ Memory leak tests

### Phase 1 (Authentication)
- [ ] AuthViewModel tests (login/signup)
- [ ] Keychain wrapper tests
- [ ] Biometric auth tests
- [ ] Auth state management tests

### Phase 2 (Roll Creation)
- [ ] RollCreationViewModel tests
- [ ] Image compression tests
- [ ] Form validation tests
- [ ] Core Data save tests

### Phase 3 (Feed)
- [ ] FeedViewModel tests
- [ ] Pagination tests
- [ ] Filter/sort tests
- [ ] Performance tests (100+ items)

### Phase 4 (Profile)
- [ ] ProfileViewModel tests
- [ ] Statistics calculation tests
- [ ] Settings persistence tests
- [ ] Data export tests

### Phase 5 (Polish)
- [ ] UI regression tests
- [ ] Performance benchmarks
- [ ] Accessibility tests
- [ ] Device compatibility tests

## 📱 Platform Requirements

### Supported Devices
- **Minimum**: iOS 15.0+, iPhone SE (2nd gen)
- **Target**: iOS 17.0+, iPhone 12 and newer
- **Optimal**: iPhone 15 Pro with Dynamic Island

### Required Capabilities
- Camera (photo capture)
- Photo library access
- Location services (optional)
- Biometric authentication
- Network (future phases)

### Accessibility Support
- VoiceOver: Full support
- Dynamic Type: Up to XXL
- Reduce Motion: Respected
- High Contrast: Supported
- Bold Text: Supported

## 🚦 Success Metrics by Phase

### Phase 1 (Authentication)
- 80% complete profile after signup
- <5% authentication errors
- 90% enable biometric login

### Phase 2 (Roll Creation)
- 70% create first roll within 24h
- <10s average roll creation time
- 95% successful saves

### Phase 3 (Feed)
- <1s feed load time
- 60% users view roll details
- 40% use search/filters

### Phase 4 (Profile)
- 50% customize settings
- 30% export their data
- 80% view statistics weekly

### Overall MVP Targets
- App launch: <1.5s
- Memory: <150MB
- Crash-free: 99.5%
- App Store: 4.5+ rating
- Retention: 30% at 7 days

## 📅 Development Timeline

### Week 1-2: Foundation
- **Week 1**: ✅ Complete onboarding (DONE 2025-01-21), start authentication
- **Week 2**: Finish auth, biometrics, profile setup

### Week 3-4: Core Features  
- **Week 3**: Roll creation flow, camera/photos
- **Week 4**: Complete creation, start feed

### Week 5-6: User Experience
- **Week 5**: Feed, search, filters, detail view
- **Week 6**: Profile, settings, data export

### Week 7: Polish & Release
- **Days 1-3**: UI polish, performance
- **Days 4-5**: Release prep, TestFlight
- **Days 6-7**: Beta feedback, fixes

### Post-Release Sprints
- **Sprint 1**: Address beta feedback
- **Sprint 2**: v1.1 features
- **Sprint 3**: Performance optimization
- **Sprint 4**: Begin v1.2 planning

## 🚀 Risk Mitigation

### Technical Risks
1. **Core Data Complexity**
   - Mitigation: Keep schema simple for MVP
   - Use lightweight migrations only
   - Test with large datasets early

2. **Image Storage**
   - Mitigation: Compress aggressively
   - Implement storage limits
   - Add cleanup for old images

3. **Performance**
   - Mitigation: Profile early and often
   - Implement pagination from start
   - Use Instruments weekly

### Schedule Risks
1. **Feature Creep**
   - Mitigation: Strict phase boundaries
   - Defer all "nice to have" features
   - Weekly progress reviews

2. **Technical Debt**
   - Mitigation: Maintain test coverage
   - Refactor during each phase
   - Code review all PRs

### User Experience Risks
1. **Complex Onboarding**
   - Mitigation: User test early
   - Keep to 3 screens max
   - Allow skip option

2. **Data Loss**
   - Mitigation: Auto-save drafts
   - Implement undo/redo
   - Clear delete confirmations

## 🎨 Design Requirements by Phase

### Phase 0 (Onboarding)
- [ ] 2 tutorial screen illustrations
- [ ] Page indicator component

### Phase 1 (Authentication)  
- [ ] Login/signup screen designs
- [ ] Biometric prompt UI
- [ ] Profile setup flow

### Phase 2 (Roll Creation)
- [ ] Camera interface design
- [ ] Photo editing controls
- [ ] Form components (rating stars)
- [ ] Success animation

### Phase 3 (Feed)
- [ ] Roll card component
- [ ] Empty state illustration
- [ ] Pull-to-refresh animation
- [ ] Search/filter UI

### Phase 4 (Profile)
- [ ] Statistics dashboard
- [ ] Settings icons
- [ ] Export format templates

### Phase 5 (Release)
- [ ] App icon (1024x1024)
- [ ] App Store screenshots
- [ ] Launch screen
- [ ] Marketing website

## 📊 Decision Log

### Key Decisions Made
1. **Local-first approach**: No backend for MVP
2. **MVVM-C architecture**: Already implemented
3. **Core Data**: For all persistence
4. **SwiftUI only**: No UIKit except where required
5. **iPhone only**: iPad support deferred
6. **UserPreferences abstraction**: Service layer for UserDefaults (Phase 0)
7. **Delegate pattern**: Consistent navigation pattern (Phase 0)
8. **Accessibility first**: WCAG 2.2 AA compliance from start (Phase 0)

### Open Decisions
1. **Analytics provider**: Privacy-friendly options only
2. **Crash reporting**: Sentry vs alternatives
3. **Restaurant data**: Manual entry vs API
4. **Subscription model**: Freemium vs paid app

## 📚 Technical Debt Tracker

### Deferred Refactorings

#### 1. AppCoordinator Singleton Pattern
**Issue**: Singleton pattern prevents proper test isolation
**Impact**: 
- One failing test in RootViewTests
- Cannot test initial app state conditions
- Makes AppCoordinator state persist between tests

**Current Workaround**: Test failure documented with explanatory comment
**Proposed Solution**: 
- Refactor to dependency injection via SceneDelegate
- Create AppCoordinatorProtocol for testing
- Inject coordinator into RootView

**When to Address**:
- Before Phase 1 (Authentication) - When adding auth state management
- If adding more lifecycle tests
- During dedicated stabilization sprint

**Effort**: 2-4 hours
**Priority**: Medium (not blocking features)

**Implementation Plan**:
```swift
// Future: SceneDelegate.swift
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var appCoordinator: AppCoordinator?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options: UISceneConnectionOptions) {
        appCoordinator = AppCoordinator(container: DIContainer())
        // Pass to RootView
    }
}
```

### Future Technical Improvements
1. **Navigation Binding Optimization**: Consider batching state updates in OnboardingViewModel
2. **Swift 6 Compatibility**: Address concurrency warnings before Swift 6 adoption
3. **Test Infrastructure**: Add UI tests for critical navigation paths

## 🔄 Living Document

This roadmap is updated weekly based on:
- Development velocity
- User feedback
- Technical discoveries
- Market conditions

**Next Review**: End of Phase 1

## 📝 Lessons Learned

### Phase 0 (Onboarding) - Completed 2025-01-21
1. **Architecture Patterns**:
   - Delegate pattern superior to closures for navigation
   - Service abstraction (UserPreferencesService) improves testability
   - @MainActor should only be on UI update methods, not entire ViewModels

2. **Testing Insights**:
   - Async haptic feedback requires Task wrapping and test delays
   - Mock naming conflicts can occur - use unique prefixes
   - Comprehensive delegate tests prevent navigation bugs

3. **Design Implementation**:
   - TabView with PageTabViewStyle perfect for onboarding
   - Accessibility labels critical from start
   - 4pt spacing grid already well-established in constants

4. **Development Velocity**:
   - Phase 0 completed in 1 day vs 3 day estimate
   - Strong foundation accelerates feature development
   - Thorough QCHECK reviews prevent technical debt

5. **Navigation Implementation**:
   - SwiftUI TabView bindings require synchronous updates
   - Async Task wrappers in property observers can break bindings
   - Delegate chain must maintain @MainActor consistency
   - Debug logging essential for diagnosing navigation issues

6. **Technical Debt Management**:
   - Singleton pattern acceptable for MVP but impacts testing
   - Document debt immediately with clear migration paths
   - Balance perfect architecture vs shipping features
   - Calculated technical debt with clear payoff timeline is acceptable

---

Last Updated: 2025-01-21
Status: Phase 0 Complete with Navigation Fix, Ready for Phase 1 (Authentication)
Version: 2.2