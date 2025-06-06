#!/bin/bash
# Merge template sync PRs that are ready

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
AUTO_MODE=false
DRY_RUN=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --auto)
      AUTO_MODE=true
      shift
      ;;
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --help)
      echo "Usage: $0 [options]"
      echo ""
      echo "Options:"
      echo "  --auto     Enable auto-merge for PRs instead of merging immediately"
      echo "  --dry-run  Show what would be done without making changes"
      echo "  --help     Show this help message"
      echo ""
      echo "Examples:"
      echo "  $0                  # Merge ready PRs immediately"
      echo "  $0 --auto          # Enable auto-merge on PRs"
      echo "  $0 --dry-run       # Show what would be merged"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# MCP repositories
REPOS=(
  "mcp-wayback-machine"
  "mcp-openalex"
  "mcp-mcp"  
  "mcp-ollama"
)

echo -e "${BLUE}=== Template Sync PR Merger ===${NC}"
echo -e "Mode: ${YELLOW}$([ "$AUTO_MODE" = true ] && echo "Auto-merge" || echo "Immediate merge")${NC}"
echo -e "Dry run: ${YELLOW}$DRY_RUN${NC}"
echo ""

MERGED_COUNT=0
SKIPPED_COUNT=0
ERROR_COUNT=0

# Function to process PRs in a repo
process_repo_prs() {
  local repo=$1
  echo -e "${YELLOW}Processing: $repo${NC}"
  
  # Get template-related PRs
  local prs=$(gh pr list --repo "Mearman/$repo" --state open --json number,title,mergeable,statusCheckRollup --jq '.[] | select(.title | test("template|sync"; "i"))' 2>/dev/null || echo "")
  
  if [ -z "$prs" ]; then
    echo -e "  ${GREEN}✓ No template sync PRs${NC}"
    return
  fi
  
  # Process each PR
  echo "$prs" | jq -r '@json' | while read -r pr_json; do
    local pr_num=$(echo "$pr_json" | jq -r '.number')
    local pr_title=$(echo "$pr_json" | jq -r '.title')
    local pr_mergeable=$(echo "$pr_json" | jq -r '.mergeable')
    local pr_checks=$(echo "$pr_json" | jq -r '.statusCheckRollup // empty')
    
    echo -e "  PR #$pr_num: $pr_title"
    
    # Check if mergeable
    if [ "$pr_mergeable" != "MERGEABLE" ]; then
      echo -e "    ${RED}✗ Not mergeable (status: $pr_mergeable)${NC}"
      ((SKIPPED_COUNT++))
      continue
    fi
    
    # Check CI status
    if [ -n "$pr_checks" ]; then
      local check_conclusion=$(echo "$pr_checks" | jq -r 'if type == "array" then .[0].conclusion else .conclusion end // "UNKNOWN"' 2>/dev/null || echo "UNKNOWN")
      if [ "$check_conclusion" != "SUCCESS" ] && [ "$check_conclusion" != "NEUTRAL" ]; then
        echo -e "    ${YELLOW}⚠ Checks not passed (status: $check_conclusion)${NC}"
        if [ "$AUTO_MODE" = true ]; then
          echo -e "    ${BLUE}→ Will enable auto-merge anyway${NC}"
        else
          ((SKIPPED_COUNT++))
          continue
        fi
      fi
    fi
    
    # Merge or enable auto-merge
    if [ "$DRY_RUN" = true ]; then
      if [ "$AUTO_MODE" = true ]; then
        echo -e "    ${BLUE}[DRY RUN] Would enable auto-merge${NC}"
      else
        echo -e "    ${BLUE}[DRY RUN] Would merge PR${NC}"
      fi
    else
      if [ "$AUTO_MODE" = true ]; then
        echo -e "    ${BLUE}→ Enabling auto-merge...${NC}"
        if gh pr merge "$pr_num" --repo "Mearman/$repo" --auto --squash --delete-branch 2>/dev/null; then
          echo -e "    ${GREEN}✓ Auto-merge enabled${NC}"
          ((MERGED_COUNT++))
        else
          echo -e "    ${RED}✗ Failed to enable auto-merge${NC}"
          ((ERROR_COUNT++))
        fi
      else
        echo -e "    ${BLUE}→ Merging PR...${NC}"
        if gh pr merge "$pr_num" --repo "Mearman/$repo" --squash --delete-branch 2>/dev/null; then
          echo -e "    ${GREEN}✓ Merged successfully${NC}"
          ((MERGED_COUNT++))
        else
          echo -e "    ${RED}✗ Failed to merge${NC}"
          ((ERROR_COUNT++))
        fi
      fi
    fi
  done
  
  echo ""
}

# Process each repository
for repo in "${REPOS[@]}"; do
  process_repo_prs "$repo"
done

# Summary
echo -e "${BLUE}=== Summary ===${NC}"
if [ "$DRY_RUN" = true ]; then
  echo -e "Dry run completed. No changes made."
else
  if [ "$AUTO_MODE" = true ]; then
    echo -e "Auto-merge enabled: ${GREEN}$MERGED_COUNT${NC}"
  else
    echo -e "PRs merged: ${GREEN}$MERGED_COUNT${NC}"
  fi
fi
echo -e "PRs skipped: ${YELLOW}$SKIPPED_COUNT${NC}"
echo -e "Errors: ${RED}$ERROR_COUNT${NC}"