# RollCall Claude Commands

This directory contains custom slash commands for Claude Code to streamline RollCall iOS app development.

## Setup

These commands are automatically available when using Claude Code in the RollCall project. Simply type `/` followed by the command name.

## Command Categories

### Core Development Loop
- `/loop` - Complete P0 cycle automation
- `/status` - Current development status
- `/metrics` - Generate CI metrics

### Architecture & Planning
- `/architect` - Update ROADMAP with architect agent
- `/p0` - Manage P0 items

### Implementation
- `/code` - Implement P0 items with Swift coder agent
- `/tdd` - Test-driven development workflow
- `/review` - Code review with reviewer agent

### Validation & Quality
- `/validate` - Smart validation based on changes
- `/quick` - Rapid format and lint check
- `/fix` - Auto-fix common issues

### Workflows
- `/morning` - Daily startup routine
- `/pr` - Pull request preparation
- `/ship` - Deployment preparation
- `/panic` - Emergency recovery

## Quick Start

1. **Start your day**: `/morning`
2. **Check status**: `/status`
3. **Implement P0**: `/code`
4. **Validate changes**: `/validate`
5. **Create PR**: `/pr create`

## Command Arguments

Many commands accept arguments for specific behavior:

```bash
/validate quick        # Format and lint only
/validate full        # Complete validation with tests
/fix ci              # Fix CI pipeline issues
/p0 done RC-P0-015   # Mark P0 item as complete
```

## Integration with Agents

These commands integrate with RollCall-specific agents:
- `rollcall-architect` - ROADMAP and P0 planning
- `rollcall-swift-coder` - TDD implementation
- `rollcall-code-reviewer` - Code review
- `rollcall-auditor` - Comprehensive auditing

## Customization

Commands use `$ARGUMENTS` variable for dynamic input:
- `/code RC-P0-015` - Implement specific P0
- `/review 123` - Review PR #123
- `/fix timeout` - Fix test timeout issues

## Best Practices

1. Always run `/validate` before committing
2. Use `/quick` for rapid iteration during development
3. Run `/morning` to start with full context
4. Use `/panic` when things are critically broken
5. Follow `/tdd` for new feature development

## Command Flow Example

```bash
# Morning routine
/morning

# Work on current P0
/code

# Quick validation during development  
/quick

# Full validation before PR
/validate full

# Create pull request
/pr create

# If issues found
/fix all

# Ship when ready
/ship feature
```

## Troubleshooting

- If commands don't appear, restart Claude Code
- For command help, use `/help`
- To see command details, check the `.md` file in this directory

## Contributing

To add new commands:
1. Create a `.md` file with the command name
2. Use clear descriptions and step-by-step instructions
3. Include usage examples with `$ARGUMENTS`
4. Test the command workflow

## Related Documentation

- `CLAUDE.md` - Development guidelines
- `ROADMAP.md` - Current P0 priorities and progress
- `.claude/agents/` - Agent-specific prompts
- `scripts/` - Shell scripts for automation