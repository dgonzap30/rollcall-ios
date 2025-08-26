# RollCall Command System Help

Display all available RollCall commands and their usage.

## Available Commands:

### 🔄 Core Loop Commands
- `/loop` - Run full P0 cycle (metrics → architect → code → review → fix)
- `/status` - Show current development status and metrics
- `/metrics [quick|full]` - Generate CI metrics and progress report

### 🏗️ Architecture Commands  
- `/architect` - Run architect agent to update ROADMAP and generate P0 Plan
- `/p0 [list|current|next|done|block]` - Manage P0 items for MVP

### 💻 Development Commands
- `/code [P0-ID]` - Implement P0 item using rollcall-swift-coder agent
- `/tdd [feature]` - Test-driven development workflow
- `/review [PR|all]` - Run comprehensive code review

### ✅ Validation Commands
- `/validate [quick|build|full|smart]` - Run validation suite
- `/quick` - Fast format and lint check only (<5 seconds)

### 🔧 Fix Commands
- `/fix [ci|timeout|lint|review|all]` - Auto-fix common issues
- `/panic [build|test|merge|deploy]` - Emergency recovery procedures

### 🚀 Workflow Commands
- `/morning` - Morning routine: status check and workspace setup
- `/pr [create|check|update]` - Prepare and manage pull requests
- `/ship [feature|hotfix|release]` - Deploy preparation and shipping

### 📊 Analytics Commands
- `/velocity` - Track development velocity and burndown
- `/health` - Overall project health check

## Quick Command Reference:

```bash
# Daily workflow
/morning                 # Start your day
/status                  # Check where you are
/code                    # Continue current P0
/validate smart          # Smart validation
/pr create              # Create pull request

# When things break
/panic build            # Fix broken builds
/fix ci                 # Unblock CI pipeline
/fix timeout            # Fix hanging tests

# Quick checks
/quick                  # Format + lint only
/metrics quick          # Fast metrics check
/p0 list               # See all P0 items
```

## Command Arguments:

Most commands accept arguments to customize behavior:
- `/validate [quick|build|full|smart]` - Validation depth
- `/fix [ci|timeout|lint|review|all]` - What to fix
- `/metrics [quick|full|export]` - Metrics detail level
- `/p0 [list|current|next|done RC-P0-###|block RC-P0-###]` - P0 actions

## Namespaced Commands:

Commands under `rollcall/` namespace:
- `/tdd` - Test-driven development (rollcall:tdd)
- `/quick` - Quick validation (rollcall:quick)

## Getting Started:

1. **New to RollCall?** Start with `/morning` to set up your workspace
2. **Continuing work?** Use `/status` to see current state
3. **Ready to code?** Run `/code` to implement the next P0
4. **Before committing?** Always run `/validate` first
5. **Creating PR?** Use `/pr create` for proper format

## Pro Tips:

- 🎯 `/loop` runs the entire cycle automatically
- ⚡ `/quick` is fastest for iterative development
- 🔍 `/review` catches issues before PR submission
- 🚨 `/panic` helps when everything is broken
- 📈 `/metrics` tracks progress toward MVP

## Need More Help?

- Check CLAUDE.md for detailed guidelines
- Review ROADMAP.md for current P0 priorities
- Use `/status` to understand current state
- Run `/validate smart` to catch issues early

Type any command to get started!