#!/bin/sh

# @version $Id: backup_config.sh 7 2017-06-15 05:53:23Z fixer $
# @date $Date: 2017-06-15 15:53:23 +1000 (Cz, 15 cze 2017) $
# @revision $Revision: 7 $
# @author $Author: fixer $
# @headurl $HeadURL: svn://.../repo_backup/backup_config.sh $

# ==================== [SETTINGS] ====================
#ścieżka do katalogu WEB (strony internetowe)
WEB_DIR="/volume1/web" #ścieżka ma być bez slash'a na końcu!!

# LOCAL SOURCE (MariaDB)
DB_HOST="" #adres IP synka
DB_PORT="3306" #port na którym pracuje baza mysql/mariaDB (domyślnie 3306)
DB_USER="" #musi być podany użytkownik na prawach administratora
DB_PASS=""
DB_EXLUDED="Database|information_schema|performance_schema" #te bazy pomijamy w backup'ie

# REMOTE SOURCE (MariaDB)  PROJECT
REMOTE1_DB_HOST="" #zdalny adres IP lub adres host'a
REMOTE1_DB_PORT="3306" #port, na którym pracuje baza mysql/mariaDB (domyślnie 3306)
REMOTE1_DB_USER="" #musi być podany użytkownik na prawach administratora
REMOTE1_DB_PASS=""
REMOTE1_DB_EXLUDED="Database|information_schema|performance_schema" #te bazy pomijamy w backup'ie

# REMOTE SOURCE (MariaDB) 
REMOTE2_DB_HOST="" #zdalny adres IP lub adres host'a
REMOTE2_DB_PORT="3306" #port, na którym pracuje baza mysql/mariaDB (domyślnie 3306)
REMOTE2_DB_USER="" #musi być podany użytkownik na prawach administratora
REMOTE2_DB_PASS=""
REMOTE2_DB_EXLUDED="Database|information_schema|performance_schema" #te bazy pomijamy w backup'ie

# folder /volume1/web (te foldery pomijamy w pakowaniu do archiwum *.7z)
FOLDER_EXLUDED="#recycle|@eaDir|cgi-bin"

# folder /volume1/photo/ (te foldery pomijamy w pakowaniu do archiwum *.7z)
FOLDER_PHOTO_EXLUDED="#recycle|@eaDir|cgi-bin" #te foldery pomijamy w pakowaniu do archiwum *.7z

# folder /volume1/svn/ (te foldery pomijamy w pakowaniu do archiwum *.7z)
FOLDER_SVN_EXLUDED="#recycle|@eaDir|cgi-bin|dumps" #te foldery pomijamy w pakowaniu do archiwum *.7z


DELETE_OLD_LOCAL_BACKUP=true # ustaw true (zalecane) jeśli chcesz aby poprzedni backup automatycznie zostawał usunięty (z synka)
                             # ustaw false jeśli chcesz aby stary backup pozostał (wtedy masz wersonowanie na pełnych kopiach)

DELETE_OLD_FTP_BACKUP=false # ustaw true jeśli chcesz aby poprzedni backup automatycznie zostawał usunięty (z FTP)
                            # ustaw false (zalecane) jeśli chcesz aby stary backup pozostał (wtedy masz wersjonowanie na pełnych kopiach)

# DESTINATION 1 (NAS)
BACKUP_DIR="/volume2/backup" #ścieżka docelowa na kopie zapasowe, ma być bez slash'a na końcu!!

BACKUP_PHOTO=true #true = ma wykonywać kopię zdjęć z nasa, false = pomija
PHOTO_DIR="/volume1/photo" #tu znajdują się nasze fotki, ścieżka ma być bez slash'a na końcu!!

BACKUP_SVN=true #true = ma wykonywać kopię folderu SVN z nasa, false = pomija
BACKUP_SVN_DUMPS=true #true = ma wykonywać zrzut wybranego repozytorium do pojedyńczego pliku DUMP z nasa, false = pomija
SVN_DIR="/volume1/svn" #tu znajdują się nasze repozytoria SVN, ścieżka ma być bez slash'a na końcu!!

SEND_TO_FTP=true #ustaw true jeśli chcesz dodatkowo twój backup wysłać na jakiś serwer FTP w przeciwnym razie ustaw false

#pierw sprawdź czy Twój wybrany serwer FTP przyjmie polecenia z CRON'a i wyśle poprawnie plik, wklep to do konsoli synka:
#curl -s -v -T /volume1/backup/backup_1.7z -u LOGIN:HASLO ftp://IP/backup/

USE_NCFTP=true # ustaw false - używa wbudowanego w Synology CURL'a jako klienta FTP do wysyłania plików
               # ustaw true  - używa klienta ftp NCFTP (zalecane)

# kopia lustrzana, którą chcemy wysłać na zewnętrzny serwer FTP
# dopilnuj aby istniał folder o nazwie "backup" zaraz w głównym katalogu
FTP_HOST=""
FTP_USER=""
FTP_PASS=""
FTP_PORT="21"

