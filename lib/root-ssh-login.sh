#!/bin/bash
: "${FORTIS_ROOT:=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
source "$FORTIS_ROOT/lib/ui.sh"

if [[ "$RootSSHLogin" == "yes" ]]; then
    RootSSHLoginStatus="${RED}ON${NC}"

elif [[ "$RootSSHLogin" == "no" ]]; then
    RootSSHLoginStatus="${GREEN}OFF${NC}"

elif [[ "$RootSSHLogin" == "prohibit-password" ]]; then
    RootSSHLoginStatus="${YELLOW}ONLY-SSH-key${NC}"

else
    RootSSHLoginStatus="${YELLOW}UNKNOWN${NC}"
fi