#!/bin/bash
# Run tests across all MCP repositories

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

# Parse command line arguments
COVERAGE=false
WATCH=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --coverage)
      COVERAGE=true
      shift
      ;;
    --watch)
      WATCH=true
      shift
      ;;
    --help)
      echo "Usage: $0 [options]"
      echo ""
      echo "Options:"
      echo "  --coverage  Run tests with coverage report"
      echo "  --watch     Run tests in watch mode"
      echo "  --help      Show this help message"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

echo -e "${BLUE}=== Running Tests Across MCP Repositories ===${NC}"
echo ""

TOTAL_PASS=0
TOTAL_FAIL=0

# Function to run tests in a repo
run_repo_tests() {
  local repo=$1
  local repo_path="../$repo"
  
  echo -e "${YELLOW}Repository: $repo${NC}"
  
  if [ ! -d "$repo_path" ]; then
    echo -e "  ${RED}✗ Directory not found${NC}"
    ((TOTAL_FAIL++))
    return
  fi
  
  cd "$repo_path"
  
  # Check if tests exist
  if [ ! -f "package.json" ]; then
    echo -e "  ${RED}✗ No package.json found${NC}"
    ((TOTAL_FAIL++))
    cd - > /dev/null
    return
  fi
  
  # Check if test script exists
  if ! grep -q '"test"' package.json; then
    echo -e "  ${YELLOW}⚠ No test script found${NC}"
    cd - > /dev/null
    return
  fi
  
  # Run tests
  echo -e "  ${BLUE}→ Running tests...${NC}"
  
  if [ "$WATCH" = true ]; then
    echo -e "  ${YELLOW}Starting watch mode (press Ctrl+C to exit)${NC}"
    yarn test:watch
  elif [ "$COVERAGE" = true ]; then
    if yarn test --coverage 2>&1; then
      echo -e "  ${GREEN}✓ Tests passed with coverage${NC}"
      
      # Show coverage summary
      if [ -f "coverage/coverage-summary.json" ]; then
        local coverage=$(jq -r '.total.lines.pct' coverage/coverage-summary.json 2>/dev/null || echo "N/A")
        echo -e "  ${BLUE}Coverage: $coverage%${NC}"
      fi
      
      ((TOTAL_PASS++))
    else
      echo -e "  ${RED}✗ Tests failed${NC}"
      ((TOTAL_FAIL++))
    fi
  else
    if yarn test 2>&1 | tail -20; then
      echo -e "  ${GREEN}✓ Tests passed${NC}"
      ((TOTAL_PASS++))
    else
      echo -e "  ${RED}✗ Tests failed${NC}"
      ((TOTAL_FAIL++))
    fi
  fi
  
  cd - > /dev/null
  echo ""
}

# Save current directory
ORIGINAL_DIR=$(pwd)

# Run tests in each repository
for repo in "${REPOS[@]}"; do
  run_repo_tests "$repo"
done

# Return to original directory
cd "$ORIGINAL_DIR"

# Summary
echo -e "${BLUE}=== Summary ===${NC}"
echo -e "Passed: ${GREEN}$TOTAL_PASS${NC}"
echo -e "Failed: ${RED}$TOTAL_FAIL${NC}"

if [ $TOTAL_FAIL -gt 0 ]; then
  exit 1
fi