#funkcja testowa start
BACKUP_ONE_BY_ONE=false #funkcja testowa więc zalecane false (pakowanie i szyfrowanie każdego pliku z osobna bez kompresji do 7zip'a i wysyłanie na serwer FTP z zachowaniem układu oryginalnych ścieżek)
FOLDER="/volume1/backup" #miejsce z którego będziemy kopiować każdy plik z osobna i szyfrować i wysyłać na serwer FTP
FTP_FOLDER="/backup" #folder na serwerze ftp do którego trafią pliki
BACKUP_TMP_DIR="/volume3/backup_3/kopia_nas/tmp" #katalog tymczasowy na spakowane i zaszyfrowane pliki, gdy pliki zostaną wysłane katalog ten zostanie usunięty
#funkcja testowa stop

#TODO: funkcja w przygotowaniu (prawdopodobnie nie działa ona na volumen'ach) dlatego ustaw false
#przenieść tą opcję do argumentów wywołań skryptu "backup.sh full/diff"
#pierwsza kopia musi być pełna a kolejne mogą być już dyferencyjne
BACKUP_DIFFERENTIAL=false #false -full backup, true -differential backup

# inne darmowe chmury z dostępem przez FTP:
# FTP_HOST=""
# FTP_PORT=21
# FTP_USER=""
# FTP_PASS=""
# FTP_PORT=21

# FTP_HOST=""
# FTP_USER=""
# FTP_PASS=""
# FTP_PORT=21

# FTP_HOST=""
# FTP_USER=""
# FTP_PASS=""
# FTP_PORT=21

TIMESTAMP_START=$(date +'%Y-%m-%d_%H-%M-%S')
LOG_FILE="${BACKUP_DIR}/"log_general_"${TIMESTAMP_START}".log
LOG_FILE2="${BACKUP_DIR}/"log_list_"${TIMESTAMP_START}".log
# exec &> "${BACKUP_DIR}/"backup_log_"$(date +'%Y-%m-%d_%H-%M-%S')".log

# to jeszcze nie działa :)
DAYS_KEEP=30 #tyle czasu kopie będą przetrzymywane
KEEP=3       #ilość przechowywanych kopii
# to jeszcze nie działa :)

# reporting on e-mail
EMAIL_TO="adres@gmail.com"
EMAIL_SUBJECT="Monit skryptu AZWKZ - Automatyzacja Zadań Wykonywania Kopii Zapasowych z dnia: $(date +'%Y-%m-%d %H:%M:%S')"
EMAIL_SENDER="adres@gmail.com"
# reporting on e-mail

# weryfikacja archiwum pod kątem poprawności spakowania (znacząco wydłuża backup ale też zwiększa bezpieczeństwo)
# zalecane true tylko przy pierwszym odpaleniu skryptu, potem lepiej ustawić na false
TESTS_ARCHIVE_FILES=true

BACKUP_CONFIG_FILES=true #kopiuj pliki i foldery z konfiguracji NAS'a

# hasło w 7zip'ie może mieć nawet 1000 znaków (ale wydłużasz czas kompresji/dekompresji)
# minimalna zalecana długość to 15 znaków
# Hasło może zawierać kombinacje znaków (wraz ze spacją) za wyjątkiem tych znaków: $ ' " `
# bezpieczne losowe hasło możecie sobie wygenerować wpisujac to do konsoli:
# for i in `seq 10`; do echo; echo "Twoje nowe bezpieczne i losowe haslo nr $i to: "; </dev/urandom tr -dc 'A-Z-a-z-0-9 {}:<>?[];,./~!@#%^&*()_+-=|~' | head -c50; echo "" ; done
PASSWORD="MOJE_HASLO!" #wygeneruj hasło!
SPLIT_VOLUME="100m" #po 100 MB każdy plik (na zew. serwer ftp warto wgrywać względnie małymi paczkami - max 999m na plik)
SPLIT_PHOTO_VOLUME="4480m" #CD-650m/700m, FAT-4092M, DVD-4480m, DVD DL-8128M, BD-23040M (dla łatwej archiwizacji na płytach)

# projekt 
USE_FTP_REMOTE1=true #pobiera fizyczne pliki web przez FTP oraz wykonuje zrzut bazy danych, na końcu wszystko kompresuje
REMOTE1_FTP_NAME=""
REMOTE1_FTP_HOST=""
REMOTE1_FTP_USER=""
REMOTE1_FTP_PASS=""
REMOTE1_FTP_PORT="21"
REMOTE1_FTP_DIR="/public_html"

# projekt 
USE_FTP_REMOTE2=true #pobiera fizyczne pliki web przez FTP oraz wykonuje zrzut bazy danych, na końcu wszystko kompresuje
REMOTE2_FTP_NAME=""
REMOTE2_FTP_HOST=""
REMOTE2_FTP_USER=""
REMOTE2_FTP_PASS=""
REMOTE2_FTP_PORT="21"
REMOTE2_FTP_DIR="/public_html"
# ==================== [SETTINGS] ====================