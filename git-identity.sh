#!/bin/bash
# git-identity.sh — switch local git identity quickly
# Usage:
#   git-identity local    → set repo-local config to a2
#   git-identity global   → reset repo-local config, fall back to global (a1)
#   git-identity status   → show current effective identity for this repo
#   git-identity          → show usage

U1_EMAIL="EMAIL@PERSONAL.com"
U1_NAME="ME PERSONAL"

U2_EMAIL="EMAIL@WORK.COM"
U2_NAME="ME WORK"

# ── Hacker-theme color palette ────────────────────────────────────────────────
# Using standard 8-color ANSI codes so terminals adapt them for light/dark mode
RESET="\033[0m"
BOLD="\033[1m"
DIM="\033[2m"

GREEN="\033[32m"
CYAN="\033[36m"
YELLOW="\033[33m"
RED="\033[31m"
MAGENTA="\033[35m"
GRAY="\033[2m"
WHITE="\033[0m"

# ── Logging helpers ───────────────────────────────────────────────────────────
log_ok()    { echo -e "${GREEN}${BOLD}  [✔] ${WHITE}$*${RESET}"; }
log_info()  { echo -e "${CYAN}${BOLD}  [~] ${WHITE}$*${RESET}"; }
log_warn()  { echo -e "${YELLOW}${BOLD}  [!] ${WHITE}$*${RESET}"; }
log_err()   { echo -e "${RED}${BOLD}  [✘] ${WHITE}$*${RESET}"; }
log_dim()   { echo -e "${GRAY}${DIM}      $*${RESET}"; }
log_sep()   { echo -e "${MAGENTA}${BOLD}  ──────────────────────────────────────${RESET}"; }
log_label() { echo -e "${MAGENTA}${BOLD}  $1 ${CYAN}$2${RESET}"; }

# Banner printed on every invocation
_banner() {
  echo -e ""
  echo -e "${GREEN}${BOLD}  ░██████╗░██╗████████╗    ██╗██████╗ ${RESET}"
  echo -e "${GREEN}${BOLD}  ██╔════╝░██║╚══██╔══╝    ██║██╔══██╗${RESET}"
  echo -e "${GREEN}${BOLD}  ██║░░██╗░██║░░░██║░░░    ██║██║░░██║${RESET}"
  echo -e "${GREEN}${BOLD}  ██║░░╚██╗██║░░░██║░░░    ██║██║░░██║${RESET}"
  echo -e "${GREEN}${BOLD}  ╚██████╔╝██║░░░██║░░░    ██║██████╔╝${RESET}"
  echo -e "${GREEN}${BOLD}  ░╚═════╝░╚═╝░░░╚═╝░░░    ╚═╝╚═════╝ ${GRAY}identity manager${RESET}"
  echo -e "${MAGENTA}${BOLD} built by @ali1raz ${RESET}"
  echo -e ""
}

_check_deps() {
  # Ensure git is installed before doing anything
  if ! command -v git &>/dev/null; then
    log_err "git is not installed. Install it from https://git-scm.com"
    exit 1
  fi

  # Ensure the user has filled in their identities — catch unconfigured placeholders
  local unconfigured=0
  for var in U1_NAME U1_EMAIL U2_NAME U2_EMAIL; do
    local val="${!var}"
    if [[ -z "$val" || "$val" == *"your"* || "$val" == *"example.com"* ]]; then
      log_err "$var is not configured. Open the script and set your identities."
      unconfigured=1
    fi
  done
  [[ $unconfigured -eq 1 ]] && exit 1
}

_check_git_repo() {
  if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    log_err "Not inside a git repository."
    exit 1
  fi
}

# Show repo context (branch) after the banner — non-fatal, just informational
_repo_context() {
  if git rev-parse --is-inside-work-tree &>/dev/null; then
    local branch
    branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null || echo "detached")
    local repo_root
    repo_root=$(basename "$(git rev-parse --show-toplevel 2>/dev/null)")
    log_info "repo  ${GRAY}${repo_root}${RESET}${CYAN}${BOLD}  branch  ${GREEN}${branch}${RESET}"
  else
    log_warn "Not inside a git repository"
  fi
  echo ""
}

_banner
_check_deps
_repo_context

case "$1" in
  local)
    _check_git_repo
    log_info "Injecting local identity override..."
    git config --local user.email "$U2_EMAIL"
    git config --local user.name  "$U2_NAME"
    log_sep
    log_ok  "Local identity set"
    log_dim "name   → $U2_NAME"
    log_dim "email  → $U2_EMAIL"
    log_sep
    ;;

  global)
    _check_git_repo
    log_info "Purging local identity overrides..."
    # Remove local overrides so the global config takes over
    git config --local --unset user.email 2>/dev/null || true
    git config --local --unset user.name  2>/dev/null || true
    log_sep
    log_ok  "Fallback to global identity"
    log_dim "name   → $U1_NAME"
    log_dim "email  → $U1_EMAIL"
    log_sep
    ;;

  status)
    _check_git_repo
    EMAIL=$(git config user.email)
    NAME=$(git config user.name)
    LOCAL_EMAIL=$(git config --local user.email 2>/dev/null || echo "(none)")
    LOCAL_NAME=$(git config --local user.name  2>/dev/null || echo "(none)")
    log_sep
    log_label "  effective" "→  $NAME <$EMAIL>"
    log_label "  local    " "→  $LOCAL_NAME <$LOCAL_EMAIL>"
    log_label "  global   " "→  $U1_NAME <$U1_EMAIL>"
    log_sep
    ;;

  "") # No argument — show full docs
    echo -e "${BOLD}${CYAN}  COMMANDS${RESET}"
    echo ""
    echo -e "  ${GREEN}${BOLD}local${RESET}   ${DIM}→${RESET}  switch this repo to alt identity"
    log_dim "         name   : ${U2_NAME}"
    log_dim "         email  : ${U2_EMAIL}"
    echo ""
    echo -e "  ${GREEN}${BOLD}global${RESET}  ${DIM}→${RESET}  clear local override, fall back to global"
    log_dim "         name   : ${U1_NAME}"
    log_dim "         email  : ${U1_EMAIL}"
    echo ""
    echo -e "  ${GREEN}${BOLD}status${RESET}  ${DIM}→${RESET}  show effective / local / global identity"
    echo ""
    log_sep
    echo -e "  ${DIM}example:  git-identity local${RESET}"
    echo ""
    ;;

  *) # Unknown argument — short error
    log_err "Unknown command: '$1'"
    log_dim "valid options: local | global | status"
    echo ""
    ;;
esac
