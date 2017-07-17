#!/bin/sh

# @version $Id: backup_web.sh 10 2017-06-28 12:51:26Z fixer $
# @date $Date: 2017-06-28 22:51:26 +1000 (Śr, 28 cze 2017) $
# @revision $Revision: 10 $
# @author $Author: fixer $
# @headurl $HeadURL: svn://.../repo_backup/backup_web.sh $

echo "======================" >> "$LOG_FILE"
echo "5. Backup ${WEB_DIR} on NAS" >> "$LOG_FILE"
echo $(date +'%d-%m-%Y %H:%M:%S') >> "$LOG_FILE"
echo "======================" >> "$LOG_FILE"

#dla uniknięcia kolizji plików stopujemy usługę WebServera HTTP Apache
/sbin/initctl stop httpd-user >> "$LOG_FILE2"
sleep 2

# pakujemy foldery i pliki www z /volume1/web/
for dir in ${WEB_DIR}/*/;
  do
    dir=${dir%*/}
    # pomijamy pakowanie folderów typu: "#recycle", "@eaDir", "cgi-bin"
    # możesz też tu dopisać nazwy folderów, których nie chcesz kompresować
    # 7zip ma też ustawione pomijanie plików "thumbs.db", "@eaDir", "@tmp", ".DS_Store", "#recycle", "lost+found"
    if echo "${dir##*/}" | grep -Ev "(${FOLDER_EXLUDED})" >/dev/null; then
      # echo ${dir##*/}
      TIMESTAMP=$(date +'%Y-%m-%d_%H-%M-%S')
      
      if [ "$BACKUP_DIFFERENTIAL" = true ]; then
        #TODO: differential backup (nadaje się do folderów web oraz dla często zmieniających się dokumentach)
        # -u- tells the main archive should not be modified
      
        #znajdujemy taki plik "PATH/backup_web_PROJEKT_DATA.7z.001"
        /usr/bin/find "${BACKUP_DIR}/" -type f -regex '.*/backup_web_${dir##*/}.*\.7z\.001' | while read line; do
          # echo "$line" #path+file
          # echo "${line##*/}" #file
          # echo "${line%/*}" #path
          
          /usr/syno/bin/7z u "$line" "${dir}" -xr!Thumbs.db -xr!@eaDir -xr!@tmp -xr!#recycle -xr!lost+found -xr!.DS_Store -t7z -m0=lzma2 -ms=off -mfb=64 -md=32m -mhe -mmt -mx9 -v${SPLIT_VOLUME} -u- -p"${PASSWORD}" -up0q3r2x2y2z0w2!"${BACKUP_DIR}/backup_web_${dir##*/}_diff_${TIMESTAMP}.7z" >> "$LOG_FILE2" 
        done
        
        # TODO: diff recovery:
        # full: 7zr.exe x c:\archive.7z -oc:\recovery_path\
        # diff: 7zr.exe x c:\archive.7z -aoa -y -oc:\recovery_path\
        # -aoa Overwrite All existing files without prompt
        # -y assume Yes on all queries

      else
        #full backup
        echo "[$(date +'%d-%m-%Y %H:%M:%S')] Compressing ${WEB_DIR}/${dir##*/}/" >> "$LOG_FILE"
        
        #pakujemy pierw TAR'em aby zachować uprawnienia do plików (chmod)
        #niestety w tym trybie nie ma sensu robić kopii dyferencyjnych ponieważ mamy w środku jeden spakowany plik + podział na volumen'y
        
        /usr/syno/bin/tar --exclude='Thumbs.db' --exclude='@eaDir' --exclude='@tmp' --exclude='#recycle' --exclude='lost+found' --exclude='.DS_Store' -cjvp "${dir}" | /usr/syno/bin/7z a -si "${BACKUP_DIR}/backup_web_${dir##*/}_${TIMESTAMP}.tar.gz.7z" -t7z -mx0 -mhe -ms=off -mmt=off -v${SPLIT_VOLUME} -p"${PASSWORD}" >> "$LOG_FILE2"
        
        #restore: 7zr x -so directory.tar.7z | tar xf

        #a tu pakujemy od razu to 7z (bez zachowania file permission)
        #jeśli chcmey tutaj mieć kopie dyferencyjne to musimy pod spodem pozbyć się parametru dzielącego na volumen'y -v${SPLIT_VOLUME}
        #/usr/syno/bin/7z a "${BACKUP_DIR}/backup_web_${dir##*/}_${TIMESTAMP}.7z" "${dir}" -xr!Thumbs.db -xr!@eaDir -xr!@tmp -xr!#recycle -xr!lost+found -xr!.DS_Store -t7z -m0=lzma2 -ms=off -mmt=off -mfb=64 -md=32m -mhe -mx9 -v${SPLIT_VOLUME} -p"${PASSWORD}" >> "$LOG_FILE2"
        echo "[$(date +'%d-%m-%Y %H:%M:%S')] Compressing completed" >> "$LOG_FILE"
        echo " " >> "$LOG_FILE"

        if [ "$TESTS_ARCHIVE_FILES" = true ] ; then
          echo "[$(date +'%d-%m-%Y %H:%M:%S')] Verifying files in the archive: ${BACKUP_DIR}/backup_web_${dir##*/}_${TIMESTAMP}.7z.001" >> "$LOG_FILE2"
          /usr/syno/bin/7z t -t7z.split "${BACKUP_DIR}/backup_web_${dir##*/}_${TIMESTAMP}.7z.001" -p"${PASSWORD}" >> "$LOG_FILE2"
          echo "[$(date +'%d-%m-%Y %H:%M:%S')] Verifying files completed: ${BACKUP_DIR}/backup_web_${dir##*/}_${TIMESTAMP}.7z.001" >> "$LOG_FILE2"
          echo " " >> "$LOG_FILE2"
        fi
      fi

    fi
  done


