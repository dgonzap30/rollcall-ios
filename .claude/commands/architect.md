# Run RollCall Architect Agent

Execute the rollcall-architect agent to update the ROADMAP and generate a P0 Plan.

## Steps:

1. **Collect Current State**:
   - Read ci-metrics.json for latest build/test/coverage metrics
   - Read ROADMAP.md to get current anchors:
     - P0_TASKS
     - METRICS
     - CHANGELOG
     - MACHINE_STATE

2. **Launch Architect Agent**:
   Use the Task tool to launch rollcall-architect agent with:
   - Current ROADMAP anchors
   - CI metrics
   - Instructions to update only the four managed anchors
   - Request for P0 Plan JSON output

3. **Update ROADMAP**:
   - Replace the four anchors in ROADMAP.md with architect's output
   - Ensure MACHINE_STATE JSON remains valid
   - Preserve all human-maintained sections

4. **Generate P0 Plan**:
   The architect should output a P0 Plan JSON with:
   - 3-7 atomic, testable P0 items
   - Each with ID (RC-P0-###), title, rationale, deliverables
   - Acceptance criteria and verification commands
   - Dependencies and estimates

5. **Commit Changes**:
   If changes were made:
   ```bash
   git add ROADMAP.md
   git commit -m "docs(roadmap): refresh P0/Metrics/State from architect"
   ```

## Arguments:
If $ARGUMENTS is provided:
- "refresh" - Force regeneration even if recent
- "dry-run" - Show what would change without updating