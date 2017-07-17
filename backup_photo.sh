#!/bin/sh

# @version $Id: backup_photo.sh 8 2017-06-26 10:07:43Z fixer $
# @date $Date: 2017-06-26 20:07:43 +1000 (Pn, 26 cze 2017) $
# @revision $Revision: 8 $
# @author $Author: fixer $
# @headurl $HeadURL: svn://.../repo_backup/backup_photo.sh $

if [ "$BACKUP_PHOTO" = true ] ; then
  echo "======================" >> "$LOG_FILE"
  echo "7. Backup ${PHOTO_DIR} on NAS" >> "$LOG_FILE"
  echo $(date +'%d-%m-%Y %H:%M:%S') >> "$LOG_FILE"
  echo "======================" >> "$LOG_FILE"

  for dir in ${PHOTO_DIR}/*/;
    do
      dir=${dir%*/}
      # pomijamy pakowanie folderów typu: "#recycle", "@eaDir", "cgi-bin"
      # możesz też tu dopisać nazwy folderów, których nie chcesz kompresować
      # 7zip ma też ustawione pomijanie plików "Thumbs.db", "@eaDir", "@tmp", ".DS_Store", "#recycle", "lost+found"
      if echo "${dir##*/}" | grep -Ev "(${FOLDER_PHOTO_EXLUDED})" >/dev/null; then
        #echo ${dir##*/}
        TIMESTAMP=$(date +'%Y-%m-%d_%H-%M-%S')
        echo "[$(date +'%d-%m-%Y %H:%M:%S')] Compressing ${PHOTO_DIR}/${dir##*/}/ started" >> "$LOG_FILE"
        
        /usr/syno/bin/7z a "${BACKUP_DIR}/photo_${dir##*/}_${TIMESTAMP}.7z" "${dir}" -xr!Thumbs.db -xr!@eaDir -xr!@tmp -xr!#recycle -xr!lost+found -xr!.DS_Store -t7z -mhe -ms=off -mmt=off -mx0 -v${SPLIT_PHOTO_VOLUME} -p"${PASSWORD}" >> "$LOG_FILE2"
        
        echo "[$(date +'%d-%m-%Y %H:%M:%S')] Compressing ${PHOTO_DIR}/${dir##*/}/ stoped" >> "$LOG_FILE"
        echo " " >> "$LOG_FILE"

        if [ "$TESTS_ARCHIVE_FILES" = true ] ; then
          echo "[$(date +'%d-%m-%Y %H:%M:%S')] Verifying files in the archive: ${BACKUP_DIR}/photo_${dir##*/}_${TIMESTAMP}.7z.001" >> "$LOG_FILE2"
          /usr/syno/bin/7z t -t7z.split "${BACKUP_DIR}/photo_${dir##*/}_${TIMESTAMP}.7z.001" -p"${PASSWORD}" >> "$LOG_FILE2"
          echo "[$(date +'%d-%m-%Y %H:%M:%S')] Verifying files completed" >> "$LOG_FILE2"
          echo " " >> "$LOG_FILE2"
        fi
      fi
    done

  # BUG FIX: na końcu jeszcze pakujemy pliki z głównego folderu, których nie ma w powyższych archiwach bo w nich są spakowane same foldery główne
  find "${PHOTO_DIR}" -mindepth 1 -maxdepth 1 -type f > "${BACKUP_DIR}/tmp_file_list.lst" #pokaż listę plików ze ścieżką
  echo "[$(date +'%d-%m-%Y %H:%M:%S')] Compressing photofiles from main folder ${PHOTO_DIR} started" >> "$LOG_FILE"
  TIMESTAMP=$(date +'%Y-%m-%d_%H-%M-%S')
  /usr/syno/bin/7z a "${BACKUP_DIR}/photo_photofiles_${TIMESTAMP}.7z" -i@"${BACKUP_DIR}/tmp_file_list.lst" -xr!Thumbs.db -xr!@eaDir -xr!@tmp -xr!#recycle -xr!lost+found -xr!.DS_Store -t7z -mhe -ms=off -mmt=off -mx0 -v${SPLIT_PHOTO_VOLUME} -p"${PASSWORD}" >> "$LOG_FILE2"
  echo "[$(date +'%d-%m-%Y %H:%M:%S')] Compressing photofiles from ${PHOTO_DIR} stoped" >> "$LOG_FILE"
  echo " " >> "$LOG_FILE"

  if [ "$TESTS_ARCHIVE_FILES" = true ] ; then
    echo "[$(date +'%d-%m-%Y %H:%M:%S')] Verifying files in the archive: ${BACKUP_DIR}/photo_photofiles_${TIMESTAMP}.7z.001" >> "$LOG_FILE2"
    /usr/syno/bin/7z t -t7z.split "${BACKUP_DIR}/photo_photofiles_${TIMESTAMP}.7z.001" -p"${PASSWORD}" >> "$LOG_FILE2"
    echo "[$(date +'%d-%m-%Y %H:%M:%S')] Verifying files completed" >> "$LOG_FILE2"
    echo " " >> "$LOG_FILE2"
  fi
  
  if [ -f "${BACKUP_DIR}/tmp_file_list.lst" ]; then
    rm -rf "${BACKUP_DIR}/tmp_file_list.lst" #uwaga: tutaj trwale usuwamy plik wraz z jego zawartością (i wcale nie trafi on do #recycle)
    echo "[$(date +'%d-%m-%Y %H:%M:%S')] *.lst file deleted" >> "$LOG_FILE"
  fi

    echo " Backup ${PHOTO_DIR} on NAS FINISH! " >> "$LOG_FILE"
    echo " " >> "$LOG_FILE"
fi