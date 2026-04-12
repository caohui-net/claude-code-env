# Git Workflow

## Commit Message Format

```
<type>: <description>

<optional body>
```

Types: feat, fix, refactor, docs, test, chore, perf, ci

Note: Attribution disabled globally via ~/.claude/settings.json.

## Pull Request Workflow

When creating PRs:
1. Analyze full commit history (not just latest commit)
2. Use `git diff [base-branch]...HEAD` to see all changes
3. Draft comprehensive PR summary
4. Include test plan with TODOs
5. Push with `-u` flag if new branch

## Feature Implementation Workflow

1. **Plan First**
   - Use **planner** agent to create implementation plan
   - Identify dependencies and risks
   - Break down into phases

2. **TDD Approach**
   - Use **tdd-guide** agent
   - Write tests first (RED)
   - Implement to pass tests (GREEN)
   - Refactor (IMPROVE)
   - Verify 80%+ coverage

3. **Code Review**
   - Use **code-reviewer** agent immediately after writing code
   - Address CRITICAL and HIGH issues
   - Fix MEDIUM issues when possible

4. **Commit & Push**
   - Detailed commit messages
   - Follow conventional commits format

## Standard Completion Flow (MANDATORY, execute automatically without prompting)

After ANY code change, execute all steps in sequence without stopping:

1. **Check related files** - identify all files affected by the change (docs, README, configs)
2. **Verify** - read modified files to confirm correctness
3. **Update change records** - update PROJECT-SUMMARY.md or equivalent docs
4. **Update session-context** - update `.omc/session-context.json` with latest state
5. **Commit & push** - single commit including all related changes

Never prompt the user between these steps. Never skip step 3 or 4.