# BUG FIX: na końcu jeszcze pakujemy pliki z głównego folderu, których nie ma w powyższych archiwach bo w nich są 
# spakowane same foldery główne
# TODO: bezpiecznie było by zapisywać pliki tymczasowe *.lst w osobnej lokalizacji a nie w miejscu docelowym gdzie ma 
# być wykonywany backup jak to jest teraz
# robimy listę plików (nie folderów) do spakowania i zapisujemy ją na dysku do pliku *.lst, potem go usuniemy oczywiście
# Handles whitespace and newlines in file names
# ls "${WEB_DIR}" -p | grep -v / > "${BACKUP_DIR}/tmp_file_list.lst"  #pokaż listę plików bez ścieżki
find "${WEB_DIR}" -mindepth 1 -maxdepth 1 -type f > "${BACKUP_DIR}/tmp_file_list.lst" #pokaż listę plików ze ścieżką
echo "[$(date +'%d-%m-%Y %H:%M:%S')] Compressing webfiles from main folder ${WEB_DIR} started" >> "$LOG_FILE"
TIMESTAMP=$(date +'%Y-%m-%d_%H-%M-%S')
#TODO: dodać TAR.GZ do archiwum

# /usr/syno/bin/7z a "${BACKUP_DIR}/backup_webfiles_${TIMESTAMP}.7z" -i@"${BACKUP_DIR}/tmp_file_list.lst" -xr!Thumbs.db -xr!@eaDir -xr!@tmp -xr!#recycle -xr!lost+found -xr!.DS_Store -t7z -m0=lzma2 -ms=off -mmt=off -mfb=64 -md=32m -mhe -mx9 -v${SPLIT_VOLUME} -p"${PASSWORD}" >> "$LOG_FILE2"
/usr/syno/bin/tar --exclude='Thumbs.db' --exclude='@eaDir' --exclude='@tmp' --exclude='#recycle' --exclude='lost+found' --exclude='.DS_Store' -cjvpf "${dir}" --files-from="${BACKUP_DIR}/tmp_file_list.lst" | /usr/syno/bin/7z a -si "${BACKUP_DIR}/backup_webfiles_${dir##*/}_${TIMESTAMP}.tar.gz.7z" -t7z -mx0 -mhe -ms=off -mmt=off -v${SPLIT_VOLUME} -p"${PASSWORD}" >> "$LOG_FILE2"

echo "[$(date +'%d-%m-%Y %H:%M:%S')] Compressing webfiles from ${WEB_DIR} stoped" >> "$LOG_FILE"
echo " " >> "$LOG_FILE"

if [ "$TESTS_ARCHIVE_FILES" = true ] ; then
  echo "[$(date +'%d-%m-%Y %H:%M:%S')] Verifying files in the archive: ${BACKUP_DIR}/backup_webfiles_${TIMESTAMP}.7z.001" >> "$LOG_FILE2"
  /usr/syno/bin/7z t -t7z.split "${BACKUP_DIR}/backup_webfiles_${TIMESTAMP}.7z.001" -p"${PASSWORD}" >> "$LOG_FILE2"
  echo "[$(date +'%d-%m-%Y %H:%M:%S')] Verifying files completed" >> "$LOG_FILE2"
  echo " " >> "$LOG_FILE2"
fi

if [ -f "${BACKUP_DIR}/tmp_file_list.lst" ]; then
  rm -rf "${BACKUP_DIR}/tmp_file_list.lst" #uwaga: tutaj trwale usuwamy plik wraz z jego zawartością (i wcale nie trafi on do #recycle)
  echo "[$(date +'%d-%m-%Y %H:%M:%S')] *.lst file deleted" >> "$LOG_FILE"
fi

# alternatywnie (nie działa ta metoda): pokaż listę plików w układzie: "plik1.txt" "plik 2.txt" (żeby wsadzić to do 7z'ipa jako zmienną)
# while IFS= read -r file; do
#   only_files="$only_files$(printf "\"$file\" ")"
# done <<EOF
# $(find "${WEB_DIR}" -mindepth 1 -maxdepth 1 -type f)
# EOF
# /usr/syno/bin/7z a "${BACKUP_DIR}/backup_webfiles_${TIMESTAMP}.7z" "$only_files" -xr!Thumbs.db -xr!@eaDir -xr!@tmp -xr!#recycle -xr!lost+found -xr!.DS_Store -t7z -m0=lzma2 -ms=off -mmt=off -mfb=64 -md=32m -mhe -mx9 -v${SPLIT_VOLUME} -p"${PASSWORD}" >> "$LOG_FILE2"

#wznawiamy usługę WebServera
/sbin/initctl start httpd-user >> "$LOG_FILE2"
sleep 2

echo " Backup ${WEB_DIR} on NAS FINISH! " >> "$LOG_FILE"
echo " " >> "$LOG_FILE"