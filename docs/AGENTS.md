# RollCall Agent Prompts

This document contains the two key prompts for the iterative P0-driven development workflow.

## Architect Prompt (Iterative P0 Planner — ROADMAP v5.0)

Use this prompt to update the ROADMAP based on current metrics and progress:

```
You are an iOS architect maintaining ROADMAP.md for RollCall.

Input: 
1. Current ROADMAP.md content (or just the four anchored blocks)
2. Latest ci-metrics.json from CI

Your task:
1. Analyze the metrics to understand current state
2. Update ONLY these four anchored blocks:
   - P0_TASKS: Close completed items, keep failing ones, add next minimal unblockers (3-7 total)
   - METRICS: Update with latest CI values
   - CHANGELOG: Append one line describing this update
   - MACHINE_STATE: Update JSON with current values
3. Return the updated blocks exactly as they should appear between anchors
4. Generate a P0 Plan (JSON) for the coder

P0 Task Selection Criteria:
- Only include tasks that directly unblock MVP progress
- Each task must be atomic and independently verifiable
- Prefer fixing broken things over adding new features
- Keep total count between 3-7 items
- Include clear acceptance criteria

Output Format:
1. Updated P0_TASKS block content
2. Updated METRICS block content  
3. Updated CHANGELOG block content
4. Updated MACHINE_STATE block content
5. P0 Plan JSON:
{
  "tasks": [
    {
      "id": "RC-P0-XXX",
      "title": "Brief title",
      "rationale": "Why this unblocks progress",
      "deliverables": ["specific", "measurable", "outcomes"],
      "acceptance": "How to verify completion"
    }
  ]
}
```

## Coder Prompt

Use this one-liner with the P0 Plan JSON from the Architect:

```
Implement exactly what's in this P0 Plan (JSON). Use TDD and Conventional Commits. One PR per RC-P0-### with the DoD checklist.
```

## Workflow Usage

### Step 1: Run CI and Get Metrics
```bash
# After CI runs, download ci-metrics.json artifact
# Or run locally:
./scripts/test.sh
swiftlint --quiet | wc -l
```

### Step 2: Feed to Architect
1. Copy current ROADMAP.md content (or just the four anchor blocks)
2. Copy ci-metrics.json content
3. Use the Architect Prompt
4. Get back updated blocks and P0 Plan

### Step 3: Update ROADMAP
```bash
# Save architect outputs to files
echo "P0 content" > new_p0.md
echo "Metrics content" > new_metrics.md
echo "Changelog content" > new_changelog.md
echo "Machine state content" > new_state.md

# Update ROADMAP
python scripts/update_anchors.py \
  P0_TASKS new_p0.md \
  METRICS new_metrics.md \
  CHANGELOG new_changelog.md \
  MACHINE_STATE new_state.md

# Commit
git add ROADMAP.md
git commit -m "docs(roadmap): update P0 tasks and metrics from architect"
```

### Step 4: Execute P0 Plan
1. Send P0 Plan JSON to coder with the one-liner prompt
2. Coder creates one PR per RC-P0-### task
3. Each PR uses the template and follows DoD

### Step 5: Iterate
After PRs merge, repeat from Step 1

## Conventions

### Branch Naming
- `feature/RC-P0-001-fix-tests`
- `fix/RC-P0-002-swiftlint`
- `refactor/RC-P0-003-viewmodel-split`

### Commit Messages
```
test(create-roll): add missing coordinator tests (RC-P0-001)
fix(lint): resolve trailing comma violations (RC-P0-002)
refactor(feed): split large view model (RC-P0-003)
```

### PR Flow
1. Create branch from main
2. Implement with TDD
3. Ensure all DoD items checked
4. Open PR with template filled
5. CI must be green
6. Merge to main

## Troubleshooting

### Coverage is null
- Ensure test bundle exists: `test-results.xcresult`
- Check xcrun xccov is available
- Verify jq expression in CI

### Lint count wrong
- Run `swiftlint --version` to check version
- Ensure same config locally and in CI
- Check working directory is correct

### Architect suggests wrong tasks
- Verify latest ROADMAP content provided
- Ensure ci-metrics.json is current
- Check MACHINE_STATE JSON is valid

## Example Metrics File

```json
{
  "build_main": "green",
  "build_tests": "red",
  "coverage_percent": 45.3,
  "swiftlint_remaining": 15,
  "test_failures": ["CreateRollCoordinatorTests"]
}
```