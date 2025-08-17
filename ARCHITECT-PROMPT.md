@agent-rollcall-architect

Title
Iterative P0 Planner — Guidelines + ROADMAP v5.0 (Anchor-Synced)

Pre-Flight (read these FIRST, then act)
1) Open and internalize “RollCall Development Guidelines”:
   - Iterative Workflow (P0 Loop) — Agent Contract
   - ROADMAP & Anchors Contract
   - CI Metrics Contract (ci-metrics.json schema)
   - P0 Plan (JSON) — Handoff Schema
   - QP0 macro intent, DoD, and zero-lint policy ramp
2) Resolve conflicts by priority:
   ROADMAP Invariants > Guidelines > Your assumptions (assumptions must be listed).

Inputs (required)
- The current ROADMAP anchors (exact text inside these four pairs):
  <!-- P0_TASKS -->…<!-- /P0_TASKS -->
  <!-- METRICS -->…<!-- /METRICS -->
  <!-- CHANGELOG -->…<!-- /CHANGELOG -->
  <!-- MACHINE_STATE -->…<!-- /MACHINE_STATE -->
- Latest CI facts (ci-metrics.json): { build_main, build_tests, coverage_percent, swiftlint_remaining, test_failures }

Objective (strict)
Update ONLY the four anchored regions in ROADMAP.md and emit a machine-readable P0 Plan (JSON) per the Guidelines’ schema. Keep P0 to 3–7 atomic, testable items that unblock MVP **now** (tests compile → coverage real → lint=0 → gates green). Do not modify any other sections.

Scope Guards
- Touch only the four anchors above.
- Respect all Invariants (platform, MVVM-C, DI via initializers, Core Data, a11y).
- Prefer refactors (split files/types) over disabling lint rules.
- If a detail is unknown, choose a minimal, standards-compliant default and record it under "assumptions".

Deliverables (return ALL, in this exact order)

1) ### Immediate Next Steps (P0) — replace between anchors
- Keep/refresh the “Scope” line.
- List 3–7 items with IDs RC-P0-### and fields: Title, Rationale, Deliverables, Acceptance.
- IDs must match p0_ids in Machine State.

2) ### Metrics — replace between anchors
- Report current: build_main, build_tests, coverage_percent (or n/a), swiftlint_remaining (integer).
- Keep perf/a11y/stability targets; fill numbers only if measured.

3) ### Changelog — append between anchors
- Preserve prior lines; append one new line like:
  - YYYY-MM-DD: concise summary (timezone America/Mexico_City)

4) ### Machine State — replace between anchors (valid JSON)
Include at least:
{
  "version": "5.0",
  "updated_at": "<ISO8601 -06:00>",
  "tz": "America/Mexico_City",
  "build_main": "green|yellow|red",
  "build_tests": "green|yellow|red",
  "coverage_percent": <number|null>,
  "swiftlint_remaining": <number>,
  "perf": { "save_p90_ms": <number|null>, "feed_p90_ms": <number|null> },
  "stability_crash_free_pct": <number|null>,
  "a11y_core_paths_verified": <true|false>,
  "p0_ids": ["RC-P0-###", ...],
  "test_failures": ["..."]
}

5) ### P0 Plan (JSON) — do NOT modify ROADMAP here
- Emit exactly the “P0 Plan (JSON) — Handoff Schema” from the Guidelines, filled with the new P0 items.
- Include "verification_commands", "assumptions", "open_questions".

Work Policy (how you decide P0)
- Treat current P0 as baseline: close if CI proves done, keep if still red, add only the smallest new unblockers.
- Prioritize strictly: tests compile → coverage real → lint to 0 → quality gates green.
- Keep 3–7 items total, each independently verifiable.

Quality Checks (self-verify before returning)
- Anchors updated only; valid JSON; p0_ids match P0 list.
- Numbers align across Metrics and Machine State.
- One new ISO-dated Changelog line.
- No edits outside anchors; no handoffs to other agents.
