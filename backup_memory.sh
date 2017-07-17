#!/bin/sh

# @version $Id: backup_memory.sh 8 2017-06-26 10:07:43Z fixer $
# @date $Date: 2017-06-26 20:07:43 +1000 (Pn, 26 cze 2017) $
# @revision $Revision: 8 $
# @author $Author: fixer $
# @headurl $HeadURL: svn://.../repo_backup/backup_memory.sh $

FREE_MEMORY=`cat /proc/meminfo | grep 'MemFree:' | awk '{print $2}'`
echo "[$(date +'%d-%m-%Y %H:%M:%S')] Free memory: $(($FREE_MEMORY / 1024)) MB" >> "$LOG_FILE"

if [ $(($FREE_MEMORY / 1024)) -lt 100 ] ; then
  echo "WARNING: There is no free memory in NAS, this script require a minimum 100 MB" >> "$LOG_FILE"
  echo "[$(date +'%d-%m-%Y %H:%M:%S')] Script stopped!" >> "$LOG_FILE"
  exit 0
fi

echo " " >> "$LOG_FILE"

if [ "$USE_NCFTP" = true ] ; then
  file="/usr/bin/ncftp/ncftpput"
  if [ ! -e "$file" ]; then
    echo "WARNING: There is no sender module called: 'ncftp', download from: 'http://www.ncftp.com/download/'" >> "$LOG_FILE"
    echo "Then copy binary files (use WinSCP) to this folder: '/usr/bin/ncftp/'" >> "$LOG_FILE"
    echo "Now you have to set the rights to a folder by typing: find "\"/usr/bin/ncftp/\"" -exec chmod 755 {} \;" >> "$LOG_FILE"
    echo "You can also use the CURL module instead of ncftp" >> "$LOG_FILE"
    echo "[$(date +'%d-%m-%Y %H:%M:%S')] Script stopped!" >> "$LOG_FILE"
    exit 0
  fi
fi

echo " " >> "$LOG_FILE"