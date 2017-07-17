#!/bin/sh

# @version $Id: backup_upload_ftp.sh 8 2017-06-26 10:07:43Z fixer $
# @date $Date: 2017-06-26 20:07:43 +1000 (Pn, 26 cze 2017) $
# @revision $Revision: 8 $
# @author $Author: fixer $
# @headurl $HeadURL: svn://.../repo_backup/backup_upload_ftp.sh $

if [ "$SEND_TO_FTP" = true ]; then
  echo "======================" >> "$LOG_FILE"
  echo "12. Sending 7z files to $FTP_HOST" >> "$LOG_FILE"
  echo $(date +'%d-%m-%Y %H:%M:%S') >> "$LOG_FILE"
  echo "======================" >> "$LOG_FILE"

  for file in ${BACKUP_DIR}/*; 
    do
      file2=${file%*/};
      if echo "${file2##*/}" | grep '^backup_*' >/dev/null; then
        # folder "backup" musi już tam istnieć! (nie koniecznie pusty)
        # --disable-epsv
        # --disable-eprt
        # --ftp-method multicwd|nocwd|singlecwd
        # --data-binary
        
        # sprawdzamy sumy kontrolne (przed wysłaniem):
        FILE_SIZE1="$(wc -c <"${file}")" #zawsze podaje wielkość pliku w bajtach
        FILE_SIZE2="$(du -h "${file}" | cut -f1)" #to automatycznie zmienia jednostki
        CRC_SUM=$(cksum "${file}" | cut -d' ' -f1) #generujemy sumę kontrolną
        # /usr/syno/bin/openssl dgst md5/sha1 "" #suma md5 lub sha1 trwa dłużej!!
        echo "[$(date +'%d-%m-%Y %H:%M:%S')] Sending file: ${FILE_SIZE2} (${FILE_SIZE1} bytes) / CRC32: ${CRC_SUM} | ${file2##*/}" >> "$LOG_FILE";

        if [ "$USE_NCFTP" = true ] ; then
          # <<EOF
          # mkdir $FTPD
          # mkdir $FTPD/$NOW
          # cd $FTPD/$NOW
          # lcd $BACKUP
          # mput *
          # quit
          # EOF
          /usr/bin/ncftp/ncftpput -v -m -u "${FTP_USER}" -p "${FTP_PASS}" -P "${FTP_PORT}" "${FTP_HOST}" "/backup" "${file}"
          if [ $? -ne 0 ]; then echo "[$(date +'%d-%m-%Y %H:%M:%S')] Upload failed" >> "$LOG_FILE"; fi
        else
          curl -s --disable-epsv -v -T ${file} -u ${FTP_USER}:${FTP_PASS} "ftp://${FTP_HOST}/backup/";
        fi

        # wput -u ftp://${FTP_USER}:${FTP_PASS}@${FTP_HOST}/backup/ ${file}
        # ftp -in -u ftp://${FTP_USER}:${FTP_PASS}@${FTP_HOST}/backup/ ${file}
        # curl -k "sftp://${FTP_HOST}/backup/" --user "${FTP_USER}:${FTP_PASS}" -T "${file}" --ftp-create-dirs
        echo "[$(date +'%d-%m-%Y %H:%M:%S')] File sended" >> "$LOG_FILE";
        echo " " >> "$LOG_FILE"
      fi;
    done;

    echo " Sending 7z files to $FTP_HOST FINISH! " >> "$LOG_FILE"
    echo " " >> "$LOG_FILE"

fi;