#!/bin/sh

# @version $Id: backup_remove_local.sh 8 2017-06-26 10:07:43Z fixer $
# @date $Date: 2017-06-26 20:07:43 +1000 (Pn, 26 cze 2017) $
# @revision $Revision: 8 $
# @author $Author: fixer $
# @headurl $HeadURL: svn://.../repo_backup/backup_remove_local.sh $

if [ "$DELETE_OLD_LOCAL_BACKUP" = true ] ; then
  echo "======================" >> "$LOG_FILE"
  echo "2. Removing old backup files from NAS: ${BACKUP_DIR}/" >> "$LOG_FILE"
  echo $(date +'%d-%m-%Y %H:%M:%S') >> "$LOG_FILE"
  echo "======================" >> "$LOG_FILE"

  LISTA1=$(/usr/bin/find "${BACKUP_DIR}/" -mindepth 1 -maxdepth 1 -name 'backup_*')
  LISTA2=$(/usr/bin/find "${BACKUP_DIR}/" -mindepth 1 -maxdepth 1 -name 'photo_*')
  echo "[$(date +'%d-%m-%Y %H:%M:%S')] Deleting from local NAS" >> "$LOG_FILE"
  echo $LISTA1 >> "$LOG_FILE"
  echo $LISTA2 >> "$LOG_FILE"
  /usr/bin/find "${BACKUP_DIR}/" -mindepth 1 -maxdepth 1 -name 'backup_*' -exec rm -f {} \; 2> /dev/null
  /usr/bin/find "${BACKUP_DIR}/" -mindepth 1 -maxdepth 1 -name 'photo_*' -exec rm -f {} \; 2> /dev/null
  # sprawdzanie wielkości pliku
  # echo `du -k "plik" | cut -f1` bytes
fi

echo " Removing old backup files from NAS ${BACKUP_DIR}/ FINISH! " >> "$LOG_FILE"
echo " " >> "$LOG_FILE"