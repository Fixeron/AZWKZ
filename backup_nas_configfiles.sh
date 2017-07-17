#!/bin/sh

# @version $Id: backup_nas_configfiles.sh 10 2017-06-28 12:51:26Z fixer $
# @date $Date: 2017-06-28 22:51:26 +1000 (Śr, 28 cze 2017) $
# @revision $Revision: 10 $
# @author $Author: fixer $
# @headurl $HeadURL: svn://.../repo_backup/backup_nas_configfiles.sh $

if [ "$BACKUP_CONFIG_FILES" = true ]; then
  echo "======================" >> "$LOG_FILE"
  echo "13. Compressing Synology config files" >> "$LOG_FILE"
  echo $(date +'%d-%m-%Y %H:%M:%S') >> "$LOG_FILE"
  echo "======================" >> "$LOG_FILE"
  
  #lista plików
  echo "/etc/*.allow"                     > "${BACKUP_DIR}/tmp_config_files.lst" #pierwszy musi mieć >
  echo "/etc/*.deny"                      >> "${BACKUP_DIR}/tmp_config_files.lst"
  echo "/etc/*.db"                        >> "${BACKUP_DIR}/tmp_config_files.lst"
  echo "/etc/*.conf"                      >> "${BACKUP_DIR}/tmp_config_files.lst"
  echo "/etc/*.secrets"                   >> "${BACKUP_DIR}/tmp_config_files.lst"
  echo "/etc/*.key"                       >> "${BACKUP_DIR}/tmp_config_files.lst"
  echo "/etc.defaults/*.deny"             >> "${BACKUP_DIR}/tmp_config_files.lst"
  echo "/etc.defaults/*.db"               >> "${BACKUP_DIR}/tmp_config_files.lst"
  echo "/etc.defaults/*.conf"             >> "${BACKUP_DIR}/tmp_config_files.lst"
  echo "/etc.defaults/*.secrets"          >> "${BACKUP_DIR}/tmp_config_files.lst"
  echo "/etc/profile"                     >> "${BACKUP_DIR}/tmp_config_files.lst"
  echo "/etc/ftpusers"                    >> "${BACKUP_DIR}/tmp_config_files.lst"
  echo "/etc/group"                       >> "${BACKUP_DIR}/tmp_config_files.lst"
  echo "/etc/crontab"                     >> "${BACKUP_DIR}/tmp_config_files.lst"
  echo "/etc/passwd"                      >> "${BACKUP_DIR}/tmp_config_files.lst"
  echo "/etc/shadow"                      >> "${BACKUP_DIR}/tmp_config_files.lst"
  echo "/etc/hosts"                       >> "${BACKUP_DIR}/tmp_config_files.lst"
  echo "/etc/fstab"                       >> "${BACKUP_DIR}/tmp_config_files.lst"
  echo "/etc.defaults/profile"            >> "${BACKUP_DIR}/tmp_config_files.lst"
  echo "/etc.defaults/ftpusers"           >> "${BACKUP_DIR}/tmp_config_files.lst"
  echo "/etc.defaults/group"              >> "${BACKUP_DIR}/tmp_config_files.lst"
  echo "/etc.defaults/crontab"            >> "${BACKUP_DIR}/tmp_config_files.lst"
  echo "/etc.defaults/passwd"             >> "${BACKUP_DIR}/tmp_config_files.lst"
  echo "/etc.defaults/shadow"             >> "${BACKUP_DIR}/tmp_config_files.lst"
  echo "/etc.defaults/hosts"              >> "${BACKUP_DIR}/tmp_config_files.lst"
  echo "/etc.defaults/fstab"              >> "${BACKUP_DIR}/tmp_config_files.lst"
  echo "/usr/syno/synoman/.htaccess"      >> "${BACKUP_DIR}/tmp_config_files.lst"
  echo "/var/packages/MariaDB/etc/my.cnf" >> "${BACKUP_DIR}/tmp_config_files.lst"
  
  #lista folderów
  echo "/etc/firewall/"                   > "${BACKUP_DIR}/tmp_config_folders.lst" #pierwszy musi mieć >
  echo "/etc/httpd/conf/"                 >> "${BACKUP_DIR}/tmp_config_folders.lst"
  echo "/etc/mysql/"                      >> "${BACKUP_DIR}/tmp_config_folders.lst"
  echo "/etc/postgresql/"                 >> "${BACKUP_DIR}/tmp_config_folders.lst"
  echo "/etc/php/"                        >> "${BACKUP_DIR}/tmp_config_folders.lst"
  echo "/etc/ssh/"                        >> "${BACKUP_DIR}/tmp_config_folders.lst"
  echo "/etc/httpd/logs/"                 >> "${BACKUP_DIR}/tmp_config_folders.lst"
  echo "/etc.defaults/ssh/"               >> "${BACKUP_DIR}/tmp_config_folders.lst"
  echo "/etc.defaults/php/"               >> "${BACKUP_DIR}/tmp_config_folders.lst"
  echo "/etc/httpd/sites-enabled-user/"   >> "${BACKUP_DIR}/tmp_config_folders.lst"
  echo "/usr/bin/ncftp/"                  >> "${BACKUP_DIR}/tmp_config_folders.lst"
  echo "/usr/bin/p7zip/"                  >> "${BACKUP_DIR}/tmp_config_folders.lst"
  echo "/usr/bin/rar/"                    >> "${BACKUP_DIR}/tmp_config_folders.lst"
  echo "/usr/syno/apache/conf/"           >> "${BACKUP_DIR}/tmp_config_folders.lst"
  echo "/usr/syno/etc/"                   >> "${BACKUP_DIR}/tmp_config_folders.lst" #php.ini, smb.conf, rc.d/autorun.sh, login_background.jpg
  echo "/usr/syno/etc.defaults/"          >> "${BACKUP_DIR}/tmp_config_folders.lst" #php.ini, smb.conf, rc.d/autorun.sh, login_background.jpg
  echo "/usr/syno/mysql/share/"           >> "${BACKUP_DIR}/tmp_config_folders.lst"
  echo "/usr/syno/avahi/services"         >> "${BACKUP_DIR}/tmp_config_folders.lst"
  echo "/var/log/synolog/"                >> "${BACKUP_DIR}/tmp_config_folders.lst"
  echo "/var/packages/MailServer/target/etc/template/"  >> "${BACKUP_DIR}/tmp_config_folders.lst"

  #pakujemy p7zip'em
  #p7z  - is a file archiver utility
  #p7za - is a stand-alone executable handling less archive formats than 7z
  #p7zr - is a minimal version of 7za that handles only 7z archives (to wersja okrojona wspierająca wyłącznie format kompresji 7z)
  echo "[$(date +'%d-%m-%Y %H:%M:%S')] Compressing Synology config files to: ${BACKUP_DIR}/backup_configfiles_${TIMESTAMP}.7z"
  TIMESTAMP=$(date +'%Y-%m-%d_%H-%M-%S')
  /usr/bin/p7zip/7zr a "${BACKUP_DIR}/backup_configfiles_${TIMESTAMP}.7z" -spf2 -t7z -m0=lzma2 -ms=off -mmt=off -mfb=64 -md=32m -mhe -mx9 -v${SPLIT_VOLUME} -p"${PASSWORD}" -ir@"${BACKUP_DIR}/tmp_config_folders.lst" -i@"${BACKUP_DIR}/tmp_config_files.lst" -xr!Thumbs.db -xr!@eaDir -xr!@tmp -xr!#recycle -xr!lost+found -xr!.DS_Store >> "$LOG_FILE2"

