# MCP Template Scripts

This directory contains utility scripts for managing MCP server repositories derived from the mcp-template.

## merge-template-updates.sh

This script helps merge updates from the mcp-template repository into derived MCP server repositories.

### Usage

From the root of your derived MCP repository (e.g., mcp-wayback-machine, mcp-openalex):

```bash
./scripts/merge-template-updates.sh
```

### What it does

1. **Validates environment**: Ensures you're in a git repository and not in the template itself
2. **Checks for clean state**: Prevents merge if you have uncommitted changes
3. **Adds template remote**: Adds mcp-template as a remote if not already present
4. **Creates merge branch**: Creates a new branch for the merge operation
5. **Excludes specific files**: Preserves repository-specific files like:
   - `package.json` (name, version, description, etc.)
   - `README.md` (repository-specific documentation)
   - `CHANGELOG.md` (repository-specific changelog)
   - Release workflows (repository-specific publishing config)
   - Tool implementations (repository-specific functionality)
6. **Performs merge**: Attempts to merge template updates
7. **Handles conflicts**: Provides guidance if conflicts occur

### Example workflow

```bash
# 1. Ensure you're on your main branch with a clean working directory
git checkout main
git status  # Should show "nothing to commit, working tree clean"

# 2. Run the merge script
./scripts/merge-template-updates.sh

# 3. Review the changes
git diff HEAD~1

# 4. Run tests to ensure everything works
npm test

# 5. Push the branch and create a PR
git push origin merge-template-YYYYMMDD-HHMMSS
# Then create a pull request on GitHub
```

### Handling conflicts

If conflicts occur, the script will:
1. List the conflicting files
2. Provide instructions for resolving them
3. Exit with instructions for completing the merge

To resolve conflicts:
1. Edit the conflicting files to resolve merge conflicts
2. Stage the resolved files: `git add <resolved-files>`
3. Complete the merge: `git commit`
4. Push the branch and create a PR

### Aborting a merge

If you want to abort the merge and return to your previous state:

```bash
git checkout main  # or your original branch
git branch -D merge-template-YYYYMMDD-HHMMSS
```