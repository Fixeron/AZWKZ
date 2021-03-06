#!/bin/sh

# @version $Id: backup_download_ftp_2.sh 9 2017-06-27 02:39:41Z fixer $
# @date $Date: 2017-06-27 12:39:41 +1000 (Wt, 27 cze 2017) $
# @revision $Revision: 9 $
# @author $Author: fixer $
# @headurl $HeadURL: svn://.../repo_backup/backup_download_ftp_2.sh $

if [ "$USE_FTP_REMOTE2" = true ] ; then
  echo "======================" >> "$LOG_FILE"
  echo "10. Backup remote FTP services: ${REMOTE2_FTP_NAME} / ${REMOTE2_FTP_HOST}" >> "$LOG_FILE"
  echo $(date +'%d-%m-%Y %H:%M:%S') >> "$LOG_FILE"
  echo "======================" >> "$LOG_FILE"
  if [ "$USE_NCFTP" = true ] ; then
    /usr/bin/ncftp/ncftpget -u "${REMOTE2_FTP_USER}" -p "${REMOTE2_FTP_PASS}" -P "${REMOTE2_FTP_PORT}" -d -v -R "${REMOTE2_FTP_HOST}" "${BACKUP_DIR}/${REMOTE2_FTP_NAME}/" "${REMOTE2_FTP_DIR}" >> "$LOG_FILE2"
  else
    echo "UWAGA: Nie sciagnolem plikow z serwera FTP: ${REMOTE2_FTP_NAME} / ${REMOTE2_FTP_HOST}" >> "$LOG_FILE"
  fi

  # sciagamy bazę mysql/mariadb ze zdalnego serwera (pamiętaj aby dodać na serwerze (np. w cpanel'u) adres ip do póli adresów zaufanych)
  echo "======================" >> "$LOG_FILE"
  echo "11. Backup remote MySQL/MariaDB ${REMOTE2_DB_HOST}" >> "$LOG_FILE"
  echo $(date +'%d-%m-%Y %H:%M:%S') >> "$LOG_FILE"
  echo "======================" >> "$LOG_FILE"
  
  databases=`mysql --skip-column-names --host=${REMOTE2_DB_HOST} --port=${REMOTE2_DB_PORT} --user=${REMOTE2_DB_USER} --password=${REMOTE2_DB_PASS} -e "show databases;" | grep -Ev "(${REMOTE2_DB_EXLUDED})"`
    for DB in $databases; do
      if [[ "${DB}" != _* ]] ; then
        echo "[$(date +'%d-%m-%Y %H:%M:%S')] mysqldump remote ${REMOTE2_FTP_NAME} for ${DB} has started" >> "$LOG_FILE"

        TIMESTAMP=$(date +'%Y-%m-%d_%H-%M-%S')
        
        /usr/syno/mysql/bin/mysqldump --host="${REMOTE2_DB_HOST}" --port="${REMOTE2_DB_PORT}" --user="${REMOTE2_DB_USER}" --password="${REMOTE2_DB_PASS}" --databases "${DB}" --default-character-set=utf8 --protocol=tcp --flush-privileges=false --skip-opt --add-drop-database --add-drop-table --add-locks=false --single-transaction=false --flush-privileges=false --flush-logs=false --no-create-info=false --complete-insert=false --extended-insert=false --hex-blob --comments --triggers --routines --events --force=true --verbose --debug-info | /usr/syno/bin/7z a -si"backup_db_remote2_${DB}_${TIMESTAMP}.sql" "${BACKUP_DIR}/backup_db_remote2_${DB}_${TIMESTAMP}.7z" -t7z -m0=lzma2 -ms=off -mmt=off -mfb=64 -md=32m -mhe -mx9 -v${SPLIT_VOLUME} -p"${PASSWORD}" >> "$LOG_FILE2"

        echo "[$(date +'%d-%m-%Y %H:%M:%S')] mysqldump completed" >> "$LOG_FILE"
      fi
    done

  echo " Backup remote MySQL/MariaDB ${REMOTE2_DB_HOST} FINISH! " >> "$LOG_FILE"
  echo " " >> "$LOG_FILE"



  # pakujemy to co ściągneliśmy z serwera FTP i jest teraz na nasie
  TIMESTAMP=$(date +'%Y-%m-%d_%H-%M-%S')
  echo "[$(date +'%d-%m-%Y %H:%M:%S')] Compressing ${BACKUP_DIR}/${REMOTE2_FTP_NAME}/ started" >> "$LOG_FILE"
  /usr/syno/bin/7z a "${BACKUP_DIR}/backup_ftp_${REMOTE2_FTP_NAME}_${TIMESTAMP}.7z" "${BACKUP_DIR}/${REMOTE2_FTP_NAME}" -xr!Thumbs.db -xr!@eaDir -xr!@tmp -xr!#recycle -xr!lost+found -xr!.DS_Store -xr!.tmb -xr!.quarantine -t7z -m0=lzma2 -ms=off -mmt=off -mfb=64 -md=32m -mhe -mx9 -v${SPLIT_VOLUME} -p"${PASSWORD}" >> "$LOG_FILE2"
  echo "[$(date +'%d-%m-%Y %H:%M:%S')] Compressing ${BACKUP_DIR}/${REMOTE2_FTP_NAME}/ stoped" >> "$LOG_FILE"
  echo " " >> "$LOG_FILE"

  if [ "$TESTS_ARCHIVE_FILES" = true ] ; then
    echo "[$(date +'%d-%m-%Y %H:%M:%S')] Verifying files in the archive: ${BACKUP_DIR}/backup_ftp_${REMOTE2_FTP_NAME}_${TIMESTAMP}.7z.001" >> "$LOG_FILE2"
    /usr/syno/bin/7z t -t7z.split "${BACKUP_DIR}/backup_ftp_${REMOTE2_FTP_NAME}_${TIMESTAMP}.7z.001" -p"${PASSWORD}" >> "$LOG_FILE2"
    echo "[$(date +'%d-%m-%Y %H:%M:%S')] Verifying files completed" >> "$LOG_FILE2"
    echo " " >> "$LOG_FILE2"
  fi

  if [ -d "${BACKUP_DIR}/${REMOTE2_FTP_NAME}" ]; then
    rm -rf "${BACKUP_DIR}/${REMOTE2_FTP_NAME}" #uwaga: tutaj trwale usuwamy folder wraz z jego zawartością (i wcale nie trafi on do #recycle)
  fi

fi

echo " Backup remote FTP services: ${REMOTE2_FTP_NAME} / ${REMOTE2_FTP_HOST} FINISH! " >> "$LOG_FILE"
echo " " >> "$LOG_FILE"
