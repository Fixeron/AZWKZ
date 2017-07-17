#!/bin/sh

# @version $Id: backup_upload_logs.sh 8 2017-06-26 10:07:43Z fixer $
# @date $Date: 2017-06-26 20:07:43 +1000 (Pn, 26 cze 2017) $
# @revision $Revision: 8 $
# @author $Author: fixer $
# @headurl $HeadURL: svn://.../repo_backup/backup_upload_logs.sh $

if [ "$SEND_TO_FTP" = true ]; then
  echo "======================" >> "$LOG_FILE"
  echo "14. Compressing and sending all log files" >> "$LOG_FILE"
  echo $(date +'%d-%m-%Y %H:%M:%S') >> "$LOG_FILE"
  echo "======================" >> "$LOG_FILE"
  # pakujemy logi *.log
  echo "[$(date +'%d-%m-%Y %H:%M:%S')] Compressing all log files..." >> "$LOG_FILE"
  TIMESTAMP=$(date +'%Y-%m-%d_%H-%M-%S')
  /usr/syno/bin/7z a "logs_${TIMESTAMP_START}--${TIMESTAMP}.7z" "${BACKUP_DIR}/*.log" -t7z -ms=off -mmt=off -mfb=64 -md=32m -mhe -mx9 -p"${PASSWORD}"

  if [ "$TESTS_ARCHIVE_FILES" = true ]; then
    echo "[$(date +'%d-%m-%Y %H:%M:%S')] Verifying files in the archive: logs_${TIMESTAMP_START}--${TIMESTAMP}.7z" >> "$LOG_FILE2"
    /usr/syno/bin/7z t -t7z "logs_${TIMESTAMP_START}--${TIMESTAMP}.7z" -p"${PASSWORD}" >> "$LOG_FILE2"
  fi
  #brak komunikatu zwrotnego w logach!
  echo "[$(date +'%d-%m-%Y %H:%M:%S')] Sending compressed log files to FTP: ${FTP_HOST}" >> "$LOG_FILE"
  /usr/bin/ncftp/ncftpput -v -m -u "${FTP_USER}" -p "${FTP_PASS}" -P "${FTP_PORT}" "${FTP_HOST}" "/backup" "logs_${TIMESTAMP_START}--${TIMESTAMP}.7z"
fi