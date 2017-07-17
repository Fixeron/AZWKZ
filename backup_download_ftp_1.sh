#!/bin/sh

# @version $Id: backup_download_ftp_1.sh 8 2017-06-26 10:07:43Z fixer $
# @date $Date: 2017-06-26 20:07:43 +1000 (Pn, 26 cze 2017) $
# @revision $Revision: 8 $
# @author $Author: fixer $
# @headurl $HeadURL: svn://.../repo_backup/backup_download_ftp_1.sh $

#–ftp-user=
#–ftp-password=

# will work only if the remote FTP server is a UNIX server, or emulates UNIX's list output
if [ "$USE_FTP_REMOTE1" = true ] ; then
  echo "======================" >> "$LOG_FILE"
  echo "8. Backup remote FTP services: ${REMOTE1_FTP_NAME} / ${REMOTE1_FTP_HOST}" >> "$LOG_FILE"
  echo $(date +'%d-%m-%Y %H:%M:%S') >> "$LOG_FILE"
  echo "======================" >> "$LOG_FILE"
  if [ "$USE_NCFTP" = true ] ; then
    echo "[$(date +'%d-%m-%Y %H:%M:%S')] Downloading multiple web files from ${REMOTE1_FTP_NAME} / ${REMOTE1_FTP_HOST}" >> "$LOG_FILE"
    /usr/bin/ncftp/ncftpget -u "${REMOTE1_FTP_USER}" -p "${REMOTE1_FTP_PASS}" -P "${REMOTE1_FTP_PORT}" -d -v -R "${REMOTE1_FTP_HOST}" "${BACKUP_DIR}/${REMOTE1_FTP_NAME}/" "${REMOTE1_FTP_DIR}" >> "$LOG_FILE2"
    echo "[$(date +'%d-%m-%Y %H:%M:%S')] Downloading multiple web files completed" >> "$LOG_FILE"
  else
    # TODO: curl tutaj wymaga poprawienia bo żadna z alternatywnych metod nie ściąga plików rekursywnie
    echo "[$(date +'%d-%m-%Y %H:%M:%S')] WARNING: Nie sciagnolem plikow z serwera FTP: ${REMOTE1_FTP_NAME} / ${REMOTE1_FTP_HOST}" >> "$LOG_FILE"
    echo "Przelacz sie przez NCFTP" >> "$LOG_FILE"
    # curl -k -v ftp://"${REMOTE1_FTP_USER}:${REMOTE1_FTP_PASS}"@${REMOTE1_FTP_HOST}/${REMOTE1_FTP_DIR}
    # curl -k -v -u "${REMOTE1_FTP_USER}:${REMOTE1_FTP_PASS}" "${REMOTE1_FTP_HOST}/${REMOTE1_FTP_DIR}/" -O "${BACKUP_DIR}/${REMOTE1_FTP_NAME}/" --ftp-create-dirs
    # curl  -k -v "ftp://${REMOTE1_FTP_HOST}:${REMOTE2_FTP_PORT}${REMOTE2_FTP_DIR}" --user "${REMOTE1_FTP_USER}:${REMOTE1_FTP_PASS}" -o "${BACKUP_DIR}/${REMOTE1_FTP_NAME}" --ftp-create-dirs
    # wget -r --user="${REMOTE1_FTP_USER}" --password="${REMOTE1_FTP_PASS}" "${REMOTE1_FTP_HOST}${REMOTE1_FTP_DIR}/" "${BACKUP_DIR}/${REMOTE1_FTP_NAME}"
    # wget --no-verbose --no-parent --recursive --level=1 --no-directories --user=login --password=pass ftp://ftp.myftpsite.com/
    
    # sFTP:
    # scp -v -r -P 22 "${BACKUP_DIR}/${REMOTE1_FTP_NAME}/" "${REMOTE1_FTP_USER}@${REMOTE1_FTP_HOST}:/${REMOTE1_FTP_DIR}"
  fi
    echo " Downloading remote FTP files: ${REMOTE1_FTP_NAME} / ${REMOTE1_FTP_HOST} FINISH! " >> "$LOG_FILE"
    echo " " >> "$LOG_FILE"


  # sciagamy bazę mysql/mariadb ze zdalnego serwera (pamiętaj aby dodać na serwerze (np. w cpanel'u) adres ip do póli adresów zaufanych)
  echo "======================" >> "$LOG_FILE"
  echo "9. Backup remote MySQL/MariaDB ${REMOTE1_DB_HOST}" >> "$LOG_FILE"
  echo $(date +'%d-%m-%Y %H:%M:%S') >> "$LOG_FILE"
  echo "======================" >> "$LOG_FILE"
  
  databases=`mysql --skip-column-names --host=${REMOTE1_DB_HOST} --port=${REMOTE1_DB_PORT} --user=${REMOTE1_DB_USER} --password=${REMOTE1_DB_PASS} -e "show databases;" | grep -Ev "(${REMOTE1_DB_EXLUDED})"`
    for DB in $databases; do
      if [[ "${DB}" != _* ]] ; then
        echo "[$(date +'%d-%m-%Y %H:%M:%S')] mysqldump remote ${REMOTE1_FTP_NAME} for ${DB} has started" >> "$LOG_FILE"

        TIMESTAMP=$(date +'%Y-%m-%d_%H-%M-%S')

        /usr/syno/mysql/bin/mysqldump --host="${REMOTE1_DB_HOST}" --port="${REMOTE1_DB_PORT}" --user="${REMOTE1_DB_USER}" --password="${REMOTE1_DB_PASS}" --databases "${DB}" --default-character-set=utf8 --protocol=tcp --flush-privileges=false --skip-opt --add-drop-database --add-drop-table --add-locks=false --single-transaction=false --flush-privileges=false --flush-logs=false --no-create-info=false --complete-insert=false --extended-insert=false --hex-blob --comments --triggers --routines --events --force=true --verbose --debug-info | /usr/syno/bin/7z a -si"backup_db_remote1_${DB}_${TIMESTAMP}.sql" "${BACKUP_DIR}/backup_db_remote1_${DB}_${TIMESTAMP}.7z" -t7z -m0=lzma2 -ms=off -mmt=off -mfb=64 -md=32m -mhe -mx9 -v${SPLIT_VOLUME} -p"${PASSWORD}" >> "$LOG_FILE2"

        echo "[$(date +'%d-%m-%Y %H:%M:%S')] mysqldump completed" >> "$LOG_FILE"
      fi
    done

    echo " Backup remote MySQL/MariaDB ${REMOTE1_DB_HOST} FINISH! " >> "$LOG_FILE"
    echo " " >> "$LOG_FILE"



  # pakujemy to co ściągneliśmy z serwera FTP i jest teraz na nasie
  TIMESTAMP=$(date +'%Y-%m-%d_%H-%M-%S')
  echo "[$(date +'%d-%m-%Y %H:%M:%S')] Compressing ${BACKUP_DIR}/${REMOTE1_FTP_NAME}/ started" >> "$LOG_FILE"
  /usr/syno/bin/7z a "${BACKUP_DIR}/backup_ftp_${REMOTE1_FTP_NAME}_${TIMESTAMP}.7z" "${BACKUP_DIR}/${REMOTE1_FTP_NAME}" -xr!Thumbs.db -xr!@eaDir -xr!@tmp -xr!#recycle -xr!lost+found -xr!.DS_Store -xr!.tmb -xr!.quarantine -t7z -m0=lzma2 -ms=off -mmt=off -mfb=64 -md=32m -mhe -mx9 -v${SPLIT_VOLUME} -p"${PASSWORD}" >> "$LOG_FILE2"
  echo "[$(date +'%d-%m-%Y %H:%M:%S')] Compressing ${BACKUP_DIR}/${REMOTE1_FTP_NAME}/ stoped" >> "$LOG_FILE"
  echo " " >> "$LOG_FILE"

  if [ "$TESTS_ARCHIVE_FILES" = true ] ; then
    echo "[$(date +'%d-%m-%Y %H:%M:%S')] Verifying files in the archive: ${BACKUP_DIR}/backup_ftp_${REMOTE1_FTP_NAME}_${TIMESTAMP}.7z.001" >> "$LOG_FILE2"
    /usr/syno/bin/7z t -t7z.split "${BACKUP_DIR}/backup_ftp_${REMOTE1_FTP_NAME}_${TIMESTAMP}.7z.001" -p"${PASSWORD}" >> "$LOG_FILE2"
    echo "[$(date +'%d-%m-%Y %H:%M:%S')] Verifying files completed" >> "$LOG_FILE2"
    echo " " >> "$LOG_FILE2"
  fi

  if [ -d "${BACKUP_DIR}/${REMOTE1_FTP_NAME}" ]; then
    rm -rf "${BACKUP_DIR}/${REMOTE1_FTP_NAME}" #uwaga: tutaj trwale usuwamy folder wraz z jego zawartością (i wcale nie trafi on do #recycle)
  fi

fi

echo " Backup remote FTP services: ${REMOTE1_FTP_NAME} / ${REMOTE1_FTP_HOST} FINISH! " >> "$LOG_FILE"
echo " " >> "$LOG_FILE"