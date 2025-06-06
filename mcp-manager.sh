#!/bin/bash
# MCP Repository Manager - Interactive Menu

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to display the menu
show_menu() {
  clear
  echo -e "${CYAN}╔═══════════════════════════════════════════╗${NC}"
  echo -e "${CYAN}║       MCP Repository Manager v1.0         ║${NC}"
  echo -e "${CYAN}╚═══════════════════════════════════════════╝${NC}"
  echo ""
  echo -e "${BLUE}Pipeline Management:${NC}"
  echo "  1) Check CI status across all repos"
  echo "  2) Trigger template sync"
  echo "  3) Check template sync PRs"
  echo "  4) Merge template sync PRs"
  echo ""
  echo -e "${BLUE}Testing:${NC}"
  echo "  5) Run all tests"
  echo "  6) Run tests with coverage"
  echo ""
  echo -e "${BLUE}Quick Actions:${NC}"
  echo "  7) View recent workflow runs"
  echo "  8) Open GitHub Actions in browser"
  echo ""
  echo "  q) Quit"
  echo ""
  echo -e "${YELLOW}Select an option:${NC} "
}

# Function to pause and wait for user
pause() {
  echo ""
  echo -e "${YELLOW}Press Enter to continue...${NC}"
  read -r
}

# Function to view recent runs
view_recent_runs() {
  echo -e "${BLUE}=== Recent Workflow Runs ===${NC}"
  echo ""
  
  local repos=("mcp-template" "mcp-wayback-machine" "mcp-openalex" "mcp-mcp" "mcp-ollama")
  
  for repo in "${repos[@]}"; do
    echo -e "${YELLOW}$repo:${NC}"
    gh run list --repo "Mearman/$repo" --limit 3 || echo "  No runs found"
    echo ""
  done
}

# Function to open GitHub Actions
open_github_actions() {
  echo -e "${BLUE}Opening GitHub Actions pages...${NC}"
  
  local repos=("mcp-template" "mcp-wayback-machine" "mcp-openalex" "mcp-mcp" "mcp-ollama")
  
  for repo in "${repos[@]}"; do
    echo "Opening $repo..."
    gh browse --repo "Mearman/$repo" actions
    sleep 1
  done
}

# Main menu loop
while true; do
  show_menu
  read -r choice
  
  case $choice in
    1)
      ./scripts/check-ci-status.sh
      pause
      ;;
    2)
      echo -e "${BLUE}Template Sync Options:${NC}"
      echo "1) Sync all repositories"
      echo "2) Sync specific repositories"
      echo "3) Dry run (preview changes)"
      echo -e "${YELLOW}Select:${NC} "
      read -r sync_choice
      
      case $sync_choice in
        1)
          ./scripts/trigger-template-sync.sh
          ;;
        2)
          echo -e "${YELLOW}Enter repository names (comma-separated):${NC}"
          echo "Example: mcp-wayback-machine,mcp-openalex"
          read -r repos
          ./scripts/trigger-template-sync.sh --repos "$repos"
          ;;
        3)
          ./scripts/trigger-template-sync.sh --dry-run
          ;;
        *)
          echo -e "${RED}Invalid option${NC}"
          ;;
      esac
      pause
      ;;
    3)
      ./scripts/check-template-sync-prs.sh
      pause
      ;;
    4)
      echo -e "${BLUE}Merge Options:${NC}"
      echo "1) Merge immediately"
      echo "2) Enable auto-merge"
      echo "3) Dry run (preview)"
      echo -e "${YELLOW}Select:${NC} "
      read -r merge_choice
      
      case $merge_choice in
        1)
          ./scripts/merge-template-prs.sh
          ;;
        2)
          ./scripts/merge-template-prs.sh --auto
          ;;
        3)
          ./scripts/merge-template-prs.sh --dry-run
          ;;
        *)
          echo -e "${RED}Invalid option${NC}"
          ;;
      esac
      pause
      ;;
    5)
      ./scripts/run-all-tests.sh
      pause
      ;;
    6)
      ./scripts/run-all-tests.sh --coverage
      pause
      ;;
    7)
      view_recent_runs
      pause
      ;;
    8)
      open_github_actions
      pause
      ;;
    q|Q)
      echo -e "${GREEN}Goodbye!${NC}"
      exit 0
      ;;
    *)
      echo -e "${RED}Invalid option. Please try again.${NC}"
      sleep 2
      ;;
  esac
done