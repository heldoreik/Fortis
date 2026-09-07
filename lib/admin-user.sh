#!/bin/bash
: "${FORTIS_ROOT:=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
source "$FORTIS_ROOT/lib/ui.sh"


if [[ -n "$SUDO_USERS" ]]; then
    Adminuser="${GREEN}ON${NC}"
else 
    Adminuser="${RED}OFF${NC}"
fi