#TODO: usuwanie

  if [ "$TESTS_ARCHIVE_FILES" = true ] ; then
    echo "[$(date +'%d-%m-%Y %H:%M:%S')] Verifying files in the archive: backup_configfiles_${TIMESTAMP}.7z.001" >> "$LOG_FILE"
    /usr/bin/p7zip/7zr t "${BACKUP_DIR}/backup_configfiles_${TIMESTAMP}.7z.001" -t7z.split -p"${PASSWORD}" >> "$LOG_FILE2"
  fi

  echo "[$(date +'%d-%m-%Y %H:%M:%S')] Deleting folder list temp file: ${BACKUP_DIR}/tmp_config_folders.lst" >> "$LOG_FILE"
  if [ -f "${BACKUP_DIR}/tmp_config_folders.lst" ]; then
    rm -rf "${BACKUP_DIR}/tmp_config_folders.lst" #uwaga: tutaj trwale usuwamy plik wraz z jego zawartością (i wcale nie trafi on do #recycle)
    echo "[$(date +'%d-%m-%Y %H:%M:%S')] Folders list deleted" >> "$LOG_FILE"
  fi

  echo "[$(date +'%d-%m-%Y %H:%M:%S')] Deleting files list temp file: ${BACKUP_DIR}/tmp_config_files.lst" >> "$LOG_FILE"
  if [ -f "${BACKUP_DIR}/tmp_config_files.lst" ]; then
    rm -rf "${BACKUP_DIR}/tmp_config_files.lst" #uwaga: tutaj trwale usuwamy plik wraz z jego zawartością (i wcale nie trafi on do #recycle)
    echo "[$(date +'%d-%m-%Y %H:%M:%S')] Files list deleted" >> "$LOG_FILE"
  fi

fi
echo " Compressing Synology config files FINISH! " >> "$LOG_FILE"
echo " " >> "$LOG_FILE"