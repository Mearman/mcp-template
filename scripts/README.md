# MCP Repository Management Scripts

This directory contains utility scripts for managing the MCP (Model Context Protocol) repositories.

## Available Scripts

### 🔍 `check-ci-status.sh`
Check the CI pipeline status across all MCP repositories.

```bash
./scripts/check-ci-status.sh
```

Shows:
- CI workflow status (pass/fail/in-progress)
- Template sync status
- Number of open PRs

### 🔄 `trigger-template-sync.sh`
Trigger template synchronization from mcp-template to downstream repositories.

```bash
# Sync all repositories
./scripts/trigger-template-sync.sh

# Dry run mode
./scripts/trigger-template-sync.sh --dry-run

# Sync specific repositories
./scripts/trigger-template-sync.sh --repos mcp-wayback-machine,mcp-openalex
```

Options:
- `--dry-run`: Preview changes without applying them
- `--repos <list>`: Comma-separated list of repos or 'all' (default: all)
- `--help`: Show help message

### 📋 `check-template-sync-prs.sh`
Check the status of template sync pull requests across repositories.

```bash
./scripts/check-template-sync-prs.sh
```

Shows:
- Open template sync PRs
- Mergeable status
- CI check status
- Auto-merge status

### 🔀 `merge-template-prs.sh`
Merge or enable auto-merge for template sync PRs.

```bash
# Merge ready PRs immediately
./scripts/merge-template-prs.sh

# Enable auto-merge on PRs
./scripts/merge-template-prs.sh --auto

# Preview what would be merged
./scripts/merge-template-prs.sh --dry-run
```

Options:
- `--auto`: Enable auto-merge instead of immediate merge
- `--dry-run`: Show what would be done without making changes
- `--help`: Show help message

### 🧪 `run-all-tests.sh`
Run tests across all MCP repositories.

```bash
# Run all tests
./scripts/run-all-tests.sh

# Run tests with coverage
./scripts/run-all-tests.sh --coverage

# Run tests in watch mode
./scripts/run-all-tests.sh --watch
```

Options:
- `--coverage`: Generate coverage reports
- `--watch`: Run in watch mode for development
- `--help`: Show help message

## Setup

Make scripts executable:
```bash
chmod +x scripts/*.sh
```

## Requirements

- GitHub CLI (`gh`) installed and authenticated
- `jq` for JSON parsing
- Node.js and Yarn installed
- Write access to MCP repositories

## Workflow Examples

### Complete Template Sync Workflow
```bash
# 1. Check current CI status
./scripts/check-ci-status.sh

# 2. Trigger template sync
./scripts/trigger-template-sync.sh

# 3. Check for created PRs
./scripts/check-template-sync-prs.sh

# 4. Enable auto-merge on PRs
./scripts/merge-template-prs.sh --auto
```

### Testing Workflow
```bash
# 1. Run all tests with coverage
./scripts/run-all-tests.sh --coverage

# 2. Check CI status
./scripts/check-ci-status.sh
```

## Notes

- Scripts assume you're running from the parent `mcp` directory
- The `trigger-template-sync.sh` script will auto-detect if you're not in mcp-template
- All scripts support colored output for better readability
- Exit codes: 0 for success, 1 for failure