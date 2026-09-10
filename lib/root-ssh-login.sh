#!/bin/bash
: "${FORTIS_ROOT:=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
source "$FORTIS_ROOT/lib/ui.sh"

case "${RootSSHLogin,,}" in
    yes)                              
        RootSSHLoginStatus="${RED}ON${NC}" ;;
    no)                               
        RootSSHLoginStatus="${GREEN}OFF${NC}" ;;
    prohibit-password|without-password) 
        RootSSHLoginStatus="${YELLOW}ONLY-SSH-key${NC}" ;;
    forced-commands-only)             
        RootSSHLoginStatus="${YELLOW}FORCED-CMD${NC}" ;;
    *)                                
        RootSSHLoginStatus="${YELLOW}UNKNOWN${NC}" ;;
esac