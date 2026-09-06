#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/Ui.sh"


if [[ -n "$SUDO_USERS" ]]; then
    Adminuser="${GREEN}ON${NC}"
else 
    Adminuser="${RED}OFF${NC}"
fi