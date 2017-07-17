#!/bin/sh

# @version $Id: backup_remove_remote.sh 8 2017-06-26 10:07:43Z fixer $
# @date $Date: 2017-06-26 20:07:43 +1000 (Pn, 26 cze 2017) $
# @revision $Revision: 8 $
# @author $Author: fixer $
# @headurl $HeadURL: svn://.../repo_backup/backup_remove_remote.sh $

if [ "$DELETE_OLD_FTP_BACKUP" = true ] ; then
  echo "======================" >> "$LOG_FILE"
  echo "3. Removing old backup files from FTP: ${FTP_HOST}" >> "$LOG_FILE"
  echo $(date +'%d-%m-%Y %H:%M:%S') >> "$LOG_FILE"
  echo "======================" >> "$LOG_FILE"

  # pokaż listę plików z logami
  # curl -v --disable-epsv -a -l -u "${FTP_USER}:${FTP_PASS}" "ftp://${FTP_HOST}:21/backup/"
  # -s (tryb ukryty) pokaż tylko pliki zaczynające się na "backup_"
  for i in $(curl --disable-epsv -s -l -u "${FTP_USER}:${FTP_PASS}" "ftp://${FTP_HOST}:21/backup/" | grep "^backup_.*"); do
  {
    echo "[$(date +'%d-%m-%Y %H:%M:%S')] Deleting from remote ftp: ${FTP_HOST} \"/backup/$i\"" >> "$LOG_FILE"
    # usuń plik (uwaga: ma problemy z usuwaniem plików w których w nazwie występuje spacja, problem dotyczy 
    # spakowanych plików np. "photo_nazwa albumu_...") gdybyśmy je wysyłali na FTP ale ich nie wysyłamy :)
    curl -v -u "${FTP_USER}:${FTP_USER}" "ftp://${FTP_HOST}:21/backup/" -Q "DELE backup/${i}"
    #nie potrafi tutaj usuwać folderów
  };
  done;
  # na końcu usuń cały folder/katalog (działa tylko gdy jest pusty)
  # curl -v --disable-epsv -u "${FTP_USER}:${FTP_USER}" "ftp://${FTP_HOST}:21/backup/" -Q "-RMD /backup/"
fi

echo " Removing old backup files from FTP: ${FTP_HOST} FINISH! " >> "$LOG_FILE"
echo " " >> "$LOG_FILE"