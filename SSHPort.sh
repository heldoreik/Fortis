#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/Ui.sh"


if [[ "$SSHPort" == "22" ]]; then
    SSHPortStatus="${RED}$SSHPort${NC}"
else 
    SSHPortStatus="${GREEN}$SSHPort${NC}"
fi