# Global Claude Code Configuration

## Language
- Respond in the same language the user writes in
- Default to Chinese for this user

## Workflow Standards
- Always read files before editing
- Test code after making changes
- Commit changes with meaningful messages
- Update documentation when behavior changes

## Tool Conventions
- Use dedicated tools (Read, Edit, Glob, Grep) instead of Bash for file operations
- Use parallel tool calls when operations are independent
- Prefer Edit over Write for modifying existing files

## Git Workflow
- Commit frequently with descriptive messages
- Use conventional commits format: `type: description`
- Never force push to main/master without explicit confirmation
- **CRITICAL**: Every commit MUST be followed by push to remote
  - Step 1: `git add <files>`
  - Step 2: `git commit -m "message"`
  - Step 3: `git push` (immediately after commit)
  - Never skip the push step unless explicitly instructed

## Security
- Never hardcode secrets or tokens in code
- Use environment variables for sensitive values
- Review code for OWASP top 10 vulnerabilities

## Code Quality
- Keep solutions minimal and focused
- Avoid over-engineering
- Don't add features beyond what was asked

## Project Management
- Project docs directory: ~/projects/
- Each project maintains PRD/ directory with ExecutionPlan.md and CHANGELOG.md
- Config backup before modification: PRD/backup/ (format: filename.keyword.timestamp)

## System Operations
- sudo operations: Execute directly without password prompt
