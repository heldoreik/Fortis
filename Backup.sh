#!/bin/bash
source ./Ui.sh





if [[ ! -d "$BACKUP_DIR" ]]; then
    mkdir $BACKUP_DIR
fi

if [[ -f "$BACKUP_DIR/sshd_config" ]]; then
    backupexists=true
else
    backupexists=false
fi
