# Implement RollCall P0 Item

Use the rollcall-swift-coder agent to implement a P0 item following TDD and MVVM-C patterns.

Usage: `/code [P0-ID]`

## Process:

1. **Identify P0 Item**:
   - If $ARGUMENTS provided (e.g., "RC-P0-015"), use that P0 ID
   - Otherwise, get next unblocked P0 from ROADMAP.md
   - Extract the P0 Plan JSON for this item

2. **Launch Swift Coder Agent**:
   Use Task tool to launch rollcall-swift-coder with:
   - The P0 Plan JSON for the specific item
   - Instructions to follow TDD approach:
     1. Write failing tests first
     2. Implement minimal code to pass
     3. Refactor for quality
   - Ensure MVVM-C architecture compliance
   - Follow all CLAUDE.md guidelines

3. **Implementation Requirements**:
   - **TDD**: Tests must be written before implementation
   - **MVVM-C**: Proper separation of concerns
   - **No Force Unwrapping**: Except in tests with safety comments
   - **SwiftLint Clean**: 0 violations required
   - **iOS 15+**: All code must support iOS 15 minimum
   - **Proper DI**: Dependency injection via initializers

4. **Deliverables**:
   - Implementation files as specified in P0 Plan
   - Unit tests with >80% coverage
   - Updated integration if needed
   - All tests passing

5. **Create PR**:
   - Branch name: `feat/RC-P0-###-description`
   - PR title includes P0 ID
   - DoD checklist in PR description
   - Paste work item from P0 Plan

## Arguments:
- If $ARGUMENTS is a P0 ID (e.g., "RC-P0-015"), implement that specific item
- If $ARGUMENTS is "next", implement the next unblocked P0
- If no arguments, implement the current/next P0 item