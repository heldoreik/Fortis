#!/bin/bash
: "${FORTIS_ROOT:=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
source "$FORTIS_ROOT/lib/ui.sh"

RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[1;33m'
CYAN=$'\033[0;36m'
WHITE=$'\033[1;37m'
BOLD=$'\033[1m'
NC=$'\033[0m'


if [[ "$PasswordAuth" == "yes" ]]; then
    PasswordAuthStatus="${RED}ON${NC}"
    PasswordAuthStatusturn="${GREEN}OFF${NC}"
else
    PasswordAuthStatus="${GREEN}OFF${NC}"
    PasswordAuthStatusturn="${RED}ON${NC}"
fi