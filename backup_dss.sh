#!/bin/sh

# @version $Id: backup_dss.sh 8 2017-06-26 10:07:43Z fixer $
# @date $Date: 2017-06-26 20:07:43 +1000 (Pn, 26 cze 2017) $
# @revision $Revision: 8 $
# @author $Author: fixer $
# @headurl $HeadURL: svn://.../repo_backup/backup_dss.sh $

echo "[$(date +'%d-%m-%Y %H:%M:%S')] DSM exporting settings to a temporary *.dss file: ${BACKUP_DIR}/dsm_config_${TIMESTAMP}.dss" >> "$LOG_FILE" 
TIMESTAMP=$(date +'%Y-%m-%d_%H-%M-%S')

/usr/syno/bin/synoconfbkp export --filepath="${BACKUP_DIR}/dsm_config_${TIMESTAMP}.dss"
sleep 2
#chmod 777 "${BACKUP_DIR}/dsm_config_${TIMESTAMP}.dss"

echo "[$(date +'%d-%m-%Y %H:%M:%S')] Compressing config file to: ${BACKUP_DIR}/backup_dsm_config_${TIMESTAMP}.7z" >> "$LOG_FILE" 

/usr/syno/bin/7z a "${BACKUP_DIR}/backup_dsm_config_${TIMESTAMP}.7z" "${BACKUP_DIR}/dsm_config_${TIMESTAMP}.dss" -t7z -m0=lzma2 -ms=off -mmt=off -mfb=64 -md=32m -mhe -mx9 -p"${PASSWORD}" >> "$LOG_FILE2"

if [ "$TESTS_ARCHIVE_FILES" = true ] ; then
  echo "[$(date +'%d-%m-%Y %H:%M:%S')] Verifying files in the archive: ${BACKUP_DIR}/backup_dsm_config_${TIMESTAMP}.7z" >> "$LOG_FILE2"
  /usr/syno/bin/7z t -t7z "${BACKUP_DIR}/backup_dsm_config_${TIMESTAMP}.7z" -p"${PASSWORD}" >> "$LOG_FILE2"
  echo "[$(date +'%d-%m-%Y %H:%M:%S')] Verifying files completed" >> "$LOG_FILE2"
  echo " " >> "$LOG_FILE2"
fi

echo "[$(date +'%d-%m-%Y %H:%M:%S')] Removing DSM temporary config file: ${BACKUP_DIR}/dsm_config_${TIMESTAMP}.dss" >> "$LOG_FILE"
if [ -f "${BACKUP_DIR}/dsm_config_${TIMESTAMP}.dss" ]; then
  rm -rf "${BACKUP_DIR}/dsm_config_${TIMESTAMP}.dss" #uwaga: tutaj trwale usuwamy plik wraz z jego zawartością (i wcale nie trafi on do #recycle)
  echo "[$(date +'%d-%m-%Y %H:%M:%S')] Removed" >> "$LOG_FILE"
fi

echo " DSM exporting settings FINISH! " >> "$LOG_FILE"
echo " " >> "$LOG_FILE"