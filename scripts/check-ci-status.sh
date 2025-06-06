#!/bin/bash
# Check CI status across all MCP repositories

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# MCP repositories
REPOS=(
  "mcp-template"
  "mcp-wayback-machine"
  "mcp-openalex"
  "mcp-mcp"
  "mcp-ollama"
)

echo -e "${BLUE}=== MCP Repositories CI Status ===${NC}"
echo ""

# Function to get workflow status
check_repo_ci() {
  local repo=$1
  echo -e "${YELLOW}Repository: $repo${NC}"
  
  # Get latest workflow runs
  local runs=$(gh run list --repo "Mearman/$repo" --limit 5 --json name,status,conclusion,event,createdAt 2>/dev/null || echo "[]")
  
  if [ "$runs" = "[]" ]; then
    echo -e "  ${RED}✗ No workflow runs found${NC}"
    return
  fi
  
  # Check CI status
  local ci_status=$(echo "$runs" | jq -r '.[] | select(.name == "CI") | "\(.conclusion // .status)"' | head -1)
  if [ -n "$ci_status" ]; then
    if [ "$ci_status" = "success" ]; then
      echo -e "  ${GREEN}✓ CI: $ci_status${NC}"
    elif [ "$ci_status" = "in_progress" ]; then
      echo -e "  ${YELLOW}⏳ CI: $ci_status${NC}"
    else
      echo -e "  ${RED}✗ CI: $ci_status${NC}"
    fi
  else
    echo -e "  ${YELLOW}⚠ CI: not found${NC}"
  fi
  
  # Check template sync status
  local sync_status=$(echo "$runs" | jq -r '.[] | select(.name | contains("Template Sync")) | "\(.conclusion // .status)"' | head -1)
  if [ -n "$sync_status" ]; then
    if [ "$sync_status" = "success" ]; then
      echo -e "  ${GREEN}✓ Template Sync: $sync_status${NC}"
    else
      echo -e "  ${RED}✗ Template Sync: $sync_status${NC}"
    fi
  fi
  
  # Check for active PRs
  local pr_count=$(gh pr list --repo "Mearman/$repo" --state open --json number --jq 'length' 2>/dev/null || echo "0")
  if [ "$pr_count" -gt 0 ]; then
    echo -e "  ${BLUE}ℹ Open PRs: $pr_count${NC}"
  fi
  
  echo ""
}

# Check each repository
for repo in "${REPOS[@]}"; do
  check_repo_ci "$repo"
done

# Summary
echo -e "${BLUE}=== Summary ===${NC}"
echo "Run 'gh workflow view' for detailed workflow information"
echo "Run './scripts/trigger-template-sync.sh' to sync templates"