#!/bin/bash
# Check for template sync PRs across MCP repositories

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# MCP repositories
REPOS=(
  "mcp-wayback-machine"
  "mcp-openalex"
  "mcp-mcp"
  "mcp-ollama"
)

echo -e "${BLUE}=== Template Sync PRs Status ===${NC}"
echo ""

TOTAL_PRS=0
MERGEABLE_PRS=0

# Function to check PRs in a repo
check_repo_prs() {
  local repo=$1
  echo -e "${YELLOW}Repository: $repo${NC}"
  
  # Get template-related PRs
  local prs=$(gh pr list --repo "Mearman/$repo" --state open --json number,title,headRefName,mergeable,statusCheckRollup,autoMergeRequest 2>/dev/null || echo "[]")
  
  local template_prs=$(echo "$prs" | jq -r '.[] | select(.title | test("template|sync"; "i"))')
  
  if [ -z "$template_prs" ]; then
    echo -e "  ${GREEN}✓ No template sync PRs${NC}"
  else
    # Process each PR
    echo "$template_prs" | jq -r '@json' | while read -r pr_json; do
      local pr_num=$(echo "$pr_json" | jq -r '.number')
      local pr_title=$(echo "$pr_json" | jq -r '.title')
      local pr_branch=$(echo "$pr_json" | jq -r '.headRefName')
      local pr_mergeable=$(echo "$pr_json" | jq -r '.mergeable')
      local pr_checks=$(echo "$pr_json" | jq -r '.statusCheckRollup // empty')
      local auto_merge=$(echo "$pr_json" | jq -r '.autoMergeRequest // empty')
      
      echo -e "  ${PURPLE}PR #$pr_num:${NC} $pr_title"
      echo -e "    Branch: $pr_branch"
      
      # Check status
      if [ "$pr_mergeable" = "MERGEABLE" ]; then
        echo -e "    ${GREEN}✓ Mergeable${NC}"
        ((MERGEABLE_PRS++))
      elif [ "$pr_mergeable" = "CONFLICTING" ]; then
        echo -e "    ${RED}✗ Has conflicts${NC}"
      else
        echo -e "    ${YELLOW}⚠ Mergeable: $pr_mergeable${NC}"
      fi
      
      # Check CI status
      if [ -n "$pr_checks" ]; then
        local check_state=$(echo "$pr_checks" | jq -r 'if type == "array" then .[0].state else .state end // "UNKNOWN"' 2>/dev/null || echo "UNKNOWN")
        if [ "$check_state" = "SUCCESS" ]; then
          echo -e "    ${GREEN}✓ Checks passed${NC}"
        elif [ "$check_state" = "PENDING" ]; then
          echo -e "    ${YELLOW}⏳ Checks pending${NC}"
        else
          echo -e "    ${RED}✗ Checks: $check_state${NC}"
        fi
      fi
      
      # Check auto-merge
      if [ -n "$auto_merge" ]; then
        echo -e "    ${BLUE}🤖 Auto-merge enabled${NC}"
      fi
      
      ((TOTAL_PRS++))
    done
  fi
  
  echo ""
}

# Check each repository
for repo in "${REPOS[@]}"; do
  check_repo_prs "$repo"
done

# Summary
echo -e "${BLUE}=== Summary ===${NC}"
echo -e "Total template sync PRs: ${YELLOW}$TOTAL_PRS${NC}"
echo -e "Mergeable PRs: ${GREEN}$MERGEABLE_PRS${NC}"
echo ""

if [ $TOTAL_PRS -gt 0 ]; then
  echo "To merge all mergeable PRs, run:"
  echo "  ./scripts/merge-template-prs.sh"
  echo ""
  echo "To view a specific PR:"
  echo "  gh pr view <number> --repo Mearman/<repo>"
fi