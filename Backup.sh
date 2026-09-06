#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/Ui.sh"





if [[ ! -d "$BACKUP_DIR" ]]; then
    mkdir "$BACKUP_DIR"
fi

if [[ -f "$BACKUP_DIR/sshd_config" ]]; then
    backupexists=true
else
    backupexists=false
fi
