#!/bin/bash

: "${FORTIS_ROOT:=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
source "$FORTIS_ROOT/lib/ui.sh"


sshkeyusers=$(for f in /home/*/.ssh/authorized_keys; do
    [[ -s "$f" ]] && echo "$f"
done | cut -d/ -f3 | paste -sd, -)

if [[ -n "$sshkeyusers" ]]; then
    sshkeystatus="${GREEN}$sshkeyusers${NC}"
else 
    sshkeystatus="${RED}OFF${NC}"
fi
