#!/bin/sh

# @version $Id: backup_mail.sh 8 2017-06-26 10:07:43Z fixer $
# @date $Date: 2017-06-26 20:07:43 +1000 (Pn, 26 cze 2017) $
# @revision $Revision: 8 $
# @author $Author: fixer $
# @headurl $HeadURL: svn://.../repo_backup/backup_mail.sh $

# EMAIL_MESSAGE=$(<${LOG_FILE});
EMAIL_MESSAGE=`cat ${LOG_FILE}` #wczytanie zawartości logu
# EMAIL_MESSAGE="Zrobione..."

# METODA 1 (bezpieczna, ale problem z wysłaniem logów w message)
echo "[$(date +'%d-%m-%Y %H:%M:%S')] Sending e-mail with short logs" >> "$LOG_FILE"
/usr/bin/php -r "mail('${EMAIL_TO}','${EMAIL_SUBJECT}','${EMAIL_MESSAGE}','From: ${EMAIL_SENDER}');"; 2> /dev/null

# METODA 2 (mniej bezpieczna ale za to z załącznikiem)
# curl --url 'smtps://smtp.gmail.com:465' --ssl-reqd --mail-from 'username@gmail.com' --mail-rcpt 'john@example.com' --upload-file mail.txt --user 'username@gmail.com:password' --insecure

# METODA 3 (mniej uniwersalna bo może działać tylko na NAS'ie Synology)
# sendmail -F "Synology Station" -f "youraccount@gmail.com" -t receiver@domain.com << EOF
# Subject: Synology Mail Test
# Seems to work. Hooray.
# EOF

#  ================ [PRZYWRACANIE BAZY DANYCH] ===================
# wcześniej należy rozpakować plik *.7z (7z x test.zip -aoa -oc:\recovery)
# mysql --host=${DB_HOST} --port=${DB_PORT} --user=${DB_USER} --password=${DB_PASS} --no-beep --default-character-set=utf8 -e "SET GLOBAL max_allowed_packet=18446744073709551615; SOURCE restore_db.sql"
