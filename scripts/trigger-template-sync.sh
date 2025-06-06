#!/bin/bash
# Trigger template sync across MCP repositories

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
DRY_RUN=false
TARGET_REPOS="all"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --repos)
      TARGET_REPOS="$2"
      shift 2
      ;;
    --help)
      echo "Usage: $0 [options]"
      echo ""
      echo "Options:"
      echo "  --dry-run          Run in dry-run mode (no changes made)"
      echo "  --repos <list>     Comma-separated list of repos or 'all' (default: all)"
      echo "  --help             Show this help message"
      echo ""
      echo "Examples:"
      echo "  $0                                    # Sync all repos"
      echo "  $0 --dry-run                         # Dry run for all repos"
      echo "  $0 --repos mcp-wayback-machine       # Sync specific repo"
      echo "  $0 --repos mcp-mcp,mcp-ollama       # Sync multiple repos"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

echo -e "${BLUE}=== Template Sync Dispatcher ===${NC}"
echo ""

# Check if we're in the template directory
if [ ! -f ".template-marker" ] || [ "$(basename $(pwd))" != "mcp-template" ]; then
  echo -e "${YELLOW}Warning: Not in mcp-template directory${NC}"
  echo "Attempting to find mcp-template..."
  
  # Try to find mcp-template
  if [ -d "../mcp-template" ]; then
    cd ../mcp-template
  elif [ -d "./mcp-template" ]; then
    cd ./mcp-template
  else
    echo "Error: Could not find mcp-template directory"
    exit 1
  fi
fi

echo -e "Working directory: ${GREEN}$(pwd)${NC}"
echo -e "Dry run: ${YELLOW}$DRY_RUN${NC}"
echo -e "Target repos: ${YELLOW}$TARGET_REPOS${NC}"
echo ""

# Trigger the workflow
echo -e "${BLUE}Triggering template sync workflow...${NC}"

if [ "$TARGET_REPOS" = "all" ]; then
  gh workflow run template-sync-dispatch.yml \
    -f dry_run="$DRY_RUN"
else
  gh workflow run template-sync-dispatch.yml \
    -f target_repos="$TARGET_REPOS" \
    -f dry_run="$DRY_RUN"
fi

echo -e "${GREEN}✓ Workflow triggered${NC}"
echo ""

# Wait a moment for the workflow to start
sleep 3

# Get the latest run
RUN_ID=$(gh run list --workflow template-sync-dispatch.yml --limit 1 --json databaseId --jq '.[0].databaseId')

if [ -n "$RUN_ID" ]; then
  echo -e "${BLUE}Workflow run started: #$RUN_ID${NC}"
  echo ""
  echo "You can:"
  echo "  - Watch progress: gh run watch $RUN_ID"
  echo "  - View in browser: gh run view $RUN_ID --web"
  echo "  - Check logs: gh run view $RUN_ID --log"
else
  echo -e "${YELLOW}Could not get workflow run ID${NC}"
fi