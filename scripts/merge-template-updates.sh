#!/bin/bash
set -e

# Script to merge updates from mcp-template into derived MCP servers
# Usage: ./scripts/merge-template-updates.sh

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "MCP Template Update Merger"
echo "========================="
echo ""

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}Error: Not in a git repository${NC}"
    exit 1
fi

# Get current repository name
REPO_NAME=$(basename -s .git `git config --get remote.origin.url`)
echo -e "Current repository: ${GREEN}$REPO_NAME${NC}"

# Check if this is the template repository
if [ "$REPO_NAME" = "mcp-template" ]; then
    echo -e "${RED}Error: This script should be run from a derived MCP repository, not the template itself${NC}"
    exit 1
fi

# Check for uncommitted changes
if ! git diff-index --quiet HEAD --; then
    echo -e "${RED}Error: You have uncommitted changes. Please commit or stash them first.${NC}"
    exit 1
fi

# Get current branch
CURRENT_BRANCH=$(git branch --show-current)
echo -e "Current branch: ${GREEN}$CURRENT_BRANCH${NC}"

# Add template remote if it doesn't exist
if ! git remote | grep -q '^mcp-template$'; then
    echo -e "${YELLOW}Adding mcp-template remote...${NC}"
    git remote add mcp-template https://github.com/Mearman/mcp-template.git
fi

# Fetch latest from template
echo -e "${YELLOW}Fetching latest from mcp-template...${NC}"
git fetch mcp-template main

# Create a new branch for the merge
MERGE_BRANCH="merge-template-$(date +%Y%m%d-%H%M%S)"
echo -e "${YELLOW}Creating merge branch: $MERGE_BRANCH${NC}"
git checkout -b "$MERGE_BRANCH"

# Files to exclude from merge (repository-specific files)
EXCLUDE_FILES=(
    "package.json"
    "README.md"
    "CHANGELOG.md"
    ".github/workflows/release.yml"
    ".github/workflows/semantic-release.yml"
    "src/tools/*"
    "src/index.ts"
    "src/cli.ts"
)

# Create .git/info/attributes for merge strategy
ATTRIBUTES_FILE=".git/info/attributes"
mkdir -p .git/info
> "$ATTRIBUTES_FILE"
for file in "${EXCLUDE_FILES[@]}"; do
    echo "$file merge=ours" >> "$ATTRIBUTES_FILE"
done

# Define merge driver
git config merge.ours.driver true

# Attempt to merge
echo -e "${YELLOW}Attempting to merge mcp-template/main...${NC}"
if git merge mcp-template/main --allow-unrelated-histories -m "merge: template updates from mcp-template/main"; then
    echo -e "${GREEN}Merge completed successfully!${NC}"
else
    echo -e "${YELLOW}Merge conflicts detected. Please resolve them manually.${NC}"
    echo ""
    echo "Conflicts in the following files:"
    git diff --name-only --diff-filter=U
    echo ""
    echo "After resolving conflicts:"
    echo "  1. Stage resolved files: git add <files>"
    echo "  2. Complete the merge: git commit"
    echo "  3. Push the branch: git push origin $MERGE_BRANCH"
    echo "  4. Create a pull request"
    exit 1
fi

# Check what changed
echo ""
echo -e "${GREEN}Files changed in this merge:${NC}"
git diff --name-only HEAD~1

# Instructions for next steps
echo ""
echo -e "${GREEN}Merge successful!${NC}"
echo ""
echo "Next steps:"
echo "  1. Review the changes: git diff HEAD~1"
echo "  2. Run tests: npm test"
echo "  3. Push the branch: git push origin $MERGE_BRANCH"
echo "  4. Create a pull request to merge into $CURRENT_BRANCH"
echo ""
echo "To abort this merge and return to $CURRENT_BRANCH:"
echo "  git checkout $CURRENT_BRANCH"
echo "  git branch -D $MERGE_BRANCH"