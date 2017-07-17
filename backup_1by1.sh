#!/bin/sh

# @version $Id: backup_1by1.sh 10 2017-06-28 12:51:26Z fixer $
# @date $Date: 2017-06-28 22:51:26 +1000 (Śr, 28 cze 2017) $
# @revision $Revision: 10 $
# @author $Author: fixer $
# @headurl $HeadURL: svn://.../repo_backup/backup_1by1.sh $

#TODO: trzeba dorobić podział na volumen'y
#TODO: przy ponownym włączeniu nowe pliki są dołączane do starego archiwum a nie powinno tak być
#TODO: sprawdzenie czy plik 7z już istnieje
#TODO: pominięcie etapu tworzenia plików na dysku - zamiast tego przekazać strumień stdio do curla
#TODO: zrobić wybór pomiędzy curlem a ncftp
#TODO: wznawianie wysyłania i pakowania od ostatniego przerwanego elementu
#TODO: w zależności od miejsca w katalogu tymczasowym pierw wszystko pakujemy a potem wszystko wysyłamy lub co spakuje to od razu wyśle a tymczasowy plik usunie
#TODO: zrobić licznik plików
if [ "$BACKUP_ONE_BY_ONE" = true ]; then
  count=0
  /usr/bin/find "${FOLDER}" -type f | while read line; do
    # echo "$line" #path+file
    # echo "${line##*/}" #file
    # echo "${line%/*}" #path

    #-an -no file name
    /usr/bin/p7zip/7zr a "${BACKUP_TMP_DIR}${line}.7z" "${line}" -t7z -ms=off -mmt=off -mhe -mx0 -p"${PASSWORD}"
    let count+=1
    #-S -show errors
    #-s -silent mode
    #-v -verbose
    curl -s --disable-epsv -v -T "${BACKUP_TMP_DIR}${line}.7z" -u "${FTP_USER}:${FTP_PASS}" "ftp://${FTP_HOST}/${FTP_FOLDER}${line%/*}/" --ftp-create-dirs;

    #w jednej linijce (uwaga: nie działa poprawnie)
    #/usr/bin/p7zip/7zr a -t7z -so "${BACKUP_TMP_DIR}${line}.7z" "${line}" -ms=off -mmt=off -mhe -mx0 -p"${PASSWORD}" | curl -s --disable-epsv -v -T - -u "${FTP_USER}:${FTP_PASS}" "ftp://${FTP_HOST}/${FTP_FOLDER}${line%/*}/" --ftp-create-dirs;

    #/usr/bin/ncftp/ncftpput -m -u -c "${FTP_USER}" -p "${FTP_PASS}" -P "${FTP_PORT}" "${FTP_HOST}" "${FTP_FOLDER}${line%/*}/" "${line##*/}.7z"
    # if [ $? -ne 0 ]; then echo "[$(date +'%d-%m-%Y %H:%M:%S')] Upload failed"; fi

    #zwykły ftp
    # ftp -n $HOST <<END_SCRIPT
    # quote USER $USER
    # quote PASS $PASSWD
    # cd $REMOTEPATH
    # put $FILE 
    # quit
    # END_SCRIPT


    # usunięcie tymczasowego archiwum
    if [ -f "${BACKUP_TMP_DIR}${line}.7z" ]; then
      rm -rf "${BACKUP_TMP_DIR}${line}.7z"
      echo "[$(date +'%d-%m-%Y %H:%M:%S')] tmp 7z deleted" >> "$LOG_FILE"
    fi
  done

  #usunięcie całego folderu
  #if [ -d "${BACKUP_TMP_DIR}/" ]; then
  #  rm -rf "${BACKUP_TMP_DIR}/"
  #  echo "[$(date +'%d-%m-%Y %H:%M:%S')] tmp folder deleted" >> "$LOG_FILE"
  #fi
fi