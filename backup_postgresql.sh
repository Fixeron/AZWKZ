#!/bin/sh

# @version $Id: backup_postgresql.sh 12 2017-07-17 01:30:14Z Fixer $
# @date $Date: 2017-07-17 11:30:14 +1000 (Pn, 17 lip 2017) $
# @revision $Revision: 12 $
# @author $Author: Fixer $
# @headurl $HeadURL: svn://fixer.synology.me/repo_backup/backup_postgresql.sh $

echo "======================" >> "$LOG_FILE"
echo "4. Backup PostreSQL on NAS" >> "$LOG_FILE"
echo $(date +'%d-%m-%Y %H:%M:%S') >> "$LOG_FILE"
echo "======================" >> "$LOG_FILE"

echo "[$(date +'%d-%m-%Y %H:%M:%S')] postresql dump has started" >> "$LOG_FILE"
TIMESTAMP=$(date +'%Y-%m-%d_%H-%M-%S')

#/usr/syno/pgsql/bin/pg_ctl reload
#/usr/bin/pg_ctl restart

	#/usr/syno/pgsql/bin/pg_dump -O -U USERNAME PGPASSWORD=hasloDoBazyDanych DBNAME -h "${DB_HOST}" -p 5432 --disable-dollar-quoting -i > DBNAME-YYYY-MM-DD.sql
	#/usr/syno/pgsql/bin/pg_dump -v -O -U fixer -W haslo DBNAME -h "${DB_HOST}" -p 5432 --disable-dollar-quoting -i | /usr/syno/bin/7z a -si"backup_db_posgresql_all_${TIMESTAMP}.sql" "${BACKUP_DIR}/backup_db_posgresql_all_${TIMESTAMP}.7z" -t7z -m0=lzma2 -ms=off -mmt=off -mfb=64 -md=32m -mhe -mx9 -v${SPLIT_VOLUME} -p"${PASSWORD}" >> "$LOG_FILE2"
  
# W pliku: "/etc/postgresql/pg_hba.conf" należy dopisać to:
## TYPE  DATABASE        USER            ADDRESS                 METHOD
#local   all             all                                     trust
#host    all             all             127.0.0.1/32            trust
#host    all             all             ::1/128                 trust
#host    all             all             TUTAJ NASZ ADRES IP LOKALNY LUB ZDALNY/24          trust

# obowiązkowo zrestartować NAS'a

  /usr/syno/pgsql/bin/psql -U postgres --version >> "$LOG_FILE2"
  /usr/syno/pgsql/bin/pg_dump --version >> "$LOG_FILE2"
  /usr/syno/pgsql/bin/psql -U postgres -l >> "$LOG_FILE2"
  #nie dziala to: -E "UTF-8"
  /usr/syno/pgsql/bin/pg_dumpall -v -O -U postgres -h "localhost" -p 5432 --disable-dollar-quoting -i | /usr/syno/bin/7z a -si"backup_db_posgresql_all_${TIMESTAMP}.sql" "${BACKUP_DIR}/backup_db_posgresql_all_${TIMESTAMP}.7z" -t7z -m0=lzma2 -ms=off -mmt=off -mfb=64 -md=32m -mhe -mx9 -v${SPLIT_VOLUME} -p"${PASSWORD}" >> "$LOG_FILE2"

	echo "[$(date +'%d-%m-%Y %H:%M:%S')] postresql dump completed" >> "$LOG_FILE"
	echo " " >> "$LOG_FILE"

	if [ "$TESTS_ARCHIVE_FILES" = true ] ; then
	  echo "[$(date +'%d-%m-%Y %H:%M:%S')] Verifying files in the archive: ${BACKUP_DIR}/backup_db_posgresql_all_${TIMESTAMP}.7z.001" >> "$LOG_FILE2"
	  /usr/syno/bin/7z t -t7z.split "${BACKUP_DIR}/backup_db_posgresql_all_${TIMESTAMP}.7z.001" -p"${PASSWORD}" >> "$LOG_FILE2"
	  echo "[$(date +'%d-%m-%Y %H:%M:%S')] Verifying files completed" >> "$LOG_FILE2"
	  echo " " >> "$LOG_FILE2"
	fi

echo " Backup PostreSQL on NAS FINISH! " >> "$LOG_FILE"
echo " " >> "$LOG_FILE"