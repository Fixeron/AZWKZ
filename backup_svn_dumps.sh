#!/bin/sh

# @version $Id: backup_svn_dumps.sh 8 2017-06-26 10:07:43Z fixer $
# @date $Date: 2017-06-26 20:07:43 +1000 (Pn, 26 cze 2017) $
# @revision $Revision: 8 $
# @author $Author: fixer $
# @headurl $HeadURL: svn://.../repo_backup/backup_svn_dumps.sh $

if [ "$BACKUP_SVN_DUMPS" = true ] ; then
  echo "======================" >> "$LOG_FILE"
  echo "6. Backup SVN DUMPS ${SVN_DIR} on NAS" >> "$LOG_FILE"
  echo $(date +'%d-%m-%Y %H:%M:%S') >> "$LOG_FILE"
  echo "======================" >> "$LOG_FILE"

  echo "svn version: $(/usr/bin/svn --version --quiet)" >> "$LOG_FILE"

  for dir in ${SVN_DIR}/*/;
    do
      dir=${dir%*/}
      if echo "${dir##*/}" | grep -Ev "(${FOLDER_SVN_EXLUDED})" >/dev/null; then
        # echo ${dir##*/}
        TIMESTAMP=$(date +'%Y-%m-%d_%H-%M-%S')
        echo "[$(date +'%d-%m-%Y %H:%M:%S')] SVN dump for repo: ${SVN_DIR}/${dir##*/}/ started" >> "$LOG_FILE"

        /usr/bin/svnadmin info "${SVN_DIR}/${dir##*/}" >> "$LOG_FILE"

        echo "Compressing SVN dump file for repository: ${dir##*/}" >> "$LOG_FILE"
        
        /usr/bin/svnadmin dump "${SVN_DIR}/${dir##*/}" | /usr/syno/bin/7z a -si "${BACKUP_DIR}/backup_svn_dump_${dir##*/}_${TIMESTAMP}.dump.7z" -t7z -m0=lzma2 -ms=off -mmt=off -mfb=64 -md=32m -mhe -mx9 -v${SPLIT_VOLUME} -p"${PASSWORD}" >> "$LOG_FILE2"
        
        # metoda bez kompresji:
        #/usr/bin/svnadmin dump "${SVN_DIR}/${dir##*/}" > ${BACKUP_DIR}/backup_svn_dump_${dir##*/}_${TIMESTAMP}.dump

        echo "Compressing SVN dump file for repository: ${dir##*/} FINISH!" >> "$LOG_FILE"
        echo " " >> "$LOG_FILE"

        echo "[$(date +'%d-%m-%Y %H:%M:%S')] SVN dump for repo: ${SVN_DIR}/${dir##*/}/ stoped" >> "$LOG_FILE"
        echo " " >> "$LOG_FILE"

        if [ "$TESTS_ARCHIVE_FILES" = true ] ; then
          echo "[$(date +'%d-%m-%Y %H:%M:%S')] Verifying files in the archive: ${BACKUP_DIR}/backup_svn_dump_${dir##*/}_${TIMESTAMP}.dump.7z.001" >> "$LOG_FILE2"
          
          /usr/syno/bin/7z t -t7z.split "${BACKUP_DIR}/backup_svn_dump_${dir##*/}_${TIMESTAMP}.dump.7z.001" -p"${PASSWORD}" >> "$LOG_FILE2"
          
          echo "[$(date +'%d-%m-%Y %H:%M:%S')] Verifying files completed" >> "$LOG_FILE2"
          echo " " >> "$LOG_FILE2"
        fi
      fi
    done

  echo " Backup SVN DUMPS ${SVN_DIR} on NAS FINISH! " >> "$LOG_FILE"
  echo " " >> "$LOG_FILE"
fi