#!/bin/sh

# @version $Id: backup_mariadb.sh 9 2017-06-27 02:39:41Z fixer $
# @date $Date: 2017-06-27 12:39:41 +1000 (Wt, 27 cze 2017) $
# @revision $Revision: 9 $
# @author $Author: fixer $
# @headurl $HeadURL: svn://.../repo_backup/backup_mariadb.sh $

echo "======================" >> "$LOG_FILE"
echo "4. Backup MariaDB on NAS" >> "$LOG_FILE"
echo $(date +'%d-%m-%Y %H:%M:%S') >> "$LOG_FILE"
echo "======================" >> "$LOG_FILE"

/sbin/initctl stop httpd-user >> "$LOG_FILE2"
sleep 8
/usr/syno/bin/synopkg restart MariaDB >> "$LOG_FILE2"
sleep 30

databases=`mysql --skip-column-names --host=${DB_HOST} --port=${DB_PORT} --user=${DB_USER} --password=${DB_PASS} -e "show databases;" | grep -Ev "(${DB_EXLUDED})"`
for DB in $databases; do
  if [[ "${DB}" != _* ]] ; then

    echo "[$(date +'%d-%m-%Y %H:%M:%S')] mysqldump for ${DB} has started" >> "$LOG_FILE"
    TIMESTAMP=$(date +'%Y-%m-%d_%H-%M-%S')

    /usr/syno/mysql/bin/mysqlcheck --host="${DB_HOST}" --port="${DB_PORT}" --user="${DB_USER}" --password="${DB_PASS}" --databases "${DB}" --check-upgrade --auto-repair >> "$LOG_FILE2"
    #/usr/syno/mysql/bin/mysql_upgrade --host="${DB_HOST}" --port="${DB_PORT}" --user="${DB_USER}" --password="${DB_PASS}"  --verbose --force >> "$LOG_FILE2"
    /usr/syno/mysql/bin/mysqldump --host="${DB_HOST}" --port="${DB_PORT}" --user="${DB_USER}" --password="${DB_PASS}" --databases "${DB}" --default-character-set=utf8 --protocol=tcp --flush-privileges=false --skip-opt --add-drop-database --add-drop-table --add-locks=false --single-transaction=false --flush-privileges=false --flush-logs=false --no-create-info=false --complete-insert=false --extended-insert=false --hex-blob --comments --triggers --routines --events --force=true --verbose --debug-info | /usr/syno/bin/7z a -si"backup_db_${DB}_${TIMESTAMP}.sql" "${BACKUP_DIR}/backup_db_${DB}_${TIMESTAMP}.7z" -t7z -m0=lzma2 -ms=off -mmt=off -mfb=64 -md=32m -mhe -mx9 -v${SPLIT_VOLUME} -p"${PASSWORD}" >> "$LOG_FILE2"
    
    echo "[$(date +'%d-%m-%Y %H:%M:%S')] mysqldump completed" >> "$LOG_FILE"
    echo " " >> "$LOG_FILE"

    if [ "$TESTS_ARCHIVE_FILES" = true ] ; then
      echo "[$(date +'%d-%m-%Y %H:%M:%S')] Verifying files in the archive: ${BACKUP_DIR}/backup_db_${DB}_${TIMESTAMP}.7z.001" >> "$LOG_FILE2"
      /usr/syno/bin/7z t -t7z.split "${BACKUP_DIR}/backup_db_${DB}_${TIMESTAMP}.7z.001" -p"${PASSWORD}" >> "$LOG_FILE2"
      echo "[$(date +'%d-%m-%Y %H:%M:%S')] Verifying files completed" >> "$LOG_FILE2"
      echo " " >> "$LOG_FILE2"
    fi

  fi
done

/sbin/initctl start httpd-user >> "$LOG_FILE2"
sleep 8
/usr/syno/bin/synopkg restart MariaDB >> "$LOG_FILE2"
sleep 30

echo " Backup MariaDB on NAS FINISH! " >> "$LOG_FILE"
echo " " >> "$LOG_FILE"