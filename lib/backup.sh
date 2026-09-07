#!/bin/bash
: "${FORTIS_ROOT:=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
source "$FORTIS_ROOT/lib/ui.sh"

if [[ ! -d "$BACKUP_DIR" ]]; then
    mkdir "$BACKUP_DIR"
fi

if [[ -f "$BACKUP_DIR/sshd_config" ]]; then
    backupexists=true
else
    backupexists=false
fi
