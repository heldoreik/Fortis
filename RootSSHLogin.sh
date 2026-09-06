#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/Ui.sh"

if [[ "$RootSSHLogin" == "yes" ]]; then
    RootSSHLoginStatus="${RED}ON${NC}"

elif [[ "$RootSSHLogin" == "no" ]]; then
    RootSSHLoginStatus="${GREEN}OFF${NC}"

elif [[ "$RootSSHLogin" == "prohibit-password" ]]; then
    RootSSHLoginStatus="${YELLOW}ONLY-SSH-key${NC}"

else
    RootSSHLoginStatus="${YELLOW}UNKNOWN${NC}"
fi