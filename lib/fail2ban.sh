#!/bin/bash
: "${FORTIS_ROOT:=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
source "$FORTIS_ROOT/lib/ui.sh"

if command -v fail2ban-client &>/dev/null && systemctl is-active --quiet fail2ban; then
    fail2banstatus="${GREEN}ON${NC}"
else
    fail2banstatus="${RED}OFF${NC}"
fi