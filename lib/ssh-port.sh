#!/bin/bash
: "${FORTIS_ROOT:=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
source "$FORTIS_ROOT/lib/ui.sh"

if [[ "$SSHPort" == "22" ]]; then
    SSHPortStatus="${RED}$SSHPort${NC}"
else 
    SSHPortStatus="${GREEN}$SSHPort${NC}"
fi