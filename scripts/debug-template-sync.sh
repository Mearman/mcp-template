#!/bin/bash
# Debug template sync issues across MCP repositories

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Repository to debug (can be passed as argument)
REPO=${1:-""}

if [ -z "$REPO" ]; then
  echo "Usage: $0 <repository-name>"
  echo ""
  echo "Available repositories:"
  echo "  - mcp-wayback-machine"
  echo "  - mcp-openalex"
  echo "  - mcp-mcp"
  echo "  - mcp-ollama"
  exit 1
fi

echo -e "${BLUE}=== Debugging Template Sync for $REPO ===${NC}"
echo ""

# Check if repository exists
if ! gh api "repos/Mearman/$REPO" >/dev/null 2>&1; then
  echo -e "${RED}✗ Repository not found: Mearman/$REPO${NC}"
  exit 1
fi

# 1. Check template marker
echo -e "${YELLOW}1. Checking template marker...${NC}"
if gh api "repos/Mearman/$REPO/contents/.template-marker" >/dev/null 2>&1; then
  echo -e "  ${GREEN}✓ Template marker exists${NC}"
else
  echo -e "  ${RED}✗ Template marker missing${NC}"
  echo "  Fix: Add .template-marker file to repository"
fi

# 2. Check workflows
echo ""
echo -e "${YELLOW}2. Checking workflows...${NC}"

# Check template-sync-handler
if gh api "repos/Mearman/$REPO/contents/.github/workflows/template-sync-handler.yml" >/dev/null 2>&1; then
  echo -e "  ${GREEN}✓ template-sync-handler.yml exists${NC}"
  
  # Check if workflow is active
  local workflow_state=$(gh api "repos/Mearman/$REPO/actions/workflows" --jq '.workflows[] | select(.path == ".github/workflows/template-sync-handler.yml") | .state' 2>/dev/null || echo "unknown")
  if [ "$workflow_state" = "active" ]; then
    echo -e "  ${GREEN}✓ Workflow is active${NC}"
  else
    echo -e "  ${RED}✗ Workflow state: $workflow_state${NC}"
  fi
else
  echo -e "  ${RED}✗ template-sync-handler.yml missing${NC}"
  echo "  Fix: Copy from mcp-template/.github/workflows/"
fi

# 3. Check recent workflow runs
echo ""
echo -e "${YELLOW}3. Recent template sync runs...${NC}"
local sync_runs=$(gh run list --repo "Mearman/$REPO" --workflow template-sync-handler.yml --limit 5 --json status,conclusion,createdAt,event 2>/dev/null || echo "[]")

if [ "$sync_runs" = "[]" ]; then
  echo -e "  ${YELLOW}⚠ No template sync runs found${NC}"
else
  echo "$sync_runs" | jq -r '.[] | "  \(.createdAt | split("T")[0]) \(.event) -> \(.conclusion // .status)"'
fi

# 4. Check for failed runs
echo ""
echo -e "${YELLOW}4. Checking for failed runs...${NC}"
local failed_runs=$(echo "$sync_runs" | jq -r '.[] | select(.conclusion == "failure") | .databaseId' | head -1)

if [ -n "$failed_runs" ]; then
  echo -e "  ${RED}✗ Found failed run: #$failed_runs${NC}"
  echo "  View logs: gh run view $failed_runs --repo Mearman/$REPO --log"
  
  # Try to get error from logs
  echo ""
  echo -e "  ${YELLOW}Attempting to extract error...${NC}"
  gh run view "$failed_runs" --repo "Mearman/$REPO" --log 2>/dev/null | grep -i "error\|failed\|fatal" | head -5 || echo "  Could not extract error"
else
  echo -e "  ${GREEN}✓ No recent failures${NC}"
fi

# 5. Test repository dispatch
echo ""
echo -e "${YELLOW}5. Testing repository dispatch...${NC}"
echo -e "  ${BLUE}→ Sending test dispatch event...${NC}"

if gh api "repos/Mearman/$REPO/dispatches" \
  -f event_type=template-sync \
  -f 'client_payload[test]=true' \
  -f 'client_payload[dry_run]=true' 2>/dev/null; then
  echo -e "  ${GREEN}✓ Dispatch sent successfully${NC}"
  
  # Wait and check if it triggered
  echo -e "  ${BLUE}→ Waiting for workflow to start...${NC}"
  sleep 5
  
  local new_run=$(gh run list --repo "Mearman/$REPO" --limit 1 --json event,createdAt --jq 'select(.[0].event == "repository_dispatch") | .[0].createdAt' 2>/dev/null || echo "")
  
  if [ -n "$new_run" ]; then
    echo -e "  ${GREEN}✓ Workflow triggered successfully${NC}"
  else
    echo -e "  ${RED}✗ Workflow did not trigger${NC}"
    echo "  Possible issues:"
    echo "    - Workflow file syntax error"
    echo "    - Workflow disabled"
    echo "    - Permissions issue"
  fi
else
  echo -e "  ${RED}✗ Failed to send dispatch${NC}"
fi

# 6. Check permissions
echo ""
echo -e "${YELLOW}6. Checking permissions...${NC}"
local perms=$(gh api "repos/Mearman/$REPO" --jq '.permissions' 2>/dev/null || echo "{}")
echo "  Repository permissions:"
echo "$perms" | jq -r 'to_entries[] | "    \(.key): \(.value)"'

# Summary
echo ""
echo -e "${BLUE}=== Summary ===${NC}"
echo "To manually trigger sync:"
echo "  gh workflow run template-sync-handler.yml --repo Mearman/$REPO"
echo ""
echo "To view workflow file:"
echo "  gh api repos/Mearman/$REPO/contents/.github/workflows/template-sync-handler.yml --jq '.content' | base64 -d"